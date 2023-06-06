<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%

  //UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/dettaglioLavCpPOP.htm");
%><%@include file = "/include/menu.inc" %><%

    SolmrLogger.debug(this, "   BEGIN dettaglioLavCpPOPView");
 
    SolmrLogger.debug(this, "--- recupero l'oggetto da visualizzare");
	LavContoProprioVO lavCp = (LavContoProprioVO) request.getAttribute("dettaglioLavorazCp");

    htmpl.set("annoCampagna", lavCp.getAnnoCampagna());   
    htmpl.set("assegnazCarburante", lavCp.getDescrAssegnazCarburante());
    htmpl.set("usoDelSuolo", lavCp.getDescrUsoDelSuolo());
    htmpl.set("lavorazione", lavCp.getDescrLavorazione());   
    
	if(lavCp.getMacchinaVO() != null){ 
	  SolmrLogger.debug(this, "-- sono presenti i dati relativi alla macchina");
	  MacchinaVO macchinaVO = lavCp.getMacchinaVO();
	  String codBreve="";
	  if (macchinaVO.getDatiMacchinaVO()!=null){
	   codBreve=macchinaVO.getDatiMacchinaVO().getCodBreveGenereMacchina();
	  }
	  else{
        if (macchinaVO.getMatriceVO()!=null){
          codBreve=macchinaVO.getMatriceVO().getCodBreveGenereMacchina();
        }
	  }
	  String tipoMacchina=null;
	  if (macchinaVO.getMatriceVO()!=null && macchinaVO.getMatriceVO().getTipoMacchina()!=null){
	     tipoMacchina=" - " + macchinaVO.getMatriceVO().getTipoMacchina();
	  }
	  else{
	    if (macchinaVO.getDatiMacchinaVO()!=null && macchinaVO.getDatiMacchinaVO().getTipoMacchina()!=null){
	      tipoMacchina=" - " +macchinaVO.getDatiMacchinaVO().getTipoMacchina();
	    }
	    else{
	      tipoMacchina="";
	    }
	  }
	  String descCategoria=macchinaVO.getTipoCategoriaVO()!=null?" - " + macchinaVO.getTipoCategoriaVO().getDescrizione():"";
 	  String descMacchina = codBreve+descCategoria + tipoMacchina +(macchinaVO.getTargaCorrente()!=null && macchinaVO.getTargaCorrente().getNumeroTarga() != null ? " - "+macchinaVO.getTargaCorrente().getNumeroTarga() : "");
 		
   	  htmpl.set("macchina",descMacchina);
 	}
 	else htmpl.set("macchina","");
 	
 	htmpl.set("motivoLavorazione", lavCp.getDescrMotivoLavoraz());
 	htmpl.set("supOre",StringUtils.formatDouble4(lavCp.getSuperficie())); 	 	
    htmpl.set("unitaDiMisura", lavCp.getUnitaMisura());
    htmpl.set("numEsecuzioni", lavCp.getNumEsecuzioni());           
    htmpl.set("litriCarburante", StringUtils.formatDouble2(lavCp.getLitriLavorazione()));                
    htmpl.set("litriBase", StringUtils.formatDouble2(lavCp.getLitriBase()));
    htmpl.set("litriMedioImpasto", StringUtils.formatDouble2(lavCp.getLitriMedioImpasto()));
    htmpl.set("litriAcclivita", StringUtils.formatDouble2(lavCp.getLitriAcclivita()));      	
    htmpl.set("note",""+StringUtils.checkNull(lavCp.getNote()));
    
    htmpl.set("dataInizioValidita",lavCp.getDataInizioValidita());
	htmpl.set("dataFineValidita", StringUtils.checkNull(lavCp.getDataFineValidita()));
	htmpl.set("dataCessazione", StringUtils.checkNull(lavCp.getDataCessazione()));
	      
    htmpl.set("dataAggiornamentoStr",UmaDateUtils.formatFullDate24(lavCp.getDataAggiornamento()));
        

    if(lavCp.getUtenteIrideVO() != null){
  	  htmpl.set("denominazioneAggiornamento",lavCp.getUtenteIrideVO().getDenominazione());
  	  htmpl.set("descrizioneEnteAppartenenza",lavCp.getUtenteIrideVO().getDescrizioneEnteAppartenenza());
  	}
  	else{
  	  htmpl.set("denominazioneAggiornamento","");
  	  htmpl.set("descrizioneEnteAppartenenza","");
  	}
    
    
    SolmrLogger.debug(this, "   END dettaglioLavCpPOPView");
    out.print(htmpl.text());

%>
