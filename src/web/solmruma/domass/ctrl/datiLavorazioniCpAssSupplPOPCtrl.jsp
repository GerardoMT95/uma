<%@page import="it.csi.solmr.dto.filter.LavContoProprioFilter"%>
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

  String iridePageName = "datiLavorazioniCpPOPCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "   BEGIN datiLavorazioniCpAssSupplPOPCtrl");
  
  
  ValidationErrors errors = new ValidationErrors();
  String view = "/domass/view/datiLavorazioniCpAssSupplPOPView.jsp";
  ValidationException valEx;
  Validator validator = new Validator(view);

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();  
  
  String annoRiferimento = request.getParameter("annoRiferimento");
  SolmrLogger.debug(this, " -- annoRiferimento ="+annoRiferimento);  
  request.setAttribute("annoRiferimento", annoRiferimento);
  
  Long idAssegnazioneCarburante = new Long(request.getParameter("idAssegnazioneCarburante"));
  SolmrLogger.debug(this, " -- idAssegnazioneCarburante ="+idAssegnazioneCarburante);
  

  try{
    UmaFacadeClient umaClient = new UmaFacadeClient();
    
    SolmrLogger.debug(this, " ------ Effettuo la ricerca delle lavorazioni Conto Proprio per l'Assegnazione Supplementare");      
    Vector<LavContoProprioVO> elencoLavContoProprio = umaClient.findLavorazContoProprioByIdAssCarb(idAssegnazioneCarburante,null,0);
    request.setAttribute("elencoLavorazioniAssSupplPop", elencoLavContoProprio);	
        
    SolmrLogger.debug(this, " ------ Effettuo la ricerca dei carburanti per frammentazione Conto Proprio");
    Vector<CarburanteFrammentazioneVO> elencoCarburantiPerFrammentaz = umaClient.getElencoCarburantePerFrammentazCPByIdAssCarb(idAssegnazioneCarburante,null,0);
    request.setAttribute("elencoCarburantiPerFrammentazAssSuppl", elencoCarburantiPerFrammentaz);	        
  }
  catch(Exception e){
    request.setAttribute("elencoLavorazioniAssSupplPop",null);
    request.setAttribute("elencoCarburantiPerFrammentazAssSuppl", null);
    SolmrLogger.error(this, "--- Exception in datiLavorazioniCpAssSupplPOPCtrl ="+e.getMessage());
    throw new ValidationException("Errore di sistema : "+e.toString());
  }
  finally{
    SolmrLogger.debug(this, "   END datiLavorazioniCpAssSupplPOPCtrl");
  }  
  %>
  <jsp:forward page ="<%=view%>" />
