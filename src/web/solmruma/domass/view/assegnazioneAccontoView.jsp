<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.SolmrLogger" %>
<%@page import="it.csi.solmr.util.DateUtils"%>

<%!
  public static final String LAYOUT = "/domass/layout/assegnazioneAcconto.htm";
%>

<%
  SolmrLogger.info(this, " - controlliEseguiView.jsp - INIZIO PAGINA");

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  htmpl.set("annoCorrente",DateUtils.getCurrentYear().toString());
  htmpl.set("messaggio","La domanda di assegnazione è stata creata e trasmessa all'ufficio UMA. Controllare i dati ed effettuare la validazione");
  SolmrLogger.info(this, " - controlliEseguiView.jsp - FINE PAGINA");
%><%=htmpl.text()%>