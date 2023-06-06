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

  String iridePageName = "datiAllevamentiAziendaPOPCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "   BEGIN datiAllevamentiAziendaPOPCtrl");
 
  ValidationErrors errors = new ValidationErrors();
  String dettaglioUrl = "/domass/view/datiAllevamentiAziendaPOPView.jsp";
  ValidationException valEx;
  Validator validator = new Validator(dettaglioUrl);

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  Long idDomAss;
  idDomAss = new Long(request.getParameter("idDomandaassegnazione"));
  SolmrLogger.debug(this, " --- idDomandaAssegnazione ="+idDomAss);
  
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

  try{        
    Vector vect = umaFacadeClient.getDettaglioAssegnazioneAllevamenti(idDomAss,tipoAssengnazione,numSupplemento);
    request.setAttribute("vect", vect);
  }
  catch(SolmrException se)
  {
    SolmrLogger.error(this, "---- SolmrException in datiAllevamentiAziendaPOPCtrl ="+se.getMessage());
    SolmrLogger.debug(this, "   END datiAllevamentiAziendaPOPCtrl");     
    throw new ValidationException("Errore di sistema : "+se.toString());
  }


  try
  {        
    Vector vectColture = umaFacadeClient.getDettaglioAssegnazioneColture(idDomAss,tipoAssengnazione,numSupplemento);
    request.setAttribute("vectColture", vectColture);
    String annoRiferimento = (String) request.getParameter("annoRiferimento");
    request.setAttribute("annoRiferimento", annoRiferimento);
  }
  catch(SolmrException se){
    SolmrLogger.error(this, "---- SolmrException2 in datiAllevamentiAziendaPOPCtrl ="+se.getMessage());
    SolmrLogger.debug(this, "   END datiAllevamentiAziendaPOPCtrl");     
    throw new ValidationException("Errore di sistema : "+se.toString());
  }

  SolmrLogger.debug(this, "   END datiAllevamentiAziendaPOPCtrl");

  %>
  <jsp:forward page ="<%=dettaglioUrl%>" />