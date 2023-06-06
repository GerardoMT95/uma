
<%@ page language="java" contentType="text/html" isErrorPage="true"%>

<%@ page import="it.csi.solmr.business.uma.*"%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.etc.uma.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="java.rmi.RemoteException"%>
<%@ page import="java.sql.Timestamp"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>





<%

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/ditta/layout/cessaDittaUmaSalvata.htm");


%><%@include file="/include/menu.inc"%>
<%


  SolmrLogger.debug(this, "cessaDittaUmaSalvataView.jsp - Begin");

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  it.csi.solmr.client.uma.UmaFacadeClient umaFacadeClient = new it.csi.solmr.client.uma.UmaFacadeClient();

  HtmplUtil.setValues(htmpl, request);
  HtmplUtil.setErrors(htmpl, errors, request);

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  ValidationException valEx = null;

  Long idDittaUma = null;
  Long idDittaUmaRicevente = null;
  String siglaPassivo = "";

  String denominazione = "";
  String dittaUMA = "";
  String cuaa = "";

  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
  denominazione = dittaVO.getDenominazione();
  SolmrLogger.debug(this, "-- denominazione ditta uma ="+denominazione);
  cuaa = dittaVO.getCuaa();
  dittaUMA = dittaVO.getDittaUMAstr();
  idDittaUma = new Long(""+request.getParameter("idDittaUMA"));
  siglaPassivo = (String)session.getAttribute("siglaProvinciaPassivo");
  idDittaUmaRicevente = new Long(""+request.getParameter("numDittaUmaConsRim"));
  SolmrLogger.debug(this, "-- idDittaUmaRicevente ="+idDittaUmaRicevente);
 // Long idDomAss = new Long(""+session.getAttribute("idDomAss"));
 // SolmrLogger.debug(this, "-- idDomAss ="+idDomAss);

  String provCompetenza ="";

  if(dittaVO.getProvUMA()!= null && !dittaVO.getProvUMA().equals(""))
    provCompetenza = umaFacadeClient.getProvinciaByIstat(dittaVO.getProvUMA());
  long annoRif = DateUtils.getCurrentYear().longValue();  
    
  htmpl.set("denominazione", denominazione);
  htmpl.set("CUAA", cuaa);
  htmpl.set("dittaUMA", dittaUMA);
  htmpl.set("umaTipoDitta", dittaVO.getTipiDitta());
  htmpl.set("provinciaCompetenza", provCompetenza);
  htmpl.set("anno",""+annoRif);
  htmpl.set("idDittaUMA", ""+idDittaUma);
//  htmpl.set("idDomAss", ""+idDomAss);  

  if(session.getAttribute("numRiga")!=null){
    int numeroRiga = new Integer(""+session.getAttribute("numRiga")).intValue();
    if(numeroRiga == 50)
      htmpl.set("numRiga", ""+UmaErrors.get("MSGFOGLIORIGACOMPLETATO"));
    else
      htmpl.set("numRiga", ""+session.getAttribute("numRiga"));
      
    htmpl.set("numFoglio", ""+session.getAttribute("numFoglio"));
  }

  Vector<Long> idBuoniPrelPassiviVect = (Vector<Long>)session.getAttribute("idBuoniPrelPassiviVect");
  Vector<Long> idBuoniPrelAttiviVect = (Vector<Long>)session.getAttribute("idBuoniPrelAttiviVect");
  
  
  //-------------- ********* Ricerca Buoni Prelievo PASSIVI ************
  SolmrLogger.debug(this, "---- Ricerca Buoni Prelievo PASSIVI");
  Vector<BuonoPrelievoVO> elencoBuoniPrelDittaDaCessare = umaFacadeClient.selectBuonoPrelievo(idBuoniPrelPassiviVect);
  if(elencoBuoniPrelDittaDaCessare != null){
      SolmrLogger.debug(this, "--- numero di Buoni prelievo PASSIVI ="+elencoBuoniPrelDittaDaCessare.size());
	  // per ogni buono prelievo, visualizzo una tabella 
	  for(int i=0;i<elencoBuoniPrelDittaDaCessare.size();i++){
	      htmpl.newBlock("blkBuonoPassivo");
	      
	      BuonoPrelievoVO buonoPrelPassivo = elencoBuoniPrelDittaDaCessare.get(i);
		  Long numBloccoPassivo = buonoPrelPassivo.getNumeroBlocco();
		  Long numBuonoPassivo = buonoPrelPassivo.getNumeroBuono();
		  String dataEmissionePassivo = DateUtils.extractDayFromDate(buonoPrelPassivo.getDataEmissione())+"/"+DateUtils.extractMonthFromDate(buonoPrelPassivo.getDataEmissione())+"/"+DateUtils.extractYearFromDate(buonoPrelPassivo.getDataEmissione());
		
		  SolmrLogger.debug(this, "---- Effettuo somma della quantita concessa per i Buoni Passivi");
		  SolmrLogger.debug(this, "--- idBuonoPrelievo ="+buonoPrelPassivo.getIdBuonoPrelievo());
		  Long qtaRestComplessivaPassivo = umaFacadeClient.selectSumQtaConcessaByIdBuono(buonoPrelPassivo.getIdBuonoPrelievo());
		  SolmrLogger.debug(this, "--- qtaRestComplessivaPassivo ="+qtaRestComplessivaPassivo);
		
		  // -------- Visualizzo Dati BUONI PRELIEVO PASSIVI
		  htmpl.set("blkBuonoPassivo.numBloccoPassivo", ""+numBloccoPassivo);
		  htmpl.set("blkBuonoPassivo.numBuonoPassivo", ""+numBuonoPassivo);
		  htmpl.set("blkBuonoPassivo.dataEmissionePassivo", ""+dataEmissionePassivo);
		  htmpl.set("blkBuonoPassivo.qtaRestComplessivaPassivo", ""+qtaRestComplessivaPassivo);
		  htmpl.set("blkBuonoPassivo.siglaProvinciaPassivo", siglaPassivo);
		  htmpl.set("blkBuonoPassivo.dittaUmaPassivo", dittaUMA);
		  // ------------------
	  
	  }
  }
  
   //-------------- Ricerca Buoni Prelievo ATTIVI  
  Vector<BuonoPrelievoVO> elencoBuoniPrelDittaRicevente = null;  
  if (idBuoniPrelAttiviVect != null && idBuoniPrelAttiviVect.size()>0) {
    SolmrLogger.debug(this, "---- Ricerca Buoni Prelievo ATTIVI");    
    SolmrLogger.debug(this, "--- numero di Buoni prelievo ATTIVI ="+idBuoniPrelAttiviVect.size());		   
	elencoBuoniPrelDittaRicevente = umaFacadeClient.selectBuonoPrelievo(idBuoniPrelAttiviVect);	
	// per ogni buono prelievo, visualizzo una tabella 
	for(int i=0;i<elencoBuoniPrelDittaRicevente.size();i++){   
	    htmpl.newBlock("blkBuonoAttivo");
	    
	    BuonoPrelievoVO buonoPrelAttivo = elencoBuoniPrelDittaRicevente.get(i); 
	    Long numBloccoAttivo = buonoPrelAttivo.getNumeroBlocco();
	    Long numBuonoAttivo = buonoPrelAttivo.getNumeroBuono();
	
	    String dataEmissioneAttivo = DateUtils.extractDayFromDate(buonoPrelAttivo.getDataEmissione())+"/"+DateUtils.extractMonthFromDate(buonoPrelAttivo.getDataEmissione())+"/"+DateUtils.extractYearFromDate(buonoPrelAttivo.getDataEmissione());
	    
	    SolmrLogger.debug(this, "-- idBuonoPrelievo ="+buonoPrelAttivo.getIdBuonoPrelievo());
	    Long qtaRestComplessivaAttivo = umaFacadeClient.selectSumQtaConcessaByIdBuono(buonoPrelAttivo.getIdBuonoPrelievo());
	    SolmrLogger.debug(this, "--- qtaRestComplessivaAttivo ="+qtaRestComplessivaAttivo);
	    String siglaDittaUmaRiceventeAttivo = request.getParameter("provincia");
	    
	    // -------- Visualizzo Dati BUONI PRELIEVO ATTIVI	    
	    htmpl.set("blkBuonoAttivo.numBloccoAttivo", ""+numBloccoAttivo);
	    htmpl.set("blkBuonoAttivo.numBuonoAttivo", ""+numBuonoAttivo);
	    htmpl.set("blkBuonoAttivo.dataEmissioneAttivo", dataEmissioneAttivo);
	    htmpl.set("blkBuonoAttivo.qtaRestComplessivaAttivo", ""+qtaRestComplessivaAttivo);
	    htmpl.set("blkBuonoAttivo.siglaProvinciaAttivo", siglaDittaUmaRiceventeAttivo.toUpperCase());
	    htmpl.set("blkBuonoAttivo.dittaUmaAttivo", ""+idDittaUmaRicevente);
	    // -------------------------
    }
  }
  
  
  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

  SolmrLogger.debug(this, "cessaDittaUmaSalvataView.jsp - End");
%>

<%= htmpl.text()%>