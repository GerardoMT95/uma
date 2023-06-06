<%@ page language="java" contentType="text/html" isErrorPage="false"%>

<%@ page import="it.csi.papua.papuaserv.dto.messaggistica.DettagliMessaggio"%>
<%@ page import="it.csi.solmr.etc.SolmrConstants"%>
<%@ page import="it.csi.solmr.util.SolmrLogger"%>
<%@ page import="it.csi.solmr.util.MessaggisticaUtils"%>
<%@ page import="it.csi.solmr.util.Validator"%>

<%!
  public final static String VIEW = "../view/dettaglioMessaggiUtenteLoginView.jsp";
  private static final String CONFERMA="../layout/";
%>

<%
  String iridePageName = "indexCtrl.jsp";
%>

<%@include file = "/include/autorizzazione.inc" %>

<%
  SolmrLogger.info(this, " - dettaglioMessaggiUtenteLoginCtrl.jsp - INIZIO PAGINA");
  DettagliMessaggio dettagliMessaggio = null;
  String funzione = request.getParameter("funzione");
   
  if (Validator.isEmpty(funzione)) {
	  String idElencoMessaggi = request.getParameter("idElencoMessaggi");
	  String chiamante = request.getParameter("chiamante");
	  
	  try {
	    dettagliMessaggio = MessaggisticaUtils.getDettagliMessaggio(Long.valueOf(idElencoMessaggi), session);
	  }catch (NumberFormatException nfe) {		    
	  }
	  
	  request.setAttribute("dettagliMessaggio", dettagliMessaggio);
	  request.setAttribute("chiamante", chiamante);
	  session.setAttribute("dettagliMessaggio", dettagliMessaggio);
   }else if (SolmrConstants.OPERATION_CONFIRM.equals(funzione)) {
	  dettagliMessaggio = (DettagliMessaggio)session.getAttribute("dettagliMessaggio");
	
	  if (dettagliMessaggio.isLetturaObbligatoria()) {
	    if (!dettagliMessaggio.isLetto()) {
			  if (SolmrConstants.FLAG_SI.equalsIgnoreCase(request.getParameter("flagDichLettura"))) {
					MessaggisticaUtils.confermaLetturaMessaggio(dettagliMessaggio.getIdElencoMessaggi(), session);
					// forzo il reload dei messaggi di testata (con il conteggio dei messaggi letti)
					session.removeAttribute(SolmrConstants.SESSION_MESSAGGI_TESTATA);
				}
			}
		}else {
		  MessaggisticaUtils.confermaLetturaMessaggio(dettagliMessaggio.getIdElencoMessaggi(), session);
			// forzo il reload dei messaggi di testata (con il conteggio dei messaggi letti)
			session.removeAttribute(SolmrConstants.SESSION_MESSAGGI_TESTATA);
		}
		
		response.sendRedirect(CONFERMA + request.getParameter("chiamante"));
		return;
	}
	
  %><jsp:forward page="<%=VIEW%>"/><%

  SolmrLogger.info(this, " - dettaglioMessaggiUtenteLoginCtrl.jsp - FINE PAGINA");
%>