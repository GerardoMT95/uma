<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@page import="org.apache.commons.lang3.StringUtils"%>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/dettaglioLavCtPerCpPOP.htm");
%>
<%@include file = "/include/menu.inc" %>
<%
    SolmrLogger.debug(this, "   BEGIN dettaglioLavCtPerCpPOPView");
    SolmrLogger.debug(this, "--- recupero l'oggetto da visualizzare");
	
    LavContoTerziPerContoProprioVO lavCtPerCp = (LavContoTerziPerContoProprioVO) request.getAttribute("dettaglioLavCTperCP");

    htmpl.set("annoCampagna", lavCtPerCp.getAnnoCampagna());   
    htmpl.set("cuaaCT", lavCtPerCp.getCuaa());
    htmpl.set("denominazioneCT", lavCtPerCp.getDenominazione());
    htmpl.set("sede", lavCtPerCp.getSedeLegale());   
    htmpl.set("indirizzo", lavCtPerCp.getIndirizzoSede());
    htmpl.set("usoDelSuolo", lavCtPerCp.getUsoDelSuolo());                
    htmpl.set("lavorazione", lavCtPerCp.getLavorazione());
    htmpl.set("unitaDiMisura", lavCtPerCp.getUnitaDiMisura());
 	htmpl.set("supOre",lavCtPerCp.getSupOreFattura()); 	 	
    htmpl.set("numEsecuzioni", lavCtPerCp.getNumeroEsecuzioni());           
    htmpl.set("consumo", lavCtPerCp.getConsumoDichiarato());      	
    htmpl.set("numeroFatture",StringUtils.trimToEmpty(lavCtPerCp.getNumeroFatture()));
    htmpl.set("eccedenza", lavCtPerCp.isEccedenza() ? "SI" : "");
	htmpl.set("data", lavCtPerCp.getDataInserimento());
    htmpl.set("modifica", lavCtPerCp.getUltimaModifica());
        
    SolmrLogger.debug(this, "   END dettaglioLavCtPerCpPOPView");
    out.print(htmpl.text());

%>
