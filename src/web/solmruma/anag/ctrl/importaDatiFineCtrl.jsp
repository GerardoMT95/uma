<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="java.util.*" %>

<%!
  public final static String VIEW = "../view/importaDatiFineView.jsp";
%>

<%

  String iridePageName = "importaDatiFineCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, " - importaDatiFineCtrl.jsp - INIZIO PAGINA");

  //Visualizzazione risultato restituito dalla procedura PL/SQL
  //relativa alla sincronizzazione dei dati

  SolmrLogger.debug(this, " - importaDatiFineCtrl.jsp - FINE PAGINA");

  %><jsp:forward page="<%=VIEW%>"/><%
%>
