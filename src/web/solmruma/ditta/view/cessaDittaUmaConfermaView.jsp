  <%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/ditta/layout/cessaDittaUmaConferma.htm");
%><%@include file = "/include/menu.inc" %><%
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  it.csi.solmr.client.uma.UmaFacadeClient umaFacadeClient = new it.csi.solmr.client.uma.UmaFacadeClient();

  htmpl.set("extCuaaAziendaDest",trimToUpper(request.getParameter("extCuaaAziendaDest")));

  HtmplUtil.setValues(htmpl, request);
  HtmplUtil.setErrors(htmpl, errors, request);

  String denominazione = "";
  String dittaUMA = "";
  String cuaa = "";
  boolean rimanenze = false;

  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

  try{
    denominazione = dittaVO.getDenominazione();
  } catch (Exception exc) {
    SolmrLogger.debug(this, "Qui dentro 5");
  }

  SolmrLogger.debug(this, "cessaDittaUmaConfermaView 22222222222222222222222222");
  try{
    cuaa = dittaVO.getCuaa();
  } catch (Exception exc) {
    SolmrLogger.debug(this, "Qui dentro 7");
  }

  try{
    dittaUMA = dittaVO.getDittaUMAstr();
  } catch (Exception exc) {
  SolmrLogger.debug(this, "Qui dentro 8");
  }

  Long idDittaUma = null;
  try {
    idDittaUma = new Long(""+request.getParameter("idDittaUMA"));
  } catch (Exception exc) {
    SolmrLogger.debug(this, "Qui dentro");
  }

  SolmrLogger.debug(this, "----------------idDittaUma dalla View 2!!!!!! "+idDittaUma);
  Long idDomAss = null;
  try {
    idDomAss = new Long(""+request.getParameter("idDomAss"));
  } catch (Exception exc) {
    SolmrLogger.debug(this, "Qui dento 2");
  }
  SolmrLogger.debug(this, "----------------idDomAss dalla View 2!!!!!!!!"+idDomAss);

  String provCompetenza ="";
  /*if(!dittaVO.getProvCompetenza().equals(""))
    provCompetenza = umaFacadeClient.getProvinciaByIstat(dittaVO.getProvCompetenza());*/

  if(!dittaVO.getProvUMA().equals(""))
    provCompetenza = umaFacadeClient.getProvinciaByIstat(dittaVO.getProvUMA());

  String uma_num = "";

  long annoRif = DateUtils.getCurrentYear().longValue();
  SolmrLogger.debug(this, "cessaDittaUmaConfermaView dopo anno rif");

  Long rimanenzaPrecContoProprioGas = null;
  if(request.getParameter("rimanenzaPrecContoProprioGas")!=null && !request.getParameter("rimanenzaPrecContoProprioGas").equals(""))
    rimanenzaPrecContoProprioGas = new Long(""+request.getParameter("rimanenzaPrecContoProprioGas"));
  else rimanenzaPrecContoProprioGas = new Long("0");

  Long rimanenzaPrecContoProprioBenz = null;
  if(request.getParameter("rimanenzaPrecContoProprioBenz")!=null && !request.getParameter("rimanenzaPrecContoProprioBenz").equals(""))
    rimanenzaPrecContoProprioBenz = new Long(""+request.getParameter("rimanenzaPrecContoProprioBenz"));
  else rimanenzaPrecContoProprioBenz = new Long("0");

  Long rimanenzaPrecContoTerziGas = null;
  if(request.getParameter("rimanenzaPrecContoTerziGas")!=null && !request.getParameter("rimanenzaPrecContoTerziGas").equals(""))
    rimanenzaPrecContoTerziGas = new Long(""+request.getParameter("rimanenzaPrecContoTerziGas"));
  else rimanenzaPrecContoTerziGas = new Long("0");

  Long rimanenzaPrecContoTerziBenz = null;
  if(request.getParameter("rimanenzaPrecContoTerziBenz")!=null && !request.getParameter("rimanenzaPrecContoTerziGas").equals(""))
    rimanenzaPrecContoTerziBenz = new Long(""+request.getParameter("rimanenzaPrecContoTerziBenz"));
  else rimanenzaPrecContoTerziBenz = new Long("0");

  //061029 - Carburante x serra - Begin
  Long rimanenzaPrecSerraGas = null;
  if(request.getParameter("rimanenzaPrecSerraGas")!=null && !request.getParameter("rimanenzaPrecSerraGas").equals("")){
    rimanenzaPrecSerraGas = new Long(""+request.getParameter("rimanenzaPrecSerraGas"));
    if(!request.getParameter("rimanenzaPrecSerraGas").equals("0"))
      rimanenze = true;
  }
  else rimanenzaPrecSerraGas = new Long("0");

  Long rimanenzaPrecSerraBenz = null;
  if(request.getParameter("rimanenzaPrecSerraBenz")!=null && !request.getParameter("rimanenzaPrecSerraBenz").equals("")){
    rimanenzaPrecSerraBenz = new Long(""+request.getParameter("rimanenzaPrecSerraBenz"));
    if(!request.getParameter("rimanenzaPrecSerraBenz").equals("0"))
      rimanenze = true;
  }
  else rimanenzaPrecSerraBenz = new Long("0");
  //061029 - Carburante x serra - End


  //061029 - Carburante x serra - Begin
  /*Long prelevatoGas = null;
  if(request.getParameter("prelevatoGas")!=null && !request.getParameter("prelevatoGas").equals(""))
    prelevatoGas = new Long(""+request.getParameter("prelevatoGas"));
  else prelevatoGas = new Long("0");

  Long prelevatoBenz = null;
  if(request.getParameter("prelevatoBenz")!=null && !request.getParameter("prelevatoBenz").equals(""))
    prelevatoBenz = new Long(""+request.getParameter("prelevatoBenz"));
  else prelevatoBenz = new Long("0");*/

  
  
  //Long prelevatoNonSerraGas = null;
  //Long prelevatoNonSerraBenz = null;
  
  Long prelevatoCPGas = null;
  Long prelevatoCPBenz = null;
  Long prelevatoCTGas = null;
  Long prelevatoCTBenz = null;

  // Conto prorio - gasolio e benzina
  if(request.getParameter("prelevatoCPGas")!=null && !request.getParameter("prelevatoCPGas").equals(""))
	  prelevatoCPGas = new Long(""+request.getParameter("prelevatoCPGas"));
  else prelevatoCPGas = new Long("0");
  
  if(request.getParameter("prelevatoCPBenz")!=null && !request.getParameter("prelevatoCPBenz").equals(""))
	  prelevatoCPBenz = new Long(""+request.getParameter("prelevatoCPBenz"));
  else prelevatoCPBenz = new Long("0");
  
  //Conto terzi - gasolio e benzina
  if(request.getParameter("prelevatoCTGas")!=null && !request.getParameter("prelevatoCTGas").equals(""))
	  prelevatoCTGas = new Long(""+request.getParameter("prelevatoCTGas"));
  else prelevatoCTGas = new Long("0");
  
  if(request.getParameter("prelevatoCTBenz")!=null && !request.getParameter("prelevatoCTBenz").equals(""))
	  prelevatoCTGas = new Long(""+request.getParameter("prelevatoCTBenz"));
  else prelevatoCTGas = new Long("0");
  
  

  Long prelevatoSerraGas = null;
  if(request.getParameter("prelevatoSerraGas")!=null && !request.getParameter("prelevatoSerraGas").equals(""))
    prelevatoSerraGas = new Long(""+request.getParameter("prelevatoSerraGas"));
  else prelevatoSerraGas = new Long("0");

  Long prelevatoSerraBenz = null;
  if(request.getParameter("prelevatoSerraBenz")!=null && !request.getParameter("prelevatoSerraBenz").equals(""))
    prelevatoSerraBenz = new Long(""+request.getParameter("prelevatoSerraBenz"));
  else prelevatoSerraBenz = new Long("0");
  //061029 - Carburante x serra - End

  Long totaleDispGas = null;
  if(request.getParameter("totaleGas")!=null && !request.getParameter("totaleGas").equals(""))
    totaleDispGas = new Long(""+request.getParameter("totaleGas"));
  else totaleDispGas = new Long("0");

  Long totaleDispBenz = null;
  if(request.getParameter("totaleBenz")!=null && !request.getParameter("totaleBenz").equals(""))
    totaleDispBenz = new Long(""+request.getParameter("totaleBenz"));
  else totaleDispBenz = new Long("0");

  Long rimanenzaContoGas = null;
  if(request.getParameter("rimanenzaContoGas")!=null && !request.getParameter("rimanenzaContoGas").equals("")){
    rimanenzaContoGas = new Long(""+request.getParameter("rimanenzaContoGas"));
    if(!request.getParameter("rimanenzaContoGas").equals("0"))
      rimanenze = true;
  }
  else rimanenzaContoGas = new Long("0");

  Long rimanenzaContoBenz = null;
  if(request.getParameter("rimanenzaContoBenz")!=null && !request.getParameter("rimanenzaContoBenz").equals("")){
    rimanenzaContoBenz = new Long(""+request.getParameter("rimanenzaContoBenz"));
    if(!request.getParameter("rimanenzaContoBenz").equals("0"))
      rimanenze = true;
  }
  else rimanenzaContoBenz = new Long("0");

  Long rimanenzaContoTerziGas = null;
  if(request.getParameter("rimanenzaContoTerziGas")!=null && !request.getParameter("rimanenzaContoTerziGas").equals("")){
    rimanenzaContoTerziGas = new Long(""+request.getParameter("rimanenzaContoTerziGas"));
    if(!request.getParameter("rimanenzaContoTerziGas").equals("0"))
      rimanenze = true;
  }
  else rimanenzaContoTerziGas = new Long("0");

  Long rimanenzaContoTerziBenz = null;
  if(request.getParameter("rimanenzaContoTerziBenz")!=null && !request.getParameter("rimanenzaContoTerziBenz").equals("")){
    rimanenzaContoTerziBenz = new Long(""+request.getParameter("rimanenzaContoTerziBenz"));
    if(!request.getParameter("rimanenzaContoTerziBenz").equals("0"))
      rimanenze = true;
  }
  else rimanenzaContoTerziBenz = new Long("0");

  //061029 - Carburante x serra - Begin
  Long rimanenzaSerraGas = null;
  if(request.getParameter("rimanenzaSerraGas")!=null && !request.getParameter("rimanenzaSerraGas").equals("")){
    rimanenzaSerraGas = new Long(""+request.getParameter("rimanenzaSerraGas"));
    if(!request.getParameter("rimanenzaSerraGas").equals("0"))
      rimanenze = true;
  }
  else rimanenzaSerraGas = new Long("0");

  Long rimanenzaSerraBenz = null;
  if(request.getParameter("rimanenzaSerraBenz")!=null && !request.getParameter("rimanenzaSerraBenz").equals("")){
    rimanenzaSerraBenz = new Long(""+request.getParameter("rimanenzaSerraBenz"));
    if(!request.getParameter("rimanenzaSerraBenz").equals("0"))
      rimanenze = true;
  }
  else rimanenzaSerraBenz = new Long("0");
  SolmrLogger.debug(this,"\n\n\n\n\n################################################");
  SolmrLogger.debug(this,"[cessaDittaUmaConfermaView::service] rimanenzaSerraBenz: "+rimanenzaSerraBenz);
  SolmrLogger.debug(this,"################################################\n\n\n\n\n");
  //061029 - Carburante x serra - End

  //061029 - Carburante x serra - Begin
  //Long totCPCTGas = new Long(rimanenzaContoGas.longValue() + rimanenzaContoTerziGas.longValue());
  //Long totCPCTBenz = new Long(rimanenzaContoBenz.longValue() + rimanenzaContoTerziBenz.longValue());
  Long totCPCTGas = new Long(rimanenzaContoGas.longValue() + rimanenzaContoTerziGas.longValue()
                            +rimanenzaSerraGas.longValue());
  Long totCPCTBenz = new Long(rimanenzaContoBenz.longValue() + rimanenzaContoTerziBenz.longValue()
                            +rimanenzaSerraBenz.longValue());
  //061029 - Carburante x serra - End

  Long consumoContoProprioGas = null;
  if(request.getParameter("consumoContoProprioGas")!=null && !request.getParameter("consumoContoProprioGas").equals(""))
    consumoContoProprioGas = new Long(""+request.getParameter("consumoContoProprioGas"));
  else consumoContoProprioGas = new Long("0");

  Long consumoContoProprioBenz = null;
  if(request.getParameter("consumoContoProprioBenz")!=null && !request.getParameter("consumoContoProprioBenz").equals(""))
    consumoContoProprioBenz = new Long(""+request.getParameter("consumoContoProprioBenz"));
  else consumoContoProprioBenz = new Long("0");

  Long consumoContoTerziGas = null;
  if(request.getParameter("consumoContoTerziGas")!=null && !request.getParameter("consumoContoTerziGas").equals(""))
    consumoContoTerziGas = new Long(""+request.getParameter("consumoContoTerziGas"));
  else consumoContoTerziGas = new Long("0");

  Long consumoContoTerziBenz = null;
  if(request.getParameter("consumoContoTerziBenz")!=null && !request.getParameter("consumoContoTerziBenz").equals(""))
    consumoContoTerziBenz = new Long(""+request.getParameter("consumoContoTerziBenz"));
  else consumoContoTerziBenz = new Long("0");

  //061029 - Carburante x serra - Begin
  Long consumoSerraGas = null;
  if(request.getParameter("consumoSerraGas")!=null && !request.getParameter("consumoSerraGas").equals(""))
    consumoSerraGas = new Long(""+request.getParameter("consumoSerraGas"));
  else consumoSerraGas = new Long("0");

  Long consumoSerraBenz = null;
  if(request.getParameter("consumoSerraBenz")!=null && !request.getParameter("consumoSerraBenz").equals(""))
    consumoSerraBenz = new Long(""+request.getParameter("consumoSerraBenz"));
  else consumoSerraBenz = new Long("0");
  //061029 - Carburante x serra - End

  //061029 - Carburante x serra - Begin
  //Long totConsumoCPCTGas = new Long(consumoContoProprioGas.longValue() + consumoContoTerziGas.longValue());
  //Long totConsumoCPCTBenz = new Long(consumoContoProprioBenz.longValue() + consumoContoTerziBenz.longValue());
  Long totConsumoCPCTGas = new Long(consumoContoProprioGas.longValue() + consumoContoTerziGas.longValue()
                                   +consumoSerraGas.longValue());
  Long totConsumoCPCTBenz = new Long(consumoContoProprioBenz.longValue() + consumoContoTerziBenz.longValue()
                                   +consumoSerraBenz.longValue());
  //061029 - Carburante x serra - End

  String dataConsegnaDoc  = request.getParameter("dataDocumentazione");
  Long numeroDocumenti = null;

  if(request.getParameter("numeroDocumenti")!=null && !request.getParameter("numeroDocumenti").equals(""))
    numeroDocumenti = new Long(""+request.getParameter("numeroDocumenti"));

  //else numeroDocumenti = new Long("0");

  String dataCessazioneAttivita = request.getParameter("dataCessazioneAttivita");
  String provincia = request.getParameter("provincia");
  Long numeroDittaUma = null;
  SolmrLogger.debug(this, "prima di numero ditta");
  if(request.getParameter("numeroDittaUma")!=null && !request.getParameter("numeroDittaUma").equals(""))
    numeroDittaUma = new Long(""+request.getParameter("numeroDittaUma"));
  SolmrLogger.debug(this, "numeroDitta: "+numeroDittaUma);

  if(rimanenze)
    htmpl.newBlock("blockFrase");

  htmpl.set("denominazione", denominazione);
  htmpl.set("umaTipoDitta",dittaVO.getTipiDitta());
  htmpl.set("CUAA", cuaa);
  htmpl.set("dittaUMA", dittaUMA);
  htmpl.set("uma_num", uma_num);
  htmpl.set("provinciaCompetenza",provCompetenza);

  htmpl.set("idDittaUMA", ""+idDittaUma);
  htmpl.set("idDomAss", ""+idDomAss);
  htmpl.set("rimPrecCPGas", ""+rimanenzaPrecContoProprioGas);
  htmpl.set("rimPrecCPBenz", ""+rimanenzaPrecContoProprioBenz);
  htmpl.set("rimPrecCTGas", ""+rimanenzaPrecContoTerziGas);
  htmpl.set("rimPrecCTBenz", ""+rimanenzaPrecContoTerziBenz);
  //061031 - Carburante x Serra - Begin
  htmpl.set("rimanenzaPrecSerraGas", ""+rimanenzaPrecSerraGas);
  htmpl.set("rimanenzaPrecSerraBenz", ""+rimanenzaPrecSerraBenz);
  //htmpl.set("prelevatoGas", ""+prelevatoGas);
  //htmpl.set("prelevatoBenz", ""+prelevatoBenz);
  
  
  htmpl.set("prelevatoCPGas", ""+prelevatoCPGas);
  htmpl.set("prelevatoCPBenz", ""+prelevatoCPBenz);
  htmpl.set("prelevatoCTGas", ""+prelevatoCTGas);
  htmpl.set("prelevatoCTBenz", ""+prelevatoCTBenz);
  
  
  
  htmpl.set("prelevatoSerraGas", ""+prelevatoSerraGas);
  htmpl.set("prelevatoSerraBenz", ""+prelevatoSerraBenz);
  //061031 - Carburante x Serra - End

  htmpl.set("totaleDispGas", ""+totaleDispGas);
  htmpl.set("totaleDispBenz", ""+totaleDispBenz);
  htmpl.set("rimAttualeCPGas", ""+rimanenzaContoGas);
  htmpl.set("rimAttualeCPBenz", ""+rimanenzaContoBenz);
  htmpl.set("rimAttualeCTGas", ""+rimanenzaContoTerziGas);
  htmpl.set("rimAttualeCTBenz", ""+rimanenzaContoTerziBenz);
  //061031 - Carburante x Serra - Begin
  htmpl.set("rimanenzaSerraGas", ""+rimanenzaSerraGas);
  htmpl.set("rimanenzaSerraBenz", ""+rimanenzaSerraBenz);
  //061031 - Carburante x Serra - End

  htmpl.set("totaleRimAttualeGas", ""+totCPCTGas);
  htmpl.set("totaleRimAttualeBenz", ""+totCPCTBenz);
  htmpl.set("consumoCPGas", ""+consumoContoProprioGas);
  htmpl.set("consumoCPBenz", ""+consumoContoProprioBenz);
  htmpl.set("consumoCTGas", ""+consumoContoTerziGas);
  htmpl.set("consumoCTBenz", ""+consumoContoTerziBenz);
  //061031 - Carburante x Serra - Begin
  htmpl.set("consumoSerraGas", ""+consumoSerraGas);
  htmpl.set("consumoSerraBenz", ""+consumoSerraBenz);
  //061031 - Carburante x Serra - End

  htmpl.set("totaleConsumoGas", ""+totConsumoCPCTGas);
  htmpl.set("totaleConsumoBenz", ""+totConsumoCPCTBenz);
  htmpl.set("dataConsegnaDoc", ""+dataConsegnaDoc);

  if(numeroDocumenti!=null && numeroDocumenti!=new Long("0"))
    htmpl.set("numDocumenti", ""+numeroDocumenti);
  else htmpl.set("numDocumenti", "");

  htmpl.set("dataCessazioneAtt", ""+dataCessazioneAttivita);
  htmpl.set("provincia", ""+provincia);

  if(numeroDittaUma!=null && numeroDittaUma!=new Long("0"))
    htmpl.set("numDittaUmaConsRim", ""+numeroDittaUma);
  else htmpl.set("numDittaUmaConsRim", "");

  htmpl.set("anno",""+annoRif);
  String denominazioneIntermediario="";
  try
  {
    denominazioneIntermediario=umaFacadeClient.getDenominazioneIntermediario(new Long(request.getParameter("tipiIntermediario")));
  }
  catch(Exception e)
  {
     SolmrLogger.debug(this, "Errore nel reperimento della denominazione dell'intermediario con codice = "+request.getParameter("tipiIntermediario"));
   // Non faccio nulla
  }

  htmpl.set("extIdIntermediarioDocCarta",request.getParameter("tipiIntermediario"));
  htmpl.set("denominazioneIntermediario",denominazioneIntermediario);
  htmpl.set("dataRicevutaDocumenti",request.getParameter("dataRicevutaDocumenti"));
  htmpl.set("numeroRicevutaDocumenti",request.getParameter("numeroRicevutaDocumenti"));
  SolmrLogger.debug(this, "errors: "+errors);
 it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
%>
<%= htmpl.text()%><%!

 public String trimToUpper(String value)
 {
  return value==null?null:value.trim().toUpperCase();
 }
 
%>