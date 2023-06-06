<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>



<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.jsf.htmpl.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.anag.*" %>
<%@ page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@ page import="it.csi.solmr.dto.uma.form.AggiornaContoTerziFormVO"%>
<%@ page import="it.csi.solmr.exception.services.MaxRecordException"%>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%

  SolmrLogger.debug(this,"    BEGIN sceltaAziendaView");

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();   
  GaaservFacadeClient gaaservFacadeClient=new GaaservFacadeClient();
  java.io.InputStream layout = application.getResourceAsStream("ditta/layout/selezioneAziendaPOP.htm");
  Htmpl htmpl = new Htmpl(layout);

  try {  
	DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
	HashMap aziendeAtecoMap=new HashMap();
		
	String cuaaStr = request.getParameter("cuaa");
  	String partitaIvaStr = request.getParameter("partitaIva");
  	String denominazioneStr = request.getParameter("denominazione");
  	String annoCampagna = request.getParameter("annoCampagna");
  	
  	String paginaChiamante = request.getParameter("paginaChiam");
  	SolmrLogger.debug(this,"-- paginaChiamante ="+paginaChiamante);
  	htmpl.set("paginaChiamante", paginaChiamante);
  
  	SolmrLogger.debug(this,"-- cuaaStr ="+cuaaStr);
  	SolmrLogger.debug(this,"-- partitaIvaStr ="+partitaIvaStr);
  	SolmrLogger.debug(this,"-- denominazioneStr ="+denominazioneStr);
  	SolmrLogger.debug(this,"-- annoCampagna ="+annoCampagna);
	 		
	AggiornaContoTerziFormVO form =(AggiornaContoTerziFormVO)session.getAttribute("formInserimentoCT"); 	
  	AnagAziendaVO anagAziendaVO=new AnagAziendaVO();
	if(!StringUtils.isStringEmpty(cuaaStr)){
		anagAziendaVO.setCUAA(cuaaStr);
		if(form!=null)
			form.setCuaa(cuaaStr);
	}	
	if(!StringUtils.isStringEmpty(partitaIvaStr)){
		anagAziendaVO.setPartitaIVA(partitaIvaStr);
		if(form!=null)
			form.setPartitaIva(partitaIvaStr);
	}	
	if(!StringUtils.isStringEmpty(denominazioneStr)){
		anagAziendaVO.setDenominazione(denominazioneStr);
		if(form!=null)
			form.setDenominazione(denominazioneStr);
	}		
  

	Vector elencoIdAziende=null;
	try{
	  SolmrLogger.debug(this, "--- chiamata a serviceGetListIdAziende()");
      elencoIdAziende = umaFacadeClient.serviceGetListIdAziende(anagAziendaVO,new Boolean(false),new Boolean(false));
    } 
    catch(Exception se) {	
	  SolmrLogger.error(this," ---- Exception DOPO LA CHIAMATA DI serviceGetListIdAziende ="+se.getMessage());             
      htmpl.newBlock("blkNoAziende");
      htmpl.newBlock("blkErrore");
      htmpl.set("blkErrore.messaggio",se.getMessage());
      htmpl.set("chiudi.pathToFollow", (String)session.getAttribute("pathToFollow"));
  }  
  
  try
  {
    if (elencoIdAziende!=null && !elencoIdAziende.isEmpty())
    {
      long idAziende[]=new long[elencoIdAziende.size()];
      for(int i=0;i<idAziende.length;i++)
      {
        idAziende[i]=(Long)elencoIdAziende.get(i);
      }
    
      SolmrLogger.debug(this, "--- chiamata a gaaservGetListCodAtecoByIdAziendaRange()");
      it.csi.solmr.ws.gaaserv.AziendaAtecoVO[] aziendaAteco = gaaservFacadeClient.gaaservGetListCodAtecoByIdAziendaRange(idAziende, null);
      
      if (aziendaAteco!=null)
	      for(int i=0;i<aziendaAteco.length;i++)
	      {
	        if (aziendaAteco[i]!=null)
  	        aziendeAtecoMap.put(aziendaAteco[i].getIdAzienda(), aziendaAteco[i]);
	      }
      
     }
   } 
   catch(Exception se) 
   { 
     SolmrLogger.error(this," ---- Exception DOPO LA CHIAMATA DI gaaservGetListCodAtecoByIdAziendaRange ="+se.getMessage());             
     htmpl.newBlock("blkNoAziende");
     htmpl.newBlock("blkErrore");
     htmpl.set("blkErrore.messaggio",se.getMessage());
     htmpl.set("chiudi.pathToFollow", (String)session.getAttribute("pathToFollow"));
  }  
  
  AnagAziendaVO[] elencoAziende=null;	
  int contAziendeDaVisualizzare = 0;	
  
  // --- Se serviceGetListIdAziende ha tornato output
  if(elencoIdAziende!=null && elencoIdAziende.size()>0){
    SolmrLogger.debug(this,"--- serviceGetListIdAziende ha restituito valori");
    SolmrLogger.debug(this,"-- chiamata a serviceGetListAziendeByIdRange"); 			
	elencoAziende=umaFacadeClient.serviceGetListAziendeByIdRange(elencoIdAziende);
	
	//htmpl.newBlock("blkSiAziende"); // Selezionare un'azienda tra quelle elencate
	//htmpl.newBlock("blkDati"); // blocco con tabella	
	if(elencoAziende != null && elencoAziende.length>0){			      
	  // ciclo sulle aziende trovate da anagrafe
	  for(int i=0;i<elencoAziende.length;i++){
	    DittaUMAVO datiDitta = null;
	    DittaUMAVO dittaUma=null;
	    boolean aziendaDaVisualizzare = false;
	    
	    AnagAziendaVO elem= (AnagAziendaVO)elencoAziende[i];						
        
        /* Se è stato trovata l'azienda di Anagrafe: cerco i dati sul db di uma
		    - se la ditta ha l'anno della data di cessazione > dell'anno campagna per il quale sto inserendo : NON visualizzo la ditta
		    - altrimenti la visualizzo
		   Altrimenti : non cerco i dati sul db di uma e visualizzo solo i dati di Anagrafe
		*/
		
		// Controllo se l'azienda di Anagrafe è presente sul db di uma (senza controllare date)
		SolmrLogger.debug(this, "-- Controllo se l'azienda di Anagrafe è presente sul db di uma (senza controllare le date)");
		SolmrLogger.debug(this, " ---- ext_id_azienda da cercare sul db di uma ="+elem.getIdAzienda());
		boolean isDittaUmaPresente = umaFacadeClient.isDittaUmaPresente(elem.getIdAzienda());
		SolmrLogger.debug(this, "-- isDittaUmaPresente ="+isDittaUmaPresente);
		
		// -- se l'azienda è presente sul db Uma -> controllo se la data_cessazione della ditta uma è valida
		if(isDittaUmaPresente){	
		  SolmrLogger.debug(this, "-- l'azienda è presente sul db Uma -> controllo se la data_cessazione della ditta uma è valida"); 		
		  Long annoCampagnaL = null;
		  if(annoCampagna != null)
		  annoCampagnaL = new Long(annoCampagna);
		  SolmrLogger.debug(this, "--- controllo se l'azienda censita sul db di uma ha la data_cessazione valida");
  		  dittaUma = umaFacadeClient.getDittaUmaByIdAziendaDataCess(elem.getIdAzienda(), annoCampagnaL);
  		  if(dittaUma != null){
  		    SolmrLogger.debug(this, "-- l'azienda è presente sul db Uma e la data_cessazione è valida -> visualizzarla");  		    
  		    aziendaDaVisualizzare = true;
  		    SolmrLogger.debug(this, "-- Ricerco i dati della ditta con data_fine_validita null");
  		    datiDitta = umaFacadeClient.findDatiDittaConDataFineValNull(dittaUma.getIdDitta());				
  		  }
  		  else{
  		    SolmrLogger.debug(this, "-- l'azienda è presente sul db Uma e la data_cessazione NON è valida -> NON visualizzarla");
  		  }
		}
		else{
		  aziendaDaVisualizzare = true;
		  SolmrLogger.debug(this, "-- l'azienda NON è presente sul db di Uma -> visualizzarla comunque");
		}
		SolmrLogger.debug(this, "-- aziendaDaVisualizzare ="+aziendaDaVisualizzare);
		if(aziendaDaVisualizzare){
		    contAziendeDaVisualizzare = contAziendeDaVisualizzare+1;
		    // creazione blocchi per una sola volta
		    if(contAziendeDaVisualizzare == 1){
		      htmpl.newBlock("blkSiAziende");
		      htmpl.newBlock("blkDati");		    
		    }
		  
		    htmpl.newBlock("blkRiga");
						
			htmpl.set("blkDati.blkRiga.sedelegaleIndirizzo",StringUtils.checkNull(elem.getSedelegIndirizzo()));					
			htmpl.set("blkDati.blkRiga.idAzienda",StringUtils.checkNull(elem.getIdAzienda()));
			SolmrLogger.debug(this, "--- idAzienda ="+elem.getIdAzienda());
					
			htmpl.set("blkDati.blkRiga.numRegImprese",StringUtils.checkNull(elem.getCCIAAnumRegImprese()));
			boolean chiamaAtecoSecondari=false;
			if(elem.getTipoAttivitaATECO() != null){
		      SolmrLogger.debug(this, "-- idAttivitaAteco ="+elem.getTipoAttivitaATECO().getCode());
		      
		    if (!"S".equals(elem.getTipoAttivitaATECO().getCodeFlag()))  
		      chiamaAtecoSecondari=true;
		    else
		    {  
				  htmpl.set("blkDati.blkRiga.flagAttivitaAgricola", StringUtils.checkNull(elem.getTipoAttivitaATECO().getCodeFlag()));
				  SolmrLogger.debug(this, "-- flagAttivitaAgricola ="+elem.getTipoAttivitaATECO().getCodeFlag());
			  }
			}   
			else chiamaAtecoSecondari=true;
			
			if (chiamaAtecoSecondari)
			{
			  if (aziendeAtecoMap!=null)
			  {
			    //controllo se uno dei suoi codici ateco secondari sia considerato agricolo
			    it.csi.solmr.ws.gaaserv.AziendaAtecoVO aziendaAteco=(it.csi.solmr.ws.gaaserv.AziendaAtecoVO)aziendeAtecoMap.get(elem.getIdAzienda());
			    if (aziendaAteco!=null && aziendaAteco.getAttivitaAtecoVO()!=null && aziendaAteco.getAttivitaAtecoVO().size()>0)
			      for(it.csi.solmr.ws.gaaserv.AttivitaAtecoVO attivita:aziendaAteco.getAttivitaAtecoVO())
			      {
			        if (aziendaAteco!=null && "S".equals(attivita.getFlagAttivitaAgricola()))
			        {
			           htmpl.set("blkDati.blkRiga.flagAttivitaAgricola", "S");
			           break;
			        }
			      }
			  }
			}
							
			htmpl.set("blkDati.blkRiga.cuaa",StringUtils.checkNull(elem.getCUAA()));
			htmpl.set("blkDati.blkRiga.partitaIva",StringUtils.checkNull(elem.getPartitaIVA()));
			htmpl.set("blkDati.blkRiga.denominazione",StringUtils.checkNull(elem.getDenominazione()));
			htmpl.set("blkDati.blkRiga.formaGiuridica",StringUtils.checkNull(elem.getTipoFormaGiuridica().getDescription()));
			htmpl.set("blkDati.blkRiga.provinciaREA",StringUtils.checkNull(elem.getCCIAAprovREA()));
			htmpl.set("blkDati.blkRiga.numeroREA",StringUtils.checkNull(elem.getCCIAAnumeroREA()));
			htmpl.set("blkDati.blkRiga.annoIscrizioneRegistroImprese",StringUtils.checkNull(elem.getCCIAAannoIscrizione()));
			htmpl.set("blkDati.blkRiga.numeroRegistroImprese",StringUtils.checkNull(elem.getCCIAAnumRegImprese()));
			htmpl.set("sedelegaleIndirizzo",StringUtils.checkNull(elem.getSedelegIndirizzo()));
			htmpl.set("comune",StringUtils.checkNull(elem.getDescComune()));
			htmpl.set("siglaProvincia",StringUtils.checkNull(elem.getSedelegProv()));
			htmpl.set("cuaa",StringUtils.checkNull(elem.getCUAA()));
			htmpl.set("denominazione",StringUtils.checkNull(elem.getDenominazione()));
			htmpl.set("istatComune",StringUtils.checkNull(elem.getSedelegComune()));
			htmpl.set("partitaIva",StringUtils.checkNull(elem.getPartitaIVA()));
					
			String desc=StringUtils.checkNull(elem.getDescComune());
			if(!StringUtils.isStringEmpty(elem.getSedelegProv()))
			 desc=desc+" ("+elem.getSedelegProv()+")";
			htmpl.set("blkDati.blkRiga.sedeLegale",desc);
			htmpl.set("sedeLegale",desc);
			
			// --- Se ho i dati della ditta UMA
			if(dittaUma != null){
			  String numeroDitta= dittaUma.getDittaUMA();			  
			  if(!StringUtils.isStringEmpty(dittaUma.getProvincia()))
			    numeroDitta=numeroDitta+" / "+dittaUma.getProvincia();
			  String dataCess = UmaDateUtils.formatDate(dittaUma.getDataCessazione());  
			  
			  SolmrLogger.debug(this, "--- numeroDitta UMA="+numeroDitta);
			  htmpl.set("blkDati.blkRiga.numeroDittaUma",numeroDitta);
			  SolmrLogger.debug(this, "--- dataCessazione UMA ="+dataCess);
		      htmpl.set("blkDati.blkRiga.dataCessazioneUma",dataCess);	
		      
		      if(datiDitta!=null){
			    String tipoConduzione = datiDitta.getDescTipoConduzione();
				htmpl.set("blkDati.blkRiga.tipologiaAzienda",tipoConduzione);
				SolmrLogger.debug(this," -- tipoConduzione ="+datiDitta.getDescTipoConduzione());
			  }
			}// fine caso : ci sono i dati della ditta UMA 
					    		  
		}// fine CASO : azienda da visualizzare 
	}// END FOR
  }  
 } 
 //-- setto messaggio se non devo visualizzare aziende
 if(contAziendeDaVisualizzare == 0){
    htmpl.newBlock("blkNoAziende");
  }   
}
catch(SolmrException se) {
  SolmrLogger.error(this, "--- SolmrException in sceltaAziendaView ="+se.getMessage());
  htmpl.newBlock("blkNoAziende");
  htmpl.newBlock("blkErrore");
  htmpl.set("blkErrore.messaggio",se.getMessage());
  htmpl.set("chiudi.pathToFollow", (String)session.getAttribute("pathToFollow"));
}


  it.csi.solmr.presentation.security.Autorizzazione aut=
  (it.csi.solmr.presentation.security.Autorizzazione)
  it.csi.solmr.util.IrideFileParser.elencoSecurity.get("AGGIORNA_CONTOTERZI");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  aut.writeBanner(htmpl,ruoloUtenza,request);


%>

<%= htmpl.text()%>

