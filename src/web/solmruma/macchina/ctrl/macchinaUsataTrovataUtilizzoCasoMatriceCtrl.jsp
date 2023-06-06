<%@ page language="java" contentType="text/html" isErrorPage="true"%>

<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.client.anag.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.dto.anag.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@page import="it.csi.solmr.etc.uma.UmaErrors"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%!private static final String VIEW              = "/macchina/view/macchinaUsataTrovataUtilizzoCasoMatriceView.jsp";
  private static final String PREV              = "../layout/macchinaUsataTrovataDatiCasoMatrice.htm";
  private static final String NEXT              = "../layout/macchinaUsataConferma.htm";
  private static final String ACQUISTA_MACCHINA = "../layout/macchinaUsataTarga.htm";
  private static final long   TARGA_UMA         = new Long(
                                                    SolmrConstants.TARGA_UMA)
                                                    .longValue();
  private static final long   TARGA_STRADALE_RA = new Long(
                                                    SolmrConstants.TARGA_STRADALE_RA)
                                                    .longValue();
  private static final long   TARGA_STRADALE_MA = new Long(
                                                    SolmrConstants.TARGA_STRADALE_MA)
                                                    .longValue();
  private static final long   TARGA_MAO         = new Long(
                                                    SolmrConstants.TARGA_MAO)
                                                    .longValue();%>
<%
  String iridePageName = "macchinaUsataTrovataUtilizzoCasoMatriceCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%
  Object commonObj = session.getAttribute("common");
  if (commonObj != null)
  {
    if (commonObj instanceof MovimentiTargaVO)
    {
      response.sendRedirect(NEXT);
    }
    else
    {
      if (!(commonObj instanceof java.util.HashMap))
      {
        response.sendRedirect(ACQUISTA_MACCHINA);
        return;
      }
    }
  }
  try
  {
    DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
        .getAttribute("dittaUMAAziendaVO");
    UmaFacadeClient umaClient = new UmaFacadeClient();
    AnagFacadeClient anagClient = new AnagFacadeClient();
    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
    SolmrLogger.debug(this,"macchinaUsataTrovataUtilizzoCasoMatriceCtrl.jsp");
    if (request.getParameter("salva") != null)
    {
      SolmrLogger.debug(this,"NEXT");
      ValidationErrors errors = validate(request, umaClient, anagClient);
      PossessoVO possessoVO = createPossessoVO(request);
      HashMap common = (HashMap) session.getAttribute("common");
      MacchinaVO macchinaVO = (MacchinaVO) common.get("macchinaVO");
      TargaVO targaVO = macchinaVO.getTargaCorrente();
      DittaUMAVO dittaProvenienzaVO = (DittaUMAVO) common
          .get("dittaProvenienzaVO");
      String tipoNuovaTarga = null;

      if ("yes".equalsIgnoreCase(request.getParameter("nuovaTarga")))
      {
        tipoNuovaTarga = getTipoNuovaTarga(macchinaVO, "Stradale"
            .equalsIgnoreCase(request.getParameter("tipoTarga")));
        String radioTarga = request.getParameter("radioTarga");
        if ("spec".equalsIgnoreCase(radioTarga))
        {
          String nuovoNumeroTarga = request
              .getParameter("nuovoNumeroTarga");
          checkFormatoTargaValido(nuovoNumeroTarga,
              new Long(tipoNuovaTarga).longValue(), errors, umaClient);
          targaVO.setNuovoNumeroTargaAssegnatoDaUtente(nuovoNumeroTarga);
        }
      }

      if (errors != null && errors.size() == 0)
      {
        SolmrLogger.debug(this,"prima di umaClient.acquistaMacchinaUsataConTarga");
        SolmrLogger.debug(this,"dittaProvenienzaVO=" + dittaProvenienzaVO);
        SolmrLogger.debug(this,"tipoNuovaTarga=" + tipoNuovaTarga);
        String mc824 = request.getParameter("mc824");
        if (mc824 != null)
        {
          targaVO.setMc_824(mc824);
        }
        MovimentiTargaVO movimentiTargaVO = umaClient
            .acquistaMacchinaUsataConTarga(dittaUMAAziendaVO, targaVO,
                new Long(dittaProvenienzaVO.getDittaUMA()),
                dittaProvenienzaVO.getProvincia(), tipoNuovaTarga,
                possessoVO, ruoloUtenza);
        SolmrLogger.debug(this,"dopo di umaClient.acquistaMacchinaUsataConTarga");
        //        movimentiTargaVO=umaClient.getMovimentazioneById(movimentiTargaVO.getIdMovimentiTargaLong());
        session.removeAttribute("common");
        /*if (tipoNuovaTarga!=null)
        {
          session.setAttribute("common",movimentiTargaVO);
        }*/
        //Implementazione acquisto usato di una macchina venduta fuori regione - Begin
        if (tipoNuovaTarga == null)
        {
          SolmrLogger.debug(this,"Modello49VO");
          Modello49VO modello49VO = new Modello49VO();
          modello49VO.setAnnoModello49(movimentiTargaVO.getAnnoModello());
          modello49VO.setNumeroModello49(movimentiTargaVO
              .getNumeroModello());

          SolmrLogger.debug(this,"\n\n\n\n\n----------------------------------------------");
          SolmrLogger.debug(this,"Caso MATRICE");
          SolmrLogger.debug(this,"modello49VO.getAnnoModello49(): "
              + modello49VO.getAnnoModello49());
          SolmrLogger.debug(this,"modello49VO.getNumeroModello49(): "
              + modello49VO.getNumeroModello49());

          //Modifica Attestazione Proprietà da macchina nuova - Begin
          Long idMacchina = new Long(movimentiTargaVO.getIdMacchina());

          SolmrLogger.debug(this,"\n\n\n+++++++++++++++++++++++++");
          SolmrLogger.debug(this,"idMacchina: " + idMacchina);

          modello49VO.setIdMacchina(movimentiTargaVO.getIdMacchina());
          //Modifica Attestazione Proprietà da macchina nuova - End

          session.setAttribute("common", modello49VO);
        }
        else
        {
          session.setAttribute("common", movimentiTargaVO);
        }
        //Implementazione acquisto usato di una macchina venduta fuori regione - End
        if (movimentiTargaVO.getDatiTarga() != null)
        {
          SolmrLogger.debug(this,"movimentiTargaVO.getDatiTarga().getNumeroTarga()="
                  + movimentiTargaVO.getDatiTarga().getNumeroTarga());
        }
        SolmrLogger.debug(this,"request.getParameter(\"tipoTarga\")="
            + request.getParameter("tipoTarga"));

        response.sendRedirect(NEXT);
        SolmrLogger.debug(this,"do redirect");
        return;
      }
      else
      {
        SolmrLogger.debug(this,"erros=" + errors);
        request.setAttribute("errors", errors);
      }
    }
    else
    {
      if (request.getParameter("indietro") != null)
      {
        SolmrLogger.debug(this,"PREV");
        response.sendRedirect(PREV);
        return;
      }
      else
      {

      }
    }
  }
  catch (SolmrException e)
  {
    ValidationErrors errors = new ValidationErrors();
    errors.add("error", new ValidationError(e.getMessage()));
    request.setAttribute("errors", errors);
  }
  catch (Exception e)
  {
    SolmrLogger.debug(this,"\n\n\n--------------------------------------------------");
    SolmrLogger.debug(this,"Errore di sistema=" + e.getMessage());
    SolmrLogger.debug(this,"--------------------------------------------------\n\n\n");
    ValidationErrors errors = new ValidationErrors();
    errors.add("error", new ValidationError(
        "Si è verificato un errore di sistema!"));
    request.setAttribute("errors", errors);
  }
%>
<jsp:forward page="<%=VIEW%>" />
<%!private ValidationErrors validate(HttpServletRequest request,
      UmaFacadeClient umaClient, AnagFacadeClient anagClient) throws Exception
  {
    ValidationErrors errors = new ValidationErrors();
    String dataCarico = request.getParameter("dataCarico");
    String dataScadenzaLeasing = request.getParameter("dataScadenzaLeasing");
    String idFormaPossesso = request.getParameter("idFormaPossesso");
    String idSocietaLeasing = request.getParameter("idSocietaLeasing");
    //boolean leasingRequired = SolmrConstants.LEASING.equals(idFormaPossesso)
        //|| SolmrConstants.NOLEGGIO.equals(idFormaPossesso);

    //SolmrLogger.debug(this,"leasingRequired=" + leasingRequired);
    SolmrLogger.debug(this,"idFormaPossesso=" + idFormaPossesso);
    //SolmrLogger.debug(this,"SolmrConstants.NOLEGGIO=" + SolmrConstants.NOLEGGIO);
    //SolmrLogger.debug(this,"SolmrConstants.LEASING=" + SolmrConstants.LEASING);
    
    SolmrLogger.debug(this,"dataCarico=" + dataCarico);
    Validator.validateDateAll(dataCarico, "dataCarico", "data di carico",
        errors, true, true);
    if ("".equals(idFormaPossesso))
    {
      errors.add("idFormaPossesso", new ValidationError(
          "Indicare la forma di possesso"));
    }
    else
    {
    
      // se idFormaPossesso = 'Leasing' o 'Utilizzo/Noleggio' -> data scadenza obbligatoria     
      if(idFormaPossesso.equals(SolmrConstants.get("LEASING")) ||
         idFormaPossesso.equals(SolmrConstants.get("UTILIZZO_NOLEGGIO")))
      { 
        if(!Validator.isNotEmpty(dataScadenzaLeasing))
        {
          errors.add("dataScadenzaLeasing",new ValidationError("Valorizzare la data scadenza contratto"));
        }
        else
        {
          if(!Validator.validateDateF(dataScadenzaLeasing)) 
          {
            errors.add("dataScadenzaLeasing",new ValidationError("Valorizzare la data correttamente"));
          }
          else
          {
            Date data = null;
            Date oggi = null;
            try
            {
              data = UmaBaseVO.parseDate(dataScadenzaLeasing);
              oggi = UmaBaseVO.parseDate(UmaDateUtils.getCurrentDateString());
            }
            catch(Exception ex)
            {
              errors.add("dataScadenzaLeasing",new ValidationError("Errore nel formato della data"));
            }
            if(!data.after(oggi))
            {
              errors.add("dataScadenzaLeasing",new ValidationError("La data scadenza contratto deve essere superiore alla data odierna"));
            }
          }
        } 
        // se idFormaPossesso = 'Leasing' -> società di leasing obbligatoria
        if(idFormaPossesso.equals(SolmrConstants.get("LEASING")))
        {
          //errors.add("idSocietaLeasing",new ValidationError("Valorizzare la ditta di leasing"));
          if (!Validator.isNotEmpty(idSocietaLeasing))
	        {
	          errors.add("idSocietaLeasing", new ValidationError(
	              "Indicare la società di leasing"));
	        }
	        else
	        {
	          if (errors.get("idSocietaLeasing") == null)
	          {
	            AnagAziendaVO dittaLeasing = null;
	            try
	            {
	              dittaLeasing = anagClient.findAziendaAttiva(new Long(
	                  idSocietaLeasing));
	              PersonaFisicaVO rapprLegale = anagClient
	                  .getTitolareORappresentanteLegaleAzienda(dittaLeasing
	                      .getIdAzienda(), new Date());
	              dittaLeasing.setRappresentanteLegale(rapprLegale.getNome() + " "
	                  + rapprLegale.getCognome());
	            }
	            catch (SolmrException e)
	            {
	              ValidationError errVal = new ValidationError("Ditta non trovata!");
	              errors.add("societaLeasing", errVal);
	            }
	            request.setAttribute("dittaLeasing", dittaLeasing);
	          }
	        }
          
          
          
        }   
      }
      // in tutti gli altri casi, se viene indicata una data scadenza (facoltativa), deve essere una data valida
      else
      {
        if(Validator.isNotEmpty(dataScadenzaLeasing))
        {
          if(!Validator.validateDateF(dataScadenzaLeasing)) 
          {
            errors.add("dataScadenzaLeasing",new ValidationError("Valorizzare la data correttamente"));
          }
          else
          {
            Date data = null;
            Date oggi = null;
            try
            {
              data = UmaBaseVO.parseDate(dataScadenzaLeasing);
              oggi = UmaBaseVO.parseDate(UmaDateUtils.getCurrentDateString());
            }
            catch(Exception ex)
            {
              errors.add("dataScadenzaLeasing",new ValidationError("Errore nel formato della data"));
            }
            if(!data.after(oggi))
            {
              errors.add("dataScadenzaLeasing",new ValidationError("La data scadenza contratto deve essere superiore alla data odierna"));
            }
          }
        }
      }
    
    
	    /*if (leasingRequired)
	    {
	      if (!Validator.isNotEmpty(idSocietaLeasing))
	      {
	        errors.add("idSocietaLeasing", new ValidationError(
	            "Indicare la società di leasing"));
	      }
	      else
	      {
	        if (errors.get("idSocietaLeasing") == null)
	        {
	          AnagAziendaVO dittaLeasing = null;
	          try
	          {
	            dittaLeasing = anagClient.findAziendaAttiva(new Long(
	                idSocietaLeasing));
	            PersonaFisicaVO rapprLegale = anagClient
	                .getTitolareORappresentanteLegaleAzienda(dittaLeasing
	                    .getIdAzienda(), new Date());
	            dittaLeasing.setRappresentanteLegale(rapprLegale.getNome() + " "
	                + rapprLegale.getCognome());
	          }
	          catch (SolmrException e)
	          {
	            ValidationError errVal = new ValidationError("Ditta non trovata!");
	            errors.add("societaLeasing", errVal);
	          }
	          request.setAttribute("dittaLeasing", dittaLeasing);
	        }
	      }
	      
	      Validator.validateDateAfterToDay(dataScadenzaLeasing,
	          "dataScadenzaLeasing", "data di scadenza del leasing", errors,
	          leasingRequired, true);
	    }*/

    }
    return errors;
  }

  private PossessoVO createPossessoVO(HttpServletRequest request)
  {
    PossessoVO possessoVO = new PossessoVO();
    possessoVO.setIdFormaPossesso(request.getParameter("idFormaPossesso"));
    possessoVO.setDataScadenzaLeasing(request
        .getParameter("dataScadenzaLeasing"));
    possessoVO.setDataInizioValidita(request.getParameter("dataCarico"));
    AnagAziendaVO dittaLeasing = (AnagAziendaVO) request
        .getAttribute("dittaLeasing");
    if (dittaLeasing != null)
    {
      possessoVO.setExtIdAziendaLong(dittaLeasing.getIdAzienda());
    }
    return possessoVO;
  }

  private String getTipoNuovaTarga(MacchinaVO macchinaVO, boolean stradale)
  {
    String codBreveGenere = macchinaVO.getMatriceVO()
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
    return SolmrConstants.TARGA_UMA;

  }

  private ValidationErrors checkFormatoTargaValido(String numeroTarga,
      long formatoTarga, ValidationErrors errors, UmaFacadeClient umaClient)
      throws SolmrException
  {

    if (Validator.isEmpty(numeroTarga))
    {
      errors.add("nuovoNumeroTarga", new ValidationError(
          UmaErrors.ERRORE_VAL_CAMPO_OBBLIGATORIO));
      return errors;
    }

    Targhe targaValidator = new Targhe();
    boolean targaValida = true;

   // TOLTI CONTROLLI SUL FORMATO DELLA TARGA PER LA TOBECONFIG
   /* if (formatoTarga == TARGA_UMA)
    {
      SolmrLogger.debug(this, "formatoTarga.longValue() == TARGA_UMA");
      targaValida = targaValidator.isValidUMA(numeroTarga);
    }
    SolmrLogger.debug(this, "targaValidator.isValidUMA(" + numeroTarga + "): "
        + targaValida);

    if (formatoTarga == TARGA_STRADALE_RA || formatoTarga == TARGA_STRADALE_MA
        || formatoTarga == TARGA_MAO)
    {
      SolmrLogger
          .debug(
              this,
              "formatoTarga.longValue().longValue() == TARGA_STRADALE_RA,TARGA_STRADALE_MA,TARGA_MAO");
      targaValida = targaValidator.isValid(numeroTarga);
    }
    SolmrLogger.debug(this, "targaValidator.isValid(" + numeroTarga + "): "
        + targaValida);

    if (targaValida == false)
    {
      errors.add("nuovoNumeroTarga", new ValidationError(""
          + SolmrConstants.get("FORMATO_TARGA_NON_VALIDA")));
    }
    else
    {
      checkTargaUnica(numeroTarga, formatoTarga, errors, umaClient);
    }
    */
    checkTargaUnica(numeroTarga, formatoTarga, errors, umaClient);

    return errors;
  }

  private ValidationErrors checkTargaUnica(String numeroTarga, long formatoTarga,
      ValidationErrors errors, UmaFacadeClient umaClient) throws SolmrException
  {
    TargaVO targaVO = null;
    Long idNumeroTarga = null;

    if (formatoTarga == TARGA_UMA)
    {
      SolmrLogger.debug(this,
          "if(formatoTarga.longValue() == TARGA_UMA.longValue())");
      targaVO = umaClient.findTargaByNumeroAndTipo(numeroTarga, new Long(TARGA_UMA));
      idNumeroTarga = targaVO.getIdNumeroTargaLong();
      if (idNumeroTarga != null)
      {
        errors.add("nuovoNumeroTarga",
            new ValidationError("Targa UMA già assegnata"));
        return errors;
      }
    }

    if (formatoTarga == TARGA_STRADALE_RA)
    {
      SolmrLogger.debug(this,
          "if(formatoTarga.longValue() == TARGA_STRADALE_RA.longValue())");
      targaVO = umaClient.findTargaByNumeroAndTipo(numeroTarga,
          new Long(TARGA_STRADALE_RA));
      idNumeroTarga = targaVO.getIdNumeroTargaLong();
      if (idNumeroTarga != null)
      {
        errors.add("nuovoNumeroTarga", new ValidationError(
            "Targa STRADALE RA già assegnata"));
        return errors;
      }
    }

    if (formatoTarga == TARGA_STRADALE_MA)
    {
      SolmrLogger.debug(this,
          "if(formatoTarga.longValue() == TARGA_STRADALE_MA.longValue())");
      targaVO = umaClient.findTargaByNumeroAndTipo(numeroTarga,
          new Long(TARGA_STRADALE_MA));
      idNumeroTarga = targaVO.getIdNumeroTargaLong();
      if (idNumeroTarga != null)
      {
        errors.add("nuovoNumeroTarga", new ValidationError(
            "Targa STRADALE MA già assegnata"));
        return errors;
      }
    }

    if (formatoTarga == TARGA_MAO)
    {
      SolmrLogger.debug(this,
          "if(formatoTarga.longValue() == TARGA_MAO.longValue())");
      targaVO = umaClient.findTargaByNumeroAndTipo(numeroTarga, new Long(TARGA_MAO));
      idNumeroTarga = targaVO.getIdNumeroTargaLong();
      if (idNumeroTarga != null)
      {
        errors.add("nuovoNumeroTarga",
            new ValidationError("Targa MAO già assegnata"));
        return errors;
      }
    }

    return errors;
  }%>

