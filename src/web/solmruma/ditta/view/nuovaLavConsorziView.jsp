<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@page import="it.csi.solmr.dto.uma.form.AggiornaConsorziFormVO"%>

<%
  String layout = "/ditta/layout/nuovaLavConsorzi.htm";
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layout);
%><%@include file="/include/menu.inc"%>
<%
  SolmrLogger.info(this, "Found layout: " + layout);
  boolean isOnChangeComboUsoSuolo="true".equals(request.getParameter("hdnOnChangeComboUsoSuolo"));
  boolean isOnChangeComboAzienda="true".equals(request.getParameter("hdnOnChangeComboAzienda"));
  SolmrLogger.debug(this, "SONO IN nuovaLavConsorziView...");
  ValidationErrors errors = (ValidationErrors) request
      .getAttribute("errors");

  AggiornaConsorziFormVO form = (AggiornaConsorziFormVO) session
      .getAttribute("formInserimentoConsorzi");
  SolmrLogger.debug(this, "form vale: " + form);

  //String coefficiente = (String)request.getAttribute("coefficiente");
  String coefficiente = form.getCoefficiente();
  if(coefficiente != null){
	  coefficiente = coefficiente.replace(",", ".");
  }
  htmpl.set("coefficiente", coefficiente);
  SolmrLogger.debug(this, "NELLA VIEW COEFFICIENTE VALE: "
      + form.getCoefficiente());
  String maggiorazione = "false";
  SolmrLogger.debug(this, "NELLA VIEW MAGGIORAZIONE....");
  SolmrLogger.debug(this, "NELLA VIEW codiceZonaAlt VALE: "+ form.getCodiceZonaAlt());
  // GETZONA
  if (form.getCodiceZonaAlt() != null && form.getCodiceZonaAlt().equals(SolmrConstants.CODICE_MONTAGNA))
  {
    maggiorazione = "true";
    SolmrLogger.debug(this, "NELLA VIEW MAGGIORAZIONE...  VALE:"
        + maggiorazione);
    form.setMaggiorazione(maggiorazione);
  }

  if (form != null)
  {

    SolmrLogger.debug(this, "form.getCuaa() vale: " + form.getCuaa());

    htmpl.set("maggiorazione", form.getMaggiorazione());

    htmpl.set("litriBase", form.getLitriBase());
    htmpl.set("litriMaggiorazione", form.getLitriMaggiorazione());
    htmpl.set("litriMedioImpasto", form.getLitriMedioImpasto());
    htmpl.set("litriTerDeclivi", form.getLitriTerDeclivi());
    htmpl.set("cavalli", form.getCavalli());
    htmpl.set("tipoCarburante", form.getTipoCarburante());
    htmpl.set("isConsorzio", form.getIsConsorzio());

    SolmrLogger.debug(this, "****nella view  form.getSuperficie() vale: "
        + form.getSuperficie());

    SolmrLogger.debug(this, "****nella view  form.getSupOre() vale: "
        + form.getSupOre());
        
    /*if(isOnChangeComboAzienda)
    {
      htmpl.set("supOreStr", form.getSuperficie());
    }
    else if (!isOnChangeComboUsoSuolo)
    {
	    if (Validator.isNotEmpty(form.getSupOre()))
	    {
	      htmpl.set("supOreStr", form.getSupOre());
	      //htmpl.set("supOreFatturaStr",form.getSupOre());
	
	    }
	    else if (Validator.isNotEmpty(form.getSuperficie())
	          && form.getTipoUnitaMisura().equalsIgnoreCase(
	              SolmrConstants.TIPO_UNITA_MISURA_S)
	          && Validator.isNotEmpty(form.getIdUsoSuolo()))
      {
        SolmrLogger.debug(this, "nella view form.getSuperficie vale: "
            + form.getSuperficie());
        htmpl.set("supOreStr", form.getSuperficie());
      }
    }*/
    
    
    if (Validator.isNotEmpty(form.getSuperficie())
            && (form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_S)
            || form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_K)
            )
            && Validator.isNotEmpty(form.getIdUsoSuolo())
            && Validator.isNotEmpty(form.getIdAziendaSocio()))
    {
      SolmrLogger.debug(this, "nella view form.getSuperficie vale: "
          + form.getSuperficie());
      htmpl.set("supOreStr", form.getSuperficie());
    }
    else
    {
      if(Validator.isNotEmpty(errors)
        && (errors.size() > 0))
      {
        htmpl.set("supOreStr", request.getParameter("supOreStr"));
      }
      else
      {    
        htmpl.set("supOreStr", "");
      }
    }
    
    
    /*if(!StringUtils.isStringEmpty(form.getSupOre())){	
    	htmpl.set("supOreStr",form.getSupOre());
    }else if(!StringUtils.isStringEmpty(form.getSuperficie()) 
    	&& form.getTipoUnitaMisura().equalsIgnoreCase(SolmrConstants.TIPO_UNITA_MISURA_S)){
    htmpl.set("supOreStr",form.getSuperficie());
    }*/

    htmpl.set("tipoUnitaMisura", form.getTipoUnitaMisura());
    htmpl.set("flagEscludiEsecuzioni", form.getFlagEscludiEsecuzioni());
    htmpl.set("unitaMisura", form.getCodiceUnitaMisura());

    SolmrLogger.debug(this, "NELLA VIEW form.getMaxCarburante() VALE: "
        + form.getMaxCarburante());

    htmpl.set("benzinaStr", form.getBenzina());
    htmpl.set("gasolioStr", form.getGasolio());
    htmpl.set("noteStr", form.getNote());

    SolmrLogger.debug(this, "NELLA VIEWW tipoUnitaMisura VALE: "
        + form.getTipoUnitaMisura());
    SolmrLogger.debug(this, "NELLA VIEWW codiceUnitaMisura VALE: "
        + form.getCodiceUnitaMisura());
    SolmrLogger.debug(this, "NELLA VIEWW form.getIsConsorzio() VALE: "
        + form.getIsConsorzio());
    if (null != form.getTipoUnitaMisura()
        && form.getTipoUnitaMisura().equalsIgnoreCase(
            SolmrConstants.TIPO_UNITA_MISURA_T)
        && (!StringUtils.isStringEmpty(form.getIsConsorzio()) && form
            .getIsConsorzio().equalsIgnoreCase("true")))
    {
      htmpl.newBlock("blkMacchina");

      if (form.getVettMacchine() != null
          && form.getVettMacchine().size() > 0)
      {
        SolmrLogger.debug(this, "form.getVettMacchine().size() vale: "
            + form.getVettMacchine().size());
        for (int i = 0; i < form.getVettMacchine().size(); i++)
        {
          htmpl.newBlock("blkComboMacchina");
          MacchinaVO elem = (MacchinaVO) form.getVettMacchine().get(i);
          //htmpl.set("blkMacchina.blkComboMacchina.idMacchina",elem.getIdMacchina()+"|"+elem.getMatriceVO().getPotenzaKW()+"|"+elem.getMatriceVO().getIdAlimentazione());
          htmpl.set("blkMacchina.blkComboMacchina.idMacchina", elem
              .getIdMacchina()
              + "|"
              + elem.getMatriceVO().getIdAlimentazione()
              + "|"
              + elem.getMatriceVO().getPotenzaKW());
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
      }

    }

    Vector vettUsoSuolo = form.getVettUsoSuolo();
    if (vettUsoSuolo != null && vettUsoSuolo.size() > 0)
    {
      SolmrLogger.debug(this, "NELLA VIEW vettUsoSuolo.size() VALE: "
          + vettUsoSuolo.size());
      for (int i = 0; i < vettUsoSuolo.size(); i++)
      {
        CategoriaUtilizzoUmaVO elem = (CategoriaUtilizzoUmaVO) vettUsoSuolo
            .get(i);
        htmpl.newBlock("blkComboUsoSuolo");
        htmpl.set("blkComboUsoSuolo.idUsoSuolo", ""
            + elem.getIdCategoriaUtilizzoUma()); 
            //+ "|" + elem.getSommaSuperficie());
        htmpl.set("blkComboUsoSuolo.descUsoSuolo", elem.getDescrizione());
        if (form.getIdUsoSuolo() != null
            && form.getIdUsoSuolo().equalsIgnoreCase(
                String.valueOf(elem.getIdCategoriaUtilizzoUma())))
        {
          htmpl.set("blkComboUsoSuolo.checkedUsoSuolo", "selected");
        }

      }
    }
    Vector vettLav = form.getVettLavorazioni();
    if (vettLav != null && vettLav.size() > 0)
    {
      SolmrLogger.debug(this, "NELLA VIEW vettLav.size() VALE: "
          + vettLav.size());
      for (int i = 0; i < vettLav.size(); i++)
      {
        TipoLavorazioneVO elem = (TipoLavorazioneVO) vettLav.get(i);
        htmpl.newBlock("blkComboLavorazione");
        htmpl.set("blkComboLavorazione.idLavorazione", ""
            + elem.getIdTipoLav() + "|" + elem.getLitriBase() + "|"
            + elem.getLitriTerreniDeclivi() + "|"
            + elem.getLitriMedioImpasto() + "|" + elem.getTipoUnitaMisura() + "|"
            + elem.getCoefficienteCavalli() + "|" + elem.getFlagEscludiEsecuzioni());
        htmpl.set("blkComboLavorazione.lavorazioneDesc", elem
            .getDescrizione());
        SolmrLogger.debug(this, "form.getIdLavorazone() vale: "
            + form.getIdLavorazone());
        SolmrLogger.debug(this, "elem.getIdTipoLav() vale: "
            + elem.getIdTipoLav());

        if (!isOnChangeComboUsoSuolo && form.getIdLavorazone() != null
            && form.getIdLavorazone().equalsIgnoreCase(
                String.valueOf(elem.getIdTipoLav())))
        {
          htmpl.set("blkComboLavorazione.checkedLavorazione", "selected");
        }

      }
    }
    
    Vector<DittaUMAAziendaVO> vettAziende = form.getVettAziendeConsorzio();
    if (vettAziende != null && vettAziende.size() > 0)
    {
      SolmrLogger.debug(this, "-- numero di azienda da caricare nella combo = "+ vettAziende.size());
      for (int i = 0; i < vettAziende.size(); i++)
      {
        DittaUMAAziendaVO elem = vettAziende.get(i);
        htmpl.newBlock("blkComboAziende");
        htmpl.set("blkComboAziende.azienda", "" + elem.getIdConsistenza()+"|"+elem.getIdAzienda());       
        htmpl.set("blkComboAziende.descAzienda", elem.getCuaa()+" - "+elem.getDenominazione());
        String denominazione = elem.getDenominazione()+" - "+elem.getSedelegIndirizzo()
          +" - "+elem.getSedelegComune()+" ("+elem.getSedelegProvincia()+")";
        htmpl.set("blkComboAziende.denominazioneAzienda", denominazione);

        if((form.getIdAziendaSocio() != null)
            && form.getIdAziendaSocio().equalsIgnoreCase(String.valueOf(elem.getIdAzienda())))
        {
          htmpl.set("blkComboAziende.checkedAzienda", "selected");
        }

      }
    }
    
    
    SolmrLogger.debug(this, "NELLA VIEW form.getNumeroEsecuzioni() VALE: "
        + form.getNumeroEsecuzioni());
    if (!StringUtils.isStringEmpty(form.getNumeroEsecuzioni()))
    {
      htmpl.set("esecuzioniStr", form.getNumeroEsecuzioni());
    }
    else
    {
      htmpl.set("esecuzioniStr", form.getMaxEsecuzioni());
    }

  }
  setErrors(htmpl, errors, request);

  if (errors != null && !errors.empty())
    HtmplUtil.setErrors(htmpl, errors, request);
  if (errors != null && errors.size() > 0)
  {
    SolmrLogger.debug(this, "&&&&&& nella view errors.size() vale: "
        + errors.size());
    SolmrLogger.debug(this, "&&&&&& nella view errors vale: " + errors);
    htmpl.set("eseguiCalcolaCarb", "false");

  }

  //this.errErrorValExc(htmpl, request, exception);
  //HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

  out.print(htmpl.text());
%>
<%!private void setErrors(Htmpl htmpl, ValidationErrors errors,
      HttpServletRequest request)
  {
    //settaggio degli eventuali errori dentro il blocco
    if (errors != null)
    {

      Iterator iterErr = errors.get("idMacchina");
      if (iterErr != null)
      {
        ValidationError err = (ValidationError) iterErr.next();
        HtmplUtil.setErrorsInBlocco("blkMacchina.err_idMacchina", htmpl,
            request, err);
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
