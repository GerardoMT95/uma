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
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String iridePageName = "dettaglioMacchinaDettaglioUtilizzoCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  AnagFacadeClient anagClient = new AnagFacadeClient();
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  String errorPage = "/macchina/view/dettaglioMacchinaUtilizzoView.jsp";

  ValidationErrors errors = new ValidationErrors();
  UtilizzoVO uVO = (UtilizzoVO)request.getAttribute("utilizzoVO");

  if(uVO!=null){
    try{
      Vector v_possessi = umaFacadeClient.getElencoPossessoByUtilizzo(uVO.getIdUtilizzoLong());
      PossessoVO[] possessi = null;
	  if(v_possessi != null){
		  possessi = (PossessoVO[]) v_possessi.toArray(new PossessoVO[0]);
	  }	
      uVO.setPossesso(possessi); 
      request.setAttribute("utilizzoVO",uVO);
    }
    catch(SolmrException sex){
      ValidationError error = new ValidationError(sex.getMessage());
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(errorPage).forward(request, response);
      return;
    }
    try{
      if(uVO.getIdAzienda()!=null){
    	AnagraficaAzVO aVO = anagClient.getDatiAziendaPerMacchine(uVO.getIdAzienda());
        request.setAttribute("datiAziendaVO",aVO);
      }
    }
    catch(SolmrException sex){
      ValidationError error = new ValidationError("Impossibile reperire i dati dell''azienda associata alla ditta UMA");
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(errorPage).forward(request, response);
      return;
    }
  }

  %>
    <jsp:forward page = "/macchina/view/dettaglioMacchinaDettaglioUtilizzoView.jsp" />
  <%
  SolmrLogger.debug(this,"----- dettaglioMacchinaDettaglioUtilizzoCtrl.jsp ----- fine");
%>

