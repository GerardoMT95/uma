<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  public final static String VIEW = "../view/sceltaImportaDatiSociView.jsp";
  public final static String VIEW_ATTESA = "../view/importaDatiSociAttesaView.jsp";  
  public static String DETTAGLIO = "../../anag/layout/dettaglioAzienda.htm";
%>

<%
  SolmrLogger.debug(this, " BEGIN sceltaImportaDatiSociCtrl");
  String iridePageName = "sceltaImportaDatiSociCtrl.jsp";
  %>
  <%@include file = "/include/autorizzazione.inc" %>
  <%
    
    SolmrLogger.debug(this, "   BEGIN sceltaImportaDatiSociCtrl");
    
    String operation = request.getParameter("operation");
    SolmrLogger.debug(this, "-- operation =" + request.getParameter("operation"));
    
    //--- CASO : e' stato selezionato 'avanti'
    if(operation != null){
      if(operation.equals("avanti")){
	      SolmrLogger.debug(this, "--- CASO : e' stato selezionato 'avanti'");
	      
	      // Controllare quale tipo di import e' stato selezionato
	      String importaDatiSoci = request.getParameter("importaSoci");
	      SolmrLogger.debug(this, "-- importaDatiSoci ="+importaDatiSoci);
	           
	      request.setAttribute("importaDatiSoci", importaDatiSoci);
	      
	      // Andare sulla view per la gestione della visualizzazione della pagina di attesa e chiamata a PACK_IMPORTA_DATI
	      SolmrLogger.debug(this, "  END sceltaImportaDatiSociCtrl");
	      %>
	      <jsp:forward page="<%=VIEW_ATTESA%>"/><%
      }
      else if(operation.equals("annulla")){
        SolmrLogger.debug(this, "--- CASO : e' stato selezionato 'annulla'");
        response.sendRedirect(DETTAGLIO);
        return;
      }
    }
    // --- CASO : accesso alla pagina di scelta
    else if(operation == null || operation.endsWith("")){
      SolmrLogger.debug(this, "--- CASO : accesso alla pagina di scelta");
      SolmrLogger.debug(this, "  END sceltaImportaDatiSociCtrl");
      // Andare sulla view per visualizzare la pagina di scelta importa dati dei soci
      %>
      <jsp:forward page="<%=VIEW%>"/><%
      return;
    }
    

%>