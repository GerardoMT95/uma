<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="java.util.*" %>

<%!
  public final static String VIEW = "../view/importaDatiAttesaView.jsp";
%>

<%
  SolmrLogger.info(this, " - importaDatiAttesaCtrl.jsp - INIZIO PAGINA");
  String iridePageName = "importaDatiAttesaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  //L'utente effettua la conferma premendo sul pulsante "conferma"

  SolmrLogger.info(this, " - importaDatiAttesaCtrl.jsp - FINE PAGINA");

  %><jsp:forward page="<%=VIEW%>"/><%
%>