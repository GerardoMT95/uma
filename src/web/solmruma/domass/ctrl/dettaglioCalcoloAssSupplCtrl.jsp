<%@page import="it.csi.solmr.etc.profile.AgriConstants"%>
<%@ page language="java" contentType="text/html"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.etc.*" %>

<jsp:useBean id="fdaVO" scope="page"
	class="it.csi.solmr.dto.uma.FrmDettaglioAssegnazioneVO">
	<jsp:setProperty name="fdaVO" property="*" />
</jsp:useBean>



<%!public static final String VIEW_URL = "/domass/view/dettaglioCalcoloAssSupplView.jsp";
  public static final String dettaglioUrl = "/domass/ctrl/dettaglioDomandaCtrl.jsp";%>

<%
  String iridePageName = "dettaglioCalcoloAssSupplCtrl.jsp";
%>
  <%@include file="/include/autorizzazione.inc"%>
<%
  
  SolmrLogger.debug(this,"   BEGIN dettaglioCalcoloAssSupplCtrl");
  try{  
      // link 'dettaglio' sul menu' -> si deve tornare sul dettaglio dell'Assegnazione
	  if(request.getParameter("operation") != null && request.getParameter("operation").equals("dettaglio")){
	      SolmrLogger.debug(this,"-- Caso Dettaglio -> dettaglioDomandaCtrl");
	      SolmrLogger.debug(this,"   END dettaglioCalcoloAssSupplCtrl");
	        %>
	          <jsp:forward page="<%=dettaglioUrl%>" />
	        <%
	  }  
	    
	    
	  UmaFacadeClient umaClient = new UmaFacadeClient();
	     
	  // Chiamata al pl PCK_SMRUMA_ASSEGNAZ_CARB.DETTAGLIO_ASSEGNAZIONE_CARB()    
	  String idAssegnazioneCarburanteSel =  (String)request.getParameter("idAssCarb"); // radio button selezionato dall'elenco dei Supplementi  
	  SolmrLogger.debug(this, "--- idAssegnazioneCarburanteSel ="+idAssegnazioneCarburanteSel);
	  request.setAttribute("idAssegnazioneCarburante",idAssegnazioneCarburanteSel);
	    
	  // Cerco il numero_supplemento su db_assegnazione_carburante, dato l'id_assegnazione_carburante selezionato
	  Long numeroSupplemento = umaClient.getNumSupplementoByIdAssCarburante(new Long(idAssegnazioneCarburanteSel));
	  request.setAttribute("numeroSupplemento",numeroSupplemento);
	  // memorizzo il valore per le popup relative ai pulsanti "dettaglio" delle voci presenti sulla pagina (A), B), ecc ..)
	  request.setAttribute("numSupplemento", numeroSupplemento);
	  SolmrLogger.debug(this, "--- numeroSupplemento selezionato dall'elenco ="+numeroSupplemento);
	                  
	  Long idDomAss = null;         
	  if (request.getParameter("idDomAss") != null){
	    idDomAss = new Long(request.getParameter("idDomAss"));    
	  }
	  SolmrLogger.debug(this," -- idDomAss ="+idDomAss);
	  request.setAttribute("idDomandaAssegnazione", idDomAss);
	  
	  String tipoAssegnazione = SolmrConstants.ID_TIPO_ASSEGNAZIONE_SUPPLEMENTARE;     
	  SolmrLogger.debug(this, " --- Chiamata a PCK_SMRUMA_ASSEGNAZ_CARB.DETTAGLIO_ASSEGNAZIONE_CARB()");
	  fdaVO = umaClient.dettaglioCalcoloPL(idDomAss,tipoAssegnazione,numeroSupplemento);
	   
	  SolmrLogger.debug(this, " --- Ricerco i dati della Domanda Assegnazione"); 
	  DomandaAssegnazione da = umaClient.findDomAssByPrimaryKey(idDomAss);
	  request.setAttribute("domandaAssegnazione", da);
	  
	  request.setAttribute("fdaVO", fdaVO);


      SolmrLogger.debug(this,"-- Vado sulla VIEW del dettaglio calcolo Assegnazione supplementare");
      SolmrLogger.debug(this,"   END dettaglioCalcoloAssSupplCtrl");
      %>
      <jsp:forward page="<%=VIEW_URL%>" />
     <%      
  } 
  catch (Exception e){
    SolmrLogger.error(this, "--- Exception in dettaglioCalcoloAssSupplCtrl ="+e.getMessage());
    setError(request, "Si è verificato un errore di sistema");
    %>
      <jsp:forward page="<%=VIEW_URL%>" />
    <%
  }
%>
<%!private void setError(HttpServletRequest request, String msg){    
    ValidationErrors errors = new ValidationErrors();
    errors.add("error", new ValidationError(msg));
    request.setAttribute("errors", errors);
  }
%>