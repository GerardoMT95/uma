<%@ page language="java"
  contentType="text/html"
  isErrorPage="false"
%>
<%!
  public final static String VIEW = "../view/nuovaDittaUmaAttendereView.jsp";
%>
<%
  String iridePageName = "nuovaDittaUmaAttendereCtrl.jsp";
%><%@include file = "/include/autorizzazione.inc" %>
<jsp:forward page="<%=VIEW%>" />