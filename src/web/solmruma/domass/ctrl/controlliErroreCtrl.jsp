<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="it.csi.solmr.util.*" %>

<%!
  public final static String VIEW = "../view/controlliErroreView.jsp";
%>

<%

  String iridePageName = "controlliErroreCtrl.jsp";
  request.setAttribute("noCheckIntermediario","TRUE");
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.info(this, " - controlliErroreCtrl.jsp - INIZIO PAGINA");

  %><jsp:forward page="<%=VIEW%>"/><%

  SolmrLogger.info(this, " - controlliErroreCtrl.jsp - FINE PAGINA");
%>