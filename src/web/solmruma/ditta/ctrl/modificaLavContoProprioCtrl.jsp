<%@ page language="java" contentType="text/html" isErrorPage="true"%>

<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@page import="java.math.BigDecimal"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
  String iridePageName = "modificaLavContoProprioCtrl.jsp";
%>
  <%@include file="/include/autorizzazione.inc"%>
<%
  SolmrLogger.debug(this, "   BEGIN modificaLavContoProprioCtrl");

  String viewUrl = "/ditta/view/modificaLavContoProprioView.jsp";
  String elencoHtm = "../../ditta/layout/elencoLavContoProprio.htm";  
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
    
  String operation = request.getParameter("operation");
  SolmrLogger.debug(this, "--- operation ="+operation);  
  
  if(operation == null || operation.equals("modifica")){
    SolmrLogger.debug(this, " --- CASO visualizzo le lavorazioni");
    // rimuovo eventuali valori in sessione
    removeValSession(session);
    
    // Recupero gli le lavorazioni conto proprio selezionate in elenco 
    Vector<LavContoProprioVO> elencoLavContoProprioMod = (Vector<LavContoProprioVO>)session.getAttribute("lavContoProprioMod");   
    SolmrLogger.debug(this, " --- numero di lavorazioni da visualizzare = "+elencoLavContoProprioMod.size());
    
    // -------- Per le combo delle macchine <K> = idLavorazioneContoProprio, <value> = elenco macchine
    HashMap<String,Vector<MacchinaVO>> hashMapMacchine = new HashMap<String,Vector<MacchinaVO>>();
    
    // -------- Informazioni per campi hidden
    HashMap<String,CategoriaColturaLavVO> hasMapCategColt = new HashMap<String,CategoriaColturaLavVO>();
    HashMap<String,Vector<TipoLavorazioneVO>> hashMapTipoLavoraz = new HashMap<String,Vector<TipoLavorazioneVO>>();
    HashMap<String,BigDecimal> hashMapMaxSuperficie = new HashMap<String,BigDecimal>();
    HashMap<String,BigDecimal> hashMapSuperficieMontagna = new HashMap<String,BigDecimal>();
    
    
    // --- Valori per il calcolo carburante
    SolmrLogger.debug(this, "--- Recupero i valori per il CALCOLO CARBURANTE");
    // prendo l'anno campagna della prima lavorazione che verrà visualizzata
    String anno = elencoLavContoProprioMod.get(0).getAnnoCampagna();
    String data = null;
    String coefficiente = umaFacadeClient.getValoreParametro(SolmrConstants.PARAMETRO_COEFFICIENTE_CAVALLI_CARBURANTE,anno,data);
    SolmrLogger.debug(this, " --- coefficiente ="+coefficiente);
    session.setAttribute("coefficienteCarburante", coefficiente);
    
    //---- Per ogni lavorazione conto proprio trovata, effettuo altre query
    for(int i=0;i<elencoLavContoProprioMod.size();i++){    
      String idLavorazContoProprio = elencoLavContoProprioMod.get(i).getIdLavorazioneContoProprio();
      SolmrLogger.debug(this, "---- idLavorazContoProprio ="+idLavorazContoProprio);
      String annoRiferimento = elencoLavContoProprioMod.get(i).getAnnoCampagna();
      String idCategoriaUtilizzoUma = elencoLavContoProprioMod.get(i).getUsoDelSuolo();
      String idLavorazioni = elencoLavContoProprioMod.get(i).getLavorazione();      
      
      // Ricerca valori legati a Uso del suolo e Lavorazione (verranno memorizzati nei campi hidden)
      
      CategoriaColturaLavVO categColturaVO = umaFacadeClient.getCategoriaColturaLav(idLavorazioni,idCategoriaUtilizzoUma,SolmrConstants.ID_TIPO_COLTURA_LAVORAZIONE_CONTO_PROPRIO, annoRiferimento);
      hasMapCategColt.put(idLavorazContoProprio, categColturaVO);
      
       // Restituisce 1 solo oggetto perchè stiamo filtrando anche per id_lavorazioni (valori necessari per il calcolo del carburante)
      Vector<TipoLavorazioneVO> tipoLavorazVO = umaFacadeClient.findLavorazioniLavContoProprio(dittaUMAAziendaVO.getIdDittaUMA().toString(), annoRiferimento, idCategoriaUtilizzoUma, idLavorazioni);
      hashMapTipoLavoraz.put(idLavorazContoProprio, tipoLavorazVO);      
                  
      if(categColturaVO != null){
        // ---- CASO Tipo unita misura = 'T'
        if(categColturaVO.getTipoUnitaMisura().equals(SolmrConstants.TIPO_UNITA_MISURA_T)){
          // Ricerca dati per il caricamento della combo 'Macchina'
          Vector<MacchinaVO> elencoMacchine = umaFacadeClient.findMacchineLavContoProprio(dittaUMAAziendaVO.getIdDittaUMA().toString(),annoRiferimento,idCategoriaUtilizzoUma,idLavorazioni);
          hashMapMacchine.put(idLavorazContoProprio, elencoMacchine);
        }
        // ---- CASO Tipo unita misura = 'S'
        else if(categColturaVO.getTipoUnitaMisura().equals(SolmrConstants.TIPO_UNITA_MISURA_S)){
          if(tipoLavorazVO != null && tipoLavorazVO.get(0) != null){      
        	String flagAsservimento = tipoLavorazVO.get(0).getFlagAsservimento();
        	SolmrLogger.debug(this, "--- flagAsservimento ="+flagAsservimento);
        
	    	// Ricerca del valore massimo per la superficie (per controllo max superficie)
	    	String codiceMotivoLavoraz = elencoLavContoProprioMod.get(i).getTipoMotivoLavVO().getCodiceMotivoLavorazione();
	    	SolmrLogger.debug(this, "--- codiceMotivoLavoraz ="+codiceMotivoLavoraz);
	    	BigDecimal maxSuperficie = umaFacadeClient.getSuperficieInsLavCP(dittaUMAAziendaVO.getIdDittaUMA(), dittaUMAAziendaVO.getIdAzienda(), idLavorazioni, idCategoriaUtilizzoUma, annoRiferimento, flagAsservimento, codiceMotivoLavoraz);
	    	SolmrLogger.debug(this, "--- maxSuperficie ="+maxSuperficie);
	    	hashMapMaxSuperficie.put(idLavorazContoProprio,maxSuperficie);		
	       
	    	// Ricerca della superficie in montagna (per calcolo litri acclività)
	    	BigDecimal superficieMontagna = umaFacadeClient.getSuperficieMontagnaCP(dittaUMAAziendaVO.getIdDittaUMA(), dittaUMAAziendaVO.getIdAzienda(), idLavorazioni, idCategoriaUtilizzoUma, flagAsservimento, codiceMotivoLavoraz);
	    	SolmrLogger.debug(this, "--- superficieMontagna ="+superficieMontagna);
	    	hashMapSuperficieMontagna.put(idLavorazContoProprio,superficieMontagna);
	    
      	  }
        }  
        // ---- CASO Tipo unita misura = 'M'
        else if(categColturaVO.getTipoUnitaMisura().equals(SolmrConstants.TIPO_UNITA_MISURA_M)){
          if(tipoLavorazVO != null && tipoLavorazVO.get(0) != null){      
        	String flagAsservimento = tipoLavorazVO.get(0).getFlagAsservimento();
        	SolmrLogger.debug(this, "--- flagAsservimento ="+flagAsservimento);
        
	    	// Ricerca del valore massimo per la superficie (per controllo max superficie)
	    	String codiceMotivoLavoraz = elencoLavContoProprioMod.get(i).getTipoMotivoLavVO().getCodiceMotivoLavorazione();
	    	SolmrLogger.debug(this, "--- codiceMotivoLavoraz ="+codiceMotivoLavoraz);
	    	BigDecimal maxSuperficie = umaFacadeClient.getSuperficieInsLavCP(dittaUMAAziendaVO.getIdDittaUMA(), dittaUMAAziendaVO.getIdAzienda(), idLavorazioni, idCategoriaUtilizzoUma, annoRiferimento, flagAsservimento, codiceMotivoLavoraz);
	    	SolmrLogger.debug(this, "--- maxSuperficie ="+maxSuperficie);
	    	hashMapMaxSuperficie.put(idLavorazContoProprio,maxSuperficie);		
	    
      	  }
        }  
        // ---- CASO Tipo unita misura = 'K'
        else if(categColturaVO.getTipoUnitaMisura().equals(SolmrConstants.TIPO_UNITA_MISURA_K)){
        
	        // Ricerca del valore massimo per la superficie (per controllo max superficie)
	        BigDecimal maxSuperficie = umaFacadeClient.getDimensioneFabbricato(dittaUMAAziendaVO.getIdAzienda().longValue(),anno);
	        SolmrLogger.debug(this, "--- maxSuperficie ="+maxSuperficie);
          hashMapMaxSuperficie.put(idLavorazContoProprio,maxSuperficie);    
        }      
      }

    }
    // memorizzo le HashMap per la view
    session.setAttribute("hashMapMacchine", hashMapMacchine);
    session.setAttribute("hasMapCategColt", hasMapCategColt);
    session.setAttribute("hashMapTipoLavoraz", hashMapTipoLavoraz);
    session.setAttribute("hashMapMaxSuperficie", hashMapMaxSuperficie);
    session.setAttribute("hashMapSuperficieMontagna",hashMapSuperficieMontagna);
  }  // fine CASO primo caricamento della pagina 
  else if (operation.equals("salva")){
    SolmrLogger.debug(this, " --- CASO salva");    
   
    Vector<LavContoProprioVO> vLavContoProprioUpdate = new Vector<LavContoProprioVO>();
    ValidationErrors errors = validate(request, (Vector<LavContoProprioVO>)session.getAttribute("lavContoProprioMod"), vLavContoProprioUpdate, umaFacadeClient);    
    if (errors.size() != 0){
      SolmrLogger.debug(this," ----- Ci sono degli errori di validazione, quanti =" + errors.size());
      request.setAttribute("errors", errors);
      // memorizzo gli oggetti con le modifiche effettuate dall'utente
      session.setAttribute("lavContoProprioMod",(Vector<LavContoProprioVO>)request.getAttribute("lavContoProprioMod"));
    }
    else{
      SolmrLogger.debug(this," ----- NON ci sono errori di validazione, procedere con UPDATE lavorazioni CP");
      try{
        // recupero le informazioni memorizzate nel validate
        Vector<LavContoProprioVO> elencoLavModificate = (Vector<LavContoProprioVO>)request.getAttribute("lavContoProprioMod");
        umaFacadeClient.aggiornaLavorazioneContoProprio(elencoLavModificate,ruoloUtenza);
      }
      catch (SolmrException sexc){
        SolmrLogger.debug(this, "--- SolmrEception in fase di aggiornaLavorazioneContoProprio ="+sexc.getMessage());
        if (sexc.getValidationErrors() != null){          
          ValidationErrors vErrors = sexc.getValidationErrors();
          if (vErrors.size() != 0){
            SolmrLogger.debug(this, "if (vErrors.size()!=0)");
            request.setAttribute("errors", vErrors);
						%>
						  <jsp:forward page="<%=viewUrl%>" />
						<%
						return;
          }
        }
        else{
          SolmrLogger.debug(this, "else (vErrors.size()!=0)");
          ValidationException valEx = new ValidationException("Eccezione di validazione" + sexc.getMessage(), viewUrl);
          valEx.addMessage(sexc.toString(), "exception");
          throw valEx;
        }        
      }
      catch (Exception e){
        SolmrLogger.debug(this, "--- Exception in fase di aggiornaLavorazioneContoProprio ="+e.getMessage());
        ValidationException valEx = new ValidationException("Eccezione di validazione" + e.getMessage(), viewUrl);
        valEx.addMessage(e.getMessage(), "exception");
        throw valEx;
      }      
	  session.setAttribute("paginaChiamante", "modifica");
      session.setAttribute("notifica", "Modifica eseguita con successo");
      response.sendRedirect(elencoHtm);
      return;
    }       
  } // fine CASO salva
  else if(operation.equals("annulla")){
    SolmrLogger.debug(this, " --- CASO annulla");   
    response.sendRedirect(elencoHtm);
    session.setAttribute("paginaChiamante", "modifica");
    return;
  } // fine CASO annulla
  
  SolmrLogger.debug(this, "   END modificaLavContoProprioCtrl");
%>
  <jsp:forward page="<%=viewUrl%>" />
<%!


  private void removeValSession(HttpSession session){
    SolmrLogger.debug(this, "   BEGIN removeValSession");
    
     session.removeAttribute("coefficienteCarburante");
     session.removeAttribute("hashMapMacchine");
     session.removeAttribute("hasMapCategColt");
     session.removeAttribute("hashMapTipoLavoraz");
     session.removeAttribute("hashMapMaxSuperficie");
     session.removeAttribute("hashMapSuperficieMontagna");
   
   SolmrLogger.debug(this, "   END removeValSession");  
  }

  private ValidationErrors validate(HttpServletRequest request, Vector<LavContoProprioVO> vLavContoProprio, Vector<LavContoProprioVO> vLavContoProprioUpdate, UmaFacadeClient umaFacadeClient) throws Exception {
    SolmrLogger.debug(this, "   BEGIN validate");
    ValidationErrors errors = new ValidationErrors();
    
    Vector<LavContoProprioVO> elencoLavModificate = new Vector<LavContoProprioVO>();
    // Ciclo sulle lavorazioni modificabili
    for (int i = 0; i < vLavContoProprio.size(); i++){
      LavContoProprioVO lavContoProprioVO = (LavContoProprioVO) vLavContoProprio.get(i);
      LavContoProprioVO lavContoProprioInsert = new LavContoProprioVO();
      
      // Salvo nell'oggetto che verrà inserito i valori non modificabili
      lavContoProprioInsert = loadVO(lavContoProprioVO);
      
      String idLavContoProprio = lavContoProprioVO.getIdLavorazioneContoProprio();                       
      SolmrLogger.debug(this, "---- Validazione su ID_LAVORAZIONE_CONTO_PROPRIO ="+idLavContoProprio);            
      // valori hidden per le validazioni
      String maxCarburante = request.getParameter("maxCarburante"+ idLavContoProprio);
      String tipoUnitaMisura = request.getParameter("tipoUnitaMisura"+ idLavContoProprio);
      String supTotaleCalcolata = request.getParameter("supTotaleCalcolata"+ idLavContoProprio);
      

      // Campi disabilitati modificati da memorizzare
      String litriCarburante = request.getParameter("litriCarburante" + idLavContoProprio);
      SolmrLogger.debug(this, "--- litriCarburante ="+litriCarburante);
      if(litriCarburante != null && !litriCarburante.equals(""))
        lavContoProprioInsert.setLitriLavorazione(new BigDecimal(litriCarburante.replace(',', '.')));
            
      String litriBaseCalcolati = request.getParameter("litriBaseCalcolati" + idLavContoProprio);  
      SolmrLogger.debug(this, "--- litriBaseCalcolati ="+litriBaseCalcolati);
      if(litriBaseCalcolati != null && !litriBaseCalcolati.equals(""))
        lavContoProprioInsert.setLitriBase(new BigDecimal(litriBaseCalcolati.replace(',', '.')));  
      
      String litriMedioImpastoCalcolati = request.getParameter("litriMedioImpastoCalcolati"+ idLavContoProprio); 
      SolmrLogger.debug(this, "--- litriMedioImpastoCalcolati ="+litriMedioImpastoCalcolati);
      if(litriMedioImpastoCalcolati != null && !litriMedioImpastoCalcolati.equals(""))
        lavContoProprioInsert.setLitriMedioImpasto(new BigDecimal(litriMedioImpastoCalcolati.replace(',', '.')));
      
      String litriAcclivita = request.getParameter("litriAcclivita"+ idLavContoProprio);  
      SolmrLogger.debug(this, "--- litriAcclivita ="+litriAcclivita);
      if(litriAcclivita != null && !litriAcclivita.equals(""))
        lavContoProprioInsert.setLitriAcclivita(new BigDecimal(litriAcclivita.replace(',', '.'))); 
         
      
      
      //-------------  Controlli sul campo note
      SolmrLogger.debug(this, " ----- Controlli Note -----");
      String note = request.getParameter("note" + idLavContoProprio);
      lavContoProprioInsert.setNote(note);
      if (!StringUtils.isStringEmpty(note)){
	      if (note.length() > 1000){
	        errors.add("note"+i, new ValidationError("Il valore immesso non deve superare i 1000 caratteri"));
	      }
	      else{
	        SolmrLogger.debug(this, "--- note ="+note);
	      }
      }
      
      // -------------- Controlli Numero esecuzioni
      String numEsecuzioni = request.getParameter("esecuzioniStr"+ idLavContoProprio);
      String maxEsecuzione = request.getParameter("maxEsecuzione"+ idLavContoProprio);
      SolmrLogger.debug(this, " ----- Controlli Numero esecuzioni -----");
      SolmrLogger.debug(this, " -- numero massimo di esecuzioni ="+ maxEsecuzione);
      SolmrLogger.debug(this, " -- Numero esecuzioni inserito =" + numEsecuzioni);
      long esecuzioniInput = 0;	
      lavContoProprioInsert.setNumEsecuzioni(numEsecuzioni);
      
	  if (Validator.isEmpty(numEsecuzioni)){
        errors.add("esecuzioniStr"+i, new ValidationError("Campo obbligatorio"));
      }
      else{              
        try{
          esecuzioniInput = Long.parseLong(numEsecuzioni);
      }
      catch (Exception ex){
        errors.add("esecuzioniStr"+i, new ValidationError("Inserire un valore numerico intero"));
      }
      if(esecuzioniInput < 0 || esecuzioniInput == 0){
          errors.add("esecuzioniStr"+i, new ValidationError("Inserire un valore numerico maggiore di zero"));
      }
      else{
        // Controllo che il numero esecuzioni indicato non superi max_esecuzioni
       	if(!StringUtils.isStringEmpty(maxEsecuzione)){
       	    SolmrLogger.debug(this, "--- controllare che non sia stato inserito un numero > del massimo consentito");
       	    long maxEsecuzioni = Long.parseLong(maxEsecuzione);
		    SolmrLogger.debug(this, " -- numero massimo di esecuzioni ="+maxEsecuzioni);
		    SolmrLogger.debug(this, " -- numero esecuzioni indicato ="+esecuzioniInput);
	        if (esecuzioniInput > maxEsecuzioni){
	          errors.add("esecuzioniStr"+i, new ValidationError("Non è possibile aumentare il valore del numero esecuzioni"));
	        }
	        else{
	          SolmrLogger.debug(this, "--- Numero esecuzioni = "+numEsecuzioni);
	          lavContoProprioInsert.setNumEsecuzioni(numEsecuzioni);
	        }
	    }  
	    else{
	      SolmrLogger.debug(this, "--- Numero esecuzioni = "+numEsecuzioni);
	      lavContoProprioInsert.setNumEsecuzioni(numEsecuzioni);
	    }
      }      
    }


    // ------------- Controllo campo 'Sup/Ore'
    String supOreStr = request.getParameter("supOreStr" + idLavContoProprio);
    lavContoProprioInsert.setSupOreStr(supOreStr);       
    SolmrLogger.debug(this, "---- Controlli sul campo Sup.(ha)/Ore");
	if (Validator.isEmpty(supOreStr)){
	     errors.add("supOreStr"+i, new ValidationError("Campo obbligatorio"));	     
	}
	else{	
	  try{	        		        
	     BigDecimal supOre = new BigDecimal(supOreStr.replace(',', '.'));	        

		// -------- CASO TIPO_MISURA = 'S'	        
	    if(!StringUtils.isStringEmpty(supTotaleCalcolata) && SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(tipoUnitaMisura)){
	      SolmrLogger.debug(this, "--  CASO TIPO_MISURA = 'S' --");
	      BigDecimal superficieCalcolataBd = new BigDecimal(supTotaleCalcolata.replace(',', '.'));
	          
	      // La superficie indicata non deve superare quella che è stata calcolata	 
	      SolmrLogger.debug(this, "-- superficie indicata dall'utente ="+supOreStr);  
	      SolmrLogger.debug(this, "--- superficie calcolata ="+ supTotaleCalcolata);           
	      if (supOre.compareTo(superficieCalcolataBd) > 0){
	        errors.add("supOreStr"+i, new ValidationError("Non è possibile aumentare il valore della superficie (valore massimo consentito "+StringUtils.formatDouble4(superficieCalcolataBd)+" ha)"));
	      }	
	   }
	   // -------- CASO TIPO_MISURA = 'K'          
     if(!StringUtils.isStringEmpty(supTotaleCalcolata) && SolmrConstants.TIPO_UNITA_MISURA_K.equalsIgnoreCase(tipoUnitaMisura)){
        SolmrLogger.debug(this, "--  CASO TIPO_MISURA = 'K' --");
        BigDecimal superficieCalcolataBd = new BigDecimal(supTotaleCalcolata.replace(',', '.'));
            
        // La superficie indicata non deve superare quella che è stata calcolata   
        SolmrLogger.debug(this, "-- superficie indicata dall'utente ="+supOreStr);  
        SolmrLogger.debug(this, "--- superficie calcolata ="+ supTotaleCalcolata);           
        if (supOre.compareTo(superficieCalcolataBd) > 0){
          errors.add("supOreStr"+i, new ValidationError("Non è possibile aumentare il valore della potenza (valore massimo consentito "+StringUtils.formatDouble4(superficieCalcolataBd)+" kw)"));
        } 
     }
     // -------- CASO TIPO_MISURA = 'M'          
     if(!StringUtils.isStringEmpty(supTotaleCalcolata) && SolmrConstants.TIPO_UNITA_MISURA_M.equalsIgnoreCase(tipoUnitaMisura)){
        SolmrLogger.debug(this, "--  CASO TIPO_MISURA = 'M' --");
        BigDecimal superficieCalcolataBd = new BigDecimal(supTotaleCalcolata.replace(',', '.'));
        superficieCalcolataBd = superficieCalcolataBd.multiply(new BigDecimal(SolmrConstants.MAX_METRO_L));
            
        // La superficie indicata non deve superare quella che è stata calcolata   
        SolmrLogger.debug(this, "-- superficie indicata dall'utente ="+supOreStr);  
        SolmrLogger.debug(this, "--- superficie calcolata ="+ supTotaleCalcolata);
        SolmrLogger.debug(this, "--- max superficie per metro lineare ="+ superficieCalcolataBd);           
        
        if(supOre.compareTo(superficieCalcolataBd)>0){
          errors.add("supOreStr"+i, new ValidationError("La lunghezza indicata non può essere maggiore di "+StringUtils.formatDouble4(superficieCalcolataBd)+" metri"));
 		}
     }  
	   if (supOre.compareTo(new BigDecimal(0)) < 0){
	     errors.add("supOreStr"+i, new ValidationError("Non è possibile inserire un valore negativo"));
	   }
	   // Non è possibile inserire il valore zero
	   String supOreFormattata = NumberUtils.formatDouble4(supOreStr, true);
	   if(supOreFormattata.equals("0,0000")){
	     errors.add("supOreStr"+i, new ValidationError("Deve essere inserito un valore maggiore di zero"));
	   }
	   else if (!Validator.validateDoubleDigit(supOreStr, 10, 4)){
	     errors.add("supOreStr"+i, new ValidationError("Il valore può avere al massimo 10 cifre intere e 4 decimali"));	            
	   }
	   else{  
	     SolmrLogger.debug(this, "--- superficie corretta ="+supOre);          	         	         
	   }
	 }
	 catch (Exception ex){	        
	   errors.add("supOreStr"+i, new ValidationError("Campo non numerico"));
	 }
   }
    
    elencoLavModificate.add(lavContoProprioInsert);

 } // chiusura ciclo lavorazioni modificabili
    
  request.setAttribute("lavContoProprioMod", elencoLavModificate);
  SolmrLogger.debug(this, "   END validate");
  return errors;
}


 private LavContoProprioVO loadVO(LavContoProprioVO lavContoProprioVO){
   SolmrLogger.debug(this, "   BEGIN loadVO");
   
   LavContoProprioVO lavCpDaInserire = new LavContoProprioVO();
   lavCpDaInserire.setIdLavorazioneContoProprio(lavContoProprioVO.getIdLavorazioneContoProprio());
   
   lavCpDaInserire.setIdDittaUma(lavContoProprioVO.getIdDittaUma());
   lavCpDaInserire.setAnnoCampagna(lavContoProprioVO.getAnnoCampagna());
   lavCpDaInserire.setUsoDelSuolo(lavContoProprioVO.getUsoDelSuolo());
   lavCpDaInserire.setDescrUsoDelSuolo(lavContoProprioVO.getDescrUsoDelSuolo());
   lavCpDaInserire.setLavorazione(lavContoProprioVO.getLavorazione());
   lavCpDaInserire.setTipoMotivoLavVO(lavContoProprioVO.getTipoMotivoLavVO());
   lavCpDaInserire.setDescrLavorazione(lavContoProprioVO.getDescrLavorazione());
   lavCpDaInserire.setIdUnitaMisura(lavContoProprioVO.getIdUnitaMisura());
   lavCpDaInserire.setIdMacchina(lavContoProprioVO.getIdMacchina());

   SolmrLogger.debug(this, "   END loadVO");
   return lavCpDaInserire;
 }

  %>
