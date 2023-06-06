<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@page import="it.csi.solmr.dto.uma.LavContoTerziVO"%>
<%@page import="it.csi.solmr.dto.uma.MacchinaVO"%>
<%@page import="it.csi.solmr.dto.UtenteIrideVO"%>
<%!
  private static final String VIEW="/ditta/view/dettaglioLavContoPOPView.jsp";
%><%

  String iridePageName = "dettaglioLavContoPOPCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

	Vector  vIdUtente = new Vector();
	MacchinaVO macchinaVO = null;
  	UmaFacadeClient umaFacadeClient=new UmaFacadeClient();

	Long idLavContoTerzi = new Long(request.getParameter("idLavContoTerzi"));
  	SolmrLogger.debug(this,"DOPO GET PARAMETER ID LAV CONTO TERZI:::::::::: "+idLavContoTerzi);
  	
	HashMap hmLavContoTerzi = (HashMap)session.getAttribute("hmLavorazioni");
  	SolmrLogger.debug(this,"DOPO HASHMAP");
	LavContoTerziVO lavContoTerziVO = (LavContoTerziVO)hmLavContoTerzi.get(idLavContoTerzi);
	SolmrLogger.debug(this,"DOPO lavContoTerziVO: "+lavContoTerziVO);
	
	SolmrLogger.debug(this,"extIdUtenteAggiornamento vale: "+lavContoTerziVO.getExtIdUtenteAggiornamento());
	vIdUtente.add(lavContoTerziVO.getExtIdUtenteAggiornamento());
	//RuoloUtenza[] ruoloUtenza = umaFacadeClient.serviceGetRuoloUtenzaByIdRange((Long[])vIdUtente.toArray(new Long[vIdUtente.size()]),false);
  	UtenteIrideVO utenteIrideVO = umaFacadeClient.getUtenteIride(lavContoTerziVO.getExtIdUtenteAggiornamento());

	if(lavContoTerziVO.getIdMacchina()!=null)
		macchinaVO = umaFacadeClient.getMacchinaById(lavContoTerziVO.getIdMacchina());

	request.setAttribute("lavContoTerzi",lavContoTerziVO);
	request.setAttribute("macchinaVO",macchinaVO);
	request.setAttribute("utenteIrideVO",utenteIrideVO);

%><jsp:forward page="<%=VIEW%>" />
