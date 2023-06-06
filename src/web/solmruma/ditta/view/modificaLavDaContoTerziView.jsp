<%@page import="it.csi.solmr.dto.uma.ZonaAltimetricaVO"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@page import="it.csi.solmr.client.uma.UmaFacadeClient"%>
<%@page import="it.csi.solmr.dto.uma.LavContoTerziVO"%>
<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*"%>
<%@page import="it.csi.solmr.dto.uma.CategoriaColturaLavVO"%>

<%

  String layout = "/ditta/layout/modificaLavDaContoTerzi.htm";
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layout);
  SolmrLogger.info(this, "Found layout: "+layout);

%><%@include file = "/include/menu.inc" %><%
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  Vector vLavContoTerzi = (Vector)request.getAttribute("vLavDaContoTerzi");
  AnagAziendaVO[] listaAnagAziendaVO = (AnagAziendaVO[])request.getAttribute("listaAnagAziendaVO");
 
  // HashMap<Long,ZonaAltimetricaVO> hashZonaAlt = (HashMap<Long,ZonaAltimetricaVO>)request.getAttribute("hashZonaAlt");
  
  // Codice zona altimetrica dell'azienda che sta inserendo i dati
  String codiceZonaAlt = (String)request.getAttribute("codiceZonaAlt");
  SolmrLogger.debug("modificaLavDaContoTerziView", " --- codiceZonaAlt ="+codiceZonaAlt);
  
  String coefficiente = (String)request.getAttribute("coefficiente"); 
  htmpl.set("coefficiente",coefficiente);
  LavContoTerziVO lavContoTerzi = null;
  //UtenteIrideVO utenteIrideVO = null;
  
  BigDecimal totaleConsCalc = BigDecimal.ZERO, totaleConsDich = BigDecimal.ZERO;
  
  for(int i = 0; i < vLavContoTerzi.size();i++){
  	SolmrLogger.debug(this,"numero iterazione: "+i);
  	lavContoTerzi = (LavContoTerziVO)vLavContoTerzi.get(i);
  	htmpl.newBlock("blkRecord");
  	htmpl.set("blkRecord.idLavContoTerzi",lavContoTerzi.getIdLavorazioneCT().toString());
  	String cuaa = lavContoTerzi.getCuaa();
	String pIva = lavContoTerzi.getPartitaIva();
	String denominazione = lavContoTerzi.getDenominazione();
	boolean maggiorazione = false;
	String tipoUnitaMisura = lavContoTerzi.getTipoUnitaMisura();
	//String codiceZonaAlt = null;
  	if(listaAnagAziendaVO != null){
	  	for(int x = 0;x < listaAnagAziendaVO.length;x++){
			AnagAziendaVO anagAziendaVO = listaAnagAziendaVO[x];
			if(lavContoTerzi.getExtIdAzienda() != null && lavContoTerzi.getExtIdAzienda().equals(anagAziendaVO.getIdAzienda())){
				cuaa = anagAziendaVO.getCUAA();
				pIva = anagAziendaVO.getPartitaIVA();
				denominazione = anagAziendaVO.getDenominazione();
				break;
			}
	  	}
  	}
  	
  	
  	htmpl.set("blkRecord.cuaa",cuaa);
  	htmpl.set("blkRecord.partitaIva",pIva);
  	htmpl.set("blkRecord.denominazione",denominazione);
  	htmpl.set("blkRecord.usoDelSuolo",lavContoTerzi.getDescUsoDelSuolo());
  	htmpl.set("blkRecord.lavorazione",lavContoTerzi.getDescTipoLavorazione());
  	String cavalli = null;
  	
  	htmpl.set("blkRecord.esecuzioniStr",lavContoTerzi.getEsecuzioniStr());
  	htmpl.set("blkRecord.unitaDiMisura",lavContoTerzi.getDescUnitaMisura());
  	htmpl.set("blkRecord.supOreStr",lavContoTerzi.getSupOreStr());
  	
  	htmpl.set("blkRecord.supOreFatturaStr",lavContoTerzi.getSupOreFatturaStr());
  	htmpl.set("blkRecord.gasolioStr",lavContoTerzi.getConsumoCalcolatoStr());
  	htmpl.set("blkRecord.benzinaStr",lavContoTerzi.getConsumoDichiaratoStr());
  	htmpl.set("blkRecord.numeroFatturaStr",StringUtils.checkNull(lavContoTerzi.getNumeroFatture()));
  	htmpl.set("blkRecord.noteStr",lavContoTerzi.getNote());
  	//htmpl.set("blkRecord.dataInizioValidita",UmaDateUtils.formatFullDate24(lavContoTerzi.getDataInizioValidita()));

  	//htmpl.set("blkRecord.dataAggiornamentoStr",UmaDateUtils.formatDate(lavContoTerzi.getDataUltimoAggiornamento()));
  	
  	//utenteIrideVO = umaFacadeClient.getUtenteIride(lavContoTerzi.getExtIdUtenteAggiornamento());
  	//htmpl.set("blkRecord.denomUtenteAgg",utenteIrideVO.getDenominazione());
  	//htmpl.set("blkRecord.enteUtenteAgg",utenteIrideVO.getDescrizioneEnteAppartenenza());
  	
  	setErrors(htmpl,errors,i,request);
  	
  	htmpl.set("blkRecord.litriBase",StringUtils.checkNull(lavContoTerzi.getLitriBase()));
  	htmpl.set("blkRecord.litriMedioImpasto",StringUtils.checkNull(lavContoTerzi.getLitriMedioImpasto()));
  	htmpl.set("blkRecord.litriTerDeclivi",StringUtils.checkNull(lavContoTerzi.getLitriTerDeclivi()));
  	htmpl.set("blkRecord.supOreCalcolata",StringUtils.checkNull(lavContoTerzi.getSupOreCalcolata()));
   	
   	if(codiceZonaAlt != null && codiceZonaAlt.equals(SolmrConstants.CODICE_MONTAGNA)){
  		maggiorazione = true;
  	}
  	htmpl.set("blkRecord.maggiorazione",""+maggiorazione); 	
  	
  	htmpl.set("blkRecord.tipoUnitaMisura",tipoUnitaMisura);
  	
  	String maxCarburante = lavContoTerzi.getMaxCarburante();

  	int annoInizioValLavoraz = DateUtils.extractYearFromDate(lavContoTerzi.getDataInizioValidita());
  	SolmrLogger.debug(this, " --- dataInizioValLavoraz ="+annoInizioValLavoraz);   	
  	CategoriaColturaLavVO categColt = umaFacadeClient.getCategoriaColturaLav(lavContoTerzi.getIdLavorazoni().toString(), lavContoTerzi.getIdCategoriaUtilizziUma().toString(), SolmrConstants.ID_TIPO_COLTURA_LAVORAZIONE_CONTO_TERZI_CONSORZI, new Integer(annoInizioValLavoraz).toString());
  	
  	cavalli = categColt.getCoefficiente().toString();
  	SolmrLogger.debug(this, "cavalli!!!!!!!!!!!! "+cavalli);
  	if(maxCarburante == null){
  		maxCarburante = calcoloMaxCarburante(tipoUnitaMisura,lavContoTerzi,maggiorazione,cavalli,coefficiente);
  	}
  	htmpl.set("blkRecord.maxCarburante",maxCarburante);
  	htmpl.set("blkRecord.cavalli",StringUtils.checkNull(cavalli));
  	
  	if (lavContoTerzi.getConsumoCalcolato()!=null)
      totaleConsCalc=totaleConsCalc.add(lavContoTerzi.getConsumoCalcolato());
          
    if (lavContoTerzi.getConsumoDichiarato()!=null)
      totaleConsDich=totaleConsDich.add(lavContoTerzi.getConsumoDichiarato());  
  	
  }
  
  htmpl.set("totaleGasolio",StringUtils.checkNull(totaleConsCalc));
  htmpl.set("totaleBenzina",StringUtils.checkNull(totaleConsDich));
  
  HtmplUtil.setValues(htmpl, request);

  htmpl.set("pageFrom",request.getParameter("pageFrom"));
  
  if(errors != null && !errors.empty())
	  HtmplUtil.setErrors(htmpl, errors, request);

  out.print(htmpl.text());

%>

<%!
	private void setErrors(Htmpl htmpl,ValidationErrors errors,int index,HttpServletRequest request)
	{
		//settaggio degli eventuali errori dentro il blocco
		if(errors != null){
			Iterator iterErr = errors.get("esecuzioniStr"+index);
	  		if(iterErr != null){
	  			ValidationError err = (ValidationError)iterErr.next();
	  			HtmplUtil.setErrorsInBlocco("blkRecord.err_esecuzioniStr",htmpl,request,err);
	  		}
	  		
	   		iterErr = errors.get("supOreStr"+index);
	  		if(iterErr != null){
	  			ValidationError err = (ValidationError)iterErr.next();
	  			HtmplUtil.setErrorsInBlocco("blkRecord.err_supOreStr",htmpl,request,err);
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
	  		
  		}
	}
	
	private String calcoloMaxCarburante(String tipoUnitaMisura,LavContoTerziVO lavContoTerzi,
			boolean maggiorazione,String cavalli,String coefficiente){
		String maxCarburante = "";
		BigDecimal carburanteLimite = null;
		
		
		BigDecimal litriBase = lavContoTerzi.getLitriBase();
		BigDecimal litriMedioImpasto = lavContoTerzi.getLitriMedioImpasto();
		BigDecimal litriTerDeclivi = lavContoTerzi.getLitriTerDeclivi();
		Long numeroEsecuzioni = lavContoTerzi.getNumeroEsecuzioni();
		BigDecimal superficie = lavContoTerzi.getSupOre();
		
		SolmrLogger.debug(this,"lavContoTerzi.getSupOreCalcolata(): "+lavContoTerzi.getSupOreCalcolata());
		SolmrLogger.debug(this,"tipoUnitaMisura: "+tipoUnitaMisura);
		SolmrLogger.debug(this,"litriBase: "+litriBase);
		SolmrLogger.debug(this,"litriMedioImpasto: "+litriMedioImpasto);
		SolmrLogger.debug(this,"litriTerDeclivi: "+litriTerDeclivi);
		SolmrLogger.debug(this,"numeroEsecuzioni: "+numeroEsecuzioni);
		SolmrLogger.debug(this,"maggiorazione: "+maggiorazione);
		SolmrLogger.debug(this,"cavalli: "+cavalli);
		SolmrLogger.debug(this,"coefficiente: "+coefficiente);
		SolmrLogger.debug(this,"superficie: "+superficie);
		
		if(superficie != null){
			if(tipoUnitaMisura.equals("S")){
				carburanteLimite = litriBase.add(litriMedioImpasto);
				if(maggiorazione == true){
					carburanteLimite = carburanteLimite.add(litriTerDeclivi);
				}
				carburanteLimite = carburanteLimite.multiply(superficie);
			}else if(tipoUnitaMisura.equals("T")){
				carburanteLimite = superficie.multiply(new BigDecimal(cavalli)).multiply(new BigDecimal(coefficiente));
			}
			else if(tipoUnitaMisura.equals("P")){
        carburanteLimite = superficie.multiply(litriBase);
      }
      else if(tipoUnitaMisura.equals("K")){
        carburanteLimite = superficie.multiply(litriBase);
      }
      else if(SolmrConstants.TIPO_UNITA_MISURA_M.equals(tipoUnitaMisura)){
          carburanteLimite = superficie.multiply(litriBase.add(litriMedioImpasto)).multiply(new BigDecimal(SolmrConstants.MAX_METRO_L));
        }
			if(numeroEsecuzioni != null){
				carburanteLimite = carburanteLimite.multiply(new BigDecimal(numeroEsecuzioni.longValue()));
			}
			
			carburanteLimite = arrotondamento(carburanteLimite.doubleValue()); 
			maxCarburante = carburanteLimite.toString();
		}//else maxCarburante = "";
		SolmrLogger.debug(this,"maxCarburante: "+maxCarburante);
		return maxCarburante;
	}
	
	private BigDecimal arrotondamento (double num){
		num = num + 0.9999;
		num = Math.abs(Math.floor(num));
		return new BigDecimal(num);
	}
%>