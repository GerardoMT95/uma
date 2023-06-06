<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>

<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String iridePageName = "dettaglioMacchinaDettaglioTargaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  String url = "/macchina/view/dettaglioMacchinaDettaglioTargaView.jsp";
  // Indietro
  if(request.getParameter("indietroDett")!=null)
    url = "/macchina/layout/dettaglioMacchinaImmatricolazioni.htm";
  SolmrLogger.debug(this,"- dettaglioMacchinaDettaglioTargaCtrl.jsp - Fine Pagina");
%>
<jsp:forward page="<%=url%>"/>