<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  private static final String VIEW="/ditta/view/dettaglioSuperficiePOPView.jsp";
%>
<%
  String iridePageName = "dettaglioSuperficiePOPCtrl.jsp";
%>
  <%@include file = "/include/autorizzazione.inc" %>
<%


%><jsp:forward page="<%=VIEW%>" />
