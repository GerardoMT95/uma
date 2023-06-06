<%@ page language="java" contentType="text/html" isErrorPage="false"%>

<%@ page import="it.csi.papua.papuaserv.exception.messaggistica.LogoutException"%>
<%@ page import="it.csi.papua.papuaserv.dto.messaggistica.ListaMessaggi"%>
<%@ page import="it.csi.solmr.etc.SolmrConstants"%>
<%@ page import="it.csi.solmr.util.SolmrLogger"%>
<%@ page import="it.csi.solmr.util.MessaggisticaUtils"%>
<%@ page import="it.csi.solmr.util.ValidationError"%>
<%@ page import="it.csi.solmr.util.ValidationErrors"%>

<%
  final String VIEW = "../view/messaggiUtenteLoginView.jsp";
  final String NEXT = "../layout/indexswhttp.htm";
  final String LOGOUT = SolmrConstants.PAGINA_FORCE_LOGOUT;
%>

<%
  String iridePageName = "indexCtrl.jsp";
%>

<%@include file = "/include/autorizzazione.inc" %>

<% 
  SolmrLogger.debug(this, "messaggiUtenteLoginCtrl BEGIN");
  
  // pulisco sessione dai messaggi di testata (in modo che vengano riletti alla prima occasione)
  session.removeAttribute(SolmrConstants.SESSION_MESSAGGI_TESTATA);

  String funzione = request.getParameter("funzione");
  ListaMessaggi listaMessaggi = null;
  
	try {
	  listaMessaggi = MessaggisticaUtils.getListaMessaggiUtenteLogin(session);
		request.setAttribute("listaMessaggi", listaMessaggi);
		
		if (listaMessaggi==null || listaMessaggi.getMessaggi()==null || listaMessaggi.getMessaggi().length==0) {
	    response.sendRedirect(NEXT);
	    return;
	  }
		
		if (SolmrConstants.OPERATION_CONFIRM.equals(funzione)) {
	    ValidationErrors errors = new ValidationErrors();
	    errors.add("error", new ValidationError( "Non è possibile continuare: esistono messaggi obbligatori non ancora letti"));
	    request.setAttribute("errors", errors);
	  }
	}catch (LogoutException ex) {
		SolmrLogger.error(this, "Forzare il logout"); 
		session.setAttribute("LogoutException", ex);
		response.sendRedirect(LOGOUT);
		return;
	}finally {
	  SolmrLogger.debug(this, "messaggiUtenteLoginCtrl END");
	}
  
%>
<jsp:forward page ="<%=VIEW%>" />