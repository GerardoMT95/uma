<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@page import="it.csi.solmr.dto.profile.RuoloUtenza"%>
<%@ page import="it.csi.solmr.etc.*" %>



<%

  //UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/dettaglioLavDaContoPOP.htm");
%><%@include file = "/include/menu.inc" %><%
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

	//RuoloUtenza[] ruoloUtenzaAgg = (RuoloUtenza[])request.getAttribute("ruoloUtenzaAgg");
	UtenteIrideVO utenteIrideVO = (UtenteIrideVO) request.getAttribute("utenteIrideVO");
	LavContoTerziVO lavContoTerzi = (LavContoTerziVO) request.getAttribute("lavContoTerzi");

    htmpl.set("cuaa",StringUtils.checkNull(lavContoTerzi.getCuaa()));
    htmpl.set("partitaIva",lavContoTerzi.getPartitaIva());
    htmpl.set("denominazione",StringUtils.checkNull(lavContoTerzi.getDenominazione()));
    if(lavContoTerzi.getExtIdAzienda()!=null){
    	 htmpl.set("sedeLegale",StringUtils.checkNull(lavContoTerzi.getSedeLegaleAnag()));
    	 SolmrLogger.debug(this,"lavContoTerzi.getSedeLegaleAnag() vale: "+lavContoTerzi.getSedeLegaleAnag());
    }else{
		SolmrLogger.debug(this,"lavContoTerzi.getDescProvincia() vale: "+lavContoTerzi.getDescProvincia());
   	  	String desc=lavContoTerzi.getDescComune();
   		if(!StringUtils.isStringEmpty(lavContoTerzi.getDescProvincia())){
   			desc=desc+" ("+lavContoTerzi.getDescProvincia()+")";
   		}	
   	 	htmpl.set("sedeLegale",StringUtils.checkNull(desc));
    }
    htmpl.set("indirizzoSedeLeg",StringUtils.checkNull(lavContoTerzi.getIndirizzoSedeLegale()));
    htmpl.set("usoDelSuolo",StringUtils.checkNull(lavContoTerzi.getDescUsoDelSuolo()));
    htmpl.set("lavorazione",StringUtils.checkNull(lavContoTerzi.getDescTipoLavorazione()));
    htmpl.set("esecuzioni",StringUtils.checkNull(lavContoTerzi.getEsecuzioniStr()));
    
    htmpl.set("unitaDiMisura",StringUtils.checkNull(lavContoTerzi.getDescUnitaMisura()));
    htmpl.set("supOre",""+StringUtils.checkNull(lavContoTerzi.getSupOreFattura()));
    htmpl.set("gasolio",""+StringUtils.checkNull(lavContoTerzi.getConsumoCalcolato()));
    htmpl.set("benzina",""+StringUtils.checkNull(lavContoTerzi.getConsumoDichiarato()));
    htmpl.set("note",""+StringUtils.checkNull(lavContoTerzi.getNote()));
    htmpl.set("dataInizioValidita",UmaDateUtils.formatFullDate24(lavContoTerzi.getDataInizioValidita()));
    htmpl.set("dataCessazione",UmaDateUtils.formatFullDate24(lavContoTerzi.getDataCessazione()));
    htmpl.set("dataAggiornamentoStr",UmaDateUtils.formatFullDate24(lavContoTerzi.getDataUltimoAggiornamento()));
    
    SolmrLogger.debug(this,"lavContoTerzi.getExtIdUtenteAggiornamento(): "+lavContoTerzi.getExtIdUtenteAggiornamento());

  	htmpl.set("denominazioneAggiornamento",utenteIrideVO.getDenominazione());
  	htmpl.set("descrizioneEnteAppartenenza",utenteIrideVO.getDescrizioneEnteAppartenenza());
    
  out.print(htmpl.text());

%>
