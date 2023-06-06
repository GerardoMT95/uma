
<%@page import="it.csi.solmr.util.SolmrLogger"%>
<%@page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@page import="it.csi.solmr.util.StringUtils"%><%!
  private static final String VIEW="/ditta/view/sceltaAziendaView.jsp";
%><%
  String iridePageName = "sceltaAziendaCtrl.jsp";
  SolmrLogger.debug(this,"SONO IN SCELTAAZIENDACNTRL E VIEW VALE: "+VIEW);
  
  
   %><%@include file = "/include/autorizzazione.inc" %><%

%><jsp:forward page="<%=VIEW%>" />

