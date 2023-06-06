<%@page	import="it.csi.solmr.dto.filter.LavContoTerziPerContoProprioFilter"%>
<%@ page language="java" contentType="text/html" isErrorPage="true"%>

<%@ page import="java.util.*"%>
<%@ page import="java.math.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@page import="org.apache.commons.lang3.StringUtils"%>

<%
	UmaFacadeClient umaClient = new UmaFacadeClient();
	List<LavContoTerziPerContoProprioVO> elencoLavCPPerCT= new ArrayList<LavContoTerziPerContoProprioVO>();
	Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/elencoLavContoTerziSuContoProprio.htm");
%>

<%@include file="/include/menu.inc"%>

<%
	LavContoTerziPerContoProprioFilter filter = (LavContoTerziPerContoProprioFilter) session.getAttribute("filterRicercaLavCTPerCP");
	
	//Viene scritta nelle funzioni js che necessitano l'id della azienda selezionata
	htmpl.set("id_azienda", filter.getIdAzienda().toString());

	String operation = (String)request.getAttribute("operation");
	
	popolaComboAnnoRiferimento(session, htmpl, filter);	
	popolaComboUsoDelSuolo(session, htmpl, filter);
	popolaComboLavorazione(session, htmpl, filter);
	
	popolaTabellaRisultatoRicerca(request,htmpl,filter);
	
	HtmplUtil.setErrors(htmpl,(ValidationErrors) request.getAttribute("errors"), request);

	out.print(htmpl.text());
%>

<%!

private void popolaTabellaRisultatoRicerca(HttpServletRequest request, Htmpl htmpl, LavContoTerziPerContoProprioFilter filter) throws Exception{
	SolmrLogger.debug(this, "   BEGIN popolaTabellaRisultatoRicerca");
				
	List<LavContoTerziPerContoProprioVO> elencoLavCpPerCt = (List<LavContoTerziPerContoProprioVO>)request.getSession().getAttribute("elencoLavCpPerCt");
	
	if(elencoLavCpPerCt.isEmpty()){
	 SolmrLogger.debug(this, "--- non sono state trovate delle Lavorazioni Conto Terzi per Conto Proprio");
	 htmpl.newBlock("blkNoLavorazioni");
	}
	else{
	  SolmrLogger.debug(this, "--- sono state trovate delle Lavorazioni Conto Proprio, quante ="+elencoLavCpPerCt.size());  	  
	  htmpl.newBlock("blkLavorazioni");
	  
	  // --------- GESTIONE PAGINAZIONE ---------------
	  int startRow = gestionePaginazione(htmpl,request,elencoLavCpPerCt);
	  SolmrLogger.debug(this, "--- startRow ="+startRow);  
	  
	  for(int i=startRow;i<elencoLavCpPerCt.size() && i< startRow+SolmrConstants.NUM_MAX_ROWS_PAG;i++){
		htmpl.newBlock("blkLavorazioni.blkLavCTerziPerCProprio");
		LavContoTerziPerContoProprioVO lavCPCT = elencoLavCpPerCt.get(i);
		
		htmpl.set("blkLavorazioni.blkLavCTerziPerCProprio.idLavContoTerzista", lavCPCT.getIdLavorazioneCT());
		htmpl.set("blkLavorazioni.blkLavCTerziPerCProprio.cuaa", lavCPCT.getCuaa());
		htmpl.set("blkLavorazioni.blkLavCTerziPerCProprio.partitaIva", lavCPCT.getPartitaIva());
		htmpl.set("blkLavorazioni.blkLavCTerziPerCProprio.denominazione", lavCPCT.getDenominazione());
		htmpl.set("blkLavorazioni.blkLavCTerziPerCProprio.usoDelSuolo", lavCPCT.getUsoDelSuolo());
		htmpl.set("blkLavorazioni.blkLavCTerziPerCProprio.lavorazione", lavCPCT.getLavorazione());
		htmpl.set("blkLavorazioni.blkLavCTerziPerCProprio.unitaMisura", lavCPCT.getUnitaDiMisura());
		htmpl.set("blkLavorazioni.blkLavCTerziPerCProprio.supOreFattura", lavCPCT.getSupOreFattura());
		htmpl.set("blkLavorazioni.blkLavCTerziPerCProprio.numEsecuzioni", lavCPCT.getNumeroEsecuzioni());      
		htmpl.set("blkLavorazioni.blkLavCTerziPerCProprio.consumoDich", lavCPCT.getConsumoDichiarato());      
		htmpl.set("blkLavorazioni.blkLavCTerziPerCProprio.numFatture", lavCPCT.getNumeroFatture());      
		htmpl.set("blkLavorazioni.blkLavCTerziPerCProprio.eccedenza", lavCPCT.isEccedenza() ? "SI":"");      
			  
	  }
	  SolmrLogger.debug(this, "   END popolaTabellaRisultatoRicerca");
	}
}

private int gestionePaginazione(Htmpl htmpl, HttpServletRequest request, List<LavContoTerziPerContoProprioVO> elencoLavCpPerCt) throws Exception{
	SolmrLogger.debug(this, "  BEGIN gestionePaginazione");
	
	String startRowStr=(String)request.getAttribute("startRow");
	SolmrLogger.debug(this, " --- startRowStr ="+startRowStr);
	int startRow=0;
	int rows = elencoLavCpPerCt.size();

	if (startRowStr!=null){
		try{
			startRow=new Integer(startRowStr).intValue();
    	}
    	catch(Exception e){
    		
    	}
	}
	
	int prevPage=startRow-SolmrConstants.NUM_MAX_ROWS_PAG;
	SolmrLogger.debug(this, "--- prevPage ="+prevPage);
 	int nextPage=startRow+SolmrConstants.NUM_MAX_ROWS_PAG;
 	SolmrLogger.debug(this, "--- nextPage ="+nextPage);
 	if (nextPage>=rows){
	   nextPage=startRow;
	}
	if (prevPage<=0){
	  prevPage=0;
	}
	int maxPage=rows/SolmrConstants.NUM_MAX_ROWS_PAG+(rows%SolmrConstants.NUM_MAX_ROWS_PAG>0?1:0);
	if (elencoLavCpPerCt.size()==0){
		maxPage=1;
	}
	int currentPage=startRow/SolmrConstants.NUM_MAX_ROWS_PAG+1+(startRow%SolmrConstants.NUM_MAX_ROWS_PAG>0?1:0);
	
	SolmrLogger.debug(this,"--- currentPage="+currentPage);
	SolmrLogger.debug(this,"---- maxPage="+maxPage);
	if (currentPage!=1){
		htmpl.set("blkLavorazioni.prev.prevPage",""+prevPage);
	}
	if (currentPage!=maxPage)
	{
		htmpl.set("blkLavorazioni.next.nextPage",""+nextPage);
	}  
	htmpl.set("blkLavorazioni.maxPage",""+maxPage);
	htmpl.set("blkLavorazioni.currentPage",""+currentPage);
	  
	SolmrLogger.debug(this, "   END gestionePaginazione");
	return startRow;
}

private void popolaComboAnnoRiferimento(HttpSession session, Htmpl htmpl, LavContoTerziPerContoProprioFilter filter) throws Exception{
	SolmrLogger.debug(this, "   BEGIN popolaComboAnnoRiferimento");
	  
	List<String> listaAnni = (List<String>) session.getAttribute("ANNI_RIF_COMBO");
	
	SolmrLogger.debug(this, " -- numero di anni da caricare nella combo ="+listaAnni.size());
	      
	String annoSel = filter.getAnnoDiRiferimento();
	 
	SolmrLogger.debug(this, "-- annoCampagnaDaSelezionare ="+annoSel);
		
	for(String anno : listaAnni){
		
	htmpl.newBlock("blkComboAnno");
	
		htmpl.set("blkComboAnno.idAnnoRiferimento",anno);
		htmpl.set("blkComboAnno.annoRiferimentoDesc",anno);
		if(StringUtils.equals(annoSel, anno)){
			htmpl.set("blkComboAnno.annoRiferimentoSel","selected");  
		} 	
	} 	
	SolmrLogger.debug(this, "   END popolaComboAnnoRiferimento");
}

private void popolaComboUsoDelSuolo(HttpSession session, Htmpl htmpl, LavContoTerziPerContoProprioFilter filter) throws Exception{
	SolmrLogger.debug(this, "   BEGIN popolaComboUsoDelSuolo");
	
	LinkedHashMap<String, String> mapUsoSuolo = (LinkedHashMap<String, String>) session.getAttribute("USO_SUOLO_COMBO"); 

	SolmrLogger.debug(this, " -- numero di usi del suolo da caricare nella combo ="+mapUsoSuolo.size());
	      
	String idCategoriaUtilizzoUmaDaSel = "0";         
	if(StringUtils.isNotBlank(filter.getIdUsoDelSuolo())){      
	  idCategoriaUtilizzoUmaDaSel = filter.getIdUsoDelSuolo();
	}
	
	SolmrLogger.debug(this, "-- idCategoriaUtilizzoUmaDaSel ="+idCategoriaUtilizzoUmaDaSel);
		
	Iterator it = mapUsoSuolo.entrySet().iterator();
	
	while (it.hasNext()) {
		Map.Entry<String, String> entry = (Map.Entry<String, String>)it.next();
	
		htmpl.newBlock("blkComboUsoSuolo");
		
		htmpl.set("blkComboUsoSuolo.idUsoSuolo", entry.getKey());
		htmpl.set("blkComboUsoSuolo.descUsoSuolo", entry.getValue());

		if(StringUtils.equals(idCategoriaUtilizzoUmaDaSel,entry.getKey())){
		  htmpl.set("blkComboUsoSuolo.usoDelSuoloSel","selected");  
		} 	
	}	
	SolmrLogger.debug(this, "   END popolaComboUsoDelSuolo");
}


private void popolaComboLavorazione(HttpSession session, Htmpl htmpl, LavContoTerziPerContoProprioFilter filter) throws Exception{
	SolmrLogger.debug(this, "   BEGIN popolaComboLavorazione");
	
	LinkedHashMap<String, String> mapTipiLavorazione = (LinkedHashMap<String, String>) session.getAttribute("LAVORAZIONI_COMBO"); 
	
	SolmrLogger.debug(this, " -- numero lavorazioni da caricare nella combo ="+mapTipiLavorazione.size());
	      
	String idLavorazioniDaSel = "0";
	if(StringUtils.isNotBlank(filter.getIdLavorazione())){      
	  idLavorazioniDaSel = filter.getIdLavorazione();
	}
	
	SolmrLogger.debug(this, "-- idLavorazioniDaSel ="+idLavorazioniDaSel);
		
	Iterator it = mapTipiLavorazione.entrySet().iterator();
	
	while (it.hasNext()) {
		Map.Entry<String, String> entry = (Map.Entry<String, String>)it.next();
	
		htmpl.newBlock("blkComboLavorazione");
		
		htmpl.set("blkComboLavorazione.idLavorazione", entry.getKey());
		htmpl.set("blkComboLavorazione.lavorazioneDesc", entry.getValue());
		 	
		if(StringUtils.equals(idLavorazioniDaSel, entry.getKey())){
		  htmpl.set("blkComboLavorazione.lavorazioneSel","selected");  
		} 	
	}	
	SolmrLogger.debug(this, "   END popolaComboLavorazione");
}

%>
