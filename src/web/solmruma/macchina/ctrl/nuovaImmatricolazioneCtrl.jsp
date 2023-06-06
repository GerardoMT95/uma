<%@ page language="java" contentType="text/html" isErrorPage="true"%>

<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%!private static final String VIEW      = "/macchina/view/nuovaImmatricolazioneView.jsp";
  private static final String ELENCO    = "../layout/elencoMacchine.htm";
  private static final String DETTAGLIO = "../layout/dettaglioMacchinaDittaImmatricolazioni.htm";
  private static final String CONFERMA  = "../layout/nuovaImmatricolazioneConferma.htm";%>
<%
  String iridePageName = "nuovaImmatricolazioneCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%
  UmaFacadeClient umaClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  ValidationErrors errors = new ValidationErrors();
  MacchinaVO mavo = new MacchinaVO();
  MovimentiTargaVO movo = new MovimentiTargaVO();
  SolmrLogger.debug(this, "[nuovaImmatricolazioneCtrl::service] ###");
  if (session.getAttribute("common") instanceof MacchinaVO)
  {
    mavo = (MacchinaVO) session.getAttribute("common");
  }
  else
    if (request.getParameter("idMacchina") != null)
    {
      Long idMacchina = new Long((String) request
          .getParameter("idMacchina"));
      mavo = umaClient.getMacchinaById(idMacchina);
    }
    
  if (mavo!=null && umaClient.isBloccoMacchinaImportataAnagrafe(mavo)) 
  {  
    it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::errorMessage!=null] utente non abilitato: "+it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
    request.setAttribute("errorMessage",it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
    %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
    return;
  }  
    
    
  movo = umaClient.getUltimaMovimentazioneByIdMacchina(mavo
      .getIdMacchinaLong());
  SolmrLogger
      .debug(
          this,
          "[nuovaImmatricolazioneCtrl::service] movo = umaClient.getUltimaMovimentazioneByIdMacchina("
              + mavo.getIdMacchinaLong() + "); ");
  SolmrLogger.debug(this, "[nuovaImmatricolazioneCtrl::service] movo = "
      + movo);
  SolmrLogger.debug(this,
      "[nuovaImmatricolazioneCtrl::service] movo.getIdNumeroTarga() "
          + movo.getIdNumeroTarga());
  SolmrLogger.debug(this, "[nuovaImmatricolazioneCtrl::service] ###");

  if (request.getParameter("annulla") != null)
  {
    response.sendRedirect(DETTAGLIO);
    return;
  }
  else
    if (request.getParameter("elenco") != null)
    {
      session.removeAttribute("common");
      response.sendRedirect(ELENCO);
      return;
    }

  if (request.getParameter("conferma") != null)
  {
    errors = validate(request, umaClient);
    if (errors != null)
    {
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] validazione fallita errors="
              + errors);
      request.setAttribute("errors", errors);
      request.setAttribute("movo", movo);
%><jsp:forward page="<%=VIEW%>" />
<%
  return;
    }
    else
    {
      Long idMovimentazione = new Long(((String) request
          .getParameter("idMovimentazione")).trim());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] validazione ok. idMovimentazione = "
              + idMovimentazione);
      request.setAttribute("idMovimentazione", idMovimentazione.toString());
    }

    try
    {
      DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
          .getAttribute("dittaUMAAziendaVO");

      TargaVO tavo = movo.getDatiTarga();
      if (tavo == null)
        tavo = new TargaVO();

      if ("stradale".equalsIgnoreCase(request.getParameter("tipoTarga")))
      {
        tavo.setIdTarga(getTipoNuovaTarga(mavo, true));
      }
      else
        if ("uma".equalsIgnoreCase(request.getParameter("tipoTarga")))
        {
          tavo.setIdTarga(getTipoNuovaTarga(mavo, false));
        }
      String radioNumeroTarga = request.getParameter("radioNumeroTarga");
      if ("D".equals(radioNumeroTarga))
      {
        tavo.setNuovoNumeroTargaAssegnatoDaUtente(request.getParameter("numeroTarga"));
      }
      else
      {
        tavo.setNumeroTarga(null);
      }
      tavo.setMc_824(request.getParameter("mc824"));
      tavo.setIdProvincia(dittaUMAAziendaVO.getProvUMA());
      movo.setIdMovimentazione(request.getParameter("idMovimentazione"));
      movo.setIdProvincia(dittaUMAAziendaVO.getProvUMA());
      movo.setDittaUma(dittaUMAAziendaVO.getDittaUMAstr());

      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] tavo.getIdTarga()"
              + tavo.getIdTarga());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] tavo.getMc_824()"
              + tavo.getMc_824());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] tavo.getFlagTargaNuova()"
              + tavo.getFlagTargaNuova());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] tavo.getIdProvincia()"
              + tavo.getIdProvincia());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] movo.getIdMovimentazione()"
              + movo.getIdMovimentazione());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] movo.getIdMovimentiTarga()"
              + movo.getIdMovimentiTarga());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] movo.getIdProvincia()"
              + movo.getIdProvincia());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] tavo.getDittaUma()"
              + movo.getDittaUma());
      SolmrLogger.debug(this, "[nuovaImmatricolazioneCtrl::service] ");
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] movo.getIdMacchina() "
              + movo.getIdMacchina());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] movo.getIdNumeroTarga()"
              + movo.getIdNumeroTargaLong());
      TargaVO tvo = movo.getDatiTarga();
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] movo.getDatiTarga() "
              + movo.getDatiTarga());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] tvo.getIdNumeroTarga() "
              + tvo.getIdNumeroTargaLong());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] tvo.getIdMacchina() "
              + tvo.getIdMacchinaLong());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] tvo.getIdTarga() "
              + tvo.getIdTargaLong());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] tvo.getNumeroTarga() "
              + tvo.getNumeroTarga());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] tvo.getIdProvincia() "
              + tvo.getIdProvinciaLong());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] tvo.getFlagTargaNuova() "
              + tvo.getFlagTargaNuova());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] tvo.getMc_824() "
              + tvo.getMc_824());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] tvo.getExtIdUtenteAggiornamento() "
              + tvo.getExtIdUtenteAggiornamentoLong());
      SolmrLogger.debug(this,
          "[nuovaImmatricolazioneCtrl::service] tvo.getDataAggiornamento() "
              + tvo.getDataAggiornamentoDate());
      try
      {
        errors=umaClient.nuovaImmatricolazione(movo, ruoloUtenza);
        if (errors!=null)
        {
          request.setAttribute("errors",errors);
        }
        else
        {
          response.sendRedirect(CONFERMA);
          return;
        }
      }
      catch (SolmrException e)
      {
        throw e;
      }
      
    }
    catch (Exception e)
    {
      throwValidation(e.getMessage(), VIEW);
    }
  }
%><jsp:forward page="<%=VIEW%>" />
<%!private ValidationErrors validate(HttpServletRequest request,
      UmaFacadeClient umaClient)
  {
    ValidationErrors errors = new ValidationErrors();
    if ("".equals(request.getParameter("idMovimentazione")))
    {
      errors.add("idMovimentazione", new ValidationError(
          "Indicare il motivo della reimmatricolazione"));
    }
    String radioNumeroTarga = request.getParameter("radioNumeroTarga");
    String numeroTarga = request.getParameter("numeroTarga");
    if ("D".equals(radioNumeroTarga))
    {
      if (Validator.isEmpty(numeroTarga))
      {
        errors.add("numeroTarga", new ValidationError(
            "Specificare un numero targa"));
      }
     // -- TOLTI I CONTROLLI SUL FORMATO DELLA TARGA PER LA TOBECONFIG 
    /*  else
      {
        numeroTarga = numeroTarga.toUpperCase();
        Targhe targaUtil = new Targhe();
        String tipoTarga = request.getParameter("tipoTarga");
        if ("uma".equals(tipoTarga))
        {
          // Formato UMA
          if (!targaUtil.isValidUMA(numeroTarga))
          {
            errors.add("numeroTarga", new ValidationError(
                "La targa indicata non ha un formato valido"));
          }
          else
          {
            String istatProvincia = null;
            try
            {
              istatProvincia = umaClient
                  .getIstatProvinciaBySiglaProvincia(numeroTarga
                      .substring(0, 2));
            }
            catch (Exception e)
            {
              SolmrLogger.dumpStackTrace(this,
                  "[nuovaImmatricolazioneCtrl::service]", e);
              istatProvincia = null;
            }
            if (istatProvincia == null)
            {
              errors.add("numeroTarga", new ValidationError(
                  "La targa indicata non ha un formato valido"));
            }
          }
        }
        else
        {
          // Formato STRADALE
          if (!targaUtil.isValid(numeroTarga))
          {
            errors.add("numeroTarga", new ValidationError(
                "La targa indicata non ha un formato valido"));
          }
        }
      }*/
    }
    return errors.size() == 0 ? null : errors;
  }

  private void throwValidation(String msg, String validateUrl)
      throws ValidationException
  {
    ValidationException valEx = new ValidationException("Eccezione : " + msg,
        validateUrl);
    valEx.addMessage(msg, "exception");
    throw valEx;
  }

  private String getTipoNuovaTarga(MacchinaVO macchinaVO, boolean stradale)
  {
    String codBreveGenere = "";
    if (macchinaVO.getMatriceVO() != null)
      codBreveGenere = macchinaVO.getMatriceVO().getCodBreveGenereMacchina()
          .trim();
    else
      if (macchinaVO.getDatiMacchinaVO() != null)
        codBreveGenere = macchinaVO.getDatiMacchinaVO()
            .getCodBreveGenereMacchina().trim();

    if (SolmrConstants.COD_BREVE_GENERE_MACCHINA_T.equals(codBreveGenere)
        || SolmrConstants.COD_BREVE_GENERE_MACCHINA_D.equals(codBreveGenere)
        || SolmrConstants.COD_BREVE_GENERE_MACCHINA_MTS.equals(codBreveGenere)
        || SolmrConstants.COD_BREVE_GENERE_MACCHINA_MTA.equals(codBreveGenere))
    {
      if (stradale)
      {
        return SolmrConstants.TARGA_STRADALE_MA;
      }
      else
      {
        return SolmrConstants.TARGA_UMA;
      }
    }

    if (SolmrConstants.COD_BREVE_GENERE_MACCHINA_MAO.equals(codBreveGenere))
    {
      if (stradale)
      {
        return SolmrConstants.TARGA_MAO;
      }
      else
      {
        return SolmrConstants.TARGA_UMA;
      }
    }

    if (SolmrConstants.get("COD_BREVE_GENERE_MACCHINA_R")
        .equals(codBreveGenere))
    {
      return SolmrConstants.TARGA_STRADALE_RA;
    }
    return SolmrConstants.TARGA_UMA;
  }%>