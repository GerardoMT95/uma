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

  String iridePageName = "datiColtureAziendaPOPCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "   BEGIN datiColtureAziendaPOPCtrl");

  ValidationErrors errors = new ValidationErrors();
  String dettaglioUrl = "/domass/view/datiColtureAziendaPOPView.jsp";
  ValidationException valEx;
  Validator validator = new Validator(dettaglioUrl);

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  Long idDomAss;
  idDomAss = new Long(request.getParameter("idDomandaassegnazione"));

  try{
  
    /* Bisogna capire se è un dettaglio di un 'Supplemento' o di una 'Assegnazione base' :
        - se numSupplemento è valorizzato : Supplemento, altrimenti 'Assegnazione base'
    */
    Long numSupplemento = null;   
    String numSupplementoStr = request.getParameter("numSupplemento");
    SolmrLogger.debug(this, " --- numSupplementoStr ="+numSupplementoStr);
    if(numSupplementoStr != null && !numSupplementoStr.equals(""))
      numSupplemento = new Long(numSupplementoStr);
    
    String tipoAssengnazione = "";
    if(numSupplemento != null && !numSupplemento.equals("")){
      tipoAssengnazione = SolmrConstants.ID_TIPO_ASSEGNAZIONE_SUPPLEMENTARE; // Supplementare
    }
    else{
       tipoAssengnazione = SolmrConstants.TIPO_ASSEGNAZIONE_BASE_SALDO; // Base
    }  
        
    Vector vect = umaFacadeClient.getDettaglioAssegnazioneColture(idDomAss,tipoAssengnazione,numSupplemento);
    request.setAttribute("vect", vect);
    String annoRiferimento = (String) request.getParameter("annoRiferimento");
    request.setAttribute("annoRiferimento", annoRiferimento);
  }
  catch(SolmrException se){
    SolmrLogger.error(this, "-- SolmrException in datiColtureAziendaPOPCtrl ="+se.getMessage());
    throw new ValidationException("Errore di sistema : "+se.toString());
  }
  finally{
    SolmrLogger.debug(this, "   END datiColtureAziendaPOPCtrl");
  }

  %>
  <jsp:forward page ="<%=dettaglioUrl%>" />
