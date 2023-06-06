<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  private static final String VIEW="/ditta/view/vistaParticellarePOPView.jsp";
%>
<%

  String iridePageName = "vistaParticellarePOPCtrl.jsp";
%>
  <%@include file = "/include/autorizzazione.inc" %>
<%
%><jsp:forward page="<%=VIEW%>" />
