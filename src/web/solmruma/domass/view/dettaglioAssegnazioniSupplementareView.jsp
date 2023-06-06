
<%@page import="it.csi.solmr.util.DateUtils"%>
<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="java.text.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/domass/layout/dettaglioAssegnazioniSupplementare.htm");
    // A causa del fatto che questa pagina ha il menu della assegnazione base
    // ma è inserita nel CU del dettaglio azienda (che è di pertinenza di un
    // altro menu) viene cambiata al volo la classe Autorizzazione per
    // permettere l'utilizzo del gestore di menu corretto.
    it.csi.solmr.presentation.security.Autorizzazione autAssegnazioneBase=
    (it.csi.solmr.presentation.security.Autorizzazione)
    it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ASSEGNAZIONE_BASE");
    request.setAttribute("__autorizzazione",autAssegnazioneBase);
%><%@include file = "/include/menu.inc" %><%

  SolmrLogger.debug(this, "   BEGIN dettaglioAssegnazioniSupplmentareView");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
  Vector assegnazioniCarburante=(Vector)request.getAttribute("assegnazioniCarburante");
  Vector utentiIride=(Vector)request.getAttribute("utentiIride");

  final String msgAssAnnullata="ANNULLATO";
  int iSize=assegnazioniCarburante==null?0:assegnazioniCarburante.size();
  //Non stato domanda assegnazione, ma stato assegnazione carburante

  /*SolmrLogger.debug(this,"#################################################################");
  SolmrLogger.debug(this,"dettaglioAssegnazioniSupplementareView - idAssCarb "+idAssCarb);
  SolmrLogger.debug(this,"#################################################################");*/

  htmpl.set("statoDomAss",request.getParameter("statoDomAss"));
  Long idDomAss=null;
  if( request.getParameter("idDomAss")!=null ){
    SolmrLogger.debug(this,"\n\n\n\n*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*");
    SolmrLogger.debug(this,"if( request.getParameter(\"idDomAss\")!=null )");
    idDomAss = new Long(request.getParameter("idDomAss"));
  }else
  if( request.getAttribute("idDomAss")!=null ){
    SolmrLogger.debug(this,"\n\n\n\n*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*");
    SolmrLogger.debug(this,"if( request.getAttribute(\"idDomAss\")!=null )");
    idDomAss = new Long((String) request.getAttribute("idDomAss"));
  }

  htmpl.set("idDomAss",""+idDomAss);
  htmpl.set("idDittaUma",request.getParameter("idDittaUma"));

  htmpl.set("annoDiRiferimento", ""+DateUtils.getCurrentYear());

  DomandaAssegnazione domAss = null;
  if(idDomAss!=null)
  {
    SolmrLogger.debug(this,"\n\n\n\n-+-+-+-+-+-+-+-+-+-+-+-+-+-+");
    SolmrLogger.debug(this,"if(idDomAss!=null)");
    domAss = umaClient.findDomAssByPrimaryKey(idDomAss);
    if(domAss.getDataRiferimento()!=null){
      htmpl.set("annoDomandaAssegnazione", ""+DateUtils.extractYearFromDate(domAss.getDataRiferimento()));
    }
  }
  
  // Recupero il valore letto da DB_PARAMETRO
  String dataInizioNuovoDettCalcAssSuppl = (String)request.getAttribute("dataInizioNuovoDettCalcAssSuppl");
  SolmrLogger.debug(this, "--- dataInizioNuovoDettCalcAssSuppl ="+dataInizioNuovoDettCalcAssSuppl);
  DateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
  Date dataInizioNuovoDettCalcAssSupplD = df.parse(dataInizioNuovoDettCalcAssSuppl);
  SolmrLogger.debug(this, "--- dataInizioNuovoDettCalcAssSupplD ="+dataInizioNuovoDettCalcAssSupplD);
 
  for(int i=0;i<iSize;i++){
    htmpl.newBlock("blkAssegnazione");
    AssegnazioneCarburanteAggrVO acaVO=(AssegnazioneCarburanteAggrVO) assegnazioniCarburante.get(i);
    AssegnazioneCarburanteVO acVO=acaVO.getAssegnazioneCarburante();
    FogliRigaVO frVO=acaVO.getFoglioRiga();
    SolmrLogger.debug(this,"\n\n\n**************************************");
    SolmrLogger.debug(this,"acVO.getAnnullato(): " + acVO.getAnnullato());
    
    htmpl.set("blkAssegnazione.idAssCarb", ""+acVO.getIdAssegnazioneCarburante());
    SolmrLogger.debug("dettaglioAssegnazioniSupplementareView", " --------- ID_ASSEGNAZIONE_CARBURANTE ="+acVO.getIdAssegnazioneCarburante());    
    
    // Controllo se per il dettaglio calcolo deve essere visualizzato il vecchio o il nuovo layout
    String layoutDettCalcolo ="";    
    Date dataAssegnazioneSuppl = acVO.getDataAssegnazione();
    SolmrLogger.debug(this," --- dataAssegnazioneSuppl ="+dataAssegnazioneSuppl);
    SolmrLogger.debug(this, "--- dataInizioNuovoDettCalcAssSupplD ="+dataInizioNuovoDettCalcAssSupplD);
    if(dataAssegnazioneSuppl.after(dataInizioNuovoDettCalcAssSupplD)){
      layoutDettCalcolo = "../layout/dettaglioCalcoloAssSuppl.htm";
    }
    else{
      layoutDettCalcolo = "../layout/carburanteAssegnabile.htm";
    }
    SolmrLogger.debug(this, "--- layoutDettCalcolo ="+layoutDettCalcolo);
    htmpl.set("blkAssegnazione.nameParLayout", ""+acVO.getIdAssegnazioneCarburante()+"_tipoLayout");
    htmpl.set("blkAssegnazione.tipoLayout",layoutDettCalcolo);
    
    
    htmpl.set("blkAssegnazione.numSupplemento",""+acVO.getNumSupplemento());
    SolmrLogger.debug(this, " --------- NUMERO_SUPPLEMENTO ="+acVO.getNumSupplemento());
    htmpl.set("blkAssegnazione.dataAssegnazione",""+formatDate(acVO.getDataAssegnazione()));
    htmpl.set("blkAssegnazione.descSupplemento",acVO.getDescSupplemento());
    htmpl.set("blkAssegnazione.motivazSupplemento",acVO.getMotivazSupplemento());

    UtenteIrideVO intermediario = null;
    if(acVO.getExtIdIntermediarioLong() != null && acVO.getExtIdIntermediarioLong().longValue() != 0)
    {
      SolmrLogger.debug(this,"@@@@@@@@@@@@@@@@@@@@@@@@@@@@ acVO.getExtIdIntermediarioLong() : "+ acVO.getExtIdIntermediarioLong());
      intermediario = umaClient.getUtenteIride(acVO.getExtIdIntermediarioLong());
    }

    if (intermediario!=null)
    {
      htmpl.set("blkAssegnazione.IntermediarioRichiesta",composeString(intermediario.getDenominazione(), intermediario.getDescrizioneEnteAppartenenza(), "-"));
    }

    SolmrLogger.debug(this,"#############################################################");
    SolmrLogger.debug(this,"dettaglioAssegnazioniSupplementareView : statoAssegnazione : "+acVO.getStatoAssegnazione());
    SolmrLogger.debug(this,"dettaglioAssegnazioniSupplementareView : getDataValidazioneSuppl : "+acVO.getDataValidazioneSuppl());
    SolmrLogger.debug(this,"dettaglioAssegnazioniSupplementareView : getDataValidazioneSupplDate : "+acVO.getDataValidazioneSupplDate());
    SolmrLogger.debug(this,"dettaglioAssegnazioniSupplementareView : noteIstruttoria-motivo rifiuto : "+acVO.getNoteIstruttoria());
    SolmrLogger.debug(this,"#############################################################");
    htmpl.set("blkAssegnazione.statoAssegnazione", acVO.getStatoAssegnazione());
    htmpl.set("blkAssegnazione.noteIstruttoria", acVO.getNoteIstruttoria());

    // Aggiunta di Andrea 30/11/2006 - Per CU-GUMA-20
    Date dataProtInt = acVO.getDataProtocolloDate();
    String numProtInt = acVO.getNumeroProtocollo();
    String dati = "";
    if(dataProtInt != null) {
      dati = dati + formatDate(dataProtInt);
      if(numProtInt != null) {
        dati = dati + " - " + numProtInt;
      }
    }
    htmpl.set("blkAssegnazione.datiProtocolloIntermediario", dati);
    // Fine Aggiunta

    htmpl.set("blkAssegnazione.dataValidazioneUMA",acVO.getDataValidazioneSuppl());
    htmpl.set("blkAssegnazione.dataRicezioneDocumenti",acVO.getDataRicevutaDocumenti());
    SolmrLogger.debug(this,"\n\n\n--------------------");
    SolmrLogger.debug(this,"acVO.getNumeroRicevutaDocumentiLong(): "+acVO.getNumeroRicevutaDocumentiLong());
    if( acVO.getNumeroRicevutaDocumentiLong().longValue()!=0 )
    {
      SolmrLogger.debug(this,"if( acVO.getNumeroRicevutaDocumentiLong().longValue()!=0 )");
      htmpl.set("blkAssegnazione.numeroProtocolloDocumenti",acVO.getNumeroRicevutaDocumenti());
    }

    if (frVO!=null)
    {
      htmpl.set("blkAssegnazione.numeroFoglioRiga", composeString(frVO.getNumeroFoglio().toString().trim(), frVO.getNumeroRiga().toString( ).trim(), "/"));
      htmpl.set("blkAssegnazione.dataStampa",""+formatDate(frVO.getDataStampa()));
    }
    htmpl.set("blkAssegnazione.dataAgg",""+formatDate(acVO.getDataAgg()));
    UtenteIrideVO utenteIrideVO= utentiIride==null?null:(UtenteIrideVO)utentiIride.get(i);
    if (utenteIrideVO!=null)
    {
      htmpl.set("blkAssegnazione.utente",composeString(utenteIrideVO.getDenominazione(), utenteIrideVO.getDescrizioneEnteAppartenenza(), "-"));
    }

    Vector qa=acaVO.getQuantitaAssegnata();
    int jSize=qa==null?0:qa.size();
    for(int j=0;j<jSize;j++)
    {
      QuantitaAssegnataVO qaVO=(QuantitaAssegnataVO) qa.get(j);
      htmpl.newBlock("blkAssegnazione.blkQuantitaAssegnata");
      htmpl.set("blkAssegnazione.blkQuantitaAssegnata.descCarburante",qaVO.getDescCarburante());
      htmpl.set("blkAssegnazione.blkQuantitaAssegnata.assContoProp",""+qaVO.getAssContoProp());
      htmpl.set("blkAssegnazione.blkQuantitaAssegnata.assContoTer",""+qaVO.getAssContoTer());
      htmpl.set("blkAssegnazione.blkQuantitaAssegnata.assSerra",""+qaVO.getAssSerra());
      htmpl.set("blkAssegnazione.blkQuantitaAssegnata.totale",""+(qaVO.getAssContoProp().longValue()+qaVO.getAssContoTer().longValue()+qaVO.getAssSerra().longValue()));
    }
  }
  
  SolmrLogger.debug(this, "   END dettaglioAssegnazioniSupplmentareView");
  
  out.print(htmpl.text());
%>
<%!
  private String formatDate(java.util.Date date)
  {
    if (date==null)
    {
      return "";
    }
    return DateUtils.formatDate(date);
  }
  private String composeString(String first, String second, String separator)
  {
    String result = "";
    if(!"".equals(first) && first != null)
    {
      result = first;
      if(!"".equals(second) && second != null)
        result += " "+separator+" " + second;
    }
    else if(!"".equals(second) && second != null)
      result = second;
    return result;
  }
%>
