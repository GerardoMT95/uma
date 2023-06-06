<%@ page language="java" contentType="text/html" isErrorPage="true"%>

<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%!public final static String VIEW = "../view/importaDatiView.jsp";
	public final static String VIEW_CONFERMA = "../view/importaDatiConfermaView.jsp";
	public final static String ANNULLA = "/anag/layout/dettaglioAzienda.htm";
	//public final static String ESEGUI = "../layout/sincronizza_dati_esegui.shtml";
	public final static String ESEGUI = "../layout/importaDatiAttesa.htm";%>

<%
	SolmrLogger.info(this, " - importaDatiCtrl.jsp - INIZIO PAGINA");
	String iridePageName = "importaDatiCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%
	HashMap hmCommon = null;

	if (request.getParameter("conferma.x") != null) { //CASO: ESECUZIONE IMPORTA
		try {
			SolmrLogger.debug(this, "request.getParameter(funzione): " + request.getParameter("funzione"));

			UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

			RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

			HashMap formeGiuridiche = (HashMap) session.getAttribute("formeGiuridicheNonSottoposteAFascicolo");
			DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
			SolmrLogger.debug(this, "\n\n\n\n\n#############################################");
			SolmrLogger.debug(this, "new String(dittaVO.getIdFormaGiuridica().toString()): " + new String(dittaVO.getIdFormaGiuridica().toString()));
			SolmrLogger.debug(this, "dittaVO.getIdConduzione(): " + dittaVO.getIdConduzione());
			SolmrLogger.debug(this, "formeGiuridiche: " + formeGiuridiche);
			SolmrLogger.debug(this, "SolmrConstants.IDCONDUZIONECONTOTERZI: " + SolmrConstants.IDCONDUZIONECONTOTERZI);
			SolmrLogger.debug(this, "formeGiuridiche.get(new String(dittaVO.getIdFormaGiuridica().toString()): " + formeGiuridiche.get(new String(dittaVO.getIdFormaGiuridica().toString())));
			SolmrLogger.debug(this, "SolmrConstants.IDCONDUZIONECONTOTERZI: " + SolmrConstants.IDCONDUZIONECONTOTERZI);
			SolmrLogger.debug(this, "#############################################\n\n\n\n\n");

			Long idDittaUma = dittaVO.getIdDittaUMA();
			//051216 Controlli x importazione dati - End

			if (dittaVO.getIdConduzione() != null && dittaVO.getIdConduzione().equalsIgnoreCase(new String(SolmrConstants.IDCONDUZIONECONTOTERZI.toString()))) {
				throw new SolmrException(SolmrConstants.MSG_DITTA_UMA_CONTO_TERZI_IMPORTA_DATI);
			}

			if (formeGiuridiche != null && formeGiuridiche.get(new String(dittaVO.getIdFormaGiuridica().toString())) != null) {
				SolmrLogger.debug(this, "if(formeGiuridiche!=null && formeGiuridiche.get(new String(dittaVO.getIdFormaGiuridica().toString()))!=null)");
				throw new SolmrException(SolmrConstants.MSG_DITTA_UMA_FORMA_GIURIDICA_NON_CONSENTITA);
			} else {
				SolmrLogger.debug(this, "else(formeGiuridiche!=null && formeGiuridiche.get(new String(dittaVO.getIdFormaGiuridica().toString()))!=null)");
			}
		} catch (SolmrException sexc) {
			Hashtable common = (Hashtable) session.getAttribute("common");
			if (common == null) {
				common = new Hashtable();
			}
			common.put("msgCreazione", sexc.getMessage());
			session.setAttribute("common", common);
			%><jsp:forward page="<%=VIEW%>" />
			<%
				} catch (Exception exc) {
						Hashtable common = (Hashtable) session.getAttribute("common");
						if (common == null) {
							common = new Hashtable();
						}
						common.put("msgCreazione", exc.getMessage());
						session.setAttribute("common", common);
			%><jsp:forward page="<%=VIEW%>" />
			<%
		}
		response.sendRedirect(ESEGUI);
		SolmrLogger.info(this, " - importaDatiCtrl.jsp - FINE PAGINA");
	}
	else if(request.getParameter("annulla.x") != null){ //CASO: ANNULLA
		%>
			<jsp:forward page="<%=ANNULLA%>" />
		<%
	}
	else{ //CASO: LANDING PAGE
		%>
			<jsp:forward page="<%=VIEW_CONFERMA%>" />
		<%
	}
	return;
%>