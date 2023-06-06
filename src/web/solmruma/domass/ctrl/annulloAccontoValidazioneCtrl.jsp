<%@ page language="java" contentType="text/html"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.etc.uma.*"%>
<%@ page import="it.csi.solmr.etc.SolmrConstants"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!public static final String VIEW                        = "/domass/view/annulloAccontoValidazioneView.jsp";
  public static final String ELENCO_ASSEGNAZIONI         = "/domass/ctrl/assegnazioniCtrl.jsp";
  public static final String ASSEGNAZIONE_ACCONTO_VALIDA = "../layout/verificaAssegnazioneAccontoValida.htm";%>

<%
  String iridePageName = "annulloAccontoValidazioneCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%
  Long idDomAss = null;
  DomandaAssegnazione da = null;
  SolmrLogger.debug(this,"- annulloAssegnazioneCtrl.jsp -  INIZIO PAGINA");

  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");
  Long idDittaUma = dittaUMAAziendaVO.getIdDittaUMA();

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  if (request.getParameter("idDomAss") != null)
  {
    SolmrLogger.debug(this,"request.getParameter(\"idDomAss\") == null");
    idDomAss = new Long(request.getParameter("idDomAss"));
  }

  if (request.getParameter("conferma.x") != null)
  {
    SolmrLogger.debug(this,"\\\\\\\\\\Conferma");

    ValidationErrors errors = new ValidationErrors();
    String motivazione = "";
    if (request.getParameter("note") != null)
    {
      motivazione = request.getParameter("note");
      SolmrLogger.debug(this,"motivazione: " + motivazione);

      if (motivazione != null && motivazione.length() == 0)
      {
        SolmrLogger.debug(this,"motivazione!=null && motivazione.length()==0");
        errors.add("note", new ValidationError(""
            + UmaErrors.get("INSERT_MOTIVO_ANNULLAMENTO")));
      }
      if (motivazione != null && motivazione.length() > 512)
      {
        SolmrLogger.debug(this,"motivazione!=null && motivazione.length()>512");
        errors.add("note", new ValidationError(""
            + UmaErrors.get("MAX_512_CHAR")));
      }
      if (errors.size() != 0)
      {
        SolmrLogger.debug(this,"      if (errors!=null)");
        da = (DomandaAssegnazione) umaFacadeClient
            .findDomAssByPrimaryKey(idDomAss);
        da.setNote(motivazione);
        SolmrLogger.debug(this,"      dopo umaFacadeClient.findDomAssByPrimaryKey");
        request.setAttribute("DomandaAssegnazione", da);
        SolmrLogger.debug(this,"errors: " + errors);
        SolmrLogger.debug(this,"errors.size(): " + errors.size());
        request.setAttribute("errors", errors);
%>
<jsp:forward page="<%=VIEW%>" />
<%
  return;
      }

    }
    SolmrLogger.debug(this,"Dopo request.getParameter(\"note\") != null");

    da = umaFacadeClient.findDomAssByPrimaryKey(idDomAss);
    da.setNote(motivazione);
    da.setUtenteAggiornamento(ruoloUtenza.getIdUtente().intValue());

    CodeDescr cdDomAss = new CodeDescr();
    cdDomAss
        .setCode(new Integer(SolmrConstants.ID_STATO_DOMANDA_ANNULLATA));
    cdDomAss.setDescription(SolmrConstants.DESC_STATO_DOMANDA_ANNULLATA);
    da.setStatoDomanda(cdDomAss);

    SolmrLogger.debug(this, "umaFacadeClient.annullaDomandaAssegnazione ("
        + da.getIdDomandaAssegnazione() + ", " + idDittaUma + ", "
        + da.getNote() + ", " + ruoloUtenza + ")");

    SolmrLogger.debug(this, "da.getIdDomandaAssegnazione(): "
        + da.getIdDomandaAssegnazione());
    SolmrLogger.debug(this, "idDittaUma: " + idDittaUma);
    SolmrLogger.debug(this, "da.getNote(): " + da.getNote());
    SolmrLogger.debug(this, "profile.getIdUtente(): "
        + ruoloUtenza.getIdUtente());
        
    int annoRiferimento = UmaDateUtils.extractYearFromDate(da.getDataRiferimento());	
	SolmrLogger.debug(this, " -- annoRiferimento ="+annoRiferimento);
    SolmrLogger.debug(this,"before call - annullaDomandaAssegnazione - annulloAssegnazioneCtrl");
    umaFacadeClient.annullaDomandaAssegnazione(da.getIdDomandaAssegnazione(), annoRiferimento, idDittaUma, da.getNote(), ruoloUtenza);
    SolmrLogger.debug(this,"after call - annullaDomandaAssegnazione - annulloAssegnazioneCtrl");
%>
<jsp:forward page="<%=ELENCO_ASSEGNAZIONI%>" />
<%
  return;
  }
  else
  {
    if (request.getParameter("indietro") != null)
    {
      response.sendRedirect(ASSEGNAZIONE_ACCONTO_VALIDA);
      return;
    }

  }

  //Visualizzazione Note per la domanda Assegnazione
  SolmrLogger.debug(this,
      "Visualizzazione Note per la domanda Assegnazione");
  da = (DomandaAssegnazione) umaFacadeClient
      .findDomAssByPrimaryKey(idDomAss);
  request.setAttribute("DomandaAssegnazione", da);
  SolmrLogger.debug(this, "da.getIdDomandaAssegnazione(): "
      + da.getIdDomandaAssegnazione());
%>
<jsp:forward page="<%=VIEW%>" />
