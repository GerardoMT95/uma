<%@ page language="java"
         contentType="text/html"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.etc.SolmrConstants" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%

  String iridePageName = "datiCarburanteMacchinePOPCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "   BEGIN datiCarburanteMacchinePOPCtrl");
  ValidationErrors errors = new ValidationErrors();
  String dettaglioUrl = "/domass/view/datiCarburanteMacchinePOPView.jsp";
  ValidationException valEx;
  Validator validator = new Validator(dettaglioUrl);

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  Long idDomAss;
  idDomAss = new Long(request.getParameter("idDomandaassegnazione"));
  
  /* Bisogna capire se è un dettaglio di un 'Supplemento' o di una 'Assegnazione base' :
        - se numSupplemento è valorizzato : Supplemento, altrimenti 'Assegnazione base'
  */
  Long numSupplemento = null;   
  String numSupplementoStr = request.getParameter("numSupplemento");
  SolmrLogger.debug(this, " --- numSupplementoStr ="+numSupplementoStr);
  if(numSupplementoStr != null && !numSupplementoStr.equals(""))
    numSupplemento = new Long(numSupplementoStr);
  String tipoAssegnazione = "";
  if(numSupplemento != null && !numSupplemento.equals("")){
    tipoAssegnazione = SolmrConstants.ID_TIPO_ASSEGNAZIONE_SUPPLEMENTARE; // Supplementare
  }
  else{
     tipoAssegnazione = SolmrConstants.TIPO_ASSEGNAZIONE_BASE_SALDO; // Base
  }

  try{    
    Vector vect = umaFacadeClient.getDettaglioAssegnazioneMachine(idDomAss,tipoAssegnazione,numSupplemento);
    request.setAttribute("vect", vect);
    String annoRiferimento = (String) request.getParameter("annoRiferimento");
    request.setAttribute("annoRiferimento", annoRiferimento);
  }
  catch(SolmrException se){
    SolmrLogger.error(this, "--- SolmrException in datiCarburanteMacchinePOPCtrl ="+se.getMessage());
    throw new ValidationException("Errore di sistema : "+se.toString());
  }
  finally{
    SolmrLogger.debug(this, "   END datiCarburanteMacchinePOPCtrl");
  }
      
  %>
  <jsp:forward page ="<%=dettaglioUrl%>" />