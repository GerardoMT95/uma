<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.etc.SolmrConstants"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.dto.comune.IntermediarioVO"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%!
  public static final String ANNULLA_URL = "/domass/ctrl/annulloAssegnazioneCtrl.jsp";
  public static final String VIEW_URL="/domass/view/dettaglioAssegnazioneAccontoView.jsp";

  public static final String DETTAGLIO_VERIFICA_ASSEGNAZIONE_URL = "/domass/ctrl/dettaglioVerificaAccontoCtrl.jsp";
%>

<%
  String iridePageName = "dettaglioDomandaCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  DomandaAssegnazione da = (DomandaAssegnazione) request
      .getAttribute("DOMANDA_ASSEGNAZIONE");
    Long idDomAss = null;
    if (request.getParameter("idDomAss") != null)
    {
      idDomAss = new Long(request.getParameter("idDomAss"));
    }
  if (da == null)
  {

    da = umaFacadeClient.findDomAssByPrimaryKey(idDomAss);
    SolmrLogger.debug(this,"idDomAss: " + idDomAss);
  }

  //da rimuovere - solo per test

  try
  {
    // Aggiunta Andrea 24/11/2006 per CU-GUMA-20 (elenco assegnazioni effettuate)
    Long extIdIntVal = da.getExtIdIntermediarioValida();
    IntermediarioVO intermediarioVO = null;
    if (extIdIntVal != null)
    {
      intermediarioVO = umaFacadeClient
          .serviceFindIntermediarioByIdIntermediario(extIdIntVal);
    }

    //caricamento dettaglioDomandaView
    SolmrLogger.debug(this,"da.getUtenteAggiornamento()="
        + da.getUtenteAggiornamento());
    SolmrLogger.debug(this,"da.getDataRiferimento()=" + da.getDataRiferimento());
    SolmrLogger.debug(this,"da.getDataAggiornamento()="
        + da.getDataAggiornamento());
    Long idDittaUma = new Long(da.getIdDitta());
    SolmrLogger.debug(this,"umaFacadeClient.findByPrimaryKey(\"" + idDittaUma
        + "\")");
    DittaUMAVO du = (DittaUMAVO) umaFacadeClient
        .findByPrimaryKey(idDittaUma);

    SolmrLogger.debug(this,"\n\n\n\nCtrl1*********************************");
    Date dataRiferimento = da.getDataRiferimento();
    SolmrLogger.debug(this,"umaFacadeClient.findDatiDitta(du, "
        + dataRiferimento + ")");
    du = umaFacadeClient.findDatiDitta(du, dataRiferimento);

    SolmrLogger.debug(this,"\n\n\n\nCtrl2*********************************");
    SolmrLogger.debug(this,"idDittaUma : " + du.getIdDitta());
    SolmrLogger.debug(this,"da.getExtIdIntermediario()="
        + da.getExtIdIntermediario());
    UtenteIrideVO utenteIrideVO = null;

    SolmrLogger.debug(this,"\n\n\n\n\n----------------Utenti");
    SolmrLogger.debug(this,"da.getExtIdIntermediario().longValue(): "
        + da.getExtIdIntermediario().longValue());

    if (da.getExtIdIntermediario().longValue() != 0)
    {
      try
      {
        utenteIrideVO = umaFacadeClient.getUtenteIride(da
            .getExtIdIntermediario());
      }
      catch (Exception e)
      {
      }
    }

    SolmrLogger.debug(this,"da.getUtenteAggiornamento(): "
        + da.getUtenteAggiornamento());
    UtenteIrideVO utenteAggiornamentoIrideVO = null;
    ;
    if (da.getUtenteAggiornamento() != 0)
    {
      try
      {
        SolmrLogger.debug(this,"utente aggiornamento iride prima di getUtenteIride("
                + da.getUtenteAggiornamento() + ")");
        utenteAggiornamentoIrideVO = umaFacadeClient
            .getUtenteIride(new Long(da.getUtenteAggiornamento()));
      }
      catch (Exception e)
      {
      }
    }
    else
    {
      SolmrLogger.debug(this,"nessun utente aggiornamento iride");
    }

    SolmrLogger.debug(this,"Prima request");

    // Aggiunta Andrea 24/11/2006 per CU-GUMA-20 (elenco assegnazioni effettuate)
    if (intermediarioVO != null)
    {
      request.setAttribute("intermediarioVOValida", intermediarioVO);
    }

    request.setAttribute("DomandaAssegnazione", da);
    request.setAttribute("DittaUMAVO", du);
    request.setAttribute("utenteIrideVO", utenteIrideVO);
    request.setAttribute("utenteAggiornamentoIrideVO",
        utenteAggiornamentoIrideVO);
    SolmrLogger.debug(this,"Dopo request");

    if (request.getParameter("annulla.x") != null)
    {
      %><jsp:forward page="<%=ANNULLA_URL%>" />
<%
  return;
    }

    SolmrLogger.debug(this,"\n\n\n sesesesesese1\n\n\n");
  }
  catch (SolmrException se)
  {
    SolmrLogger.debug(this,"\n\n\n sesesesesese2\n\n\n");
    //if ( !(se instanceof ValidationException) )
    throw new ValidationException("Errore di sistema : " + se.toString(),
        VIEW_URL);
  }

  if (request.getParameter("annullaBuoni") != null)
  {
    SolmrLogger.debug(this,"request.getParameter(\"annullaBuoni\"): "
        + request.getParameter("annullaBuoni"));
    if (request.getParameter("annullaBuoni").equalsIgnoreCase(
        "dettaglioVerificaAssegnazione"))
    {
      //Dettaglio Verifica Assegnazione
      SolmrLogger.debug(this,"request.getParameter(\"annullaBuoni\").equalsIgnoreCase("
              + DETTAGLIO_VERIFICA_ASSEGNAZIONE_URL + ")");
%>
<jsp:forward page="<%=DETTAGLIO_VERIFICA_ASSEGNAZIONE_URL%>" />
<%
  return;
    }
  }
%>
<%!private void throwValidation(String msg, String validateUrl)
      throws ValidationException
  {
    ValidationException valEx = new ValidationException("Errore: eccezione="
        + msg, validateUrl);
    valEx.addMessage(msg, "exception");
    throw valEx;
  }%>
<jsp:forward page="<%=VIEW_URL%>" />