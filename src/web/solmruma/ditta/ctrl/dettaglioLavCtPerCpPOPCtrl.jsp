<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@page import="it.csi.solmr.dto.uma.LavContoTerziPerContoProprioVO"%>
<%@page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@page import="it.csi.solmr.dto.profile.RuoloUtenza"%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*"%>

<%!
  private static final String VIEW="/ditta/view/dettaglioLavCtPerCpPOPView.jsp";
%>
<%
  String iridePageName = "dettaglioLavCtPerCpPOPCtrl.jsp";
%>
<%@include file = "/include/autorizzazione.inc" %>
<%
  
    SolmrLogger.debug(this, "   BEGIN dettaglioLavCtPerCpPOPCtrl");

  	UmaFacadeClient umaFacadeClient=new UmaFacadeClient();

	Long idLavContoTerzista = new Long(request.getParameter("idLavContoTerzista"));
  	SolmrLogger.debug(this,"--- idLavContoTerzista ="+idLavContoTerzista);
  	
  	SolmrLogger.debug(this,"---- RICERCA DATI per il dettaglio");
  	
  	LavContoTerziPerContoProprioVO dettaglioLavCTperCP = umaFacadeClient.getDettaglioLavContoTerziPerContoProprio(idLavContoTerzista);	

  	SolmrLogger.debug(this,"---- AGGIUNTA DATI ANAGRAFE per il dettaglio");
  	
  	RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  	
  	Long extIdAzienda = new Long(dettaglioLavCTperCP.getExtIdAzienda());

  	AnagAziendaVO anagAziendaVO = umaFacadeClient.serviceGetAziendaById(extIdAzienda, new Date(), SianUtils.getSianVO(ruoloUtenza));
	if (anagAziendaVO != null)
	{
		dettaglioLavCTperCP.setPartitaIva(anagAziendaVO.getPartitaIVA());
		dettaglioLavCTperCP.setCuaa(anagAziendaVO.getCUAA());
		dettaglioLavCTperCP.setDenominazione(anagAziendaVO.getDenominazione());
		String desc = anagAziendaVO.getDescComune();
		if (!StringUtils.isStringEmpty(anagAziendaVO.getSedelegProv())){
			desc = desc +" "+ anagAziendaVO.getSedelegProv();
		}
		dettaglioLavCTperCP.setSedeLegale(desc);
		dettaglioLavCTperCP.setIndirizzoSede(anagAziendaVO.getSedelegIndirizzo());
	}
	else
	{
	  throw new SolmrException(
	      "Errore grave, se il problema persiste contattare l'assistenza tecnica comunicando il  seguente messaggio: Dati azienda non trovati alla data inserimento dichiarazione!");
	}
  	
	dettaglioLavCTperCP.setUltimaModifica(dettaglioLavCTperCP.getUltimaModifica().concat("(" + ruoloUtenza.getDenominazione()  + " - " + ruoloUtenza.getDescrizioneEnte() + ")"));
  	
  	SolmrLogger.debug(this,"---- dettaglio: "+dettaglioLavCTperCP.toString());

	request.setAttribute("dettaglioLavCTperCP", dettaglioLavCTperCP);

%>
<jsp:forward page="<%=VIEW%>" />
