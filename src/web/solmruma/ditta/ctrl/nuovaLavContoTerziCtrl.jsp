supOreStr<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="java.util.*"%>
<%@page import="it.csi.solmr.dto.uma.form.AggiornaContoTerziFormVO"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%
	String iridePageName = "nuovaLavContoTerziCtrl.jsp";
  String msgVerificaAziendeAnagrafe = "Operazione non permessa. L''azienda indicata non e''presente nell''Anagrafe delle imprese agricole ed agroalimentari.";
%>
<%@include file="/include/autorizzazione.inc"%>
<%
	SolmrLogger.debug(this,"   BEGIN nuovaLavContoTerziCtrl.jsp");
  
  
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  String viewUrl = "/ditta/view/nuovaLavContoTerziView.jsp";
 
  String elencoHtm = "../../ditta/layout/elencoLavContoTerzi.htm";
  String elencoBisHtm = "../../ditta/layout/elencoLavContoTerziBis.htm";
  
  
  // ------- **** Primo accesso alla pagina -> rimuovere l'eventuale valore memorizzato in sessione  
  if(request.getParameter("funzione") == null){
      SolmrLogger.debug(this, "---- Primo accesso alla pagina ----");     
      // Rimuovo dalla sessione gli oggetti eventualmente settati
      removeAttributeFromSession(session);
  } 
  

  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  AggiornaContoTerziFormVO form = (AggiornaContoTerziFormVO) session.getAttribute("formInserimentoCT");

  String flagPulisciSessione = (String) request.getAttribute("flagPulisciSessione");
  SolmrLogger.debug(this, "flagPulisciSessione vale: "+ flagPulisciSessione);

  if (!StringUtils.isStringEmpty(flagPulisciSessione) || form == null)
  {
    form = new AggiornaContoTerziFormVO();
  }

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  AnnoCampagnaVO annoCampagnaVO = (AnnoCampagnaVO) session.getAttribute("annoCampagna");
  
  
  // ---------------- *** GESTIONE CASO reimposta azienda *** -------------------
  if (request.getParameter("funzione") != null && request.getParameter("funzione").equalsIgnoreCase("reimpostaAzienda")){
    SolmrLogger.debug(this, "---- CASO reimpostaAzienda");
    // Ripulire tutti i campi riguardanti l'azienda e ricaricare il resto della pagina invariata
    form.setSedeLegale("");    
    form.setIndirizzoSedeLegale("");    
    form.setIdAzienda(null);
    form.setIdAziendaOld(null);
    form.setCuaa("");
    form.setPartitaIva("");
    form.setDenominazione("");
    form.setSupOreFattura("");
    form.setConsumoDichiarato("");
    
    // torno sulla view
    SolmrLogger.debug(this, "   END nuovaLavContoTerziCtrl");
%>
<jsp:forward page="<%=viewUrl%>" />
<%
	}
  // ---------- *** GESTIONE CASO rimuovi *** ---------------------
  if (request.getParameter("funzione") != null && request.getParameter("funzione").equalsIgnoreCase("rimuovi")){
    SolmrLogger.debug(this, "---- CASO rimuovi");
    
    // Controllo quali elementi sono stati selezionati nella tabella di riepilogo
    String[] posizioni = request.getParameterValues("idLavContoTerzi");
    if(posizioni != null){
      SolmrLogger.debug(this, "- numero di elementi da rimuovere dalla tabella di riepilogo ="+posizioni.length);
      // recupero dalla sessione l'elenco visualizzato nella tabella di riepilogo
      Vector<LavContoTerziVO> lavContoTerziVect = (Vector<LavContoTerziVO>)session.getAttribute("lavContoTerziVect");
      
      // elimino tutti gli elementi          
      if(posizioni.length == lavContoTerziVect.size()){
        SolmrLogger.debug(this, "- elimino tutti gli elementi");
        session.removeAttribute("lavContoTerziVect");
      }
      else{      
        int contatore = 0;
        for(int i=0;i<posizioni.length;i++){
          String indiceToRemove = (String)posizioni[i];
	      if(i == 0) {
	        lavContoTerziVect.removeElementAt(Integer.parseInt(indiceToRemove));
	      }
	      else{
	        lavContoTerziVect.removeElementAt(Integer.parseInt(indiceToRemove) - contatore);
	      }
	      contatore++;
        }
        // risetto in sessione l'elenco delle lavorazioni da visualizzare nel riepilogo
        session.setAttribute("lavContoTerziVect", lavContoTerziVect);
      }        
    }  
    SolmrLogger.debug(this, "   END nuovaLavContoTerziCtrl");
    // torno sulla view
%>
<jsp:forward page="<%=viewUrl%>" />
<%
	}  
  
  
  // ------------ *** GESTIONE CASO SALVA **** -----------------
  if (request.getParameter("funzione") != null && request.getParameter("funzione").equalsIgnoreCase("salva")){
    SolmrLogger.debug(this, "---- CASO salva");
    
    // --- Controllare che nessuna delle lavorazioni presenti nella tabella di riepilogo siano state già inserite sul db
    SolmrLogger.debug(this, "-- Controllare che nessuna delle lavorazioni presenti nella tabella di riepilogo siano state già inserite sul db");
    int posizioneElementoKO = controlloPresenzaLavorazioneSuDb(session,dittaUMAAziendaVO,annoCampagnaVO,umaFacadeClient);
    
    // --- CASO : visualizzare l'errore per l'elemento già presente sul db
    if(posizioneElementoKO >-1){
      SolmrLogger.debug(this, "-- Nella tabella di riepilogo c'è una lavorazione già presente sul db!");
      ValidationErrors errors = new ValidationErrors();
      String msg = "Per azienda, uso del suolo e lavorazione indicati e'' gia'' presente a sistema una lavorazione. Impossibile procedere con l''inserimento.";
      errors.add("idLavContoTerzi_"+new Integer(posizioneElementoKO).toString(), new ValidationError(msg));
      
      request.setAttribute("errorType", new Long(SolmrConstants.VALIDAZIONE_KO_BLOCCANTI));
      request.setAttribute("errors", errors);
       
      SolmrLogger.debug(this, "   END nuovaLavContoTerziCtrl");
      // torno sulla view per visualizzare l'errore nella riga della tabella di riepilogo
%>
<jsp:forward page="<%=viewUrl%>" />
<%
	} 
    // --- CASO : effettuare l'inserimento sul db
    else{
      SolmrLogger.debug(this, "-- Si puo' procedere con l'inserimento dei dati presenti nella tabella di riepilogo");
      Vector<LavContoTerziVO> lavContoTerziVect = (Vector<LavContoTerziVO>)session.getAttribute("lavContoTerziVect");
      try{
        // Dati per cercare se esiste già id_campagna_contoterzisti in DB_CAMPAGNA_CONTOTERZISTI   
	    annoCampagnaVO.setIdDittaUma(dittaUMAAziendaVO.getIdDittaUMA());
	    annoCampagnaVO.setVersoLavorazioni(SolmrConstants.VERSO_LAVORAZIONI_E);
	    annoCampagnaVO.setExtIdUtenteAggiornamento(ruoloUtenza.getIdUtente());
	        
        umaFacadeClient.inserisciLavPerContoTerziMultipla(annoCampagnaVO,lavContoTerziVect);
      }
      catch(Exception ex){
        SolmrLogger.error(this, "-- Exception in inserisciLavPerContoTerziMultipla ="+ex.getMessage());
        ValidationException valEx = new ValidationException("Eccezione in fase di inserimento" + ex.getMessage(), viewUrl);
        valEx.addMessage(ex.getMessage(), "exception");
        throw valEx;
      }

      SolmrLogger.debug(this, "-- L'INSERIMENTO e' stato eseguito con successo");      
      String forwardUrl = elencoHtm;
      
      if("bis".equalsIgnoreCase(request.getParameter("pageFrom"))){
        forwardUrl = elencoBisHtm;
      }
	  
	  // viene utilizzato per mantenere i filtri settati in fase di ricerca nella pagina di Elenco lavorazioni
	  session.setAttribute("paginaChiamante", "inserisci");
	  
      session.setAttribute("notifica", "Inserimento eseguito con successo");
      SolmrLogger.debug(this, "-- forwardUrl ="+forwardUrl);
      response.sendRedirect(forwardUrl);
      SolmrLogger.debug(this, "   END nuovaLavContoTerziCtrl");
      return;              
    }// fine caso inserimento sul db    
        
  }// fine caso SALVA  
    

  String idAziendaPop = (String) request.getParameter("idAziendaPop");
  String provincia = (String) request.getParameter("provincia");
  String comune = (String) request.getParameter("comune");
  String sedelegaleIndirizzo = (String) request.getParameter("sedelegaleIndirizzo");
  String sedeLegale = (String) request.getParameter("sedeLegale");

  String sedeLegaleStr = (String) request.getParameter("sedeLegaleStr");
  String indirizzoSedeLegaleStr = (String) request.getParameter("indirizzoSedeLegaleStr");
  SolmrLogger.debug(this, "NEL CONTROLLER sedeLegaleStr vale: "+ sedeLegaleStr);
  SolmrLogger.debug(this, "NEL CONTROLLER indirizzoSedeLegaleStr vale: "+ indirizzoSedeLegaleStr);

  form.setSedeLegale(StringUtils.toUpperTrim(sedeLegaleStr));
  form.setIndirizzoSedeLegale(StringUtils.toUpperTrim(indirizzoSedeLegaleStr));

  form.setIdDittaUmaAssociata(request.getParameter("idDittaUmaAssociata"));
 
  
  SolmrLogger.debug(this, "idAziendaPop  ="+ idAziendaPop);

  if (!StringUtils.isStringEmpty(idAziendaPop)
      && !"null".equalsIgnoreCase(idAziendaPop))
  {
    form.setIdAzienda(idAziendaPop);    
  }

  UmaFacadeClient umaClient = new UmaFacadeClient();

  if (!StringUtils.isStringEmpty(sedelegaleIndirizzo))
  {
    form.setIndirizzoSedeLegale(StringUtils.toUpperTrim(sedelegaleIndirizzo));
  }

  if (!StringUtils.isStringEmpty(comune)
      && !StringUtils.isStringEmpty(provincia))
  {
    String desc = comune + "(" + provincia + ")";
    form.setSedeLegale(StringUtils.toUpperTrim(desc));
    SolmrLogger.debug(this,"NEL CONTROLLER comune  provincia (da popUp)vale: " + desc);
  }
  SolmrLogger.debug(this,"NEL CONTROLLER sedelegaleIndirizzo (da popUp) vale: "+ sedelegaleIndirizzo);
  SolmrLogger.debug(this, "NEL CONTROLLER sedeLegale (da popUp) vale: "+ sedeLegale);

  if (!StringUtils.isStringEmpty(sedeLegale))
  {
    form.setSedeLegale(StringUtils.toUpperTrim(sedeLegale));
  }
  String cuaa = StringUtils.toUpperTrim((String) request.getParameter("cuaaStr"));
  String denominazione = StringUtils.toUpperTrim((String) request.getParameter("denominazioneStr"));
  String partitaIva = (String) request.getParameter("partitaIvaStr");

  SolmrLogger.debug(this, "**** indirizzoSedeLegaleStr vale: "+ indirizzoSedeLegaleStr);
  SolmrLogger.debug(this, "**** sedeLegaleStr vale: " + sedeLegaleStr);

  String numeroFattura = (String) request.getParameter("numeroFattura");
  String note = StringUtils.toUpperTrim((String) request.getParameter("note"));
  form.setNumeroFatture(StringUtils.toUpperTrim(numeroFattura));
  form.setNote(StringUtils.toUpperTrim(note));

  SolmrLogger.debug(this, "**** cuaa vale: %" + cuaa + "%");
  if (!StringUtils.isStringEmpty(cuaa))
    cuaa = cuaa.trim();
  form.setCuaa(StringUtils.toUpperTrim(cuaa));
  form.setDenominazione(StringUtils.toUpperTrim(denominazione));
  form.setPartitaIva(partitaIva);


  if (!StringUtils.isStringEmpty(form.getIdAzienda()))
  {
    Vector vExtIdAzienda = new Vector();
    vExtIdAzienda.add(new Long(form.getIdAzienda()));
    Long idDittaUma = null; // per uniformità con il modifica (qui potrei sapere se ho l'idDittaUma, in modifica no perchè non l'ho salvato sul db)
    SolmrLogger.debug(this, "--- ricerco la zona altimetrica");
    HashMap<Long,ZonaAltimetricaVO> hashZonaAlt = umaFacadeClient.getZonaAltByExtIdAziendaRange((Long[]) vExtIdAzienda.toArray(new Long[vExtIdAzienda.size()]), idDittaUma);
    if(hashZonaAlt != null){
	    ZonaAltimetricaVO zonaAltrimetrica =  hashZonaAlt.get(NumberUtils.parseLong(form.getIdAzienda()));
	    String codiceZonaAlt = null;
	    if(zonaAltrimetrica != null){
	      codiceZonaAlt = zonaAltrimetrica.getCodiceZonaAltimetrica();
	      SolmrLogger.debug(this, "--- codiceZonaAlt ="+codiceZonaAlt);   
	      form.setCodiceZonaAlt(codiceZonaAlt);     
	      form.setDescrZonaAlt(zonaAltrimetrica.getDescrZonaAltimetrica());
	      form.setComuneZonaAlt(zonaAltrimetrica.getDescrComune());
	    }
	    else{
	      form.setCodiceZonaAlt(null);
	      form.setDescrZonaAlt("");
	      form.setComuneZonaAlt("");
	    }
    }
    else{
      form.setCodiceZonaAlt(null);
	  form.setDescrZonaAlt("");
	  form.setComuneZonaAlt("");
    }
  }
  

  String anno = annoCampagnaVO.getAnnoCampagna();
  String data = null;
  String coefficiente = umaFacadeClient.getValoreParametro(SolmrConstants.PARAMETRO_COEFFICIENTE_CAVALLI_CARBURANTE,anno,data);
  SolmrLogger.debug(this, "coefficiente vale: " + coefficiente);  
  form.setCoefficiente(coefficiente);

  String litriBase = (String) request.getParameter("litriBase");
  form.setLitriBase(litriBase);
  SolmrLogger.debug(this, "---- litriBase =" + litriBase);

  String litriMaggiorazione = (String) request.getParameter("litriMaggiorazione");
  form.setLitriMaggiorazione(litriMaggiorazione);
  SolmrLogger.debug(this, "---- litriMaggiorazione =" + litriMaggiorazione);

  String litriMedioImpasto = (String) request.getParameter("litriMedioImpasto");
  form.setLitriMedioImpasto(litriMedioImpasto);
  SolmrLogger.debug(this, "---- litriMedioImpasto =" + litriMedioImpasto);

  String litriTerDeclivi = (String) request.getParameter("litriTerDeclivi");
  form.setLitriTerDeclivi(litriTerDeclivi);
  SolmrLogger.debug(this, "---- litriTerDeclivi =" + litriTerDeclivi);

  //999|1|1|1|1|T
  String idLavorazione = (String) request.getParameter("idLavorazione");
  SolmrLogger.debug(this, "idLavorazione vale: " + idLavorazione);

  form.setConsumoDichiarato(request.getParameter("consumoDichiarato"));
  form.setEccedenza(request.getParameter("eccedenza"));

  //998|3|12|4|20|S
  if (!StringUtils.isStringEmpty(idLavorazione))
  {
    StringTokenizer st = new StringTokenizer(idLavorazione, "|");
    if (st.hasMoreTokens()){
      form.setIdLavorazone(st.nextToken());
    // SolmrLogger.debug(this,"1");
    }
    if (st.hasMoreTokens()){
      form.setLitriBase(st.nextToken());
      SolmrLogger.debug(this," -- litriBase ="+form.getLitriBase());
    }
    if (st.hasMoreTokens()){
      form.setLitriMaggiorazione(st.nextToken());
    //SolmrLogger.debug(this,"3");
    }
    if (st.hasMoreTokens()){
      form.setLitriMedioImpasto(st.nextToken());
    //SolmrLogger.debug(this,"4");
    }
    if (st.hasMoreTokens()){
      form.setLitriTerDeclivi(st.nextToken());
    }
    if (st.hasMoreTokens()){
        form.setTipoUnitaMisura(st.nextToken());
        SolmrLogger.debug(this," -- tipoUnitaMisura ="+form.getTipoUnitaMisura());
    }
    if (st.hasMoreTokens()){
      form.setFlagEscludiEsecuzioni(st.nextToken());
    //SolmrLogger.debug(this,"6");
    }
    if (st.hasMoreTokens()){
    	if("S".equals(st.nextToken())){
    		form.setLavAScavalco(0);
    	}
    	else{
    		form.setLavAScavalco(-1);
    	}
    //SolmrLogger.debug(this,"7");
    }
    
    try{
      long idLavorazioni=Long.parseLong(form.getIdLavorazone());
      long annoCampagna = Long.parseLong(annoCampagnaVO.getAnnoCampagna());
      long idCategoriaUtilizzo = Long.parseLong(form.getIdUsoSuolo());
      
      SolmrLogger.debug(this,"------- form.getIdDittaUmaAssociata()="+form.getIdDittaUmaAssociata());
      SolmrLogger.debug(this,"------- umaClient.getLavorazioneDichiarataDaAziendaContoProprio(dittaUMAAziendaVO.getIdDittaUMA(), annoCampagna, idCategoriaUtilizzo, idLavorazioni)="+umaClient.getLavorazioneDichiarataDaAziendaContoProprio(dittaUMAAziendaVO.getIdDittaUMA(), annoCampagna, idCategoriaUtilizzo, idLavorazioni));
      
      //Se l'azienda selezionata non ha una ditta Uma associata il sistema visualizza il valore 'N.D' (non disponibile).
      if (StringUtils.isStringEmpty(form.getIdDittaUmaAssociata()) && !StringUtils.isStringEmpty(form.getCuaa())){
        form.setLavorazioneDichiarataDaAziendaContoProprio("N.D.");
      }
      else{
      	form.setLavorazioneDichiarataDaAziendaContoProprio(umaClient.getLavorazioneDichiarataDaAziendaContoProprio(dittaUMAAziendaVO.getIdDittaUMA(), annoCampagna, idCategoriaUtilizzo, idLavorazioni));
      }
      
      if (!StringUtils.isStringEmpty(form.getIdAzienda()) || !StringUtils.isStringEmpty(form.getCuaa()))
      {
        Long extIdAzienda =null;
        String CUAA=null;
        
        if (!StringUtils.isStringEmpty(form.getIdAzienda())) {      
          extIdAzienda=new Long(form.getIdAzienda());
        }
        else {  
        	CUAA=form.getCuaa();
        }
          
        form.setLavorazioneDichiataDaAziendaContoTerzi(umaClient.getLavorazioneDichiataDaAziendaContoTerzi(dittaUMAAziendaVO.getIdDittaUMA(), annoCampagna, idCategoriaUtilizzo, idLavorazioni, CUAA, extIdAzienda));
      }
      else{
	    form.setLavorazioneDichiataDaAziendaContoTerzi("NO");
      }
    }
    catch(Exception e){
        SolmrLogger.debug(this,"Ops tutto questo è imbarazzante. Si è verificata un'eccezione: "+e.getMessage());
    };
    
  }
  else
  {
    form.setIdLavorazone(null);
  }
  
  SolmrLogger.debug(this, " ------- Nella ctrl idLavorazione vale: " + idLavorazione);
  SolmrLogger.debug(this, " ------- Nella ctrl form.getLitriBase vale: "+ form.getLitriBase());
  SolmrLogger.debug(this, " ------- Nella ctrl form.getLitriMaggiorazione vale: "+ form.getLitriMaggiorazione());
  SolmrLogger.debug(this, " ------- Nella ctrl form.getLitriMedioImpasto vale: "+ form.getLitriMedioImpasto());
  SolmrLogger.debug(this, " ------- Nella ctrl form.getLitriTerDeclivi vale: "+ form.getLitriTerDeclivi());
  SolmrLogger.debug(this, " ------- Nella ctrl form.getTipoUnitaMisura vale: "+ form.getTipoUnitaMisura());

  String supOreStr = (String) request.getParameter("supOreStr");
  SolmrLogger.debug(this, "****nel controller supOreStr vale: " + supOreStr);
  form.setSupOre(supOreStr);

  String supOreFatturaStr = (String) request.getParameter("supOreFatturaStr");
  SolmrLogger.debug(this, "****nel controller supOreFatturaStr vale: "+ supOreFatturaStr);
  form.setSupOreFattura(supOreFatturaStr);

  //SolmrLogger.debug(this,"SONO IN nuovaLavContoTerziCntr e tipoUnitaMisura  vale: "+tipoUnitaMisura);

  String idMacchina = (String) request.getParameter("idMacchina");
  SolmrLogger.debug(this,"SONO IN nuovaLavContoTerziCntr e idMacchina  vale: " + idMacchina);
  form.setIdMacchina(idMacchina);

  SolmrLogger.debug(this, "Nella ctrl idMacchina vale: " + idMacchina);

  String cavalli = (String) request.getParameter("cavalli");
  form.setCavalli(cavalli);

  SolmrLogger.debug(this, "Nella ctrl cavalli vale: " + cavalli);

  String tipoCarburante = (String) request.getParameter("tipoCarburante");
  form.setTipoCarburante(tipoCarburante);

  SolmrLogger.debug(this, "Nella ctrl tipoCarburante vale: "+ tipoCarburante);

  String ettari = (String) request.getParameter("ettari");
  if (!StringUtils.isStringEmpty(ettari))
  {
    form.setEttari(ettari);
  }

  String numeroEsecuzioni = (String) request.getParameter("numeroEsecuzioni");
  SolmrLogger.debug(this, "Nella ctrl numeroEsecuzioni vale: "+ numeroEsecuzioni);
  form.setNumeroEsecuzioni(numeroEsecuzioni);

  String tipoUnitaMisura = (String) request.getParameter("tipoUnitaMisura");
  SolmrLogger.debug(this, "nel controller tipoUnitaMisura vale: "+ tipoUnitaMisura);

  String gasolioStr = request.getParameter("gasolioStr");
  String benzinaStr = request.getParameter("benzinaStr");

  form.setGasolio(gasolioStr);
  form.setBenzina(benzinaStr);

  String maxCarburante = request.getParameter("maxCarburante");
  SolmrLogger.debug(this, "Nel controller maxCarburante vale: "+ maxCarburante);
  form.setMaxCarburante(maxCarburante);
  
  String litriAcclivita = request.getParameter("litriAcclivita");
  SolmrLogger.debug(this, "--- litriAcclivita ="+litriAcclivita);
  form.setLitriAcclivita(litriAcclivita);
  
  String maxLitriAcclivita = request.getParameter("maxLitriAcclivita");
  SolmrLogger.debug(this, "--- maxLitriAcclivita ="+maxLitriAcclivita);
  form.setMaxLitriAcclivita(maxLitriAcclivita);
  
  String[] scavalco = request.getParameterValues("scavalco");
  if(scavalco!=null && scavalco.length==1){
	  form.setLavAScavalco(1);
  }
  else{
	  form.setLavAScavalco(0);
  }

  // -- Non è ancora stato indicato un idAzienda
  // PROVA : PER LA TOBECONFIG : COMBO Uso del Suolo sempre popolata con tutti gli usi del suolo, filtrati solo per anno di riferimento
  //if (StringUtils.isStringEmpty(form.getIdAzienda())){
    SolmrLogger.debug(this, "--- Ricerca elementi per combo 'Uso del suolo'  - vengono caricati tutti gli 'Usi del suolo', filtrati solo per anno di riferimento");
    SolmrLogger.debug(this, "-- annoCampagna ="+annoCampagnaVO.getAnnoCampagna());
	
    if(form.getLavAScavalco() != null && form.getLavAScavalco() == 1){
    	form.setVettUsoSuolo(umaClient.findCategorieUtilizzoUmaCTScavalco(annoCampagnaVO.getAnnoCampagna()));
    }
    else{
    	form.setVettUsoSuolo(umaClient.findCategorieUtilizzoUma(annoCampagnaVO.getAnnoCampagna()));
	}
    
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
    
  //}
  
  /* NOTE PER LA TOBECONFIG : COMBO Uso del Suolo sempre popolata con tutti gli usi del suolo, filtrati solo per anno di riferimento
     Ricerco comunque gli Uso del suolo legati all'idAzienda selezionata, per capire se all'aggiungi stanno aggiungendo un uso del suolo presente nel fascicolo dell'azienda o no 
     e poter dare un messaggio all'utente
  */
   
  // --> COMMENTATA LA PARTE SOTTO INIZIO
  boolean changedCombo = false;
 
  String usoSuolo = (String) request.getParameter("usoSuolo");
  SolmrLogger.debug(this,"-- Uso del suolo selezionato nalla combo ="+usoSuolo);  
  
  /* Se l'idAzienda è valorizzato o è cambiato :
     - ripopolo la combo 'Uso del suolo'
     - se è stato già selezionato un idUsoDelSuolo ed è ancora presente tra i nuovi valori -> ripopolo la combo 'Lavorazioni', altrimenti la svuoto 
  */
// **** PROVA INIZIO
  form.setIdUsoSuolo(usoSuolo);

     // NUOVA PARTE INIZIO (memorizzo gli usi del suolo legati all'azienda)
     if (form.getIdAzienda() != null && !form.getIdAzienda().trim().equals("") && (form.getIdAziendaOld() == null 
   		  || ( form.getIdAziendaOld() != null && (new Long(form.getIdAzienda()).longValue() != new Long(form.getIdAziendaOld()).longValue())))){
    	 
    	 SolmrLogger.debug(this, "-- ID AZIENDA VALORIZZATO : form.getIdAzienda() = "+form.getIdAzienda());
     	 
    	 changedCombo = true;     	
     	 
     	 Vector<CategoriaUtilizzoUmaVO> usiDelSuoloAziendaVett = null;
     	 SolmrLogger.debug(this, "-- form.getLavAScavalco() ="+form.getLavAScavalco());
     	 if(form.getLavAScavalco() != null && form.getLavAScavalco() == 1){     		
     		usiDelSuoloAziendaVett = umaClient.findCategorieUtilizzoUmaCTScavalco(annoCampagnaVO.getAnnoCampagna());
         }
     	 // Memorizzo gli usi del suolo legati all'azienda
         else{
           usiDelSuoloAziendaVett = umaClient.findCategorieUtilizzoUmaByIdAzienda(form.getIdAzienda(), annoCampagnaVO.getAnnoCampagna());
         }
     	 HashMap<Long,String> usoDelSuoloAziendaHM = new HashMap<Long,String>();
     	 if(usiDelSuoloAziendaVett != null){
     		SolmrLogger.debug(this, "-- Numero di usi del suolo legati all'azienda ="+usiDelSuoloAziendaVett.size());
	      	for(int i=0;i<usiDelSuoloAziendaVett.size();i++){
	            CategoriaUtilizzoUmaVO catAz = (CategoriaUtilizzoUmaVO)usiDelSuoloAziendaVett.get(i);
	            usoDelSuoloAziendaHM.put(catAz.getIdCategoriaUtilizzoUma(), catAz.getDescrizione());
	        }
     	 }
         session.setAttribute("usoDelSuoloAziendaHM", usoDelSuoloAziendaHM);
     }	
     // NUOVA PARTE FINE (memorizzo gli usi del suolo legati all'azienda)
     
     /* NOTE : PER LA TOBECONFIG POTREBBE SUCCEDERE DI NON AVERE RISULTATI PER LA COMBO 'USO DEL SUOLO' PER ESEMPIO SE L'AZIENDA PER LA QUALE SI STA CERCANDO HA SOLO TERRENI FUORI REGIONE :
	 				in questo caso la combo sarà vuota e non potrà inserire la lavorazione*/
	 				
	 				
     
  /*SolmrLogger.debug(this,"-- idAzienda ="+form.getIdAzienda());
  SolmrLogger.debug(this,"-- idAziendaOld ="+form.getIdAziendaOld());
  if (form.getIdAzienda() != null && !form.getIdAzienda().trim().equals("") && (form.getIdAziendaOld() == null 
		  || ( form.getIdAziendaOld() != null && (new Long(form.getIdAzienda()).longValue() != new Long(form.getIdAziendaOld()).longValue())))){
  	changedCombo = true;
    SolmrLogger.debug(this,"--- Ripopolo la combo 'Uso del suolo' CON idAzienda ="+ form.getIdAzienda());
    if(form.getLavAScavalco() != null && form.getLavAScavalco() == 1){
    	form.setVettUsoSuolo(umaClient.findCategorieUtilizzoUmaCTScavalco(annoCampagnaVO.getAnnoCampagna()));
    }
    else{
    	form.setVettUsoSuolo(umaClient.findCategorieUtilizzoUmaByIdAzienda(form.getIdAzienda(), annoCampagnaVO.getAnnoCampagna()));
    }*/
    
	 				
    //Vector v=form.getVettUsoSuolo();
            	
    // Se la ricerca filtrata per idAzienda e annoCampagna non ha trovato risultati -> vengono caricati tutti gli Usi del suolo possibili
    // (Es : può capitare quando si sta cercando di inserire per un annoCampagna per il quale l'azienda non ha ancora Dichiarazioni di consistenza in anagrafe)
    /*if (v==null || v.size()<=0){
      SolmrLogger.debug(this,"--- Ripopolo la combo con tutti gli 'Uso del suolo' possibili, filtrati solo per anno di riferimento");
      SolmrLogger.debug(this, "-- annoCampagna ="+annoCampagnaVO.getAnnoCampagna());
      if(form.getLavAScavalco() != null && form.getLavAScavalco() == 1){
      	form.setVettUsoSuolo(umaClient.findCategorieUtilizzoUmaCTScavalco(annoCampagnaVO.getAnnoCampagna()));
      }
      else{
      	form.setVettUsoSuolo(umaClient.findCategorieUtilizzoUma(annoCampagnaVO.getAnnoCampagna()));
      }
    }*/
       
  /* form.setIdUsoSuolo(usoSuolo);
  }*/
  //else
  //{
	  if(request.getParameter("funzione") != null && (request.getParameter("funzione").equalsIgnoreCase("changeScavalco"))){
		  SolmrLogger.debug(this, " -- request.getParameter(funzione) ="+request.getParameter("funzione"));
		  if(form.getLavAScavalco() != null && form.getLavAScavalco() == 1){
		 	 form.setVettUsoSuolo(umaClient.findCategorieUtilizzoUmaCTScavalco(annoCampagnaVO.getAnnoCampagna()));
		  }
		  // NUOVA PARTE INIZIO (memorizzo gli usi del suolo legati all'azienda)
		  else if(form.getIdAziendaOld() != null && !StringUtils.isStringEmpty(form.getIdAziendaOld())){
		     //form.setVettUsoSuolo(umaClient.findCategorieUtilizzoUmaByIdAzienda(form.getIdAziendaOld(), annoCampagnaVO.getAnnoCampagna()));
		     SolmrLogger.debug(this, " -- getIdAziendaOld ="+form.getIdAziendaOld());
		     Vector<CategoriaUtilizzoUmaVO> usiDelSuoloAziendaVett = umaClient.findCategorieUtilizzoUmaByIdAzienda(form.getIdAziendaOld(), annoCampagnaVO.getAnnoCampagna());
		     HashMap<Long,String> usoDelSuoloAziendaHM = new HashMap<Long,String>();
	     	 if(usiDelSuoloAziendaVett != null){
	     		SolmrLogger.debug(this, "-- Numero di usi del suolo legati all'azienda ="+usiDelSuoloAziendaVett.size());
		      	for(int i=0;i<usiDelSuoloAziendaVett.size();i++){
		            CategoriaUtilizzoUmaVO catAz = (CategoriaUtilizzoUmaVO)usiDelSuoloAziendaVett.get(i);
		            usoDelSuoloAziendaHM.put(catAz.getIdCategoriaUtilizzoUma(), catAz.getDescrizione());
		        }
	     	 }
	         session.setAttribute("usoDelSuoloAziendaHM", usoDelSuoloAziendaHM);
		  }
		  // NUOVA PARTE FINE (memorizzo gli usi del suolo legati all'azienda)
		  else{
		    form.setVettUsoSuolo(umaClient.findCategorieUtilizzoUma(annoCampagnaVO.getAnnoCampagna()));
		  }
	  }
	  
/*	  if (! (!StringUtils.isStringEmpty(idAziendaPop)
	         && !"null".equalsIgnoreCase(idAziendaPop)) )
	  {
  		form.setIdUsoSuolo(usoSuolo);
  	}
  }*/
// *** PROVA FINE

  SolmrLogger.debug(this, "NEL CONTROLLER usoSuolo VALE: " + usoSuolo);
  ////if(!StringUtils.isStringEmpty(usoSuolo)){
  //form.setIdUsoSuolo(usoSuolo);
  ////}
  
  if (!StringUtils.isStringEmpty(form.getIdUsoSuolo())
  		&& (form.getIdUsoSuoloOld()==null
  				|| (!StringUtils.isStringEmpty(form.getIdUsoSuoloOld())
  						&& (new Long(form.getIdUsoSuolo()).longValue() != new Long(form.getIdUsoSuoloOld()).longValue())
  					 )
  			 )
  	 )
  {
    changedCombo = true;
  }
  
  
  SolmrLogger.debug(this, "-- form.getIdUsoSuolo() ="+form.getIdUsoSuolo());
  // --- Ricarico la combo
  if (!StringUtils.isStringEmpty(form.getIdUsoSuolo())
  	/*	&& (form.getIdUsoSuoloOld()==null
  				|| (!StringUtils.isStringEmpty(form.getIdUsoSuoloOld())
  						&& (new Long(form.getIdUsoSuolo()).longValue() != new Long(form.getIdUsoSuoloOld()).longValue())
  					 )
  			 )*/
  	 )
  {
		//changedCombo = true;

    SolmrLogger.debug(this,"PRIMA DI CHIAMARE findElencoLavorazioni CON form.getIdUsoSuolo(): "+ form.getIdUsoSuolo());
    SolmrLogger.debug(this, "dittaUMAAziendaVO.getIdDittaUMA(): "+ dittaUMAAziendaVO.getIdDittaUMA());
    SolmrLogger.debug(this, "annoCampagnaVO.getAnnoCampagna(): "+ annoCampagnaVO.getAnnoCampagna());
    
    // ---- Valori da visualizzare nella combo 'Lavorazioni' -----
    if (!StringUtils.isStringEmpty(annoCampagnaVO.getAnnoCampagna())){      
      SolmrLogger.debug(this, "---- Ricerca degli elementi da visualizzare nella combo 'Lavorazioni'");
      Vector vettLavorazioni = null;
      if(form.getLavAScavalco() != null && form.getLavAScavalco() == 1){
      	vettLavorazioni = umaClient.findElencoLavorazioniConScavalco(form.getIdUsoSuolo(), "" + dittaUMAAziendaVO.getIdDittaUMA(), ""+ annoCampagnaVO.getAnnoCampagna());
      }
      else{
      	vettLavorazioni = umaClient.findElencoLavorazioni(form.getIdUsoSuolo(), "" + dittaUMAAziendaVO.getIdDittaUMA(), ""+ annoCampagnaVO.getAnnoCampagna());
      }
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
    
    //form.setIdLavorazone(null);
  }
 
  
  if (!StringUtils.isStringEmpty(form.getIdLavorazone())
  		&& (form.getIdLavorazoneOld()==null
  				|| (!StringUtils.isStringEmpty(form.getIdLavorazoneOld())
  						&& (new Long(form.getIdLavorazone()).longValue() != new Long(form.getIdLavorazoneOld()).longValue())
  					 )
  			 )
  	 )
  {
  	changedCombo = true;
  }
  
  
  //Aggiornamento campi di comodo del giro precedente
	form.setIdAziendaOld(form.getIdAzienda());
	form.setIdUsoSuoloOld(form.getIdUsoSuolo());
	form.setIdLavorazoneOld(form.getIdLavorazone());


	BigDecimal superficieDisponibile=new BigDecimal("0");
  // cerco il valore di superficie solo 
  // se l'azienda per la quale è stata fatta la lavorazione risulta essere censita in Anagrafe
  // ed è stato selezionato un valore dalla combo uso suoloDB_UNITA_MISURA.TIPO == 'S' 
  if (!StringUtils.isStringEmpty(form.getIdAzienda())
      && !StringUtils.isStringEmpty(form.getIdUsoSuolo()))
  /*&& form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_T)*/
  {
    SolmrLogger.debug(this, "PRIMA DI CHIAMARE maxSuperficie....");
		//changedCombo = true;
  }

  if (!StringUtils.isStringEmpty(form.getIdUsoSuolo())
      && !StringUtils.isStringEmpty(form.getIdLavorazone()))
  {
  	//changedCombo = true;
  	
    // Cerco il valore da proporre a video nel campo numero esecuzioni
    CategoriaColturaLavVO elem = umaClient.getCategoriaColturaLav(form.getIdLavorazone(), form.getIdUsoSuolo(), SolmrConstants.ID_TIPO_COLTURA_LAVORAZIONE_CONTO_TERZI_CONSORZI, annoCampagnaVO.getAnnoCampagna());
    if (elem != null)
    {
      SolmrLogger.debug(this, "DOPO getCategoriaColturaLav ...");
      SolmrLogger.debug(this, "elem.getMaxEsecuzione() VALE: "
          + elem.getMaxEsecuzione());
      SolmrLogger.debug(this, "elem.getCodiceUnitaMisura() VALE: "
          + elem.getCodiceUnitaMisura());

      //form.setNumeroEsecuzioni(""+elem.getMaxEsecuzione());
      if (null != elem.getMaxEsecuzione())
      	form.setMaxEsecuzioni(""+elem.getMaxEsecuzione());
      else
      	form.setMaxEsecuzioni("1");

      form.setTipoUnitaMisura(elem.getTipoUnitaMisura());
      //form.setIdUnitaMisura(elem.getCodiceUnitaMisura());
      form.setCodiceUnitaMisura(elem.getCodiceUnitaMisura());
      //form.setTipoUnitaMisura(elem.getCodiceUnitaMisura());
      form.setIdUnitaMisura(StringUtils.getLongValue(elem
          .getIdUnitaMisura()));
    }
    
    // ---- **** Ricerca degli elementi da visualizzare nella combo 'Macchina utilizzata' ***** ----
    if (form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_T))
    {
      // carico combo macchine
      SolmrLogger.debug(this, "--- Ricerca degli elementi da visualizzare nella combo 'Macchina utilizzata'");
      Vector vettMacchine = umaClient.findMacchineUtilizzate(new Long(form
          .getIdLavorazone()), new Long(form.getIdUsoSuolo()), new Long(annoCampagnaVO
          .getAnnoCampagna()), dittaUMAAziendaVO.getIdDittaUMA(), false);
      
      form.setVettMacchine(vettMacchine);      
      form.setIdMacchina(idMacchina);
      
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
    	form.setIdMacchina("");
    }

  }
  else
  {
    form.setTipoUnitaMisura("");
    form.setIdUnitaMisura("");
    form.setNumeroEsecuzioni("");
    form.setMaxEsecuzioni("");
  }
  
  
  if(form.getTipoUnitaMisura() != null && (form.getTipoUnitaMisura().equals(SolmrConstants.TIPO_UNITA_MISURA_S)||form.getTipoUnitaMisura().equals(SolmrConstants.TIPO_UNITA_MISURA_M))){
      SolmrLogger.debug(this, "------ CALCOLO DELLA SUPERFICIE da proporre nei campi 'Sup(ha)' e 'Sup(ha) Fattura'");
	  // --------- CALCOLO DELLA SUPERFICIE da proporre nei campi 'Sup(ha)' e 'Sup(ha) Fattura'
	  // Attenzione : se l'unità di misura sono le ore non si deve settare tale valore nei campi 'Ore' e 'Ore Fattura'
	  if(changedCombo){
	    SolmrLogger.debug(this, "-- E' stata modificata la combo");	   		
	    //Superficie fascicolo
	    BigDecimal superficie = umaClient.maxSuperficieEsecuzioni(form.getIdAzienda(),form.getIdLavorazone(), form.getIdUsoSuolo(), annoCampagnaVO.getAnnoCampagna(), SolmrConstants.ID_TIPO_COLTURA_LAVORAZIONE_CONTO_TERZI_CONSORZI);		
	        
	    if(Validator.isNotEmpty(superficie))
	    {
	String umps=umaFacadeClient.getParametro(SolmrConstants.PARAMETRO_COEFFICIENTE_SUPERFICIE_LAV_CONTO_TERZI);
		    Long umpsLong=NumberUtils.parseLong(umps);
		    if (umpsLong==null)
		    {
		      throw new SolmrException("Attenzione! si è verificato un errore grave. Se il problema persiste contattare l'assistenza tecnica comunicando il seguente messaggio: PARAMETRO "+SolmrConstants.PARAMETRO_COEFFICIENTE_SUPERFICIE_LAV_CONTO_TERZI+" non valido o assente");
		    }
		    BigDecimal umpsDecimal = new BigDecimal(umpsLong.longValue()).setScale(4).divide(new BigDecimal(100), BigDecimal.ROUND_HALF_UP);
		    umpsDecimal = umpsDecimal.add(new BigDecimal("1"));		
		    BigDecimal supMax=superficie.multiply(umpsDecimal).setScale(4, BigDecimal.ROUND_HALF_UP);
		    SolmrLogger.debug(this, "DOPO LA CHIAMATA A maxSuperficie....");
	    
		    LavorazioniFilterVO lavorazioniFilter = new LavorazioniFilterVO(annoCampagnaVO.getAnnoCampagna(),form.getIdUsoSuolo(),form.getIdLavorazone(),form.getIdAzienda(),form.getCuaa());
	//String superficieDichiarataLavorazioniContoTerzi2 = umaFacadeClient.superficieDichiarataLavorazioniContoTerzi(lavorazioniFilter);			
																		
	String superficieDichiarataLavorazioniContoTerzi = umaFacadeClient.superficieDichiarataLavorazioniContoTerziEsecuzioni(lavorazioniFilter);			
	BigDecimal superficieDichiarataLavorazioniContoTerziBD = Validator.isNotEmpty(superficieDichiarataLavorazioniContoTerzi)?new BigDecimal(superficieDichiarataLavorazioniContoTerzi):new BigDecimal("0");			
		    SolmrLogger.debug(this, "DOPO LA CHIAMATA A superficieDichiarataLavorazioniContoTerzi....");
		    
	BigDecimal superficieDichLavContoTerziNegativaBD=superficieDichiarataLavorazioniContoTerziBD.multiply(new BigDecimal("-1")).setScale(4); //.divide(new BigDecimal(100),BigDecimal.ROUND_HALF_UP);			
	superficieDisponibile=supMax.add(superficieDichLavContoTerziNegativaBD);			
		
		    superficieDisponibile=superficieDisponibile.divide(umpsDecimal,BigDecimal.ROUND_HALF_UP).setScale(4);		   
		    		    
		    BigDecimal maxEsecuzioniBD = Validator.isNotEmpty(form.getMaxEsecuzioni())?new BigDecimal(form.getMaxEsecuzioni()):new BigDecimal("1");		    
		    superficieDisponibile=superficieDisponibile.divide(maxEsecuzioniBD,BigDecimal.ROUND_HALF_UP).setScale(4);
		    		    
		    superficieDisponibile = (Validator.isNotEmpty(superficieDisponibile)?superficieDisponibile:new BigDecimal("0")); 		    	   
	    }   
	    SolmrLogger.debug(this, "-- superficieDisponibile =" + superficieDisponibile); 
	    form.setSuperficie("" + superficieDisponibile);
	    form.setSupOre("" + superficieDisponibile);
	  	//form.setSupOreFattura("" + superficieDisponibile);
	  } // fine CASO changeCombo
	  
	  // Se la superficie disponibile è < 0, propongo 0
	  if (superficieDisponibile.compareTo(BigDecimal.ZERO) < 0){
	  	  form.setSupOre("0");
	  	  //form.setSupOreFattura("0");
	  }
  } // fine CASO unità di misura = S


    //inizio caso unità misura = K
  if(form.getTipoUnitaMisura() != null && form.getTipoUnitaMisura().equals(SolmrConstants.TIPO_UNITA_MISURA_K))
  {
      SolmrLogger.debug(this, "------ CASO POTENZA ");
  
    if(changedCombo)
    {
      if (Validator.isNotEmpty(form.getIdAzienda()))
	      superficieDisponibile = umaClient.getDimensioneFabbricato(Long.parseLong(form.getIdAzienda()),annoCampagnaVO.getAnnoCampagna());   
	      
      form.setSuperficie("" + superficieDisponibile);
      form.setSupOre("" + superficieDisponibile);
    } // fine CASO changeCombo

    if (superficieDisponibile.compareTo(BigDecimal.ZERO) < 0){
        form.setSupOre("0");
        //form.setSupOreFattura("0");
    }
  } // fine CASO unità di misura = K
  
  session.setAttribute("formInserimentoCT", form);

  // ---------------- *** GESTIONE CASO aggiungi *** -------------------
  if (request.getParameter("funzione") != null && (request.getParameter("funzione").equalsIgnoreCase("aggiungi") || request.getParameter("funzione").equalsIgnoreCase("aggiungiDopoWarning"))){
    SolmrLogger.debug(this,"--- CASO AGGIUNGI ---");   
    
    LavContoTerziVO lavContoTerziInsert = new LavContoTerziVO();
    SolmrLogger.debug(this, "---- Effettuo validazione dei campi");
    ValidationErrors errors = validateInsert(request, session, form, lavContoTerziInsert,annoCampagnaVO,umaClient,msgVerificaAziendeAnagrafe, dittaUMAAziendaVO);
        
	//Recupera la componente esito, per verificare se esistono dei warning
    // non risolti nella compilazione della checklist dinamica, il che indica
    // che la checklist non è stata del tutto impostata
    int sizeWarning = errors != null ? errors.sizeWarning() : 0;
    int size = errors != null ? errors.size() : 0;
    int validateResult = 0;
    if (size > 0)
    {
      SolmrLogger.debug(this, "-- ci sono degli errori BLOCCANTI");
      SolmrLogger.debug(this," ---- numero di errori bloccanti =" + errors.size());
      validateResult = SolmrConstants.VALIDAZIONE_KO_BLOCCANTI;
    }
    else{
      //Se non ci sono errori bloccanti, ma ci sono errori di warning
      if (sizeWarning > 0){
        SolmrLogger.debug(this, "-- NON ci sono degli errori BLOCCANTI, ma ci sono errori di WARNING");
        SolmrLogger.debug(this," ---- numero di errori di warning =" + sizeWarning);
        validateResult = SolmrConstants.VALIDAZIONE_KO_WARNING;
      }
    }
    request.setAttribute("errorType", new Long(validateResult));
        
    // se CASO 'aggiungiDopoWarning' -> è stato dato l'ok sulla popup di warning relativo all'azienda che si sta per inserire
    // -> dopo aver fatto ok, deve eseguire ciò che deve fare l'aggiungi e non presentare più il popup di warning
    if(request.getParameter("funzione").equalsIgnoreCase("aggiungiDopoWarning"))
      request.setAttribute("errorType", null);
    
    if(! (validateResult == new Long(SolmrConstants.VALIDAZIONE_OK).intValue() || 
    		(validateResult == new Long(SolmrConstants.VALIDAZIONE_KO_WARNING).intValue() &&  Validator.isNotEmpty(request.getParameter("bConfirmWarning")))))
    {
      request.setAttribute("errors", errors);      
    }
    else{     
      try{               	        
	       if (StringUtils.isStringEmpty(form.getIdAzienda())){
	          lavContoTerziInsert.setCuaa(form.getCuaa());
	          lavContoTerziInsert.setDenominazione(form.getDenominazione());
	          lavContoTerziInsert.setIndirizzoSedeLegale(form.getIndirizzoSedeLegale());
	          lavContoTerziInsert.setPartitaIva(partitaIva);
	          lavContoTerziInsert.setIstatSedeLegaleComune(form.getIstatComune());
	        }
	    	        
	
	        lavContoTerziInsert.setNumeroFatture(form.getNumeroFatture());
	        lavContoTerziInsert.setNote(form.getNote());
	        lavContoTerziInsert.setTipoUnitaMisura(form.getTipoUnitaMisura());
	        
	        
	        SolmrLogger.debug(this,"prima del salvataggio form.getIstatComune() vale: "+ form.getIstatComune());
	        SolmrLogger.debug(this,"prima del salvataggio lavContoTerziInsert.getSupOreCalcolata() vale: "+ lavContoTerziInsert.getSupOreCalcolata());
	
	        lavContoTerziInsert.setExtIdUtenteAggiornamento(ruoloUtenza.getIdUtente());
	        
	        lavContoTerziInsert.setCodiceUnitaMisura(form.getCodiceUnitaMisura());	
	        
	        
	        // *********** Dati per la tabella di riepilogo ***
	        
	        // Valorizzo la descrizione della lavorazione
	        HashMap<Long,String> lavorazHM = (HashMap<Long,String>)session.getAttribute("lavorazHM");  
	        SolmrLogger.debug(this, "- idLavorazioni ="+lavContoTerziInsert.getIdLavorazoni());
            String descrLavorazione = lavorazHM.get(lavContoTerziInsert.getIdLavorazoni());
            lavContoTerziInsert.setDescrLavorazione(descrLavorazione);
            
            // Valorizzo la descrizione dell'uso del suolo
            HashMap<Long,String> usoDelSuoloHM = (HashMap<Long,String>)session.getAttribute("usoDelSuoloHM");
	        SolmrLogger.debug(this, "-- idUsoDelSuolo ="+lavContoTerziInsert.getIdCategoriaUtilizziUma());
            Long idUsoDelSuolo = lavContoTerziInsert.getIdCategoriaUtilizziUma();
            SolmrLogger.debug(this, "- idUsoDelSuolo ="+idUsoDelSuolo);
            String usoDelSuolo = usoDelSuoloHM.get(idUsoDelSuolo);
            lavContoTerziInsert.setDescrUsoDelSuolo(usoDelSuolo);
            
            // Se è stata selezionata la macchina, valorizzo la descrizione della macchina
            if(lavContoTerziInsert.getIdMacchina() != null){
              HashMap<Long,String> macchineHM = (HashMap<Long,String>)session.getAttribute("macchineHM");
              String descrMacchina = macchineHM.get(lavContoTerziInsert.getIdMacchina());
              lavContoTerziInsert.setDescrMacchina(descrMacchina);
            }
            	        
	        // Cuaa e Denominazione dell'azienda
	        lavContoTerziInsert.setCuaaAzRiepilogo(form.getCuaa());
	        lavContoTerziInsert.setDenominazioneAzRiepilogo(form.getDenominazione());
	        
	        // *************
	        
	        lavContoTerziInsert.setScavalco(1 == form.getLavAScavalco());
	        
	        // memorizzo in sessione l'oggetto che si deve visualizzare nella tabella di riepilogo e che si dovrà inserire
	        SolmrLogger.debug(this, "-- ********** Memorizzo in sessione l'oggetto ********** --");
	        Vector<LavContoTerziVO> lavContoTerziVect = (Vector<LavContoTerziVO>)session.getAttribute("lavContoTerziVect");
	        if(lavContoTerziVect == null){
	          lavContoTerziVect = new Vector<LavContoTerziVO>();
	        }
	        lavContoTerziVect.add(lavContoTerziInsert);
	        session.setAttribute("lavContoTerziVect", lavContoTerziVect);        	        
	      
      }         
      catch (Exception e){
        ValidationException valEx = new ValidationException("Eccezione di validazione" + e.getMessage(), viewUrl);
        valEx.addMessage(e.getMessage(), "exception");
        SolmrLogger.error(this, " --- Exception durante la validazione sull'aggiungi ="+e.getMessage());
        throw valEx;
      }      
    }
  }
    // --------- *** Caso annulla *** ----------
  else if(request.getParameter("funzione") != null && request.getParameter("funzione").equalsIgnoreCase("annulla")){
      SolmrLogger.debug(this, "---- Gestione CASO annulla ----");
      
      // Rimuovo dalla sessione gli eventuali elementi settati in sessione
      removeAttributeFromSession(session);
      
      // viene utilizzato per mantenere i filtri settati in fase di ricerca nella pagina di Elenco lavorazioni
      session.setAttribute("paginaChiamante", "inserisci");
      
      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom"))){
        response.sendRedirect(elencoBisHtm);
      }
      else{
        response.sendRedirect(elencoHtm);
      }
      return;
   }
%>
<jsp:forward page="<%=viewUrl%>" />
<%!private void removeAttributeFromSession(HttpSession session) {
		session.removeAttribute("lavContoTerziVect");
		session.removeAttribute("usoDelSuoloHM");
		session.removeAttribute("lavorazHM");
		session.removeAttribute("macchineHM");
		session.removeAttribute("usoDelSuoloAziendaHM");
	}

	private ValidationErrors validateInsert(HttpServletRequest request, HttpSession session, AggiornaContoTerziFormVO form, LavContoTerziVO lavContoTerziInsert, AnnoCampagnaVO annoCampagnaVO,
			UmaFacadeClient umaFacadeClient, String msgVerificaAziendeAnagrafe, DittaUMAAziendaVO dittaUMAAziendaVO) throws Exception {
		SolmrLogger.debug(this, "   BEGIN validateInsert");
		ValidationErrors errors = new ValidationErrors();

		String cuaa = StringUtils.toUpperTrim(request.getParameter("cuaaStr"));
		String denominazione = StringUtils.toUpperTrim(request.getParameter("denominazioneStr"));
		String partitaIva = request.getParameter("partitaIvaStr");
		String indirizzoSedeLegale = StringUtils.toUpperTrim(request.getParameter("indirizzoSedeLegaleStr"));
		String usoSuolo = request.getParameter("usoSuolo");
		String idLavorazione = request.getParameter("idLavorazione");
		String sedeLegaleStr = StringUtils.toUpperTrim(request.getParameter("sedeLegaleStr"));

		BigDecimal zero = new BigDecimal(0);

		// ----------- Controlli campi azienda -----------
		SolmrLogger.debug(this, " --- Controlli campi azienda ---");
		if (Validator.isEmpty(cuaa)) {
			errors.add("cuaaStr", new ValidationError("Campo obbligatorio"));
		} else if (!Validator.controlloCf(cuaa.trim()) && !Validator.controlloPIVA(cuaa.trim())) {
			errors.add("cuaaStr", new ValidationError("Cuaa non corretto"));
		}

		if (Validator.isEmpty(denominazione)) {
			errors.add("denominazioneStr", new ValidationError("Campo obbligatorio"));
		}
		if (Validator.isEmpty(partitaIva)) {
			//errors.add("partitaIvaStr",new ValidationError("Campo obbligatorio"));
		} else if (!Validator.controlloPIVA(partitaIva.trim())) {
			errors.add("partitaIvaStr", new ValidationError("Partita Iva non corretta"));
		}

		if (Validator.isEmpty(sedeLegaleStr)) {
			errors.add("sedeLegaleStr", new ValidationError("Campo obbligatorio"));
		} else {
			try {
				sedeLegaleStr = StringUtils.trim(sedeLegaleStr);
				String provinciaStr = StringUtils.trim(request.getParameter("provinciaStr"));
				//System.err.println("sedeLegaleStr = ["+sedeLegaleStr+"]");
				//System.err.println("provinciaStr = ["+provinciaStr+"]");
				String istatComune = umaFacadeClient.ricercaCodiceComuneNonEstinto(sedeLegaleStr, provinciaStr);
				if (istatComune == null) {
					errors.add("sedeLegaleStr", new ValidationError("Comune inesistente"));
				} else {
					// In base alle if precedenti sono sicuro che l'elemento con indice 0 esista
					form.setIstatComune(istatComune);
				}
			} catch (SolmrException e) {
				e.printStackTrace();
				errors.add("sedeLegaleStr", new ValidationError("Comune inesistente"));
			}
		}
		if (!StringUtils.isStringEmpty(form.getIdAzienda())) {
			if (Validator.isEmpty(indirizzoSedeLegale)) {
				errors.add("indirizzoSedeLegaleStr", new ValidationError("Campo obbligatorio"));
			}
		}

		// ----------- Controlli uso del suolo -----------
		SolmrLogger.debug(this, " --- Controlli uso del suolo");
		if (Validator.isEmpty(usoSuolo)) {
			errors.add("usoSuolo", new ValidationError("Campo obbligatorio"));
		} else {
			lavContoTerziInsert.setIdCategoriaUtilizziUma(new Long(usoSuolo));
		}

		// Controlli Lavorazione
		SolmrLogger.debug(this, " --- Controlli Lavorazione");
		SolmrLogger.debug(this, "idLavorazione vale: " + idLavorazione);
		if (Validator.isEmpty(idLavorazione)) {

			errors.add("idLavorazione", new ValidationError("Campo obbligatorio"));
		} else {
			StringTokenizer st = new StringTokenizer(idLavorazione, "|");
			if (st.hasMoreTokens()) {
				//form.setIdLavorazone(st.nextToken());
				lavContoTerziInsert.setIdLavorazoni(new Long(st.nextToken()));
			}
		}

		String esecuzioniStr = request.getParameter("numeroEsecuzioni");
		String macchinaUtilizzata = request.getParameter("idMacchina");
		String supOreStr = request.getParameter("supOreStr");
		String supOreFatturaStr = request.getParameter("supOreFatturaStr");
		String consumoDichiarato = request.getParameter("consumoDichiarato");
		String gasolioStr = request.getParameter("gasolioStr");
		String benzinaStr = request.getParameter("benzinaStr");
		String numeroFattura = request.getParameter("numeroFattura");
		String note = request.getParameter("note");
		String litriAcclivitaStr = request.getParameter("litriAcclivita");

		String eccedenzaStr = request.getParameter("eccedenza");
		String consumoCalcolatoStr = request.getParameter("consumiCalcolati");

		lavContoTerziInsert.setEsecuzioniStr(esecuzioniStr);
		lavContoTerziInsert.setSupOreStr(supOreStr);
		lavContoTerziInsert.setSupOreFatturaStr(supOreFatturaStr);
		lavContoTerziInsert.setLitriAcclivitaStr(litriAcclivitaStr);

		SolmrLogger.debug(this, " --- Controlli Note");
		if (!StringUtils.isStringEmpty(note)) {
			if (note.length() > 1000) {
				errors.add("note", new ValidationError("Il valore immesso non deve superare i 1000 caratteri"));
			} else {
				lavContoTerziInsert.setNote(note);
			}
		}

		SolmrLogger.debug(this, " --- Controlli Numero fattura");
		if (StringUtils.isStringEmpty(numeroFattura)) {
			errors.add("numeroFattura", new ValidationError("Campo obbligatorio"));
		} else if (!StringUtils.isStringEmpty(numeroFattura)) {
			if (numeroFattura.length() > 200) {
				errors.add("numeroFattura", new ValidationError("Il valore immesso non deve superare i 200 caratteri"));
			} else {
				lavContoTerziInsert.setNumeroFatture(numeroFattura);
			}
		}

		// Controlli Numero esecuzioni
		SolmrLogger.debug(this, " ----- Controlli Numero esecuzioni -----");
		SolmrLogger.debug(this, " -- numero massimo di esecuzioni =" + form.getMaxEsecuzioni());
		SolmrLogger.debug(this, " -- Numero esecuzioni inserito =" + esecuzioniStr);
		long esecuzioniInput = 0;
		if (Validator.isEmpty(esecuzioniStr)) {
			errors.add("esecuzioniStr", new ValidationError("Campo obbligatorio"));
		} else {
			try {
				esecuzioniInput = Long.parseLong(esecuzioniStr);
			} catch (Exception ex) {
				errors.add("esecuzioniStr", new ValidationError("Inserire un valore numerico intero"));
			}
			if (esecuzioniInput < 0 || esecuzioniInput == 0) {
				errors.add("esecuzioniStr", new ValidationError("Inserire un valore numerico maggiore di zero"));
			} else {
				//Se FLAG_ESCLUDI_ESECUZIONI = 'N', ed è previsto un massimo -> controllo il max esecuzioni
				if (form.getFlagEscludiEsecuzioni() != null && form.getFlagEscludiEsecuzioni().equalsIgnoreCase("N") && !StringUtils.isStringEmpty(form.getMaxEsecuzioni())) {
					SolmrLogger.debug(this, "--- controllare che non sia stato inserito un numero > del massimo consentito");
					long numeroEsecuzioni = Long.parseLong(form.getMaxEsecuzioni());
					SolmrLogger.debug(this, " -- numero massimo di esecuzioni =" + numeroEsecuzioni);
					SolmrLogger.debug(this, " -- numero esecuzioni indicato =" + esecuzioniInput);
					if (esecuzioniInput > numeroEsecuzioni) {
						errors.add("esecuzioniStr", new ValidationError("Non è possibile aumentare il valore del numero esecuzioni"));
					} else {
						lavContoTerziInsert.setNumeroEsecuzioni(new Long(esecuzioniInput));
					}
				} else {
					lavContoTerziInsert.setNumeroEsecuzioni(new Long(esecuzioniInput));
				}
			}
		}

		// Controlli legati all'unità di misura
		SolmrLogger.debug(this, " ----- Controlli legati all'unità di misura -----");
		// NOTE : PER LA TOBECONFIG ABBIAMO TOLTO LA VISUALIZZAZIONE DELLA COMBO MACCHINE, QUINDI COMMENTIAMO LA VALIDAZIONE SU QUESTO CAMPO
		if (!StringUtils.isStringEmpty(form.getTipoUnitaMisura()) && form.getTipoUnitaMisura().equalsIgnoreCase("T")) {
			SolmrLogger.debug(this, " -- CASO unita' di misura = TEMPO");
			/*SolmrLogger.debug(this, " -- CASO unita' di misura = TEMPO");

			SolmrLogger.debug(this, " --- Controlli sul campo Macchina");
			SolmrLogger.debug(this, " -- idMacchina =" + macchinaUtilizzata);
			if (Validator.isEmpty(macchinaUtilizzata)) {
				errors.add("idMacchina", new ValidationError("Campo obbligatorio"));
			} else {
				StringTokenizer token = new StringTokenizer(macchinaUtilizzata, "|");
				lavContoTerziInsert.setIdMacchinaStr(token.nextToken());
				SolmrLogger.debug(this, "idMacchina ke setto nel vo di insert vale: " + lavContoTerziInsert.getIdMacchinaStr());
			}*/
		}

		SolmrLogger.debug(this, "Nel validate idUnitaMisura da salvare vale: " + form.getIdUnitaMisura());
		if (!StringUtils.isStringEmpty(form.getIdUnitaMisura())) {
			lavContoTerziInsert.setIdUnitaMisura(new Long(form.getIdUnitaMisura()));
		}

		// -- ** Solo se è stata selezionata la lavorazione bisogna effettuare il controllo sui campi 'Sup(ha)/Ore' ** -- 

		SolmrLogger.debug(this, "-- supOreStr =" + supOreStr);
		SolmrLogger.debug(this, "-- idLavorazione =" + idLavorazione);

		// ---- Controlli sui campi Sup(ha) e Ore
		if (idLavorazione != null && !idLavorazione.trim().equals("")) {
			SolmrLogger.debug(this, "----  Controlli sui campi Sup(ha) e Ore");

			// Se non ci sono errori sul campo 'Numero esecuzioni'
			if (errors.get("esecuzioniStr") == null) {

				if (!StringUtils.isStringEmpty(form.getIdAzienda())){
					lavContoTerziInsert.setExtIdAzienda(new Long(form.getIdAzienda()));
				}
				
				if(form.getLavAScavalco() == null || form.getLavAScavalco() < 1){
				//Questi controlli vanno esclusi se si tratta di lavorazione a scavalco
					if (SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(form.getTipoUnitaMisura()) || SolmrConstants.TIPO_UNITA_MISURA_K.equalsIgnoreCase(form.getTipoUnitaMisura())) {
						// --------- *** Controlli comuni per il campo 'Superficie' ed il campo 'Ore' ***
						
						// NOTE : PER LA TOBECONFIG tolto il controllo : se viene selezionato un Uso del Suolo che non è in fascicolo per l'azienda indicata, questo campo non può essere valorizzato
						// Il campo deve essere valorizzato
						/*if (Validator.isEmpty(supOreStr)) {
							errors.add("supOreStr", new ValidationError("Campo obbligatorio"));
						}
						else {*/
						SolmrLogger.debug(this, "-- supOreStr ="+supOreStr);
						if(Validator.isNotEmpty(supOreStr)){						
							try {
								BigDecimal supOre = null;
								// Il campo deve essere un numerico
								// try{
								supOre = new BigDecimal(supOreStr.replace(',', '.'));
								// }
								/*catch(Exception ex){
								  errors.add("supOreStr", new ValidationError("Campo non numerico"));
								}	
								 */
								 
								 // NOTE : TOLTO CONTROLLO PER LA TOBECONFIG
								// Il campo deve essere > 0
								/*BigDecimal supZero = new BigDecimal(0);
								if (supOre.compareTo(supZero) < 0 || supOre.compareTo(supZero) == 0) {
									errors.add("supOreStr", new ValidationError("Indicare un valore maggiore di zero"));
								} else {*/
									
									// Il campo può avere al massimo 10 cifre intere e 4 decimali
									if (!Validator.validateDoubleDigit(supOreStr, 10, 4)) {
										errors.add("supOreStr", new ValidationError("Il valore può avere al massimo 10 cifre intere e 4 decimali"));
									} else {
										lavContoTerziInsert.setSupOre(supOre);
										// Nel caso in cui l'idAzienda sia valorizzata e l'unità di misura sia 'S' -> calcolo la max superficie disponibile e la propongo
										if (!StringUtils.isStringEmpty(form.getIdAzienda())) {
											SolmrLogger.debug(this, "--- calcolare la superficie disponibile ed effettuare il controllo con la superficie inserita");
											lavContoTerziInsert.setExtIdAzienda(new Long(form.getIdAzienda()));
											try {
												SolmrLogger.debug(this, "nel validator supOreStr vale: %" + supOreStr + "%");
												SolmrLogger.debug(this, "nel validator form.getSupOre() vale: %" + form.getSupOre() + "%");
												SolmrLogger.debug(this, "nel validator form.getSuperficie() vale: " + form.getSuperficie());
												SolmrLogger.debug(this, "nel validator  form.getTipoUnitaMisura() vale: " + form.getTipoUnitaMisura());

												// ------ Controlli solo per il campo SUPERFICIE
												if (!StringUtils.isStringEmpty(form.getSuperficie()) && SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(form.getTipoUnitaMisura())) {
													BigDecimal superficieForm = new BigDecimal(form.getSuperficie().replace(',', '.'));
													SolmrLogger.debug(this, "nel validator supOre vale: %" + supOre + "%");
													String umps = umaFacadeClient.getParametro(SolmrConstants.PARAMETRO_COEFFICIENTE_SUPERFICIE_LAV_CONTO_TERZI);
													Long umpsLong = NumberUtils.parseLong(umps);
													if (umpsLong == null) {
														throw new SolmrException(
																"Attenzione! si è verificato un errore grave. Se il problema persiste contattare l'assistenza tecnica comunicando il seguente messaggio: PARAMETRO "
																		+ SolmrConstants.PARAMETRO_COEFFICIENTE_SUPERFICIE_LAV_CONTO_TERZI + " non valido o assente");
													}
													BigDecimal delta = superficieForm.multiply(new BigDecimal(umpsLong.longValue())).setScale(4).divide(new BigDecimal(100), BigDecimal.ROUND_HALF_UP);
													BigDecimal supMax = superficieForm.add(delta);

													BigDecimal maxEsecuzioniBD = Validator.isNotEmpty(form.getMaxEsecuzioni()) ? new BigDecimal(form.getMaxEsecuzioni()) : new BigDecimal("1");

													supMax = supMax.multiply(maxEsecuzioniBD).setScale(4, BigDecimal.ROUND_HALF_UP);

													BigDecimal supOreEsecuzioni = new BigDecimal(supOre.doubleValue());
													if (form.getFlagEscludiEsecuzioni().equalsIgnoreCase("N")) {
														BigDecimal esecuzioniInputBD = Validator.isNotEmpty(esecuzioniInput) ? new BigDecimal(esecuzioniInput) : new BigDecimal("1");
														supOreEsecuzioni = supOreEsecuzioni.multiply(esecuzioniInputBD).setScale(4, BigDecimal.ROUND_HALF_UP);
													} else {
														supOreEsecuzioni = supOreEsecuzioni.setScale(4, BigDecimal.ROUND_HALF_UP);
													}

													if (supOreEsecuzioni.compareTo(supMax) > 0) {
														String msgSupDisponibile = "Non è possibile aumentare il valore della superficie oltre il " + umps + "% (valore massimo consentito "
																+ StringUtils.formatDouble4(supMax) + " ha ";
														if (form.getFlagEscludiEsecuzioni().equalsIgnoreCase("N")) {
															msgSupDisponibile += ", al netto di " + lavContoTerziInsert.getNumeroEsecuzioni() + " esecuzioni).";
														} else {
															msgSupDisponibile += ").";
														}
														errors.add("supOreStr", new ValidationError(msgSupDisponibile));
													} else {
														SolmrLogger.debug(this, "--- setto supOreCalcolata =" + supOre);
														lavContoTerziInsert.setSupOreCalcolata(supOre);
													}
												}// FINE controlli solo campo SUPERFIICIE      
												if (SolmrConstants.TIPO_UNITA_MISURA_K.equalsIgnoreCase(form.getTipoUnitaMisura())){
													lavContoTerziInsert.setSupOreCalcolata(supOre);
												}
											} catch (SolmrException ex) {
												throw ex;
											} catch (Exception ex) {
												SolmrLogger.error(this, "Exception" + ex.getMessage());
												errors.add("supOreStr", new ValidationError("Campo non numerico"));
											}
										}
									}
								//} // NOTE : TOLTO CONTROLLO PER LA TOBECONFIG
							} catch (Exception ex) {
								errors.add("supOreStr", new ValidationError("Campo non numerico"));
							}
						}
					} else{
						lavContoTerziInsert.setSupOreCalcolata(null);
					}
				}
				else{
					BigDecimal supOre = null;
					supOre = new BigDecimal(supOreStr.replace(',', '.'));
					lavContoTerziInsert.setSupOreCalcolata(supOre);
				}
			}
		}

		// ---- Controlli sui campi Sup(ha) Fattura e Ore Fattura
		// -- ** Solo se è stata selezionata la lavorazione bisogna effettuare il controllo sui campi 'Sup(ha)/Ore Fattura' ** -- 
		SolmrLogger.debug(this, "idLavorazione vale: " + idLavorazione);
		if (idLavorazione != null && !idLavorazione.trim().equals("")) {
			SolmrLogger.debug(this, "---- -- Controlli sui campi Sup(ha) Fattura e Ore Fattura");
			SolmrLogger.debug(this, "supOreFatturaStr =" + supOreFatturaStr);
			if (Validator.isEmpty(supOreFatturaStr)) {
				errors.add("supOreFatturaStr", new ValidationError("Campo obbligatorio"));
			} else {
				try {
					BigDecimal supOreFattura = new BigDecimal(supOreFatturaStr.replace(',', '.'));
					// Il campo deve essere > 0
					BigDecimal supZero = new BigDecimal(0);
					if (supOreFattura.compareTo(supZero) < 0 || supOreFattura.compareTo(supZero) == 0) {
						errors.add("supOreFatturaStr", new ValidationError("Indicare un valore maggiore di zero"));
					} else if (!Validator.validateDoubleDigit(supOreFatturaStr, 10, 4)) {
						errors.add("supOreFatturaStr", new ValidationError("Il valore può avere al massimo 10 cifre intere e 4 decimali"));
					} else {
						SolmrLogger.debug(this, "SONO NEL VALIDATE E SETTO SUPORECALCOLATA CON :" + supOreFattura);
						lavContoTerziInsert.setSupOreFattura(supOreFattura);
					}
				} catch (Exception ex) {
					errors.add("supOreFatturaStr", new ValidationError("Campo non numerico"));
				}
			}

			if (Validator.isEmpty(consumoDichiarato)) {
				errors.add("consumoDichiarato", new ValidationError("Campo obbligatorio"));
			} else {
				try {
					BigDecimal consumoDichiaratoB = new BigDecimal(consumoDichiarato.replace(',', '.'));
					// Il campo deve essere > 0
					BigDecimal supZero = new BigDecimal(0);
					if (consumoDichiaratoB.compareTo(supZero) < 0 || consumoDichiaratoB.compareTo(supZero) == 0) {
						errors.add("consumoDichiarato", new ValidationError("Indicare un valore maggiore di zero"));
					} else if (!Validator.validateDoubleDigit(supOreFatturaStr, 10, 4)) {
						errors.add("consumoDichiarato", new ValidationError("Il valore può avere al massimo 10 cifre intere e 4 decimali"));
					}
				} catch (Exception ex) {
					errors.add("consumoDichiarato", new ValidationError("Campo non numerico"));
				}
			}
		}

		lavContoTerziInsert.setConsumoDichiaratoStr(consumoDichiarato);
		lavContoTerziInsert.setEccedenzaStr(eccedenzaStr);
		lavContoTerziInsert.setConsumoCalcolatoStr(consumoCalcolatoStr);

		// --------- Se è stata scelta la lavorazione ed è stato valorizzato il campo 'litriAcclività', controllare il campo
		if (idLavorazione != null && !idLavorazione.trim().equals("")) {
			SolmrLogger.debug(this, "--- litriAcclivitaStr =" + litriAcclivitaStr);
			if (!Validator.isEmpty(litriAcclivitaStr)) {
				SolmrLogger.debug(this, "--- Sono necessari i controlli sul campo 'litriAcclivita'");
				// Deve essere un campo numerico positivo con due numeri decimali
				try {
					BigDecimal litriAcclivitaBd = new BigDecimal(litriAcclivitaStr.replace(',', '.'));
					SolmrLogger.debug(this, "--- litriAcclivitaBd =" + litriAcclivitaBd);
					// Il campo deve essere > -1
					BigDecimal valConfronto = new BigDecimal(-1);
					if (litriAcclivitaBd.compareTo(valConfronto) < 0 || litriAcclivitaBd.compareTo(valConfronto) == 0) {
						SolmrLogger.debug(this, "--- litri acclività deve essere un numero positivo");
						errors.add("litriAcclivita", new ValidationError("Indicare un valore positivo"));
					}
					// deve avere 2 numeri decimali	      
					else if (!Validator.validateDoubleDigit(litriAcclivitaStr, 10, 2)) {
						SolmrLogger.debug(this, "--- litri acclività può avere al massimo 10 cifre intere e 2 decimali");
						errors.add("litriAcclivita", new ValidationError("Il valore può avere al massimo 10 cifre intere e 2 decimali"));
					}
					
					// il valore non può essere maggiore del lavore calcolato
					else {
						// NOTE : PER LA TOBECONFIG : NON SI DEVE FARE IL CONTROLLO SOTTO SE litri acclività VALE 0					
					  if(litriAcclivitaBd.compareTo(new BigDecimal(0)) != 0){						 					 
						String maxLitriAcclivitaStr = form.getMaxLitriAcclivita();
						SolmrLogger.debug(this, "-- il valore di litriAcclivitaBd non puo' essere maggiore del valore calcolato maxLitriAcclivitaStr ="+maxLitriAcclivitaStr);
						BigDecimal maxLitriAcclivita = new BigDecimal(maxLitriAcclivitaStr.replace(',', '.'));
						if (litriAcclivitaBd.compareTo(maxLitriAcclivita) == 1) {
							SolmrLogger.debug(this, "--- litri acclività non può superare il valore calcolato =" + maxLitriAcclivita);
							errors.add("litriAcclivita", new ValidationError("Il valore di litri per acclività non può essere maggiore di " + maxLitriAcclivitaStr + " litri"));
						} else {
							SolmrLogger.debug(this, "--- il valore litriAcclivita è corretto =" + litriAcclivitaBd);
							lavContoTerziInsert.setLitriAcclivita(litriAcclivitaBd);
						}
					  }	
					}

				} catch (Exception ex) {
					SolmrLogger.error(this, "-- Exception controllo litriAcclivita ="+ex.getMessage());				
					errors.add("litriAcclivita", new ValidationError("Campo non numerico"));
				}
			}
			// se il campo non è valorizzato metto il valore zero (il campo db è NotNullable)
			else {
				lavContoTerziInsert.setLitriAcclivita(new BigDecimal(0));
			}
		}

		// ---- Controlli sui campi gasolio e benzina
		SolmrLogger.debug(this, "-- Controlli sui campi gasolio e benzina");
		if (Validator.isEmpty(gasolioStr) && Validator.isEmpty(benzinaStr)) {
			errors.add("gasolioStr", new ValidationError("Valorizzare uno dei due campi: G(lt) o B(lt)"));
			errors.add("benzinaStr", new ValidationError("Valorizzare uno dei due campi: G(lt) o B(lt)"));
		} else if (!Validator.isEmpty(gasolioStr) && !Validator.isEmpty(benzinaStr)) {
			errors.add("gasolioStr", new ValidationError("Valorizzare solo uno dei due campi: G(lt) o B(lt)"));
			errors.add("benzinaStr", new ValidationError("Valorizzare solo uno dei due campi: G(lt) o B(lt)"));
		} else {
			if (!Validator.isEmpty(gasolioStr)) {
				try {
					SolmrLogger.debug(this, "Nel validate gasolioStr: " + gasolioStr);
					SolmrLogger.debug(this, "Nel validate form.getMaxCarburante(): " + form.getMaxCarburante());
					long gasolio = Long.parseLong(gasolioStr);
					if (!Validator.isEmpty(form.getMaxCarburante()) && gasolio > Long.parseLong(form.getMaxCarburante())) {
						errors.add("gasolioStr", new ValidationError("Il valore gasolio non può essere maggiore di " + form.getMaxCarburante() + " litri"));
					} else if (gasolio < 0) {
						errors.add("gasolioStr", new ValidationError("Non è possibile inserire un valore negativo"));
					} else {
						lavContoTerziInsert.setGasolioStr(gasolioStr);
					}

				} catch (Exception ex) {
					errors.add("gasolioStr", new ValidationError("Campo non numerico"));
				}
			}
			if (!Validator.isEmpty(benzinaStr)) {
				try {
					long benzina = Long.parseLong(benzinaStr);
					SolmrLogger.debug(this, "benzina: " + benzina);
					SolmrLogger.debug(this, "form.getMaxCarburante(): " + form.getMaxCarburante());
					if (!Validator.isEmpty(form.getMaxCarburante()) && benzina > Long.parseLong(form.getMaxCarburante())) {
						errors.add("benzinaStr", new ValidationError("Non è possibile aumentare la quantità"));
					} else if (benzina < 0) {
						errors.add("benzinaStr", new ValidationError("Non è possibile inserire un valore negativo"));
					} else {
						lavContoTerziInsert.setBenzinaStr(benzinaStr);
					}
				} catch (Exception ex) {
					errors.add("benzinaStr", new ValidationError("Campo non numerico"));
				}
			}
		}
		SolmrLogger.debug(this, "10..");

		if (errors.size() == 0) {
			AnagAziendaVO anag = new AnagAziendaVO();
			anag.setCUAA(form.getCuaa());
			anag.setPartitaIVA(form.getPartitaIva());
			anag.setDenominazione(form.getDenominazione());
			//In anagrafe un parametro di ricerca non specificato qui sopra
			// corrisponde anche al caso del parametro vuoto
			//Se si vogliono verificare questi casi bisogna implementare un
			// equals nel for sotto per verificare che l'utente non abbia
			// modificato i parametri di ricerca prima di salvare
			Vector vettAziende = umaFacadeClient.serviceGetListIdAziende(anag, new Boolean(false), new Boolean(false));
			if (vettAziende != null && vettAziende.size() > 0) {
				boolean aziendaFound = false;
				if (form.getIdAzienda() != null) {
					for (int cntAziende = 0; cntAziende < vettAziende.size(); cntAziende++) {
						Long idAziendSearched = (Long) vettAziende.get(cntAziende);
						if (new Long(form.getIdAzienda()).longValue() == idAziendSearched.longValue()) {
							aziendaFound = true;
						}
					}
				}
				if (form.getIdAzienda() == null || !aziendaFound) {
					String msgAziendeAnagrafeNonCercata = "Il CUAA indicato e'' presente nell''Anagrafe delle imprese agricole ed agroalimentari: indicare l''azienda selezionando il pulsante 'Cerca azienda'";
					//throw new Exception(msgAziendeAnagrafeNonCercata);
					errors.add("cuaaStr", new ValidationError(msgAziendeAnagrafeNonCercata));
				}
			} else {
				//Se l'azienda non è presente in anagrafe
				String paramVerificaAziendeAnagrafe = umaFacadeClient.getParametro(SolmrConstants.PARAMETRO_VERIFICA_AZIENDE_ANAGRAFE);
				//String msgVerificaAziendeAnagrafe = "Operazione non permessa. L''azienda indicata non e'' presente su SIAP.";
				if (paramVerificaAziendeAnagrafe.equalsIgnoreCase(SolmrConstants.FLAG_SI)) {
					//throw new Exception(msgVerificaAziendeAnagrafe);
					errors.add("cuaaStr", new ValidationError(msgVerificaAziendeAnagrafe));
				}
			}
		}

		Long maxEsecuzioniLong = (Validator.isNotEmpty(form.getMaxEsecuzioni()) ? new Long(form.getMaxEsecuzioni()) : null);
		SolmrLogger.debug(this, "-- maxEsecuzioniLong =" + maxEsecuzioniLong);
		//Numero max di lavorazioni consentite, controllato solo se su db il campo
		// DB_CATEG_COLTURA_LAVORAZIONI.MAX_ESECUZIONI è specificato, ed è maggiore di 0,
		// per quell'uso del suolo, e quella lavorazione

		// ----- Controllo se ci sono già altre lavorazioni con gli stessi dati inseriti
		if (errors.size() == 0) {
			SolmrLogger.debug(this, "--- Controllare se ci sono già altre lavorazioni con gli stessi dati");

			LavorazioniFilterVO lavorazioniFilter = new LavorazioniFilterVO(annoCampagnaVO.getAnnoCampagna(), form.getIdUsoSuolo(), form.getIdLavorazone(), form.getIdAzienda(), form.getCuaa(), ""
					+ dittaUMAAziendaVO.getIdDittaUMA(), null);
			String countDistintLavorazioniContoTerzi = umaFacadeClient.countDistintLavorazioniContoTerzi(lavorazioniFilter);
			SolmrLogger.debug(this, "- countDistintLavorazioniContoTerzi =" + countDistintLavorazioniContoTerzi);

			if (new Long(countDistintLavorazioniContoTerzi).longValue() > 0) {
				SolmrLogger.debug(this, "--- Ci sono gia lavorazioni con gli stessi dati!");
				String msgNumeroMaxLavorazioniConsentite = "Per azienda, uso del suolo e lavorazione indicati e'' gia'' presente a sistema una lavorazione. Impossibile procedere con l''inserimento.";
				errors.add("cuaaStr", new ValidationError(msgNumeroMaxLavorazioniConsentite));
				errors.add("usoSuolo", new ValidationError(msgNumeroMaxLavorazioniConsentite));
				errors.add("idLavorazione", new ValidationError(msgNumeroMaxLavorazioniConsentite));
			}
		}
		// ------- Controllo che nella tabella di riepilogo non ci sia già una lavorazione con gli stessi dati inseriti (controllo sugli stessi campi sopra)
		if (errors.size() == 0) {
			SolmrLogger.debug(this, "--- Controllo che nella tabella di riepilogo non ci sia già una lavorazione con gli stessi dati inseriti (controllo sugli stessi campi sopra)");
			String idUsoDelSuolo = form.getIdUsoSuolo();
			String idLav = form.getIdLavorazone();
			String idAzienda = form.getIdAzienda();
			String cuaaIns = form.getCuaa();

			int posizioneLavorazioneGiaPresente = -1;

			// Verifico se bisogna fare il controllo con idAzienda o con cuaa
			if (idAzienda != null && !idAzienda.trim().equals("")) {
				posizioneLavorazioneGiaPresente = controlloPresenzaLavRiepilogoConIdAzienda(idUsoDelSuolo, idLav, idAzienda, session);
			} else {
				posizioneLavorazioneGiaPresente = controlloPresenzaLavRiepilogoConCuaa(idUsoDelSuolo, idLav, cuaaIns, session);
			}

			SolmrLogger.debug(this, "-- posizioneLavorazioneGiaPresente =" + posizioneLavorazioneGiaPresente);
			if (posizioneLavorazioneGiaPresente > -1) {
				SolmrLogger.debug(this, "-- La lavorazione e' gia' presente nella tabella di riepilogo!");
				String msgNumeroMaxLavorazioniConsentite = "Per azienda, uso del suolo e lavorazione indicati e'' gia'' presente nella tabella di riepilogo una lavorazione. Impossibile procedere con l''inserimento.";
				errors.add("cuaaStr", new ValidationError(msgNumeroMaxLavorazioniConsentite));
				errors.add("usoSuolo", new ValidationError(msgNumeroMaxLavorazioniConsentite));
				errors.add("idLavorazione", new ValidationError(msgNumeroMaxLavorazioniConsentite));
			}
		}

		// ---------- Errore di Warning ------
		//Cuaa dell'azienda cercata uguale a quella attiva in sessione
		if (errors.size() == 0) {
			String msgAziendaCercataUgualeAllaCollegata = "Attenzione! Si sta inserendo una fattura intestata all''azienda stessa.";
			if (form.getCuaa().equalsIgnoreCase(dittaUMAAziendaVO.getCuaa())) {
				SolmrLogger.debug(this, "--- si sta inserendo una fattura intestata all'azienda stessa!");
				errors.add("cuaaStr", new ValidationError(msgAziendaCercataUgualeAllaCollegata), true);
			}
		}

		request.setAttribute("vLavContoTerzi", lavContoTerziInsert);
		
		/* NOTE : PER TOBECONFIG AGGIUNTO IL CONTROLLO SULL'USO DEL SUOLO SELEZIONATO :
		  La combo Uso del suolo ora carica tutti gli uso del suolo, non solo quelli presenti nel fascicolo dell'azienda indicata.
		  Controllare se l'uso del suolo selezionato è un uso del suolo presente in fascicolo o no. Nel caso in cui non sia nel fascicolo, dare messaggio all'utente:
			"ATTENZIONE: è stato scelto un uso del suolo non presente nel fascicolo 2021 dell'azienda selezionata. 
				Nel caso si voglia comunque procedere con l'inserimento è necessario indicare la motivazione nel campo Note."
	    */	    
		if (Validator.isNotEmpty(usoSuolo) && Validator.isNotEmpty(form.getIdAzienda())) {		  
		  Long usoDelSuoloSelLong = Long.parseLong(usoSuolo);
		  SolmrLogger.debug(this, "--- uso del suolo selezionato ="+usoDelSuoloSelLong);
		  // Controllo se l'uso del suolo selezionato è tra quelli del fascicolo aziendale dell'azienda indicata
		  HashMap<Long,String> usoDelSuoloAziendaHM = (HashMap<Long,String>)session.getAttribute("usoDelSuoloAziendaHM");
		  if(usoDelSuoloAziendaHM != null){
			  String usoDelSuoloDescr = usoDelSuoloAziendaHM.get(usoDelSuoloSelLong);
			  if(Validator.isEmpty(usoDelSuoloDescr)){
				  SolmrLogger.debug(this, "--- L'USO DEL SUOLO SELEZIONATO NON E' TRA QUELLI DEL FASCICOLO AZIENDALE");
				  // Controllo se sono state indicate le Note (obbligatorie in questo caso)
				  if(Validator.isEmpty(note)){
					  SolmrLogger.debug(this, "-- Il campo Note non è stato valorizzato");
					  String msgUsoDelSuoloNonNelFascicoloAziendale ="ATTENZIONE: è stato scelto un uso del suolo non presente nel fascicolo "+annoCampagnaVO.getAnnoCampagna()+" dell''azienda selezionata. Nel caso si voglia comunque procedere con l''inserimento è necessario indicare la motivazione nel campo Note.";
					  errors.add("note", new ValidationError(msgUsoDelSuoloNonNelFascicoloAziendale));
				  }
			  }
		  }		 
		}
		
		
		SolmrLogger.debug(this, "   END validateInsert");
		return errors;
	}

	private int controlloPresenzaLavRiepilogoConIdAzienda(String idUsoDelSuolo, String idLav,String idAzienda,HttpSession session) throws Exception{
    SolmrLogger.debug(this, "   BEGIN controlloPresenzaLavRiepilogoConIdAzienda");
    
    int posizioneLavorazioneGiaPresente = -1;
    // Recupero dalla sessione il vettore con gli elementi della tabella di riepilogo
    Vector<LavContoTerziVO> lavContoTerziVect = (Vector<LavContoTerziVO>)session.getAttribute("lavContoTerziVect");
    if(lavContoTerziVect != null && lavContoTerziVect.size()>0){
      SolmrLogger.debug(this, "-- ci sono delle lavorazioni nella tabella di riepilogo, controllare che non ce ne siano gia' con gli stessi dati inseriti");
      for(int i=0;i<lavContoTerziVect.size();i++){
        LavContoTerziVO lavoraz = lavContoTerziVect.get(i);
        
        // Se è stato indicato un extIdAzienda proseguo con i controlli
        Long extIdAzienda = lavoraz.getExtIdAzienda();
        if(extIdAzienda != null){          
          long idUsoSuoloRiep = lavoraz.getIdCategoriaUtilizziUma().longValue();
          long idLavorazRiep = lavoraz.getIdLavorazoni().longValue();
          long idAziendaRiep = extIdAzienda.longValue();
          
          long idUsoSuolo = new Long(idUsoDelSuolo).longValue();
          long idLavoraz = new Long(idLav).longValue();
          long idAz = new Long(idAzienda).longValue();
          
          if(idUsoSuoloRiep == idUsoSuolo && idLavorazRiep == idLavoraz &&  idAziendaRiep == idAz){
            SolmrLogger.debug(this, "-- esiste gia' una lavorazione nel riepilogo con gli stessi dati");
            posizioneLavorazioneGiaPresente = i;
            return posizioneLavorazioneGiaPresente;
          }          
        }
      } 
    }    
    SolmrLogger.debug(this, "   END controlloPresenzaLavRiepilogoConIdAzienda");
    return posizioneLavorazioneGiaPresente;
  }

	private int controlloPresenzaLavRiepilogoConCuaa(String idUsoDelSuolo,String idLav,String cuaaIns,HttpSession session) throws Exception{
    SolmrLogger.debug(this, "   BEGIN controlloPresenzaLavRiepilogoConCuaa");
    
    int posizioneLavorazioneGiaPresente = -1;
    // Recupero dalla sessione il vettore con gli elementi della tabella di riepilogo
    Vector<LavContoTerziVO> lavContoTerziVect = (Vector<LavContoTerziVO>)session.getAttribute("lavContoTerziVect");
    if(lavContoTerziVect != null && lavContoTerziVect.size()>0){
      SolmrLogger.debug(this, "-- ci sono delle lavorazioni nella tabella di riepilogo, controllare che non ce ne siano gia' con gli stessi dati inseriti");
      for(int i=0;i<lavContoTerziVect.size();i++){
        LavContoTerziVO lavoraz = lavContoTerziVect.get(i);
        
        // Se NON è stato indicato un extIdAzienda proseguo con i controlli
        Long extIdAzienda = lavoraz.getExtIdAzienda();
        if(extIdAzienda == null){          
          long idUsoSuoloRiep = lavoraz.getIdCategoriaUtilizziUma().longValue();
          long idLavorazRiep = lavoraz.getIdLavorazoni().longValue();
          String cuaaRiep = lavoraz.getCuaa().trim().toUpperCase();
          
          long idUsoSuolo = new Long(idUsoDelSuolo).longValue();
          long idLavoraz = new Long(idLav).longValue();
          cuaaIns = cuaaIns.trim().toUpperCase();
          
          if(idUsoSuoloRiep == idUsoSuolo && idLavorazRiep == idLavoraz &&  cuaaRiep.equals(cuaaIns)){
            SolmrLogger.debug(this, "-- esiste gia' una lavorazione nel riepilogo con gli stessi dati");
            posizioneLavorazioneGiaPresente = i;
            return posizioneLavorazioneGiaPresente;
          }          
        }
      } 
    }    
    SolmrLogger.debug(this, "   END controlloPresenzaLavRiepilogoConCuaa");
    return posizioneLavorazioneGiaPresente;
  }

	// Controlla se sul db ci sono già le lavorazioni presenti nella tabella di riepilogo
	// -> se viene tornato un valore >-1 : errore
	private int controlloPresenzaLavorazioneSuDb(HttpSession session, DittaUMAAziendaVO dittaUMAAziendaVO, AnnoCampagnaVO annoCampagnaVO, UmaFacadeClient umaFacadeClient) throws Exception{
    SolmrLogger.debug(this, "   BEGIN controlloPresenzaLavorazioneSuDb");
    
    int posizioneElementoNonValido = -1;
    Vector<LavContoTerziVO> lavContoTerziVect = (Vector<LavContoTerziVO>)session.getAttribute("lavContoTerziVect");
    for(int i=0;i<lavContoTerziVect.size();i++){
      LavContoTerziVO lav = lavContoTerziVect.get(i);
        
      String extIdAzienda = null;
      if(lav.getExtIdAzienda() != null)
        extIdAzienda = lav.getExtIdAzienda().toString();
          
      LavorazioniFilterVO lavorazioniFilter = new LavorazioniFilterVO(annoCampagnaVO.getAnnoCampagna(), 
                                                      lav.getIdCategoriaUtilizziUma().toString(), 
                                                      lav.getIdLavorazoni().toString(),
                                                      extIdAzienda,
                                                      lav.getCuaa(),
                                                       ""+dittaUMAAziendaVO.getIdDittaUMA(),null);               
        
      String countDistintLavorazioniContoTerzi = umaFacadeClient.countDistintLavorazioniContoTerzi(lavorazioniFilter);    	
      SolmrLogger.debug(this, "- countDistintLavorazioniContoTerzi ="+countDistintLavorazioniContoTerzi);
    	
      if(new Long(countDistintLavorazioniContoTerzi).longValue()>0){
        SolmrLogger.debug(this, "--- Ci sono gia lavorazioni con gli stessi dati!");
    	SolmrLogger.debug(this, "--- elemento nella posizione ="+i);
    	posizioneElementoNonValido = i;
    	SolmrLogger.debug(this, "   END controlloPresenzaLavorazioneSuDb");
    	return posizioneElementoNonValido;
      }    
    }// ciclo sulle lavorazioni presenti nella tabella di riepilogo   
    
    SolmrLogger.debug(this, "   END controlloPresenzaLavorazioneSuDb");
    return posizioneElementoNonValido;    
  }

	private void addStringForDescMacchina(StringBuffer sb, String value) {
		if (Validator.isNotEmpty(value)) {
			if (sb.length() > 0) {
				sb.append(" - ");
			}
			sb.append(value);
		}
	}%>

