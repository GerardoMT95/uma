<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.math.BigDecimal"%>
<%@ page import="it.csi.solmr.dto.uma.form.AggiornaConsorziFormVO"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
  String iridePageName = "nuovaLavConsorziCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%
  SolmrLogger.debug(this,"SONO IN nuovaLavConsorziCtrl.jsp");
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  String viewUrl = "/ditta/view/nuovaLavConsorziView.jsp";

  //String elencoHtm="../../ditta/layout/elencoLavContoTerzi.htm";
  String elencoHtm = "../../ditta/layout/elencoLavConsorzi.htm";
  String elencoBisHtm = "../../ditta/layout/elencoLavContoTerziBis.htm";
  
  

  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");

  AggiornaConsorziFormVO form = (AggiornaConsorziFormVO) session
      .getAttribute("formInserimentoConsorzi");

  String flagPulisciSessione = (String) request
      .getAttribute("flagPulisciSessione");
  SolmrLogger.debug(this, "flagPulisciSessione vale: "
      + flagPulisciSessione);

  if (!StringUtils.isStringEmpty(flagPulisciSessione) || form == null)
  {
    form = new AggiornaConsorziFormVO();
  }
  boolean isConsorzio = umaFacadeClient
      .isDittaUmaConsorzio(dittaUMAAziendaVO.getIdAzienda());
  if (isConsorzio)
    form.setIsConsorzio("true");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  AnnoCampagnaVO annoCampangaVO = (AnnoCampagnaVO) session
      .getAttribute("annoCampagna");
  SolmrLogger.debug(this, "annoCampangaVO vale: " + annoCampangaVO);
  
  String note = (String) request.getParameter("note");
  form.setNote(note);
   
  String anno = annoCampangaVO.getAnnoCampagna();
  String data = null;
  String coefficiente = umaFacadeClient.getValoreParametro(SolmrConstants.PARAMETRO_COEFFICIENTE_CAVALLI_CARBURANTE,anno,data);
  SolmrLogger.debug(this, "coefficiente vale: " + coefficiente);
  form.setCoefficiente(coefficiente);
  //form.setComuneVO(comuneVO);

  String litriBase = (String) request.getParameter("litriBase");
  form.setLitriBase(litriBase);
  SolmrLogger.debug(this, "Nella ctrl litriBase vale: " + litriBase);

  String litriMaggiorazione = (String) request
      .getParameter("litriMaggiorazione");
  form.setLitriMaggiorazione(litriMaggiorazione);

  String litriMedioImpasto = (String) request
      .getParameter("litriMedioImpasto");
  form.setLitriMedioImpasto(litriMedioImpasto);

  String litriTerDeclivi = (String) request.getParameter("litriTerDeclivi");
  form.setLitriTerDeclivi(litriTerDeclivi);

  //999|1|1|1|1|T
  String idLavorazione = (String) request.getParameter("idLavorazione");
  SolmrLogger.debug(this, "idLavorazione vale: " + idLavorazione);

  //998|3|12|4|20|S
  if (!StringUtils.isStringEmpty(idLavorazione))
  {
    StringTokenizer st = new StringTokenizer(idLavorazione, "|");
    if (st.hasMoreTokens())
      form.setIdLavorazone(st.nextToken());
    // SolmrLogger.debug(this,"1");
    if (st.hasMoreTokens())
      form.setLitriBase(st.nextToken());
    //SolmrLogger.debug(this,"2");
    if (st.hasMoreTokens())
      form.setLitriTerDeclivi(st.nextToken());
    //SolmrLogger.debug(this,"2");
    if (st.hasMoreTokens())
      form.setLitriMedioImpasto(st.nextToken());
    //SolmrLogger.debug(this,"4");
    if (st.hasMoreTokens())
      form.setTipoUnitaMisura(st.nextToken());
    //SolmrLogger.debug(this,"6");
    if (st.hasMoreTokens())
      form.setCavalli(st.nextToken());
    if (st.hasMoreTokens())
      form.setFlagEscludiEsecuzioni(st.nextToken());
  }
  else
  {
    form.setIdLavorazone(null);
  }

  SolmrLogger
      .debug(this, "Nella ctrl idLavorazione vale: " + idLavorazione);
  SolmrLogger.debug(this, "Nella ctrl form.getLitriBase vale: "
      + form.getLitriBase());
  SolmrLogger.debug(this, "Nella ctrl form.getLitriMedioImpasto vale: "
      + form.getLitriMedioImpasto());
  SolmrLogger.debug(this, "Nella ctrl form.getTipoUnitaMisura vale: "
      + form.getTipoUnitaMisura());
  SolmrLogger.debug(this, "Nella ctrl form.getCavalli vale: "
      + form.getCavalli());

  String supOreStr = (String) request.getParameter("supOreStr");
  SolmrLogger.debug(this, "****nel controller supOreStr vale: " + supOreStr);
  form.setSupOre(supOreStr);

  /* String supOreFatturaStr=(String)request.getParameter("supOreFatturaStr");
   SolmrLogger.debug(this,"****nel controller supOreFatturaStr vale: "+supOreFatturaStr);
   form.setSupOreFattura(supOreFatturaStr);
   */

  //SolmrLogger.debug(this,"SONO IN nuovaLavContoTerziCntr e tipoUnitaMisura  vale: "+tipoUnitaMisura);
  String idMacchina = (String) request.getParameter("idMacchina");
  SolmrLogger.debug(this,
      "SONO IN nuovaLavContoTerziCntr e idMacchina  vale: " + idMacchina);
  form.setIdMacchina(idMacchina);

  SolmrLogger.debug(this, "Nella ctrl idMacchina vale: " + idMacchina);

  String cavalli = (String) request.getParameter("cavalli");
  form.setCavalli(cavalli);

  String cavalliConsorzio = (String) request
      .getParameter("cavalliConsorzio");
  form.setCavalliConsorzio(cavalliConsorzio);

  SolmrLogger.debug(this, "Nella ctrl cavalli vale: " + cavalli);

  String tipoCarburante = (String) request.getParameter("tipoCarburante");
  form.setTipoCarburante(tipoCarburante);

  SolmrLogger.debug(this, "Nella ctrl tipoCarburante vale: "
      + tipoCarburante);

  String ettari = (String) request.getParameter("ettari");
  if (!StringUtils.isStringEmpty(ettari))
  {
    form.setEttari(ettari);
  }

  String numeroEsecuzioni = (String) request
      .getParameter("numeroEsecuzioni");
  SolmrLogger.debug(this, "Nella ctrl numeroEsecuzioni vale: "
      + numeroEsecuzioni);
  form.setNumeroEsecuzioni(numeroEsecuzioni);

  String tipoUnitaMisura = (String) request.getParameter("tipoUnitaMisura");
  SolmrLogger.debug(this, "nel controller tipoUnitaMisura vale: "
      + tipoUnitaMisura);

  String gasolioStr = request.getParameter("gasolioStr");
  String benzinaStr = request.getParameter("benzinaStr");

  form.setGasolio(gasolioStr);
  form.setBenzina(benzinaStr);

  String maxCarburante = request.getParameter("maxCarburante");
  SolmrLogger.debug(this, "Nel controller maxCarburante vale: "
      + maxCarburante);
  form.setMaxCarburante(maxCarburante);

  SolmrLogger.debug(this, "-- ricerca degli elementi per la COMBO Uso del suolo, filtrati per anno");
  SolmrLogger.debug(this, "-- annoCampagna ="+annoCampangaVO.getAnnoCampagna()); 
  form.setVettUsoSuolo(umaFacadeClient.findCategorieUtilizzoUma(annoCampangaVO.getAnnoCampagna()));
 

  String usoSuolo = (String) request.getParameter("usoSuolo");
  SolmrLogger.debug(this, "NEL CONTROLLER usoSuolo VALE: " + usoSuolo);
  form.setIdUsoSuolo(usoSuolo);
  // form.setIdUsoSuolo(usoSuolo);
  
  
  if (Validator.isNotEmpty(usoSuolo))
  {
    SolmrLogger.debug(this,
        "PRIMA DI CHIAMARE findElencoLavorazioniConsorzi CON form.getIdUsoSuolo(): "
            + form.getIdUsoSuolo());
    SolmrLogger.debug(this, "dittaUMAAziendaVO.getIdDittaUMA(): "
        + dittaUMAAziendaVO.getIdDittaUMA());
    SolmrLogger.debug(this, "annoCampangaVO.getAnnoCampagna(): "
        + annoCampangaVO.getAnnoCampagna());
    Vector vettLavorazioni = umaFacadeClient.findElencoLavorazioniConsorzi(
        dittaUMAAziendaVO.getIdAzienda(), form.getIdUsoSuolo(), ""
            + dittaUMAAziendaVO.getIdDittaUMA(), ""
            + annoCampangaVO.getAnnoCampagna());
    SolmrLogger.debug(this,
        "DOPO LA CHIAMATA DI  findElencoLavorazioniConsorzi");
    form.setVettLavorazioni(vettLavorazioni);
  }
  
  
  //Aggiungo i cuaa da visualizzare nella combo 'Aziende'
  form.setVettAziendeConsorzio(umaFacadeClient.findElencoCuaaLavorazioniConsorzi(dittaUMAAziendaVO.getIdDittaUMA(), dittaUMAAziendaVO.getIdAzienda()));
  
  
  String azienda = (String) request.getParameter("azienda");
  SolmrLogger.debug(this, "--- azienda selezionato ="+azienda);
    
  // --- Calcolo della zona altimetrica dell'azienda selezionata nella combo, se viene trovata l'id_ditta_uma corrispondente
  if(Validator.isNotEmpty(azienda)){
    StringTokenizer st = new StringTokenizer(azienda, "|");
    String idConsistenza = "";
    String idAzienda = "";
    if (st.hasMoreTokens())
      idConsistenza = st.nextToken();
    if (st.hasMoreTokens())
      idAzienda = st.nextToken();
    SolmrLogger.debug(this, "--- idAzienda selezionato ="+idAzienda); 
    SolmrLogger.debug(this, "--- E' stata selezionata l'azienda, verifiche per calcolo zona altimetrica ---");
    DittaUMAVO dittaTrovata = umaFacadeClient.getDittaUmaByIdAziendaDataCess(new Long(idAzienda), new Long(annoCampangaVO.getAnnoCampagna()));
    String codiceZonaAlt = null;
    if(dittaTrovata != null && dittaTrovata.getIdDitta() != null){
      SolmrLogger.debug(this, "--- E' stato trovato l'ID_DITTA_UMA corrispondente all'azienda selezionata, effettuo calcolo ZONA ALTIMETRICA");
	  ZonaAltimetricaVO zonaAltimetrica = umaFacadeClient.getZonaAltByIdDittaUma(dittaTrovata.getIdDitta());
	  if(zonaAltimetrica != null)
	    codiceZonaAlt = zonaAltimetrica.getCodiceZonaAltimetrica();
	  SolmrLogger.debug(this, " -- codiceZonaAlt ="+codiceZonaAlt);
    }
    form.setCodiceZonaAlt(codiceZonaAlt);
  }
  // -------

  //Calcolo la sup ha/ore
  if (Validator.isNotEmpty(usoSuolo) && Validator.isNotEmpty(azienda))
  {    
    StringTokenizer st = new StringTokenizer(azienda, "|");
    String idConsistenza = "";
    String idAzienda = "";
    if (st.hasMoreTokens())
      idConsistenza = st.nextToken();
    if (st.hasMoreTokens())
      idAzienda = st.nextToken();
      
    form.setIdAziendaSocio(idAzienda);
    
    // Solo se è stata anche selezionata una lavorazione
    SolmrLogger.debug(this, "--- idLavorazione selezionata ="+form.getIdLavorazone());
    if(form.getIdLavorazone() != null && !form.getIdLavorazone().trim().equals("")){
	    BigDecimal superficie = null;	    
	    SolmrLogger.debug(this, "--- idConsistenza ="+idConsistenza);
	    SolmrLogger.debug(this, "--- usoSuolo ="+usoSuolo);
	    SolmrLogger.debug(this, "--- idLavorazioni ="+form.getIdLavorazone());
	    SolmrLogger.debug(this, "--- idAzienda ="+idAzienda);
	    
	    if (form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_K))
	    {
	       //calcolo la potenza
	       superficie=umaFacadeClient.getDimensioneFabbricato(Long.parseLong(idAzienda),annoCampangaVO.getAnnoCampagna());   
	       form.setSuperficie(superficie.toString());
	    }
	    else
	    {
		    if(idConsistenza != null && !idConsistenza.trim().equals("") && !idConsistenza.equals("0")){
		      superficie = umaFacadeClient.getSuperficeSocio(dittaUMAAziendaVO.getIdDittaUMA(), new Long(idAzienda), new Long(idConsistenza), new Long(usoSuolo), new Long(annoCampangaVO.getAnnoCampagna()), new Long(form.getIdLavorazone()));
		      form.setSuperficie(superficie.toString());
		    }
		    else{
		      form.setSuperficie("");
		    }
	    }	    
    } 
    else
      form.setSuperficie(""); 

    SolmrLogger.debug(this, " --- form.getSuperficie() vale: "+ form.getSuperficie());    
  }
  else
  {
    form.setSuperficie("");
    //form.setSupOreFattura("");
  }
  

  if (!StringUtils.isStringEmpty(form.getIdUsoSuolo())
      && !StringUtils.isStringEmpty(form.getIdLavorazone()))
  {
    // Cerco il valore da proporre a video nel campo numero esecuzioni
    CategoriaColturaLavVO elem = umaFacadeClient.getCategoriaColturaLav(form.getIdLavorazone(), form.getIdUsoSuolo(), SolmrConstants.ID_TIPO_COLTURA_LAVORAZIONE_CONTO_TERZI_CONSORZI, annoCampangaVO.getAnnoCampagna());
    if (elem != null)
    {
      SolmrLogger.debug(this, "DOPO getCategoriaColturaLav ...");
      SolmrLogger.debug(this, "elem.getMaxEsecuzione() VALE: "
          + elem.getMaxEsecuzione());
      SolmrLogger.debug(this, "elem.getCodiceUnitaMisura() VALE: "
          + elem.getCodiceUnitaMisura());

      //form.setNumeroEsecuzioni(""+elem.getMaxEsecuzione());
      if (null != elem.getMaxEsecuzione())
        form.setMaxEsecuzioni("" + elem.getMaxEsecuzione());
      form.setTipoUnitaMisura(elem.getTipoUnitaMisura());
      //form.setIdUnitaMisura(elem.getCodiceUnitaMisura());
      form.setCodiceUnitaMisura(elem.getCodiceUnitaMisura());
      //form.setTipoUnitaMisura(elem.getCodiceUnitaMisura());
      form.setIdUnitaMisura(StringUtils.getLongValue(elem
          .getIdUnitaMisura()));
    }
    if (form.getTipoUnitaMisura().equalsIgnoreCase(
        SolmrConstants.TIPO_UNITA_MISURA_T))
    {
      // carico combo macchine
      //Long idLavorazioni,Long idLavorazioniContoTerzi,Long anno,Long idDittaUma)
      Vector vettMacchine = umaFacadeClient.findMacchineUtilizzate(new Long(form
          .getIdLavorazone()), new Long(form.getIdUsoSuolo()), new Long(
          annoCampangaVO.getAnnoCampagna()), dittaUMAAziendaVO
          .getIdDittaUMA(), true);
      form.setVettMacchine(vettMacchine);
      SolmrLogger.debug(this, "Nel controller vettMacchine vale: "
          + vettMacchine);
    }

  }
  else
  {
    form.setTipoUnitaMisura("");
    form.setIdUnitaMisura("");
    form.setNumeroEsecuzioni("");
    form.setMaxEsecuzioni("");
  }

  session.setAttribute("formInserimentoConsorzi", form);

  if (request.getParameter("salva.x") != null)
  {
    SolmrLogger.debug(this, "nuovaLavConsorziCtrl - salva.x   ");
    LavConsorziVO lavConsorzioInsert = new LavConsorziVO();
    ValidationErrors errors = validateInsert(request, form,
        lavConsorzioInsert);
    
    //Controllo lavorazioni duplicate
    if(umaFacadeClient.checkIfLavConsorziDuplicata(dittaUMAAziendaVO.getIdDittaUMA(), anno, lavConsorzioInsert.getIdCategoriaUtilizziUma(), lavConsorzioInsert
            .getIdLavorazioni(), lavConsorzioInsert.getIdAziendaSocio())){
    	errors.add("azienda", new ValidationError("Impossibile procedere. È già presente a sistema una lavorazione consorzi/cooperative con stessi uso del suolo, lavorazione e azienda selezionati."));
    }
    
    SolmrLogger.debug(this,"errors.size()=" + errors.size());
    if (errors.size() != 0)
    {
      request.setAttribute("errors", errors);
    }
    else
    {
      try
      {
        //SolmrLogger.debug(this,"umaFacadeClient.isDittaUmaConsorzio(dittaUMAAziendaVO.getIdDittaUMA() vale:   "+umaFacadeClient.isDittaUmaConsorzio(dittaUMAAziendaVO.getIdAzienda());
        if (umaFacadeClient.isDittaUmaConsorzio(dittaUMAAziendaVO.getIdAzienda()))
        {
          lavConsorzioInsert
              .setVersoLavorazione(SolmrConstants.VERSO_LAVORAZIONI_E);
        }
        else
        {
          lavConsorzioInsert
              .setVersoLavorazione(SolmrConstants.VERSO_LAVORAZIONI_S);
        }
        lavConsorzioInsert.setExtIdUtenteAggiornamento(ruoloUtenza
            .getIdUtente());

        lavConsorzioInsert.setNote(form.getNote());
        
        // solo se ext-idAzienda !=null e unitamisura tipo==S | K | M
        if (form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_S)
             || form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_K) 
             || form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_M))
            // !StringUtils.isStringEmpty(form.getSuperficie()))
        {          
          BigDecimal supOreCalc = null;
          if(form.getSuperficie() != null && !form.getSuperficie().trim().equals("")){
            supOreCalc = new BigDecimal(form.getSuperficie().replace(',', '.'));            
          }  
          lavConsorzioInsert.setSupOreCalcolata(supOreCalc);
        }
        
        
        
        SolmrLogger.debug(this,
            "prima del salvataggio form.getIstatComune() vale: "
                + form.getIstatComune());
        SolmrLogger.debug(this,
            "prima del salvataggio lavConsorzioInsert.getSupOreCalcolata() vale: "
                + lavConsorzioInsert.getSupOreCalcolata());

        lavConsorzioInsert.setExtIdUtenteAggiornamento(ruoloUtenza
            .getIdUtente());
        lavConsorzioInsert.setIdDittaUma(dittaUMAAziendaVO.getIdDittaUMA());
        lavConsorzioInsert
            .setAnnoCampagna(annoCampangaVO.getAnnoCampagna());
        umaFacadeClient.insertLavorazioneConsorzi(lavConsorzioInsert);
      }
      catch (SolmrException sexc)
      {
        SolmrLogger.debug(this, "catch SolmrEception sexc");
        if (sexc.getValidationErrors() != null)
        {
          SolmrLogger.debug(this,
              "        if (sexc.getValidationErrors()!=null)");
          ValidationErrors vErrors = sexc.getValidationErrors();
          if (vErrors.size() != 0)
          {
            SolmrLogger.debug(this, "          if (vErrors.size()!=0)");
            request.setAttribute("errors", vErrors);
						%>
						<jsp:forward page="<%=viewUrl%>" />
						<%
						return;
          }
        }
        else
        {
          SolmrLogger.debug(this, "          else (vErrors.size()!=0)");
          ValidationException valEx = new ValidationException(
              "Eccezione di validazione" + sexc.getMessage(), viewUrl);
          valEx.addMessage(sexc.toString(), "exception");
          throw valEx;
        }
        SolmrLogger.debug(this,
            "        dopo if (sexc.getValidationErrors()!=null)");
      }
      catch (Exception e)
      {
        ValidationException valEx = new ValidationException(
            "Eccezione di validazione" + e.getMessage(), viewUrl);
        valEx.addMessage(e.getMessage(), "exception");
        throw valEx;
      }
      String forwardUrl = elencoHtm;
      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
      {
        forwardUrl = elencoBisHtm;
      }

      session.setAttribute("notifica", "Inserimento eseguito con successo");
      response.sendRedirect(forwardUrl);
      return;
    }
  }
  else
  {

    if (request.getParameter("annulla.x") != null)
    {
      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
      {
        response.sendRedirect(elencoBisHtm);
      }
      else
      {
        response.sendRedirect(elencoHtm);
      }
      return;
    }
    else
    {
      /*SolmrLogger.debug(this,"\n\n\nsettaggio nuova dataCarico");
      SolmrLogger.debug(this,"dataCarico="+serraVO.getDataCaricoStr()+"\n\n\n");
      if (serraVO.getDataCaricoStr()==null)
      {
        serraVO.setDataCaricoStr(DateUtils.formatDate(new Date()));
      }
      request.setAttribute("serraVO",serraVO);*/
    }
  }
%>
<jsp:forward page="<%=viewUrl%>" />
<%!
  private ValidationErrors validateInsert(HttpServletRequest request,
      AggiornaConsorziFormVO form, LavConsorziVO lavConsorzioInsert) throws Exception
  {
    SolmrLogger.debug(this, "Sono in validateInsert..");
    ValidationErrors errors = new ValidationErrors();
    String usoSuolo = request.getParameter("usoSuolo");
    String idLavorazione = request.getParameter("idLavorazione");
    String azienda = request.getParameter("azienda");

    BigDecimal zero = new BigDecimal(0);

    SolmrLogger.debug(this, "1..");
    SolmrLogger.debug(this, "usoSuolo vale: " + usoSuolo);
    if (Validator.isEmpty(usoSuolo))
    {
      errors.add("usoSuolo", new ValidationError("Campo obbligatorio"));
    }
    else
    {
      lavConsorzioInsert.setIdCategoriaUtilizziUma(new Long(usoSuolo));
    }
    SolmrLogger.debug(this, "idLavorazione vale: " + idLavorazione);
    if (Validator.isEmpty(idLavorazione))
    {

      errors.add("idLavorazione", new ValidationError("Campo obbligatorio"));
    }
    else
    {
      StringTokenizer st = new StringTokenizer(idLavorazione, "|");
      if (st.hasMoreTokens())
      {
        //form.setIdLavorazone(st.nextToken());
        lavConsorzioInsert.setIdLavorazioni(new Long(st.nextToken()));
      }
    }    
    if (Validator.isEmpty(azienda)
     && (form.getVettAziendeConsorzio() != null) && (form.getVettAziendeConsorzio().size() > 0))
    {
      errors.add("azienda", new ValidationError("Campo obbligatorio"));
    }
    else
    {
      StringTokenizer st = new StringTokenizer(azienda, "|");
      if (st.hasMoreTokens())
      {
        st.nextToken();
        //form.setIdLavorazone(st.nextToken());
        lavConsorzioInsert.setIdAziendaSocio(new Long(st.nextToken()));
      }
    }


    SolmrLogger.debug(this, "3.."); 

    //LavContoTerziVO lavContoTerziVO = (LavContoTerziVO)vLavContoTerzi.get(i);

    //String idLavContoTerzi = lavContoTerziVO.getIdLavorazioneCT().toString();
    String esecuzioniStr = request.getParameter("numeroEsecuzioni");
    String macchinaUtilizzata = request.getParameter("idMacchina");
    String supOreStr = request.getParameter("supOreStr");

    String gasolioStr = request.getParameter("gasolioStr");
    String benzinaStr = request.getParameter("benzinaStr");

    String note = request.getParameter("note");
    //String maxEsecuzioni = request.getParameter("numeroEsecuzioni");

    SolmrLogger.debug(this, "4..");
    lavConsorzioInsert.setEsecuzioniStr(esecuzioniStr);

    lavConsorzioInsert.setSupOreStr(supOreStr);

    SolmrLogger.debug(this, "5..");
    if (!StringUtils.isStringEmpty(note))
    {
      if (note.length() > 1000)
      {
        errors.add("note", new ValidationError(
            "Il valore immesso non deve superare i 1000 caratteri"));
      }
      else
      {
        lavConsorzioInsert.setNote(note);
      }
    }

    //lavContoTerziInsert.setTotaleGasolioModStr(totGasolioDich);
    //lavContoTerziInsert.setTotaleBenzinaModStr(totBenzinaDich);
    SolmrLogger.debug(this, "NEL validateInsert form.getMaxEsecuzioni() vale: "
        + form.getMaxEsecuzioni());
    SolmrLogger.debug(this, "esecuzioniStr vale: " + esecuzioniStr);
    if (!StringUtils.isStringEmpty(form.getMaxEsecuzioni()))
    {
      long esecuzioniInput = 0;
      if (Validator.isEmpty(esecuzioniStr))
      {
        errors.add("esecuzioniStr", new ValidationError("Campo obbligatorio"));
      }
      else
      {
        long numeroEsecuzioni = Long.parseLong(form.getMaxEsecuzioni());

        try
        {
          esecuzioniInput = Long.parseLong(esecuzioniStr);
        }
        catch (Exception ex)
        {
          errors.add("esecuzioniStr", new ValidationError(
              "Valore numerico intero"));
        }
        //@@todo - Da verificare caricamento property flagEscludiEsecuzioniS
        //Se FLAG_ESCLUDI_ESECUZIONI = 'N', non controllo il max esecuzioni
       	if(form.getFlagEscludiEsecuzioni().equalsIgnoreCase("N"))
       	{
	        if (esecuzioniInput > numeroEsecuzioni)
	        {
	          errors.add("esecuzioniStr", new ValidationError(
	              "Non è possibile aumentare il valore del numero esecuzioni"));
	        }
	        else
	        {
	          lavConsorzioInsert.setNumeroEsecuzioni(new Long(esecuzioniInput));
	        }
	      }
        if (esecuzioniInput < 0)
          errors.add("esecuzioniStr", new ValidationError(
              "Non è possibile inserire un valore negativo"));

        /*if (esecuzioniInput > numeroEsecuzioni)
        {
          errors.add("esecuzioniStr", new ValidationError(
              "Non è possibile aumentare il valore del numero esecuzioni"));
        }*/
      }
    }
    SolmrLogger.debug(this, "6..");
    if (!StringUtils.isStringEmpty(form.getTipoUnitaMisura())
        && form.getTipoUnitaMisura().equalsIgnoreCase("T")
        && (!StringUtils.isStringEmpty(form.getIsConsorzio()) && form
            .getIsConsorzio().equalsIgnoreCase("true")))
    {
      //lavContoTerziInsert.setIdMacchinaStr(macchinaUtilizzata);
      //lavContoTerziInsert.setTipoUnitaMisura(form.getTipoUnitaMisura());dfgsdf
      SolmrLogger.debug(this, "NEL VALIDATO idMacchina vale: "
          + macchinaUtilizzata);
      if (Validator.isEmpty(macchinaUtilizzata))
      {
        errors.add("idMacchina", new ValidationError("Campo obbligatorio"));
      }
      else
      {
        StringTokenizer token = new StringTokenizer(macchinaUtilizzata, "|");
        lavConsorzioInsert.setIdMacchinaStr(token.nextToken());
        SolmrLogger.debug(this, "idMacchina ke setto nel vo di insert vale: "
            + lavConsorzioInsert.getIdMacchinaStr());
      }

    }
    SolmrLogger.debug(this, "Nel validate idUnitaMisura da salvare vale: "
        + form.getIdUnitaMisura());
    if (!StringUtils.isStringEmpty(form.getIdUnitaMisura()))
    {
      lavConsorzioInsert.setIdUnitaMisura(new Long(form.getIdUnitaMisura()));
    }
    //il campo è modificabile al ribasso solo se extIdAzienda != null
    SolmrLogger.debug(this, "Nel validate supOreStr vale: " + supOreStr);
    if (Validator.isEmpty(supOreStr))
    {
      errors.add("supOreStr", new ValidationError("Campo obbligatorio"));
    }
    else
    {

      SolmrLogger.debug(this, "nel validator supOreStr vale: %" + supOreStr
          + "%");
      SolmrLogger.debug(this, "nel validator form.getSupOre() vale: %"
          + form.getSupOre() + "%");
      SolmrLogger.debug(this, "nel validator form.getSuperficie() vale: "
          + form.getSuperficie());
      SolmrLogger.debug(this, "nel validator  form.getTipoUnitaMisura() vale: "
          + form.getTipoUnitaMisura());

      try
      {
        BigDecimal supOre = new BigDecimal(supOreStr.replace(',', '.'));
        BigDecimal superficieForm = null;
        try
        {
        superficieForm= new BigDecimal(form.getSuperficie()
            .replace(',', '.'));
        }
        catch(Exception e)
        {
          superficieForm=null;
        }
        if (superficieForm != null
            && supOre.compareTo(superficieForm) > 0
            && SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(form.getTipoUnitaMisura()))
        {
          errors.add("supOreStr", new ValidationError(
                    "Non è possibile aumentare il valore della superficie (valore massimo consentito "+StringUtils.formatDouble4(superficieForm)+" ha)"));
        }
        else if (superficieForm != null
            && supOre.compareTo(superficieForm) > 0
            && SolmrConstants.TIPO_UNITA_MISURA_K.equalsIgnoreCase(form.getTipoUnitaMisura()))
        {
          errors.add("supOreStr", new ValidationError(
                    "Non è possibile aumentare il valore della potenza (valore massimo consentito "+StringUtils.formatDouble4(superficieForm)+" kw)"));
        }
        else if (superficieForm != null
                && SolmrConstants.TIPO_UNITA_MISURA_M.equalsIgnoreCase(form.getTipoUnitaMisura()))
        {
        	BigDecimal superficieLineare = superficieForm.multiply(new BigDecimal(SolmrConstants.MAX_METRO_L));
        	if(supOre.compareTo(superficieLineare) > 0){
              errors.add("supOreStr", new ValidationError(
                        "La lunghezza indicata non può essere maggiore di "+StringUtils.formatDouble4(superficieLineare)+" metri"));
        	}
        }
        else if (supOre.compareTo(zero) == -1)
        {
          errors.add("supOreStr", new ValidationError(
              "Non è possibile inserire un valore negativo"));
        }
        else if (!Validator.validateDoubleDigit(supOreStr, 10, 4))
        {
          errors.add("supOreStr", new ValidationError("Il valore può avere al massimo 10 cifre intere e 4 decimali"));
        }
        else
        {
          SolmrLogger.debug(this, "nel validator lavConsorzioInsert vale: %"+ lavConsorzioInsert + "%");
          lavConsorzioInsert.setSupOre(supOre); 
          if (SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(form.getTipoUnitaMisura())
            || SolmrConstants.TIPO_UNITA_MISURA_K.equalsIgnoreCase(form.getTipoUnitaMisura())
          )
          {
            lavConsorzioInsert.setSupOreCalcolata(supOre);
          }
        }
      }
      catch (Exception ex)
      {
        ex.printStackTrace();
        errors.add("supOreStr", new ValidationError("Campo non numerico"));
      }
    }

    SolmrLogger.debug(this, "8..");

    SolmrLogger.debug(this, "9..");
    if (Validator.isEmpty(gasolioStr) && Validator.isEmpty(benzinaStr))
    {
      errors.add("gasolioStr", new ValidationError(
          "Valorizzare uno dei due campi: G(lt) o B(lt)"));
      errors.add("benzinaStr", new ValidationError(
          "Valorizzare uno dei due campi: G(lt) o B(lt)"));
    }
    else if (!Validator.isEmpty(gasolioStr) && !Validator.isEmpty(benzinaStr))
    {
      errors.add("gasolioStr", new ValidationError(
          "Valorizzare solo uno dei due campi: G(lt) o B(lt)"));
      errors.add("benzinaStr", new ValidationError(
          "Valorizzare solo uno dei due campi: G(lt) o B(lt)"));
    }
    else
    {
      if (!Validator.isEmpty(gasolioStr))
      {
        try
        {
          SolmrLogger.debug(this, "Nel validate gasolioStr: " + gasolioStr);
          SolmrLogger.debug(this, "Nel validate form.getMaxCarburante(): "
              + form.getMaxCarburante());
          long gasolio = Long.parseLong(gasolioStr);
          if (!Validator.isEmpty(form.getMaxCarburante())
              && gasolio > Long.parseLong(form.getMaxCarburante()))
          {
            errors.add("gasolioStr", new ValidationError(
                "Non è possibile aumentare la quantità"));
          }
          else if (gasolio < 0)
          {
            errors.add("gasolioStr", new ValidationError(
                "Non è possibile inserire un valore negativo"));
          }
          else
          {
            lavConsorzioInsert.setGasolioStr(gasolioStr);
          }

        }
        catch (Exception ex)
        {
          errors.add("gasolioStr", new ValidationError("Campo non numerico"));
        }
      }
      if (!Validator.isEmpty(benzinaStr))
      {
        try
        {
          long benzina = Long.parseLong(benzinaStr);
          SolmrLogger.debug(this, "benzina: " + benzina);
          SolmrLogger.debug(this, "form.getMaxCarburante(): "
              + form.getMaxCarburante());
          if (!Validator.isEmpty(form.getMaxCarburante())
              && benzina > Long.parseLong(form.getMaxCarburante()))
          {
            errors.add("benzinaStr", new ValidationError(
                "Non è possibile aumentare la quantità"));
          }
          else if (benzina < 0)
              errors.add("benzinaStr", new ValidationError(
                  "Non è possibile inserire un valore negativo"));
          else
          {
            lavConsorzioInsert.setBenzinaStr(benzinaStr);
          }
        }
        catch (Exception ex)
        {
          errors.add("benzinaStr", new ValidationError("Campo non numerico"));
        }
      }
    }
    
    SolmrLogger.debug(this, "10..");

    request.setAttribute("vLavContoTerzi", lavConsorzioInsert);
    return errors;
  }%>