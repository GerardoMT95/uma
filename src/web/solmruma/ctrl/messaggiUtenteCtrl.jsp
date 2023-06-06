<%@ page language="java" contentType="text/html" isErrorPage="false" %>

<%@ page import="it.csi.papua.papuaserv.exception.messaggistica.LogoutException"%>
<%@ page import="it.csi.papua.papuaserv.dto.messaggistica.ListaMessaggi"%>
<%@ page import="it.csi.solmr.util.SolmrLogger"%>
<%@ page import="it.csi.solmr.util.MessaggisticaUtils"%>

<%
  final String VIEW = "../view/messaggiUtenteView.jsp";
  final String LOGOUT = "/layout/force_logout.htm";
%>

<%
  String iridePageName = "indexCtrl.jsp";
%>

<%@include file = "/include/autorizzazione.inc" %>

<%
  SolmrLogger.debug(this, "messaggiUtenteCtrl BEGIN");

  ListaMessaggi listaMessaggi = null;
  
	try {
		listaMessaggi = MessaggisticaUtils.getListaMessaggiUtente(session);
		request.setAttribute("listaMessaggi", listaMessaggi);
	}catch (LogoutException ex){
		SolmrLogger.error(this, "Forzare il logout");
		session.setAttribute("LogoutException", ex);
		response.sendRedirect(LOGOUT);
		return;
	}finally {
		SolmrLogger.debug(this, "messaggiUtenteCtrl END");
	}
  
%>
<jsp:forward page ="<%=VIEW%>" />