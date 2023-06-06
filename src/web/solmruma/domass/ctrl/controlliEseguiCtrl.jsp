<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%><%@ page import="it.csi.solmr.util.*" %><%!
  public final static String VIEW = "../view/controlliEseguiView.jsp";
%><%

  String iridePageName = "controlliEseguiCtrl.jsp";
  request.setAttribute("noCheckIntermediario","TRUE");
  request.setAttribute("noVerificaGerarchiaIntermediario","TRUE");
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.info(this, " - controlliEseguiCtrl.jsp - INIZIO PAGINA");

  %><jsp:forward page="<%=VIEW%>"/><%

  SolmrLogger.info(this, " - controlliEseguiCtrl.jsp - FINE PAGINA");
%>