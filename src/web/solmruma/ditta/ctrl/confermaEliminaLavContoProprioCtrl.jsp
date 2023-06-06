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
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String iridePageName = "confermaEliminaLavContoProprioCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "   BEGIN confermaEliminaLavContoProprioCtrl");

  UmaFacadeClient umaClient = new UmaFacadeClient();
  String url="/ditta/ctrl/elencoLavContoProprioCtrl.jsp";
  String viewUrl="/ditta/view/confermaEliminaLavContoProprioView.jsp";
  String elenco="/ditta/ctrl/elencoLavContoProprioCtrl.jsp"; 
  String elencoHtm="../../ditta/layout/elencoLavContoProprio.htm";
   
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  // Recupero gli id_lavorazioni_conto_proprio selezionati e da eliminare
  SolmrLogger.debug(this, "---- recupero gli id_lavorazioni_conto_proprio selezionati e da eliminare");
  Long[] idLavContoProprio = (Long[])session.getAttribute("idLavContoProprioSel");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
   
   
  if (request.getParameter("conferma")!=null){
	    SolmrLogger.debug(this, "--------- CASO di CONFERMA elimina Lavorazioni Conto Proprio");            
	    // Eliminazione lavorazioni conto proprio
	    try{
	      umaClient.deleteLavContoProprio(idLavContoProprio,ruoloUtenza.getIdUtente());
	      session.setAttribute("notifica","Eliminazione eseguita con successo");
	    }
	    catch(Exception e){
	      SolmrLogger.error(this, " ----- Exception durante deleteLavContoProprio ="+e.getMessage()); 
	      throwValidation(e.getMessage(),url);
	    }    	  
	    session.setAttribute("paginaChiamante", "elimina");
	    response.sendRedirect(elencoHtm);
	    return;   
  }
  else if (request.getParameter("annulla")!=null){ 
         SolmrLogger.debug(this, "--------- CASO di ANNULLA elimina Lavorazioni Conto Proprio");
         session.setAttribute("paginaChiamante", "elimina");    
         response.sendRedirect(elencoHtm);                  
      return;
  }
  else{
      SolmrLogger.debug(this," ---- Visualizzare la pagina di conferma elimina");
      %>
      <jsp:forward page="<%=viewUrl%>"/>
      <%
  }

SolmrLogger.debug(this, "   END confermaEliminaLavContoProprioCtrl");  
%>
<%!
private void throwValidation(String msg,String validateUrl) throws ValidationException{
  ValidationException valEx = new ValidationException(msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}

%>
