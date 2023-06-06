<%@page import="it.csi.solmr.dto.filter.LavContoProprioFilter"%>
<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.exception.*" %>

<%
  SolmrLogger.debug(this, "   BEGIN elencoLavContoProprioView");
  
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Vector<LavContoProprioVO> elencoLavContoProprio=null;
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/elencoLavContoProprio.htm");
%>
  <%@include file = "/include/menu.inc" %>
<%

  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
  
  LavContoProprioFilter filter = (LavContoProprioFilter)session.getAttribute("filterRicercaLavContoProprio");    
  String operation = (String)request.getAttribute("operation");
  
  // --- Popolamento combo 'Anno di riferimento'
  SolmrLogger.debug(this, "---- Popolamento combo 'Anno di riferimento'");
  popolaComboAnnoRiferimento(session,htmpl,filter,request);
  
  // -- Popolameto combo 'Assegnazione carburante'
  SolmrLogger.debug(this, "---- Popolameto combo 'Assegnazione carburante'");
  popolaComboAssegnazioneCarburante(session, htmpl, filter, request);
  
  // --- Popolamento combo 'Uso del Suolo'
  SolmrLogger.debug(this, "---- Popolamento combo 'Uso del Suolo'");
  popolaComboUsoDelSuolo(session, htmpl, filter, request);
  
  // --- Popolamento combo 'Uso del Suolo'
  SolmrLogger.debug(this, "---- Popolamento combo 'Lavorazione'");
  popolaComboLavorazione(session, htmpl, filter, request);
  
  
  // --- Selezione o no del check 'Visualizza variazioni storiche'
  if(filter.getVariazioniStoriche())      
    htmpl.set("variazStoricheChecked","checked");
  
  
  // ---- Popolamento Tabella con i risultati di ricerca
  SolmrLogger.debug(this, "---- Popolamento Tabella con i risultati di ricerca");
  popolaTabellaRisultatoRicerca(session,htmpl,filter,request);
  
  
  
  out.print(htmpl.text());
%>
<%!

  // -- Popola con il risultato di ricerca
  private void popolaTabellaRisultatoRicerca(HttpSession session,Htmpl htmpl,LavContoProprioFilter filter,HttpServletRequest request) throws Exception{
    SolmrLogger.debug(this, "   BEGIN popolaTabellaRisultatoRicerca");
                
    // Controllo se sono stati trovati dei risultati dalla ricerca
    Vector<LavContoProprioVO> elencoLavContoProprio = (Vector<LavContoProprioVO>)session.getAttribute("elencoLavContoProprio");
    if(elencoLavContoProprio == null || elencoLavContoProprio.size()==0){
     SolmrLogger.debug(this, "--- non sono state trovate delle Lavorazioni Conto Proprio");
     htmpl.newBlock("blkNoLavorazioni");
    }
    else{
      SolmrLogger.debug(this, "--- sono state trovate delle Lavorazioni Conto Proprio, quante ="+elencoLavContoProprio.size());  	  
      htmpl.newBlock("blkLavorazioni");
      
      // -- COLONNE AGGIUNTIVE PER STORICO
      // Controllo se è stata effettuata una ricerca con 'variazioni storiche' o no (in questo caso si devono visualizzare delle colonne in più) 
	  if(filter.getVariazioniStoriche()){
	     SolmrLogger.debug(this, "--- E' stata effettuata una ricerca con VARIAZIONI STORICHE	");
	     htmpl.newBlock("blkLavorazioni.blkColStorico");
	  }
	  else{
	    SolmrLogger.debug(this, "--- E' stata effettuata una ricerca senza VARIAZIONI STORICHE	");
	  }
      
      // --------- GESTIONE PAGINAZIONE ---------------
      int startRow = gestionePaginazione(htmpl,request,elencoLavContoProprio);
      SolmrLogger.debug(this, "--- startRow ="+startRow);  
      
      HashMap<String, String> hmMotivoLavoraz = new HashMap<String,String>();
         
 
      for(int i=startRow;i<elencoLavContoProprio.size() && i< startRow+SolmrConstants.NUM_MAX_ROWS_PAG;i++){
        htmpl.newBlock("blkLavorazioni.blkLavContoProprio");
        LavContoProprioVO lavCP = elencoLavContoProprio.get(i);
        
        htmpl.set("blkLavorazioni.blkLavContoProprio.idLavContoProprio", lavCP.getIdLavorazioneContoProprio());
        htmpl.set("blkLavorazioni.blkLavContoProprio.usoDelSuolo", lavCP.getUsoDelSuolo());
        htmpl.set("blkLavorazioni.blkLavContoProprio.lavorazione", lavCP.getLavorazione());
        
        htmpl.set("blkLavorazioni.blkLavContoProprio.codTipoLavorazione", lavCP.getCodiceMotivoLavoraz());
        // popolo l'HashMap per la legenda Motivo lavorazione
        hmMotivoLavoraz.put(lavCP.getCodiceMotivoLavoraz(), lavCP.getDescrMotivoLavoraz());
        
        htmpl.set("blkLavorazioni.blkLavContoProprio.superficie", StringUtils.formatDouble4(lavCP.getSuperficie()));
        htmpl.set("blkLavorazioni.blkLavContoProprio.unitaMisura", lavCP.getUnitaMisura());
        htmpl.set("blkLavorazioni.blkLavContoProprio.numEsecuzioni", lavCP.getNumEsecuzioni());      
        htmpl.set("blkLavorazioni.blkLavContoProprio.litriCarburante", StringUtils.formatDouble2(lavCP.getLitriLavorazione()));
        
        htmpl.set("blkLavorazioni.blkLavContoProprio.litriBase", StringUtils.formatDouble2(lavCP.getLitriBase()));
        htmpl.set("blkLavorazioni.blkLavContoProprio.litriMedioImpasto", StringUtils.formatDouble2(lavCP.getLitriMedioImpasto()));
        htmpl.set("blkLavorazioni.blkLavContoProprio.litriAcclivita", StringUtils.formatDouble2(lavCP.getLitriAcclivita()));      
	 
	    // Controllo se è stata effettuata una ricerca con 'variazioni storiche' o no (in questo caso si devono visualizzare delle colonne in più) 
	    if(filter.getVariazioniStoriche()){
	       htmpl.newBlock("blkLavorazioni.blkValStorico");
	      // valori per colonne aggiuntive
	      htmpl.set("blkLavorazioni.blkLavContoProprio.blkValStorico.dataInizioAttivita",lavCP.getDataInizioValidita());
	      htmpl.set("blkLavorazioni.blkLavContoProprio.blkValStorico.dataFineAttivita", StringUtils.checkNull(lavCP.getDataFineValidita()));
	      htmpl.set("blkLavorazioni.blkLavContoProprio.blkValStorico.dataCessazione", StringUtils.checkNull(lavCP.getDataCessazione()));
	    }	
	          
      }// chiusura ciclo sugli elementi trovati
      
      // Formatto la stringa per la Legenda 'Motivo lavorazione'
      String legendaLavorazioni = "";
      Set<String> keys = hmMotivoLavoraz.keySet();
	  if(!keys.isEmpty()){	 
	     Iterator itKeys = keys.iterator();
	     int cont = 0;
	 	 while (itKeys.hasNext()){
	 	   String chiave = (String)itKeys.next();
	 	   SolmrLogger.debug(this, " -- chiave ="+chiave);
	 	   if(cont == 0){
	 	     legendaLavorazioni = chiave + " - "+hmMotivoLavoraz.get(chiave);
	 	   }
	 	   else{
	 	    legendaLavorazioni += ", "+chiave + " - "+hmMotivoLavoraz.get(chiave);
	 	   }
	 	   cont +=1;
	 	 }
	  }	  
      
      htmpl.set("blkLavorazioni.legendaLavorazioni", legendaLavorazioni);
      
      // Valore del totale carburante : TOTALE RELATIVO AL RISULTATO COMPLETO DELLA RICERCA ed esclusivamente dei record con DATA_FINE_VALIDITA e DATA_CESSAZIONE non valorizzate  
      htmpl.set("blkLavorazioni.totaleLitriCarburante", StringUtils.formatDouble2(elencoLavContoProprio.get(startRow).getTotaleLitriLavorazione()));
      
      // Visualizzo il TOTALE (totale di tutti i record trovati)
      if(!filter.getVariazioniStoriche())
        htmpl.newBlock("blkLavorazioni.totCasoNoStorico");
      else
        htmpl.newBlock("blkLavorazioni.totCasoStorico");
      
    } // FINE sono state trovate delle lavorazioni
    
    
    SolmrLogger.debug(this, "   END popolaTabellaRisultatoRicerca");
  }


 // --- Gestione per la paginazione (torna startRow)
 private int gestionePaginazione(Htmpl htmpl, HttpServletRequest request, Vector<LavContoProprioVO> elencoLavContoProprio) throws Exception{
   SolmrLogger.debug(this, "  BEGIN gestionePaginazione");
   
   //String startRowStr=request.getParameter("startRow");
   String startRowStr=(String)request.getAttribute("startRow");
   SolmrLogger.debug(this, " --- startRowStr ="+startRowStr);
   int startRow=0;
   int rows = elencoLavContoProprio.size();

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
  if (nextPage>=rows)
  {
    nextPage=startRow;
  }
  if (prevPage<=0)
  {
    prevPage=0;
  }
  int maxPage=rows/SolmrConstants.NUM_MAX_ROWS_PAG+(rows%SolmrConstants.NUM_MAX_ROWS_PAG>0?1:0);
  if (elencoLavContoProprio.size()==0)
  {
    maxPage=1;
  }
  int currentPage=startRow/SolmrConstants.NUM_MAX_ROWS_PAG+1+(startRow%SolmrConstants.NUM_MAX_ROWS_PAG>0?1:0);

  int size=elencoLavContoProprio.size();
  SolmrLogger.debug(this,"--- currentPage="+currentPage);
  SolmrLogger.debug(this,"---- maxPage="+maxPage);
  if (currentPage!=1)
  {
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


 // --- Popola la combo 'Anno di riferimento' (se siamo al primo accesso alla pagina, seleziona come default l'anno attuale)
 private void popolaComboAnnoRiferimento(HttpSession session, Htmpl htmpl, LavContoProprioFilter filter, HttpServletRequest request) throws Exception{
   SolmrLogger.debug(this, "   BEGIN popolaComboAnnoRiferimento");
   
   Vector<CodeDescr> elencoAnniDiRiferimento = (Vector<CodeDescr>)session.getAttribute("elencoAnniRiferimento");
   SolmrLogger.debug(this, " -- numero di anni da caricare nella combo ="+elencoAnniDiRiferimento.size());
         
   int annoCampagnaDaSelezionare = new Integer(filter.getAnnoDiRiferimento()).intValue();
   
   SolmrLogger.debug(this, "-- annoCampagnaDaSelezionare ="+annoCampagnaDaSelezionare);
 	
   for(int i=0;i<elencoAnniDiRiferimento.size();i++){  
  	htmpl.newBlock("blkComboAnno");  	
  	CodeDescr anno = elencoAnniDiRiferimento.get(i);
 	htmpl.set("blkComboAnno.idAnnoRiferimento",""+anno.getCode());
 	htmpl.set("blkComboAnno.annoRiferimentoDesc",""+anno.getDescription());
 	 	
 	if(annoCampagnaDaSelezionare == anno.getCode().intValue()){
 	  htmpl.set("blkComboAnno.annoRiferimentoSel","selected");  
 	} 	
  }	
   SolmrLogger.debug(this, "   END popolaComboAnnoRiferimento");
 }
 
 
 // --- Popola la combo 'Assegnazione carburante'
 private void popolaComboAssegnazioneCarburante(HttpSession session, Htmpl htmpl, LavContoProprioFilter filter, HttpServletRequest request) throws Exception{
   SolmrLogger.debug(this, "   BEGIN popolaComboAssegnazioneCarburante");
   
   Vector<CodeDescriptionLong> elencoAssegnazCarburante = (Vector<CodeDescriptionLong>)session.getAttribute("elencoAssegnazCarburante");     
   if(elencoAssegnazCarburante != null && elencoAssegnazCarburante.size() >0 ){
       SolmrLogger.debug(this, " -- numero assegnazioni carburante da caricare nella combo ="+elencoAssegnazCarburante.size());                
	   long idAssegnazCarburanteDaSel = 0;         
	   if(filter.getIdAssegnazioneCarburante() != null && !filter.getIdAssegnazioneCarburante().trim().equals(""))      
	     idAssegnazCarburanteDaSel = new Long(filter.getIdAssegnazioneCarburante()).longValue();
	   
	   SolmrLogger.debug(this, "-- idAssegnazCarburanteDaSel ="+idAssegnazCarburanteDaSel);
	 	
	   for(int i=0;i<elencoAssegnazCarburante.size();i++){  
	  	htmpl.newBlock("blkComboAssegnazCarb");  	
	  	CodeDescriptionLong assegnazCarb = elencoAssegnazCarburante.get(i);
	 	htmpl.set("blkComboAssegnazCarb.idAssegnazioneCarb",""+assegnazCarb.getCode());
	 	htmpl.set("blkComboAssegnazCarb.assegnazioneCarbDesc",""+assegnazCarb.getDescription());
	 	 	
	 	if(idAssegnazCarburanteDaSel == assegnazCarb.getCode().longValue()){
	 	  htmpl.set("blkComboAssegnazCarb.assegnazCarbSel","selected");  
	 	} 	
	   }
   }	
   SolmrLogger.debug(this, "   END popolaComboAssegnazioneCarburante");
 }
 
 // --- Popola la combo 'Uso del suolo'
 private void popolaComboUsoDelSuolo(HttpSession session, Htmpl htmpl, LavContoProprioFilter filter, HttpServletRequest request) throws Exception{
   SolmrLogger.debug(this, "   BEGIN popolaComboUsoDelSuolo");
   
   Vector<CodeDescr> elencoUsiDelSuolo = (Vector<CodeDescr>)session.getAttribute("elencoUsiDelSuolo");
   SolmrLogger.debug(this, " -- numero di usi del suolo da caricare nella combo ="+elencoUsiDelSuolo.size());
         
   int idCategoriaUtilizzoUmaDaSel = 0;         
   if(filter.getIdCategoriaUtilizzoUma() != null && !filter.getIdCategoriaUtilizzoUma().trim().equals(""))      
     idCategoriaUtilizzoUmaDaSel = new Integer(filter.getIdCategoriaUtilizzoUma()).intValue();
   
   SolmrLogger.debug(this, "-- idCategoriaUtilizzoUmaDaSel ="+idCategoriaUtilizzoUmaDaSel);
 	
   for(int i=0;i<elencoUsiDelSuolo.size();i++){  
  	htmpl.newBlock("blkComboUsoSuolo");  	
  	CodeDescr usoDelSuolo = elencoUsiDelSuolo.get(i);
 	htmpl.set("blkComboUsoSuolo.idUsoSuolo",""+usoDelSuolo.getCode());
 	htmpl.set("blkComboUsoSuolo.descUsoSuolo",""+usoDelSuolo.getDescription());
 	 	
 	if(idCategoriaUtilizzoUmaDaSel == usoDelSuolo.getCode().intValue()){
 	  htmpl.set("blkComboUsoSuolo.usoDelSuoloSel","selected");  
 	} 	
  }	
   SolmrLogger.debug(this, "   END popolaComboUsoDelSuolo");
 }
 
 
 // Popola la combo 'Lavorazione'
 private void popolaComboLavorazione(HttpSession session, Htmpl htmpl, LavContoProprioFilter filter, HttpServletRequest request) throws Exception{
   SolmrLogger.debug(this, "   BEGIN popolaComboLavorazione");
   
   Vector<CodeDescr> elencoLavorazioni = (Vector<CodeDescr>)session.getAttribute("elencoLavorazioni");
   SolmrLogger.debug(this, " -- numero lavorazioni da caricare nella combo ="+elencoLavorazioni.size());
         
   int idLavorazioniDaSel =0;
   if(filter.getIdLavorazioni() != null && !filter.getIdLavorazioni().trim().equals(""))      
     idLavorazioniDaSel = new Integer(filter.getIdLavorazioni()).intValue();
   
   SolmrLogger.debug(this, "-- idLavorazioniDaSel ="+idLavorazioniDaSel);
 	
   for(int i=0;i<elencoLavorazioni.size();i++){  
  	htmpl.newBlock("blkComboLavorazione");  	
  	CodeDescr lav = elencoLavorazioni.get(i);
 	htmpl.set("blkComboLavorazione.idLavorazione",""+lav.getCode());
 	htmpl.set("blkComboLavorazione.lavorazioneDesc",""+lav.getDescription());
 	 	
 	if(idLavorazioniDaSel == lav.getCode().intValue()){
 	  htmpl.set("blkComboLavorazione.lavorazioneSel","selected");  
 	} 	
  }	
   SolmrLogger.debug(this, "   END popolaComboLavorazione");
 }
 


  
  %>
