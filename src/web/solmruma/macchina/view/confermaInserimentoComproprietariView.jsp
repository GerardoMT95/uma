<%@
  page language="java"
  contentType="text/html"
  isErrorPage="true"
%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.etc.*"%>
<%!
  private static final String messaggio = "Attestazione proprietà già esistente! <br> Si vuole proseguire con la creazione?";
%>
<%
  SolmrLogger.debug(this,"ConfermaInserimentoComproprietariView.jsp - Begin");

  java.io.InputStream layout = application.getResourceAsStream("/macchina/layout/confermaInserimentoComproprietari.htm");
  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
  HashMap common2 = (HashMap) session.getAttribute("common2");
  Long idMacchina = (Long) common2.get("idMacchina");
  SolmrLogger.debug(this,"idMacchina: "+idMacchina);
  htmpl.set("idMacchina", ""+idMacchina);

  htmpl.setStringProcessor(null);
  htmpl.set("messaggio",messaggio);
  HtmplUtil.setErrors(htmpl, (ValidationErrors) request.getAttribute("errors"), request);
%>
<%= htmpl.text()%>