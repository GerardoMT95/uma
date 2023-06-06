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

  SolmrLogger.debug(this, "   BEGIN datiLavorazioniCpPOPCtrl");
  
  
  ValidationErrors errors = new ValidationErrors();
  String view = "/domass/view/datiLavorazioniCpPOPView.jsp";
  ValidationException valEx;
  Validator validator = new Validator(view);

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  
  Long idDittaUma = new Long(request.getParameter("idDittaUma"));
  SolmrLogger.debug(this, " -- idDittaUma ="+idDittaUma);
  String annoRiferimento = request.getParameter("annoRiferimento");
  SolmrLogger.debug(this, " -- annoRiferimento ="+annoRiferimento);
  request.setAttribute("annoRiferimento", annoRiferimento);
  
  Long idDomandaAssegnazione = new Long(request.getParameter("idDomandaassegnazione"));
  SolmrLogger.debug(this, " -- idDomandaAssegnazione ="+idDomandaAssegnazione);
  
  /* Controllo se la domanda assegnazione base corrispondente all'idDomandaAssegnazione selezionato è
     con stato :
       - in BOZZA : la query di ricerca lavorazioni e delle frammentazioni avranno la condizione con id_assegnazione_carburante is null e si filtrerà per id_ditta_uma e anno_campagna
       - altrimenti : la query di ricerca lavorazioni e delle frammentazioni avranno la condizione con id_assegnazione_carburante =  a quello su db_assegnazione_carburante
                      legato all'idDomandaAssegnazione e con tipo_assegnazione = 'B'
  */
  try{
    UmaFacadeClient umaClient = new UmaFacadeClient();
    Long idAssegnazCarbFilter = null;
    Long idDittaUmaFilter = null;
    int annoCampagna= 0;
    SolmrLogger.debug(this, " --- Ricerco i dati della Domanda Assegnazione, per controllarne lo stato"); 
	DomandaAssegnazione domandaAss = umaClient.findDomAssByPrimaryKey(idDomandaAssegnazione);
	if(domandaAss.getIdStatoDomanda().longValue() == new Long(SolmrConstants.ID_STATO_DOMANDA_BOZZA).longValue()){
	  SolmrLogger.debug(this, " -- Lo STATO della Domanda di Assegnazione è IN BOZZA");
	  idDittaUmaFilter = idDittaUma;
	  SolmrLogger.debug(this, " - idDittaUma = "+idDittaUma);	  
	  annoCampagna = UmaDateUtils.extractYearFromDate(domandaAss.getDataRiferimento());
	  SolmrLogger.debug(this, " - annoCampagna = "+annoCampagna);	  
	}
	else{
	  SolmrLogger.debug(this, " -- Lo STATO della Domanda di Assegnazione NON è IN BOZZA");
	  SolmrLogger.debug(this, " --- Ricerco l'id_assegnazione_carburante legato alla Domanda di Assegnazione Base selezionata");
      idAssegnazCarbFilter = umaClient.getIdAssegnazCarbByDomAss(idDomandaAssegnazione);
	}
    SolmrLogger.debug(this, " -- idAssegnazCarbFilter ="+idAssegnazCarbFilter);
    
    SolmrLogger.debug(this, " ------ Effettuo la ricerca delle lavorazioni Conto Proprio per la popup di Assegnazione Base ");
   
    Vector<LavContoProprioVO> elencoLavContoProprio = umaClient.findLavorazContoProprioByIdAssCarb(idAssegnazCarbFilter,idDittaUmaFilter, annoCampagna);
    request.setAttribute("elencoLavorazioniPop", elencoLavContoProprio);	
    
    SolmrLogger.debug(this, " ------ Effettuo la ricerca dei carburanti per frammentazione Conto Proprio");
    Vector<CarburanteFrammentazioneVO> elencoCarburantiPerFrammentaz = umaClient.getElencoCarburantePerFrammentazCPByIdAssCarb(idAssegnazCarbFilter,idDittaUmaFilter, annoCampagna);
    request.setAttribute("elencoCarburantiPerFrammentaz", elencoCarburantiPerFrammentaz);	    
    
  }
  catch(Exception e){
    request.setAttribute("elencoLavorazioniPop",null);
    request.setAttribute("elencoCarburantiPerFrammentaz", null);
    SolmrLogger.error(this, "--- Exception in datiLavorazioniCpPOPCtrl ="+e.getMessage());
    throw new ValidationException("Errore di sistema : "+e.toString());
  }
  finally{
    SolmrLogger.debug(this, "   END datiLavorazioniCpPOPCtrl");
  }  
  %>
  <jsp:forward page ="<%=view%>" />
