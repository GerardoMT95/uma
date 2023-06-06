<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="java.math.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Vector elencoLavContoTerzi=null;
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/elencoLavContoTerzi.htm");
%>
  <%@include file = "/include/menu.inc" %>
<%

  //this.errErrorValExc(htmpl, request, exception);
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

  elencoLavContoTerzi=(Vector)session.getAttribute("vettLavContoVerzi");
  SolmrLogger.debug(this,"NELLA VIEW elencoLavContoTerzi vale: "+elencoLavContoTerzi);
  if (elencoLavContoTerzi==null)
  {
    elencoLavContoTerzi=new Vector(); // Evito nullpointerexception
  }
  SolmrLogger.debug(this,"NELLA VIEW elencoLavContoTerzi.size() vale: "+elencoLavContoTerzi.size());
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
  if(elencoLavContoTerzi!=null && elencoLavContoTerzi.size()>0)
  {
    htmpl.newBlock("blkSiLavorazioni");	
    htmpl.newBlock("blkIntestazione");
    htmpl.newBlock("blkDati");
    BigDecimal totaleConsCalc = BigDecimal.ZERO, totaleConsDich = BigDecimal.ZERO, totaleEccedenza = BigDecimal.ZERO;
    BigDecimal totaleGasolioCalc = BigDecimal.ZERO;
    
    //mi ricavo i totale
    int sizeTot=elencoLavContoTerzi.size();
    for( int i=0;i<sizeTot;i++)
    {
      elem = (LavContoTerziVO)elencoLavContoTerzi.elementAt(i);
      if (elem.getConsumoCalcolato()!=null)
          totaleConsCalc=totaleConsCalc.add(elem.getConsumoCalcolato());
          
      if (elem.getConsumoDichiarato()!=null)
        totaleConsDich=totaleConsDich.add(elem.getConsumoDichiarato());
      
      if (elem.getEccedenza()!=null)
        totaleEccedenza=totaleEccedenza.add(elem.getEccedenza());      
        
      if  (elem.getGasolio()!=null)
        totaleGasolioCalc=totaleGasolioCalc.add(elem.getGasolio());  
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
      if(elem.getExtIdAzienda()!=null)
      {
        htmpl.set("blkDati.blkLavorazione.sedeLegale",StringUtils.checkNull(elem.getSedeLegaleAnag()));
        SolmrLogger.debug(this,"elem.getSedeLegaleAnag() vale: "+elem.getSedeLegaleAnag());
      }
      else
      {
      	SolmrLogger.debug(this,"elem.getDescProvincia() vale: "+elem.getDescProvincia());
       	String desc=elem.getDescComune();
      	if(!StringUtils.isStringEmpty(elem.getDescProvincia()))
      	{
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
       //SolmrLogger.debug(this,"QUI 4 ");
      htmpl.set("blkDati.blkLavorazione.supOreFattura",""+StringUtils.checkNull(elem.getSupOreFatturaStr()));
      
      if (SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(elem.getTipoUnitaMisura())
             || SolmrConstants.TIPO_UNITA_MISURA_K.equalsIgnoreCase(elem.getTipoUnitaMisura()) || SolmrConstants.TIPO_UNITA_MISURA_M.equalsIgnoreCase(elem.getTipoUnitaMisura())){
	       		//SolmrLogger.debug(this,"QUI 5 ");
	      		htmpl.set("blkDati.blkLavorazione.supOre",""+StringUtils.checkNull(elem.getSupOreCalcolataStr()));
       			//SolmrLogger.debug(this,"QUI 6 ");
    	}
      htmpl.set("blkDati.blkLavorazione.fatture",""+StringUtils.checkNull(elem.getNumeroFatture()));
       //SolmrLogger.debug(this,"QUI 7 ");
	  }// end for
	  
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
	 	  {
	 	  	htmpl.set("blkDati.blkVisTotDichiarato.totaleGasolioDich",StringUtils.checkNull(elem.getTotaleGasolioMod()));
	 	  }
	  	 
 	  }
 	  //SolmrLogger.debug(this,"QUI 10 ");
     
    //SolmrLogger.debug(this,"QUI 11 ");
  }
  else
  {
    htmpl.newBlock("blkNoLavorazioni");
  }
  //String visPulsanteImportaLav =(String)request.getAttribute("flagVisPulsanteImportaLav");
  boolean visPulsanteImportaLav =verificaCondizioniPulsanteImportaLav(request,umaClient);
  SolmrLogger.debug(this,"Sono in elencoLavContoTerziView  e visPulsanteImportaLav vale: "+visPulsanteImportaLav);
  if(visPulsanteImportaLav)
  {
  	htmpl.newBlock("blkImporta");
  }
  
  if(flagIntermediario)
    htmpl.newBlock("blkIntermediario");
/*
  Double volumeTotale = new Double(0);
  for(int i=0;i<elencoLavContoTerzi.size();i++){
    LavContoTerziVO serraVO=(LavContoTerziVO)elencoLavContoTerzi.get(i);
    volumeTotale = new Double( serraVO.getVolumeMetriCubi().doubleValue() + volumeTotale.doubleValue() );
  }

  //if( supUtilizzataTotale.doubleValue()!=0 ){
  if (elencoLavContoTerzi.size()!=0){
    SolmrLogger.debug(this,"volumeTotale!=0");
    htmpl.newBlock("blkSommaVolume");
//    String volumeTotaleStr = numericFormat4.format(volumeTotale);
    htmpl.set("blkSommaVolume.volumeTotale",volumeTotale==null?null:""+volumeTotale.longValue());
  }
*/
 	

 // carico combo anniCampagna
  AnnoCampagnaVO annoCampagnaSel= (AnnoCampagnaVO)session.getAttribute("annoCampagna");
  SolmrLogger.debug(this,"NELLA VIEW annoCampagnaSel VALE: "+annoCampagnaSel);
  
  if(null!=annoCampagnaSel)
  {
	  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
	  // se non ci sono stati errori o se è un messaggio da visualizzare nella popup -> prendo oggetto in sessione
	  if(errors == null || errors.size()==0 || (errors.size() == 1 && (errors.get("error") != null && errors.get("error").next() != null)) ){
	      if(!StringUtils.isStringEmpty(annoCampagnaSel.getAnnoCampagna()) && elencoLavContoTerzi!=null && elencoLavContoTerzi.size()>0)
  	      {
   		    SolmrLogger.debug(this,"NELLA VIEW annoCampagnaSel.getAnnoCampagna() VALE: "+annoCampagnaSel.getAnnoCampagna());
	  	    htmpl.set("blkSiLavorazioni.campagna",annoCampagnaSel.getAnnoCampagna());
	      }
		  if(!StringUtils.isStringEmpty(annoCampagnaSel.getCuaaContoProprio()))
		  {
	   		SolmrLogger.debug(this,"NELLA VIEW annoCampagnaSel.getCuaaContoProprio() VALE: "+annoCampagnaSel.getCuaaContoProprio());
		  	htmpl.set("cuaaFiltroStr",annoCampagnaSel.getCuaaContoProprio());
		  }
		  if(!StringUtils.isStringEmpty(annoCampagnaSel.getPartitaIvaContoProprio()))
		  {
	   		SolmrLogger.debug(this,"NELLA VIEW annoCampagnaSel.getPartitaIvaContoProprio() VALE: "+annoCampagnaSel.getPartitaIvaContoProprio());
		  	htmpl.set("partitaIvaFiltroStr",annoCampagnaSel.getPartitaIvaContoProprio());
		  }
		  if(!StringUtils.isStringEmpty(annoCampagnaSel.getDenominazioneContoProprio()))
		  {
	   		SolmrLogger.debug(this,"NELLA VIEW annoCampagnaSel.getDenominazioneContoProprio() VALE: "+annoCampagnaSel.getDenominazioneContoProprio());
		  	htmpl.set("denominazioneFiltroStr",annoCampagnaSel.getDenominazioneContoProprio());
		  }
	  }
	  // se ci sono stati degli errori nella validazione -> prendo i valori inseriti dall'utente
	  else{
	    if(elencoLavContoTerzi!=null && elencoLavContoTerzi.size()>0){
	      String annoRiferimento = (String)request.getAttribute("annoRiferimento");
	      htmpl.set("blkSiLavorazioni.campagna",annoRiferimento);
	    }
	    
	    String cuaa = (String)request.getAttribute("cuaa");
	    if(cuaa != null)
	      htmpl.set("cuaaFiltroStr",cuaa);
	      
	    String partitaIva = (String)request.getAttribute("partitaIva");   
	    if(partitaIva != null)
	      htmpl.set("partitaIvaFiltroStr", partitaIva);
	     
	    String denominazione = (String)request.getAttribute("denominazione");
	    htmpl.set("denominazioneFiltroStr",denominazione);
	  }
  }
  Vector vettAnniCampagna =(Vector)session.getAttribute("LavCTvettAnniCampagna");
  SolmrLogger.debug(this,"NELLA VIEW vettAnniCampagna vale: "+vettAnniCampagna);
  Vector vett= new Vector();
  if(vettAnniCampagna!=null && vettAnniCampagna.size()>0)
  {
  	vett=vettAnniCampagna;
  }
  SolmrLogger.debug(this,"NELLA VIEW vettCampagna da stampare vett.size() vale: "+vett.size());
  	  	
  for(int i=0;i<vett.size();i++){
  	AnnoCampagnaVO elemAnno = (AnnoCampagnaVO)vett.get(i);
  	htmpl.newBlock("blkComboAnno");
  	//htmpl.set("blkComboAnno.idAnnoRiferimento",""+elemAnno.getId_campagnaContoTerzisti());
  		
 	htmpl.set("blkComboAnno.idAnnoRiferimento",""+elemAnno.getAnnoCampagna());
 	htmpl.set("blkComboAnno.annoRiferimentoDesc",""+elemAnno.getAnnoCampagna());
 	String annoCampagnaDaSelezionare = "";
 	ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
 		
 	/* Attenzione : errors è valorizzato anche quando si arriva da inserisci, modifica ed elimina, con il messaggio visualizzato nell'alert (Es : inserimento effettuato con successo)
 		                Bisogna quindi controllare qual'è la paginaChiamante, se l'attributo in sessione è valorizzato, prendere l'anno settato in sessione, per l'anno da selezionare nella combo
 	*/
 	if(errors == null || errors.size()==0){
 	  if(annoCampagnaSel != null)
 	    annoCampagnaDaSelezionare = annoCampagnaSel.getAnnoCampagna(); 		     
 	}
 	else{
 	  annoCampagnaDaSelezionare = (String)request.getAttribute("annoRiferimento");
 		  
 	  // Se stiamo arrivando dall'annulla di inserisci, modifica, elimina -> ricaricare i valori presenti in sessione (valori impostati in fase di ricerca)
	  String paginaChiamante = (String)session.getAttribute("paginaChiamante");
	  SolmrLogger.debug(this, " -- paginaChiamante ="+paginaChiamante);
	  if(paginaChiamante != null && !paginaChiamante.trim().equals("")){
	    annoCampagnaDaSelezionare = annoCampagnaSel.getAnnoCampagna();
	  }  	      
    }
 	SolmrLogger.debug(this,"-- annoCampagnaDaSelezionare= "+annoCampagnaDaSelezionare); 	
 	if (i==0 ||( annoCampagnaDaSelezionare != null && annoCampagnaDaSelezionare.equalsIgnoreCase(elemAnno.getAnnoCampagna()))){ 	  
      htmpl.set("blkComboAnno.annoRiferimentoSel","selected");
   	}		
  }
  // rimuovo l'eventuale valore in sessione settato dalla pagina chiamante
  session.removeAttribute("paginaChiamante");	
						
  
  out.print(htmpl.text());
%>
<%!

  private boolean verificaCondizioniPulsanteImportaLav(HttpServletRequest request,UmaFacadeClient umaClient)
    throws SolmrException
  {
		boolean visualizza=true;
		try
		{
		
			SolmrLogger.debug(this," verificaCondizioniPulsanteImportaLav BEGIN...");
			RuoloUtenza ruoloUtenza = (RuoloUtenza) request.getSession().getAttribute("ruoloUtenza");
			if(ruoloUtenza!=null)
			{
				SolmrLogger.debug(this,"profile.getRuoloUtenza().isUtenteIntermediario() vale: "+ruoloUtenza.isUtenteIntermediario());			
				SolmrLogger.debug(this,"profile.getRuoloUtenza().isUtenteProvinciale() vale: "+ruoloUtenza.isUtenteProvinciale());							
				if(!ruoloUtenza.isUtenteIntermediario() && !ruoloUtenza.isUtenteProvinciale() && !ruoloUtenza.isUtenteRegionale())
				{
					visualizza=false;
				}
				else
				{
					AnnoCampagnaVO annoCampagna =(AnnoCampagnaVO)request.getSession().getAttribute("annoCampagna");
					if(annoCampagna!=null )
						SolmrLogger.debug(this,"annoCampagna.getAnnoCampagna() vale: "+annoCampagna.getAnnoCampagna());
					if(null!=annoCampagna && !StringUtils.isStringEmpty(annoCampagna.getAnnoCampagna()))
					{
						String annoOggi = String.valueOf(UmaDateUtils.getCurrentYear().intValue());
						String annoOggiMenoUno = String.valueOf((UmaDateUtils.getCurrentYear().intValue()-1));
						SolmrLogger.debug(this,"annoCampagna.getAnnoCampagna() VALE: "+annoCampagna.getAnnoCampagna());
						if(!(annoCampagna.getAnnoCampagna().equalsIgnoreCase(annoOggi) 
							|| annoCampagna.getAnnoCampagna().equalsIgnoreCase(annoOggiMenoUno)))
						{
								visualizza=false;
						}
						else
						{
							DittaUMAAziendaVO dittaUma = (DittaUMAAziendaVO)request.getSession().getAttribute("dittaUMAAziendaVO");		
							Vector vett=umaClient.findDomAssByIdDittaUmaAnnoRif(dittaUma.getIdDittaUMA(), annoCampagna.getAnnoCampagna());
							SolmrLogger.debug(this,"vett di findDomAssByIdDittaUmaAnnoRif vale: "+vett);
							if(vett!=null )
								SolmrLogger.debug(this,"vett.size() di findDomAssByIdDittaUmaAnnoRif   vale: "+vett.size());
							if(vett==null || vett.size()>0)
							{
								visualizza=false;							
							}	
						}		
					}
				}
			}
		}catch(SolmrException e)
		{
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
