<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  private static final String VIEW="/macchina/view/nuovaImmatricolazioneConfermaView.jsp";
  private static final String ELENCO="../layout/elencoMacchine.htm";
  private static final String DETTAGLIO="../layout/dettaglioMacchinaDittaImmatricolazioni.htm";
%>
<%

  String iridePageName = "nuovaImmatricolazioneConfermaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  UmaFacadeClient umaClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


  ValidationErrors errors = new ValidationErrors();
  MacchinaVO mavo = new MacchinaVO();
  MovimentiTargaVO movo = new MovimentiTargaVO();
  SolmrLogger.debug(this,"###");
  if(session.getAttribute("common") instanceof MacchinaVO)
  {
    mavo = (MacchinaVO)session.getAttribute("common");
  }
  else if(request.getParameter("idMacchina")!=null)
  {
    Long idMacchina = new Long((String)request.getParameter("idMacchina"));
    mavo = umaClient.getMacchinaById(idMacchina);
  }

  if (request.getParameter("chiudi")!=null)
  {
    session.setAttribute("common", umaClient.getMacchinaById(mavo.getIdMacchinaLong()));
    response.sendRedirect(DETTAGLIO);
    return;
  }

  movo = umaClient.getUltimaMovimentazioneByIdMacchina(mavo.getIdMacchinaLong());
  request.setAttribute("movo", movo);
  %><jsp:forward page="<%=VIEW%>" /><%
%>

<%!
private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException("Eccezione : "+msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}
%>
