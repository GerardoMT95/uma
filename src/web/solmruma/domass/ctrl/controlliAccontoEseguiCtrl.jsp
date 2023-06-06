<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%><%@ page import="it.csi.solmr.util.*" %><%!
  public final static String VIEW = "../view/controlliAccontoEseguiView.jsp";
  public final static String CLOSE_URL = "../layout/assegnazioni.htm";
%><%
  session.removeAttribute("ASSEGNAZIONE_VALIDA");
  request.setAttribute("closeUrl",CLOSE_URL);
  SolmrLogger.debug(this, " - controlliAccontoEseguiCtrl.jsp - INIZIO PAGINA");
  String iridePageName = "controlliAccontoEseguiCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%
  %><jsp:forward page="<%=VIEW%>"/><%

  SolmrLogger.debug(this, " - controlliAccontoEseguiCtrl.jsp - FINE PAGINA");
%>