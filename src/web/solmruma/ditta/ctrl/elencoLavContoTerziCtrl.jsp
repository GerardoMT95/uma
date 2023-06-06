<%@ page language="java" contentType="text/html" isErrorPage="true"%>

<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@page import="it.csi.solmr.dto.profile.RuoloUtenza"%>
<%@page import="javax.servlet.http.HttpSession"%>


<%
	String iridePageName = "elencoLavContoTerziCtrl.jsp";
%>
<%@include file="/include/autorizzazione.inc"%>
<%
	DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  SolmrLogger.debug(this,"[elencoLavContoTerziCtrl::service] ################## idDittaUma "+idDittaUma);
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  UmaFacadeClient umaClient = new UmaFacadeClient();
  String url="/ditta/view/elencoLavContoTerziView.jsp";
  String modificaUrl="/ditta/ctrl/modificaLavContoTerziCtrl.jsp";
  String validateUrl="/ditta/view/elencoLavContoTerziView.jsp";
  String insertUrl="/ditta/ctrl/nuovaLavContoTerziCtrl.jsp";
  String deleteUrl="/ditta/ctrl/confermaEliminaLavContoTerziCtrl.jsp";
  String allegaFatturaUrl = "/ditta/ctrl/allegaFatturaContoTerziCtrl.jsp";
  //String urlDeleteOk="../../ditta/layout/elencoSerre.htm?notifica=delete";

  String info=(String)session.getAttribute("notifica");
  SolmrLogger.debug(this," --- info ="+info);
  
  String umar = umaClient.getParametro(SolmrConstants.PARAMETRO_UMAR);  
  request.setAttribute("PARAMETRO_UMAR", umar);
  
  // Se info è valorizzato, si sta arrivando da altre pagine (inserisci, elimina, modifica)
  if (info!=null)
  {
    AnnoCampagnaVO annoCampagnaVO = (AnnoCampagnaVO)session.getAttribute("annoCampagna");
    findData(request,umaClient,idDittaUma,url,ruoloUtenza,response,annoCampagnaVO, info);
    session.removeAttribute("notifica");
    throwValidation(info,validateUrl);
  }

  SolmrLogger.debug(this,"[elencoLavContoTerziCtrl::service] *************************** idDittaUma "+idDittaUma);
  
  
  AnnoCampagnaVO annoCampagna;
  
  //------ Prendo i nuovi filtri settati dall'utente sulla pagina, SOLO se sto facendo la ricerca dalla pagina di ricerca  
 
  String operation = (String)request.getParameter("operation");
  SolmrLogger.debug(this, "-- operation ="+operation);
  SolmrLogger.debug(this, "-- request.getParameter(inserisci.x) ="+request.getParameter("inserisci.x"));
  if( 
     
     /*(  (operation == null || operation.equals("")) && 
         request.getParameter("inserisci.x") == null &&
          request.getParameter("modifica.x") == null && 
          request.getParameter("elimina.x") == null &&
          request.getParameter("annulla.x") == null  )
        || !operation.equals("paginazione")  )*/
         (operation == null || operation.equals("")) || 
         (operation != null && !operation.equals("paginazione") 
       ) 
    ){
        SolmrLogger.debug(this, "-- setto i filtri nel VO per la ricerca");
		String annoRiferimento = (String) request.getParameter("annoRiferimento");
	    String cuaaFiltroContoProprio = (String) request.getParameter("cuaaFiltroStr");
	    String partitaIvaFiltroContoProprio = (String) request.getParameter("partitaIvaFiltroStr");
	    String denominazioneFiltroContoProprio = (String) request.getParameter("denominazioneFiltroStr");
	    
	    annoCampagna = new AnnoCampagnaVO();		
	  	annoCampagna.setAnnoCampagna(annoRiferimento);
	  	annoCampagna.setCuaaContoProprio(cuaaFiltroContoProprio);				
	  	annoCampagna.setPartitaIvaContoProprio(partitaIvaFiltroContoProprio);	
	  	annoCampagna.setDenominazioneContoProprio(denominazioneFiltroContoProprio);
		//session.setAttribute("annoCampagna",annoCampagna);
	}
	else{
	  SolmrLogger.debug(this, "-- prendo i filtri settati in sessione per la ricerca");
	  annoCampagna = (AnnoCampagnaVO)session.getAttribute("annoCampagna");
	}
	
	// Se stiamo arrivando da inserisci, modifica, elimina -> ricaricare i valori presenti in sessione (valori impostati in fase di ricerca)
	String paginaChiamante = (String)session.getAttribute("paginaChiamante");
	SolmrLogger.debug(this, " -- paginaChiamante ="+paginaChiamante);
	if(paginaChiamante != null && !paginaChiamante.trim().equals("")){
      SolmrLogger.debug(this, "-- prendo i filtri settati in sessione per la ricerca");
	  annoCampagna = (AnnoCampagnaVO)session.getAttribute("annoCampagna");	    
    }    
	
		
  SolmrLogger.debug(this, "-- request.getParameter(inserisci.x) ="+request.getParameter("inserisci.x"));
  if (request.getParameter("inserisci.x")!=null)
  {
    session.setAttribute("annoCampagna",annoCampagna);
  	try
  	{	
	if(annoCampagna.getAnnoCampagna()!=null  && new Long(annoCampagna.getAnnoCampagna()).longValue()!=DateUtils.getCurrentYear().longValue())
	{	  		
		request.setAttribute("flagPulisciSessione","true");
%>
<jsp:forward page="<%=insertUrl%>" />
<%
	return;
	  		//}
	}
	else
	{
	  request.setAttribute("flagPulisciSessione","true");
%>
<jsp:forward page="<%=insertUrl%>" />
<%
	return;
	}

		}
		catch(Exception e)
	  {
      request.setAttribute("errorMessage",e.getMessage());
      SolmrLogger.error(this,"ERRORE... "+e.getMessage());
      //System.err.println("e.getMessage(): "+e.getMessage());
      //e.printStackTrace();
%>
<jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
<%
	return;
		}
  }
  else
  {
  	if(request.getParameter("storico.x")!=null)
  	{
  		//String annoRiferimento = request.getParameter("annoRiferimento");
  		SolmrLogger.debug(this,"CASO STORICO ");
	SolmrLogger.debug(this,"sono in elencoLavContoTerziCtrl CASO STORICO e annoCampagna  annoRiferimento VALE: "+annoCampagna.getAnnoCampagna());
	/*if(!StringUtils.isStringEmpty(annoRiferimento)){
		  		AnnoCampagnaVO annoCampagna = new AnnoCampagnaVO();
		  		annoCampagna.setAnnoCampagna(annoRiferimento);
		  		session.setAttribute("annoCampagna",annoCampagna);
	}*/
  		 
  		String urlStorico="/ditta/ctrl/elencoLavContoTerziBisCtrl.jsp";
%>
<jsp:forward page="<%=urlStorico%>" />
<%
	return;  		
  	}
  	if(request.getParameter("importa.x")!=null)
  	{
  		//String annoRiferimento = request.getParameter("annoRiferimento");
  		SolmrLogger.debug(this,"CASO IMPORTAAAAAA ");
		String urlConferma="/ditta/ctrl/confermaImportaLavContoTerziCtrl.jsp";
%>
<jsp:forward page="<%=urlConferma%>" />
<%
	return;  		
  	}
    else if(request.getParameter("ricarica.x")!=null)
    {
  		try
  		{
		SolmrLogger.debug(this,"Sono in RICARICAAAAA ");
	  //String annoRiferimento = request.getParameter("annoRiferimento");
	  SolmrLogger.debug(this,"annoRiferimento VALE: "+annoCampagna.getAnnoCampagna());
	  	/*if(!StringUtils.isStringEmpty(annoRiferimento)){
	  		AnnoCampagnaVO annoCampagna = new AnnoCampagnaVO();
	  		annoCampagna.setAnnoCampagna(annoRiferimento);
	  		session.setAttribute("annoCampagna",annoCampagna);
	  	}*/
	  	//SolmrLogger.debug(this,"VERIFICO LE CONDIZIONI X VIS IL PULSANTE IMPORTA LAVORAZIONI...   ");
		  	    //verificaCondizioniPulsanteImportaLav(request,umaClient);
		  	    
	  DittaUMAAziendaVO dittaUma = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
	  SolmrLogger.debug(this,"dittaUma VALE: "+dittaUma);
		/*if (null!= dittaUma && dittaUma.getIdConduzione()!=null){
		            SolmrLogger.debug(this,"[elencoLavContoTerziCtrl::ricarica] dittaUma.getIdDittaUMA() VALE: "+dittaUma.getIdDittaUMA());	
		            SolmrLogger.debug(this,"[elencoLavContoTerziCtrl::ricarica] IDCONDUZIONE VALE: "+dittaUma.getIdConduzione());	
		          	if(!(dittaUma.getIdConduzione().equalsIgnoreCase("2") || dittaUma.getIdConduzione().equalsIgnoreCase("3"))){
	
	            throw new Exception("La ditta effettua solo attivita' per conto proprio, operazione non permessa");
	
	        }else{*/
  	    SolmrLogger.debug(this,"Sono in RICARICAAAAA PRIMA di getVettLavorazioni");
  	    
  	   // ------ Se sono stati indicati : cuaa o partita iva o denominazione :     
       String cuaa = annoCampagna.getCuaaContoProprio();
       String partitaIva = annoCampagna.getPartitaIvaContoProprio();   
       String denominazione = annoCampagna.getDenominazioneContoProprio(); 
       String annoRiferimento = annoCampagna.getAnnoCampagna();
  	   Vector<Long> listIdAzienda = null;
       
       SolmrLogger.debug(this,"-- cuaa ="+cuaa);
       SolmrLogger.debug(this,"-- partita iva ="+partitaIva);
       SolmrLogger.debug(this,"-- denominazione ="+denominazione);
       
       if(!StringUtils.isStringEmpty(cuaa) || !StringUtils.isStringEmpty(partitaIva) || !StringUtils.isStringEmpty(denominazione)){
         // Validazione campi
         ValidationErrors errors = annoCampagna.validate();

         if (! (errors == null || errors.size() == 0)) {
           SolmrLogger.debug(this, "----- ci sono errori di validazione sui filtri di ricerca");
           request.setAttribute("errors", errors);
           request.setAttribute("cuaa", cuaa);
           request.setAttribute("partitaIva", partitaIva);
           request.setAttribute("denominazione", denominazione);          
           request.setAttribute("annoRiferimento", annoRiferimento);
           
           request.getRequestDispatcher(validateUrl).forward(request, response);
           return;
         }
         
                 
         SolmrLogger.debug(this,"-- effettuare la chiamata ad anagrafe -- serviceGetListIdAziende()");
         AnagAziendaVO anagAziendaVO= new AnagAziendaVO();
         if(!StringUtils.isStringEmpty(cuaa))
           anagAziendaVO.setCUAA(cuaa.trim());
         if(!StringUtils.isStringEmpty(partitaIva))  
           anagAziendaVO.setPartitaIVA(partitaIva.trim());
         if(!StringUtils.isStringEmpty(denominazione))  
           anagAziendaVO.setDenominazione(denominazione.trim());  
         listIdAzienda = umaClient.serviceGetListIdAziende(anagAziendaVO,false,false);
       } 
  	    
  	    SolmrLogger.debug(this, "-- sono stati superati tutti i controlli di validazione, metto in sessione l'oggetto con i filtri per la ricerca");
  	    session.setAttribute("annoCampagna",annoCampagna);
  	    
  	      Long extIdAziendaCorrente = null;
  		  VectorUtils.getVettLavorazioni(request, umaClient,dittaUma.getIdDittaUMA(),extIdAziendaCorrente,
  		  annoCampagna.getAnnoCampagna(), annoCampagna.getCuaaContoProprio(),
	  annoCampagna.getPartitaIvaContoProprio(), annoCampagna.getDenominazioneContoProprio(), listIdAzienda,
  		  ruoloUtenza, false, new Integer(0));
  		  SolmrLogger.debug(this,"Sono in RICARICAAAAA DOPO di getVettLavorazioni");
  		  SolmrLogger.debug(this,"Sono in RICARICAAAAA DOPO di getVettLavorazioni url VALE: "+url);
  		  // Visualizzazione Lav conto terzi
        //findData(request,umaClient,idDittaUma,url);
        request.removeAttribute("ricarica.x");
%>
<jsp:forward page="<%=url%>" />
<%
	SolmrLogger.debug(this,"QUIIIIIII");
		return;
	   			/*}
	   }
	   else if(dittaUma.getIdConduzione()==null)
	   			throw new Exception("La ditta effettua solo attivita' per conto proprio, operazione non permessa");*/
		  }
		  catch(Exception e)
	    {
	      request.setAttribute("errorMessage",e.getMessage());
	      SolmrLogger.debug(this,"ERRORE... "+e.getMessage());
	      //e.printStackTrace();
%>
<jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
<%
	return;
	    }
      //<jsp:forward page="=modificaUrl>" />
	  }
  	else if (request.getParameter("modifica.x")!=null)
    {
      try
      {
      	String[] checkBoxSel = request.getParameterValues("checkbox");
      	Long[] vIdLav = new Long[checkBoxSel.length];
      	HashMap<Long, Boolean> mappaAbilitazioniScavalco = new HashMap<Long, Boolean>();
      	
      	for(int i = 0;i < checkBoxSel.length;i++)
      	{
      		vIdLav[i] = new Long(checkBoxSel[i]);
      	}
      	SolmrLogger.debug(this, " ----------- Ricerca delle lavorazioni da visualizzare nella pagina di modifica");
      	
      	Vector vLavContoTerzi=umaClient.findLavorazioneContoTerziByIdRange(vIdLav);
      	for(int i = 0; i < vLavContoTerzi.size();i++)
      	{
      		LavContoTerziVO lavContoTerziVO = (LavContoTerziVO)vLavContoTerzi.get(i);
	        if (lavContoTerziVO.getDataFineValidita()!=null || lavContoTerziVO.getDataCessazione() != null)
	        {
	          throw new Exception("Una delle lavorazioni non è modificabile perchè si riferisce ad un dato storicizzato");
	        }
      	}

      	SolmrLogger.debug(this, " ----------- Per ciascuna lavorazione da visualizzare viene controllata la possibilita' di scavalco");
      	mappaAbilitazioniScavalco = umaClient.getMappaScavalcoPossibileLavorazioni(vIdLav);
      	
      	session.setAttribute("vLavMapScavalco", mappaAbilitazioniScavalco);
        session.setAttribute("vLavContoTerzi", vLavContoTerzi);
      }
      catch(Exception e)
      {
      	e.printStackTrace();
        request.setAttribute("errorMessage",e.getMessage());
%>
<jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
<%
	return;
      }
%>
<jsp:forward page="<%=modificaUrl%>" />
<%
	}
    else
    {
      if (request.getParameter("elimina.x")!=null)
      {
        try
        {
	      	String[] checkBoxSel = request.getParameterValues("checkbox");
	      	Long[] vIdLav = new Long[checkBoxSel.length];
	      	for(int i = 0;i < checkBoxSel.length;i++)
	      	{
	      		vIdLav[i] = new Long(checkBoxSel[i]);
	      	}
	      	Vector vLavContoTerzi=umaClient.findLavorazioneContoTerziByIdRange(vIdLav);
	      	for(int i = 0; i < vLavContoTerzi.size();i++)
	      	{
	      		LavContoTerziVO lavContoTerziVO = (LavContoTerziVO)vLavContoTerzi.get(i);
		        if (lavContoTerziVO.getDataFineValidita()!=null 
		          || lavContoTerziVO.getDataCessazione() != null)
		        {
		          throw new Exception("Una delle lavorazioni non è modificabile perchè si riferisce ad un dato storicizzato");
		        }
	      	}
	        session.setAttribute("vLavContoTerzi",vIdLav);

		    }
        catch(Exception e)
        {
          request.setAttribute("errorMessage",e.getMessage());
%>
<jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
<%
	return;
        }
%>
<jsp:forward page="<%=deleteUrl%>" />
<%
	}
      else if (request.getParameter("allegaFattura.x")!=null)
      {
    	SolmrLogger.debug(this, "-- CASO allegaFattura");	
        try{        	        	
        	SolmrLogger.debug(this, " ----------- Ricerca delle fattura dell'anno precedente");
        	int prevYear = getPreviousYear();
        	SolmrLogger.debug(this, "-- prevYear ="+prevYear);
        	request.setAttribute("annoCampagna", new Integer(prevYear).toString());
        	
        	List<FatturaContoTerziVO> fatturaContoTerziList =umaClient.findFattureContoTerziByAnnoIdDittaUma(new Integer(prevYear).longValue(), dittaUMAAziendaVO.getIdDittaUMA());
        	request.setAttribute("vElencoFatturaContoTerziVO", fatturaContoTerziList); 
        	session.setAttribute("vElencoFatturaContoTerziVO", fatturaContoTerziList);
        	
        }
        catch(Exception e){
          SolmrLogger.error(this, "-- Exception ="+e.getMessage());
          request.setAttribute("errorMessage",e.getMessage());
  			%>
  				<jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
  			<%
  		  return;
        }
  %>
  <jsp:forward page="<%=allegaFatturaUrl%>" />
  <%
  	}
      else 
      {
        // inizio cris
	      try
	      {
	       	//SolmrLogger.debug(this,"Sono in CARICA DATII");
	     	 	//SolmrLogger.debug(this,"[elencoLavContoTerziCtrl::service] CONTROLLO IDCONDIZIONE");	
	
	       	//if (null!= dittaUMAAziendaVO && dittaUMAAziendaVO.getIdConduzione()!=null)
	       	//{
		       	//SolmrLogger.debug(this,"[elencoLavContoTerziCtrl::service] dittaUma.getIdDittaUMA() VALE: "+dittaUMAAziendaVO.getIdDittaUMA());	
		        //SolmrLogger.debug(this,"[elencoLavContoTerziCtrl::service] IDCONDUZIONE VALE: "+dittaUMAAziendaVO.getIdConduzione());	
		          	/*if(!(dittaUMAAziendaVO.getIdConduzione().equalsIgnoreCase("2") || dittaUMAAziendaVO.getIdConduzione().equalsIgnoreCase("3"))){
	            		throw new Exception("La ditta effettua solo attivita' per conto proprio, operazione non permessa");
	
	        }else{*/
		  		// CARICO DATI				    
		  	findData(request,umaClient,idDittaUma,url, ruoloUtenza,response,annoCampagna,info);
			    //SolmrLogger.debug(this,"vettLavorazioni vale: "+vettLavorazioni);
		  	//}  
	  			//}
      		//SolmrLogger.debug(this,"VERIFICO LE CONDIZIONI X VIS IL PULSANTE IMPORTA LAVORAZIONI...   ");
  	        //verificaCondizioniPulsanteImportaLav(request,umaClient);
      	}
	      catch(Exception e)
	      {
	        request.setAttribute("errorMessage",e.getMessage());
%>
<jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
<%
	return;
	      }
	      // Visualizzazione Lav conto terzi
	      //findData(request,umaClient,idDittaUma,url, ruoloUtenza);
%>
<jsp:forward page="<%=url%>" />
<%
	}// end cris
      
    }
  }// end
%>

<%!private void findData(HttpServletRequest request,UmaFacadeClient umaClient,Long idDittaUma,String validateUrl, RuoloUtenza ruoloUtenza, HttpServletResponse response, AnnoCampagnaVO annoCampagna, String info)
      throws ValidationException
  {
     SolmrLogger.debug(this, "    BEGIN findData");
	  try
    {
		  SolmrLogger.debug(this,"[elencoLavContoTerziCtrl::service::::begin] \n\n\n\n\n\n\n\n\nidDittaUma="+idDittaUma+" \n\n\n\n\n\n\n\n\n....");
		  HttpSession session = request.getSession();
     	  
	 	  SolmrLogger.debug(this, " ---- Ricerca degli anni da visualizzare nella COMBO Anno rifirimento");
	 	  Vector<AnnoCampagnaVO> vettAnniCampagna= umaClient.findAnniCampLavPerCt(idDittaUma);
	 	  SolmrLogger.debug(this, " -- ordinamento degli anni");
		  Collections.sort(vettAnniCampagna);
		  SolmrLogger.debug(this," ---- numero di anni da visualizzare nella combo ="+vettAnniCampagna.size());
		  session.setAttribute("LavCTvettAnniCampagna",vettAnniCampagna);
	  	
	     
	   	
	   	if(annoCampagna != null && annoCampagna.getAnnoCampagna()!=null){
	   		SolmrLogger.debug(this,"ANNOCAMPAGNA IN SESSION VALE: "+annoCampagna.getAnnoCampagna());
	   		
	   		// --- Setto anche gli altri filtri, se sono stati valorizzati e se sono nel caso di NON paginazione
	   		String operation = (String)request.getParameter("operation");
	   		
	   		// Se stiamo arrivando da inserisci, modifica, elimina -> ricaricare i valori presenti in sessione (valori impostati in fase di ricerca)
	        String paginaChiamante = (String)session.getAttribute("paginaChiamante");
	        SolmrLogger.debug(this, " -- paginaChiamante ="+paginaChiamante);
	   		if(paginaChiamante == null || paginaChiamante.trim().equals("")){
	   		  if( 
			     (
			       (operation == null || operation.equals("")) && 
			         request.getParameter("inserisci.x") == null &&
			          request.getParameter("modifica.x") == null && 
			          request.getParameter("elimina.x") == null &&
			          request.getParameter("annulla.x") == null)
			        || !operation.equals("paginazione")  ){
        		SolmrLogger.debug(this, "-- setto i filtri nel VO per la ricerca");
				String annoRiferimento = (String) request.getParameter("annoRiferimento");
	    		String cuaaFiltroContoProprio = (String) request.getParameter("cuaaFiltroStr");
	    		String partitaIvaFiltroContoProprio = (String) request.getParameter("partitaIvaFiltroStr");
	    		String denominazioneFiltroContoProprio = (String) request.getParameter("denominazioneFiltroStr");
	    		
	    		// se i campi indicati sono corretti
	    		 ValidationErrors errors = validate(cuaaFiltroContoProprio,partitaIvaFiltroContoProprio);
	    		 if ((errors == null || errors.size() == 0)) {	    						
					if(!StringUtils.isStringEmpty(annoRiferimento))
					{
		  			annoCampagna.setAnnoCampagna(annoRiferimento);
					}
					if(!StringUtils.isStringEmpty(cuaaFiltroContoProprio))
					{
				  	annoCampagna.setCuaaContoProprio(cuaaFiltroContoProprio);
					}
					if(!StringUtils.isStringEmpty(partitaIvaFiltroContoProprio))
					{
				  	annoCampagna.setPartitaIvaContoProprio(partitaIvaFiltroContoProprio);
					}
					if(!StringUtils.isStringEmpty(denominazioneFiltroContoProprio))
					{
				  	annoCampagna.setDenominazioneContoProprio(denominazioneFiltroContoProprio);
					}
				}	
	         }
	       } 
	   	}
	   	else
	   	{
	   	  SolmrLogger.debug(this,"ANNOCAMPAGNA IN SESSION E' NULL");
	   		annoCampagna = new AnnoCampagnaVO();
	   		annoCampagna.setAnnoCampagna(String.valueOf(UmaDateUtils.getCurrentYear()));	   		 
	   	}	 
	   	
	   	
	    
	    
	    String startRowStr=request.getParameter("startRow");
		  Integer startRow = null;
		  if(Validator.isNotEmpty(startRowStr))
		  {
		    startRow = new Integer(startRowStr);
		  }


       // ------ Se sono stati indicati : cuaa o partita iva o denominazione :   
       // -- Se info != null  si sta arrivando da altre pagine -> prendere il valore settato in sessione
       String cuaa = "";
       String partitaIva = "";
       String denominazione = "";
       String annoRiferimento = "";
       SolmrLogger.debug(this, "-- info ="+info);     
       String operation = (String)request.getParameter("operation");
       SolmrLogger.debug(this, "-- operation ="+operation); 
       
       // Se stiamo arrivando dall'annulla di inserisci, modifica, elimina -> ricaricare i valori presenti in sessione (valori impostati in fase di ricerca)
	   String paginaChiamante = (String)session.getAttribute("paginaChiamante");
	   SolmrLogger.debug(this, " -- paginaChiamante ="+paginaChiamante);
	   		
              
       if(info  == null && (paginaChiamante == null || paginaChiamante.trim().equals(""))){
		   cuaa = (String) request.getParameter("cuaaFiltroStr");
		   partitaIva = (String) request.getParameter("partitaIvaFiltroStr");
		   denominazione = (String) request.getParameter("denominazioneFiltroStr");
		   annoRiferimento = (String)request.getParameter("annoRiferimento");
	   }
	   // si sta arrivando da inserisci/modifica..., prendere i dati in sessione per rifare la ricerca
	   if(info != null || (paginaChiamante != null && !paginaChiamante.trim().equals(""))){
	     AnnoCampagnaVO annoCampagnaInSessione =(AnnoCampagnaVO)session.getAttribute("annoCampagna");
	     cuaa = annoCampagnaInSessione.getCuaaContoProprio();
	     partitaIva = annoCampagnaInSessione.getPartitaIvaContoProprio();
	     denominazione = annoCampagnaInSessione.getDenominazioneContoProprio();
	     annoRiferimento = annoCampagnaInSessione.getAnnoCampagna();	     
	   }	  
	   // si sta arrivando dalla paginazione, prendere i dati in sessione per rifare la ricerca
	   if(operation != null && operation.equals("paginazione")){
	     AnnoCampagnaVO annoCampagnaInSessione =(AnnoCampagnaVO)session.getAttribute("annoCampagna");
	     cuaa = annoCampagnaInSessione.getCuaaContoProprio();
	     partitaIva = annoCampagnaInSessione.getPartitaIvaContoProprio();
	     denominazione = annoCampagnaInSessione.getDenominazioneContoProprio();
	     annoRiferimento = annoCampagnaInSessione.getAnnoCampagna();	
	   }
	   
 
	   Vector<Long> listIdAzienda = null;
       
       SolmrLogger.debug(this,"-- cuaa ="+cuaa);
       SolmrLogger.debug(this,"-- partita iva ="+partitaIva);
       SolmrLogger.debug(this,"-- denominazione ="+denominazione);
       
       if(!StringUtils.isStringEmpty(cuaa) || !StringUtils.isStringEmpty(partitaIva) || !StringUtils.isStringEmpty(denominazione)){
         // Validazione campi
         ValidationErrors errors = validate(cuaa,partitaIva);

         if (! (errors == null || errors.size() == 0)) {
           SolmrLogger.debug(this, "----- ci sono errori di validazione sui filtri di ricerca");
           request.setAttribute("errors", errors);
           request.setAttribute("cuaa", cuaa);
           request.setAttribute("partitaIva", partitaIva);
           request.setAttribute("denominazione", denominazione);           
           request.setAttribute("annoRiferimento", annoRiferimento);
           request.getRequestDispatcher(validateUrl).forward(request, response);
           return;
         }
         
         SolmrLogger.debug(this,"-- effettuare la chiamata ad anagrafe -- serviceGetListIdAziende()");
         AnagAziendaVO anagAziendaVO= new AnagAziendaVO();
         if(!StringUtils.isStringEmpty(cuaa))
           anagAziendaVO.setCUAA(cuaa.trim());
         if(!StringUtils.isStringEmpty(partitaIva))  
           anagAziendaVO.setPartitaIVA(partitaIva.trim());
         if(!StringUtils.isStringEmpty(denominazione))  
           anagAziendaVO.setDenominazione(denominazione.trim());  
         listIdAzienda = umaClient.serviceGetListIdAziende(anagAziendaVO,false,false);
       } 
       
        session.setAttribute("annoCampagna",annoCampagna);
        Long extIdAziendaCorrente = null;
	  	VectorUtils.getVettLavorazioni(request,umaClient,idDittaUma, extIdAziendaCorrente,
	  			annoCampagna.getAnnoCampagna(), annoCampagna.getCuaaContoProprio(),
					annoCampagna.getPartitaIvaContoProprio(), annoCampagna.getDenominazioneContoProprio(), listIdAzienda,
	  			ruoloUtenza, false, startRow);
	   	SolmrLogger.debug(this,"[elencoLavContoTerziCtrl::findData:::::end]");
    }
    catch(Exception e)
    {
      SolmrLogger.error(this, "-- Exception in findData ="+e.getMessage());
      throwValidation(e.getMessage(),validateUrl);
    }
    finally{
      SolmrLogger.debug(this, "    END findData");
    }
  }

	private ValidationErrors validate(String cuaaContoProprio, String partitaIvaContoProprio) {
		ValidationErrors errors = new ValidationErrors();
		if (Validator.isNotEmpty(cuaaContoProprio)) {
			if (cuaaContoProprio.length() != 11 && cuaaContoProprio.length() != 16) {
				errors.add("cuaaFiltroStr", new ValidationError("CUAA errato"));
			} else if (cuaaContoProprio.length() == 11 && !Validator.isNumericInteger(cuaaContoProprio)) {
				errors.add("cuaaFiltroStr", new ValidationError("CUAA errato"));
			}
		}

		if (Validator.isNotEmpty(partitaIvaContoProprio) && (partitaIvaContoProprio.length() != 11 || !Validator.isNumericInteger(partitaIvaContoProprio))) {
			errors.add("partitaFiltroIvaStr", new ValidationError("Partita IVA errata"));
		}
		return errors;
	}

	private String getRequestSessionValue(HttpServletRequest request, String key) throws ValidationException {
		HttpSession session = request.getSession(true);
		String value = Validator.isNotEmpty(request.getParameter(key)) ? request.getParameter(key) : (String) session.getAttribute(key);
		session.setAttribute(key, value);
		return value;
	}

	private void throwValidation(String msg, String validateUrl) throws ValidationException {
		ValidationException valEx = new ValidationException(msg, validateUrl);
		valEx.addMessage(msg, "exception");
		throw valEx;
	}
	
	private int getPreviousYear() {
      Calendar prevYear = Calendar.getInstance();
      prevYear.add(Calendar.YEAR, -1);
      return prevYear.get(Calendar.YEAR);
    }%>
