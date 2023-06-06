<%@page import="it.csi.solmr.dto.uma.ZonaAltimetricaVO"%>
<%@page import="it.csi.solmr.etc.SolmrConstants"%>
<%@page import="java.math.BigDecimal"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@page import="it.csi.solmr.dto.ComuneVO"%>
<%@page import="it.csi.solmr.dto.uma.MacchinaVO"%>
<%@page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@page import="it.csi.solmr.dto.profile.RuoloUtenza"%>
<%@page import="it.csi.solmr.client.uma.UmaFacadeClient"%>
<%@page import="it.csi.solmr.dto.uma.LavConsorziVO"%>
<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>

<%

  String layout = "/ditta/layout/modificaLavConsorzi.htm";
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layout);
  SolmrLogger.info(this, "Found layout: "+layout);

%>
  <%@include file = "/include/menu.inc" %>
<%

  SolmrLogger.debug(this, "   BEGIN modificaLavConsorziView");
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  Vector vLavConsorzi = (Vector)request.getAttribute("vLavConsorzi");
  HashMap hashMapMacchine = (HashMap)request.getAttribute("hashMapMacchine");
 // String codiceZonaAlt = (String)request.getAttribute("codiceZonaAlt"); 
  Boolean isConsorzio = (Boolean)request.getAttribute("isConsorzio");
  
  //boolean maggiorazione = false;
  
  /*if(codiceZonaAlt != null && codiceZonaAlt.equals(SolmrConstants.CODICE_MONTAGNA))
  {
	  maggiorazione = true;
  }*/
  
  String coefficiente = (String)request.getAttribute("coefficiente"); 
  htmpl.set("coefficiente",coefficiente);
  LavConsorziVO lavConsorzi = null;
  
  SolmrLogger.debug(this, " --- numero di lavorazioni consorzi da visualizzare ="+vLavConsorzi.size());
  for(int i = 0; i < vLavConsorzi.size();i++)
  {  
    // maggiorazione in base alla zona altimetrica dell'azienda per la quale sono state effettuati i lavori
    boolean maggiorazione = false;	
  	lavConsorzi = (LavConsorziVO)vLavConsorzi.get(i);
  	htmpl.newBlock("blkRecord");
  	SolmrLogger.debug(this, " --- ID_LAVORAZIONE_CONSORZI ="+lavConsorzi.getIdLavorazioneConsorzi());
  	htmpl.set("blkRecord.idLavorazioneConsorzi",lavConsorzi.getIdLavorazioneConsorzi().toString());
	String disabledMacchina = "";
	
	String tipoUnitaMisura = lavConsorzi.getTipoUnitaMisura();
	String flagEscludiEsecuzioni = lavConsorzi.getFlagEscludiEsecuzioni();
  	htmpl.set("blkRecord.usoDelSuolo",lavConsorzi.getDescCategoriaUtilizzo());
  	htmpl.set("blkRecord.lavorazione",lavConsorzi.getDescTipoLavorazione());
	if(Validator.isNotEmpty(lavConsorzi.getIdAziendaSocio())){
	    String azienda = "";
    	if(lavConsorzi.getCuaaAziendaSocio() != null && !lavConsorzi.getCuaaAziendaSocio().trim().equals(""))
      		azienda = lavConsorzi.getCuaaAziendaSocio();
    	if(lavConsorzi.getPiAziendaSocio() != null && !lavConsorzi.getPiAziendaSocio().trim().equals(""))
	  		azienda += " - "+lavConsorzi.getPiAziendaSocio();
		if(lavConsorzi.getDescAziendaSocio() != null && !lavConsorzi.getDescAziendaSocio().trim().equals(""))
	  		azienda +=  " - "+lavConsorzi.getDescAziendaSocio();
	     
	    htmpl.set("blkRecord.azienda", azienda);
	}
  	if(tipoUnitaMisura != null && (tipoUnitaMisura.equalsIgnoreCase("S") || tipoUnitaMisura.equalsIgnoreCase("P")
  	   || tipoUnitaMisura.equalsIgnoreCase("K") || SolmrConstants.TIPO_UNITA_MISURA_M.equals(tipoUnitaMisura)) 
  	  || isConsorzio.booleanValue() == false)
  	{
  		disabledMacchina = "disabled";
  	}
  	htmpl.set("blkRecord.disabledMacchina",disabledMacchina);
  	Vector listaMacchine = (Vector)hashMapMacchine.get(lavConsorzi.getIdLavorazioneConsorzi());
  	String idMacchina = lavConsorzi.getIdMacchinaStr();
  	String cavalli = null;
  	//se la ditta non è un consorzio i cavalli assumono il valore del campo coefficiente
  	if(isConsorzio.booleanValue() == false)
  		cavalli = lavConsorzi.getCoefficiente().toString();
  	SolmrLogger.debug(this,"isConsorzio: "+isConsorzio);
  	SolmrLogger.debug(this,"cavalli: "+cavalli);
  	
  	for(int y = 0;y < listaMacchine.size();y++)
  	{
			MacchinaVO macchinaVO = (MacchinaVO)listaMacchine.get(y);
			htmpl.newBlock("blkRecord.blkComboMacchina");
			htmpl.set("blkRecord.blkComboMacchina.id",macchinaVO.getIdMacchina()+"|"+macchinaVO.getMatriceVO().getPotenzaKW()+"|"+macchinaVO.getMatriceVO().getIdAlimentazione());
			StringBuffer descMacchina = new StringBuffer();
	        addStringForDescMacchina(descMacchina,macchinaVO.getMatriceVO().getCodBreveGenereMacchina());
			addStringForDescMacchina(descMacchina,macchinaVO.getTipoCategoriaVO().getDescrizione());
			String tipoMacchina=macchinaVO.getMatriceVO().getTipoMacchina();
			if (Validator.isEmpty(tipoMacchina))
			{
	        addStringForDescMacchina(descMacchina, macchinaVO.getDatiMacchinaVO().getMarca());
			}
			else
			{
			    addStringForDescMacchina(descMacchina,tipoMacchina);
			}
	        addStringForDescMacchina(descMacchina,macchinaVO.getTargaCorrente().getNumeroTarga());
		
			htmpl.set("blkRecord.blkComboMacchina.desc",descMacchina.toString());
			if(idMacchina != null && idMacchina.equals(macchinaVO.getIdMacchina()))
			{
				if(cavalli == null)
				{
					//se i cavalli non sono stati valorizzati vuol dire che la ditta è un consorzio 
					//e che il valore è preso dal campo potenzaKW.
					cavalli = macchinaVO.getMatriceVO().getPotenzaKW();
				}
				htmpl.set("blkRecord.blkComboMacchina.selected","selected");
				
				htmpl.set("blkRecord.tipoCarburante",macchinaVO.getMatriceVO().getIdAlimentazione());
			}
	}
	 	htmpl.set("blkRecord.cavalli",cavalli);
	 	htmpl.set("blkRecord.esecuzioniStr",lavConsorzi.getEsecuzioniStr());
	 	htmpl.set("blkRecord.unitaDiMisura",lavConsorzi.getCodiceUnitaMisura());
	 	htmpl.set("blkRecord.supOreStr",lavConsorzi.getSupOreStr());
	 	htmpl.set("blkRecord.gasolioStr",lavConsorzi.getGasolioStr());
	 	htmpl.set("blkRecord.benzinaStr",lavConsorzi.getBenzinaStr());
	 	htmpl.set("blkRecord.noteStr",lavConsorzi.getNote());
	 	
	 	setErrors(htmpl,errors,i,request);
	 	
	 	htmpl.set("blkRecord.litriBase",StringUtils.checkNull(lavConsorzi.getLitriBase()));
	
	 	htmpl.set("blkRecord.litriMedioImpasto",StringUtils.checkNull(lavConsorzi.getLitriMedioImpasto()));
	 	htmpl.set("blkRecord.litriTerDeclivi",StringUtils.checkNull(lavConsorzi.getLitriTerDeclivi()));
	 	htmpl.set("blkRecord.supOreCalcolata",StringUtils.checkNull(lavConsorzi.getSupOreCalcolata()));
	
	// ---- Controllo se è in una zona Montana, per vedere se deve avere una maggiorazione
	SolmrLogger.debug(this, "--- Controllo se è in una zona Montana, per vedere se deve avere una maggiorazione");  	
  	ZonaAltimetricaVO zonaAltimetricaVO =  lavConsorzi.getZonaAltimetricaAziendaLav();
  	if(zonaAltimetricaVO != null && zonaAltimetricaVO.getCodiceZonaAltimetrica().equals(SolmrConstants.CODICE_MONTAGNA)){
  	  SolmrLogger.debug(this, " --- caso di Zona Altimetrica = MONTAGNA");
  	  maggiorazione = true;
  	}
  	SolmrLogger.debug(this, " --- maggiorazione ="+maggiorazione);
  	htmpl.set("blkRecord.maggiorazione",""+maggiorazione);
  	// ------
  	
  	htmpl.set("blkRecord.tipoUnitaMisura",tipoUnitaMisura);
  	htmpl.set("blkRecord.flagEscludiEsecuzioni",flagEscludiEsecuzioni);
  	
  	String maxCarburante = lavConsorzi.getMaxCarburante();
  	if(maxCarburante == null)
  		maxCarburante = calcoloMaxCarburante(tipoUnitaMisura,lavConsorzi,maggiorazione,
  											 cavalli,coefficiente,flagEscludiEsecuzioni);
  	htmpl.set("blkRecord.maxCarburante",maxCarburante);
  } // ---- FINE ciclo Lavorazioni Consorzi
  
  
  String totaleGasolio = StringUtils.checkNull(lavConsorzi.getTotaleGasolio());
  String totaleBenzina = StringUtils.checkNull(lavConsorzi.getTotaleBenzina());
  

  htmpl.set("totaleGasolio",totaleGasolio);
  htmpl.set("totaleBenzina",totaleBenzina);
  
  HtmplUtil.setValues(htmpl, request);

  htmpl.set("pageFrom",request.getParameter("pageFrom"));
  
  if(errors != null && !errors.empty())
	  HtmplUtil.setErrors(htmpl, errors, request);


  SolmrLogger.debug(this, "   END modificaLavConsorziView");

  out.print(htmpl.text());

%>

<%!
	private void setErrors(Htmpl htmpl,ValidationErrors errors,int index,HttpServletRequest request)
	{
		//settaggio degli eventuali errori dentro il blocco
		if(errors != null)
		{
			Iterator iterErr = errors.get("esecuzioniStr"+index);
  		if(iterErr != null)
  		{
  			ValidationError err = (ValidationError)iterErr.next();
  			HtmplUtil.setErrorsInBlocco("blkRecord.err_esecuzioniStr",htmpl,request,err);
  		}
  		
   		iterErr = errors.get("idMacchina"+index);
  		if(iterErr != null)
  		{
  			ValidationError err = (ValidationError)iterErr.next();
  			HtmplUtil.setErrorsInBlocco("blkRecord.err_idMacchina",htmpl,request,err);
  		}
	  		
   		iterErr = errors.get("supOreStr"+index);
  		if(iterErr != null){
  			ValidationError err = (ValidationError)iterErr.next();
  			HtmplUtil.setErrorsInBlocco("blkRecord.err_supOreStr",htmpl,request,err);
  		}
  		
   		iterErr = errors.get("supOreFatturaStr"+index);
  		if(iterErr != null){
  			ValidationError err = (ValidationError)iterErr.next();
  			HtmplUtil.setErrorsInBlocco("blkRecord.err_supOreFatturaStr",htmpl,request,err);
  		}
  		
  		iterErr = errors.get("gasolioStr"+index);
  		if(iterErr != null){
  			ValidationError err = (ValidationError)iterErr.next();
  			HtmplUtil.setErrorsInBlocco("blkRecord.err_gasolioStr",htmpl,request,err);
  		}
  		
   		iterErr = errors.get("benzinaStr"+index);
  		if(iterErr != null){
  			ValidationError err = (ValidationError)iterErr.next();
  			HtmplUtil.setErrorsInBlocco("blkRecord.err_benzinaStr",htmpl,request,err);
  		}
  		
   		iterErr = errors.get("noteStr"+index);
  		if(iterErr != null){
  			ValidationError err = (ValidationError)iterErr.next();
  			HtmplUtil.setErrorsInBlocco("blkRecord.err_noteStr",htmpl,request,err);
  		}
  		
   		iterErr = errors.get("numeroFatturaStr"+index);
  		if(iterErr != null){
  			ValidationError err = (ValidationError)iterErr.next();
  			HtmplUtil.setErrorsInBlocco("blkRecord.err_numeroFatturaStr",htmpl,request,err);
  		}
  		
  		
 		}
	}
	
	private String calcoloMaxCarburante(String tipoUnitaMisura,LavConsorziVO lavConsorzi,
			boolean maggiorazione,String cavalli,String coefficiente,String flagEscludiEsecuzioni)
	{
		String maxCarburante = "";
		BigDecimal carburanteLimite = null;
		
		
		BigDecimal litriBase = lavConsorzi.getLitriBase();
	
		BigDecimal litriMedioImpasto = lavConsorzi.getLitriMedioImpasto();
		BigDecimal litriTerDeclivi = lavConsorzi.getLitriTerDeclivi();
		Long numeroEsecuzioni = lavConsorzi.getNumeroEsecuzioni();
		BigDecimal superficie = lavConsorzi.getSupOre();
		
		SolmrLogger.debug(this,"tipoUnitaMisura: "+tipoUnitaMisura);
		SolmrLogger.debug(this,"litriBase: "+litriBase);
	
		SolmrLogger.debug(this,"litriMedioImpasto: "+litriMedioImpasto);
		SolmrLogger.debug(this,"litriTerDeclivi: "+litriTerDeclivi);
		SolmrLogger.debug(this,"numeroEsecuzioni: "+numeroEsecuzioni);
		SolmrLogger.debug(this,"maggiorazione: "+maggiorazione);
		SolmrLogger.debug(this,"cavalli: "+cavalli);
		SolmrLogger.debug(this,"coefficiente: "+coefficiente);
		SolmrLogger.debug(this,"superficie: "+superficie);
		
		if(superficie != null)
		{
			if(tipoUnitaMisura.equals("S"))
			{
				carburanteLimite = litriBase.add(litriMedioImpasto);
				if(maggiorazione == true)
				{
					carburanteLimite = carburanteLimite.add(litriTerDeclivi);
				}
				carburanteLimite = carburanteLimite.multiply(superficie);
			}
			else if(tipoUnitaMisura.equals("T"))
			{
				carburanteLimite = superficie.multiply(new BigDecimal(cavalli)).multiply(new BigDecimal(coefficiente));
			}
			else if(tipoUnitaMisura.equals("P"))
      {
        carburanteLimite = superficie.multiply(litriBase);
      }
      else if(tipoUnitaMisura.equals("K"))
      {
        carburanteLimite = superficie.multiply(litriBase);
      }
      else if(SolmrConstants.TIPO_UNITA_MISURA_M.equals(tipoUnitaMisura))
      {
    	BigDecimal maxLin = new BigDecimal(SolmrConstants.MAX_METRO_L);
        carburanteLimite = superficie.multiply(litriBase).multiply(maxLin);
        carburanteLimite = carburanteLimite.add(superficie.multiply(litriMedioImpasto).multiply(maxLin));
      }		
			if(numeroEsecuzioni != null)
			{
				if(flagEscludiEsecuzioni == null || flagEscludiEsecuzioni.equalsIgnoreCase("") || flagEscludiEsecuzioni.equalsIgnoreCase("N"))
				{
					carburanteLimite = carburanteLimite.multiply(new BigDecimal(numeroEsecuzioni.longValue()));
				}
			}
			
			carburanteLimite = arrotondamento(carburanteLimite.doubleValue()); 
			maxCarburante = carburanteLimite.toString();
		}
		return maxCarburante;
	}
	
	private BigDecimal arrotondamento (double num)
	{
		num = num + 0.9999;
		num = Math.abs(Math.floor(num));
		return new BigDecimal(num);
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
