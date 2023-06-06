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
  Vector elencoLavDaContoTerzi=null;
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/elencoLavDaContoTerziBis.htm");
%><%@include file = "/include/menu.inc" %><%
	DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


  DecimalFormat numericFormat4 = new DecimalFormat(SolmrConstants.FORMATO_NUMERIC_1INT_4DEC);

  //this.errErrorValExc(htmpl, request, exception);
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

  elencoLavDaContoTerzi=(Vector)session.getAttribute("vettLavDaContoTerzi");
  SolmrLogger.debug(this,"NELLA VIEW elencoLavDaContoTerziBis vale: "+elencoLavDaContoTerzi);
  if (elencoLavDaContoTerzi==null)
  {
    elencoLavDaContoTerzi=new Vector(); // Evito nullpointerexception
  }
  SolmrLogger.debug(this,"NELLA VIEW di elencoLavDaContoTerziBis elencoLavDaContoTerzi.size() vale: "+elencoLavDaContoTerzi.size());
  String startRowStr=request.getParameter("startRow");
  int startRow=0;
  int rows=elencoLavDaContoTerzi.size();

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
  if (elencoLavDaContoTerzi.size()==0)
  {
    maxPage=1;
  }
  int currentPage=startRow/SolmrConstants.NUM_MAX_ROWS_PAG+1+(startRow%SolmrConstants.NUM_MAX_ROWS_PAG>0?1:0);

  int size=elencoLavDaContoTerzi.size();
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
  //htmpl.set("numSerre",""+elencoLavDaContoTerzi.size());
  htmpl.set("maxPage",""+maxPage);
  htmpl.set("currentPage",""+currentPage);
  
  LavContoTerziVO elem= new LavContoTerziVO();
  if(elencoLavDaContoTerzi!=null && elencoLavDaContoTerzi.size()>0)
  {
   	  htmpl.newBlock("blkDati");
      htmpl.newBlock("blkSiLavorazioni");
  	  htmpl.newBlock("blkIntestazione");
  	  BigDecimal totaleConsCalc = BigDecimal.ZERO, totaleConsDich = BigDecimal.ZERO;
  	  
  	  //mi ricavo i totale
	    int sizeTot=elencoLavDaContoTerzi.size();
	    for( int i=0;i<sizeTot;i++)
	    {
	      elem = (LavContoTerziVO)elencoLavDaContoTerzi.elementAt(i);
	      
	      if (elem.getDataFineValidita()==null && elem.getDataCessazione()==null)
	      {
	      
		      if (elem.getConsumoCalcolato()!=null)
		        totaleConsCalc=totaleConsCalc.add(elem.getConsumoCalcolato());
		          
		      if (elem.getConsumoDichiarato()!=null)
		        totaleConsDich=totaleConsDich.add(elem.getConsumoDichiarato());      
		    }
	    }
  	  
  	  
		  for(int i=startRow;i<size && i< startRow+SolmrConstants.NUM_MAX_ROWS_PAG;i++)
		  {
			    elem = (LavContoTerziVO)elencoLavDaContoTerzi.elementAt(i);
				htmpl.newBlock("blkDati.blkLavorazione");
			    
			    htmpl.set("blkDati.blkLavorazione.idLavContoTerzi",StringUtils.checkNull(elem.getIdLavorazioneCT()));
				htmpl.set("blkDati.blkLavorazione.cuaa",StringUtils.checkNull(elem.getCuaa()));
				htmpl.set("blkDati.blkLavorazione.denominazione",StringUtils.checkNull(elem.getDenominazione()));
				htmpl.set("blkDati.blkLavorazione.lavorazione",StringUtils.checkNull(elem.getDescTipoLavorazione()));
				htmpl.set("blkDati.blkLavorazione.consumoCalcolato",""+StringUtils.checkNull(elem.getConsumoCalcolato()));
		    htmpl.set("blkDati.blkLavorazione.consumoDichiarato",""+StringUtils.checkNull(elem.getConsumoDichiarato()));
				htmpl.set("blkDati.blkLavorazione.partitaIva",elem.getPartitaIva());
				SolmrLogger.debug(this,"elem.getCuaa() vale: "+elem.getCuaa());
				SolmrLogger.debug(this,"elem.getExtIdAzienda() vale: "+elem.getExtIdAzienda());
				htmpl.set("blkDati.blkLavorazione.sedeLegale",StringUtils.checkNull(elem.getSedeLegaleAnag()));
				SolmrLogger.debug(this,"elem.getSedeLegaleAnag() vale: "+elem.getSedeLegaleAnag());
				
				htmpl.set("blkDati.blkLavorazione.indirizzoSedeLegale",StringUtils.checkNull(elem.getIndirizzoSedeLegale()));
				htmpl.set("blkDati.blkLavorazione.usoDelSuolo",StringUtils.checkNull(elem.getDescUsoDelSuolo()));
				htmpl.set("blkDati.blkLavorazione.unitaDiMisura",StringUtils.checkNull(elem.getDescUnitaMisura()));
				htmpl.set("blkDati.blkLavorazione.supOre",""+StringUtils.checkNull(elem.getSupOreFatturaStr()));
				
				htmpl.set("blkDati.blkLavorazione.inizioValidita",UmaDateUtils.formatDateNext(elem.getDataInizioValidita()));
				htmpl.set("blkDati.blkLavorazione.fineValidita",UmaDateUtils.formatDateNext(elem.getDataFineValidita()));
				htmpl.set("blkDati.blkLavorazione.dataCessazione",UmaDateUtils.formatDateNext(elem.getDataCessazione()));	
		  }
	  
	  htmpl.set("blkDati.totaleGasolio",StringUtils.checkNull(totaleConsCalc));
  	htmpl.set("blkDati.totaleBenzina",StringUtils.checkNull(totaleConsDich));
  	   
  }else{
   htmpl.newBlock("blkNoLavorazioni");
   }

  if (elencoLavDaContoTerzi.size()==0)
  {
    SolmrLogger.debug(this,"notifica");
    htmpl.set("notifica","Nessuna lavorazione storicizzata per la ditta uma selezionata");
  }

 // carico combo anniCampagna
  AnnoCampagnaVO annoCampagnaSel= (AnnoCampagnaVO)session.getAttribute("annoCampagna");
  
  SolmrLogger.debug(this,"NELLA VIEW annoCampagnaSel VALE: "+annoCampagnaSel);
   if(null!=annoCampagnaSel && !StringUtils.isStringEmpty(annoCampagnaSel.getAnnoCampagna())
  && elencoLavDaContoTerzi!=null && elencoLavDaContoTerzi.size()>0){
   			SolmrLogger.debug(this,"NELLA VIEW annoCampagnaSel.getAnnoCampagna() VALE: "+annoCampagnaSel.getAnnoCampagna());
	  		htmpl.set("blkSiLavorazioni.campagna",annoCampagnaSel.getAnnoCampagna());
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
