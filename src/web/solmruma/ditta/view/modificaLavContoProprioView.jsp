<%@page import="java.math.BigDecimal"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@page import="it.csi.solmr.dto.uma.*"%>
<%@page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@page import="it.csi.solmr.dto.uma.LavContoProprioVO"%>
<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%! public static final Long UNO=new Long(1); %>
<%

  String layout = "/ditta/layout/modificaLavContoProprio.htm";
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layout);
  SolmrLogger.debug(this, "Found layout: "+layout);

%>
  <%@include file = "/include/menu.inc" %>
<%
  SolmrLogger.debug(this, "   BEGIN modificaLavContoProprioView");
  
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  
  // Recupero i dati da visualizzare
  SolmrLogger.debug(this, " --- Recupero i dati da visualizzare");
  Vector<LavContoProprioVO> elencoLavContoProprioMod = (Vector<LavContoProprioVO>)session.getAttribute("lavContoProprioMod");  
  HashMap<String,Vector<MacchinaVO>> hashMapMacchine = (HashMap<String,Vector<MacchinaVO>>)session.getAttribute("hashMapMacchine");
  HashMap<String,CategoriaColturaLavVO> hasMapCategColt = (HashMap<String,CategoriaColturaLavVO>)session.getAttribute("hasMapCategColt");
  HashMap<String,Vector<TipoLavorazioneVO>> hashMapTipoLavoraz = (HashMap<String,Vector<TipoLavorazioneVO>>)session.getAttribute("hashMapTipoLavoraz");
  HashMap<String,BigDecimal> hashMapMaxSuperficie = (HashMap<String,BigDecimal>)session.getAttribute("hashMapMaxSuperficie");
  HashMap<String,BigDecimal> hashMapSuperficieMontagna = (HashMap<String,BigDecimal>)session.getAttribute("hashMapSuperficieMontagna");

  for(int i = 0; i < elencoLavContoProprioMod.size();i++){  	
  	LavContoProprioVO lavContoProprio = (LavContoProprioVO)elencoLavContoProprioMod.get(i);
  	htmpl.newBlock("blkLavorazione");
  	
  	SolmrLogger.debug(this, "------------ *** idLavorazioneContoProprio ="+lavContoProprio.getIdLavorazioneContoProprio());
  	htmpl.set("blkLavorazione.idLavContoProprio", lavContoProprio.getIdLavorazioneContoProprio());
  	htmpl.set("blkLavorazione.usoDelSuolo", lavContoProprio.getDescrUsoDelSuolo());
  	htmpl.set("blkLavorazione.lavorazione", lavContoProprio.getDescrLavorazione());
  	htmpl.set("blkLavorazione.motivoLavorazione", lavContoProprio.getTipoMotivoLavVO().getDescrizione());    	
  	htmpl.set("blkLavorazione.supOreStr", lavContoProprio.getSupOreStr());
  	htmpl.set("blkLavorazione.unitaDiMisura", lavContoProprio.getCodiceUnitaMisura());
  	htmpl.set("blkLavorazione.esecuzioniStr", lavContoProprio.getNumEsecuzioni());  	
  	htmpl.set("blkLavorazione.litriCarburante", StringUtils.formatDouble2(lavContoProprio.getLitriLavorazione()));
  	htmpl.set("blkLavorazione.litriBaseCalcolati", StringUtils.formatDouble2(lavContoProprio.getLitriBase()));
  	htmpl.set("blkLavorazione.litriMedioImpastoCalcolati", StringUtils.formatDouble2(lavContoProprio.getLitriMedioImpasto()));
  	htmpl.set("blkLavorazione.litriAcclivita", StringUtils.formatDouble2(lavContoProprio.getLitriAcclivita()));
  	  	
  	// --- Popolamento e selezione Combo macchina
  	String idMacchina = lavContoProprio.getIdMacchina();
  	Vector<MacchinaVO> listaMacchine = (Vector)hashMapMacchine.get(lavContoProprio.getIdLavorazioneContoProprio());
  	if(listaMacchine != null && listaMacchine.size() >0){  	
  	  htmpl.newBlock("blkLavorazione.blkMacchina");
	  	String cavalli = null;
	  	for(int y = 0;y < listaMacchine.size();y++){
		  MacchinaVO macchinaVO = (MacchinaVO)listaMacchine.get(y);
		  htmpl.newBlock("blkLavorazione.blkMacchina.blkComboMacchina");
		  htmpl.set("blkLavorazione.blkMacchina.blkComboMacchina.id",macchinaVO.getIdMacchina()+"|"+macchinaVO.getMatriceVO().getPotenzaKW()+"|"+macchinaVO.getMatriceVO().getIdAlimentazione());
		  StringBuffer descMacchina = new StringBuffer();
		  addStringForDescMacchina(descMacchina,macchinaVO.getMatriceVO().getCodBreveGenereMacchina());
		  addStringForDescMacchina(descMacchina,macchinaVO.getTipoCategoriaVO().getDescrizione());
		  String tipoMacchina=macchinaVO.getMatriceVO().getTipoMacchina();
		  if (Validator.isEmpty(tipoMacchina)){
		    addStringForDescMacchina(descMacchina, macchinaVO.getDatiMacchinaVO().getMarca());
		  }
		  else{
		    addStringForDescMacchina(descMacchina,tipoMacchina);
		  }
		  addStringForDescMacchina(descMacchina,macchinaVO.getTargaCorrente().getNumeroTarga());
		  htmpl.set("blkLavorazione.blkMacchina.blkComboMacchina.desc",descMacchina.toString());
		  if(idMacchina != null && idMacchina.equals(macchinaVO.getIdMacchina())){
		     cavalli = macchinaVO.getMatriceVO().getPotenzaKW();
			 htmpl.set("blkLavorazione.blkMacchina.blkComboMacchina.selected","selected");
			 htmpl.set("blkLavorazione.cavalli",cavalli);	// hidden			
		  }
		}// chiusura ciclo combo macchina
	}// ci sono macchine
	  	
  	htmpl.set("blkLavorazione.noteStr", lavContoProprio.getNote());
  	
  	setErrors(htmpl,errors,i,request);
  	
  	// -- Recupero i dati per i campi hidden 
  	
  	String coefficiente = (String)session.getAttribute("coefficienteCarburante");
  	SolmrLogger.debug(this, " --- coefficiente ="+coefficiente);
  	if(coefficiente != null)
  	  htmpl.set("blkLavorazione.coefficiente",""+coefficiente);  	   
  	 
  	CategoriaColturaLavVO categColtVO = hasMapCategColt.get(lavContoProprio.getIdLavorazioneContoProprio());
  	if(categColtVO != null){  	  
  	  Long maxEsecuzione = categColtVO.getMaxEsecuzione();
  	  SolmrLogger.debug(this, " --- max_esecuzione ="+maxEsecuzione);
  	  if(maxEsecuzione != null)
  	    htmpl.set("blkLavorazione.maxEsecuzione", maxEsecuzione.toString());
  	      	    
  	  String tipoUnitaMisura = categColtVO.getTipoUnitaMisura();
  	  SolmrLogger.debug(this, " -- tipoUnitaMisura ="+tipoUnitaMisura);
  	  htmpl.set("blkLavorazione.tipoUnitaMisura", tipoUnitaMisura);  	    	     	   
  	}
  	
  	  
  	Vector<TipoLavorazioneVO> datiTipoLavoraz = hashMapTipoLavoraz.get(lavContoProprio.getIdLavorazioneContoProprio());
  	if(datiTipoLavoraz != null && datiTipoLavoraz.size()>0){
  	  // prendo l'unico elemento che devo avere nel vettore
  	  TipoLavorazioneVO tipoLavorazVO = datiTipoLavoraz.get(0);
  	  if(tipoLavorazVO != null){  	    
  	      	    // Campi per il calcolo carburante  	  
  	    if(tipoLavorazVO.getLitriBase() != null)
  	      htmpl.set("blkLavorazione.litriBase", ""+tipoLavorazVO.getLitriBase());
  	    if(tipoLavorazVO.getLitriMedioImpasto() != null)
  		  htmpl.set("blkLavorazione.litriMedioImpasto", ""+tipoLavorazVO.getLitriMedioImpasto());      
   	    if(tipoLavorazVO.getLitriTerreniDeclivi() != null)
  		  htmpl.set("blkLavorazione.litriTerDeclivi", ""+tipoLavorazVO.getLitriTerreniDeclivi()); 	      
 
	     htmpl.set("blkLavorazione.flagAsservimento", tipoLavorazVO.getFlagAsservimento());                          
         htmpl.set("blkLavorazione.flagEscludiEsecuzioni", tipoLavorazVO.getFlagEscludiEsecuzioni());
  	    
  	  }
  	}  	  	
  	// Max superficie permessa  	
    BigDecimal maxSuperficie = hashMapMaxSuperficie.get(lavContoProprio.getIdLavorazioneContoProprio());
  	htmpl.set("blkLavorazione.supTotaleCalcolata", ""+maxSuperficie);
  	
  	// Eventuale superficie di montagna per il calcolo litri acclività
  	BigDecimal superficieMontagna = hashMapSuperficieMontagna.get(lavContoProprio.getIdLavorazioneContoProprio());
    htmpl.set("blkLavorazione.supMontagnaCalcolata", ""+superficieMontagna);  	
    
  } // CHIUSURA CICLO LAVORAZIONI da visualizzare
  

  HtmplUtil.setValues(htmpl, request);

  htmpl.set("pageFrom",request.getParameter("pageFrom"));
  
  
  if (errors != null && errors.size() > 0)    
    htmpl.set("eseguiCalcolaCarb", "false");
  
  
  if(errors != null && !errors.empty())
    HtmplUtil.setErrors(htmpl, errors, request);

  SolmrLogger.debug(this, "   END modificaLavContoProprioView");
  out.print(htmpl.text());

%>

<%!
	private void setErrors(Htmpl htmpl,ValidationErrors errors,int index,HttpServletRequest request){
	  SolmrLogger.debug(this, "   BEGIN setErrors");
	  
		//settaggio degli eventuali errori dentro il blocco
		if(errors != null){
			Iterator iterErr = errors.get("esecuzioniStr"+index);
	  		if(iterErr != null){
	  			ValidationError err = (ValidationError)iterErr.next();
	  			HtmplUtil.setErrorsInBlocco("blkLavorazione.err_esecuzioniStr",htmpl,request,err);
	  		}
	  		
	   		iterErr = errors.get("idMacchina"+index);
	  		if(iterErr != null){
	  			ValidationError err = (ValidationError)iterErr.next();
	  			HtmplUtil.setErrorsInBlocco("blkLavorazione.blkMacchina.err_idMacchina",htmpl,request,err);
	  		}
	  		
	   		iterErr = errors.get("supOreStr"+index);
	  		if(iterErr != null){
	  			ValidationError err = (ValidationError)iterErr.next();
	  			HtmplUtil.setErrorsInBlocco("blkLavorazione.err_supOreStr",htmpl,request,err);
	  		}
	  		
	   		iterErr = errors.get("noteStr"+index);
	  		if(iterErr != null){
	  			ValidationError err = (ValidationError)iterErr.next();
	  			HtmplUtil.setErrorsInBlocco("blkLavorazione.err_noteStr",htmpl,request,err);
	  		}  		  		
 		}
 		SolmrLogger.debug(this, "   END setErrors");
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
