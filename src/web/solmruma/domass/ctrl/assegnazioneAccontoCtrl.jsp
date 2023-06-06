<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%><%!
  public final static String VIEW = "../view/assegnazioneAccontoView.jsp";
  public final static String CLOSE_URL = "../layout/assegnazioni.htm";
%><%
  session.removeAttribute("ASSEGNAZIONE_VALIDA");
  request.setAttribute("closeUrl",CLOSE_URL);
  String iridePageName = "assegnazioneAccontoCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%
  %><jsp:forward page="<%=VIEW%>"/><%
%>