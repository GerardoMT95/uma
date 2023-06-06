<%@page import="it.csi.solmr.interfaceCSI.uma.UmaCSIInterface"%>
<%@page import="it.csi.solmr.dto.filter.LavContoProprioFilter"%>
<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="java.util.*"%>
<%@page import="it.csi.solmr.dto.uma.form.AggiornaContoProprioFormVO"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%
  String iridePageName = "nuovaLavContoProprioCtrl.jsp";  
%>
  <%@include file="/include/autorizzazione.inc"%>
<%
  
  SolmrLogger.debug(this,"   BEGIN nuovaLavContoProprioCtrl.jsp");
  
  
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  String viewUrl = "/ditta/view/nuovaLavContoProprioView.jsp"; 
  String elencoHtm = "../../ditta/layout/elencoLavContoProprio.htm";
  
  String funzione = request.getParameter("funzione");
  SolmrLogger.debug(this, "--- funzione = "+funzione);
  
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma = dittaUMAAziendaVO.getIdDittaUMA();
  SolmrLogger.debug(this, " -- idDittaUma ="+idDittaUma);
  String annoCampagna = ((LavContoProprioFilter)session.getAttribute("filterRicercaLavContoProprio")).getAnnoDiRiferimento();
  SolmrLogger.debug(this, " -- annoCampagna ="+annoCampagna);
  
  AggiornaContoProprioFormVO form = (AggiornaContoProprioFormVO) session.getAttribute("formInserimentoCP");
  String flagPulisciSessione = (String) request.getAttribute("flagPulisciSessione");
  SolmrLogger.debug(this, "flagPulisciSessione vale: "+ flagPulisciSessione);

  if (!StringUtils.isStringEmpty(flagPulisciSessione) || form == null){
    form = new AggiornaContoProprioFormVO();
  }
  
  
  /* ------- **** Primo accesso alla pagina :
      - rimuovere i valori memorizzati in sessione
      - effettuare query per il poplamento delle combo
   */  
  if(funzione == null || funzione.equals("")){
      SolmrLogger.debug(this, "---- CASO Primo accesso alla pagina ----");     
      // Rimuovo dalla sessione gli oggetti eventualmente settati
      removeAttributeFromSession(session);      
     
     // -- *** Combo 'Uso del suolo'
     SolmrLogger.debug(this, "-- Ricerca elementi per la COMBO Uso del Suolo");
     findDatiUsoDelSuolo(idDittaUma,session,form,umaFacadeClient);
     
     
     // Controllo se per l'anno in corso sia già presente l'assegnazione base/saldo validata
     SolmrLogger.debug(this, "-- Controllo se per l'anno in corso sia già presente l'assegnazione base/saldo validata");
     Boolean isPresenteAssegnazValidata = false;
     Vector elencoDomandeAsse = umaFacadeClient.findDomandeAssegnazByIdDittaAnnoRif(idDittaUma,new Long(annoCampagna),SolmrConstants.ID_STATO_DOMANDA_VALIDATA );
     if(elencoDomandeAsse != null && elencoDomandeAsse.size()>0)
       isPresenteAssegnazValidata = true;
     SolmrLogger.debug(this, "--- isPresenteAssegnazValidata ="+isPresenteAssegnazValidata);  
     session.setAttribute("isPresenteAssegnazValidata", isPresenteAssegnazValidata);  
     
     // -- *** Combo 'Motivo lavorazione'     
     SolmrLogger.debug(this, "-- Ricerca elementi per la COMBO Motivo lavorazione");
     findDatiMotivoLavorazione(isPresenteAssegnazValidata,session,form,umaFacadeClient);     

  } // fine Primo accesso
  else{
    // -- Motivo lavorazione (prendo il valore dal campo hidden)
    String idMotivoLavorazione = (String) request.getParameter("motivoLavorazSel");
    SolmrLogger.debug(this, "-- idMotivoLavorazione ="+idMotivoLavorazione);
    form.setIdMotivoLavorazione(idMotivoLavorazione);
  }
  // --------- *** Caso annulla *** ----------
  if(funzione != null && funzione.equalsIgnoreCase("annulla")){
    SolmrLogger.debug(this, "---- Gestione CASO annulla ----");
      
    // Rimuovo dalla sessione gli eventuali elementi settati in sessione
    removeAttributeFromSession(session);      
    // viene utilizzato per mantenere i filtri settati in fase di ricerca nella pagina di Elenco lavorazioni
    session.setAttribute("paginaChiamante", "inserisci");             
    response.sendRedirect(elencoHtm);      
    return;
  }      
  
  // Anno campagna
   form.setAnnoCampagna(annoCampagna);
   
   // Uso del suolo selezionato
   String idUsoSuolo = (String) request.getParameter("usoSuolo");
   SolmrLogger.debug(this,"-- Uso del suolo selezionato nalla combo ="+idUsoSuolo);
   form.setIdUsoSuolo(idUsoSuolo);
   SolmrLogger.debug(this, " --- idUso del Suolo selezionato ="+form.getIdUsoSuolo());
   
   
   // -- *** Combo 'Lavorazione'
   // --- Carico la Combo 'Lavorazione' : se è stato selezionato un elemento nella combo 'Uso del suolo'  
   findDatiLavorazione(idDittaUma, annoCampagna, idUsoSuolo, umaFacadeClient, form, session);
   
   // -- Numero esecuzioni
   String numeroEsecuzioni = (String) request.getParameter("numeroEsecuzioni");
   SolmrLogger.debug(this, "--- numero esecuzioni ="+ numeroEsecuzioni);
   form.setNumeroEsecuzioni(numeroEsecuzioni);
   
   // Unità di misura
   String unitaDiMisura = (String) request.getParameter("unitaDiMisura");
   SolmrLogger.debug(this, "--- unita di misura ="+ unitaDiMisura);
   form.setDescrUnitaMisura(unitaDiMisura);



   // --- Valori per il calcolo carburante
   SolmrLogger.debug(this, "--- Recupero i valori per il CALCOLO CARBURANTE");
   String anno = annoCampagna;
   String data = null;
   String coefficiente = umaFacadeClient.getValoreParametro(SolmrConstants.PARAMETRO_COEFFICIENTE_CAVALLI_CARBURANTE,anno,data);
   SolmrLogger.debug(this, " --- coefficiente ="+coefficiente);
   form.setCoefficiente(coefficiente);  

   String litriBase = (String) request.getParameter("litriBase");
   form.setLitriBase(litriBase);      

   String litriMedioImpasto = (String) request.getParameter("litriMedioImpasto");
   form.setLitriMedioImpasto(litriMedioImpasto);

   String litriTerDeclivi = (String) request.getParameter("litriTerDeclivi");
   form.setLitriTerDeclivi(litriTerDeclivi);
   
   String note = (String) request.getParameter("note");  
   form.setNote(note);
  
   // ----
   
   // -- Lavorazione : setto i valori, se è stata selezionata una Lavorazione, Es : 999|1|1|1|1|T
   String idLavorazione = (String) request.getParameter("idLavorazione");
   SolmrLogger.debug(this, "----- idLavorazione selezionato ="+idLavorazione);

   // Es valore di idLavorazione : 998|3|12|4|20|S
   if (!StringUtils.isStringEmpty(idLavorazione)){
    StringTokenizer st = new StringTokenizer(idLavorazione, "|");
    if (st.hasMoreTokens())
      form.setIdLavorazone(st.nextToken());    
    if (st.hasMoreTokens())
      form.setLitriBase(st.nextToken());          
    if (st.hasMoreTokens())
      form.setLitriMedioImpasto(st.nextToken());    
    if (st.hasMoreTokens())
      form.setLitriTerDeclivi(st.nextToken());
    if (st.hasMoreTokens())      
        form.setTipoUnitaMisura(st.nextToken());
    if (st.hasMoreTokens())
      form.setFlagEscludiEsecuzioni(st.nextToken());    
    if (st.hasMoreTokens())
      form.setFlagAsservimento(st.nextToken());
  }
  else
  {
    form.setIdLavorazone(null);
  }
  
  SolmrLogger.debug(this, "-- idLavorazione =" + idLavorazione);
  SolmrLogger.debug(this, "--- litriBase ="+ form.getLitriBase());
  SolmrLogger.debug(this, "--- litriMedioImpasto ="+ form.getLitriMedioImpasto());
  SolmrLogger.debug(this, "--- litriTerDeclivi ="+ form.getLitriTerDeclivi());
  SolmrLogger.debug(this, "--- tipoUnitaMisura ="+ form.getTipoUnitaMisura());
  

  String supOreStr = (String) request.getParameter("supOreStr");
  SolmrLogger.debug(this, "--- supOreStr ="+supOreStr);
  form.setSupOre(supOreStr);
    
  String litriCarburante = (String) request.getParameter("litriCarburante");
  SolmrLogger.debug(this, "--- litriCarburante ="+litriCarburante);
  form.setLitriCarburante(litriCarburante);
  
  String litriBaseCalcolati = (String) request.getParameter("litriBaseCalcolati");
  SolmrLogger.debug(this, "--- litriBaseCalcolati ="+litriBaseCalcolati);
  form.setLitriBaseCalcolati(litriBaseCalcolati);
    
  String litriMedioImpastoCalcolati = (String) request.getParameter("litriMedioImpastoCalcolati");
  SolmrLogger.debug(this, "--- litriMedioImpastoCalcolati ="+litriMedioImpastoCalcolati);
  form.setLitriMedioImpastoCalcolati(litriMedioImpastoCalcolati);
  
  String litriAcclivita = (String) request.getParameter("litriAcclivita");
  SolmrLogger.debug(this, "--- litriAcclivita ="+litriAcclivita);
  form.setLitriAcclivita(litriAcclivita);
  
  
  
  String idMacchina = (String) request.getParameter("idMacchina");
  SolmrLogger.debug(this,"--- idMacchina ="+idMacchina);
  form.setIdMacchina(idMacchina);
  
  String cavalli = (String) request.getParameter("cavalli");
  SolmrLogger.debug(this,"--- cavalli ="+cavalli);
  form.setCavalli(cavalli);
  

  String tipoUnitaMisura = (String) request.getParameter("tipoUnitaMisura");
  SolmrLogger.debug(this, "--- tipoUnitaMisura ="+ tipoUnitaMisura);

 
  // ---- *** Se è stato selezionato un valore nella combo 'Lavorazione' e quindi 'Uso del suolo'
  if (!StringUtils.isStringEmpty(form.getIdUsoSuolo()) && !StringUtils.isStringEmpty(form.getIdLavorazone())){
    SolmrLogger.debug(this, " ----- E' stata selezionata una LAVORAZIONE :"+form.getIdLavorazone());
    
    // Cerco il valore da proporre nel campo 'Numero esecuzioni' e 'Unità di misura'
    SolmrLogger.debug(this, " --- cerco il valore da proporre a video nel campo 'Numero esecuzioni' e 'Unita di misura'");
    calcolaNumEsecuzUnitaMisura(form,umaFacadeClient); 
    
    // Controllo se deve esssere visualizzata la **** Combo 'Macchina' ed, in tal caso, ricerco i valori 
    findDatiMacchina(idDittaUma,annoCampagna,form,umaFacadeClient,session);    
    
  }    
  else{
    form.setTipoUnitaMisura("");
    form.setIdUnitaMisura("");
    form.setCodiceUnitaMisura("");   
    form.setMaxEsecuzioni("");
  }

  
  // ------------- Alla selezione di una 'Lavorazione' o di un 'Motivo lavorazione' --> CALCOLO SUPERFICIE
  /* Sup. (ha)/Ore : 
       - se DB_UNITA_MISURA = 'T' : vuoto (gestito da JavaScript)
       - se DB_UNIT_MISURA = 'S' : 
          - controllo il codice legato all'idMotivoLavorazione selezionato
             - se DB_TIPO_LAVORAZIONI.FLAG_ASSERVIMENTO = 'S' :                  
             - se DB_TIPO_LAVORAZIONI.FLAG_ASSERVIMENTO = 'N' :
     Note : avremo quindi 8 casistiche di calcolo Superficie (4 codici di Motivo lavorazione * 2 tipi di FLAG_ASSERVIMENTO)                      
  */  
  SolmrLogger.debug(this, " --- Tipo unita misura legata alla lavorazione ="+form.getTipoUnitaMisura());
  // Attenzione : se l'unità di misura sono le ore non si deve settare tale valore  
  if(form.getTipoUnitaMisura() != null && !form.getTipoUnitaMisura().equals("")){
    SolmrLogger.debug(this, "--- funzione ="+funzione);
    if(funzione != null && (funzione.equals("cambioLavorazione") || funzione.equals("cambioMotivoLavorazione"))){
	  SolmrLogger.debug(this, "-- E' stata modificata la combo Lavorazione o la combo Motivo lavorazione");
      if(form.getTipoUnitaMisura().equals(SolmrConstants.TIPO_UNITA_MISURA_S)){	            	 		 
		     SolmrLogger.debug(this, "------ CALCOLO DELLA SUPERFICIE da proporre nel campo 'Sup(ha)/Ore'");
			
			 // Recupero il CODICE_MOTIVO_LAVORAZIONE, dato l'idMotivoLavorazione selezionato nella combo
			 HashMap<Long,TipoMotivoLavorazioneVO> motivoLavHm = (HashMap<Long,TipoMotivoLavorazioneVO>)session.getAttribute("motivoLavorazHM");
			 String idMotivoLavorazSel = form.getIdMotivoLavorazione();
			 SolmrLogger.debug(this, "--- idMotivoLavorazSel ="+idMotivoLavorazSel);
			 TipoMotivoLavorazioneVO tipoMotLavVO = motivoLavHm.get(new Long(idMotivoLavorazSel));
			 String codiceMotivoLavoraz = tipoMotLavVO.getCodiceMotivoLavorazione();
			 SolmrLogger.debug(this, "--- codiceMotivoLavoraz ="+codiceMotivoLavoraz);
			 		     
		     // --------- CALCOLO DELLA SUPERFICIE da proporre nel campo 'Sup(ha)/Ore'	    	    				    	    
		     BigDecimal superficie = umaFacadeClient.getSuperficieInsLavCP(idDittaUma, dittaUMAAziendaVO.getIdAzienda(), form.getIdLavorazone(), form.getIdUsoSuolo(), form.getAnnoCampagna(), form.getFlagAsservimento(), codiceMotivoLavoraz);		
		     SolmrLogger.debug(this, " ----- Superficie totale calcolata ="+superficie);   
		       	   
		     form.setSuperficieCalcolata("" + superficie);
		     form.setSupOre("" + superficie);
		     
		     // Se la superficie è < 0, propongo 0
		     BigDecimal supZero= new BigDecimal("0");  
		     if (superficie.compareTo(supZero) < 0){
		  	   form.setSupOre("0");	  	  
		     }
		     		     
		     // ----------- CALCOLO DELLA SUPERFICIE in MONTAGNA (serve per il calcolo del carburante)
		     BigDecimal superficieMontagna = umaFacadeClient.getSuperficieMontagnaCP(idDittaUma, dittaUMAAziendaVO.getIdAzienda(), form.getIdLavorazone(), form.getIdUsoSuolo(), form.getFlagAsservimento(), codiceMotivoLavoraz);
		     SolmrLogger.debug(this, " ----- Superficie montagna ="+superficieMontagna);
		     form.setSuperficieMontagna("" + superficieMontagna);
		     	     	    
		  } // fine CASO TIPO UNITA MISURA = S
			else if(form.getTipoUnitaMisura().equals(SolmrConstants.TIPO_UNITA_MISURA_K))
			{
				     BigDecimal superficie = umaFacadeClient.getDimensioneFabbricato(dittaUMAAziendaVO.getIdAzienda().longValue(),annoCampagna);
				     form.setSuperficieCalcolata("" + superficie);
		         form.setSupOre("" + superficie);
		         
	           // Se la superficie è < 0, propongo 0
	           if (superficie.compareTo(BigDecimal.ZERO) < 0)
	             form.setSupOre("0");       
				  }
		  // CASO unità di misura = 'T' e 'P' e 'M'
          else{
            SolmrLogger.debug(this, " -- Caso unita' di misura = 'T,P,M' -> non viene effettuato a priori il calcolo della Superficie");
	        form.setSuperficieCalcolata("");
	        form.setSupOre("");
          }	  	  
      } // fine ONCHANGE COMBO LAVORAZIONE o ONCHANGE COMBO MOTIVO LAVORAZIONE  	  
 } // caso TIPO UNITA MISURA valorizzata 
  
  

   // ---------------- *** GESTIONE CASO aggiungi *** -------------------
  if (funzione != null && (funzione.equalsIgnoreCase("aggiungi"))){
    SolmrLogger.debug(this,"--- CASO AGGIUNGI ---");   
    
    LavContoProprioVO lavContoProprioInsert = new LavContoProprioVO();
    SolmrLogger.debug(this, "---- Effettuo validazione dei campi");
    ValidationErrors errors = validateInsert(request, session, form, lavContoProprioInsert, annoCampagna, umaFacadeClient, dittaUMAAziendaVO);
    request.setAttribute("errors", errors);
        
    // Se non sono stati riscontrati errori : preparo l'oggetto da visualizzare nella tabella di riepilogo
    if(errors.empty() || errors.size()==0){    	    
	    try{               	              
		  lavContoProprioInsert.setNote(form.getNote());	        	 	
		  lavContoProprioInsert.setExtIdUtenteAggiornamento(ruoloUtenza.getIdUtente());	        
		  lavContoProprioInsert.setCodiceUnitaMisura(form.getCodiceUnitaMisura());	
		  lavContoProprioInsert.setIdUnitaMisura(form.getIdUnitaMisura());
		  
		        	        
		   // *********** Dati mancanti per la tabella di riepilogo (descrizioni legate agli id selezionati nella combo) ***
		        
		   // Valorizzo la descrizione della lavorazione
		   HashMap<Long,String> lavorazHM = (HashMap<Long,String>)session.getAttribute("lavorazHM");  
		   SolmrLogger.debug(this, "- idLavorazioni ="+lavContoProprioInsert.getLavorazione());
	       String descrLavorazione = lavorazHM.get(new Long(lavContoProprioInsert.getLavorazione()));
	       lavContoProprioInsert.setDescrLavorazione(descrLavorazione);
	            
	       // Valorizzo la descrizione dell'uso del suolo
	       HashMap<Long,String> usoDelSuoloHM = (HashMap<Long,String>)session.getAttribute("usoDelSuoloHM");
		   SolmrLogger.debug(this, "-- idUsoDelSuolo ="+lavContoProprioInsert.getUsoDelSuolo());
	       String idUsoDelSuolo = lavContoProprioInsert.getUsoDelSuolo();
	       SolmrLogger.debug(this, "- idUsoDelSuolo ="+idUsoDelSuolo);
	       String usoDelSuolo = usoDelSuoloHM.get(new Long(idUsoDelSuolo));
	       lavContoProprioInsert.setDescrUsoDelSuolo(usoDelSuolo);
	            
	       // Se è stata selezionata la macchina, valorizzo la descrizione della macchina
	       if(lavContoProprioInsert.getIdMacchina() != null){
	         HashMap<Long,String> macchineHM = (HashMap<Long,String>)session.getAttribute("macchineHM");
	         String descrMacchina = macchineHM.get(new Long(lavContoProprioInsert.getIdMacchina()));
	         lavContoProprioInsert.setDescrMacchina(descrMacchina);
	       }
            	        	   
	       // *************
	       
	       lavContoProprioInsert.setIdDittaUma(idDittaUma.toString());
	       lavContoProprioInsert.setAnnoCampagna(annoCampagna);
	   
	   // memorizzo in sessione l'oggetto che si deve visualizzare nella tabella di riepilogo e che si dovrà inserire
	        SolmrLogger.debug(this, "-- ********** Memorizzo in sessione l'oggetto ********** --");
	        Vector<LavContoProprioVO> lavContoProprioVect = (Vector<LavContoProprioVO>)session.getAttribute("lavContoProprioVect");
	        if(lavContoProprioVect == null)
	          lavContoProprioVect = new Vector<LavContoProprioVO>();
	        lavContoProprioVect.add(lavContoProprioInsert);
	        session.setAttribute("lavContoProprioVect", lavContoProprioVect);        	        
	      
      }         
      catch (Exception e){
        ValidationException valEx = new ValidationException("Eccezione di validazione" + e.getMessage(), viewUrl);
        valEx.addMessage(e.getMessage(), "exception");
        SolmrLogger.error(this, " --- Exception durante la validazione sull'aggiungi ="+e.getMessage());
        throw valEx;
      }  
    }      
  }// fine caso AGGIUNGI  
  
  // ------------ *** GESTIONE CASO SALVA **** -----------------
  if (request.getParameter("funzione") != null && request.getParameter("funzione").equalsIgnoreCase("salva")){
    SolmrLogger.debug(this, "---- CASO salva");
    
    
    // ----------- **** CONTROLLI ULTERIORI SULLE LAVORAZIONI DELLA TABELLA DI RIEPILOGO **** ------------------
    /* Note : viene effettuato un ciclo dove per ogni lavorazione andiamo a fare tutti i controlli, se un controllo
              non viene superato, fermiamo il ciclo e visualizziamo l'errore per la Lavorazione che non ha rispettato i controlli
    */
    //-- viene tornata la posizione dell'elemento che non ha superato la validazione (il messaggio di errore viene settato nel metodo)
    int posizioneElementoKO = validazioniConLavorazDb(session, request, dittaUMAAziendaVO,annoCampagna,umaFacadeClient);
    
    // --- CASO : visualizzare l'errore
    if(posizioneElementoKO >-1){
      SolmrLogger.debug(this, "-- una lavorazione non ha superato le validazioni al SALVA, posizione :"+posizioneElementoKO);       
      SolmrLogger.debug(this, "   END nuovaLavContoProprioCtrl");
      // torno sulla view per visualizzare l'errore nella riga della tabella di riepilogo
      %>
        <jsp:forward page="<%=viewUrl%>" />
      <%
    }     
    else{            
      // --- CASO : effettuare l'inserimento sul db  
      SolmrLogger.debug(this, "-- Si puo' procedere con l'inserimento dei dati presenti nella tabella di riepilogo");
      Vector<LavContoProprioVO> lavContoProprioVect = (Vector<LavContoProprioVO>)session.getAttribute("lavContoProprioVect");
      try{       	        
        umaFacadeClient.inserisciLavContoProprioMultipla(lavContoProprioVect);
      }
      catch(Exception ex){
        SolmrLogger.error(this, "-- Exception in inserisciLavContoProprioMultipla ="+ex.getMessage());
        ValidationException valEx = new ValidationException("Eccezione in fase di inserimento Lavorazione Conto Proprio" + ex.getMessage(), viewUrl);
        valEx.addMessage(ex.getMessage(), "exception");
        throw valEx;
      }

      SolmrLogger.debug(this, "-- L'INSERIMENTO Lavorazione Conto Proprio e' stato eseguito con successo");      
      String forwardUrl = elencoHtm;           
	  
	  // viene utilizzato per mantenere i filtri settati in fase di ricerca nella pagina di Elenco lavorazioni
	  session.setAttribute("paginaChiamante", "inserisci");
	  
      session.setAttribute("notifica", "Inserimento eseguito con successo");
      SolmrLogger.debug(this, "-- forwardUrl ="+forwardUrl);
      response.sendRedirect(forwardUrl);
      SolmrLogger.debug(this, "   END nuovaLavContoProprioCtrl");
      return;              
    }// fine caso inserimento sul db    
        
  }// fine caso SALVA  
  
  // ---------- *** GESTIONE CASO rimuovi *** ---------------------
  if (funzione != null && funzione.equalsIgnoreCase("rimuovi")){
    SolmrLogger.debug(this, "---- CASO rimuovi");
    
    // Controllo quali elementi sono stati selezionati nella tabella di riepilogo
    String[] posizioni = request.getParameterValues("idLavContoProprio");
    if(posizioni != null){
      SolmrLogger.debug(this, "- numero di elementi da rimuovere dalla tabella di riepilogo ="+posizioni.length);
      // recupero dalla sessione l'elenco visualizzato nella tabella di riepilogo
      Vector<LavContoProprioVO> lavContoProprioVect = (Vector<LavContoProprioVO>)session.getAttribute("lavContoProprioVect");
      
      // elimino tutti gli elementi          
      if(posizioni.length == lavContoProprioVect.size()){
        SolmrLogger.debug(this, "- elimino tutti gli elementi");
        session.removeAttribute("lavContoProprioVect");
      }
      else{      
        int contatore = 0;
        for(int i=0;i<posizioni.length;i++){
          String indiceToRemove = (String)posizioni[i];
	      if(i == 0) {
	        lavContoProprioVect.removeElementAt(Integer.parseInt(indiceToRemove));
	      }
	      else{
	        lavContoProprioVect.removeElementAt(Integer.parseInt(indiceToRemove) - contatore);
	      }
	      contatore++;
        }
        // risetto in sessione l'elenco delle lavorazioni da visualizzare nel riepilogo
        session.setAttribute("lavContoProprioVect", lavContoProprioVect);
      }        
    }// fine caso RIMUOVI  

    SolmrLogger.debug(this, "   END nuovaLavContoTerziCtrl");
    // torno sulla view
    %>
      <jsp:forward page="<%=viewUrl%>" />
    <%     
  }  
  
  
  session.setAttribute("formInserimentoCP", form);


%>
  <jsp:forward page="<%=viewUrl%>" />
<%!


 // Controllo se deve essere visualizzata la combo 'Macchina' ed in tal caso ne ricerca gli elementi da visualizzare
 private void findDatiMacchina(Long idDittaUma, String annoCampagna, AggiornaContoProprioFormVO form, UmaFacadeClient umaFacadeClient,HttpSession session) throws Exception{
   SolmrLogger.debug(this, "   BEGIN findDatiMacchina");
   try{
     // Combo visualizzata solo quando l'unità di misurapresenta DB_UNITA_MISURA.TIPO = 'T'
     SolmrLogger.debug(this, " --- tipoUnitaMisura ="+form.getTipoUnitaMisura()); 
     if(form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_T)){
      SolmrLogger.debug(this, " -- La combo Macchina deve essere visualizzata"); 
      
      // Ricerco elementi
      SolmrLogger.debug(this, "--- Ricerca degli elementi da visualizzare nella combo 'Macchina'");
      Vector vettMacchine = umaFacadeClient.findMacchineLavContoProprio(idDittaUma.toString(),annoCampagna, form.getIdUsoSuolo(), form.getIdLavorazone());
      
      form.setVettMacchine(vettMacchine);      
      
      // --- Setto nell'HashMap utilizzata nella tab di riepilogo gli elementi
      if(form.getVettMacchine() != null){
        HashMap<Long,String> macchineHM = new HashMap<Long,String>();
        for(int i=0;i<form.getVettMacchine().size();i++){
          MacchinaVO macchina = (MacchinaVO)form.getVettMacchine().get(i);
          
          StringBuffer descMacchina = new StringBuffer();
          addStringForDescMacchina(descMacchina, macchina.getMatriceVO().getCodBreveGenereMacchina());
          addStringForDescMacchina(descMacchina, macchina.getTipoCategoriaVO().getDescrizione());
          String tipoMacchina = macchina.getMatriceVO().getTipoMacchina();
          
          if (Validator.isEmpty(tipoMacchina)){
            addStringForDescMacchina(descMacchina, macchina.getDatiMacchinaVO().getMarca());
          }
          else{
            addStringForDescMacchina(descMacchina, tipoMacchina);
          }
          addStringForDescMacchina(descMacchina, macchina.getTargaCorrente().getNumeroTarga());
          
          macchineHM.put(macchina.getIdMacchinaLong(), descMacchina.toString()); 
        }
        session.setAttribute("macchineHM", macchineHM);
      }
     }
     else{
      SolmrLogger.debug(this, " -- La combo Macchina non deve essere visualizzata");
      form.setIdMacchina("");    	
     }
   }
   catch(Exception ex){
   }
   finally{
     SolmrLogger.debug(this, "   END findDatiMacchina");
   }
 }

 // Cerca il valore da proporre nel campo 'Numero esecuzioni' e 'Unità misura'
 private void calcolaNumEsecuzUnitaMisura(AggiornaContoProprioFormVO form, UmaFacadeClient umaClient) throws Exception{
   SolmrLogger.debug(this, "   BEGIN calcolaNumeroEsecuzioni");
   try{
     String idTipoColturaLavorazCp = SolmrConstants.ID_TIPO_COLTURA_LAVORAZIONE_CONTO_PROPRIO;
     CategoriaColturaLavVO elem = umaClient.getCategoriaColturaLav(form.getIdLavorazone(), form.getIdUsoSuolo(), idTipoColturaLavorazCp, form.getAnnoCampagna());
     
     if (elem != null){      
      SolmrLogger.debug(this, "--- maxEsecuzione ="+ elem.getMaxEsecuzione());
      SolmrLogger.debug(this, "--- codiceUnitaMisura ="+ elem.getCodiceUnitaMisura());
      
      if (null != elem.getMaxEsecuzione())
      	form.setMaxEsecuzioni(""+elem.getMaxEsecuzione());
      else
      	form.setMaxEsecuzioni("1");

      form.setTipoUnitaMisura(elem.getTipoUnitaMisura());      
      form.setCodiceUnitaMisura(elem.getCodiceUnitaMisura());      
      form.setIdUnitaMisura(StringUtils.getLongValue(elem.getIdUnitaMisura()));
    }          
   }
   catch(Exception ex){
     SolmrLogger.error(this, "--- Exception in calcolaNumEsecuzUnitaMisura ="+ex.getMessage());
     throw ex;
   }  
 }

 // -- Ricerca gli elementi per la Comvo 'Lavorazione'
 private void findDatiLavorazione(Long idDittaUma,String annoCampagna,String idUsoSuolo, UmaFacadeClient umaClient, AggiornaContoProprioFormVO form, HttpSession session) throws Exception{
   SolmrLogger.debug(this, "   BEGIN findDatiLavorazione");
   try{
     SolmrLogger.debug(this, "--- idUsoDelSuolo selezionato ="+idUsoSuolo);
     if (!StringUtils.isStringEmpty(idUsoSuolo)){
   		SolmrLogger.debug(this, "---- Ricerca degli elementi da visualizzare nella combo 'Lavorazioni'");
   		String idLavorazioni = null; // non filtro per id_lavorazioni in questo caso
      	Vector vettLavorazioni = umaClient.findLavorazioniLavContoProprio(idDittaUma.toString(),annoCampagna,idUsoSuolo,idLavorazioni);
        form.setVettLavorazioni(vettLavorazioni);
      
        // --- Setto nell'HashMap utilizzata nella tab di riepilogo gli elementi
        if(form.getVettLavorazioni() != null){
          HashMap<Long,String> lavorazHM = new HashMap<Long,String>();
          for(int i=0;i<form.getVettLavorazioni().size();i++){
            TipoLavorazioneVO tipoLav = (TipoLavorazioneVO)form.getVettLavorazioni().get(i);
            lavorazHM.put(tipoLav.getIdTipoLav(), tipoLav.getDescrizione()); 
          }
          session.setAttribute("lavorazHM", lavorazHM);
      }
     }
   }
   catch(Exception ex){
     SolmrLogger.error(this, " --- Exception in findDatiLavorazione ="+ex.getMessage());
     throw ex;
   }
   finally{
     SolmrLogger.debug(this, "   END findDatiLavorazione");
   }      
 }


 // -- Ricerca gli elementi per la Combo 'Motivo lavorazione' --> Solo al primo accesso della pagina
 private void findDatiMotivoLavorazione(boolean isPresenteAssegnazValidata,HttpSession session, AggiornaContoProprioFormVO form, UmaFacadeClient umaClient)throws Exception{
   SolmrLogger.debug(this, "   BEGIN findDatiMotivoLavorazione");
   
   try{
	   Vector<TipoMotivoLavorazioneVO> motiviLavorazione = null;
	   // Controllo se c'è sono assegnazione saldo/base validata
	   SolmrLogger.debug(this, "-- isPresenteAssegnazValidata "+isPresenteAssegnazValidata); 
	   // -- Caso caricamento elementi con TIPO_ASSEGNAZIONE = 'S' -> Abilitato
	   if(isPresenteAssegnazValidata){
	    SolmrLogger.debug(this, "--  Caso caricamento elementi con TIPO_ASSEGNAZIONE = 'S' ");
	    motiviLavorazione = umaClient.findMotivoLavorazLavContoProprio(SolmrConstants.TIPO_ASSEGNAZIONE_SUPPLEMENTO);
	    // non deve essere selezionato nessun elemento di default
	    form.setIdMotivoLavorazione("");
	   }
	   // -- Caso caricamento elementi con TIPO_ASSEGNAZIONE = 'B' -> Disabilitato e selezionato
	   else{
	     SolmrLogger.debug(this, "--  Caso caricamento elementi con TIPO_ASSEGNAZIONE = 'B' ");
	     motiviLavorazione = umaClient.findMotivoLavorazLavContoProprio(SolmrConstants.TIPO_ASSEGNAZIONE_BASE_SALDO);
	     // In questo caso ci sarà solo 1 valore nella combo disabilitata e verrà selezionato di default
	     if(motiviLavorazione != null && motiviLavorazione.size() > 0){
	       Long idMotivoLavorazDaSel = motiviLavorazione.get(0).getIdMotivoLavorazione();
	       String idMotivoLavSel = "";
	       if(idMotivoLavorazDaSel != null)
	         idMotivoLavSel = idMotivoLavorazDaSel.toString();
	       SolmrLogger.debug(this, "-- idMotivoLavSel ="+idMotivoLavSel);
	       form.setIdMotivoLavorazione(idMotivoLavSel);
	     }	     
	   }
	   form.setVettMotivoLavorazione(motiviLavorazione);
   
       // Memorizzo in una HashMap gli elementi per poter visualizzare la descrizione nella tabella di riepilogo e poter individuare il codice legato all'id selezionato
       SolmrLogger.debug(this, "--- Memorizzo in una HashMap i motivi lavorazioni per poter visualizzare la descrizione nella tabella di riepilogo");
       if(form.getVettMotivoLavorazione() != null){
         HashMap<Long,TipoMotivoLavorazioneVO> motivoLavorazHM = new HashMap<Long,TipoMotivoLavorazioneVO>();
         for(int i=0;i<form.getVettMotivoLavorazione().size();i++){
           TipoMotivoLavorazioneVO motivoL = (TipoMotivoLavorazioneVO)form.getVettMotivoLavorazione().get(i);
           motivoLavorazHM.put(motivoL.getIdMotivoLavorazione(), motivoL);
         }
         session.setAttribute("motivoLavorazHM", motivoLavorazHM);
       }   
   }
   catch(Exception ex){
     SolmrLogger.error(this, "--- Exception in findDatiMotivoLavorazione ="+ex.getMessage());
     throw ex;
   }
   finally{
     SolmrLogger.debug(this, "   END findDatiMotivoLavorazione");
   }   
 }

 // -- Ricerca gli elemnenti per la Combo 'Uso del Suolo'
 private void findDatiUsoDelSuolo(Long idDittaUma, HttpSession session, AggiornaContoProprioFormVO form, UmaFacadeClient umaClient) throws Exception{
   SolmrLogger.debug(this, "   BEGIN findDatiUsoDelSuolo");
   try{
     SolmrLogger.debug(this, "--- ricerca degli elementi per la COMBO Uso del Suolo");  
     Vector vettUsoDelSuolo = umaClient.findUsiDelSuoloLavContoProprio(idDittaUma.toString()); 
     form.setVettUsoSuolo(vettUsoDelSuolo);
   
     // Memorizzo in una HashMap gli elementi per poter visualizzare la descrizione nella tabella di riepilogo
     SolmrLogger.debug(this, "--- Memorizzo in una HashMap gli elementi per poter visualizzare la descrizione nella tabella di riepilogo");
     if(form.getVettUsoSuolo() != null){
       HashMap<Long,String> usoDelSuoloHM = new HashMap<Long,String>();
       for(int i=0;i<form.getVettUsoSuolo().size();i++){
         CategoriaUtilizzoUmaVO cat = (CategoriaUtilizzoUmaVO)form.getVettUsoSuolo().get(i);
         usoDelSuoloHM.put(cat.getIdCategoriaUtilizzoUma(), cat.getDescrizione());
       }
       session.setAttribute("usoDelSuoloHM", usoDelSuoloHM);
    }
   }
   catch(Exception ex){
     SolmrLogger.error(this, "--- Exception in findDatiUsoDelSuolo ="+ex.getMessage());
     throw ex;
   }
   finally{
     SolmrLogger.debug(this, "   END findDatiUsoDelSuolo");
   }
 }

 private void removeAttributeFromSession(HttpSession session){
   SolmrLogger.debug(this, "   BEGIN removeAttributeFromSession");
   
   session.removeAttribute("formInserimentoCP");
   session.removeAttribute("lavContoProprioVect");
   session.removeAttribute("usoDelSuoloHM");
   session.removeAttribute("lavorazHM");
   session.removeAttribute("macchineHM");
   session.removeAttribute("isPresenteAssegnazValidata");
   session.removeAttribute("motivoLavorazHM");
   
   SolmrLogger.debug(this, "   END removeAttributeFromSession");
 }



private ValidationErrors validateInsert(HttpServletRequest request, HttpSession session, AggiornaContoProprioFormVO form, LavContoProprioVO lavContoProprioInsert, String annoCampagna, UmaFacadeClient umaFacadeClient, DittaUMAAziendaVO dittaUMAAziendaVO) throws Exception {
    SolmrLogger.debug(this, "   BEGIN validateInsert");
    ValidationErrors errors = new ValidationErrors();
       
    String usoSuolo = request.getParameter("usoSuolo");
    String idLavorazione = request.getParameter("idLavorazione");    
    String idMotivoLavoraz = request.getParameter("motivoLavorazSel");

    BigDecimal zero = new BigDecimal(0);
 
    // ----------- Controlli uso del suolo -----------
    SolmrLogger.debug(this, " --- Controlli uso del suolo");
    if (Validator.isEmpty(usoSuolo)){
      errors.add("usoSuolo", new ValidationError("Campo obbligatorio"));
    }
    else{
      SolmrLogger.debug(this, " -- Uso del suolo ="+usoSuolo);
      lavContoProprioInsert.setUsoDelSuolo(usoSuolo);
    }
    
    // Controlli Lavorazione
    SolmrLogger.debug(this, " --- Controlli Lavorazione"); 
    SolmrLogger.debug(this, "-- idLavorazione =" + idLavorazione);
    if (Validator.isEmpty(idLavorazione)){
      errors.add("idLavorazione", new ValidationError("Campo obbligatorio"));
    }
    else{
      StringTokenizer st = new StringTokenizer(idLavorazione, "|");
      if (st.hasMoreTokens()){               
        lavContoProprioInsert.setLavorazione(st.nextToken());
        SolmrLogger.debug(this, " -- Lavorazione ="+lavContoProprioInsert.getLavorazione());
      }
    }
    
    // Controlli Motivo Lavorazione
    SolmrLogger.debug(this, " --- Controlli Motivo Lavorazione");
    SolmrLogger.debug(this, " -- idMotivoLavoraz ="+idMotivoLavoraz);
    if(Validator.isEmpty(idMotivoLavoraz)){
      errors.add("idMotivoLavoraz", new ValidationError("Campo obbligatorio"));
    }
    else{
      TipoMotivoLavorazioneVO tipoMotLavVO = new TipoMotivoLavorazioneVO();
      tipoMotLavVO.setIdMotivoLavorazione(new Long(idMotivoLavoraz));
      lavContoProprioInsert.setTipoMotivoLavVO(tipoMotLavVO);
    }

    
    // Campi disabilitati : non deve essere eseguita una validazione            
    String unitaMisura = request.getParameter("unitaDiMisura");
    SolmrLogger.debug(this, "--- codice unita di misura ="+unitaMisura);
    SolmrLogger.debug(this, "--- id unita di misura ="+form.getIdUnitaMisura());    
    lavContoProprioInsert.setUnitaMisura(form.getIdUnitaMisura());
    
    String litriCarburante = request.getParameter("litriCarburante");
    SolmrLogger.debug(this, "--- litriCarburante ="+litriCarburante);
    if(litriCarburante != null && !litriCarburante.equals(""))
      lavContoProprioInsert.setLitriLavorazione(new BigDecimal(litriCarburante.replace(',', '.')));
        
    String litriBaseCalcolati = request.getParameter("litriBaseCalcolati");
    SolmrLogger.debug(this, "--- litriBaseCalcolati ="+litriBaseCalcolati);
    if(litriBaseCalcolati != null && !litriBaseCalcolati.equals(""))
      lavContoProprioInsert.setLitriBase(new BigDecimal(litriBaseCalcolati.replace(',', '.')));
     
    String litriMedioImpastoCalcolati = request.getParameter("litriMedioImpastoCalcolati");
    SolmrLogger.debug(this, "--- litriMedioImpastoCalcolati ="+litriMedioImpastoCalcolati);
    if(litriMedioImpastoCalcolati != null && !litriMedioImpastoCalcolati.equals(""))
      lavContoProprioInsert.setLitriMedioImpasto(new BigDecimal(litriMedioImpastoCalcolati.replace(',', '.')));
    
    String litriAcclivita = request.getParameter("litriAcclivita");
    SolmrLogger.debug(this, "--- litriAcclivita ="+litriAcclivita);
    if(litriAcclivita != null && !litriAcclivita.equals(""))
      lavContoProprioInsert.setLitriAcclivita(new BigDecimal(litriAcclivita.replace(',', '.')));
        

    String note = request.getParameter("note");
    SolmrLogger.debug(this, " --- Controlli Note");
    if (!StringUtils.isStringEmpty(note)){
      if (note.length() > 1000){
        errors.add("note", new ValidationError("Il valore immesso non deve superare i 1000 caratteri"));
      }
      else{
        lavContoProprioInsert.setNote(note);
      }
    }
        
    // Controlli Numero esecuzioni
    String numeroEsecuzioni = request.getParameter("numeroEsecuzioni");
    SolmrLogger.debug(this, " ----- Controlli Numero esecuzioni -----");
    SolmrLogger.debug(this, " -- numero massimo di esecuzioni ="+ form.getMaxEsecuzioni());
    SolmrLogger.debug(this, " -- Numero esecuzioni inserito =" + numeroEsecuzioni);
    long esecuzioniInput = 0;	
	if (Validator.isEmpty(numeroEsecuzioni)){
      errors.add("numeroEsecuzioni", new ValidationError("Campo obbligatorio"));
    }
    else{       
      try{
          esecuzioniInput = Long.parseLong(numeroEsecuzioni);
      }
      catch (Exception ex){
        errors.add("numeroEsecuzioni", new ValidationError("Inserire un valore numerico intero"));
      }
      if(esecuzioniInput < 0 || esecuzioniInput == 0){
          errors.add("numeroEsecuzioni", new ValidationError("Inserire un valore numerico maggiore di zero"));
      }
      else{
        // Controllo che il numero esecuzioni indicato non superi max_esecuzioni
       	if(!StringUtils.isStringEmpty(form.getMaxEsecuzioni())){
       	    SolmrLogger.debug(this, "--- controllare che non sia stato inserito un numero > del massimo consentito");
       	    long maxEsecuzioni = Long.parseLong(form.getMaxEsecuzioni());
		    SolmrLogger.debug(this, " -- numero massimo di esecuzioni ="+maxEsecuzioni);
		    SolmrLogger.debug(this, " -- numero esecuzioni indicato ="+esecuzioniInput);
	        if (esecuzioniInput > maxEsecuzioni){
	          errors.add("numeroEsecuzioni", new ValidationError("Non è possibile aumentare il valore del numero esecuzioni"));
	        }
	        else{
	          SolmrLogger.debug(this, "--- Numero esecuzioni = "+numeroEsecuzioni);
	          lavContoProprioInsert.setNumEsecuzioni(numeroEsecuzioni);
	        }
	    }  
	    else{
	      SolmrLogger.debug(this, "--- Numero esecuzioni = "+numeroEsecuzioni);
	      lavContoProprioInsert.setNumEsecuzioni(numeroEsecuzioni);
	    }
      }      
    }
    
    
    
    // Controlli legati all'unità di misura -> Selezione della macchina
    String macchinaUtilizzata = request.getParameter("idMacchina");
    SolmrLogger.debug(this, " ----- Controlli legati all'unità di misura  -----");
    if(!StringUtils.isStringEmpty(form.getTipoUnitaMisura()) && form.getTipoUnitaMisura().equalsIgnoreCase("T")){
      SolmrLogger.debug(this, " -- CASO unita' di misura = T");            
      SolmrLogger.debug(this, " --- Controlli sul campo Macchina");
      SolmrLogger.debug(this, " -- idMacchina ="+ macchinaUtilizzata);
      if (Validator.isEmpty(macchinaUtilizzata)){
        errors.add("idMacchina", new ValidationError("Campo obbligatorio"));
      }
      else
      {
        StringTokenizer token = new StringTokenizer(macchinaUtilizzata, "|");
        lavContoProprioInsert.setIdMacchina(token.nextToken());
        SolmrLogger.debug(this, " ---- idMacchina memorizzato ="+ lavContoProprioInsert.getIdMacchina());
      }
    }
	
	     
    // -- ** Controllo campo 'Sup(ha)/Ore' ** --
    String supOreStr = request.getParameter("supOreStr");          
    SolmrLogger.debug(this, "-- supOreStr =" + supOreStr); 
    SolmrLogger.debug(this, "-- idLavorazione =" + idLavorazione);
    
    // ---- Controlli sul campo Sup(ha) / Ore
    //if(idLavorazione != null && !idLavorazione.trim().equals("")){	        
      // Se non ci sono errori sul campo 'Numero esecuzioni'
      //if(errors.get("numeroEsecuzioni") == null){	       
       SolmrLogger.debug(this, "---- Controlli sul campo Sup.(ha)/Ore");
	   if (Validator.isEmpty(supOreStr)){
	     errors.add("supOreStr", new ValidationError("Campo obbligatorio"));
	     form.setSuperficieCalcolata(null);	     
	   }
	   else{	
	     try{	        
	        // se prima il campo 'Sup(Ore)/ha' è stato ripulito, ricalcolare la max superficie
	        if(form.getSuperficieCalcolata() == null||SolmrConstants.TIPO_UNITA_MISURA_M.equalsIgnoreCase(form.getTipoUnitaMisura())){
	          // --------- CALCOLO DELLA SUPERFICIE da proporre nel campo 'Sup(ha)/Ore'	    	  
	          // Recupero il CODICE_MOTIVO_LAVORAZIONE, dato l'idMotivoLavorazione selezionato nella combo
			 HashMap<Long,TipoMotivoLavorazioneVO> motivoLavHm = (HashMap<Long,TipoMotivoLavorazioneVO>)session.getAttribute("motivoLavorazHM");
			 String idMotivoLavorazSel = form.getIdMotivoLavorazione();
			 SolmrLogger.debug(this, "--- idMotivoLavorazSel ="+idMotivoLavorazSel);
			 TipoMotivoLavorazioneVO tipoMotLavVO = motivoLavHm.get(new Long(idMotivoLavorazSel));
			 String codiceMotivoLavoraz = tipoMotLavVO.getCodiceMotivoLavorazione();
			 SolmrLogger.debug(this, "--- codiceMotivoLavoraz ="+codiceMotivoLavoraz);  				    	    
		     BigDecimal superficie = umaFacadeClient.getSuperficieInsLavCP(dittaUMAAziendaVO.getIdDittaUMA(), dittaUMAAziendaVO.getIdAzienda(), form.getIdLavorazone(), form.getIdUsoSuolo(), form.getAnnoCampagna(), form.getFlagAsservimento(), codiceMotivoLavoraz);		
		     SolmrLogger.debug(this, " ----- Superficie totale calcolata ="+superficie);   
		       	   
		     form.setSuperficieCalcolata("" + superficie);
	        }	        
	        BigDecimal supOre = new BigDecimal(supOreStr.replace(',', '.'));	        

			// -------- CASO TIPO_MISURA = 'S'	        
	        if (!StringUtils.isStringEmpty(form.getSuperficieCalcolata())
	            && SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(form.getTipoUnitaMisura())){
	          SolmrLogger.debug(this, "--  CASO TIPO_MISURA = 'S' --");
	          BigDecimal superficieCalcolataBd = new BigDecimal(form.getSuperficieCalcolata().replace(',', '.'));
	          
	          // La superficie indicata non deve superare quella che è stata calcolata	 
	          SolmrLogger.debug(this, "-- superficie indicata dall'utente ="+supOreStr);  
	          SolmrLogger.debug(this, "--- superficie calcolata ="+ form.getSuperficieCalcolata() + "%");           
	          if (supOre.compareTo(superficieCalcolataBd) > 0){	            
	             errors.add("supOreStr", new ValidationError("La superficie indicata non può essere maggiore della superficie calcolata in base all''uso del suolo e al motivo della lavorazione ("+StringUtils.formatDouble4(superficieCalcolataBd)+")"));
	          }	
	        }
	     	// -------- CASO TIPO_MISURA = 'K'
	        if (!StringUtils.isStringEmpty(form.getSuperficieCalcolata())
              && SolmrConstants.TIPO_UNITA_MISURA_K.equalsIgnoreCase(form.getTipoUnitaMisura())){
            SolmrLogger.debug(this, "--  CASO TIPO_MISURA = 'K' --");
            BigDecimal superficieCalcolataBd = new BigDecimal(form.getSuperficieCalcolata().replace(',', '.'));
            
            // La superficie indicata non deve superare quella che è stata calcolata   
            SolmrLogger.debug(this, "-- potenza indicata dall'utente ="+supOreStr);  
            SolmrLogger.debug(this, "--- potenza calcolata ="+ form.getSuperficieCalcolata() + "%");           
            if (supOre.compareTo(superficieCalcolataBd) > 0){             
               errors.add("supOreStr", new ValidationError("La potenza indicata non può essere maggiore della potenza calcolata in base all''uso del suolo e al motivo della lavorazione ("+StringUtils.formatDouble4(superficieCalcolataBd)+")"));
            } 
          }
	      // -------- CASO TIPO_MISURA = 'M'	
	      if (SolmrConstants.TIPO_UNITA_MISURA_M.equalsIgnoreCase(form.getTipoUnitaMisura())){
	            SolmrLogger.debug(this, "--  CASO TIPO_MISURA = 'M' --");
	            BigDecimal superficieCalcolataBd = new BigDecimal(form.getSuperficieCalcolata().replace(',', '.'));
	            superficieCalcolataBd = superficieCalcolataBd.multiply(new BigDecimal(SolmrConstants.MAX_METRO_L));
		        SolmrLogger.debug(this, "--- max superficie per metro lineare ="+ superficieCalcolataBd);           
	            if(supOre.compareTo(superficieCalcolataBd)>0){
		          errors.add("supOreStr", new ValidationError("La lunghezza indicata non può essere maggiore di "+StringUtils.formatDouble4(superficieCalcolataBd)+" metri"));
         		}
	      }
	      
	        // Non è possibile inserire un valore negativo
	        if (supOre.compareTo(zero) < 0){
	          errors.add("supOreStr", new ValidationError("Non è possibile inserire un valore negativo"));
	        }
	        // Non è possibile inserire il valore zero
	        String supOreFormattata = NumberUtils.formatDouble4(supOreStr, true);
	        if(supOreFormattata.equals("0,0000")){
	          errors.add("supOreStr", new ValidationError("Deve essere inserito un valore maggiore di zero"));
	        }
	        else if (!Validator.validateDoubleDigit(supOreStr, 10, 4)){
	            errors.add("supOreStr", new ValidationError("Il valore può avere al massimo 10 cifre intere e 4 decimali"));	            
	        }
	        else{  
	          SolmrLogger.debug(this, "--- Memorizzo superficie ="+supOre);          
	          lavContoProprioInsert.setSuperficie(supOre);	          	                 
	        }
	      }
	      catch (Exception ex){	        
	        errors.add("supOreStr", new ValidationError("Campo non numerico"));
	      }
	     }
	  

   
    // ----- Controllo se ci sono già altre lavorazioni con gli stessi dati inseriti sul db
    if (errors.size()==0){
       SolmrLogger.debug(this, "--- Controllare se ci sono già altre lavorazioni sul db con gli stessi dati di quella che si sta per aggiungere in riepilogo");	    	
       
       LavContoProprioFilter lavorazioniFilter = new LavContoProprioFilter();
       lavorazioniFilter.setIdDittaUma(dittaUMAAziendaVO.getIdDittaUMA());
       lavorazioniFilter.setAnnoDiRiferimento(form.getAnnoCampagna());
       lavorazioniFilter.setIdUsoDelSuolo(form.getIdUsoSuolo());
       lavorazioniFilter.setIdLavorazione(form.getIdLavorazone());
       lavorazioniFilter.setIdMotivoLavorazione(form.getIdMotivoLavorazione());
               
       String countLavorazioniCP = umaFacadeClient.countLavorazContoProprioByFilter(lavorazioniFilter);    	
       SolmrLogger.debug(this, "- countLavorazioniCP ="+countLavorazioniCP);
    	
    	if(new Long(countLavorazioniCP).longValue()>0){
    	    SolmrLogger.debug(this, "--- Ci sono gia lavorazioni con gli stessi dati!");
    	    String msgNumeroMaxLavorazioniConsentite = "Per il motivo della lavorazione e per l''uso del suolo indicati e'' gia'' presente una lavorazione. Impossibile procedere con l''inserimento.";    		
    		errors.add("usoSuolo", new ValidationError(msgNumeroMaxLavorazioniConsentite));
    		errors.add("idLavorazione", new ValidationError(msgNumeroMaxLavorazioniConsentite));
    		errors.add("idMotivoLavoraz", new ValidationError(msgNumeroMaxLavorazioniConsentite));
    	}    	
    }
    // ------- Controllo che nella tabella di riepilogo non ci sia già una lavorazione con gli stessi dati inseriti nella pagina
    if(errors.size() == 0){
      SolmrLogger.debug(this, "--- Controllo che nella tabella di riepilogo non ci sia già una lavorazione con gli stessi dati inseriti (controllo sugli stessi campi sopra)");
      String idUsoDelSuolo = form.getIdUsoSuolo();
      String idLav = form.getIdLavorazone();    
      String idMotivoLavorazione = form.getIdMotivoLavorazione();  
      
      int posizioneLavorazioneGiaPresente = -1;            
      posizioneLavorazioneGiaPresente = controlloPresenzaLavRiepilogo(idUsoDelSuolo,idLav, idMotivoLavorazione, session);
            
      SolmrLogger.debug(this, "-- posizioneLavorazioneGiaPresente ="+posizioneLavorazioneGiaPresente);
      if(posizioneLavorazioneGiaPresente > -1){
        SolmrLogger.debug(this, "-- La lavorazione e' gia' presente nella tabella di riepilogo!");
        String msgNumeroMaxLavorazioniConsentite = "Per il motivo della lavorazione e per l''uso del suolo indicati la lavorazione e'' gia'' presente nella tabella di riepilogo. Impossibile procedere con l''inserimento.";    	
    	errors.add("usoSuolo", new ValidationError(msgNumeroMaxLavorazioniConsentite));
    	errors.add("idLavorazione", new ValidationError(msgNumeroMaxLavorazioniConsentite));
    	errors.add("idMotivoLavoraz", new ValidationError(msgNumeroMaxLavorazioniConsentite));
      }      
    }    

    request.setAttribute("vLavContoProprio", lavContoProprioInsert);
    
    SolmrLogger.debug(this, "   END validateInsert");
    return errors;
  }
  
  
  // Controlla se esiste già nella tabella di riepilogo un'altra lavorazione con gli stessi : idUsoDelSuolo, idLavorazione e idMotivoLavorazione
  private int controlloPresenzaLavRiepilogo(String idUsoDelSuolo, String idLav, String idMotivoLavorazione, HttpSession session) throws Exception{
    SolmrLogger.debug(this, "   BEGIN controlloPresenzaLavRiepilogo");
    
    int posizioneLavorazioneGiaPresente = -1;
    // Recupero dalla sessione il vettore con gli elementi della tabella di riepilogo
    Vector<LavContoProprioVO> lavContoProprioVect = (Vector<LavContoProprioVO>)session.getAttribute("lavContoProprioVect");
    if(lavContoProprioVect != null && lavContoProprioVect.size()>0){
      SolmrLogger.debug(this, "-- ci sono delle lavorazioni nella tabella di riepilogo, controllare che non ce ne siano gia' con gli stessi dati inseriti");
      for(int i=0;i<lavContoProprioVect.size();i++){
        LavContoProprioVO lavoraz = lavContoProprioVect.get(i);
                
        long idUsoSuoloRiep = new Long(lavoraz.getUsoDelSuolo()).longValue();
        long idLavorazRiep = new Long(lavoraz.getLavorazione()).longValue();  
        long idMotivoLavorazRiep = lavoraz.getTipoMotivoLavVO().getIdMotivoLavorazione().longValue();      
          
        long idUsoSuolo = new Long(idUsoDelSuolo).longValue();
        long idLavoraz = new Long(idLav).longValue();
        long idMotivloLavoraz = new Long(idMotivoLavorazione).longValue();
          
       if(idUsoSuoloRiep == idUsoSuolo && idLavorazRiep == idLavoraz && idMotivoLavorazRiep == idMotivloLavoraz){
         SolmrLogger.debug(this, "-- esiste gia' una lavorazione nel riepilogo con gli stessi dati");
         posizioneLavorazioneGiaPresente = i;
         return posizioneLavorazioneGiaPresente;
       }          
    } 
   }    
   SolmrLogger.debug(this, "   END controlloPresenzaLavRiepilogo");
   return posizioneLavorazioneGiaPresente;
 }
  


  private int validazioniConLavorazDb(HttpSession session, HttpServletRequest request, DittaUMAAziendaVO dittaUMAAziendaVO, String annoCampagna, UmaFacadeClient umaFacadeClient) throws Exception{
    SolmrLogger.debug(this, "   BEGIN validazioniConLavorazDb");
    
    int posizioneElementoNonValido = -1;    
    Vector<LavContoProprioVO> lavContoProprioVect = (Vector<LavContoProprioVO>)session.getAttribute("lavContoProprioVect");
    
    // Ciclo sulle lavorazioni presenti nella tabella di riepilogo
    for(int i=0;i<lavContoProprioVect.size();i++){
        // ----- Lavorazione da controllare
        LavContoProprioVO lav = lavContoProprioVect.get(i);
    
	    // --- 1)  Controllare che nessuna delle lavorazioni presenti nella tabella di riepilogo siano state già inserite sul db
	    SolmrLogger.debug(this, "-- 1) Controllare che nessuna delle lavorazioni presenti nella tabella di riepilogo siano state già inserite sul db");
	    boolean lavorazDuplicata = controlloPresenzaLavorazioneSuDb(lav,dittaUMAAziendaVO,annoCampagna,umaFacadeClient);
	    SolmrLogger.debug(this, "-- lavorazDuplicata = "+lavorazDuplicata);
	    if(lavorazDuplicata)
	       posizioneElementoNonValido = i;	
		if(posizioneElementoNonValido > -1){
		  SolmrLogger.debug(this, "-- Nella tabella di riepilogo c'è una lavorazione già presente sul db!");
		 
		  ValidationErrors errors = new ValidationErrors();
	      String msg = "Per uso del suolo e lavorazione indicati e'' gia'' presente una lavorazione. Impossibile procedere con l''inserimento.";
	      errors.add("idLavContoProprio_"+new Integer(posizioneElementoNonValido).toString(), new ValidationError(msg));
		  
		  request.setAttribute("errors", errors); 
		  SolmrLogger.debug(this, "   END validazioniConLavorazDb"); 
		  return posizioneElementoNonValido;                 
	    }
	    // se la lavorazione non è duplicata
	    else{
	      /* 2) Controllare se ci sono delle lavorazioni vincolate (madre/figlia), se ce ne sono, 
	             devono rispettare il vincolo indicato in DB_LEGAME_LAVORAZIONE
	       */
	       SolmrLogger.debug(this, "-- 2) Controllare se ci sono delle lavorazioni vincolate (madre/figlia)");
	       String descrLavorazioneCollegataNonTrovata = controlloLavorazioniVincolate(session,lav,dittaUMAAziendaVO,annoCampagna,umaFacadeClient);
	       SolmrLogger.debug(this, "-- descrLavorazioneCollegataNonTrovata = "+descrLavorazioneCollegataNonTrovata);
	       if(descrLavorazioneCollegataNonTrovata != null && !descrLavorazioneCollegataNonTrovata.trim().equals(""))
	         posizioneElementoNonValido = i;
	       if(posizioneElementoNonValido > -1){
		     SolmrLogger.debug(this, "-- Non è stata rispettata la regola delle lavorazioni vincolate (madre/figlia)");
		     ValidationErrors errors = new ValidationErrors();
		     String msg = "Per il motivo della lavorazione e l''uso del suolo indicati la lavorazione selezionata non può essere inserita in assenza della lavorazione "+descrLavorazioneCollegataNonTrovata;
		     errors.add("idLavContoProprio_"+new Integer(posizioneElementoNonValido).toString(), new ValidationError(msg));
		  
		     request.setAttribute("errors", errors); 
		     SolmrLogger.debug(this, "   END validazioniConLavorazDb"); 
		     return posizioneElementoNonValido; 
		   }
		   // se i controlli delle lavorazioni vincolate è andato a buon fine
		   else{
		     /* 3) Controllo se ci sono delle lavorazioni alternative, se ce ne sono,
		           non devono essere presenti nella tabella di riepilogo e sul db
		      */
		      SolmrLogger.debug(this, "-- 3) Controllare se ci sono delle lavorazioni alternative");
		      String descrLavorazioneCollegataTrovata = controlloLavorazioniAlternative(session,lav,dittaUMAAziendaVO,annoCampagna,umaFacadeClient);
		      if(descrLavorazioneCollegataTrovata != null && !descrLavorazioneCollegataTrovata.trim().equals(""))
	            posizioneElementoNonValido = i;
	          if(posizioneElementoNonValido > -1){
		        SolmrLogger.debug(this, "-- Non è stata rispettata la regola delle lavorazioni alternative");
		        ValidationErrors errors = new ValidationErrors();
		        String msg = "Per il  motivo della lavorazione e per l''uso del suolo indicati la lavorazione selezionata non può essere inserita in presenza della lavorazione "+descrLavorazioneCollegataTrovata;
		        errors.add("idLavContoProprio_"+new Integer(posizioneElementoNonValido).toString(), new ValidationError(msg));
		  
		        request.setAttribute("errors", errors); 
		        SolmrLogger.debug(this, "   END validazioniConLavorazDb"); 
		        return posizioneElementoNonValido; 
		      }
		      // se i controlli delle lavorazioni alternative è andato a buon fine
		      else{
				SolmrLogger.debug(this, "-- 4) Controllare la linea di lavorazione");
		        String descrLineaLavoraz = controlloLineaLavorazione(session,lav,dittaUMAAziendaVO,annoCampagna,umaFacadeClient);
		        if(descrLineaLavoraz != null && !descrLineaLavoraz.trim().equals(""))
	            posizioneElementoNonValido = i;
	            if(posizioneElementoNonValido > -1){
			        SolmrLogger.debug(this, "-- Non è stata rispettata la regola della linea di lavorazione");
			        ValidationErrors errors = new ValidationErrors();
			        String msg = "Per il motivo di lavorazione e per l''uso del suolo indicati la lavorazione selezionata fa parte di in una linea di lavorazione ("+descrLineaLavoraz+") non compatibile con una o più lavorazioni già presenti, a loro volta collegate a differenti linee di lavorazione";
			        errors.add("idLavContoProprio_"+new Integer(posizioneElementoNonValido).toString(), new ValidationError(msg));
			  
			        request.setAttribute("errors", errors); 
			        SolmrLogger.debug(this, "   END validazioniConLavorazDb"); 
			        return posizioneElementoNonValido; 
		        }
		      }  
		   }   	            
	    }
    }// CHIUSURA CICLO LAVORAZIONI presenti nella tabella di riepilogo
    
    
    SolmrLogger.debug(this, "   END validazioniConLavorazDb");
    return posizioneElementoNonValido;
  }
  
  
  /* Controllo se la lavorzione passata in input (della tabella di riepilogo)
     ricade in UNA SOLA linea di lavorazione per l'uso del suolo indicato
     Se si, viene verificato che non siano state caricate lavorazioni di altre linee di lavorazione per lo stesso uso del suolo e motivo lavorazione
  */
  private String controlloLineaLavorazione(HttpSession session, LavContoProprioVO lav, DittaUMAAziendaVO dittaUMAAziendaVO, String annoCampagna, UmaFacadeClient umaFacadeClient) throws Exception{
    SolmrLogger.debug(this, "   BEGIN controlloLineaLavorazione");
    
    String descrLineaDiLavoraz = "";
    // -- Controllo se per l'uso del suolo e la lavorazione è prevista UNA linea di lavorazione
    SolmrLogger.debug(this, "--- Controllo se per l'uso del suolo e la lavorazione è prevista UNA linea di lavorazione");
    Vector<CodeDescr> elencoLineeDiLavoraz = umaFacadeClient.getLineeLavorazByFilter(new Long(lav.getLavorazione()),new Long(lav.getUsoDelSuolo()));
    if(elencoLineeDiLavoraz != null && elencoLineeDiLavoraz.size()==1){
      SolmrLogger.debug(this, "-- è stata trovata UNA linea di lavorazione, controllare che non siano state inserite delle lavorazioni con lo stesso uso del suolo e linea di lavorazione diversa");            
      
      // -- Controllare che non siano state inserite delle lavorazioni con stesso uso del suolo e diversa linea di lavorazione           
      int idLineaLav = elencoLineeDiLavoraz.get(0).getCode().intValue();
      SolmrLogger.debug(this, "--- *** idLineaLav ="+idLineaLav);     
      
      // -> controllo sulla tabella di riepilogo
      Vector<LavContoProprioVO> lavContoProprioVect = (Vector<LavContoProprioVO>)session.getAttribute("lavContoProprioVect");
      boolean lineaLavorazioneDiversa = false;
      // --- Ciclo sulle lavorazioni del riepilogo
      for(int j=0;j<lavContoProprioVect.size();j++){
        LavContoProprioVO lavRiep = lavContoProprioVect.get(j);
        // ricerco se ci sono delle lavorazioni legate ad UNA SOLA linea di lavorazione e se questa linea è diversa da quella in esame, in tal caso -> ERRORE
        Vector<CodeDescr> elencoLineeDiLavorazTabRiep = umaFacadeClient.getLineeLavorazByFilter(new Long(lavRiep.getLavorazione()) ,new Long(lavRiep.getUsoDelSuolo()));
        
        if(elencoLineeDiLavorazTabRiep != null && elencoLineeDiLavorazTabRiep.size()==1){          
          /* Il controllo si deve effettuare solo se :
              idMotivoLavorazione, idLavorazioni, idUsoDelSuolo
              della tab di riepilogo sono uguali a quelli che si stanno analizzando all'interno della tabella di riepilogo
              Solo in quel caso la linea di lavorazione deve essere la stessa
          */
          if( (new Long(lav.getLavorazione()).longValue() == new Long(lavRiep.getLavorazione()).longValue()) &&
              (new Long(lav.getUsoDelSuolo()).longValue() == new Long(lavRiep.getUsoDelSuolo()).longValue()) &&
              (lav.getTipoMotivoLavVO().getIdMotivoLavorazione().longValue() == lavRiep.getTipoMotivoLavVO().getIdMotivoLavorazione().longValue())
            ){
	          SolmrLogger.debug(this, "--- Controllare se la linea di lavorazione è uguale o no");
	          int idLineaLavTabRiep = elencoLineeDiLavorazTabRiep.get(0).getCode().intValue();
	          SolmrLogger.debug(this, "--- *** idLineaLavTabRiep ="+idLineaLavTabRiep);
	          if(idLineaLav != idLineaLavTabRiep){
	            SolmrLogger.debug(this, "--- La linea di lavorazione è diversa!");
	            lineaLavorazioneDiversa = true;
	            break;
	          }
          }
        }        
      }  // chiusura ciclo sugli elementi della tabella di riepilogo
      
      // -> Non sono state trovate delle linee di lavorazione diverse, controllo sul DB
      if(!lineaLavorazioneDiversa){
        SolmrLogger.debug(this, " ---- Non sono state trovate delle linee di lavorazione diverse, controllo sul DB");
        Integer countLineeDiLavDiverse = umaFacadeClient.countLavorazCpPerLineaLavorazDiversa(dittaUMAAziendaVO.getIdDittaUMA(), new Long(lav.getAnnoCampagna()), new Integer(idLineaLav), new Long(lav.getUsoDelSuolo()), lav.getTipoMotivoLavVO().getIdMotivoLavorazione());
        if(countLineeDiLavDiverse != null && countLineeDiLavDiverse.intValue()>0){
          SolmrLogger.debug(this, "--- Sono state trovate delle linee di lavorazione diverse per l'ID_CATEGORIA_UTILIZZO_UMA ="+lav.getUsoDelSuolo()+". Numero di LINEE LAVORAZIONE DIVERSE SUL DB ="+countLineeDiLavDiverse);
          lineaLavorazioneDiversa = true;
        }
      }
      
      
      if(lineaLavorazioneDiversa){
        SolmrLogger.debug(this, " ---- E' stata trovata una Linea di lavorazione diversa");
        descrLineaDiLavoraz = elencoLineeDiLavoraz.get(0).getDescription();
        SolmrLogger.debug(this, "--- *** descrLineaDiLavoraz ="+descrLineaDiLavoraz);
        SolmrLogger.debug(this, "   END controlloLineaLavorazione");
        return descrLineaDiLavoraz;
      }
      
    }// Caso : una linea di lavorazione legata alla lavorazione in esame    
    
    SolmrLogger.debug(this, "   END controlloLavorazioniAlternative");
    return descrLineaDiLavoraz;
  }


  /* Controllo se la lavorazione passata in input è una lavorazione alternativa, in questo caso
     non deve essere già presente su db o sulla tabella di riepilogo una o più delle lavorazioni alternative a quella indicata
     // -> torna la descrizione della lavorazione alternativa trovata 
  */
  private String controlloLavorazioniAlternative(HttpSession session, LavContoProprioVO lav, DittaUMAAziendaVO dittaUMAAziendaVO, String annoCampagna, UmaFacadeClient umaFacadeClient) throws Exception{
    SolmrLogger.debug(this, "   BEGIN controlloLavorazioniAlternative");
    
    String descrLavorazTrovata = "";
    Long idTipoLegameLavoraz = new Long(SolmrConstants.ID_TIPO_LEGAME_LAVORAZ_ALTERNATIVE);
    Vector<CodeDescr> lavorazioniCollegate = umaFacadeClient.getLavorazioniCollegateByFilter(new Long(lav.getLavorazione()), new Long(lav.getUsoDelSuolo()), idTipoLegameLavoraz);
    
    // Sono stati trovati degli ID_LAVORAZIONE_COLLEGATA
    if(lavorazioniCollegate != null && lavorazioniCollegate.size()>0){
      SolmrLogger.debug(this, " -- Sono stati trovati degli ID_LAVORAZIONE_COLLEGATA, controllare che non siano presenti");
      SolmrLogger.debug(this, " -- Numero di ID_LAVORAZIONE_COLLEGATA da controllare ="+lavorazioniCollegate.size());     
    
      // --- Ciclo sugli ID_LAVORAZIONE_COLLEGATA
      for(int i = 0;i<lavorazioniCollegate.size();i++){
        CodeDescr lavorazioneCollegata = lavorazioniCollegate.get(i); 
        Long idLavorazioneCollegata = lavorazioneCollegata.getCode().longValue();
        
        SolmrLogger.debug(this, " -- *** idLavorazioneCollegata da cercare ="+idLavorazioneCollegata);
        SolmrLogger.debug(this, " -- *** idCategoriaUtilizzoUma da cercare ="+lav.getUsoDelSuolo());
        
        // Controllo se la lavorazione è presente nella tabella di riepilogo        
        Vector<LavContoProprioVO> lavContoProprioVect = (Vector<LavContoProprioVO>)session.getAttribute("lavContoProprioVect");
        boolean lavorazAlternativaTrovata = false;
        
        // --- Ciclo sulle lavorazioni del riepilogo
        for(int j=0;j<lavContoProprioVect.size();j++){
          LavContoProprioVO lavRiep = lavContoProprioVect.get(j);
          // Controllo se idLavorazione e uso del suolo coincidono
          if( (new Long(lavRiep.getLavorazione()).longValue() == idLavorazioneCollegata.longValue()) &&
              (new Long(lavRiep.getUsoDelSuolo()).longValue() == new Long(lav.getUsoDelSuolo()).longValue()) &&
              (lavRiep.getTipoMotivoLavVO().getIdMotivoLavorazione().longValue() == lav.getTipoMotivoLavVO().getIdMotivoLavorazione().longValue())
             ){
            SolmrLogger.debug(this, " -- Lavorazione ALTERNATIVA trovata nel riepilogo"); 
            lavorazAlternativaTrovata = true;
            break;
          }
        }// fine ciclo Lavorazioni del riepilogo
                
        // Se l'ID_LAVORAZIONE_COLLEGATA non è stata trovata nella tab di riepilogo, la cerco sul db
        if(!lavorazAlternativaTrovata){
          SolmrLogger.debug(this, " -- La lavorazione MADRE non è stata trovata nel riepilogo, la cerco sul db");
          LavContoProprioFilter lavFilter = new LavContoProprioFilter();
          lavFilter.setIdDittaUma(dittaUMAAziendaVO.getIdDittaUMA());
          lavFilter.setAnnoDiRiferimento(annoCampagna);
          lavFilter.setIdUsoDelSuolo(lav.getUsoDelSuolo()); // id_categoria_utilizzo_uma della lavorazione in esame
          lavFilter.setIdMotivoLavorazione(lav.getTipoMotivoLavVO().getIdMotivoLavorazione().toString());
          lavFilter.setIdLavorazione(idLavorazioneCollegata.toString()); // ID_LAVORAZIONE_COLLEGATA
          String countLavorazTrovate = umaFacadeClient.countLavorazContoProprioByFilter(lavFilter);
          if(countLavorazTrovate != null && new Long(countLavorazTrovate).longValue()>0){
            SolmrLogger.debug(this, " -- Lavorazione ALTERNATIVA trovata sul DB");
            lavorazAlternativaTrovata = true;            
          }
        }
        
        // Se l'ID_LAVORAZIONE_COLLEGATA (alternativa) è stata trovata -> mi fermo e do errore
        SolmrLogger.debug(this, " -- lavorazAlternativaTrovata ="+lavorazAlternativaTrovata);
        if(lavorazAlternativaTrovata){
          SolmrLogger.debug(this, " -- La lavorazione ALTERNATIVA è stata trovata, ERRORE");
          descrLavorazTrovata = lavorazioneCollegata.getDescription();
          SolmrLogger.debug(this, " -- descrLavorazTrovata ="+descrLavorazTrovata);
          SolmrLogger.debug(this, "   END controlloLavorazioniAlternative");
          return descrLavorazTrovata;
        }
        
      }// fine ciclo ID_LAVORAZIONE_COLLEGATA da controllare se presenti
    }
    
    SolmrLogger.debug(this, " -- descrLavorazTrovata ="+descrLavorazTrovata);
    SolmrLogger.debug(this, "   END controlloLavorazioniAlternative");
    return descrLavorazTrovata;  
  }
  


  /* Controllo se la lavorazione passata in input ha il legame di vincolo, in questo caso le madri devono essere presenti sul db o sulla tabella di riepilogo
   -> torna la descrizione della lavorazione che non è stata trovata
  */ 
  private String controlloLavorazioniVincolate(HttpSession session, LavContoProprioVO lav, DittaUMAAziendaVO dittaUMAAziendaVO, String annoCampagna, UmaFacadeClient umaFacadeClient) throws Exception{
    SolmrLogger.debug(this, "   BEGIN controlloLavorazioniVincolate");
    
    String descrLavorazNonTrovata = "";
    Long idTipoLegameLavoraz = new Long(SolmrConstants.ID_TIPO_LEGAME_LAVORAZ_VINCOLATE);
    Vector<CodeDescr> lavorazioniCollegate = umaFacadeClient.getLavorazioniCollegateByFilter(new Long(lav.getLavorazione()), new Long(lav.getUsoDelSuolo()), idTipoLegameLavoraz);
    
    // Sono stati trovati degli ID_LAVORAZIONE_COLLEGATA
    if(lavorazioniCollegate != null && lavorazioniCollegate.size()>0){
      SolmrLogger.debug(this, " -- Sono stati trovati degli ID_LAVORAZIONE_COLLEGATA, controllare se sono già presenti");
      SolmrLogger.debug(this, " -- Numero di ID_LAVORAZIONE_COLLEGATA da controllare ="+lavorazioniCollegate.size());     
    
      // --- Ciclo sugli ID_LAVORAZIONE_COLLEGATA
      for(int i = 0;i<lavorazioniCollegate.size();i++){
        CodeDescr lavorazioneCollegata = lavorazioniCollegate.get(i); 
        Long idLavorazioneCollegata = lavorazioneCollegata.getCode().longValue();
        
        SolmrLogger.debug(this, " -- *** idLavorazioneCollegata da cercare ="+idLavorazioneCollegata);
        SolmrLogger.debug(this, " -- *** idCategoriaUtilizzoUma da cercare ="+lav.getUsoDelSuolo());
        
        // Controllo se la lavorazione è presente nella tabella di riepilogo        
        Vector<LavContoProprioVO> lavContoProprioVect = (Vector<LavContoProprioVO>)session.getAttribute("lavContoProprioVect");
        boolean lavorazMadreTrovata = false;
        
        // --- Ciclo sulle lavorazioni del riepilogo
        for(int j=0;j<lavContoProprioVect.size();j++){
          LavContoProprioVO lavRiep = lavContoProprioVect.get(j);
          // Controllo se idLavorazione e uso del suolo coincidono
          if( (new Long(lavRiep.getLavorazione()).longValue() == idLavorazioneCollegata.longValue()) &&
              (new Long(lavRiep.getUsoDelSuolo()).longValue() == new Long(lav.getUsoDelSuolo()).longValue()) &&
              (lavRiep.getTipoMotivoLavVO().getIdMotivoLavorazione().longValue() == lav.getTipoMotivoLavVO().getIdMotivoLavorazione().longValue())
             ){
            SolmrLogger.debug(this, " -- Lavorazione MADRE trovata nel riepilogo"); 
            lavorazMadreTrovata = true;
            break;
          }
        }// fine ciclo Lavorazioni del riepilogo
        
        // Se l'ID_LAVORAZIONE_COLLEGATA non è stata trovata nella tab di riepilogo, la cerco sul db
        if(!lavorazMadreTrovata){
          SolmrLogger.debug(this, " -- La lavorazione MADRE non è stata trovata nel riepilogo, la cerco sul db");
          LavContoProprioFilter lavFilter = new LavContoProprioFilter();
          lavFilter.setIdDittaUma(dittaUMAAziendaVO.getIdDittaUMA());
          lavFilter.setAnnoDiRiferimento(annoCampagna);
          lavFilter.setIdUsoDelSuolo(lav.getUsoDelSuolo()); // id_categoria_utilizzo_uma della lavorazione in esame
          lavFilter.setIdMotivoLavorazione(lav.getTipoMotivoLavVO().getIdMotivoLavorazione().toString());
          lavFilter.setIdLavorazione(idLavorazioneCollegata.toString()); // ID_LAVORAZIONE_COLLEGATA
          String countLavorazTrovate = umaFacadeClient.countLavorazContoProprioByFilter(lavFilter);
          if(countLavorazTrovate != null && new Long(countLavorazTrovate).longValue()>0){
            SolmrLogger.debug(this, " -- Lavorazione MADRE trovata sul DB");
            lavorazMadreTrovata = true;            
          }
        }
        
        // Se l'ID_LAVORAZIONE_COLLEGATA non è stata trovata neanche sul db -> mi fermo e do errore
        SolmrLogger.debug(this, " -- lavorazMadreTrovata ="+lavorazMadreTrovata);
        if(!lavorazMadreTrovata){
          SolmrLogger.debug(this, " -- La lavorazione MADRE non è stata trovata neanche sul db, ERRORE");
          descrLavorazNonTrovata = lavorazioneCollegata.getDescription();
          SolmrLogger.debug(this, " -- descrLavorazNonTrovata ="+descrLavorazNonTrovata);
          SolmrLogger.debug(this, "   END controlloLavorazioniVincolate");
          return descrLavorazNonTrovata;
        }
        
      }// fine ciclo ID_LAVORAZIONE_COLLEGATA da controllare se presenti
    }
    
    SolmrLogger.debug(this, " -- descrLavorazNonTrovata ="+descrLavorazNonTrovata);
    SolmrLogger.debug(this, "   END controlloLavorazioniVincolate");
    return descrLavorazNonTrovata;    
  }


  // ----- Controlla se la lavorazione passata in input è già presente sul db
  private boolean controlloPresenzaLavorazioneSuDb(LavContoProprioVO lav, DittaUMAAziendaVO dittaUMAAziendaVO, String annoCampagna, UmaFacadeClient umaFacadeClient) throws Exception{
    SolmrLogger.debug(this, "   BEGIN controlloPresenzaLavorazioneSuDb");
    boolean isLavorazDuplicata = false;
    
    LavContoProprioFilter lavorazioniFilter = new LavContoProprioFilter();
    lavorazioniFilter.setIdDittaUma(dittaUMAAziendaVO.getIdDittaUMA());
    lavorazioniFilter.setAnnoDiRiferimento(annoCampagna);
    lavorazioniFilter.setIdUsoDelSuolo(lav.getUsoDelSuolo());
    lavorazioniFilter.setIdLavorazione(lav.getLavorazione()); 
                                                            
    String countLavCP = umaFacadeClient.countLavorazContoProprioByFilter(lavorazioniFilter);    	
    SolmrLogger.debug(this, "- countLavCP ="+countLavCP);
    	
    if(new Long(countLavCP).longValue()>0){
        SolmrLogger.debug(this, "--- Ci sono gia lavorazioni con gli stessi dati!");
    	isLavorazDuplicata = true;
    	SolmrLogger.debug(this, "   END controlloPresenzaLavorazioneSuDb");
    	return isLavorazDuplicata;
      }          
    
    SolmrLogger.debug(this, "   END controlloPresenzaLavorazioneSuDb");
    return isLavorazDuplicata;    
  }
  
  
   private void addStringForDescMacchina(StringBuffer sb, String value)
  {
    if (Validator.isNotEmpty(value))
    {
      if (sb.length() > 0)
      {
        sb.append(" - ");
      }
      sb.append(value);
    }
  }%>
  
  