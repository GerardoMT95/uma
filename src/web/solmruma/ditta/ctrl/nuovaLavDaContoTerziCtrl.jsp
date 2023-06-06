<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="java.util.*"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@page import="it.csi.solmr.dto.uma.form.AggiornaDaContoTerziFormVO"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%
  String iridePageName = "nuovaLavDaContoTerziCtrl.jsp";
  request.setAttribute("DACONTOTERZI", Boolean.TRUE);
%><%@include file="/include/autorizzazione.inc"%>
<%
  SolmrLogger.debug(this,"SONO IN nuovaLavDaContoTerziCtrl.jsp");
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  String viewUrl = "/ditta/view/nuovaLavDaContoTerziView.jsp";

  String elencoHtm = "../../ditta/layout/elencoLavDaContoTerzi.htm";
  String elencoBisHtm = "../../ditta/layout/elencoLavDaContoTerziBis.htm";
  String validateUrl = "/ditta/view/nuovaLavDaContoTerziView.jsp";

  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");

  AggiornaDaContoTerziFormVO form = (AggiornaDaContoTerziFormVO) session
      .getAttribute("formInserimentoDCT");

  String flagPulisciSessione = (String) request
      .getAttribute("flagPulisciSessione");
  SolmrLogger.debug(this, "flagPulisciSessione vale: "
      + flagPulisciSessione);

  if (!StringUtils.isStringEmpty(flagPulisciSessione) || form == null)
  {
    form = new AggiornaDaContoTerziFormVO();
  }

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  AnnoCampagnaVO annoCampangaVO = (AnnoCampagnaVO) session
      .getAttribute("annoCampagna");

  String idAziendaPop = (String) request.getParameter("idAziendaPop");
  String provincia = (String) request.getParameter("provincia");
  String comune = (String) request.getParameter("comune");
  String sedelegaleIndirizzo = (String) request
      .getParameter("sedelegaleIndirizzo");
  String sedeLegale = (String) request.getParameter("sedeLegale");

  String cuaa = (String) request.getParameter("cuaaStr");
  String denominazione = (String) request.getParameter("denominazioneStr");
  String partitaIva = (String) request.getParameter("partitaIvaStr");

  if (idAziendaPop != null)
    SolmrLogger.debug(this, "idAziendaPop  lunghezza: %"
        + idAziendaPop.length() + "%");
  SolmrLogger.debug(this, "NEL CONTROLLER idAziendaPop  vale: %"
      + idAziendaPop + "%");
  if (!StringUtils.isStringEmpty(idAziendaPop)
      && !"null".equalsIgnoreCase(idAziendaPop))
  {
    form.setIdAzienda(idAziendaPop);
  }

  UmaFacadeClient umaClient = new UmaFacadeClient();
  SolmrLogger.debug(this, "NEL CONTROLLER sedelegaleIndirizzo  vale: %"
      + sedelegaleIndirizzo + "%");

  if (!StringUtils.isStringEmpty(sedelegaleIndirizzo))
  {
    form.setIndirizzoSedeLegale(sedelegaleIndirizzo);
  }

  if (!StringUtils.isStringEmpty(comune)
      && !StringUtils.isStringEmpty(provincia))
  {
    String desc = comune + "(" + provincia + ")";
    form.setSedeLegale(desc);
  }
  if (!StringUtils.isStringEmpty(sedeLegale))
  {
    form.setSedeLegale(sedeLegale);
  }

  String sedeLegaleStr = (String) request.getParameter("sedeLegaleStr");
  String indirizzoSedeLegaleStr = (String) request
      .getParameter("indirizzoSedeLegaleStr");
  String istatComune = (String) request.getParameter("istatComune");

  SolmrLogger.debug(this, "**** sedeLegaleStr vale: " + sedeLegaleStr);
  SolmrLogger.debug(this, "**** indirizzoSedeLegaleStr vale: "
      + indirizzoSedeLegaleStr);
  SolmrLogger.debug(this, "**** istatComune vale: " + istatComune);

  String note = (String) request.getParameter("note");
  form.setNote(note);

  if (!StringUtils.isStringEmpty(istatComune))
  {
    form.setIstatComune(istatComune);
  }

  if (!StringUtils.isStringEmpty(cuaa))
    cuaa = cuaa.trim();
  form.setCuaa(cuaa);
  form.setDenominazione(denominazione);
  form.setPartitaIva(partitaIva);

  if (!StringUtils.isStringEmpty(sedeLegaleStr))
  {
    form.setSedeLegale(sedeLegaleStr);
  }
  if (!StringUtils.isStringEmpty(indirizzoSedeLegaleStr))
  {
    form.setIndirizzoSedeLegale(indirizzoSedeLegaleStr);
  }

  
  // ---- Ricerco la zona altimetrica della ditta Uma sulla quale sto lavorando (me stessa)
  SolmrLogger.debug(this, "****dittaUMAAziendaVO.getIdDittaUMA() vale: "+ dittaUMAAziendaVO.getIdDittaUMA());
  if (null != dittaUMAAziendaVO.getIdDittaUMA()){
    String codiceZonaAlt = null;
    ZonaAltimetricaVO zonaAltimetrica = umaFacadeClient.getZonaAltByIdDittaUma(dittaUMAAziendaVO.getIdDittaUMA());
    if(zonaAltimetrica != null)
      codiceZonaAlt = zonaAltimetrica.getCodiceZonaAltimetrica();
    SolmrLogger.debug(this, " -- codiceZonaAlt ="+codiceZonaAlt);
    form.setCodiceZonaAlt(codiceZonaAlt);
  }

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

  String tipoUnitaMisura = (String) request.getParameter("tipoUnitaMisura");
  /*if(!StringUtils.isStringEmpty(tipoUnitaMisura)){
  		form.setTipoUnitaMisura(tipoUnitaMisura);
  }*/

  //999|1|1|1|1|T
  String idLavorazione = (String) request.getParameter("idLavorazione");
  SolmrLogger.debug(this, "idLavorazione vale: " + idLavorazione);
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
      form.setLitriMaggiorazione(st.nextToken());
    //SolmrLogger.debug(this,"3");
    if (st.hasMoreTokens())
      form.setLitriMedioImpasto(st.nextToken());
    //SolmrLogger.debug(this,"4");
    if (st.hasMoreTokens())
      form.setLitriTerDeclivi(st.nextToken());
    if (st.hasMoreTokens())
      // SolmrLogger.debug(this,"5");
      if (st.hasMoreTokens())
        form.setTipoUnitaMisura(st.nextToken());
    //SolmrLogger.debug(this,"6");
    if (st.hasMoreTokens())
      form.setCavalli(st.nextToken());
    //SolmrLogger.debug(this,"6");
  }
  else
  {
    form.setIdLavorazone(null);
  }

  SolmrLogger
      .debug(this, "Nella ctrl idLavorazione vale: " + idLavorazione);
  SolmrLogger.debug(this, "Nella ctrl form.getLitriBase vale: "
      + form.getLitriBase());
  SolmrLogger.debug(this, "Nella ctrl form.getLitriMaggiorazione vale: "
      + form.getLitriMaggiorazione());
  SolmrLogger.debug(this, "Nella ctrl form.getLitriMedioImpasto vale: "
      + form.getLitriMedioImpasto());
  SolmrLogger.debug(this, "Nella ctrl form.getLitriTerDeclivi vale: "
      + form.getLitriTerDeclivi());
  SolmrLogger.debug(this, "Nella ctrl form.getTipoUnitaMisura vale: "
      + form.getTipoUnitaMisura());

  String supOreStr = (String) request.getParameter("supOreStr");
  SolmrLogger
      .debug(this, "****nel controller supOreStr vale: " + supOreStr);
  form.setSupOre(supOreStr);

  SolmrLogger.debug(this,
      "SONO IN nuovaLavDaContoTerziCtrl e tipoUnitaMisura  vale: "
          + tipoUnitaMisura);

  String idMacchina = (String) request.getParameter("idMacchina");
  SolmrLogger.debug(this,
      "SONO IN nuovaLavDaContoTerziCtrl e idMacchina  vale: " + idMacchina);
  form.setIdMacchina(idMacchina);

  SolmrLogger.debug(this, "Nella ctrl idMacchina vale: " + idMacchina);

  /* String cavalli=(String)request.getParameter("cavalli");
   form.setCavalli(cavalli);

   SolmrLogger.debug(this,"Nella ctrl cavalli vale: "+cavalli);
   */
  String tipoCarburante = (String) request.getParameter("tipoCarburante");
  form.setTipoCarburante(tipoCarburante);

  SolmrLogger.debug(this, "Nella ctrl tipoCarburante vale: "
      + tipoCarburante);

  String ettari = (String) request.getParameter("ettari");
  if (!StringUtils.isStringEmpty(ettari))
  {
    form.setEttari(ettari);
  }

  String idUnitaMisura = (String) request.getParameter("idUnitaMisura");
  SolmrLogger.debug(this, "nel controller idUnitaMisura vale: "
      + idUnitaMisura);

  String gasolioStr = request.getParameter("gasolioStr");
  String benzinaStr = request.getParameter("benzinaStr");
  SolmrLogger.debug(this, "Nella ctrl gasolioStr vale: " + gasolioStr);
  SolmrLogger.debug(this, "Nella ctrl benzinaStr vale: " + benzinaStr);
  String maxCarburante = request.getParameter("maxCarburante");
  form.setGasolio(gasolioStr);
  form.setBenzina(benzinaStr);
  
  form.setMaxCarburante(maxCarburante);

  String esecuzioniStr = request.getParameter("numeroEsecuzioni");
  SolmrLogger.debug(this, "Nella ctrl numeroEsecuzioni vale: "
      + esecuzioniStr);
  form.setNumeroEsecuzioni(esecuzioniStr);

  SolmrLogger.debug(this,
      "PRIMA DI CHIAMARE  findCategorieUtilizzoUmaByIdDittaUma  idDittaUma vale: "
          + dittaUMAAziendaVO.getIdDittaUMA());

  SolmrLogger.debug(this,
      "PRIMA DI CHIAMARE  findCategorieUtilizzoUmaByIdDittaUma  ");
  form.setVettUsoSuolo(umaClient
      .findCategorieUtilizzoUmaByIdDittaUma(StringUtils
          .getLongValue(dittaUMAAziendaVO.getIdDittaUMA())));
  SolmrLogger.debug(this,
      "PRIMA DI CHIAMARE  findCategorieUtilizzoUmaByIdDittaUma  ");

  String usoSuolo = (String) request.getParameter("usoSuolo");
  SolmrLogger.debug(this, "NEL CONTROLLER usoSuolo VALE: " + usoSuolo);
  if (!StringUtils.isStringEmpty(usoSuolo))
  {
    StringTokenizer st = new StringTokenizer(usoSuolo, "|");
    if (st.hasMoreTokens())
      form.setIdUsoSuolo(st.nextToken());
    if (st.hasMoreTokens())
    {
      form.setSuperficie(st.nextToken());
    }

  }
  else
  {
    form.setIdUsoSuolo("");
    form.setSuperficie("");
  }
  
  if(form.getTipoUnitaMisura() != null && form.getTipoUnitaMisura().equals(SolmrConstants.TIPO_UNITA_MISURA_K))
    form.setSuperficie(umaClient.getDimensioneFabbricato(dittaUMAAziendaVO.getIdAzienda(),annoCampangaVO.getAnnoCampagna()).toString());   
  
  if (!StringUtils.isStringEmpty(form.getIdUsoSuolo()))
  {

    SolmrLogger.debug(this,
        "PRIMA DI CHIAMARE findElencoLavorazioniDCT CON form.getIdUsoSuolo(): "
            + form.getIdUsoSuolo());

    SolmrLogger.debug(this, "annoCampangaVO.getAnnoCampagna(): "
        + annoCampangaVO.getAnnoCampagna());
    Vector vettLavorazioni = umaClient.findElencoLavorazioniDCT(form.getIdUsoSuolo(),annoCampangaVO.getAnnoCampagna());
    SolmrLogger
        .debug(this, "DOPO LA CHIAMATA DI  findElencoLavorazioniDCT");
    form.setVettLavorazioni(vettLavorazioni);
  }

  // cerco il valore di superficie solo 
  // se l'azienda per la quale è stata fatta la lavorazione risulta essere censita in Anagrafe
  // ed è stato selezionato un valore dalla combo uso suolo

  if (!StringUtils.isStringEmpty(form.getIdUsoSuolo())
      && !StringUtils.isStringEmpty(form.getIdLavorazone()))
  {
    // Cerco il valore da proporre a video nel campo numero esecuzioni
    CategoriaColturaLavVO elem = umaClient.getCategoriaColturaLav(form.getIdLavorazone(), form.getIdUsoSuolo(), SolmrConstants.ID_TIPO_COLTURA_LAVORAZIONE_CONTO_TERZI_CONSORZI, annoCampangaVO.getAnnoCampagna());
    if (elem != null)
    {
      SolmrLogger.debug(this, "DOPO getCategoriaColturaLav 1...");
      SolmrLogger.debug(this, "elem.getMaxEsecuzione() VALE: "
          + elem.getMaxEsecuzione());
      SolmrLogger.debug(this, "elem.getCodiceUnitaMisura() VALE: "
          + elem.getCodiceUnitaMisura());

      //form.setNumeroEsecuzioni(""+elem.getMaxEsecuzione());
      if (null != elem.getMaxEsecuzione())
        form.setMaxEsecuzioni("" + elem.getMaxEsecuzione());
      else
        form.setMaxEsecuzioni("");
      form.setTipoUnitaMisura(elem.getTipoUnitaMisura());
      //form.setIdUnitaMisura(elem.getCodiceUnitaMisura());
      form.setCodiceUnitaMisura(elem.getCodiceUnitaMisura());
      //form.setTipoUnitaMisura(elem.getCodiceUnitaMisura());
      form.setIdUnitaMisura(StringUtils.getLongValue(elem
          .getIdUnitaMisura()));

    }

  }
  else
  {
    form.setTipoUnitaMisura("");
    form.setIdUnitaMisura("");
    form.setNumeroEsecuzioni("");
    form.setMaxEsecuzioni("");
  }

  SolmrLogger.debug(this,
      "ALLA FINE DEL CONTROLLER form.getidAzienda vale: "
          + form.getIdAzienda());
  session.setAttribute("formInserimentoDCT", form);

  if (request.getParameter("salva.x") != null)
  {
    SolmrLogger.debug(this,
        "nuovaLavDaContoTerziCtrl - SONO IN SALVAAAAAA   ");
    LavContoTerziVO lavContoTerziInsert = new LavContoTerziVO();
    ValidationErrors errors = validateInsert(request, form,
        lavContoTerziInsert, umaClient);
    SolmrLogger.debug(this,"errors.size()=" + errors.size());
    if (errors.size() != 0)
    {
      request.setAttribute("errors", errors);
    }
    else
    {
      try
      {
        // prima di fare insert controllo se
        //Se l'azienda indicata non è stata cercata nell'Anagrafe il sistema verifica se il CUAA indicato
        // è' presente in anagrafe richiamando il servizio di serviceGetListIdAziende 
        //passandogli come parametri il  CUAA, AttivitaBool: false e Schedario: false. 
        //Se il servizio ritorna almeno un'azienda il salvataggio si interrompe e viene visualizzato il 
        //messaggio 'Il CUAA indicato e' presente nell'Anagrafe delle imprese agricole ed agroalimentari: 
        //indicare l'azienda selezionando il pulsante 'Cerca azienda'
        SolmrLogger.debug(this, "Nel salva form.getIdAzienda() vale: "
            + form.getIdAzienda());
        SolmrLogger.debug(this, "Nel salva form.getCuaa() vale: "
            + form.getCuaa());
        if (form.getIdAzienda() == null
            && !StringUtils.isStringEmpty(form.getCuaa()))
        {
          AnagAziendaVO anag = new AnagAziendaVO();
          anag.setCUAA(form.getCuaa().trim());
          Vector vettAziende = umaFacadeClient.serviceGetListIdAziende(
              anag, new Boolean(false), new Boolean(false));
          if (vettAziende != null && vettAziende.size() > 0)
          {
            //throw new Exception("Il CUAA indicato e' presente nell'Anagrafe delle imprese agricole ed agroalimentari: indicare l'azienda selezionando il pulsante 'Cerca azienda'");
            String mess = "Il CUAA indicato e&rsquo; presente nell&rsquo;Anagrafe delle imprese agricole ed agroalimentari: indicare l&rsquo;azienda selezionando il pulsante &rsquo;Cerca azienda&rsquo;";
            throwValidation(mess, validateUrl);
          }
          else
          {
            String mess = "Il CUAA indicato non e&rsquo; censito nell&rsquo;Anagrafe.Se viene indicato un CUAA questo deve essere presente nell&rsquo;Anagrafe.";
            throwValidation(mess, validateUrl);
          }
        }        
        SolmrLogger.debug(this,
            "PRIMA DI INSERIMENTO dittaUMAAziendaVO.getIdDittaUMA() vale: "
                + dittaUMAAziendaVO.getIdDittaUMA());
        annoCampangaVO.setIdDittaUma(dittaUMAAziendaVO.getIdDittaUMA());
        annoCampangaVO
            .setVersoLavorazioni(SolmrConstants.VERSO_LAVORAZIONI_S);
        annoCampangaVO.setExtIdUtenteAggiornamento(ruoloUtenza
            .getIdUtente());

        /*	lavContoTerziInsert.setCuaa(form.getCuaa());
        	lavContoTerziInsert.setDenominazione(form.getDenominazione());
        	lavContoTerziInsert.setIndirizzoSedeLegale(form.getIndirizzoSedeLegale());
        	lavContoTerziInsert.setPartitaIva(partitaIva);
        	lavContoTerziInsert.setIstatSedeLegaleComune(form.getIstatComune());*/
        SolmrLogger.debug(this,
            "PRIMA DI INSERIMENTO form.getIdAzienda() vale: "
                + form.getIdAzienda());
        if (!StringUtils.isStringEmpty(form.getIdAzienda()))
        {
          lavContoTerziInsert
              .setExtIdAzienda(new Long(form.getIdAzienda()));
        }

        lavContoTerziInsert.setNote(form.getNote());
        
        lavContoTerziInsert.setConsumoDichiaratoStr(form.getBenzina());
        lavContoTerziInsert.setConsumoCalcolatoStr(form.getGasolio());
        lavContoTerziInsert.setTipoUnitaMisura(form.getTipoUnitaMisura());

        if (!StringUtils.isStringEmpty(form.getSuperficie())
            && (SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(form.getTipoUnitaMisura())
            || SolmrConstants.TIPO_UNITA_MISURA_K.equalsIgnoreCase(form.getTipoUnitaMisura())
            || SolmrConstants.TIPO_UNITA_MISURA_M.equalsIgnoreCase(form.getTipoUnitaMisura())
            ))
        {
          BigDecimal supOreCalc = new BigDecimal(form.getSuperficie()
              .replace(',', '.'));
          lavContoTerziInsert.setSupOreCalcolata(supOreCalc);
        }
        SolmrLogger.debug(this,
            "prima del salvataggio form.getIstatComune() vale: "
                + form.getIstatComune());
        SolmrLogger.debug(this,
            "prima del salvataggio lavContoTerziInsert.getSupOreCalcolata() vale: "
                + lavContoTerziInsert.getSupOreCalcolata());

        lavContoTerziInsert.setExtIdUtenteAggiornamento(ruoloUtenza
            .getIdUtente());
            
        // campo NotNullable DB_LAVORAZIONE_CONTOTERZI.LITRI_TERRENI_DECLIVI settato = 0    
        lavContoTerziInsert.setLitriAcclivita(new BigDecimal(0));    
            
        umaFacadeClient.inserisciLavorazioneContoTerzi(annoCampangaVO,
            lavContoTerziInsert);
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
            "123Eccezione di validazione" + e.getMessage(), viewUrl);
        valEx.addMessage(e.getMessage(), "exception");
        SolmrLogger.debug(this, "ECCEZIONEEEEEEEE" + e.getMessage());
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
<%!private void throwValidation(String msg, String validateUrl)
      throws ValidationException
  {
    ValidationException valEx = new ValidationException(msg, validateUrl);
    valEx.addMessage(msg, "exception");
    throw valEx;
  }

  private ValidationErrors validateInsert(HttpServletRequest request,
      AggiornaDaContoTerziFormVO form, LavContoTerziVO lavContoTerziInsert,
      UmaFacadeClient umaFacadeClient) throws Exception
  {
    SolmrLogger.debug(this, "Sono in validateInsert..");
    ValidationErrors errors = new ValidationErrors();
    //String totGasolioDich = request.getParameter("totGasolioStr");
    //String totBenzinaDich = request.getParameter("totBenzinaStr");
    String cuaa = request.getParameter("cuaaStr");
    String partitaIva = request.getParameter("partitaIvaStr");
    String usoSuolo = request.getParameter("usoSuolo");
    String idLavorazione = request.getParameter("idLavorazione");

    BigDecimal zero = new BigDecimal(0);

    if (!Validator.isEmpty(cuaa))
    {
      //errors.add("cuaaStr",new ValidationError("Campo obbligatorio"));
      if (!Validator.controlloCf(cuaa) && !Validator.controlloPIVA(cuaa))
      {
        errors.add("cuaaStr", new ValidationError("Cuaa non corretto"));
        SolmrLogger.debug(this, "errore cuaa..");
      }
    }
    if (!Validator.isEmpty(partitaIva))
    {
      if (!Validator.controlloPIVA(partitaIva))
      {
        errors.add("partitaIvaStr", new ValidationError(
            "Partita Iva non corretta"));
        SolmrLogger.debug(this, "errore pi..");
      }
    }

    SolmrLogger.debug(this, "1..");

    if (Validator.isEmpty(usoSuolo))
    {
      errors.add("usoSuolo", new ValidationError("Campo obbligatorio"));
      SolmrLogger.debug(this, "errore usoSuolo..");
    }
    else
    {
      StringTokenizer st = new StringTokenizer(usoSuolo, "|");
      if (st.hasMoreTokens())
        lavContoTerziInsert.setIdCategoriaUtilizziUma(new Long(st.nextToken()));
    }
    SolmrLogger.debug(this, "idLavorazione vale: " + idLavorazione);
    if (Validator.isEmpty(idLavorazione))
    {
      errors.add("idLavorazione", new ValidationError("Campo obbligatorio"));
      SolmrLogger.debug(this, "errore idLavorazione..");
    }
    else
    {
      StringTokenizer st = new StringTokenizer(idLavorazione, "|");
      if (st.hasMoreTokens())
      {
        //form.setIdLavorazone(st.nextToken());
        lavContoTerziInsert.setIdLavorazoni(new Long(st.nextToken()));
      }
    }
    SolmrLogger.debug(this, "2..");

    SolmrLogger.debug(this, "3..");

    //LavContoTerziVO lavContoTerziVO = (LavContoTerziVO)vLavContoTerzi.get(i);

    //String idLavContoTerzi = lavContoTerziVO.getIdLavorazioneCT().toString();
    String esecuzioniStr = request.getParameter("numeroEsecuzioni");
    String supOreStr = request.getParameter("supOreStr");
    String gasolioStr = request.getParameter("gasolioStr");
    String benzinaStr = request.getParameter("benzinaStr");
    String note = request.getParameter("note");
    //String maxEsecuzioni = request.getParameter("numeroEsecuzioni");

    SolmrLogger.debug(this, "4..");
    lavContoTerziInsert.setEsecuzioniStr(esecuzioniStr);

    lavContoTerziInsert.setSupOreStr(supOreStr);

    SolmrLogger.debug(this, "5..");
    if (!StringUtils.isStringEmpty(note))
    {
      if (note.length() > 1000)
      {
        SolmrLogger.debug(this, "errore note..");
        errors.add("note", new ValidationError(
            "Il valore immesso non deve superare i 1000 caratteri"));
      }
      else
      {
        lavContoTerziInsert.setNote(note);
      }
    }

    //lavContoTerziInsert.setTotaleGasolioModStr(totGasolioDich);
    //lavContoTerziInsert.setTotaleBenzinaModStr(totBenzinaDich);
    SolmrLogger.debug(this, "NEL validateInsert form.getMaxEsecuzioni() vale: "
        + form.getMaxEsecuzioni());
    SolmrLogger.debug(this, "esecuzioniStr vale: " + esecuzioniStr);
    if (form.getMaxEsecuzioni() != null && !form.getMaxEsecuzioni().equals(""))
    {
      long esecuzioniInput = 0;
      if (Validator.isEmpty(esecuzioniStr))
      {
        errors.add("numeroEsecuzioni",
            new ValidationError("Campo obbligatorio"));
        SolmrLogger.debug(this, "errore numeroEsecuzioni..");
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
          errors.add("numeroEsecuzioni", new ValidationError(
              "Valore numerico intero"));
          SolmrLogger.debug(this, "errore numeroEsecuzioni..");
        }
        if (esecuzioniInput > numeroEsecuzioni)
        {
          errors.add("numeroEsecuzioni", new ValidationError(
              "Non è possibile aumentare il valore del numero esecuzioni"));
          SolmrLogger.debug(this, "errore numeroEsecuzioni..");
        }
        else
          if (esecuzioniInput < 0)
          {
            errors.add("numeroEsecuzioni", new ValidationError(
                "Non è possibile inserire un valore negativo"));
            SolmrLogger.debug(this, "errore numeroEsecuzioni..");
          }
          else
            if (esecuzioniInput > numeroEsecuzioni)
            {
              SolmrLogger.debug(this, "errore numeroEsecuzioni..");
              errors.add("numeroEsecuzioni", new ValidationError(
                  "Non è possibile aumentare il valore del numero esecuzioni"));
            }
            else
            {
              lavContoTerziInsert
                  .setNumeroEsecuzioni(new Long(esecuzioniInput));

            }
      }
    }
    SolmrLogger.debug(this, "6..");

    SolmrLogger.debug(this, "Nel validate idUnitaMisura da salvare vale: "
        + form.getIdUnitaMisura());
    if (!StringUtils.isStringEmpty(form.getIdUnitaMisura()))
    {
      lavContoTerziInsert.setIdUnitaMisura(new Long(form.getIdUnitaMisura()));
    }
    //il campo è modificabile al ribasso solo se extIdAzienda != null

    if (Validator.isEmpty(supOreStr))
    {
      errors.add("supOreStr", new ValidationError("Campo obbligatorio"));
      SolmrLogger.debug(this, "errore supOreStr..");
    }
    else
    {

      try
      {
        SolmrLogger.debug(this, "nel validator supOreStr vale: %" + supOreStr
            + "%");
        SolmrLogger.debug(this, "nel validator form.getSupOre() vale: %"
            + form.getSupOre() + "%");
        SolmrLogger.debug(this, "nel validator form.getSuperficie() vale: %"
            + form.getSuperficie() + "%");
        BigDecimal supOre = new BigDecimal(supOreStr.replace(',', '.'));
        if (form.getIdAzienda() != null)//{
          lavContoTerziInsert.setExtIdAzienda(new Long(form.getIdAzienda()));
        /*if(!StringUtils.isStringEmpty(form.getSuperficie())){
        	BigDecimal superficieForm = new BigDecimal(form.getSuperficie().replace(',','.'));
        	SolmrLogger.debug(this,"nel validator supOre vale: %"+supOre+"%");
        	SolmrLogger.debug(this,"nel validator superficieForm vale: %"+superficieForm+"%");
        	SolmrLogger.debug(this,"nel validator compareTo1 vale: %"+(superficieForm.compareTo(supOre))+"%");
        	SolmrLogger.debug(this,"nel validator compareTo2 vale: %"+(supOre.compareTo(superficieForm))+"%");
        	if(superficieForm.compareTo(supOre) > 0){
        		errors.add("supOreStr",new ValidationError("Non è possibile aumentare il valore della superficie"));
        	}
        }	
        if(supOre.compareTo(zero)<0){
        			errors.add("supOreStr",new ValidationError("Non è possibile inserire un valore negativo"));
        			SolmrLogger.debug(this,"errore supOreStr..");
        	}else if(!Validator.isNumericInteger(supOreStr)){//if(!Validator.validateDoubleDigit(supOreStr,10,4)){
        		errors.add("supOreStr",new ValidationError("Il valore deve essere intero"));
        		SolmrLogger.debug(this,"errore supOreStr..");
        	}else{
        		SolmrLogger.debug(this,"nel validator lavContoTerziInsert vale: %"+lavContoTerziInsert+"%");
        	    //lavContoTerziInsert.setSupOreCalcolata(supOre);
        		lavContoTerziInsert.setSupOre(supOre);
        		SolmrLogger.debug(this,"SONO NEL VALIDATE E SETTO SUPORECALCOLATA CON :"+supOre);
        }*/

        if (!StringUtils.isStringEmpty(form.getSuperficie())
            && SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(form
                .getTipoUnitaMisura()))
        {
          BigDecimal superficieForm = new BigDecimal(form.getSuperficie()
              .replace(',', '.'));
          SolmrLogger
              .debug(this, "nel validator supOre vale: %" + supOre + "%");
              
          if (supOre.compareTo(superficieForm) > 0)
          {
             errors.add("supOreStr", new ValidationError(
                 "Non è possibile aumentare il valore della superficie (valore massimo consentito "+StringUtils.formatDouble4(superficieForm)+" ha)"));
          }

        }
        if (!StringUtils.isStringEmpty(form.getSuperficie())
            && SolmrConstants.TIPO_UNITA_MISURA_M.equalsIgnoreCase(form
                .getTipoUnitaMisura()))
        {
          SolmrLogger.debug(this, "--  CASO TIPO_MISURA = 'M' --");
          BigDecimal superficieForm = new BigDecimal(form.getSuperficie().replace(',', '.'));
          SolmrLogger
              .debug(this, "nel validator supOre vale: %" + supOre + "%");
         
          superficieForm = superficieForm.multiply(new BigDecimal(SolmrConstants.MAX_METRO_L));
	        SolmrLogger.debug(this, "--- max superficie per metro lineare ="+ superficieForm);           
          if(supOre.compareTo(superficieForm)>0){
	          errors.add("supOreStr", new ValidationError("La lunghezza indicata non può essere maggiore di "+StringUtils.formatDouble4(superficieForm)+" metri"));
   		}
          
        }
        if (!StringUtils.isStringEmpty(form.getSuperficie())
                && SolmrConstants.TIPO_UNITA_MISURA_K.equalsIgnoreCase(form
                    .getTipoUnitaMisura()))
            {
              BigDecimal superficieForm = new BigDecimal(form.getSuperficie().replace(',', '.'));
              SolmrLogger
                  .debug(this, "nel validator supOre vale: %" + supOre + "%");
                  
              if (supOre.compareTo(superficieForm) > 0)
              {
                 errors.add("supOreStr", new ValidationError(
                     "Non è possibile aumentare il valore della potenza (valore massimo consentito "+StringUtils.formatDouble4(superficieForm)+" kw)"));
              }

        }
        if (supOre.compareTo(zero) < 0)
        {
          errors.add("supOreStr", new ValidationError(
              "Non è possibile inserire un valore negativo"));
        }
        else
          if (!Validator.validateDoubleDigit(supOreStr, 10, 4))
          {
            errors.add("supOreStr", new ValidationError(
                "Il valore può avere al massimo 10 cifre intere e 4 decimali"));
            SolmrLogger.debug(this, "errore supOreStr..");
          }
          else
          {
            SolmrLogger.debug(this, "nel validator lavContoTerziInsert vale: %"
                + lavContoTerziInsert + "%");
            lavContoTerziInsert.setSupOre(supOre);
            lavContoTerziInsert.setSupOreFatturaStr(form.getSupOre());
            
          }
        //}// END IF	
      }
      catch (Exception ex)
      {
        SolmrLogger.dumpStackTrace(this, "ERRORACCIO: " + ex, ex);
        errors.add("supOreStr", new ValidationError("Campo non numerico"));
      }

    }

    SolmrLogger.debug(this, "9..");
    if (Validator.isEmpty(benzinaStr))
    {
      errors.add("benzinaStr", new ValidationError(
          "Campo obbligatorio"));
    }
    else
      {
        if (!Validator.isEmpty(benzinaStr))
        {
          try
          {
            long benzina = Long.parseLong(benzinaStr);
            SolmrLogger.debug(this, "benzina: " + benzina);
            
            SolmrLogger.debug(this, "form.getMaxCarburante(): " + form.getMaxCarburante());
            if (!Validator.isEmpty(form.getMaxCarburante())
                && benzina > Long.parseLong(form.getMaxCarburante()))
            {
              errors.add("benzinaStr", new ValidationError(
                  "Non è possibile aumentare la quantità"));
              SolmrLogger.debug(this, "errore benzinaStr..");
            }
            else
            
            
            if (benzina < 0)
            {
              errors.add("benzinaStr", new ValidationError(
                  "Non è possibile inserire un valore negativo"));
            }
            else
            {
              lavContoTerziInsert.setBenzinaStr(benzinaStr);
            }
          }
          catch (Exception ex)
          {
            errors.add("benzinaStr", new ValidationError("Campo non numerico"));
            SolmrLogger.debug(this, "errore benzinaStr..");
          }
        }
      }
    SolmrLogger.debug(this, "10..");

    if (errors != null && errors.size() > 0)
    {
      request.setAttribute("cacolaCarburante", "false");
    }
    request.setAttribute("vLavContoTerzi", lavContoTerziInsert);
    return errors;
  }%>