<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@page import="it.csi.solmr.dto.uma.form.AggiornaDaContoTerziFormVO"%>

<%

  String layout = "/ditta/layout/nuovaLavDaContoTerzi.htm";
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layout);
%><%@include file = "/include/menu.inc" %><%  SolmrLogger.info(this, "Found layout: "+layout);

  SolmrLogger.debug(this,"SONO IN nuovaLavDaContoTerziView...");
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  AggiornaDaContoTerziFormVO form =(AggiornaDaContoTerziFormVO)session.getAttribute("formInserimentoDCT");
  SolmrLogger.debug(this,"form vale: "+form);
   SolmrLogger.debug(this,"ALL'INIZIO NELLA VIEWWW form.getIdAzienda() vale: "+form.getIdAzienda());
  
   AnnoCampagnaVO annoCampangaVO = (AnnoCampagnaVO) session.getAttribute("annoCampagna");
   htmpl.set("annoCampagna", annoCampangaVO.getAnnoCampagna());
    
 
  SolmrLogger.debug(this,"NELLA VIEW COEFFICIENTE VALE: "+form.getCoefficiente());
  String maggiorazione = "false";
 
  SolmrLogger.debug(this,"NELLA VIEW MAGGIORAZIONE....");
  SolmrLogger.debug(this,"NELLA VIEW codiceZonaAltimetrica ="+form.getCodiceZonaAlt());
  // GETZONA
  if( form.getCodiceZonaAlt() != null && form.getCodiceZonaAlt().equals(SolmrConstants.CODICE_MONTAGNA)){  
  		maggiorazione = "true";
  		form.setMaggiorazione(maggiorazione);
  }
 
  boolean isOnChangeComboUsoSuolo="true".equals(request.getParameter("hdnOnChangeComboUsoSuolo"));

  if(form!=null){
  	SolmrLogger.debug(this,"form.getCuaa() vale: "+form.getCuaa());
  	SolmrLogger.debug(this,"********form.getIdAzienda() vale: "+form.getIdAzienda());
  	SolmrLogger.debug(this,"form.getPartitaIva() vale: "+form.getPartitaIva());
  	SolmrLogger.debug(this,"form.getDenominazione() vale: "+form.getDenominazione());
  	SolmrLogger.debug(this,"************form.getNumeroEsecuzioni() vale: "+form.getNumeroEsecuzioni());
  	
  	htmpl.set("litriBase", form.getLitriBase());
  	htmpl.set("litriMaggiorazione", form.getLitriMaggiorazione());
 	htmpl.set("litriMedioImpasto", form.getLitriMedioImpasto());
  	htmpl.set("litriTerDeclivi", form.getLitriTerDeclivi());
  	
  	htmpl.set("tipoCarburante", form.getTipoCarburante());
  	htmpl.set("coefficiente",form.getCoefficiente());
  	
  	htmpl.set("maggiorazione", form.getMaggiorazione());
  	
  	
  	 SolmrLogger.debug(this,"****nella view  form.getSuperficie() vale: "+form.getSuperficie());
  	
  	 SolmrLogger.debug(this,"****nella view  form.getSupOre() vale: "+form.getSupOre());
  	  SolmrLogger.debug(this,"****nella view form.getTipoUnitaMisura() vale: "+form.getTipoUnitaMisura());
    if (!isOnChangeComboUsoSuolo)
    {
  	 
  	if(!StringUtils.isStringEmpty(form.getSupOre())){
  		htmpl.set("supOreStr", form.getSupOre());
  	}else if(!StringUtils.isStringEmpty(form.getSuperficie())
  	&& (!StringUtils.isStringEmpty(form.getTipoUnitaMisura())
  	&& (SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(form.getTipoUnitaMisura())
  	|| SolmrConstants.TIPO_UNITA_MISURA_K.equalsIgnoreCase(form.getTipoUnitaMisura())
  	))){
  		SolmrLogger.debug(this,"nella view form.getSuperficie vale: "+form.getSuperficie());
  		htmpl.set("supOreStr",form.getSuperficie());
  	}
    }  	
   
  	
  	
  	
  	htmpl.set("cuaaStr", form.getCuaa());
  	htmpl.set("partitaIvaStr", form.getPartitaIva());
  	htmpl.set("denominazioneStr", form.getDenominazione());
  	htmpl.set("sedeLegaleStr", form.getSedeLegale());
  	htmpl.set("indirizzoSedeLegaleStr", form.getIndirizzoSedeLegale());
  	htmpl.set("tipoUnitaMisura", form.getTipoUnitaMisura());
  	htmpl.set("unitaMisura", form.getCodiceUnitaMisura());
  	SolmrLogger.debug(this,"*****form.getBenzina() vale: "+form.getBenzina());
  	SolmrLogger.debug(this,"*****form.getGasolio() vale: "+form.getGasolio());
  	htmpl.set("benzinaStr", form.getBenzina());
  	htmpl.set("gasolioStr", form.getGasolio());
  	
  	
  	//htmpl.set("benzinaStr", form.getBenzina());
  	//htmpl.set("gasolioStr", form.getGasolio());
  	htmpl.set("noteStr", form.getNote());
    htmpl.set("cavalli", form.getCavalli());
  
  	
  	
  	SolmrLogger.debug(this,"NELLA VIEWW tipoUnitaMisura VALE: "+form.getTipoUnitaMisura());
  	
  
  }
  
  
  	Vector vettUsoSuolo = form.getVettUsoSuolo();
  	if(vettUsoSuolo!=null && vettUsoSuolo.size()>0){
  		SolmrLogger.debug(this,"NELLA VIEW vettUsoSuolo.size() VALE: "+vettUsoSuolo.size());
  		for(int i=0;i<vettUsoSuolo.size();i++){
  			CategoriaUtilizzoUmaVO elem=(CategoriaUtilizzoUmaVO)vettUsoSuolo.get(i);
  			htmpl.newBlock("blkComboUsoSuolo");
  			htmpl.set("blkComboUsoSuolo.idUsoSuolo",""+elem.getIdCategoriaUtilizzoUma()+"|"+elem.getSommaSuperficie());
  			htmpl.set("blkComboUsoSuolo.descUsoSuolo",elem.getDescrizione());
  			if (form.getIdUsoSuolo()!=null 
  				&& form.getIdUsoSuolo().equalsIgnoreCase(String.valueOf(elem.getIdCategoriaUtilizzoUma()))){
       		htmpl.set("blkComboUsoSuolo.checkedUsoSuolo","selected");
    	}
  			
  		}
  	}
  	Vector vettLav = form.getVettLavorazioni();
  	if(vettLav!=null && vettLav.size()>0){
  		SolmrLogger.debug(this,"NELLA VIEW vettLav.size() VALE: "+vettLav.size());
  		for(int i=0;i<vettLav.size();i++){
  			TipoLavorazioneVO elem=(TipoLavorazioneVO)vettLav.get(i);
  			htmpl.newBlock("blkComboLavorazione");
  			htmpl.set("blkComboLavorazione.idLavorazione",""+elem.getIdTipoLav()+"|"+elem.getLitriBase()+"|"+elem.getLitriMaggiorazioneConto3()+"|"+elem.getLitriMedioImpasto()
  			+"|"+elem.getLitriTerreniDeclivi()+"|"+elem.getTipoUnitaMisura()+"|"+elem.getCoefficienteCavalli());
  			htmpl.set("blkComboLavorazione.lavorazioneDesc",elem.getDescrizione());
  			SolmrLogger.debug(this,"form.getIdLavorazone() vale: "+form.getIdLavorazone());
  			SolmrLogger.debug(this,"elem.getIdTipoLav() vale: "+elem.getIdTipoLav());
  			
  			if (!isOnChangeComboUsoSuolo && form.getIdLavorazone()!=null 
  				&& form.getIdLavorazone().equalsIgnoreCase(String.valueOf(elem.getIdTipoLav()))){
       		htmpl.set("blkComboLavorazione.checkedLavorazione","selected");
    		}
  			
  		}
  	}
  	SolmrLogger.debug(this,"NELLA VIEW form.getNumeroEsecuzioni() VALE: "+form.getNumeroEsecuzioni());
  	if(!StringUtils.isStringEmpty(form.getNumeroEsecuzioni())){
  		htmpl.set("esecuzioniStr", form.getNumeroEsecuzioni());
  	}else{
  		htmpl.set("esecuzioniStr", form.getMaxEsecuzioni());
  	}
  	SolmrLogger.debug(this,"form.getMaxEsecuzioni() vale: "+form.getMaxEsecuzioni());
  	htmpl.set("maxEsecuzioni", form.getMaxEsecuzioni());
  


 

	SolmrLogger.debug(this,"ALLA FINE NELLA VIEWWW form.getIdAzienda() vale: "+form.getIdAzienda());
  //HtmplUtil.setErrors(htmpl, errors, request);

  //this.errErrorValExc(htmpl, request, exception);
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
  SolmrLogger.debug(this,"nella view errors vale: "+errors);
  if(errors!=null && errors.size()>0){
  	SolmrLogger.debug(this,"&&&&&& nella view errors.size() vale: "+errors.size());
  		SolmrLogger.debug(this,"&&&&&& nella view errors vale: "+errors);
  	htmpl.set("eseguiCalcolaCarb", "false");
  
  }
  out.print(htmpl.text());

%>