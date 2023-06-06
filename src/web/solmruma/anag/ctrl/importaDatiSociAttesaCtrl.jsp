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
  public final static String VIEW = "../view/importaDatiSociAttesaView.jsp";
%>

<%
  SolmrLogger.debug(this, "  BEGIN importaDatiSociAttesaCtrl");
  String iridePageName = "importaDatiSociAttesaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  // Visualizzare la pagina di attesa, dopo la pagina di sceltaImportaDatiSoci

  SolmrLogger.debug(this, "  END importaDatiSociAttesaCtrl");

  %><jsp:forward page="<%=VIEW%>"/><%
%>