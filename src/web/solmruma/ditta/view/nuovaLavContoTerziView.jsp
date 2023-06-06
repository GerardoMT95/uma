<%@page import="it.csi.solmr.etc.profile.AgriConstants"%>
<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="java.math.*"%>
<%@ page import="it.csi.solmr.dto.uma.form.AggiornaContoTerziFormVO"%>

<%
  String layout = "/ditta/layout/nuovaLavContoTerzi.htm";
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layout);
%>
  <%@include file="/include/menu.inc"%>
<%

  SolmrLogger.debug(this, "   BEGIN nuovaLavContoTerziView");
  
  ValidationErrors errors = (ValidationErrors) request.getAttribute("errors");

  AggiornaContoTerziFormVO form = (AggiornaContoTerziFormVO) session.getAttribute("formInserimentoCT");
  
  AnnoCampagnaVO annoCampagnaVO = (AnnoCampagnaVO) session.getAttribute("annoCampagna");  
  htmpl.set("annoCampagna", annoCampagnaVO.getAnnoCampagna());
  Long annoProx = Long.parseLong(annoCampagnaVO.getAnnoCampagna()) + 1;
  htmpl.set("annoProx", annoProx.toString());
    
  htmpl.set("coefficiente", form.getCoefficiente());  
  
  htmpl.set("max_metro_lineare", String.valueOf(SolmrConstants.MAX_METRO_L));
  
  String maggiorazione = "false";  
  // default : non c'è maggiorazione per il calcolo del carburante
  form.setMaggiorazione(maggiorazione);  
  // Se c'è l'azienda, c'è il codice della zona altimetrica ed è = 'M' (Montagna) -> c'è maggiorazione (litriTerDeclivi)
  if (form.getIdAzienda() != null && form.getCodiceZonaAlt() != null && form.getCodiceZonaAlt().equals(SolmrConstants.CODICE_MONTAGNA)){
    maggiorazione = "true";   
    form.setMaggiorazione(maggiorazione);
  }
  
  
  
 
  
  // --- Se è stata selezionata la Lavorazione : visualizzare i campi Sup (ha) o Ore : la label corretta (Sup (ha) o Ore) sarà in base all'unità di misura della lavorazione
    if(form.getTipoUnitaMisura() != null && !form.getTipoUnitaMisura().trim().equals("")){
      SolmrLogger.debug(this, "--- unità di misura della lavorazione valorizzata, visualizzare i campi Sup. / Ore");
      htmpl.newBlock("blkCampiSupOre");
      // Controllo se visualizzare 'Sup (ha) o Ore'
      if(form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_T)){
        SolmrLogger.debug(this, "-- visualizzare la label ORE");
        htmpl.newBlock("blkCampiSupOre.blkLabelOre");
      }
      else if(form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_S)){
        SolmrLogger.debug(this, "-- visualizzare la label Sup. (ha)");
        htmpl.newBlock("blkCampiSupOre.blkLabelSup");                      
      }
      else if(form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_P)){
        SolmrLogger.debug(this, "-- visualizzare la label Peso (t)*");
        htmpl.newBlock("blkCampiSupOre.blkLabelTon");                      
      }
      else if(form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_K)){
        SolmrLogger.debug(this, "-- visualizzare la label Peso (t)*");
        htmpl.newBlock("blkCampiSupOre.blkLabelPot");                      
      }
      else if(form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_M)){
          SolmrLogger.debug(this, "-- visualizzare la label Metro (m)*");
          htmpl.newBlock("blkCampiSupOre.blkLabelMet");                      
        }
    }

  boolean isOnChangeComboUsoSuolo = "true".equals(request.getParameter("hdnOnChangeComboUsoSuolo"));

  if (form != null){
    SolmrLogger.debug(this, "-- visualizzare i dati --");    
    htmpl.set("maggiorazione", form.getMaggiorazione());

    htmpl.set("litriBase", form.getLitriBase());
    htmpl.set("litriMaggiorazione", form.getLitriMaggiorazione());
    htmpl.set("litriMedioImpasto", form.getLitriMedioImpasto());
    htmpl.set("litriTerDeclivi", form.getLitriTerDeclivi());
    htmpl.set("cavalli", form.getCavalli());
    htmpl.set("tipoCarburante", form.getTipoCarburante());
    htmpl.set("litriBasePerEsecuzioni", form.getLitriBasePerEsecuzioni());
    htmpl.set("consumoDichiarato", form.getConsumoDichiarato());
    htmpl.set("eccedenza", form.getEccedenza());
    
    if(form.getLavAScavalco()!=null && form.getLavAScavalco()==1){
    	htmpl.set("enableScavalco", "checked");
    }
    
    htmpl.set("lavorazioneDichiarataDaAziendaContoProprio", form.getLavorazioneDichiarataDaAziendaContoProprio());
    htmpl.set("lavorazioneDichiataDaAziendaContoTerzi", form.getLavorazioneDichiataDaAziendaContoTerzi());
    htmpl.set("idDittaUmaAssociata", form.getIdDittaUmaAssociata());
    

    SolmrLogger.debug(this, "****nella view  form.getSuperficie() vale: "+ form.getSuperficie());

    SolmrLogger.debug(this, "****nella view  form.getSupOre() vale: "+ form.getSupOre());
    SolmrLogger.debug(this,"****nella view  form.getSupOreFattura() vale: "+ form.getSupOreFattura());
    
    // --------- *** GESTIONE valorizzazione campi Sup(ha)/Ore *** -------------
    if (!isOnChangeComboUsoSuolo && form.getIdLavorazone() != null && !form.getIdLavorazone().trim().equals("")){
      SolmrLogger.debug(this,"-- *** GESTIONE selezione COMBO 'Uso del suolo' e valorizzazione campi Sup(ha)/Ore *** ----"); 
      
      if (!StringUtils.isStringEmpty(form.getSupOreFattura())){
        htmpl.set("blkCampiSupOre.supOreFatturaStr", form.getSupOreFattura());       
      }
      

      if (!StringUtils.isStringEmpty(form.getSupOre()) && form.getTipoUnitaMisura().equalsIgnoreCase(
                SolmrConstants.TIPO_UNITA_MISURA_S))
      {
        htmpl.set("blkCampiSupOre.blkLabelSup.supOreStr", form.getSupOre());
      }
      
      else if (!StringUtils.isStringEmpty(form.getSuperficie()) && form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_S))
      {
        htmpl.set("blkCampiSupOre.blkLabelSup.supOreStr", form.getSuperficie());
      }
      
      if (!StringUtils.isStringEmpty(form.getSupOre()) && form.getTipoUnitaMisura().equalsIgnoreCase(
                SolmrConstants.TIPO_UNITA_MISURA_K))
      {
        htmpl.set("blkCampiSupOre.blkLabelPot.supOreStr", form.getSupOre());
      }
      
      else if (!StringUtils.isStringEmpty(form.getSuperficie()) && form.getTipoUnitaMisura().equalsIgnoreCase(
                SolmrConstants.TIPO_UNITA_MISURA_K))
      {
        htmpl.set("blkCampiSupOre.blkLabelPot.supOreStr", form.getSuperficie());
      }
      if (!StringUtils.isStringEmpty(form.getSupOre()) && form.getTipoUnitaMisura().equalsIgnoreCase(
                SolmrConstants.TIPO_UNITA_MISURA_M))
      {
        htmpl.set("blkCampiSupOre.blkLabelMet.supOreStr", form.getSupOre());
      }
      
      else if (!StringUtils.isStringEmpty(form.getSuperficie()) && form.getTipoUnitaMisura().equalsIgnoreCase(
                SolmrConstants.TIPO_UNITA_MISURA_M))
      {
        htmpl.set("blkCampiSupOre.blkLabelMet.supOreStr", form.getSuperficie());
      }
      
    } // fine GESTIONE selezione COMBO 'Uso del suolo' *** ----
    
    
    
    htmpl.set("cuaaStr", form.getCuaa());
    htmpl.set("partitaIvaStr", form.getPartitaIva());
    htmpl.set("denominazioneStr", form.getDenominazione());   
    
    String sedeLeg = StringUtils.checkNull(form.getSedeLegale());
    
    
    if(sedeLeg != null && !sedeLeg.trim().equals("")){
	    String provincia = request.getParameter("provinciaStr");
	    StringTokenizer stSedeLeg = new StringTokenizer(sedeLeg, "()");
	    if (stSedeLeg.hasMoreTokens())
	    {
	      sedeLeg = stSedeLeg.nextToken().trim().toUpperCase();
	      if (stSedeLeg.hasMoreTokens())
	      {
	        provincia = stSedeLeg.nextToken().trim().toUpperCase();
	      }
	    }    
	    htmpl.set("provinciaStr", provincia);
    }
    
    htmpl.set("sedeLegaleStr", sedeLeg);
    
    htmpl.set("indirizzoSedeLegaleStr", form.getIndirizzoSedeLegale());
    
    
    htmpl.set("tipoUnitaMisura", form.getTipoUnitaMisura());
    htmpl.set("flagEscludiEsecuzioni", form.getFlagEscludiEsecuzioni());
    //htmpl.set("unitaMisura", form.getCodiceUnitaMisura());

    SolmrLogger.debug(this, "NELLA VIEW form.getMaxCarburante() VALE: "+ form.getMaxCarburante());       

    htmpl.set("benzinaStr", form.getBenzina());
    htmpl.set("gasolioStr", form.getGasolio());
    htmpl.set("noteStr", form.getNote());
    htmpl.set("numeroFatturaStr", form.getNumeroFatture());
    

    SolmrLogger.debug(this, "NELLA VIEWW tipoUnitaMisura VALE: "
        + form.getTipoUnitaMisura());
    SolmrLogger.debug(this, "NELLA VIEWW codiceUnitaMisura VALE: "
        + form.getCodiceUnitaMisura());
        
    // NOTE : PER LA BASLICATA TOLTA LA COMBO DELLE MACCHINE
    // ---- Se l'unità di misuara sono le ore -> visualizzare la combo 'Macchina utilizzata'
    if (null != form.getTipoUnitaMisura() && form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_T)){
      SolmrLogger.debug(this, "-- Caso tipo unita misura TEMPO");	
      /*htmpl.newBlock("blkNoLitriAcclivita");
      SolmrLogger.debug(this, "-- Visualizzare la COMBO 'Macchina utilizzata'");
      htmpl.newBlock("blkMacchina");
      htmpl.set("maggiorazione", form.getMaggiorazione());
      if (form.getVettMacchine() != null && form.getVettMacchine().size() > 0)
      {
        SolmrLogger.debug(this, "form.getVettMacchine().size() vale: "
            + form.getVettMacchine().size());
        for (int i = 0; i < form.getVettMacchine().size(); i++)
        {
          htmpl.newBlock("blkComboMacchina");
          MacchinaVO elem = (MacchinaVO) form.getVettMacchine().get(i);
          htmpl.set("blkMacchina.blkComboMacchina.idMacchina", elem
              .getIdMacchina()
              + "|"
              + elem.getMatriceVO().getPotenzaKW()
              + "|"
              + elem.getMatriceVO().getIdAlimentazione());
          StringBuffer descMacchina = new StringBuffer();
          addStringForDescMacchina(descMacchina, elem.getMatriceVO()
              .getCodBreveGenereMacchina());
          addStringForDescMacchina(descMacchina, elem.getTipoCategoriaVO()
              .getDescrizione());
          String tipoMacchina = elem.getMatriceVO().getTipoMacchina();
          if (Validator.isEmpty(tipoMacchina))
          {
            addStringForDescMacchina(descMacchina, elem.getDatiMacchinaVO()
                .getMarca());
          }
          else
          {
            addStringForDescMacchina(descMacchina, tipoMacchina);
          }
          addStringForDescMacchina(descMacchina, elem.getTargaCorrente()
              .getNumeroTarga());

          htmpl.set("blkMacchina.blkComboMacchina.macchinaDesc",
              descMacchina.toString());
          SolmrLogger.debug(this, "NELLA VIEW form.getIdMacchina() vale: "
              + form.getIdMacchina());
          if (!StringUtils.isStringEmpty(form.getIdMacchina()))
          {
            StringTokenizer st = new StringTokenizer(form.getIdMacchina(),
                "|");
            String idM = st.nextToken();
            SolmrLogger.debug(this, "NELLA VIEW idM vale: %" + idM + "%");
            SolmrLogger.debug(this,
                "NELLA VIEW elem.getIdMacchina() vale: %"
                    + elem.getIdMacchina() + "%");
            if (idM.equals(elem.getIdMacchina()))
            {
              htmpl.set("blkMacchina.blkComboMacchina.checkedMacchina",
                  "selected");
            }
          }

        }
      }*/
    }
    
    // Se l'unità di misura è la SUPERFICIE : visualizzare i campi per la 'Zona altimetrica' e i 'litri acclività'
    else if(form.getTipoUnitaMisura() != null && form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_S)){
      SolmrLogger.debug(this, "-- Visualizare i campi per la 'Zona altimetrica' e i 'litri acclività'");
      htmpl.newBlock("blkZonaAltimetrica");
      
      if(form.getComuneZonaAlt() != null && !form.getComuneZonaAlt().trim().equals(""))
        htmpl.set("blkZonaAltimetrica.comuneZonaAltimetrica", form.getComuneZonaAlt());
      else
        htmpl.set("blkZonaAltimetrica.comuneZonaAltimetrica", "NON PRESENTE");   
      
      if(form.getDescrZonaAlt() != null && !form.getDescrZonaAlt().trim().equals(""))  
        htmpl.set("blkZonaAltimetrica.zonaAltimetrica", form.getDescrZonaAlt());
      else
        htmpl.set("blkZonaAltimetrica.zonaAltimetrica", "NON PRESENTE");       
      
      htmpl.newBlock("blkLitriAcclivita");      
      
      // in questo caso il campo è = 0 e non può essere modificato, in quanto nel calcolo del carburante non verrà preso in considerazione        
      if(form.getMaggiorazione().equals("false")){
        htmpl.set("blkLitriAcclivita.readonlyLitriAcclivita", "readonly style='background-color:LightGrey'"); 
      }
      else{
        htmpl.set("blkLitriAcclivita.litriAcclivita", form.getLitriAcclivita());
      }   
    }
    else{
      htmpl.newBlock("blkNoLitriAcclivita");
    }
     
    // ---- Caricamento della combo 'Uso del suolo' -----
    Vector vettUsoSuolo = form.getVettUsoSuolo();
    boolean idUsoDelSuoloTrovato = false;
    if (vettUsoSuolo != null && vettUsoSuolo.size() > 0){
      SolmrLogger.debug(this, "---- *** Caricamento della combo 'Uso del suolo' ***");
      SolmrLogger.debug(this, "NELLA VIEW vettUsoSuolo.size() VALE: "+ vettUsoSuolo.size());
      for (int i = 0; i < vettUsoSuolo.size(); i++)
      {
        CategoriaUtilizzoUmaVO elem = (CategoriaUtilizzoUmaVO) vettUsoSuolo.get(i);
        htmpl.newBlock("blkComboUsoSuolo");
        htmpl.set("blkComboUsoSuolo.idUsoSuolo", ""+ elem.getIdCategoriaUtilizzoUma());
        htmpl.set("blkComboUsoSuolo.descUsoSuolo", elem.getDescrizione());
                
        if (form.getIdUsoSuolo() != null && form.getIdUsoSuolo().equalsIgnoreCase(String.valueOf(elem.getIdCategoriaUtilizzoUma()))){
          SolmrLogger.debug(this, "--- idUsoDelSuolo da selezionare nella combo ="+form.getIdUsoSuolo());
          htmpl.set("blkComboUsoSuolo.checkedUsoSuolo", "selected");
          idUsoDelSuoloTrovato = true;
        }

      }
    }
    
    // ----- Caricamento combo 'Lavorazioni' ------
    // Se c'è un Uso del suolo selezionato, carico la combo Lavorazioni, altrimenti la svuoto
  SolmrLogger.debug(this, "-- idUsoDelSuoloTrovato ="+idUsoDelSuoloTrovato);  
  if(idUsoDelSuoloTrovato){
    Vector vettLav = form.getVettLavorazioni();
    if (vettLav != null && vettLav.size() > 0)
    {
      SolmrLogger.debug(this, "---- *** Caricamento della combo 'Lavorazioni' ***");
      SolmrLogger.debug(this, "NELLA VIEW vettLav.size() VALE: "+ vettLav.size());
      for (int i = 0; i < vettLav.size(); i++)
      {
        TipoLavorazioneVO elem = (TipoLavorazioneVO) vettLav.get(i);
        htmpl.newBlock("blkComboLavorazione");
        htmpl.set("blkComboLavorazione.idLavorazione", ""
            + elem.getIdTipoLav() + "|" + elem.getLitriBase() + "|"
            + elem.getLitriMaggiorazioneConto3() + "|"
            + elem.getLitriMedioImpasto() + "|"
            + elem.getLitriTerreniDeclivi() + "|"
            + elem.getTipoUnitaMisura() + "|"
            + elem.getFlagEscludiEsecuzioni() + "|"
            + elem.getLavAScavalco());
        htmpl.set("blkComboLavorazione.lavorazioneDesc", elem
            .getDescrizione());
        SolmrLogger.debug(this, "form.getIdLavorazone() vale: "
            + form.getIdLavorazone());
        SolmrLogger.debug(this, "elem.getIdTipoLav() vale: "
            + elem.getIdTipoLav());

        if (!isOnChangeComboUsoSuolo
            && form.getIdLavorazone() != null
            && form.getIdLavorazone().equalsIgnoreCase(
                String.valueOf(elem.getIdTipoLav())))
        {
          htmpl.set("blkComboLavorazione.checkedLavorazione", "selected");
        }

      }
    }
  }
  else{
    form.setVettLavorazioni(null);
    form.setIdLavorazone(null);
  }  
    
    
    SolmrLogger.debug(this, "NELLA VIEW form.getNumeroEsecuzioni() VALE: "+ form.getNumeroEsecuzioni());
    SolmrLogger.debug(this, "NELLA VIEW form.getMaxEsecuzioni() VALE: "+ form.getMaxEsecuzioni());
    if (!StringUtils.isStringEmpty(form.getNumeroEsecuzioni()))
    {
      htmpl.set("esecuzioniStr", form.getNumeroEsecuzioni());
    }
    else
    {
      htmpl.set("esecuzioniStr", form.getMaxEsecuzioni());
    }

  }  
  
  if (errors != null && errors.size() > 0){    
    htmpl.set("eseguiCalcolaCarb", "false");
  }


  // --- Gestione visualizzazione degli errori  
  SolmrLogger.debug(this,"--- setErrors");
  setErrors(htmpl, errors, request);
  
  HtmplUtil.setErrors(htmpl, errors, request);

  Long errorType = (Long) request.getAttribute("errorType");
  
  String onLoad = "";
  SolmrLogger.debug(this, "-- errorType ="+errorType);
  if(errorType != null) {
    if(errorType.intValue()==SolmrConstants.VALIDAZIONE_KO_WARNING){
    	onLoad = "calcolaMaxLitriAcclivita();calcoloCarburante();confermaWarning()";
    }    
    SolmrLogger.debug(this, "-- onLoad ="+onLoad);
  }
  else
  {
    // se si sta ricaricando la pagina per errori, non bisogna ricalcolare 'litri acclività' (l'utente potrebbe averne modificato il valore, bisogna mantenere quello) 
    if(errors != null && !errors.empty())
      onLoad = "calcolaMaxLitriAcclivita();calcoloCarburante()";
    else
       onLoad = "calcoloLitriAcclivita();calcoloCarburante()";
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


 private void popolaTabellaDiRiepilogo(Htmpl htmpl, HttpSession session, HttpServletRequest request) throws Exception{
   SolmrLogger.debug(this, "   BEGIN popolaTabellaDiRiepilogo");
   
   Vector<LavContoTerziVO> lavContoTerziVect = (Vector<LavContoTerziVO>)session.getAttribute("lavContoTerziVect");
   if(lavContoTerziVect != null && lavContoTerziVect.size()>0){   
     
     SolmrLogger.debug(this, "--- Ci sono elementi da visualizzare nella tabella di riepilogo, quanti ="+lavContoTerziVect.size());
     htmpl.newBlock("blkRiepilogoLavCt");    
     
     for(int i=0;i<lavContoTerziVect.size();i++){
       LavContoTerziVO lav = lavContoTerziVect.get(i);
       htmpl.newBlock("blkRiepilogoLavCt.blkLavorazione");
              
       
       htmpl.set("blkRiepilogoLavCt.blkLavorazione.idLavContoTerzi", new Integer(i).toString());
       htmpl.set("blkRiepilogoLavCt.blkLavorazione.cuaa", lav.getCuaaAzRiepilogo());
       htmpl.set("blkRiepilogoLavCt.blkLavorazione.denominazione", lav.getDenominazioneAzRiepilogo());
       
       
       htmpl.set("blkRiepilogoLavCt.blkLavorazione.usoDelSuolo", lav.getDescrUsoDelSuolo());
              
       htmpl.set("blkRiepilogoLavCt.blkLavorazione.lavorazione",lav.getDescrLavorazione());
       
       String descrMacchina = lav.getDescrMacchina();
       SolmrLogger.debug(this, "- descrMacchina ="+descrMacchina);
       if(descrMacchina != null ){          
         htmpl.set("blkRiepilogoLavCt.blkLavorazione.macchina", lav.getDescrMacchina());
       }
       
       htmpl.set("blkRiepilogoLavCt.blkLavorazione.numEsecuzioni",lav.getNumeroEsecuzioni().toString());
       
       htmpl.set("blkRiepilogoLavCt.blkLavorazione.litriAcclivita", lav.getLitriAcclivitaStr());
       
       htmpl.set("blkRiepilogoLavCt.blkLavorazione.unitaDiMisura", lav.getCodiceUnitaMisura());
       
       if(SolmrConstants.TIPO_UNITA_MISURA_M.equals(lav.getCodiceUnitaMisura())){
	       htmpl.set("blkRiepilogoLavCt.blkLavorazione.supOre",lav.getSupOreFatturaStr());
       }
       else{
	       htmpl.set("blkRiepilogoLavCt.blkLavorazione.supOre",lav.getSupOreStr());       
       }
       
       htmpl.set("blkRiepilogoLavCt.blkLavorazione.supOreFattura", lav.getSupOreFatturaStr());       
       
       htmpl.set("blkRiepilogoLavCt.blkLavorazione.gasolio", lav.getGasolioStr());
       
       htmpl.set("blkRiepilogoLavCt.blkLavorazione.eccedenza", lav.getEccedenzaStr());
       htmpl.set("blkRiepilogoLavCt.blkLavorazione.consumoCalcolato", lav.getConsumoCalcolatoStr());
       htmpl.set("blkRiepilogoLavCt.blkLavorazione.consumoDichiarato", lav.getConsumoDichiaratoStr());
       
       htmpl.set("blkRiepilogoLavCt.blkLavorazione.benzina", lav.getBenzinaStr());
       
       htmpl.set("blkRiepilogoLavCt.blkLavorazione.fatture", lav.getNumeroFatture());
       
       htmpl.set("blkRiepilogoLavCt.blkLavorazione.lavScavalco", lav.isScavalco() ? "S" : "N" );
       
       htmpl.set("blkRiepilogoLavCt.blkLavorazione.note", lav.getNote());   
       
       // ----- Controllo se ci sono errori (per visualizzare eventuali errori sulle righe della tabella per lavoraz gia' presenti sul db)
       ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");      
      // cambio il template
      if(errors != null){     
        // Se ci sono errori che contengono err_idLavoraz_+<posizione> ---> visualizzare la 'X' rossa nella riga       
        SolmrLogger.debug(this, "-- cerco se ci sono errori con :"+"err_idLavoraz_"+new Integer(i).toString());   
        Iterator itr = errors.get("idLavContoTerzi_"+new Integer(i).toString());        
        if(itr != null && itr.hasNext()){
          SolmrLogger.debug(this," --- caso di segnalazione sulla riga della tabella di riepilogo - posizione ="+i);
          htmpl.set("blkRiepilogoLavCt.blkLavorazione.err_idLavContoTerzi", "$$err_idLavContoTerzi_" + new Integer(i).toString());
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
      
      // Errore per 'Litri acclività'
      Iterator iterErrLitriAcclivita = errors.get("litriAcclivita");
      if (iterErrLitriAcclivita != null){
        ValidationError err = (ValidationError) iterErrLitriAcclivita.next();
        HtmplUtil.setErrorsInBlocco("blkLitriAcclivita.err_litriAcclivita", htmpl,request, err);
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
