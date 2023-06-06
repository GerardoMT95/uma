<%@page import="it.csi.solmr.etc.SolmrConstants"%>
<%@page import="it.csi.solmr.dto.uma.ZonaAltimetricaVO"%>
<%@page import="java.math.BigDecimal"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@page import="it.csi.solmr.dto.uma.MacchinaVO"%>
<%@page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@page import="it.csi.solmr.dto.uma.LavContoTerziVO"%>
<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%!public static final Long UNO = new Long(1);%>
<%
	String layout = "/ditta/layout/modificaLavContoTerzi.htm";
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layout);
  SolmrLogger.info(this, "Found layout: "+layout);
%>
<%@include file="/include/menu.inc"%>
<%
	SolmrLogger.debug(this, "   BEGIN modificaLavContoTerzuView");

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  Vector vLavContoTerzi = (Vector)request.getAttribute("vLavContoTerzi");
  HashMap<Long, Boolean> mapScavalco = (HashMap<Long, Boolean>) session.getAttribute("vLavMapScavalco");
  
//  RuoloUtenza[] ruoloUtenzaAgg = (RuoloUtenza[])request.getAttribute("ruoloUtenzaAgg");
  
  AnagAziendaVO[] listaAnagAziendaVO = (AnagAziendaVO[])request.getAttribute("listaAnagAziendaVO");
  HashMap hashMapMacchine = (HashMap)request.getAttribute("hashMapMacchine");
  HashMap<Long,ZonaAltimetricaVO> hashZonaAlt = (HashMap<Long,ZonaAltimetricaVO>)request.getAttribute("hashZonaAlt"); 
  String coefficiente = (String)request.getAttribute("coefficiente");
  if(!StringUtils.isStringEmpty(coefficiente)){
	  coefficiente = coefficiente.replace(",", ".");
  }
  htmpl.set("coefficiente",coefficiente);
  htmpl.set("max_metro_lineare", String.valueOf(SolmrConstants.MAX_METRO_L));
  LavContoTerziVO lavContoTerzi = null;
  BigDecimal totaleConsCalc=BigDecimal.ZERO, totaleConsDich=BigDecimal.ZERO, totaleEccedenza=BigDecimal.ZERO;
  BigDecimal totaleGasolioCalc = BigDecimal.ZERO;
  
  StringBuffer recordId=new StringBuffer();
  StringBuffer recordTipoUnitaMisura=new StringBuffer();
  
  for(int i = 0; i < vLavContoTerzi.size();i++)
  {
  	SolmrLogger.debug(this,"numero iterazione: "+i);
  	lavContoTerzi = (LavContoTerziVO)vLavContoTerzi.get(i);
  	htmpl.newBlock("blkRecord");
  	SolmrLogger.debug(this," --- idLavorazioneContoTerzi ="+lavContoTerzi.getIdLavorazioneCT().toString());
  	htmpl.set("blkRecord.idLavContoTerzi",lavContoTerzi.getIdLavorazioneCT().toString());
  	String cuaa = lavContoTerzi.getCuaa();
		String pIva = lavContoTerzi.getPartitaIva();
		String denominazione = lavContoTerzi.getDenominazione();
		String disabledMacchina = "";
		boolean maggiorazione = false;
		String tipoUnitaMisura = lavContoTerzi.getTipoUnitaMisura();
		String flagEscludiEsecuzioni = lavContoTerzi.getFlagEscludiEsecuzioni();
		
		String codiceZonaAlt = null;
		String comuneZonaAlt = "";
		String descrZonaAlt = "";
		
  	if(listaAnagAziendaVO != null)
  	{
	  	for(int x = 0;x < listaAnagAziendaVO.length;x++)
	  	{
		AnagAziendaVO anagAziendaVO = listaAnagAziendaVO[x];
		if(lavContoTerzi.getExtIdAzienda() != null && lavContoTerzi.getExtIdAzienda().equals(anagAziendaVO.getIdAzienda()))
		{
			cuaa = anagAziendaVO.getCUAA();
			pIva = anagAziendaVO.getPartitaIVA();
			denominazione = anagAziendaVO.getDenominazione();
			break;
		}
	  	}
  	}
  	
  	SolmrLogger.debug(this," --- lavContoTerzi.getExtIdAzienda(): "+lavContoTerzi.getExtIdAzienda());
  	if(lavContoTerzi.getExtIdAzienda() != null){
  	   SolmrLogger.debug(this, "--- recupero la zona altrimetrica");
  	   if(hashZonaAlt != null){
  	     ZonaAltimetricaVO zonaAltimetrica = hashZonaAlt.get(lavContoTerzi.getExtIdAzienda()); 
  	     if(zonaAltimetrica != null){
  		   codiceZonaAlt = zonaAltimetrica.getCodiceZonaAltimetrica();
  		   comuneZonaAlt = zonaAltimetrica.getDescrComune();
  		   descrZonaAlt = zonaAltimetrica.getDescrZonaAltimetrica();
  		 }  
  	   }	
  	}
  	SolmrLogger.debug(this, "--- codiceZonaAlt = "+codiceZonaAlt);
  	
  	htmpl.set("blkRecord.cuaa",cuaa);
  	htmpl.set("blkRecord.partitaIva",pIva);
  	htmpl.set("blkRecord.denominazione",denominazione);
  	htmpl.set("blkRecord.usoDelSuolo",lavContoTerzi.getDescUsoDelSuolo());
  	htmpl.set("blkRecord.lavorazione",lavContoTerzi.getDescTipoLavorazione());
  	// NOTE : MODIFICA PER LA TOBECONFIG : LA COMBO MACCHINE VIENE ANCHE DISABILITATA PER IL TIPO UNITA DI MISURA 'T'
  	if(tipoUnitaMisura != null && (
  			tipoUnitaMisura.equalsIgnoreCase("K") || tipoUnitaMisura.equalsIgnoreCase("S") || tipoUnitaMisura.equalsIgnoreCase("P") || tipoUnitaMisura.equalsIgnoreCase("M") 
  			|| tipoUnitaMisura.equalsIgnoreCase("T")
  		 )
  	  )		
  		{
  		disabledMacchina = "disabled";
  	}
  	htmpl.set("blkRecord.disabledMacchina",disabledMacchina);
  	Vector listaMacchine = (Vector)hashMapMacchine.get(lavContoTerzi.getIdLavorazioneCT());
  	String idMacchina = lavContoTerzi.getIdMacchinaStr();
  	String cavalli = null;
  	
  	for(int y = 0;y < listaMacchine.size();y++)
  	{
		MacchinaVO macchinaVO = (MacchinaVO)listaMacchine.get(y);
		htmpl.newBlock("blkRecord.blkComboMacchina");
		SolmrLogger.debug(this, "--- idMacchina = "+macchinaVO.getIdMacchina());
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
	    SolmrLogger.debug(this, "--- descMacchina ="+descMacchina.toString());
	    htmpl.set("blkRecord.blkComboMacchina.desc",descMacchina.toString());
	if(idMacchina != null && idMacchina.equals(macchinaVO.getIdMacchina()))
	{
		cavalli = macchinaVO.getMatriceVO().getPotenzaKW();
		SolmrLogger.debug(this, "--- selected ="+idMacchina);
		htmpl.set("blkRecord.blkComboMacchina.selected","selected");
		htmpl.set("blkRecord.cavalli",cavalli);
		htmpl.set("blkRecord.tipoCarburante",macchinaVO.getMatriceVO().getIdAlimentazione());
	}
	}
  	
	 	htmpl.set("blkRecord.esecuzioniStr",lavContoTerzi.getEsecuzioniStr());
	 	htmpl.set("blkRecord.unitaDiMisura",lavContoTerzi.getDescUnitaMisura());
	 	
	 	if (SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(lavContoTerzi.getTipoUnitaMisura())
             || SolmrConstants.TIPO_UNITA_MISURA_K.equalsIgnoreCase(lavContoTerzi.getTipoUnitaMisura()) || SolmrConstants.TIPO_UNITA_MISURA_M.equalsIgnoreCase(lavContoTerzi.getTipoUnitaMisura()))
	 	{
	 	  htmpl.newBlock("blkRecord.blkSupHaFascicolo");
	 	  htmpl.set("blkRecord.blkSupHaFascicolo.idLavContoTerzi",lavContoTerzi.getIdLavorazioneCT().toString());
	 	  htmpl.set("blkRecord.blkSupHaFascicolo.supOreStr",lavContoTerzi.getSupOreCalcolataStr());
	 	}
	 	else
	 	{
      htmpl.newBlock("blkRecord.blkNoSupHaFascicolo");
      htmpl.set("blkRecord.blkNoSupHaFascicolo.idLavContoTerzi",lavContoTerzi.getIdLavorazioneCT().toString());
    }
	 	
	 	htmpl.set("blkRecord.supOreFatturaStr",lavContoTerzi.getSupOreFatturaStr());
	 	
	 	
	 	htmpl.set("blkRecord.gasolioStr",lavContoTerzi.getGasolioStr());
	 	htmpl.set("blkRecord.consumiCalcolatiStr",lavContoTerzi.getConsumoCalcolatoStr());
	 	htmpl.set("blkRecord.consumoDichiaratoStr",lavContoTerzi.getConsumoDichiaratoStr());
	 	htmpl.set("blkRecord.eccedenzaStr",lavContoTerzi.getEccedenzaStr());
	 	htmpl.set("blkRecord.numeroFatturaStr",StringUtils.checkNull(lavContoTerzi.getNumeroFatture()));
	 	
	 	if (lavContoTerzi.getConsumoCalcolato()!=null)
	   	totaleConsCalc=totaleConsCalc.add(lavContoTerzi.getConsumoCalcolato());
	  
	  if (lavContoTerzi.getConsumoDichiarato()!=null)
      totaleConsDich=totaleConsDich.add(lavContoTerzi.getConsumoDichiarato());
      
    if (lavContoTerzi.getEccedenza()!=null)
      totaleEccedenza=totaleEccedenza.add(lavContoTerzi.getEccedenza());   	
      
    if  (lavContoTerzi.getGasolio()!=null)
      totaleGasolioCalc=totaleGasolioCalc.add(lavContoTerzi.getGasolio());  
	 	
	 	// Zona altimetrica
	 	if(comuneZonaAlt != null && !comuneZonaAlt.trim().equals(""))
	 	  htmpl.set("blkRecord.comune",comuneZonaAlt);
	 	else
	 	  htmpl.set("blkRecord.comune","NON PRESENTE");
	 	
	 	if(descrZonaAlt != null && !descrZonaAlt.trim().equals(""))    
	 	  htmpl.set("blkRecord.zonaAltimetrica",descrZonaAlt);
	 	else
	 	  htmpl.set("blkRecord.zonaAltimetrica","NON PRESENTE"); 
	 	
	 	htmpl.set("blkRecord.noteStr",lavContoTerzi.getNote());
  	
	 	setErrors(htmpl,errors,lavContoTerzi.getIdLavorazioneCT().intValue(),request);
	 	
	 	htmpl.set("blkRecord.litriBase",StringUtils.checkNull(lavContoTerzi.getLitriBase()));
	 	htmpl.set("blkRecord.litriMaggiorazione",StringUtils.checkNull(lavContoTerzi.getLitriConto3()));
	 	htmpl.set("blkRecord.litriMedioImpasto",StringUtils.checkNull(lavContoTerzi.getLitriMedioImpasto()));
	 	
	 	htmpl.set("blkRecord.supOreCalcolata",StringUtils.checkNull(lavContoTerzi.getSupOreCalcolata()));
	 	
	 	if(codiceZonaAlt != null && codiceZonaAlt.equals(SolmrConstants.CODICE_MONTAGNA))
	 	{
	 		maggiorazione = true;
	 	}
  	    htmpl.set("blkRecord.maggiorazione",""+maggiorazione);
  	
  	// Serve per il calcolo maxLitriAcclivita
  	SolmrLogger.debug(this, "--- litriTerDeclivi ="+lavContoTerzi.getLitriTerDeclivi());
	htmpl.set("blkRecord.litriTerDeclivi",StringUtils.checkNull(lavContoTerzi.getLitriTerDeclivi()));
	 	
  	// Litri Acclività : campo disabilitato se non prevista la maggiorazione o se unita misura = 'T'
  	htmpl.set("blkRecord.litriAcclivita",StringUtils.checkNull(lavContoTerzi.getLitriAcclivitaStr()));
  	if(!maggiorazione || SolmrConstants.TIPO_UNITA_MISURA_T.equals(tipoUnitaMisura) || SolmrConstants.TIPO_UNITA_MISURA_M.equals(tipoUnitaMisura)){
  	  htmpl.set("blkRecord.readonlyLitriAcclivita", "readonly style='background-color:LightGrey'");
  	}
  	htmpl.set("blkRecord.tipoUnitaMisura",tipoUnitaMisura);
  	htmpl.set("blkRecord.flagEscludiEsecuzioni",flagEscludiEsecuzioni);
  	
  	if (i!=0) 
  	{
  	   recordId.append(",");
  	   recordTipoUnitaMisura.append(",");
  	}
  	recordId.append(lavContoTerzi.getIdLavorazioneCT().toString());
  	recordTipoUnitaMisura.append("'").append(tipoUnitaMisura).append("'");
  	
  	
  	// Calcolo del maxCarburante e del maxLitriAcclività  	
  	calcoloMaxCarburanteLitriAcclivita(tipoUnitaMisura,lavContoTerzi,maggiorazione,cavalli,coefficiente,flagEscludiEsecuzioni,htmpl);

	if(mapScavalco.get(lavContoTerzi.getIdLavorazioneCT())!=null && !mapScavalco.get(lavContoTerzi.getIdLavorazioneCT())){
    	htmpl.set("blkRecord.enableScavalco","disabled");
  	}else{
  		if(lavContoTerzi.isScavalco()){
  			htmpl.set("blkRecord.enableScavalco","checked");
  		}
  	}
   	
  } // chiusura ciclo LAVORAZION CONTO TERZI DA VISUALIZZARE IN MODIFICA
  
  htmpl.bset("recordId",recordId.toString());
  htmpl.bset("recordTipoUnitaMisura",recordTipoUnitaMisura.toString());
  
  //String totaleGasolioCalc = StringUtils.checkNull(lavContoTerzi.getTotaleGasolio());
  
  String totGasolioMod = lavContoTerzi.getTotaleGasolioModStr() != null ? lavContoTerzi.getTotaleGasolioModStr() : null;

  htmpl.set("totaleGasolioCalc",totaleGasolioCalc.toString());
  htmpl.set("totaleConsCalc",totaleConsCalc.toString());
  htmpl.set("totaleConsDich",totaleConsDich.toString());
  htmpl.set("totaleEccedenza",totaleEccedenza.toString());
  

  String annoCampagnaVO = ((it.csi.solmr.dto.uma.AnnoCampagnaVO) session.getAttribute("annoCampagna")).getAnnoCampagna();
            
  String umar=(String)request.getAttribute("PARAMETRO_UMAR");  
  
  //confrontto l'anno campagna con l'anno recuperato da DB
  if (Long.parseLong(annoCampagnaVO)<=Long.parseLong(umar) && totGasolioMod!=null)
  {
    htmpl.newBlock("blkTotGasolioReadonly");
    htmpl.set("blkTotGasolioReadonly.totaleGasolioDich",totGasolioMod);
  }
  
  

  HtmplUtil.setValues(htmpl, request);

  htmpl.set("pageFrom",request.getParameter("pageFrom"));
  
  if(errors != null && !errors.empty())
	  HtmplUtil.setErrors(htmpl, errors, request);


  SolmrLogger.debug(this, "   END modificaLavContoTerziView");

  out.print(htmpl.text());
%>

<%!private void setErrors(Htmpl htmpl, ValidationErrors errors, int index, HttpServletRequest request) {
		//settaggio degli eventuali errori dentro il blocco
		if (errors != null) {
			Iterator iterErr = errors.get("esecuzioniStr" + index);
			if (iterErr != null) {
				ValidationError err = (ValidationError) iterErr.next();
				HtmplUtil.setErrorsInBlocco("blkRecord.err_esecuzioniStr", htmpl, request, err);
			}

			iterErr = errors.get("idMacchina" + index);
			if (iterErr != null) {
				ValidationError err = (ValidationError) iterErr.next();
				HtmplUtil.setErrorsInBlocco("blkRecord.err_idMacchina", htmpl, request, err);
			}

			iterErr = errors.get("litriAcclivita" + index);
			if (iterErr != null) {
				ValidationError err = (ValidationError) iterErr.next();
				HtmplUtil.setErrorsInBlocco("blkRecord.err_litriAcclivita", htmpl, request, err);
			}

			iterErr = errors.get("supOreStr" + index);
			if (iterErr != null) {
				ValidationError err = (ValidationError) iterErr.next();
				HtmplUtil.setErrorsInBlocco("blkRecord.err_supOreFatturaStr", htmpl, request, err);
			}

			iterErr = errors.get("supOreFatturaStr" + index);
			if (iterErr != null) {
				ValidationError err = (ValidationError) iterErr.next();
				HtmplUtil.setErrorsInBlocco("blkRecord.err_supOreFatturaStr", htmpl, request, err);
			}

			iterErr = errors.get("consumoDichiaratoStr" + index);
			if (iterErr != null) {
				ValidationError err = (ValidationError) iterErr.next();
				HtmplUtil.setErrorsInBlocco("blkRecord.err_consumoDichiaratoStr", htmpl, request, err);
			}

			iterErr = errors.get("noteStr" + index);
			if (iterErr != null) {
				ValidationError err = (ValidationError) iterErr.next();
				HtmplUtil.setErrorsInBlocco("blkRecord.err_noteStr", htmpl, request, err);
			}

			iterErr = errors.get("numeroFatturaStr" + index);
			if (iterErr != null) {
				ValidationError err = (ValidationError) iterErr.next();
				HtmplUtil.setErrorsInBlocco("blkRecord.err_numeroFatturaStr", htmpl, request, err);
			}

		}
	}

	// Calcola il MAX CARBURANTE ed il MAX LITRI ACCLIVITA' e setta i valori nei campi di hidden 
	private void calcoloMaxCarburanteLitriAcclivita(String tipoUnitaMisura, LavContoTerziVO lavContoTerzi, boolean maggiorazione, String cavalli, String coefficiente, String flagEscludiEsecuzioni,
			Htmpl htmpl) throws Exception {
		SolmrLogger.debug(this, "   BEGIN calcoloMaxCarburanteLitriAcclivita");

		BigDecimal carburanteLimite = new BigDecimal("0");
		BigDecimal litriAcclitivaLimite = new BigDecimal("0");

		BigDecimal litriBase = lavContoTerzi.getLitriBase();
		BigDecimal litriMaggiorazione = lavContoTerzi.getLitriConto3();
		BigDecimal litriMedioImpasto = lavContoTerzi.getLitriMedioImpasto();
		BigDecimal litriTerDeclivi = lavContoTerzi.getLitriTerDeclivi();
		Long numeroEsecuzioni = lavContoTerzi.getNumeroEsecuzioni();
		BigDecimal superficie = lavContoTerzi.getSupOre();

		SolmrLogger.debug(this, "-- tipoUnitaMisura: " + tipoUnitaMisura);
		SolmrLogger.debug(this, "-- flagEscludiEsecuzioni: " + flagEscludiEsecuzioni);
		SolmrLogger.debug(this, "-- litriBase: " + litriBase);
		SolmrLogger.debug(this, "-- litriMaggiorazione: " + litriMaggiorazione);
		SolmrLogger.debug(this, "-- litriMedioImpasto: " + litriMedioImpasto);
		SolmrLogger.debug(this, "-- litriTerDeclivi: " + litriTerDeclivi);
		SolmrLogger.debug(this, "-- numeroEsecuzioni: " + numeroEsecuzioni);
		SolmrLogger.debug(this, "-- maggiorazione: " + maggiorazione);
		SolmrLogger.debug(this, "-- cavalli: " + cavalli);
		SolmrLogger.debug(this, "-- coefficiente: " + coefficiente);
		SolmrLogger.debug(this, "-- superficie: " + superficie);

		/*String maxCarburante = lavContoTerzi.getMaxCarburante();  	
		String maxLitriAcclivita = lavContoTerzi.getMaxLitriAcclivita();*/
		String maxCarburante = "";
		String maxLitriAcclivita = "";

		//if(maxCarburante == null){		
		if (superficie != null) {
			SolmrLogger.debug(this, " --- CALCOLARE il valore di MAX CARBURANTE");
			if (SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(tipoUnitaMisura) || SolmrConstants.TIPO_UNITA_MISURA_K.equalsIgnoreCase(tipoUnitaMisura)) {
				SolmrLogger.debug(this, " --- CASO unità di misura = 'S'");
				if (numeroEsecuzioni != null) {
					SolmrLogger.debug(this, " --- numeroEsecuzioni != null");
					if (flagEscludiEsecuzioni == null || flagEscludiEsecuzioni.equalsIgnoreCase("") || flagEscludiEsecuzioni.equalsIgnoreCase("N")) {
						SolmrLogger.debug(this, " --- flagEscludiEsecuzioni vuoto o = 'N'");
						carburanteLimite = litriBase.multiply(new BigDecimal(numeroEsecuzioni.longValue()));
						// Attenzione : i litriMaggiorazione NON devono essere moltiplicati per il numero esecuzioni
						carburanteLimite = carburanteLimite.add(litriMaggiorazione);
						carburanteLimite = carburanteLimite.add(litriMedioImpasto.multiply(new BigDecimal(numeroEsecuzioni.longValue())));
					} else {
						SolmrLogger.debug(this, " --- flagEscludiEsecuzioni = 'S'");
						SolmrLogger.debug(this, "tipoUnitaMisura=S && flagEscludiEsecuzioni==S");
						carburanteLimite = (litriBase.add(litriMaggiorazione)).add(litriMedioImpasto);
					}
				} else {
					SolmrLogger.debug(this, " --- numeroEsecuzioni == null");
					carburanteLimite = (litriBase.add(litriMaggiorazione)).add(litriMedioImpasto);
				}
				// Solo in questo caso il campo 'litri Acclività' è abilitato ed è necessario calcolare il maxLitriAcclività
				if (maggiorazione == true) {
					SolmrLogger.debug(this, " --- caso di MAGGIORAZIONE");
					carburanteLimite = carburanteLimite.add(litriTerDeclivi.multiply(new BigDecimal(NumberUtils.nvl(numeroEsecuzioni, UNO).longValue())));

					// -----------  CALCOLO MAX LITRI ACCLIVITA' --------
					//if(maxLitriAcclivita == null){
					SolmrLogger.debug(this, " --- CALCOLARE il valore di MAX LITRI ACCLIVITA'");
					if (numeroEsecuzioni != null && !numeroEsecuzioni.equals("") && (flagEscludiEsecuzioni == null || flagEscludiEsecuzioni.equals("") || flagEscludiEsecuzioni.equals("N"))) {
						SolmrLogger.debug(this, " -- è stato settato il numeroEsecuzioni e flagEscludiEsecuzioni non è valorizzato o è = 'N'");
						SolmrLogger.debug(this, " -- litriTerDeclivi =" + litriTerDeclivi);
						SolmrLogger.debug(this, " -- numeroEsecuzioni =" + numeroEsecuzioni);
						SolmrLogger.debug(this, " -- superficie =" + superficie);
						litriAcclitivaLimite = (litriTerDeclivi.multiply(new BigDecimal(numeroEsecuzioni))).multiply(superficie);
					} else {
						litriAcclitivaLimite = litriTerDeclivi.multiply(superficie);
					}
					//}
					// -----------------------------------------------------
				}
				SolmrLogger.debug(this, " --- carburanteLimite calcolato =" + carburanteLimite);
				SolmrLogger.debug(this, " --- superficie =" + superficie);
				carburanteLimite = carburanteLimite.multiply(superficie);
				SolmrLogger.debug(this, " --- carburanteLimite finale =" + carburanteLimite);

			}// fine CASO 'unitaMisura' = 'S'
			else if (tipoUnitaMisura.equals("T") && cavalli != null) {
				SolmrLogger.debug(this, " --- CASO unità di misura = 'T'");
				carburanteLimite = superficie.multiply(new BigDecimal(cavalli)).multiply(new BigDecimal(coefficiente));
				if (carburanteLimite != null && numeroEsecuzioni != null) {
					if (flagEscludiEsecuzioni == null || flagEscludiEsecuzioni.equalsIgnoreCase("") || flagEscludiEsecuzioni.equalsIgnoreCase("N")) {
						carburanteLimite = carburanteLimite.multiply(new BigDecimal(numeroEsecuzioni.longValue()));
					} else {
						SolmrLogger.debug(this, "tipoUnitaMisura=T && flagEscludiEsecuzioni==S");
					}
				}
				// Note : nel caso di 'unitaMisura' = 'T' il campo è sempre disabilitato			
			}// fine CASO 'unitaMisura' = 'T'
			else if (tipoUnitaMisura.equals("P")) {
				SolmrLogger.debug(this, " --- CASO unità di misura = 'P'");
				carburanteLimite = superficie.multiply(litriBase);

				if (carburanteLimite != null && numeroEsecuzioni != null) {
					if (flagEscludiEsecuzioni == null || flagEscludiEsecuzioni.equalsIgnoreCase("") || flagEscludiEsecuzioni.equalsIgnoreCase("N")) {
						carburanteLimite = carburanteLimite.multiply(new BigDecimal(numeroEsecuzioni.longValue()));
					} else {
						SolmrLogger.debug(this, "tipoUnitaMisura=P && flagEscludiEsecuzioni==S");
					}
				}
			}// fine CASO 'unitaMisura' = 'P'

			if (carburanteLimite != null) {
				carburanteLimite = arrotondamento(carburanteLimite.doubleValue());
				maxCarburante = carburanteLimite.toString();
			}

			SolmrLogger.debug(this, "--- litriAcclitivaLimite prima di arrotondare =" + litriAcclitivaLimite);
			if (litriAcclitivaLimite != null) {
				Double litriAcclitivaLimiteArrotondati = arrotondamentoAcclivita(litriAcclitivaLimite.doubleValue());
				maxLitriAcclivita = litriAcclitivaLimiteArrotondati.toString();
			}
		}
		//}		

		SolmrLogger.debug(this, "--- maxCarburante =" + maxCarburante);
		htmpl.set("blkRecord.maxCarburante", maxCarburante);

		SolmrLogger.debug(this, "--- maxLitriAcclivita =" + maxLitriAcclivita);
		htmpl.set("blkRecord.maxLitriAcclivita", maxLitriAcclivita);

		SolmrLogger.debug(this, "   END calcoloMaxCarburanteLitriAcclivita");
	}

	private double arrotondamentoAcclivita(double num) {
		SolmrLogger.debug(this, "-- num =" + num);
		double litriAcclivitaArrot = new BigDecimal(num).setScale(2, BigDecimal.ROUND_UP).doubleValue();
		SolmrLogger.debug(this, "-- litriAcclivitaArrot =" + litriAcclivitaArrot);
		return litriAcclivitaArrot;
	}

	private BigDecimal arrotondamento(double num) {
		num = num + 0.9999;
		num = Math.abs(Math.floor(num));
		return new BigDecimal(num);
	}

	private void addStringForDescMacchina(StringBuffer sb, String value) {
		if (Validator.isNotEmpty(value)) {
			if (sb.length() > 0) {
				sb.append(" - ");
			}
			sb.append(value);
		}
	}%>
