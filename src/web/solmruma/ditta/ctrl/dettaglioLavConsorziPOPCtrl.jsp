<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@page import="it.csi.solmr.dto.uma.LavConsorziVO"%>
<%@page import="it.csi.solmr.dto.uma.MacchinaVO"%>
<%@page import="it.csi.solmr.dto.UtenteIrideVO"%>
<%!
  private static final String VIEW="/ditta/view/dettaglioLavConsorziPOPView.jsp";
%><%

  String iridePageName = "dettaglioLavConsorziPOPCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

	Vector  vIdUtente = new Vector();
	MacchinaVO macchinaVO = null;
  	UmaFacadeClient umaFacadeClient=new UmaFacadeClient();

	Long idLavConsorzi = new Long(request.getParameter("idLavConsorzi"));
  	SolmrLogger.debug(this,"DOPO GET PARAMETER ID LAV CONSORZI:::::::::: "+idLavConsorzi);
		
	HashMap hmLavConsorzi = (HashMap)session.getAttribute("hmLavorazioni");
  	SolmrLogger.debug(this,"DOPO HASHMAP");
	LavConsorziVO lavConsorziVO = (LavConsorziVO)hmLavConsorzi.get(idLavConsorzi);
	SolmrLogger.debug(this,"DOPO lavConsorziVO: "+lavConsorziVO);
	
	SolmrLogger.debug(this,"extIdUtenteAggiornamento vale: "+lavConsorziVO.getExtIdUtenteAggiornamento());
	vIdUtente.add(lavConsorziVO.getExtIdUtenteAggiornamento());
  	UtenteIrideVO utenteIrideVO = umaFacadeClient.getUtenteIride(lavConsorziVO.getExtIdUtenteAggiornamento());

	SolmrLogger.debug(this,"id_macchina: "+lavConsorziVO.getIdMacchina());
	if(lavConsorziVO.getIdMacchina()!=null)
		macchinaVO = umaFacadeClient.findDettaglioMacchinaById(lavConsorziVO.getIdMacchina());

	request.setAttribute("lavConsorzi",lavConsorziVO);
	request.setAttribute("macchinaVO",macchinaVO);
	request.setAttribute("utenteIrideVO",utenteIrideVO);

%><jsp:forward page="<%=VIEW%>" />
