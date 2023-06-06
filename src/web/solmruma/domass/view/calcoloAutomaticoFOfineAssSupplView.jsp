
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
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
  SolmrLogger.debug(this, "   BEGIN calcoloAutomaticoFOfineAssSupplView");
  
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("domass/layout/calcoloAutomaticoAssegnazioneSupplFine.htm");
%><%@include file = "/include/menu.inc" %>
<%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
  htmpl.set("action","../layout/verificaAssegnazioneSupplementare.htm");
  htmpl.set("idDittaUma",idDittaUma==null?null:idDittaUma.toString());
  
  SolmrLogger.debug(this, "-- idDomAss ="+request.getParameter("idDomAss"));
  htmpl.set("idDomAss",request.getParameter("idDomAss"));
  
  SolmrLogger.debug(this, "-- numSupplemento ="+request.getParameter("numSupplemento"));
  htmpl.set("numSupplemento",request.getParameter("numSupplemento"));
  
  // Titolo del Supplemento (Supplemento anno xxxx o Supplemento Maggiorazione)
  SolmrLogger.debug(this,"-- Setto il titolo del Supplemento");
  Hashtable common = (Hashtable) session.getAttribute("common");
  if(common != null){
	  String notifica = (String) common.get("notifica");
	  SolmrLogger.debug(this, "--- notifica: " + notifica);
	  if(notifica.equalsIgnoreCase("supplementare")){
		 htmpl.newBlock("blkTitoloAssSuppl");
		 htmpl.set("blkTitoloAssSuppl.anno", ""+DateUtils.getCurrentYear());
		 htmpl.set("anno",""+DateUtils.getCurrentYear());
	  }
	  else if(notifica.equalsIgnoreCase("supplementareMaggiorazione")){
		 htmpl.newBlock("blkTitoloAssSupplementareMaggiorazione");
		 CampagnaMaggiorazioneVO campagnaMaggVo = umaClient.getCampagnaMaggiorazionebySysdate();
		 if(campagnaMaggVo != null){
		   htmpl.set("blkTitoloAssSupplementareMaggiorazione.titoloAssSupplMagg", campagnaMaggVo.getTitoloBreveMaggiorazione().toUpperCase());
		 }
	  }
  }
  
  
  
  SolmrLogger.debug(this, "   END calcoloAutomaticoFOfineAssSupplView");
  out.print(htmpl.text());
%>
