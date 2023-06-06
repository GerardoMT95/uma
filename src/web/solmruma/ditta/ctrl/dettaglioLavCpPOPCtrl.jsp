<%@page import="it.csi.solmr.dto.uma.LavContoProprioVO"%>
<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@page import="it.csi.solmr.dto.uma.LavContoTerziVO"%>
<%@page import="it.csi.solmr.dto.uma.MacchinaVO"%>
<%@page import="it.csi.solmr.dto.UtenteIrideVO"%>
<%!
  private static final String VIEW="/ditta/view/dettaglioLavCpPOPView.jsp";
%><%

  String iridePageName = "dettaglioLavCpPOPCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%
  
    SolmrLogger.debug(this, "   BEGIN dettaglioLavCpPOPCtrl");

  	UmaFacadeClient umaFacadeClient=new UmaFacadeClient();

	Long idLavContoProprio = new Long(request.getParameter("idLavContoProprio"));
  	SolmrLogger.debug(this,"--- idLavContoProprio ="+idLavContoProprio);
  	
  	SolmrLogger.debug(this,"---- RICERCA DATI per il dettaglio");
  	LavContoProprioVO dettaglioLavorazCp = umaFacadeClient.getDettaglioLavContoProprio(idLavContoProprio);	
  	if(dettaglioLavorazCp.getIdMacchina()!=null){
  	  SolmrLogger.debug(this,"---- RICERCA DATI Macchina");  	 
	  MacchinaVO macchinaVO = umaFacadeClient.getMacchinaById(new Long(dettaglioLavorazCp.getIdMacchina()));
	  dettaglioLavorazCp.setMacchinaVO(macchinaVO);
	}			
    					
	SolmrLogger.debug(this," --- extIdUtenteAggiornamento ="+dettaglioLavorazCp.getExtIdUtenteAggiornamento());
	SolmrLogger.debug(this,"---- RICERCA DATI utente aggiornamento");	
  	UtenteIrideVO utenteIrideVO = umaFacadeClient.getUtenteIride(dettaglioLavorazCp.getExtIdUtenteAggiornamento());
	dettaglioLavorazCp.setUtenteIrideVO(utenteIrideVO);

	request.setAttribute("dettaglioLavorazCp",dettaglioLavorazCp);
	

%><jsp:forward page="<%=VIEW%>" />
