  <%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>
<%@ page import="it.csi.solmr.business.uma.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
  Htmpl htmpl = HtmplFactory.getInstance(application)
                  .getHtmpl("/ditta/layout/cessaDittaUma.htm");
%><%@include file = "/include/menu.inc" %><%
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  it.csi.solmr.client.uma.UmaFacadeClient umaFacadeClient = new it.csi.solmr.client.uma.UmaFacadeClient();

  htmpl.set("extCuaaAziendaDest",trimToUpper(request.getParameter("extCuaaAziendaDest")));
  HtmplUtil.setValues(htmpl, request);
  HtmplUtil.setErrors(htmpl, errors, request);
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  ValidationException valEx = null;

//TEST CON DITTA UMA RIMANENZE = 2, DITTA DA CESSARE = 3
  Long idDittaUma = null;
  try {
    idDittaUma = new Long(""+request.getAttribute("idDittaUMA"));
  } catch (Exception exc) {
    SolmrLogger.debug(this,"Qui dentro");
  }
  SolmrLogger.debug(this,"----------------idDittaUma dalla View!!!!!! "+idDittaUma);
  Long idDomAss = null;
  try {
    if(request.getAttribute("idDomAss")!=null){
      idDomAss = new Long(""+request.getAttribute("idDomAss"));
    }
    else{
      idDomAss = new Long(""+request.getParameter("idDomAss"));
    }
  } catch (Exception exc) {
    SolmrLogger.debug(this,"Qui dentro 2");
  }
  SolmrLogger.debug(this,"----------------idDomAss dalla View!!!!!!!!"+idDomAss);
  Long intermediario = null;
  try {
    intermediario = new Long(""+request.getAttribute("intermediario"));
  } catch (Exception exc) {
    SolmrLogger.debug(this,"Qui dentro 2");
  }
  SolmrLogger.debug(this,"----------------intermediario dalla View!!!!!!!!"+intermediario);

  String utente = "";
  String ente = "";
  //String cod = "";
  String denominazione = "";
  String dittaUMA = "";
  String cuaa = "";
  //String codFiscale = "";
  String num_uma = "";

  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
  try{
    denominazione = dittaVO.getDenominazione();
  } catch (Exception exc) {
    SolmrLogger.debug(this,"Qui dentro 5");
  }

  try{
    cuaa = dittaVO.getCuaa();
  } catch (Exception exc) {
  SolmrLogger.debug(this,"Qui dentro 7");
  }

  try{
    dittaUMA = dittaVO.getDittaUMAstr();
  } catch (Exception exc) {
  SolmrLogger.debug(this,"Qui dentro 8");
  }

  try{
      num_uma = request.getParameter("num_uma");
  } catch (Exception exc) {
    SolmrLogger.debug(this,"Qui dentro 9");
  }

  String provCompetenza ="";
  /*if(!dittaVO.getProvCompetenza().equals(""))
    provCompetenza = umaFacadeClient.getProvinciaByIstat(dittaVO.getProvCompetenza());*/
  if(!dittaVO.getProvUMA().equals("")){
    provCompetenza = umaFacadeClient.getProvinciaByIstat(dittaVO.getProvUMA());
  }
  //Long idDomAss = umaFacadeClient.findByCriterio(idDittaUma.longValue()).getIdDomandaAssegnazione();
  long annoRif = DateUtils.getCurrentYear().longValue();
  long rimanenzaPrecContoProprioGas = 0;
  long rimanenzaPrecContoProprioBenz = 0;
  long rimanenzaPrecContoTerziBenz = 0;
  long rimanenzaPrecContoTerziGas = 0;
  long rimanenzaPrecSerraBenz = 0;
  long rimanenzaPrecSerraGas = 0;

  long prelevatoSerraGas = 0;
  long prelevatoSerraBenz = 0;
  
  /*long prelevatoNonSerraGas = 0;
  long prelevatoNonSerraBenz = 0;*/
  
  long prelevatoCPGas = 0;
  long prelevatoCPBenz = 0;
  long prelevatoCTGas = 0;
  long prelevatoCTBenz = 0;
  

  long totaleGas  = 0;
  long totaleBenz  = 0;
  long totaleSerraGas  = 0;
  long totaleSerraBenz  = 0;
  long totaleNonSerraGas  = 0;
  long totaleNonSerraBenz  = 0;

  long rimanenzaContoGas = 0;
  long rimanenzaContoBenz = 0;
  long rimanenzaContoTerziGas = 0;
  long rimanenzaContoTerziBenz = 0;
  long rimanenzaSerraGas = 0;
  long rimanenzaSerraBenz = 0;
  long totRimanenzaGas = 0;
  long totRimanenzaBenz = 0;

  long consumoContoProprioGas = 0;
  long consumoContoProprioBenz = 0;
  long consumoContoTerziGas = 0;
  long consumoContoTerziBenz = 0;
  long consumoSerraGas = 0;
  long consumoSerraBenz = 0;
  long totConsumoGas = 0;
  long totConsumoBenz = 0;

  //long numeroDocumenti = 0;
  String numeroDocumenti = "";
  String dataDocumentazione = null;
  String dataCessazioneAttivita = DateUtils.getCurrentDateString();
  String provincia = "";
  //long numeroDittaUma=0;
  String numeroDittaUma = "";

  rimanenzaPrecContoProprioGas = umaFacadeClient.selectConsumoRimanenzaContoProprio(idDomAss, SolmrConstants.ID_GASOLIO);
  rimanenzaPrecContoProprioBenz = umaFacadeClient.selectConsumoRimanenzaContoProprio(idDomAss, SolmrConstants.ID_BENZINA);
  rimanenzaPrecContoTerziGas = umaFacadeClient.selectConsumoRimanenzaContoTerzi(idDomAss, SolmrConstants.ID_GASOLIO);
  rimanenzaPrecContoTerziBenz = umaFacadeClient.selectConsumoRimanenzaContoTerzi(idDomAss, SolmrConstants.ID_BENZINA);

  //061029 - Carburante x serra - Begin
  rimanenzaPrecSerraGas = umaFacadeClient.selectConsumoRimanenzaSerra(idDomAss, SolmrConstants.ID_GASOLIO);
  rimanenzaPrecSerraBenz = umaFacadeClient.selectConsumoRimanenzaSerra(idDomAss, SolmrConstants.ID_BENZINA);
  //061029 - Carburante x serra - End

  SolmrLogger.debug(this, "\n\n\n\n###########################");
  SolmrLogger.debug(this, "idDomAss: "+idDomAss);
  SolmrLogger.debug(this, "###########################\n\n\n\n");
  
/*  prelevatoNonSerraGas = umaFacadeClient.selectPrelevatoNonSerra(idDomAss, SolmrConstants.ID_GASOLIO);
  prelevatoNonSerraBenz = umaFacadeClient.selectPrelevatoNonSerra(idDomAss, SolmrConstants.ID_BENZINA);
  */
  
  prelevatoCPGas = new Long(umaFacadeClient.selectPrelevatoContoProprio(idDomAss, ""+SolmrConstants.get("ID_GASOLIO"))).longValue();
  prelevatoCPBenz = new Long(umaFacadeClient.selectPrelevatoContoProprio(idDomAss, ""+SolmrConstants.get("ID_BENZINA"))).longValue();
  prelevatoCTGas = new Long(umaFacadeClient.selectPrelevatoContoTerzi(idDomAss, ""+SolmrConstants.get("ID_GASOLIO"))).longValue();
  prelevatoCTBenz = new Long(umaFacadeClient.selectPrelevatoContoTerzi(idDomAss, ""+SolmrConstants.get("ID_BENZINA"))).longValue();
 
  
  SolmrLogger.debug(this, "-- prelevatoCPGas: "+prelevatoCPGas);
  SolmrLogger.debug(this, "-- prelevatoCPBenz: "+prelevatoCPBenz);
  SolmrLogger.debug(this, "-- prelevatoCTGas: "+prelevatoCTGas);
  SolmrLogger.debug(this, "-- prelevatoCTBenz: "+prelevatoCTBenz);
  
  
  //061029 - Carburante x serra - Begin
  prelevatoSerraGas = umaFacadeClient.selectPrelevatoSerra(idDomAss, SolmrConstants.ID_GASOLIO);
  prelevatoSerraBenz = umaFacadeClient.selectPrelevatoSerra(idDomAss, SolmrConstants.ID_BENZINA);
  //061029 - Carburante x serra - End

 
 /* SolmrLogger.debug(this, "prelevatoNonSerraGas: "+prelevatoNonSerraGas);
  SolmrLogger.debug(this, "prelevatoNonSerraBenz: "+prelevatoNonSerraBenz);*/
    
  SolmrLogger.debug(this, "prelevatoSerraGas: "+prelevatoSerraGas);
  SolmrLogger.debug(this, "prelevatoSerraBenz: "+prelevatoSerraBenz);


  //061029 - Carburante x serra - Begin
  totaleNonSerraGas = rimanenzaPrecContoProprioGas + rimanenzaPrecContoTerziGas + prelevatoCPGas + prelevatoCTGas;
  totaleNonSerraBenz = rimanenzaPrecContoProprioBenz + rimanenzaPrecContoTerziBenz + prelevatoCPBenz + prelevatoCTBenz;
  totaleSerraGas = rimanenzaPrecSerraGas + prelevatoSerraGas;
  totaleSerraBenz = rimanenzaPrecSerraBenz + prelevatoSerraBenz;
  //totaleGas = rimanenzaPrecContoProprioGas + rimanenzaPrecContoTerziGas + prelevatoGas;
  totaleGas = totaleSerraGas + totaleNonSerraGas;
  //totaleBenz = rimanenzaPrecContoProprioBenz + rimanenzaPrecContoTerziBenz + prelevatoBenz;
  totaleBenz = totaleSerraBenz + totaleNonSerraBenz;
  //061029 - Carburante x serra - End


  if(intermediario!=null)
    htmpl.set("intermediario",""+intermediario);

  htmpl.set("denominazione",denominazione);
  htmpl.set("CUAA",cuaa);
  htmpl.set("dittaUMA",dittaUMA);
  htmpl.set("umaTipoDitta",dittaVO.getTipiDitta());
  htmpl.set("provinciaCompetenza",provCompetenza);
  htmpl.set("idDittaUMA", ""+idDittaUma);
  htmpl.set("idDomAss", ""+idDomAss);

  htmpl.set("anno",""+annoRif);
  htmpl.set("rimanenzaPrecContoProprioBenz",""+rimanenzaPrecContoProprioBenz);
  htmpl.set("rimanenzaPrecContoProprioGas",""+rimanenzaPrecContoProprioGas);
  htmpl.set("rimanenzaPrecContoTerziBenz",""+rimanenzaPrecContoTerziBenz);
  htmpl.set("rimanenzaPrecContoTerziGas",""+rimanenzaPrecContoTerziGas);
  //061029 - Carburante x serra - Begin
  htmpl.set("rimanenzaPrecSerraBenz",""+rimanenzaPrecSerraBenz);
  htmpl.set("rimanenzaPrecSerraGas",""+rimanenzaPrecSerraGas);
  
  htmpl.set("prelevatoCPGas",""+prelevatoCPGas);
  htmpl.set("prelevatoCPBenz",""+prelevatoCPBenz);
  htmpl.set("prelevatoCTGas",""+prelevatoCTGas);
  htmpl.set("prelevatoCTBenz",""+prelevatoCTBenz);
  
  
  htmpl.set("prelevatoSerraGas",""+prelevatoSerraGas);
  htmpl.set("prelevatoSerraBenz",""+prelevatoSerraBenz);
  //061029 - Carburante x serra - End

  htmpl.set("totaleGas",""+totaleGas);
  htmpl.set("totaleBenz",""+totaleBenz);
  htmpl.set("rimanenzaContoGas",""+rimanenzaContoGas);
  htmpl.set("rimanenzaContoBenz",""+rimanenzaContoBenz);
  htmpl.set("rimanenzaContoTerziGas",""+rimanenzaContoTerziGas);
  htmpl.set("rimanenzaContoTerziBenz",""+rimanenzaContoTerziBenz);

  //061029 - Carburante x serra - Begin
  htmpl.set("rimanenzaSerraGas",""+rimanenzaSerraGas);
  htmpl.set("rimanenzaSerraBenz",""+rimanenzaSerraBenz);
  totRimanenzaGas = rimanenzaContoGas + rimanenzaContoTerziGas + rimanenzaSerraGas;
  totRimanenzaBenz = rimanenzaContoBenz + rimanenzaContoTerziBenz + rimanenzaSerraBenz;
  SolmrLogger.debug(this, "totRimanenzaGas: "+totRimanenzaGas);
  SolmrLogger.debug(this, "totRimanenzaBenz: "+totRimanenzaBenz);
  htmpl.set("totRimanenzaGas",""+totRimanenzaGas);
  htmpl.set("totRimanenzaBenz",""+totRimanenzaBenz);
  //061029 - Carburante x serra - End

  /*if(request.getParameter("consumoContoProprioGas") == null
     && request.getParameter("consumoContoProprioBenz")==null)
  {
    htmpl.set("consumoContoProprioGas",""+totaleGas);
    htmpl.set("consumoContoProprioBenz",""+totaleBenz);
  }
  else
  {
    htmpl.set("consumoContoProprioGas",""+consumoContoProprioGas);
    htmpl.set("consumoContoProprioBenz",""+consumoContoProprioBenz);
  }*/

  //Valorizzazione Consumi in base al tipo Conduzione Ditta - Begin
  long idConduzione;
  SolmrLogger.debug(this,"dittaVO.getIdConduzione() != null");
  idConduzione = new Long (dittaVO.getIdConduzione()).longValue();

  if(request.getParameter("consumoContoProprioGas") == null
       && request.getParameter("consumoContoProprioBenz")==null)
  {
      SolmrLogger.debug(this,"\n\n\n******************************************");
      SolmrLogger.debug(this,"request.getParameter(\"consumoContoProprioGas\") == null || "+
                         "request.getParameter(\"consumoContoProprioBenz\") == null");

      if (dittaVO.getIdConduzione() == null){
        //Nel caso in cui il tipo conduzione non sia impostato,
        // lo assume come conto proprio
        SolmrLogger.debug(this,"dittaVO.getIdConduzione() == null");
        idConduzione = 1;
      }

      SolmrLogger.debug(this,"totaleGas: "+totaleGas);
      SolmrLogger.debug(this,"totaleBenz: "+totaleBenz);
      // Primo Caricamento della pagina
      if ( idConduzione == new Long(""+SolmrConstants.get("IDCONDUZIONECONTOPROPRIO")).longValue()
        || idConduzione == new Long(""+SolmrConstants.get("IDCONDUZIONECONTOPROPRIOETERZI")).longValue()
      )
      {
        //Valorizzo il conto proprio se la conduzione è conto Proprio
        //  o conto Proprio e Terzi
        SolmrLogger.debug(this,"Primo caricamento pagina - Conto Proprio");
        
        // SMRUMA-717
        // consumoContoTerziGas = 0;
        consumoContoTerziGas = umaFacadeClient.selectConsumoContoTerzi(idDittaUma);
        consumoContoTerziBenz = 0;
        
        consumoContoProprioGas = totaleNonSerraGas - consumoContoTerziGas;
        consumoContoProprioBenz = totaleNonSerraBenz - consumoContoTerziBenz;
        
        htmpl.set("consumoContoProprioGas",""+consumoContoProprioGas);
        htmpl.set("consumoContoProprioBenz",""+consumoContoProprioBenz);
        htmpl.set("consumoContoTerziGas",""+consumoContoTerziGas);
        htmpl.set("consumoContoTerziBenz",""+consumoContoTerziBenz);
      }
      else
      {
        SolmrLogger.debug(this,"Primo caricamento pagina - Conto Terzi");
        consumoContoProprioGas = 0;
        consumoContoProprioBenz = 0;
        consumoContoTerziGas = totaleNonSerraGas;
        consumoContoTerziBenz = totaleNonSerraBenz;
        htmpl.set("consumoContoProprioGas",""+consumoContoProprioGas);
        htmpl.set("consumoContoProprioBenz",""+consumoContoProprioBenz);
        htmpl.set("consumoContoTerziGas",""+consumoContoTerziGas);
        htmpl.set("consumoContoTerziBenz",""+consumoContoTerziBenz);
      }

      //061029 - Carburante x serra - Begin
      consumoSerraGas = totaleSerraGas;
      consumoSerraBenz = totaleSerraBenz;
      htmpl.set("consumoSerraGas",""+consumoSerraGas);
      htmpl.set("consumoSerraBenz",""+consumoSerraBenz);

      totConsumoGas = consumoContoProprioGas + consumoContoTerziGas + consumoSerraGas;
      totConsumoBenz = consumoContoProprioBenz + consumoContoTerziBenz + consumoSerraBenz;
      SolmrLogger.debug(this, "totConsumoGas: "+totConsumoGas);
      SolmrLogger.debug(this, "totConsumoBenz: "+totConsumoBenz);
      htmpl.set("totConsumoGas",""+totConsumoGas);
      htmpl.set("totConsumoBenz",""+totConsumoBenz);
      //061029 - Carburante x serra - End
    }
  else
  {
    // Caricamenti della pagina successivi al primo
    SolmrLogger.debug(this,"Caricamenti successivi al primo");

    htmpl.set("consumoContoProprioGas",""+consumoContoProprioGas);
    htmpl.set("consumoContoProprioBenz",""+consumoContoProprioBenz);
    htmpl.set("consumoContoTerziGas",""+consumoContoTerziGas);
    htmpl.set("consumoContoTerziBenz",""+consumoContoTerziBenz);
    //061029 - Carburante x serra - Begin
    htmpl.set("consumoSerraGas",""+consumoSerraGas);
    htmpl.set("consumoSerraBenz",""+consumoSerraBenz);

    totConsumoGas = consumoContoProprioGas + consumoContoTerziGas + consumoSerraGas;
    totConsumoBenz = consumoContoProprioBenz + consumoContoTerziBenz + consumoSerraBenz;
    SolmrLogger.debug(this, "totConsumoGas: "+totConsumoGas);
    SolmrLogger.debug(this, "totConsumoBenz: "+totConsumoBenz);
    htmpl.set("totConsumoGas",""+totConsumoGas);
    htmpl.set("totConsumoBenz",""+totConsumoBenz);
    //061029 - Carburante x serra - End
  }


  //Imposta il tipo conduzione per il JavaScript di calcolo automatico dei consumi
  htmpl.set("tipoConduzione",""+idConduzione);
  //Valorizzazione Consumi in base al tipo Conduzione Ditta - End
  htmpl.set("dataDocumentazione",dataDocumentazione);
  //htmpl.set("numeroDocumenti",numeroDocumenti);

  if(!numeroDocumenti.equals("") && !numeroDocumenti.equals("0"))
    htmpl.set("numeroDocumenti", ""+numeroDocumenti);
  else htmpl.set("numeroDocumenti", "");

  htmpl.set("dataCessazioneAttivita",dataCessazioneAttivita);
  htmpl.set("provincia",provincia);
  //htmpl.set("numeroDittaUma",""+numeroDittaUma);

  if(!numeroDittaUma.equals("") && !numeroDittaUma.equals("0"))
    htmpl.set("numeroDittaUma", ""+numeroDittaUma);
  else htmpl.set("numeroDittaUma", "");

  htmpl.set("tipiIntermediario",request.getParameter("tipiIntermediario"));
  htmpl.set("dataRicevutaDocumenti",request.getParameter("dataRicevutaDocumenti"));
  htmpl.set("numeroRicevutaDocumenti",request.getParameter("numeroRicevutaDocumenti"));
  //SolmrLogger.debug(this, "exception: "+exception);
  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
%>
<%= htmpl.text()%><%!
 public String trimToUpper(String value)
 {
  return value==null?null:value.trim().toUpperCase();
 }
%>