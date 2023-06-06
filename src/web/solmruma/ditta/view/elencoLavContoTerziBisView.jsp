<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="java.math.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%
	UmaFacadeClient umaClient = new UmaFacadeClient();
  String storicizzazione=request.getParameter("storico");
  Vector elencoLavContoTerzi=null;
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/elencoLavContoTerziBis.htm");
%><%@include file = "/include/menu.inc" %><%
	DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


  DecimalFormat numericFormat4 = new DecimalFormat(SolmrConstants.FORMATO_NUMERIC_1INT_4DEC);

  //this.errErrorValExc(htmpl, request, exception);
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

  elencoLavContoTerzi=(Vector)session.getAttribute("vettLavContoVerzi");
  SolmrLogger.debug(this,"NELLA VIEW elencoLavContoTerziBis vale: "+elencoLavContoTerzi);
  if (elencoLavContoTerzi==null)
  {
    elencoLavContoTerzi=new Vector(); // Evito nullpointerexception
  }
  SolmrLogger.debug(this,"NELLA VIEW di elencoLavContoTerziBis elencoLavContoTerzi.size() vale: "+elencoLavContoTerzi.size());
  String startRowStr=request.getParameter("startRow");
  int startRow=0;
  int rows=elencoLavContoTerzi.size();

  if (startRowStr!=null)
  {
    try
    {
      startRow=new Integer(startRowStr).intValue();
    }
    catch(Exception e) // Errore, suppongo startrow==0 e quindi non faccio nulla!!!
    {
    }
  }
  int prevPage=startRow-SolmrConstants.NUM_MAX_ROWS_PAG;
  int nextPage=startRow+SolmrConstants.NUM_MAX_ROWS_PAG;
  if (nextPage>=rows)
  {
    nextPage=startRow;
  }
  if (prevPage<=0)
  {
    prevPage=0;
  }
  int maxPage=rows/SolmrConstants.NUM_MAX_ROWS_PAG+(rows%SolmrConstants.NUM_MAX_ROWS_PAG>0?1:0);
  if (elencoLavContoTerzi.size()==0)
  {
    maxPage=1;
  }
  int currentPage=startRow/SolmrConstants.NUM_MAX_ROWS_PAG+1+(startRow%SolmrConstants.NUM_MAX_ROWS_PAG>0?1:0);

  int size=elencoLavContoTerzi.size();
  SolmrLogger.debug(this,"currentPage="+currentPage);
  SolmrLogger.debug(this,"maxPage="+maxPage);
  if (currentPage!=1)
  {
    htmpl.set("prev.prevPage",""+prevPage);
  }
  if (currentPage!=maxPage)
  {
    htmpl.set("next.nextPage",""+nextPage);
  }
  htmpl.set("numSerre",""+elencoLavContoTerzi.size());
  htmpl.set("maxPage",""+maxPage);
  htmpl.set("currentPage",""+currentPage);
  
  boolean flagIntermediario = false;
  LavContoTerziVO elem= new LavContoTerziVO();
  if(elencoLavContoTerzi!=null && elencoLavContoTerzi.size()>0){
   	  htmpl.newBlock("blkDati");
      htmpl.newBlock("blkSiLavorazioni");
  	  htmpl.newBlock("blkIntestazione");
  	  BigDecimal totaleConsCalc = BigDecimal.ZERO, totaleConsDich = BigDecimal.ZERO, totaleEccedenza = BigDecimal.ZERO;
  	  BigDecimal totaleGasolioCalc = BigDecimal.ZERO;
  	  
  	//mi ricavo i totale
    int sizeTot=elencoLavContoTerzi.size();
    for( int i=0;i<sizeTot;i++)
    {
      elem = (LavContoTerziVO)elencoLavContoTerzi.elementAt(i);
      
      if (elem.getDataFineValidita()==null && elem.getDataCessazione()==null)
      {
	      if (elem.getConsumoCalcolato()!=null)
	          totaleConsCalc=totaleConsCalc.add(elem.getConsumoCalcolato());
	          
	      if (elem.getConsumoDichiarato()!=null)
	        totaleConsDich=totaleConsDich.add(elem.getConsumoDichiarato());
	      
	      if (elem.getEccedenza()!=null)
	        totaleEccedenza=totaleEccedenza.add(elem.getEccedenza());   
	        
	      if  (elem.getGasolio()!=null)
          totaleGasolioCalc=totaleGasolioCalc.add(elem.getGasolio());       
      }
    }
  	  
	  for(int i=startRow;i<size && i< startRow+SolmrConstants.NUM_MAX_ROWS_PAG;i++)
	  {
	    elem = (LavContoTerziVO)elencoLavContoTerzi.elementAt(i);
		htmpl.newBlock("blkDati.blkLavorazione");
	    if(!StringUtils.isStringEmpty(elem.getIdLavorazioneOriginaria()))
	      {
	        htmpl.set("blkDati.blkLavorazione.modLavOriginaria", "color:red");
	        flagIntermediario = true;
	      }
	      
	      htmpl.set("blkDati.blkLavorazione.idLavContoTerzi",StringUtils.checkNull(elem.getIdLavorazioneCT()));
	      htmpl.set("blkDati.blkLavorazione.cuaa",StringUtils.checkNull(elem.getCuaa()));
	      htmpl.set("blkDati.blkLavorazione.denominazione",StringUtils.checkNull(elem.getDenominazione()));
	      htmpl.set("blkDati.blkLavorazione.lavorazione",StringUtils.checkNull(elem.getDescTipoLavorazione()));
	      htmpl.set("blkDati.blkLavorazione.gasolio",""+StringUtils.checkNull(elem.getGasolio()));
	      
	      htmpl.set("blkDati.blkLavorazione.consumoCalcolato",""+StringUtils.checkNull(elem.getConsumoCalcolatoStr()));
	      htmpl.set("blkDati.blkLavorazione.consumoDichiarato",""+StringUtils.checkNull(elem.getConsumoDichiaratoStr()));
	      htmpl.set("blkDati.blkLavorazione.eccedenza",""+StringUtils.checkNull(elem.getEccedenzaStr()));
	      
	      htmpl.set("blkDati.blkLavorazione.partitaIva",elem.getPartitaIva());
	      SolmrLogger.debug(this,"elem.getCuaa() vale: "+elem.getCuaa());
	      SolmrLogger.debug(this,"elem.getExtIdAzienda() vale: "+elem.getExtIdAzienda());
	      
	      if(elem.getExtIdAzienda()!=null){
	      	 htmpl.set("blkDati.blkLavorazione.sedeLegale",StringUtils.checkNull(elem.getSedeLegaleAnag()));
	      	 SolmrLogger.debug(this,"elem.getSedeLegaleAnag() vale: "+elem.getSedeLegaleAnag());
	      }else{
	      
	      		SolmrLogger.debug(this,"elem.getDescProvincia() vale: "+elem.getDescProvincia());
	      	  	String desc=elem.getDescComune();
	      		if(!StringUtils.isStringEmpty(elem.getDescProvincia())){
	      			desc=desc+" ("+elem.getDescProvincia()+")";
	      		}	
	      	 	htmpl.set("blkDati.blkLavorazione.sedeLegale",StringUtils.checkNull(desc));
	      }
	       //SolmrLogger.debug(this,"QUI 1 ");
	      htmpl.set("blkDati.blkLavorazione.indirizzoSedeLegale",StringUtils.checkNull(elem.getIndirizzoSedeLegale()));
	       //SolmrLogger.debug(this,"QUI 2 ");
	      htmpl.set("blkDati.blkLavorazione.usoDelSuolo",StringUtils.checkNull(elem.getDescUsoDelSuolo()));
	       //SolmrLogger.debug(this,"QUI 3 ");
	      htmpl.set("blkDati.blkLavorazione.unitaDiMisura",StringUtils.checkNull(elem.getDescUnitaMisura()));
	      
	      if (SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(elem.getTipoUnitaMisura())
             || SolmrConstants.TIPO_UNITA_MISURA_K.equalsIgnoreCase(elem.getTipoUnitaMisura()))
          htmpl.set("blkDati.blkLavorazione.supOre",""+StringUtils.checkNull(elem.getSupOreCalcolataStr()));

	      htmpl.set("blkDati.blkLavorazione.supOreFattura",""+StringUtils.checkNull(elem.getSupOreFattura()));
	       //SolmrLogger.debug(this,"QUI 6 ");
	      htmpl.set("blkDati.blkLavorazione.fatture",""+StringUtils.checkNull(elem.getNumeroFatture()));
	      //SolmrLogger.debug(this,"QUI 7 ");
	      //
	      
	      htmpl.set("blkDati.blkLavorazione.inizioValidita",UmaDateUtils.formatDateNext(elem.getDataInizioValidita()));
	       SolmrLogger.debug(this,"QUI 8 ");
	      htmpl.set("blkDati.blkLavorazione.fineValidita",UmaDateUtils.formatDateNext(elem.getDataFineValidita()));
	       SolmrLogger.debug(this,"QUI 9 ");
	      htmpl.set("blkDati.blkLavorazione.dataCessazione",UmaDateUtils.formatDateNext(elem.getDataCessazione()));	    
	      
	  }
	  
	  htmpl.set("blkDati.totaleGasolioCalc",StringUtils.checkNull(totaleGasolioCalc));
	  htmpl.set("blkDati.totaleConsCalc",StringUtils.checkNull(totaleConsCalc));
	  htmpl.set("blkDati.totaleConsDich",StringUtils.checkNull(totaleConsDich));
	  htmpl.set("blkDati.totaleEccedenza",StringUtils.checkNull(totaleEccedenza));
	   //SolmrLogger.debug(this,"QUI 8 ");
  	  htmpl.set("blkDati.totaleBenzinaCalc",StringUtils.checkNull(elem.getTotaleBenzina()));
  	   //SolmrLogger.debug(this,"QUI 9 ");
  	   
  AnnoCampagnaVO annoCampagnaSel= (AnnoCampagnaVO)session.getAttribute("annoCampagna");	   
  String umar=(String)request.getAttribute("PARAMETRO_UMAR");  
  
  //confrontto l'anno campagna con l'anno recuperato da DB
  if (Long.parseLong(annoCampagnaSel.getAnnoCampagna())<=Long.parseLong(umar))
  {
  	  if(null!= elem.getTotaleGasolioMod())
  	   	htmpl.set("blkDati.blkVisTotDichiarato.totaleGasolioDich",StringUtils.checkNull(elem.getTotaleGasolioMod()));
  }
       //SolmrLogger.debug(this,"QUI 11 ");
  }else{
   htmpl.newBlock("blkNoLavorazioni");
   }
  
  
  if(flagIntermediario)
    htmpl.newBlock("blkIntermediario");


  // carico combo anniCampagna
  AnnoCampagnaVO annoCampagnaSel= (AnnoCampagnaVO)session.getAttribute("annoCampagna");    
  
  SolmrLogger.debug(this,"NELLA VIEW annoCampagnaSel VALE: "+annoCampagnaSel);
  if(null!=annoCampagnaSel){
  	if(!StringUtils.isStringEmpty(annoCampagnaSel.getAnnoCampagna())
  		&& elencoLavContoTerzi!=null && elencoLavContoTerzi.size()>0){
   			SolmrLogger.debug(this,"NELLA VIEW annoCampagnaSel.getAnnoCampagna() VALE: "+annoCampagnaSel.getAnnoCampagna());
	  		htmpl.set("blkSiLavorazioni.campagna",annoCampagnaSel.getAnnoCampagna());
	  }
	  if(!StringUtils.isStringEmpty(annoCampagnaSel.getCuaaContoProprio())){
   			SolmrLogger.debug(this,"NELLA VIEW annoCampagnaSel.getCuaaContoProprio() VALE: "+annoCampagnaSel.getCuaaContoProprio());
	  		htmpl.set("cuaaFiltroStr",annoCampagnaSel.getCuaaContoProprio());
	  }
	  if(!StringUtils.isStringEmpty(annoCampagnaSel.getPartitaIvaContoProprio())){
   			SolmrLogger.debug(this,"NELLA VIEW annoCampagnaSel.getPartitaIvaContoProprio() VALE: "+annoCampagnaSel.getPartitaIvaContoProprio());
	  		htmpl.set("partitaIvaFiltroStr",annoCampagnaSel.getPartitaIvaContoProprio());
	  }
	  if(!StringUtils.isStringEmpty(annoCampagnaSel.getDenominazioneContoProprio())){
   			SolmrLogger.debug(this,"NELLA VIEW annoCampagnaSel.getDenominazioneContoProprio() VALE: "+annoCampagnaSel.getDenominazioneContoProprio());
	  		htmpl.set("denominazioneFiltroStr",annoCampagnaSel.getDenominazioneContoProprio());
	  }
  }
  Vector vettAnniCampagna =(Vector)session.getAttribute("LavCTvettAnniCampagna");
  SolmrLogger.debug(this,"NELLA VIEW vettAnniCampagna vale: "+vettAnniCampagna);
  if(vettAnniCampagna!=null && vettAnniCampagna.size()>0){
  	SolmrLogger.debug(this,"NELLA VIEW vettAnniCampagna.size() vale: "+vettAnniCampagna.size());
  	for(int i=0;i<vettAnniCampagna.size();i++){
  		AnnoCampagnaVO elemAnno = (AnnoCampagnaVO)vettAnniCampagna.get(i);
  		htmpl.newBlock("blkComboAnno");
  		//htmpl.set("blkComboAnno.idAnnoRiferimento",""+elemAnno.getId_campagnaContoTerzisti());
  		htmpl.set("blkComboAnno.idAnnoRiferimento",""+elemAnno.getAnnoCampagna());
  		htmpl.set("blkComboAnno.annoRiferimentoDesc",""+elemAnno.getAnnoCampagna());
  		SolmrLogger.debug(this,"NELLA VIEW CARICA COMBO annoCampagnaSel vale: "+annoCampagnaSel);
  		SolmrLogger.debug(this,"NELLA VIEW CARICA COMBO elemAnno.getAnnoCampagna() vale: "+elemAnno.getAnnoCampagna());
  		if (i==0 ||(annoCampagnaSel!=null 
  			&& (annoCampagnaSel.getAnnoCampagna()).equalsIgnoreCase(elemAnno.getAnnoCampagna()))){
  			SolmrLogger.debug(this,"NELLA VIEW CARICA COMBO annoCampagnaSel.getAnnoCampagna() vale: "+annoCampagnaSel.getAnnoCampagna());
       		htmpl.set("blkComboAnno.annoRiferimentoSel","selected");
    	}
  	}
				
  } 

  out.print(htmpl.text());
%>
<%!private String formatDate(Date aDate)
  {
    if (aDate==null)
    {
      return "";
    }
    return UmaDateUtils.formatDate(aDate);
  }%>
