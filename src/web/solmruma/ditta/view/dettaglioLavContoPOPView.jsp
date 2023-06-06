<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%

  //UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/dettaglioLavContoPOP.htm");
%><%@include file = "/include/menu.inc" %><%
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

	//RuoloUtenza[] ruoloUtenzaAgg = (RuoloUtenza[])request.getAttribute("ruoloUtenzaAgg");
	UtenteIrideVO utenteIrideVO = (UtenteIrideVO) request.getAttribute("utenteIrideVO");
	LavContoTerziVO lavContoTerzi = (LavContoTerziVO) request.getAttribute("lavContoTerzi");
	MacchinaVO macchinaVO = (MacchinaVO) request.getAttribute("macchinaVO");

    htmpl.set("cuaa",StringUtils.checkNull(lavContoTerzi.getCuaa()));
    htmpl.set("partitaIva",lavContoTerzi.getPartitaIva());
    htmpl.set("denominazione",StringUtils.checkNull(lavContoTerzi.getDenominazione()));
    if(lavContoTerzi.getExtIdAzienda()!=null){
    	 htmpl.set("sedeLegale",StringUtils.checkNull(lavContoTerzi.getSedeLegaleAnag()));
    	 SolmrLogger.debug(this,"lavContoTerzi.getSedeLegaleAnag() vale: "+lavContoTerzi.getSedeLegaleAnag());
    }else{
		SolmrLogger.debug(this,"lavContoTerzi.getDescProvincia() vale: "+lavContoTerzi.getDescProvincia());
   	  	String desc=lavContoTerzi.getDescComune();
   		if(!StringUtils.isStringEmpty(lavContoTerzi.getDescProvincia())){
   			desc=desc+" ("+lavContoTerzi.getDescProvincia()+")";
   		}	
   	 	htmpl.set("sedeLegale",StringUtils.checkNull(desc));
    }
    htmpl.set("indirizzoSedeLeg",StringUtils.checkNull(lavContoTerzi.getIndirizzoSedeLegale()));
    htmpl.set("usoDelSuolo",StringUtils.checkNull(lavContoTerzi.getDescUsoDelSuolo()));
    htmpl.set("lavorazione",StringUtils.checkNull(lavContoTerzi.getDescTipoLavorazione()));
    htmpl.set("esecuzioni",StringUtils.checkNull(lavContoTerzi.getEsecuzioniStr()));
    htmpl.set("litriAcclivita", StringUtils.checkNull(lavContoTerzi.getLitriAcclivitaStr())); 
    
	if(macchinaVO!=null){ 
	  String codBreve="";
	  if (macchinaVO.getDatiMacchinaVO()!=null)
	  {
	   codBreve=macchinaVO.getDatiMacchinaVO().getCodBreveGenereMacchina();
	  }
	  else
	  {
      if (macchinaVO.getMatriceVO()!=null)
      {
       codBreve=macchinaVO.getMatriceVO().getCodBreveGenereMacchina();
      }
	  }
	  String tipoMacchina=null;
	  if (macchinaVO.getMatriceVO()!=null && macchinaVO.getMatriceVO().getTipoMacchina()!=null)
	  {
	     tipoMacchina=" - " + macchinaVO.getMatriceVO().getTipoMacchina();
	  }
	  else
	  {
	   if (macchinaVO.getDatiMacchinaVO()!=null && macchinaVO.getDatiMacchinaVO().getTipoMacchina()!=null)
	   {
	     tipoMacchina=" - " +macchinaVO.getDatiMacchinaVO().getTipoMacchina();
	   }
	   else
	   {
	     tipoMacchina="";
	   }
	  }
	  String descCategoria=macchinaVO.getTipoCategoriaVO()!=null?" - " + macchinaVO.getTipoCategoriaVO().getDescrizione():"";
 		String descMacchina = codBreve+descCategoria+ 
			tipoMacchina
			+(macchinaVO.getTargaCorrente()!=null && macchinaVO.getTargaCorrente().getNumeroTarga() != null ? " - "+macchinaVO.getTargaCorrente().getNumeroTarga() : "");
 		
 		htmpl.set("macchina",descMacchina);
 	}
 	else htmpl.set("macchina","");
 	
    htmpl.set("unitaDiMisura",StringUtils.checkNull(lavContoTerzi.getDescUnitaMisura()));
    htmpl.set("supOreFattura",""+StringUtils.checkNull(lavContoTerzi.getSupOreFattura()));
    if (SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(lavContoTerzi.getTipoUnitaMisura()))
    {
      htmpl.newBlock("blkSup");
      htmpl.set("blkSup.supOre",""+StringUtils.checkNull(lavContoTerzi.getSupOreCalcolataStr()));
    }
    else 
	    if (SolmrConstants.TIPO_UNITA_MISURA_T.equalsIgnoreCase(lavContoTerzi.getTipoUnitaMisura()))
	      htmpl.newBlock("blkOre");
	    else 
		    if (SolmrConstants.TIPO_UNITA_MISURA_P.equalsIgnoreCase(lavContoTerzi.getTipoUnitaMisura()))
		      htmpl.newBlock("blkPeso");  
		    else 
		    {
		      htmpl.newBlock("blkLabelPot");  
		      htmpl.set("blkLabelPot.supOre",""+StringUtils.checkNull(lavContoTerzi.getSupOreCalcolataStr()));
		    }
	    
    
    
    htmpl.set("gasolio",""+StringUtils.checkNull(lavContoTerzi.getGasolio()));
    htmpl.set("consumoCalcolato",""+StringUtils.checkNull(lavContoTerzi.getConsumoCalcolatoStr()));
    htmpl.set("consumoDichiarato",""+StringUtils.checkNull(lavContoTerzi.getConsumoDichiaratoStr()));
    htmpl.set("eccedenza",""+StringUtils.checkNull(lavContoTerzi.getEccedenzaStr()));
    htmpl.set("numerofatture",""+StringUtils.checkNull(lavContoTerzi.getNumeroFatture()));
    htmpl.set("note",""+StringUtils.checkNull(lavContoTerzi.getNote()));
    htmpl.set("dataInizioValidita",UmaDateUtils.formatFullDate24(lavContoTerzi.getDataInizioValidita()));
    htmpl.set("dataCessazione",UmaDateUtils.formatFullDate24(lavContoTerzi.getDataCessazione()));
    htmpl.set("dataAggiornamentoStr",UmaDateUtils.formatFullDate24(lavContoTerzi.getDataUltimoAggiornamento()));
    
    htmpl.set("lavScavalco", lavContoTerzi.isScavalco() ? "S" : "N");
    
    SolmrLogger.debug(this,"lavContoTerzi.getExtIdUtenteAggiornamento(): "+lavContoTerzi.getExtIdUtenteAggiornamento());

  	htmpl.set("denominazioneAggiornamento",utenteIrideVO.getDenominazione());
  	htmpl.set("descrizioneEnteAppartenenza",utenteIrideVO.getDescrizioneEnteAppartenenza());
    
  out.print(htmpl.text());

%>
