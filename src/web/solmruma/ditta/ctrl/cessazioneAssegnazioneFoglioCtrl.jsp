<%@page import="it.csi.solmr.etc.profile.AgriConstants"%>
<%@ page import="it.csi.solmr.util.*,it.csi.solmr.dto.uma.*" %>

<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String iridePageName = "cessazioneAssegnazioneFoglioCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

// NOTA : se siamo su questa pagina è perchè NON è stato trovato record su DB_NUMERAZIONE_FOGLIO

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  String url = "/ditta/layout/cessazioneAssegnazioneFoglio.htm";
  String succUrl = "/ditta/layout/cessaDittaUmaSalvata.htm";
  String urlSenzaVerifica = "/ditta/layout/cessaDittaUmaSalvataSenzaVerifica.htm";

  ValidationException valEx = null;
  Validator validator = new Validator(url);
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  Long anno = null;
  //Long idAssCarb = null;

  if(session.getAttribute("anno")!=null)
    anno = new Long(""+session.getAttribute("anno"));

  /*if(session.getAttribute("idAssCarb")!=null)
    idAssCarb = new Long(""+session.getAttribute("idAssCarb"));*/

  SolmrLogger.debug(this,"cessazioneAssegnazioneFoglioCtrl, anno: "+anno);
  Vector elencoNumerazioneFoglio = umaFacadeClient.selectNumFoglioByProvAndAnno(ruoloUtenza, anno);
  SolmrLogger.debug(this,"elencoNumerazioneFoglio: "+elencoNumerazioneFoglio);
  request.setAttribute("elencoNumerazioneFoglio", elencoNumerazioneFoglio);

  if(request.getParameter("avanti")!=null){
    SolmrLogger.debug(this,"HO CLICKATO AVANTI!!!!!!!!!!!!!");
    Long idNumerazioneFoglio = null;
    if(request.getParameter("radiobutton")!=null && new Long(request.getParameter("radiobutton")).longValue()!=-1){
      idNumerazioneFoglio = new Long(request.getParameter("radiobutton"));    
    }
    SolmrLogger.debug(this,"---- idNumerazioneFoglio: "+idNumerazioneFoglio);
    String extCuaaAziendaDest=request.getParameter("extCuaaAziendaDest");

    DomandaAssegnazione da = (DomandaAssegnazione)session.getAttribute("domandaAssegnazione");
    Vector vectCrVO = (Vector)session.getAttribute("vectConsumoRimanenzaVO");
    Vector<BuonoPrelievoVO> elencoBuoniPrelievo = (Vector<BuonoPrelievoVO>)session.getAttribute("vectBuonoPrelievoVO");
    Date dataCessazione = (Date)session.getAttribute("dataCessazione");

    SolmrLogger.debug(this,"*******************cessazioneAssegnazioneFoglioCtrl**********************");
    SolmrLogger.debug(this," ----- id domanda assegnazione"+da.getIdDitta());
    SolmrLogger.debug(this,"-- dimensione vettore consumo rimanenze: "+vectCrVO.size());    
    SolmrLogger.debug(this,"-- data cessazione: "+dataCessazione);
    Long idDittaUma = new Long(request.getParameter("idDittaUMA"));
    SolmrLogger.debug(this,"-- dopo request idDittaUMA: "+idDittaUma);
    DittaUMAVO dittaUmaVO = umaFacadeClient.findDittaVOByIdDitta(idDittaUma);
    SolmrLogger.debug(this,"-- data findDittaVOByIdDitta");
    String siglaDittaDaCessare = dittaUmaVO.getExtProvinciaUMA();
    
    SolmrLogger.debug(this,"-- data siglaDittaDaCessare: "+siglaDittaDaCessare);
    String provinciaDaCessare = umaFacadeClient.getSiglaProvinciaByIstatProvincia(siglaDittaDaCessare);
    session.setAttribute("siglaProvinciaPassivo", provinciaDaCessare);
    
    /*
      L'HashMap tornata in output sarà composta da:
        - key = BUONI_PREL_PASSIVI, BUONI_PREL_ATTIVI, FOGLIO, RIGA
        - valore = Vector<Long>
    */
    HashMap<String, Vector<Long>> outputCessaDittaUma = umaFacadeClient.cessaDittaConNumeroFoglio(da, vectCrVO, elencoBuoniPrelievo, dataCessazione, ruoloUtenza, idNumerazioneFoglio,extCuaaAziendaDest);
    url = urlSenzaVerifica;


    SolmrLogger.debug(this,"-- Recupero i dati restituiti da  cessaDittaConNumeroFoglio()");
    // Recupero gli ID_BUONO_PRELIEVO inseriti per la ditta cedente (quella che viene cessata)
    Vector<Long> idBuoniPrelPassiviVect = outputCessaDittaUma.get(SolmrConstants.BUONI_PREL_PASSIVI);  
    
    // Recupero gli ID_BUONO_PRELIEVO inseriti per l'eventuale ditta ricevente
    Vector<Long> idBuoniPrelAttiviVect = outputCessaDittaUma.get(SolmrConstants.BUONI_PREL_ATTIVI);           
    
    // Recupero il foglio
    Long foglio = null;
    Vector<Long> foglioVect = outputCessaDittaUma.get(SolmrConstants.FOGLIO);
    if(foglioVect != null && foglioVect.size() >0)
     foglio = foglioVect.get(0);
    
    // Recupero la riga
    Vector<Long> rigaVect = outputCessaDittaUma.get(SolmrConstants.RIGA);
    Long riga = null;
    if(rigaVect != null && rigaVect.size() >0)
      riga = rigaVect.get(0);
    
    // Se c'erano delle rimanenze, sono stati inseriti dei record in DB_BUONO_PRELIEVO
    if(!outputCessaDittaUma.isEmpty() && idBuoniPrelPassiviVect != null && idBuoniPrelPassiviVect.size()>0){
      SolmrLogger.debug(this,"-- sono stati inseriti dei buoni prelievo"); 
      // ditta cedente (ditta cesssata)
      session.setAttribute("idBuoniPrelPassiviVect", idBuoniPrelPassiviVect);
      // eventuale ditta ricevente        
      session.setAttribute("idBuoniPrelAttiviVect", idBuoniPrelAttiviVect);
      SolmrLogger.debug(this, "--- setto url ="+succUrl);
      url = succUrl;
    }
    SolmrLogger.debug(this," -- numFoglio: "+foglio);
    SolmrLogger.debug(this," -- numRiga: "+foglio);
    session.setAttribute("numFoglio", ""+foglio);
    session.setAttribute("numRiga", ""+foglio);

    //return;
  }
  else url = "/ditta/view/cessazioneAssegnazioneFoglioView.jsp";
%>
<jsp:forward page="<%=url%>"/>
