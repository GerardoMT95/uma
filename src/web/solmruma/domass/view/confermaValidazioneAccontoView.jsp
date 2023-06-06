<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@page import="it.csi.jsf.htmpl.Htmpl"%>
<%@page import="it.csi.jsf.htmpl.HtmplFactory"%>
<%@page import="it.csi.solmr.etc.SolmrConstants"%>
<%!// Costanti
  private static final String LAYOUT = "domass/layout/confermaValidazioneAcconto.htm";%>
<%
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
  htmpl.set("messaggio",SolmrConstants.MESSAGGIO_CONFERMA_VALIDAZIONE_ACCONTO);
%><%@include file="/include/menu.inc"%><%=htmpl.text()%>
