<%@page import="it.csi.solmr.dto.CodeDescr"%>
<%@page import="it.csi.solmr.dto.CodeDescriptionLong"%>
<%@ page language="java" contentType="text/html" isErrorPage="true"%>

<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.dto.filter.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@page import="it.csi.solmr.dto.profile.RuoloUtenza"%>
<%@page import="javax.servlet.http.HttpSession"%>
<%@page import="org.apache.commons.lang3.StringUtils"%>

<%!public static String VIEW = "/ditta/view/elencoLavContoTerziSuContoProprioView.jsp";%>

<%
	String iridePageName = "elencoLavContoTerziSuContoProprioCtrl.jsp";
%>
<%@	include file="/include/autorizzazione.inc"%>
<%
	SolmrLogger.debug(this, "   BEGIN elencoLavContoTerziSuContoProprioCtrl");

	DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
	Long idAzienda = dittaUMAAziendaVO.getIdAzienda();
	SolmrLogger.debug(this," ---- idAzienda "+idAzienda);
  
 	RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  
 	String operation = (String)request.getParameter("operation");
 	request.setAttribute("operation", operation);
 	SolmrLogger.debug(this, "----- operation ="+operation);
  
	UmaFacadeClient umaClient = new UmaFacadeClient();

	LavContoTerziPerContoProprioFilter filter = new LavContoTerziPerContoProprioFilter();
	filter.setIdAzienda(idAzienda);
	
	if(StringUtils.isEmpty(operation)){
		
		SolmrLogger.debug(this, "----- PRIMO CARICAMENTO DELLA PAGINA");
	
		removeValSession(session);
			    
		String annoPrecedente = String.valueOf(UmaDateUtils.getCurrentYear().intValue() - 1);
			
		session.setAttribute("ANNI_RIF_COMBO", umaClient.getListaAnniCampagnaCTCP(idAzienda));
		session.setAttribute("USO_SUOLO_COMBO", umaClient.getTipiUsoSuoloPerAnnoSelezionatoCTCP(idAzienda, annoPrecedente));
		session.setAttribute("LAVORAZIONI_COMBO", umaClient.getTipiLavorazionePerAnnoSelezionatoCTCP(idAzienda, annoPrecedente));
			
		filter.setAnnoDiRiferimento(annoPrecedente);
			
		session.setAttribute("filterRicercaLavCTPerCP", filter);
		
		SolmrLogger.debug(this, "---- effettua la ricerca con i filtri forzati");
		try{ 
		    List<LavContoTerziPerContoProprioVO> elencoLavCpPerCt = umaClient.findLavorazioniCTPerCPByFilter(filter);
		    session.setAttribute("elencoLavCpPerCt", elencoLavCpPerCt);
		}
		catch(Exception ex){
		    SolmrLogger.error(this, "--- Exception in elencoLavCPCTCtrl con findLavorazioniCTPerCPByFilter ="+ex.getMessage());
		    request.setAttribute("errorMessage",ex.getMessage());
%>
<jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
<%
			return;
		}
	}
	else if(operation != null){
		if("ricerca".equals(operation)||"paginazione".equals(operation)){
			SolmrLogger.debug(this, "----- RICERCA ELENCO LAVORAZIONI TRAMITE FILTRO RICERCA");

			if("paginazione".equals(operation)){
				SolmrLogger.debug(this, "----- PAGINAZIONE ATTIVA");
				String startRowStr=request.getParameter("startRow");
				request.setAttribute("startRow", startRowStr);	     
			}
			filter.setAnnoDiRiferimento((String)request.getParameter("annoRiferimento"));
			filter.setcUAA((String)request.getParameter("cuaa"));
			filter.setDenominazione((String)request.getParameter("Denominazione"));
			filter.setIdLavorazione((String)request.getParameter("Lavorazione"));
			filter.setIdUsoDelSuolo((String)request.getParameter("usoSuolo"));
			filter.setPartitaIva((String)request.getParameter("iva"));
			
			SolmrLogger.debug(this, "----- con filtro: "+filter.toString());
			
			session.setAttribute("filterRicercaLavCTPerCP", filter);
			
			SolmrLogger.debug(this, "---- effettua la ricerca con i filtri impostati");
			try{ 
			    List<LavContoTerziPerContoProprioVO> elencoLavCpPerCt = umaClient.findLavorazioniCTPerCPByFilter(filter);
				SolmrLogger.debug(this, "---- lista elencoLavCpPerCt"+elencoLavCpPerCt.toString());
			    session.setAttribute("elencoLavCpPerCt", elencoLavCpPerCt);
			}
			catch(Exception ex){
			    SolmrLogger.error(this, "--- Exception in elencoLavCPCTCtrl con findLavorazioniCTPerCPByFilter ="+ex.getMessage());
			    request.setAttribute("errorMessage",ex.getMessage());
	%>
	<jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
	<%
				return;
			}
		}
	}
%>

<jsp:forward page="<%=VIEW%>" />

<%!
private void removeValSession(HttpSession session) throws Exception {
		SolmrLogger.debug(this, "   BEGIN removeValSession");

		session.removeAttribute("filterRicercaLavCTPerCP");
		session.removeAttribute("elencoLavCpPerCt");
		session.removeAttribute("ANNI_RIF_COMBO");
		session.removeAttribute("USO_SUOLO_COMBO");
		session.removeAttribute("LAVORAZIONI_COMBO");

		SolmrLogger.debug(this, "   END removeValSession");
}
%>