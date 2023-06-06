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

  String iridePageName = "datiCarburanteLavorazioniPOPCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "   BEGIN datiCarburanteLavorazioniPOP");

  ValidationErrors errors = new ValidationErrors();
  String dettaglioUrl = "/domass/view/datiCarburanteLavorazioniPOPView.jsp";
  ValidationException valEx;
  Validator validator = new Validator(dettaglioUrl);

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  Long idDomAss;
  idDomAss = new Long(request.getParameter("idDomandaassegnazione"));
  
  String annoDomanda = request.getParameter("annoDomanda");
  request.setAttribute("annoDomanda", annoDomanda);

  try
  {
    Vector vect = new Vector();
    
    // Cerca le decurtazioni per Conto terzi
    SolmrLogger.debug(this, "-- Cerca le decurtazioni per Conto terzi");
    vect = umaFacadeClient.getDettaglioAssegnazioneLavorazioni(idDomAss);
    request.setAttribute("vect", vect);
    
    // Cerca le decurtazioni per Consorzi
    SolmrLogger.debug(this, "-- Cerca le decurtazioni per Consorzi");
    Vector<FrmDettaglioAssegnazioneLavorazioniVO> decurtazVectConsorzi = umaFacadeClient.getDettAssegnazLavConsorzi(idDomAss);
    request.setAttribute("decurtazVectConsorzi", decurtazVectConsorzi);
    
  }
  catch(SolmrException se){
    throw new ValidationException("Errore di sistema : "+se.toString());
  }
  finally{
    SolmrLogger.debug(this, "   BEGIN datiCarburanteLavorazioniPOP");
  }

  SolmrLogger.debug(this, "   BEGIN datiCarburanteLavorazioniPOP");

  %>
  <jsp:forward page ="<%=dettaglioUrl%>" />
