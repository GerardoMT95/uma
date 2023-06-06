<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="it.csi.solmr.business.uma.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.client.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
  SolmrLogger.debug(this, "BEGIN giorniRiscaldSerraView");	

  String layout = "/ditta/layout/giorniRiscaldSerra.htm";
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layout);
  SolmrLogger.info(this, "Found layout: "+layout);

%><%@include file = "/include/menu.inc" %><%
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  Vector result = null;
  int len;

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  DecimalFormat numericFormat2 = new DecimalFormat(SolmrConstants.FORMATO_NUMERIC_1INT_2DEC);

  // Dati generici della serra
  SolmrLogger.debug(this, "-- Recupero i dati generici della serra");
  SerraVO serraVO=(SerraVO) request.getAttribute("serraVO");    
  htmpl.set("coltura", serraVO.getDescrizioneTipoColtura());
  htmpl.set("tipoEforma", serraVO.getDescrizioneTipoFormaSerra());
  htmpl.set("dataCarico", serraVO.getDataCaricoStr());
  htmpl.set("volume", serraVO.getVolumeMetriCubiStr());
  
  // Dati con giorni di riscaldamento per mese
  SolmrLogger.debug(this, "-- Recupero i dati con giorni di riscaldamento per mese");
  List<SerraRiscaldamentoVO> giorniRiscaldamentoDb = (List<SerraRiscaldamentoVO>)request.getAttribute("giorniRiscaldamentoDb");
  if(giorniRiscaldamentoDb != null && giorniRiscaldamentoDb.size()>0){
	 // Scorro i record trovati e li setto nel mese corretto	
	 for (Iterator<SerraRiscaldamentoVO> iterator = giorniRiscaldamentoDb.iterator(); iterator.hasNext();) {
		 SerraRiscaldamentoVO serraRiscaldamentoVO = (SerraRiscaldamentoVO) iterator.next(); 
		 if(serraRiscaldamentoVO.getMese().equalsIgnoreCase("GENNAIO")){
		   htmpl.set("ggDiRiscaldGennaio", ""+serraRiscaldamentoVO.getGiorni()); 
		 }
		 if(serraRiscaldamentoVO.getMese().equalsIgnoreCase("FEBBRAIO")){
		   htmpl.set("ggDiRiscaldFebbraio", ""+serraRiscaldamentoVO.getGiorni());
		 }
		 if(serraRiscaldamentoVO.getMese().equalsIgnoreCase("MARZO")){
		   htmpl.set("ggDiRiscaldMarzo", ""+serraRiscaldamentoVO.getGiorni()); 
		 }
		 if(serraRiscaldamentoVO.getMese().equalsIgnoreCase("APRILE")){
		   htmpl.set("ggDiRiscaldAprile", ""+serraRiscaldamentoVO.getGiorni());
		 }
		 if(serraRiscaldamentoVO.getMese().equalsIgnoreCase("MAGGIO")){
		   htmpl.set("ggDiRiscaldMaggio", ""+serraRiscaldamentoVO.getGiorni());
		 }
		 if(serraRiscaldamentoVO.getMese().equalsIgnoreCase("GIUGNO")){
	       htmpl.set("ggDiRiscaldGiugno", ""+serraRiscaldamentoVO.getGiorni());
		 }
		 if(serraRiscaldamentoVO.getMese().equalsIgnoreCase("LUGLIO")){
		    htmpl.set("ggDiRiscaldLuglio", ""+serraRiscaldamentoVO.getGiorni());			 
		 }
		 if(serraRiscaldamentoVO.getMese().equalsIgnoreCase("AGOSTO")){
		   htmpl.set("ggDiRiscaldAgosto", ""+serraRiscaldamentoVO.getGiorni());			 
		 }
		 if(serraRiscaldamentoVO.getMese().equalsIgnoreCase("SETTEMBRE")){
		   htmpl.set("ggDiRiscaldSettembre", ""+serraRiscaldamentoVO.getGiorni());			 	 
		 }
		 if(serraRiscaldamentoVO.getMese().equalsIgnoreCase("OTTOBRE")){
		   htmpl.set("ggDiRiscaldOttobre", ""+serraRiscaldamentoVO.getGiorni()); 
		 }
		 if(serraRiscaldamentoVO.getMese().equalsIgnoreCase("NOVEMBRE")){
		   htmpl.set("ggDiRiscaldNovembre", ""+serraRiscaldamentoVO.getGiorni());
		 }
		 if(serraRiscaldamentoVO.getMese().equalsIgnoreCase("DICEMBRE")){
		   htmpl.set("ggDiRiscaldDicembre", ""+serraRiscaldamentoVO.getGiorni());
		 }		 
	 }
	 // Controllo se la serra selezionata nell'elenco ha DATA_FINE_VALIDITA valorizzata : in questo caso i campi devono essere disabilitati
	 if(serraVO.getDataFineValidita() != null){
		 SolmrLogger.debug(this, "-- La serra selezionata ha DATA_FINE_VALIDITA valorizzata, i campi devono essere disabilitati");
		 htmpl.set("disabledGgDiRiscaldGennaio", "disabled");	 
		 htmpl.set("disabledGgDiRiscaldFebbraio", "disabled");
		 htmpl.set("disabledGgDiRiscaldMarzo", "disabled");
		 htmpl.set("disabledGgDiRiscaldAprile", "disabled");
		 htmpl.set("disabledGgDiRiscaldMaggio", "disabled");
		 htmpl.set("disabledGgDiRiscaldGiugno", "disabled");
		 htmpl.set("disabledGgDiRiscaldLuglio", "disabled");
		 htmpl.set("disabledGgDiRiscaldAgosto", "disabled");
		 htmpl.set("disabledGgDiRiscaldSettembre", "disabled");
		 htmpl.set("disabledGgDiRiscaldOttobre", "disabled");
		 htmpl.set("disabledGgDiRiscaldNovembre", "disabled");
		 htmpl.set("disabledGgDiRiscaldDicembre", "disabled");
		 htmpl.set("disabledSalvaGgRiscald", "disabled");
	 }
	 
  
  }
  
    

  HtmplUtil.setValues(htmpl, serraVO, request.getParameter("pathToFollow"));
  HtmplUtil.setValues(htmpl, request);
  
  htmpl.set("idSerra",""+serraVO.getIdSerra());
  htmpl.set("pageFrom",request.getParameter("pageFrom"));

  HtmplUtil.setErrors(htmpl, errors, request);

  //this.errErrorValExc(htmpl, request, exception);
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

  SolmrLogger.debug(this, "END giorniRiscaldSerraView");
  
  out.print(htmpl.text());

%>
