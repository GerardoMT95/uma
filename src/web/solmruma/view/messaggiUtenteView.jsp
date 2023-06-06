<%@ page language="java" contentType="text/html" isErrorPage="false" %>

<%@ page import="it.csi.jsf.htmpl.Htmpl" %>
<%@ page import="it.csi.jsf.htmpl.HtmplFactory" %>
<%@ page import="it.csi.papua.papuaserv.dto.messaggistica.Messaggio"%>
<%@ page import="it.csi.papua.papuaserv.dto.messaggistica.ListaMessaggi"%>
<%@ page import="it.csi.solmr.util.SolmrLogger"%>
<%@ page import="it.csi.solmr.util.DateUtils"%>
<%@ page import="it.csi.solmr.util.HtmplUtil"%>
<%@ page import="it.csi.solmr.util.ValidationErrors"%>

<%!
  public static final String LAYOUT="layout/messaggi_utente.htm";
%>


<%
  SolmrLogger.debug(this, "messaggiUtenteView BEGIN");
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%>

<%@include file = "/include/menu.inc" %>

<%
  ListaMessaggi listaMessaggi = (ListaMessaggi)request.getAttribute("listaMessaggi");

  if (listaMessaggi!=null && listaMessaggi.getMessaggi()!=null && listaMessaggi.getMessaggi().length>0) {
    boolean primoDaLeggere = true;
  	boolean primoLetto = true;
  	htmpl.newBlock("blkData");
  	 
  	for (Messaggio messaggio : listaMessaggi.getMessaggi()) {
  		String blk="";
  		
  		if (messaggio.isLetto()) {
  			blk = "blkData.blkMessaggioLetto";
  			
  			if (primoLetto) {
  				htmpl.newBlock("blkData.blktitoloLetti");
  				primoLetto = false;
  			}
  		}else {
  			blk = "blkData.blkMessaggioDaLeggere";
  			
  			if (primoDaLeggere) {
  				htmpl.newBlock("blkData.blktitoloDaLeggere");
  				primoDaLeggere = false;
  			}
  		}
  		
  		htmpl.newBlock(blk);
  		htmpl.set(blk+".idMessaggio", ""+messaggio.getIdElencoMessaggi());
  		htmpl.set(blk+".titolo", messaggio.getTitolo());
  		htmpl.set(blk+".dataInserimento", DateUtils.formatDateTimeNotNull(messaggio.getDataInizioValidita()));
  		htmpl.set(blk+".flagAllegati", messaggio.isConAllegati()? "SI" : "NO");
  		
  		if (messaggio.isLetturaObbligatoria()) {
	  		htmpl.set(blk+".style", "color: #bf5229;");
  		}
    }
  }else {
  	htmpl.newBlock("blkNoData");
  }

  ValidationErrors errors = (ValidationErrors) request.getAttribute("errors");
  HtmplUtil.setErrors(htmpl, errors, request);
  
  SolmrLogger.debug(this, "messaggiUtenteView END");
%>
<%=htmpl.text() %>