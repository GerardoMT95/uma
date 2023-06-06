<%@ page language="java" contentType="text/html" isErrorPage="false" %>

<%@ page import="it.csi.jsf.htmpl.Htmpl" %>
<%@ page import="it.csi.jsf.htmpl.HtmplFactory" %>
<%@ page import="it.csi.papua.papuaserv.dto.messaggistica.Allegato"%>
<%@ page import="it.csi.papua.papuaserv.dto.messaggistica.DettagliMessaggio"%>
<%@ page import="it.csi.solmr.etc.SolmrConstants"%>
<%@ page import="it.csi.solmr.util.SolmrLogger"%>
<%@ page import="it.csi.solmr.util.DateUtils"%>

<%!
  public static final String LAYOUT_LOGIN = "layout/dettaglio_messaggi_utente_login.htm";
  public static final String LAYOUT_NORMALE = "layout/dettaglio_messaggi_utente.htm";
%>

<%
  SolmrLogger.info(this, " - dettaglioMessaggiUtenteLoginView.jsp - INIZIO PAGINA");
  String pagina = LAYOUT_NORMALE;
	if (((String)request.getAttribute("chiamante")).indexOf("messaggi_utente_login.")!=-1) {
		pagina = LAYOUT_LOGIN;
	}
	
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(pagina);

%>

<%@include file = "/include/menu.inc" %>

<%  
  
  DettagliMessaggio dettagliMessaggio = (DettagliMessaggio) request.getAttribute("dettagliMessaggio");
  
  htmpl.set("CONFIRM", SolmrConstants.OPERATION_CONFIRM);

  htmpl.set("chiamante", (String)request.getAttribute("chiamante"));
  htmpl.set("titolo", dettagliMessaggio.getTitolo());
  htmpl.set("utenteInserimento",  dettagliMessaggio.getUtenteAggiornamento().getNome()+" "+
            dettagliMessaggio.getUtenteAggiornamento().getCognome()+" - "+
            dettagliMessaggio.getUtenteAggiornamento().getDenominazioneEnte());
  htmpl.set("dataInserimento", DateUtils.formatDateTimeNotNull(dettagliMessaggio.getDataInizioValidita()));
  
  String testoMessaggio = dettagliMessaggio.getTestoMessaggio();
  if (testoMessaggio!=null) {
    // sostituisco \n con <br> 
  	testoMessaggio = testoMessaggio.replaceAll("\n", "<br\\>");
  }
  	
  htmpl.set("testoMessaggio", testoMessaggio, null);
  if (dettagliMessaggio.getAllegati()!=null && dettagliMessaggio.getAllegati().length>0) {
    htmpl.newBlock("blkAllegati");
    
    for (Allegato allegato : dettagliMessaggio.getAllegati()) {
		  htmpl.newBlock("blkAllegati.blkAllegato");
		  htmpl.set("blkAllegati.blkAllegato.descrizione", allegato.getDescrizione() );
		  htmpl.set("blkAllegati.blkAllegato.nomeFile", allegato.getNomeFile() );
		  htmpl.set("blkAllegati.blkAllegato.idAllegato", ""+allegato.getIdAllegato() );
	  }
  }
  
  if (dettagliMessaggio.isLetturaObbligatoria()) {
   	htmpl.newBlock("blkDichLettura");
   	
   	if (dettagliMessaggio.isLetto()) {
   	  htmpl.set("blkDichLettura.checked", SolmrConstants.HTML_CHECKED );
   		htmpl.set("blkDichLettura.disabled", SolmrConstants.HTML_DISABLED );
	  }
  }
   
  SolmrLogger.info(this, " - dettMessaggiUtenteLogin.jsp - FINE PAGINA");
%>
<%= htmpl.text()%>