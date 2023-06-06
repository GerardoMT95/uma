<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza"%>
<%@ page import="it.csi.solmr.etc.*" %>



<%

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/dettaglioLavConsorziPOP.htm");
%>
  <%@include file = "/include/menu.inc" %>
<%
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
  UmaFacadeClient umaFacadeClient=new UmaFacadeClient();
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  DittaUMAVO dittaUmaVO =umaFacadeClient.findDittaVOByIdDitta(idDittaUma);
  boolean isConsorzio = umaFacadeClient.isDittaUmaConsorzio(dittaUmaVO.getExtIdAzienda());
  
  
	UtenteIrideVO utenteIrideVO = (UtenteIrideVO) request.getAttribute("utenteIrideVO");
	LavConsorziVO lavConsorzi = (LavConsorziVO) request.getAttribute("lavConsorzi");
	MacchinaVO macchinaVO = (MacchinaVO) request.getAttribute("macchinaVO");
	SolmrLogger.debug(this,"macchinaVO: "+macchinaVO);

  htmpl.set("usoDelSuolo",StringUtils.checkNull(lavConsorzi.getDescCategoriaUtilizzo()));
  htmpl.set("lavorazione",StringUtils.checkNull(lavConsorzi.getDescTipoLavorazione()));
  if(Validator.isNotEmpty(lavConsorzi.getIdAziendaSocio())){        
    String azienda = "";
    if(lavConsorzi.getCuaaAziendaSocio() != null && !lavConsorzi.getCuaaAziendaSocio().trim().equals(""))
      azienda = lavConsorzi.getCuaaAziendaSocio();
    if(lavConsorzi.getPiAziendaSocio() != null && !lavConsorzi.getPiAziendaSocio().trim().equals(""))
	  azienda += " - "+lavConsorzi.getPiAziendaSocio();
	if(lavConsorzi.getDescAziendaSocio() != null && !lavConsorzi.getDescAziendaSocio().trim().equals(""))
	  azienda +=  " - "+lavConsorzi.getDescAziendaSocio();
	        
    htmpl.set("azienda", azienda);
  }
  
  htmpl.set("esecuzioni",StringUtils.checkNull(lavConsorzi.getEsecuzioniStr()));
    
	if(isConsorzio)
	{
		SolmrLogger.debug(this,"isConsorzio true");
		htmpl.newBlock("blkConsorzio");
		if(macchinaVO!=null)
		{
			//SolmrLogger.debug(this,"TARGA:: "+macchinaVO.getTargaCorrente().getNumeroTarga());
			String descMacchina = "";
			if(Validator.isNotEmpty(macchinaVO.getTipoCategoriaVO())
			  && Validator.isNotEmpty(macchinaVO.getTipoCategoriaVO().getDescrizione()))
			{
	 		  descMacchina += macchinaVO.getTipoCategoriaVO().getDescrizione();
	 		}
	 		if(Validator.isNotEmpty(macchinaVO.getMatriceVO()))
	 		{
	 		  String tipoMacchina = "";
	 		  if(Validator.isNotEmpty(macchinaVO.getMatriceVO().getTipoMacchina()))
	 		  {
	 		    tipoMacchina = macchinaVO.getMatriceVO().getTipoMacchina();
	 		  }
	 		  else
	 		  {
	 		    if(Validator.isNotEmpty(macchinaVO.getDatiMacchinaVO())
	 		      && Validator.isNotEmpty(macchinaVO.getDatiMacchinaVO().getMarca()))
	 		    {
	 		      tipoMacchina = macchinaVO.getDatiMacchinaVO().getMarca();
	 		    }
	 		  }
				descMacchina +=" - "+tipoMacchina;
		  }
		  if(Validator.isNotEmpty(macchinaVO.getTargaCorrente())
		   && Validator.isNotEmpty(macchinaVO.getTargaCorrente().getNumeroTarga()))
		  {
		    descMacchina +=" - "+macchinaVO.getTargaCorrente().getNumeroTarga();
		  }
	 		
	 		htmpl.set("blkConsorzio.macchina",descMacchina);
	 	}
	 	else htmpl.set("blkConsorzio.macchina","");
 	}
 	
  htmpl.set("unitaDiMisura",StringUtils.checkNull(lavConsorzi.getDescUnitaMisura()));
  htmpl.set("supOre",""+StringUtils.checkNull(lavConsorzi.getSupOre()));

  htmpl.set("gasolio",""+StringUtils.checkNull(lavConsorzi.getGasolio()));
  htmpl.set("benzina",""+StringUtils.checkNull(lavConsorzi.getBenzina()));
  htmpl.set("note",""+StringUtils.checkNull(lavConsorzi.getNote()));
  htmpl.set("dataInizioValidita",UmaDateUtils.formatFullDate24(lavConsorzi.getDataInizioValidita()));
  htmpl.set("dataCessazione",UmaDateUtils.formatFullDate24(lavConsorzi.getDataCessazione()));
  htmpl.set("dataAggiornamentoStr",UmaDateUtils.formatFullDate24(lavConsorzi.getDataUltimoAggiornamento()));
  
  SolmrLogger.debug(this,"lavConsorzi.getExtIdUtenteAggiornamento(): "+lavConsorzi.getExtIdUtenteAggiornamento());

	htmpl.set("denominazione",utenteIrideVO.getDenominazione());
	htmpl.set("descrizioneEnteAppartenenza",utenteIrideVO.getDescrizioneEnteAppartenenza());
    
  out.print(htmpl.text());

%>
