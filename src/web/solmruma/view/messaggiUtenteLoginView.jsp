<%@ page language="java" contentType="text/html" isErrorPage="false"%>

<%@ page import="it.csi.jsf.htmpl.Htmpl" %>
<%@ page import="it.csi.jsf.htmpl.HtmplFactory" %>
<%@ page import="it.csi.papua.papuaserv.dto.messaggistica.Messaggio"%>
<%@ page import="it.csi.papua.papuaserv.dto.messaggistica.ListaMessaggi"%>
<%@ page import="it.csi.solmr.etc.SolmrConstants"%>
<%@ page import="it.csi.solmr.util.SolmrLogger"%>
<%@ page import="it.csi.solmr.util.DateUtils"%>
<%@ page import="it.csi.solmr.util.HtmplUtil"%>
<%@ page import="it.csi.solmr.util.ValidationErrors"%>

<%!
  public static final String LAYOUT="../layout/messaggi_utente_login.htm";
%>

<%
  SolmrLogger.debug(this, "messaggiUtenteLoginView BEGIN");
  
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%>

<%@include file = "/include/menu.inc" %>

<%
  htmpl.set("conferma", SolmrConstants.OPERATION_CONFIRM );
  
  ListaMessaggi listaMessaggi = (ListaMessaggi)request.getAttribute("listaMessaggi");

  if (listaMessaggi.getMessaggi()!=null && listaMessaggi.getMessaggi().length>0) {
  	for (Messaggio messaggio : listaMessaggi.getMessaggi()) {
  		htmpl.newBlock("blkMessaggio");
  		htmpl.set("blkMessaggio.idMessaggio", ""+messaggio.getIdElencoMessaggi() );
  		htmpl.set("blkMessaggio.titolo", messaggio.getTitolo() );
  		htmpl.set("blkMessaggio.dataInserimento", DateUtils.formatDateTimeNotNull(messaggio.getDataInizioValidita()));
  		htmpl.set("blkMessaggio.flagAllegati", messaggio.isConAllegati()? "SI" : "NO");
  	}
  }

  ValidationErrors errors = (ValidationErrors) request.getAttribute("errors");
  HtmplUtil.setErrors(htmpl, errors, request);
  
  SolmrLogger.debug(this, "messaggiUtenteLoginView END");
%>
<%=htmpl.text() %>