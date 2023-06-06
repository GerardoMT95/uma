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
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/elencoLavDaContoTerzi.htm");
%><%@include file = "/include/menu.inc" %><%
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


  DecimalFormat numericFormat4 = new DecimalFormat(SolmrConstants.FORMATO_NUMERIC_1INT_4DEC);

  //this.errErrorValExc(htmpl, request, exception);
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

  elencoLavDaContoTerzi=(Vector)session.getAttribute("vettLavDaContoTerzi");
  SolmrLogger.debug(this,"NELLA VIEW elencoLavDaContoTerzi vale: "+elencoLavDaContoTerzi);
  if (elencoLavDaContoTerzi==null)
  {
    elencoLavDaContoTerzi=new Vector();
  }
  SolmrLogger.debug(this,"NELLA VIEW elencoLavDaContoTerzi.size() vale: "+elencoLavDaContoTerzi.size());
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
  Long radio=null;
  
  LavContoTerziVO elem= new LavContoTerziVO();
  if(elencoLavDaContoTerzi!=null && elencoLavDaContoTerzi.size()>0){
  
  	  htmpl.newBlock("blkSiLavorazioni");	
  	  htmpl.newBlock("blkIntestazione");
  	  htmpl.newBlock("blkDati");
  	  BigDecimal totaleConsCalc = BigDecimal.ZERO, totaleConsDich = BigDecimal.ZERO;

      //mi ricavo i totale
    int sizeTot=elencoLavDaContoTerzi.size();
    for( int i=0;i<sizeTot;i++)
    {
      elem = (LavContoTerziVO)elencoLavDaContoTerzi.elementAt(i);
      if (elem.getConsumoCalcolato()!=null)
        totaleConsCalc=totaleConsCalc.add(elem.getConsumoCalcolato());
          
      if (elem.getConsumoDichiarato()!=null)
        totaleConsDich=totaleConsDich.add(elem.getConsumoDichiarato());       
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
			
		  htmpl.set("blkDati.blkLavorazione.supOreFattura",""+StringUtils.checkNull(elem.getSupOreFatturaStr()));
	    
	  }// end for
	  
	  htmpl.set("blkDati.totaleConsCalc",StringUtils.checkNull(totaleConsCalc));
  	  htmpl.set("blkDati.totaleConsDich",StringUtils.checkNull(totaleConsDich));
  }
  else{
   htmpl.newBlock("blkNoLavorazioni");
   }
  //String visPulsanteImportaLav =(String)request.getAttribute("flagVisPulsanteImportaLav");
  boolean visPulsanteImportaLav =verificaCondizioniPulsanteImportaLav(request,umaClient);
  SolmrLogger.debug(this,"Sono in elencoLavDaContoTerziView  e visPulsanteImportaLav vale: "+visPulsanteImportaLav);
  if(visPulsanteImportaLav){
  	htmpl.newBlock("blkImporta");
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
  Vector vett= new Vector();
  if(vettAnniCampagna!=null && vettAnniCampagna.size()>0){
  	vett=vettAnniCampagna;
  }
  	SolmrLogger.debug(this,"NELLA VIEW vettCampagna da stampare vett.size() vale: "+vett.size());
  	
  	for(int i=0;i<vett.size();i++){
  		AnnoCampagnaVO elemAnno = (AnnoCampagnaVO)vett.get(i);
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
  	
						
  
  out.print(htmpl.text());
%>
<%!private String formatDate(Date aDate)
  {
    if (aDate==null)
    {
      return "";
    }
    return UmaDateUtils.formatDate(aDate);
  }
  
  private boolean verificaCondizioniPulsanteImportaLav(HttpServletRequest request,UmaFacadeClient umaClient)throws SolmrException{
		boolean visualizza=true;
		try{
		
				SolmrLogger.debug(this," verificaCondizioniPulsanteImportaLav BEGIN...");
				RuoloUtenza ruoloUtenza = (RuoloUtenza) request.getSession().getAttribute("ruoloUtenza");
				if(ruoloUtenza!=null)
					SolmrLogger.debug(this,"profile.getRuoloUtenza().isUtenteIntermediario() vale: "+ruoloUtenza.isUtenteIntermediario());					
				if(!ruoloUtenza.isUtenteIntermediario()){
					visualizza=false;
				}else{
					AnnoCampagnaVO annoCampagna =(AnnoCampagnaVO)request.getSession().getAttribute("annoCampagna");
					if(annoCampagna!=null )
						SolmrLogger.debug(this,"annoCampagna.getAnnoCampagna() vale: "+annoCampagna.getAnnoCampagna());
					if(null!=annoCampagna && !StringUtils.isStringEmpty(annoCampagna.getAnnoCampagna())){
							String annoOggi = String.valueOf(UmaDateUtils.getCurrentYear().intValue());
							String annoOggiMenoUno = String.valueOf((UmaDateUtils.getCurrentYear().intValue()-1));
							SolmrLogger.debug(this,"annoCampagna.getAnnoCampagna() VALE: "+annoCampagna.getAnnoCampagna());
							if(!(annoCampagna.getAnnoCampagna().equalsIgnoreCase(annoOggi) 
								|| annoCampagna.getAnnoCampagna().equalsIgnoreCase(annoOggiMenoUno))){
									visualizza=false;
							}else{
								DittaUMAAziendaVO dittaUma = (DittaUMAAziendaVO)request.getSession().getAttribute("dittaUMAAziendaVO");		
								Vector vett=umaClient.findDomAssByIdDittaUmaAnnoRif(dittaUma.getIdDittaUMA(), annoCampagna.getAnnoCampagna());
								SolmrLogger.debug(this,"vett di findDomAssByIdDittaUmaAnnoRif vale: "+vett);
								if(vett!=null )
									SolmrLogger.debug(this,"vett.size() di findDomAssByIdDittaUmaAnnoRif   vale: "+vett.size());
								if(vett==null || vett.size()>0){
									visualizza=false;							
								}	
							}		
					}
				}
		}catch(SolmrException e){
			  request.setAttribute("errorMessage",e.getMessage());
	         
	          e.printStackTrace();
	          SolmrLogger.debug(this,"ERRORE NEL CONTROLLER verificaCondizioniPulsanteImportaLav.. "+e.getMessage());
	          
	    }
	    SolmrLogger.debug(this," verificaCondizioniPulsanteImportaLav  visualizza vale: "+visualizza);
	    if(visualizza)
  	    		//request.setAttribute("flagVisPulsanteImportaLav","visualizza");
		SolmrLogger.debug(this," verificaCondizioniPulsanteImportaLav  END...");
		return visualizza;

}
  
  
  %>
