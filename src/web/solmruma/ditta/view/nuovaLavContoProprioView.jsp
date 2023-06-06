<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.dto.uma.form.AggiornaContoProprioFormVO"%>
<%@ page import="it.csi.solmr.dto.filter.LavContoProprioFilter"%>

<%
  String layout = "/ditta/layout/nuovaLavContoProprio.htm";
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layout);
%>
  <%@include file="/include/menu.inc"%>
<%

  SolmrLogger.debug(this, "   BEGIN nuovaLavContoProprioView");
  
  ValidationErrors errors = (ValidationErrors) request.getAttribute("errors");
  AggiornaContoProprioFormVO form = (AggiornaContoProprioFormVO) session.getAttribute("formInserimentoCP");
  
  // Anno campagna (fisso: anno corrente settato dalla pagina di elenco Lavorazioni Conto Proprio)
  String annoCampagna = ((LavContoProprioFilter)session.getAttribute("filterRicercaLavContoProprio")).getAnnoDiRiferimento();
  SolmrLogger.debug(this, " -- annoCampagna ="+annoCampagna);
  htmpl.set("annoCampagna", annoCampagna);
  
  // --- Popolo la combo 'Uso del Suolo'      
  boolean isUsoDelSuoloSelezionato = popoloComboUsoDelSuolo(form,htmpl);
  boolean isOnChangeComboUsoSuolo = "true".equals(request.getParameter("hdnOnChangeComboUsoSuolo"));
  
  // --- Popolo la combo 'Lavorazione' (se è stato selezionato un Uso del suolo)
  SolmrLogger.debug(this, "---- isUsoDelSuoloSelezionato ="+isUsoDelSuoloSelezionato);
  SolmrLogger.debug(this, "---- isOnChangeComboUsoSuolo ="+isOnChangeComboUsoSuolo);
  popoloComboLavorazioni(form, htmpl, isUsoDelSuoloSelezionato, isOnChangeComboUsoSuolo);
  
  
  // --- Popolo la combo 'Motivazione lavorazione'
  SolmrLogger.debug(this, "--- Popolo la combo 'Motivazione lavorazione'");
  popoloComboMotivoLavorazione(form, htmpl, session);
    
  
  // --- Valorizzo il campo 'Numero esecuzioni' (se è stato selezionata 'Lavorazione')  
  SolmrLogger.debug(this, "--- numeroEsecuzioni ="+ form.getNumeroEsecuzioni());
  SolmrLogger.debug(this, "--- maxEsecuzioni ="+ form.getMaxEsecuzioni());
  if (!StringUtils.isStringEmpty(form.getNumeroEsecuzioni())){
   	htmpl.set("esecuzioniStr", form.getNumeroEsecuzioni());
  }
  else{
   	htmpl.set("esecuzioniStr", form.getMaxEsecuzioni());
  }      
    
  // --- Valorizzo il campo 'Unita di misura'
  if(!StringUtils.isStringEmpty(form.getCodiceUnitaMisura()))
   	 htmpl.set("unitaDiMisura", form.getCodiceUnitaMisura());
   	 
   	 
   	 
  // ---- Combo 'Macchina utilizzata' : non è sempre visualizzata, solo quando db_unita_misura.tipo = 'T'
  popoloComboMacchina(form,htmpl);
   	  
  
  // Sup. (ha)/ Ore 	  
  if (!isOnChangeComboUsoSuolo){  	 
  	if(!StringUtils.isStringEmpty(form.getSupOre())){
  	  htmpl.set("supOreStr", form.getSupOre());
  	}
  	else if(!StringUtils.isStringEmpty(form.getSuperficieCalcolata()) && 
  	     (!StringUtils.isStringEmpty(form.getTipoUnitaMisura()) &&
  	      (SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(form.getTipoUnitaMisura())
  	      || SolmrConstants.TIPO_UNITA_MISURA_K.equalsIgnoreCase(form.getTipoUnitaMisura()))
  	      )){
    	SolmrLogger.debug(this,"--- superficie da visualizzare ="+form.getSuperficieCalcolata());
  		htmpl.set("supOreStr",form.getSuperficieCalcolata());
  	}
  } 
  
  
  // Litri carburante, litri base, litri acclività CALCOLATI
  htmpl.set("litriCarburante", form.getLitriCarburante());
  htmpl.set("litriBaseCalcolati", form.getLitriBaseCalcolati());
  htmpl.set("litriMedioImpastoCalcolati", form.getLitriMedioImpastoCalcolati());
  htmpl.set("litriAcclivita", form.getLitriAcclivita());
  
  // Note
  htmpl.set("note",form.getNote());
  
  
  // Campi hidden - legati alla Lavorazione selezionata (per il calcolo del carburante)
  htmpl.set("litriBase", form.getLitriBase());
  htmpl.set("litriMedioImpasto", form.getLitriMedioImpasto());
  htmpl.set("litriTerDeclivi", form.getLitriTerDeclivi());
  htmpl.set("cavalli", form.getCavalli());	
  htmpl.set("coefficiente", form.getCoefficiente());  
  htmpl.set("flagAsservimento", form.getFlagAsservimento());
  htmpl.set("supTotaleCalcolata", form.getSuperficieCalcolata());
  htmpl.set("supMontagnaCalcolata", form.getSuperficieMontagna());
  htmpl.set("tipoUnitaMisura", form.getTipoUnitaMisura());
  htmpl.set("flagEscludiEsecuzioni", form.getFlagEscludiEsecuzioni());

  
  if (errors != null && errors.size() > 0){    
    htmpl.set("eseguiCalcolaCarb", "false");
  }
  
  // --- Gestione visualizzazione degli errori  
  SolmrLogger.debug(this,"--- setErrors");
  setErrors(htmpl, errors, request);
  
  HtmplUtil.setErrors(htmpl, errors, request);

  Long errorType = (Long) request.getAttribute("errorType");
  
  String onLoad = "";
  if( errorType != null && errorType.intValue()==SolmrConstants.VALIDAZIONE_KO_WARNING){
    onLoad = "confermaWarning()";
  }
  else{
    onLoad = "calcoloCarburante()";
  }
  SolmrLogger.debug(this, "-- onLoad = "+onLoad);
  htmpl.set("onLoad", onLoad);
  
  // ---- Se ci sono delle lavorazioni da visualizzare nella tabella di riepilogo, viene popolata la tabella
   popolaTabellaDiRiepilogo(htmpl,session,request);
  
  
  
  HtmplUtil.reparseTemplate(htmpl);
  HtmplUtil.setErrors(htmpl, errors, request);
  
  
   

  out.print(htmpl.text());
%>
<%!
  private void popoloComboMacchina(AggiornaContoProprioFormVO form, Htmpl htmpl) throws Exception{
    SolmrLogger.debug(this, "   BEGIN popoloComboMacchina");
    try{
      // ---- Se l'unità di misura sono le ore -> visualizzare la combo 'Macchina utilizzata'
      if (form.getTipoUnitaMisura() != null  && form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_T)){
        SolmrLogger.debug(this, "-- Visualizzare la COMBO 'Macchina utilizzata'");
        htmpl.newBlock("blkMacchina");       
        if (form.getVettMacchine() != null && form.getVettMacchine().size() > 0){        
          for (int i = 0; i < form.getVettMacchine().size(); i++){
          	htmpl.newBlock("blkComboMacchina");
          	MacchinaVO elem = (MacchinaVO) form.getVettMacchine().get(i);
          	htmpl.set("blkMacchina.blkComboMacchina.idMacchina", elem
              .getIdMacchina()
              + "|"
              + elem.getMatriceVO().getPotenzaKW()
              + "|"
              + elem.getMatriceVO().getIdAlimentazione());
          	StringBuffer descMacchina = new StringBuffer();
            addStringForDescMacchina(descMacchina, elem.getMatriceVO().getCodBreveGenereMacchina());
          	addStringForDescMacchina(descMacchina, elem.getTipoCategoriaVO().getDescrizione());
          	String tipoMacchina = elem.getMatriceVO().getTipoMacchina();
            if (Validator.isEmpty(tipoMacchina)){
            	addStringForDescMacchina(descMacchina, elem.getDatiMacchinaVO().getMarca());
            }
            else{
              addStringForDescMacchina(descMacchina, tipoMacchina);
            }
            addStringForDescMacchina(descMacchina, elem.getTargaCorrente().getNumeroTarga());

            htmpl.set("blkMacchina.blkComboMacchina.macchinaDesc",descMacchina.toString());            
            if (!StringUtils.isStringEmpty(form.getIdMacchina())){
              StringTokenizer st = new StringTokenizer(form.getIdMacchina(),"|");
              String idM = st.nextToken();                          
              if (idM.equals(elem.getIdMacchina())){
                htmpl.set("blkMacchina.blkComboMacchina.checkedMacchina","selected");
              }
            }
        }// chiusura ciclo
      }
    }
    }
     catch(Exception ex){
      SolmrLogger.error(this, "--- Exception in popoloComboMacchina ="+ex.getMessage());
      throw ex;
    }
    finally{
      SolmrLogger.debug(this, "   END popoloComboMacchina");
    }
    
  }


  private void popoloComboMotivoLavorazione(AggiornaContoProprioFormVO form, Htmpl htmpl, HttpSession session) throws Exception{
    SolmrLogger.debug(this, "   BEGIN popoloComboMotivoLavorazione");
    try{
       Vector<TipoMotivoLavorazioneVO> vettMotivazioneLavorazione = form.getVettMotivoLavorazione();
       if (vettMotivazioneLavorazione != null && vettMotivazioneLavorazione.size() > 0){
         SolmrLogger.debug(this, "---- *** Caricamento della combo 'Motivazione lavorazione' ***");     
         for (int i = 0; i < vettMotivazioneLavorazione.size(); i++){
           TipoMotivoLavorazioneVO elem = (TipoMotivoLavorazioneVO) vettMotivazioneLavorazione.get(i);
           htmpl.newBlock("blkComboMotivoLavoraz");
           htmpl.set("blkComboMotivoLavoraz.idMotivoLavoraz", ""+ elem.getIdMotivoLavorazione());
           htmpl.set("blkComboMotivoLavoraz.motivoLavorazDesc", elem.getDescrizione());
                
           if (form.getIdMotivoLavorazione() != null && form.getIdMotivoLavorazione().equalsIgnoreCase(String.valueOf(elem.getIdMotivoLavorazione()))){
             SolmrLogger.debug(this, "--- idMotivoLavorazione da selezionare nella combo ="+form.getIdMotivoLavorazione());
             htmpl.set("blkComboMotivoLavoraz.checkedMotivoLavoraz", "selected");  
             // setto anche il campo hidden che verrà letto per controllare il valore selezionato nella combo
             htmpl.set("motivoLavorazSel", form.getIdMotivoLavorazione());          
           }
        }
        // se non c'è assegnazione base/saldo validata, la combo sarà disabilitata
        Boolean isPresenteAssegnazValidata = (Boolean)session.getAttribute("isPresenteAssegnazValidata"); 
        if(!isPresenteAssegnazValidata.booleanValue()){        
          SolmrLogger.debug(this, "-- disabilitare la combo 'Motivo lavorazione'");
          htmpl.set("disabledMotivoLavorazione", "disabled");
        }        
      }      
    }
    catch(Exception ex){
      SolmrLogger.error(this, "--- Exception in popoloComboMotivoLavorazione ="+ex.getMessage());
      throw ex;
    }
    finally{
      SolmrLogger.debug(this, "   END popoloComboMotivoLavorazione");
    }
  }


  private boolean popoloComboUsoDelSuolo(AggiornaContoProprioFormVO form, Htmpl htmpl) throws Exception{
    SolmrLogger.debug(this, "   BEGIN popoloComboUsoDelSuolo");
    try{
       Vector vettUsoSuolo = form.getVettUsoSuolo();
  	   boolean isUsoDelSuoloSelezionato = false;
       if (vettUsoSuolo != null && vettUsoSuolo.size() > 0){
         SolmrLogger.debug(this, "---- *** Caricamento della combo 'Uso del suolo' ***");     
         for (int i = 0; i < vettUsoSuolo.size(); i++){
           CategoriaUtilizzoUmaVO elem = (CategoriaUtilizzoUmaVO) vettUsoSuolo.get(i);
           htmpl.newBlock("blkComboUsoSuolo");
           htmpl.set("blkComboUsoSuolo.idUsoSuolo", ""+ elem.getIdCategoriaUtilizzoUma());
           htmpl.set("blkComboUsoSuolo.descUsoSuolo", elem.getDescrizione());
                
           if (form.getIdUsoSuolo() != null && form.getIdUsoSuolo().equalsIgnoreCase(String.valueOf(elem.getIdCategoriaUtilizzoUma()))){
             SolmrLogger.debug(this, "--- idUsoDelSuolo da selezionare nella combo ="+form.getIdUsoSuolo());
             htmpl.set("blkComboUsoSuolo.checkedUsoSuolo", "selected");
             isUsoDelSuoloSelezionato = true;
           }
        }
      }
      return isUsoDelSuoloSelezionato;
    }
    catch(Exception ex){
      SolmrLogger.error(this, "--- Exception in popoloComboUsoDelSuolo ="+ex.getMessage());
      throw ex;
    }
    finally{
      SolmrLogger.debug(this, "   END popoloComboUsoDelSuolo");
    }
  }
  
  
  /* Controllo se devo anche popolare la combo 'Lavorazioni'
      ----- Caricamento combo 'Lavorazioni' ------
        - se c'è un Uso del suolo selezionato, carico la combo Lavorazioni, altrimenti la svuoto
      
      -- Note :
    	 l'id della combo sarà composto da :
            idTipoLav|litriBase|litriMedioImpasto|litriTerDeclivi|tipoUnitaMisura|flagEscludiEsecuzioni|flagAsservimento
    
    */  
  private void popoloComboLavorazioni(AggiornaContoProprioFormVO form, Htmpl htmpl, boolean isUsoDelSuoloSelezionato, boolean isOnChangeComboUsoSuolo) throws Exception{
    SolmrLogger.debug(this, "   BEGIN popoloComboLavorazioni");
    try{       
       SolmrLogger.debug(this, "-- isUsoDelSuoloSelezionato ="+isUsoDelSuoloSelezionato);  
   	   if(isUsoDelSuoloSelezionato){
    		Vector vettLav = form.getVettLavorazioni();
    		if (vettLav != null && vettLav.size() > 0){
      			SolmrLogger.debug(this, "---- *** Caricamento della combo 'Lavorazioni' ***");      	
      			for (int i = 0; i < vettLav.size(); i++){
        			TipoLavorazioneVO elem = (TipoLavorazioneVO) vettLav.get(i);
        			htmpl.newBlock("blkComboLavorazione");
        			htmpl.set("blkComboLavorazione.idLavorazione", ""
            			+ elem.getIdTipoLav() + "|" + elem.getLitriBase() + "|"
            			+ elem.getLitriMedioImpasto() + "|"
            			+ elem.getLitriTerreniDeclivi() + "|"
            			+ elem.getTipoUnitaMisura() + "|"
            			+ elem.getFlagEscludiEsecuzioni() +"|"
            			+ elem.getFlagAsservimento());
        			htmpl.set("blkComboLavorazione.lavorazioneDesc", elem.getDescrizione());        
        			if (!isOnChangeComboUsoSuolo
            			&& form.getIdLavorazone() != null
            			&& form.getIdLavorazone().equalsIgnoreCase(
                		String.valueOf(elem.getIdTipoLav()))){
          				htmpl.set("blkComboLavorazione.checkedLavorazione", "selected");
        			}
      			}
    		}
  		}
  		else{
    		form.setVettLavorazioni(null);
    		form.setIdLavorazone(null);
  		}
    }
    catch(Exception ex){
       SolmrLogger.error(this, " --- Exception in popoloComboLavorazioni ="+ex.getMessage());
       throw ex;
    }
    finally{
      SolmrLogger.debug(this, "   END popoloComboLavorazioni");
    }  
  }
  
  

 private void popolaTabellaDiRiepilogo(Htmpl htmpl, HttpSession session, HttpServletRequest request) throws Exception{
   SolmrLogger.debug(this, "   BEGIN popolaTabellaDiRiepilogo");
   
   Vector<LavContoProprioVO> lavContoProprioVect = (Vector<LavContoProprioVO>)session.getAttribute("lavContoProprioVect");
   if(lavContoProprioVect != null && lavContoProprioVect.size()>0){   
     
     SolmrLogger.debug(this, "--- Ci sono elementi da visualizzare nella tabella di riepilogo, quanti ="+lavContoProprioVect.size());
     htmpl.newBlock("blkRiepilogoLavCp");    
     
     for(int i=0;i<lavContoProprioVect.size();i++){
       LavContoProprioVO lav = lavContoProprioVect.get(i);
       htmpl.newBlock("blkRiepilogoLavCp.blkLavorazione");
                    
       htmpl.set("blkRiepilogoLavCp.blkLavorazione.idLavContoProprio", new Integer(i).toString());                    
       htmpl.set("blkRiepilogoLavCp.blkLavorazione.usoDelSuolo", lav.getDescrUsoDelSuolo());              
       htmpl.set("blkRiepilogoLavCp.blkLavorazione.lavorazione",lav.getDescrLavorazione());
       
       String descrMacchina = lav.getDescrMacchina();
       SolmrLogger.debug(this, "- descrMacchina ="+descrMacchina);
       if(descrMacchina != null ){          
         htmpl.set("blkRiepilogoLavCp.blkLavorazione.macchina", lav.getDescrMacchina());
       }
              
       htmpl.set("blkRiepilogoLavCp.blkLavorazione.numEsecuzioni",lav.getNumEsecuzioni());
       
       // Motivo lavorazione
       Long idMotivoLavoraz = lav.getTipoMotivoLavVO().getIdMotivoLavorazione();
       HashMap<Long,TipoMotivoLavorazioneVO> motivoLavHm = (HashMap<Long,TipoMotivoLavorazioneVO>)session.getAttribute("motivoLavorazHM");
       TipoMotivoLavorazioneVO motivoLavVO = motivoLavHm.get(idMotivoLavoraz);
       htmpl.set("blkRiepilogoLavCp.blkLavorazione.motivoLavoraz", motivoLavVO.getDescrizione());
       
       
       htmpl.set("blkRiepilogoLavCp.blkLavorazione.supOre",lav.getSuperficie().toString());       
       htmpl.set("blkRiepilogoLavCp.blkLavorazione.unitaDiMisura", lav.getCodiceUnitaMisura());       
       
       if(lav.getLitriLavorazione() != null)
        htmpl.set("blkRiepilogoLavCp.blkLavorazione.litriCarburante",lav.getLitriLavorazione().toString());       
       
       if(lav.getLitriBase() != null)
         htmpl.set("blkRiepilogoLavCp.blkLavorazione.litriBase",lav.getLitriBase().toString());
       if(lav.getLitriMedioImpasto() != null)  
         htmpl.set("blkRiepilogoLavCp.blkLavorazione.litriMedioImpasto",lav.getLitriMedioImpasto().toString());
       if(lav.getLitriAcclivita() != null)  
         htmpl.set("blkRiepilogoLavCp.blkLavorazione.litriAcclivita",lav.getLitriAcclivita().toString());
              
       htmpl.set("blkRiepilogoLavCp.blkLavorazione.note", lav.getNote());   
       
       // ----- Controllo se ci sono errori (per visualizzare eventuali errori sulle righe della tabella per lavoraz gia' presenti sul db)
       ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");      
      // cambio il template
      if(errors != null){     
        // Se ci sono errori che contengono err_idLavoraz_+<posizione> ---> visualizzare la 'X' rossa nella riga       
        SolmrLogger.debug(this, "-- cerco se ci sono errori con :"+"err_idLavoraz_"+new Integer(i).toString());   
        Iterator itr = errors.get("idLavContoProprio_"+new Integer(i).toString());        
        if(itr != null && itr.hasNext()){
          SolmrLogger.debug(this," --- caso di segnalazione sulla riga della tabella di riepilogo - posizione ="+i);
          htmpl.set("blkRiepilogoLavCp.blkLavorazione.err_idLavContoProprio", "$$err_idLavContoProprio_" + new Integer(i).toString());
        }                   
      }// fine ci sono errori   
      
  
     }// -- fine ciclo sulle lavorazioni
     
     // Visualizzo pulsanti 'Salva' e 'Annulla'
     htmpl.newBlock("blkPulsanti");
   }
   // Se non ci sono elementi da visualizzare nella tabella, visualizzo il pulsante 'Annulla' vicino al pulsante 'Aggiungi'
   else{
     SolmrLogger.debug(this, "--- NON ci sono elementi da visualizzare nella tabella di riepilogo");
     
     // Visualizzo pulsante 'Annulla'
     htmpl.newBlock("blkPulsanteAnnulla");
   }
   
   SolmrLogger.debug(this, "   END popolaTabellaDiRiepilogo");
 }

private void setErrors(Htmpl htmpl, ValidationErrors errors,
      HttpServletRequest request)
  {
    //settaggio degli eventuali errori dentro il blocco
    if (errors != null)
    {

      // -- Errore per la combo Macchina
      Iterator iterErr = errors.get("idMacchina");
      if (iterErr != null){
        ValidationError err = (ValidationError) iterErr.next();
        HtmplUtil.setErrorsInBlocco("blkMacchina.err_idMacchina", htmpl,request, err);
      }
      
      // -- Errore per 'Sup (ha)/ Ore'
      Iterator iterErrSupOre = errors.get("supOreStr");
      if (iterErrSupOre != null){
        ValidationError err = (ValidationError) iterErrSupOre.next();
        HtmplUtil.setErrorsInBlocco("blkCampiSupOre.err_supOreStr", htmpl,request, err);
      }
      
      // -- Errore per 'Sup (ha)/ Ore Fattura'
      Iterator iterErrSupOreFatt = errors.get("supOreFatturaStr");
      if (iterErrSupOreFatt != null){
        ValidationError err = (ValidationError) iterErrSupOreFatt.next();
        HtmplUtil.setErrorsInBlocco("blkCampiSupOre.err_supOreFatturaStr", htmpl,request, err);
      }
      

    }
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
