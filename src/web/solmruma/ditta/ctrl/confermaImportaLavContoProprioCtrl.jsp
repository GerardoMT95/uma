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
<%@ page import="it.csi.solmr.etc.anag.AnagErrors" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<jsp:useBean id="serraVO" scope="page"
             class="it.csi.solmr.dto.uma.SerraVO">
  <jsp:setProperty name="serraVO" property="*" />
</jsp:useBean>
<%

  String iridePageName = "confermaImportaLavContoProprioCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "   BEGIN confermaImportaLavContoProprioCtrl");

  UmaFacadeClient umaClient = new UmaFacadeClient();  
  String viewUrl="/ditta/view/confermaImportaLavContoProprioView.jsp";
  String elencoCtrl="/ditta/ctrl/elencoLavContoProprioCtrl.jsp";  
  String elencoHtm="../layout/elencoLavContoProprio.htm";  
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza"); 

  String validateUrl = elencoCtrl;
  
  String operation = request.getParameter("operation");
  SolmrLogger.debug(this, "---- operation ="+operation);

  if (operation != null && operation.equals("conferma")){
    SolmrLogger.debug(this,"-------- Caso conferma IMPORTA lavorazioni");    
    try{
      // Recupero i dati da passare in input al pl PCK_SMRUMA_CARICA_LAVORAZ_CP  
      SolmrLogger.debug(this,"--- Recupero i dati da passare in input al pl PCK_SMRUMA_CARICA_LAVORAZ_CP");    
      Long idUtente = ruoloUtenza.getIdUtente();
      DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
      
      Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();      
      // Test per avere codice di errore dal pl
      //Long idDittaUma = null;
      
      SolmrLogger.debug(this,"--- Effettuo l'IMPORTA lavorazioni conto proprio");
      umaClient.importaLavorazioniContoProprio(idDittaUma, idUtente);    
      SolmrLogger.debug(this,"--- l'IMPORTA lavorazioni è andato a buon fine");       
      session.setAttribute("notifica","Operazione eseguita con successo");
      
      session.setAttribute("paginaChiamante", "importa"); 	    
    }
    catch(Exception e){
	  SolmrLogger.debug(this,"---- Exception durante importaLavorazioniContoProprio ="+e.getMessage());
	  throwValidation(e.getMessage(),validateUrl);
	}
   
    SolmrLogger.debug(this,"-- torno su "+elencoHtm);       
    
    response.sendRedirect(elencoHtm);
    return;
  }
  else{
    if (operation != null && operation.equals("annulla")){
      SolmrLogger.debug(this,"-------- CASO annulla");     
      response.sendRedirect(elencoHtm);
      session.setAttribute("paginaChiamante", "importa");
      return;
    }
    else{      
      SolmrLogger.debug(this,"-------- CASO visualizza pagina per scelta importa lavorazioni"); 
      %>
      <jsp:forward page="<%=viewUrl%>"/>
      <%
    }
  }
%>
<%!
private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException(msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}





%>
