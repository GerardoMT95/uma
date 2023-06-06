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
  private static final String VIEW="/ditta/view/dettaglioLavDaContoPOPView.jsp";
%><%

  String iridePageName = "dettaglioLavDaContoPOPCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

	Vector  vIdUtente = new Vector();
	MacchinaVO macchinaVO = null;
  	UmaFacadeClient umaFacadeClient=new UmaFacadeClient();

	Long idLavDaContoTerzi = new Long(request.getParameter("idLavDaContoTerzi"));
  	SolmrLogger.debug(this,"DOPO GET PARAMETER ID LAV CONTO TERZI:::::::::: "+idLavDaContoTerzi);
		
	HashMap hmLavDaContoTerzi = (HashMap)session.getAttribute("hmDaLavorazioni");
  	SolmrLogger.debug(this,"DOPO HASHMAP");
	LavContoTerziVO lavDaContoTerziVO = (LavContoTerziVO)hmLavDaContoTerzi.get(idLavDaContoTerzi);
	SolmrLogger.debug(this,"DOPO lavDaContoTerziVO: "+lavDaContoTerziVO);
	
	SolmrLogger.debug(this,"extIdUtenteAggiornamento vale: "+lavDaContoTerziVO.getExtIdUtenteAggiornamento());
	vIdUtente.add(lavDaContoTerziVO.getExtIdUtenteAggiornamento());
	//RuoloUtenza[] ruoloUtenza = umaFacadeClient.serviceGetRuoloUtenzaByIdRange((Long[])vIdUtente.toArray(new Long[vIdUtente.size()]),false);
  	UtenteIrideVO utenteIrideVO = umaFacadeClient.getUtenteIride(lavDaContoTerziVO.getExtIdUtenteAggiornamento());

	if(lavDaContoTerziVO.getIdMacchina()!=null)
		macchinaVO = umaFacadeClient.findDettaglioMacchinaById(lavDaContoTerziVO.getIdMacchina());

	request.setAttribute("lavContoTerzi",lavDaContoTerziVO);
	request.setAttribute("macchinaVO",macchinaVO);
	request.setAttribute("utenteIrideVO",utenteIrideVO);

%><jsp:forward page="<%=VIEW%>" />
