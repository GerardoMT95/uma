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
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  private static final String DETTAGLIO="../layout/dettaglioMacchinaDittaImmatricolazioni.htm";
  private static final String ELENCO="../layout/elencoMacchine.htm";
%>
<%

  String iridePageName = "venditaFuoriRegioneConfermaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  String viewUrl="/macchina/view/venditaFuoriRegioneConfermaView.jsp";
  UmaFacadeClient umaClient = new UmaFacadeClient();
  MovimentiTargaVO movimentiTargaVO = (MovimentiTargaVO) session.getAttribute("common");
  request.setAttribute("movimentiTargaVO", movimentiTargaVO);
  SolmrLogger.debug(this,"movimentiTargaVO  ### "+movimentiTargaVO);

  if (request.getParameter("chiudi")!=null)
  {
    request.setAttribute("movimentiTargaVO", umaClient.getMacchinaById(movimentiTargaVO.getIdMacchinaLong()));
    session.setAttribute("common", umaClient.getMacchinaById(movimentiTargaVO.getIdMacchinaLong()) );
    response.sendRedirect(DETTAGLIO);
    return;
  }
  if (request.getParameter("elenco")!=null)
  {
//    session.removeAttribute("common");
    response.sendRedirect(ELENCO);
    return;
  }

  %><jsp:forward page="<%=viewUrl%>" /><%

  return;
%>