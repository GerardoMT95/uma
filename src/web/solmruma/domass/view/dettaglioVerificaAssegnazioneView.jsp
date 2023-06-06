
<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@page import="it.csi.solmr.etc.SolmrConstants"%>

<%
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("domass/layout/dettaglioVerificaAssegnazione.htm");
    // A causa del fatto che questa pagina ha il menu della assegnazione base
    // ma è inserita nel CU del dettaglio azienda (che è di pertinenza di un
    // altro menu) viene cambiata al volo la classe Autorizzazione per
    // permettere l'utilizzo del gestore di menu corretto.
    it.csi.solmr.presentation.security.Autorizzazione autAssegnazioneBase=
    (it.csi.solmr.presentation.security.Autorizzazione)
    it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ASSEGNAZIONE_BASE");
    request.setAttribute("__autorizzazione",autAssegnazioneBase);
%><%@include file = "/include/menu.inc" %><%


  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

  Vector assegnazioniCarburante=(Vector)request.getAttribute("assegnazioniCarburante");
  Vector consumiRimanenze=(Vector)request.getAttribute("consumiRimanenze");
  Vector utentiIride=(Vector)request.getAttribute("utentiIride");
  Vector utentiIrideConsRim=(Vector)request.getAttribute("utentiIrideConsRim");

  int iSize=consumiRimanenze==null?0:consumiRimanenze.size();
  ConsumoRimanenzaVO crVO = null;

  htmpl.set("annoDiRiferimento", ""+DateUtils.getCurrentYear());

  Long idDomAss=null;
  if( request.getParameter("idDomAss")!=null )
  {
    idDomAss = new Long(request.getParameter("idDomAss"));
  }else
  if( request.getAttribute("idDomAss")!=null )
  {
    idDomAss = new Long((String) request.getAttribute("idDomAss"));
  }
  DomandaAssegnazione domAss = null;
  if(idDomAss!=null)
  {
    SolmrLogger.debug(this,"if(idDomAss!=null)");
    domAss = umaClient.findDomAssByPrimaryKey(idDomAss);
    if(domAss.getDataRiferimento()!=null){
      htmpl.set("annoDomandaAssegnazione", ""+DateUtils.extractYearFromDate(domAss.getDataRiferimento()));
    }
    if (domAss.getDataProtocolloFurto()!=null)
    {
      htmpl.newBlock("blkFurto");
      htmpl.set("blkFurto.dataProtocolloDenFurto", DateUtils.formatDate(domAss.getDataProtocolloFurto()));
      htmpl.set("blkFurto.numProtocolloDenFurto", domAss.getNumProtocolloDenFurto());
      htmpl.set("blkFurto.estremiDenFurto", domAss.getEstremiDenFurto());
    }
  }

  for(int i=0;i<iSize;i++)
  {
    htmpl.newBlock("blkConsumiRimanenze");
    crVO=(ConsumoRimanenzaVO)consumiRimanenze.get(i);
    htmpl.set("blkConsumiRimanenze.descCarburante",""+crVO.getDescCarburante());
    htmpl.set("blkConsumiRimanenze.consContoProp",""+crVO.getConsContoProp());
    htmpl.set("blkConsumiRimanenze.consContoTer",""+crVO.getConsContoTer());
    htmpl.set("blkConsumiRimanenze.consSerra",""+crVO.getConsSerra());
    htmpl.set("blkConsumiRimanenze.rimContoProp",""+crVO.getRimContoProp());
    htmpl.set("blkConsumiRimanenze.rimContoTer",""+crVO.getRimContoTer());
    htmpl.set("blkConsumiRimanenze.rimSerra",""+crVO.getRimSerra());
    htmpl.set("blkConsumiRimanenze.totale",""+(crVO.getConsContoProp().longValue()+
        crVO.getConsContoTer().longValue()+
        crVO.getConsSerra().longValue()+
        crVO.getRimContoProp().longValue()+
        crVO.getRimContoTer().longValue()+
        crVO.getRimSerra().longValue()));
    if (crVO.getCarburanteRubato()!=null && crVO.getCarburanteRubato().longValue()!=0)    
    {
      if (it.csi.solmr.etc.SolmrConstants.ID_BENZINA.equals(crVO.getIdCarburante().toString()))
      {
        htmpl.newBlock("blkFurto.blkbenzina");
        htmpl.set("blkFurto.blkbenzina.benzinaOggettoFurto", crVO.getCarburanteRubato().toString());    
      }
      if (it.csi.solmr.etc.SolmrConstants.ID_GASOLIO.equals(crVO.getIdCarburante().toString()))
      {
        htmpl.newBlock("blkFurto.blkgasolio");
        htmpl.set("blkFurto.blkgasolio.gasolioOggettoFurto", crVO.getCarburanteRubato().toString());      
      }
    }    
  }
  if (iSize!=0)
  {
    htmpl.newBlock("blkConsumiRimanenzeBlk1");
    htmpl.newBlock("blkConsumiRimanenzeBlk2");
  }
  UtenteIrideVO utenteIrideVO;
  //Data Aggiornamento e Utente della tabella Consumi e Rimanenze
  if (crVO != null)
  {
    htmpl.set("dataAggConsRim",""+formatDate(crVO.getDataAgg()));
    utenteIrideVO= utentiIrideConsRim==null?null:(UtenteIrideVO)utentiIrideConsRim.get(0);
    if (utenteIrideVO!=null)
    {
      htmpl.set("blkConsumiRimanenzeBlk2.denominazioneUtenteConsRim",utenteIrideVO.getDenominazione());
      htmpl.set("blkConsumiRimanenzeBlk2.descrizioneEnteConsRim",utenteIrideVO.getDescrizioneEnteAppartenenza());
    }
  }

  htmpl.set("statoDomAss",request.getParameter("statoDomAss"));
  htmpl.set("idDomAss",request.getParameter("idDomAss"));
  htmpl.set("idDittaUma",request.getParameter("idDittaUma"));
  if (assegnazioniCarburante!=null && assegnazioniCarburante.size()==1)
  {
    AssegnazioneCarburanteAggrVO acaVO=(AssegnazioneCarburanteAggrVO) assegnazioniCarburante.get(0);
    AssegnazioneCarburanteVO acVO=acaVO.getAssegnazioneCarburante();
    FogliRigaVO frVO=acaVO.getFoglioRiga();
    htmpl.set("dataAssegnazione",""+formatDate(acVO.getDataAssegnazione()));
    if (frVO!=null)
    {
      htmpl.set("foglioRiga", composeString(""+frVO.getNumeroFoglio(), ""+frVO.getNumeroRiga(), "/"));

      htmpl.set("dataStampa",""+formatDate(frVO.getDataStampa()));
    }
    htmpl.set("dataAgg",""+formatDate(acVO.getDataAgg()));

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
    htmpl.set("datiProtocolloIntermediario", dati);
    // Fine Aggiunta

    utenteIrideVO= utentiIride==null?null:(UtenteIrideVO)utentiIride.get(0);
    if (utenteIrideVO!=null)
    {
      htmpl.set("denominazioneUtente",utenteIrideVO.getDenominazione());
      htmpl.set("descrizioneEnte",utenteIrideVO.getDescrizioneEnteAppartenenza());
    }
    Vector qa=acaVO.getQuantitaAssegnata();
    int jSize=qa==null?0:qa.size();
    for(int j=0;j<jSize;j++)
    {
      QuantitaAssegnataVO qaVO=(QuantitaAssegnataVO) qa.get(j);
      htmpl.newBlock("blkQuantitaAssegnata");
      htmpl.set("blkQuantitaAssegnata.descCarburante",qaVO.getDescCarburante());
      htmpl.set("blkQuantitaAssegnata.assContoProp",""+qaVO.getAssContoProp());
      htmpl.set("blkQuantitaAssegnata.assContoTer",""+qaVO.getAssContoTer());
      htmpl.set("blkQuantitaAssegnata.assSerra",""+qaVO.getAssSerra());
      htmpl.set("blkQuantitaAssegnata.totale",""+(qaVO.getAssContoProp().longValue()+qaVO.getAssContoTer().longValue()+qaVO.getAssSerra().longValue()));
    }
    if (jSize!=0)
    {
      htmpl.newBlock("blkQuantitaAssegnataBlk1");
      htmpl.newBlock("blkQuantitaAssegnataBlk2");
    }
  }


/****************************************** ACCONTO *******************************************************/
  Vector assegnazioneAcconto = (Vector)request.getAttribute("assegnazioneAcconto");
  DomandaAssegnazione acconto = (DomandaAssegnazione) request.getAttribute("acconto");
  if (acconto!=null)
  {
    htmpl.set("accontoStatoDomAss",acconto.getStatoDomanda().getDescription());
  }
  else
  {
  	htmpl.set("accontoStatoDomAss",SolmrConstants.DESCRIZIONE_STATO_ACCONTO_NON_PRESENTE);
  }
  if (assegnazioneAcconto!=null && assegnazioneAcconto.size()==1)
  {
    AssegnazioneCarburanteAggrVO acaVO=(AssegnazioneCarburanteAggrVO) assegnazioneAcconto.get(0);
    AssegnazioneCarburanteVO acVO=acaVO.getAssegnazioneCarburante();
    FogliRigaVO frVO=acaVO.getFoglioRiga();
    htmpl.set("accontoDataAssegnazione",""+formatDate(acVO.getDataAssegnazione()));
    if (frVO!=null)
    {
      htmpl.set("accontoFoglioRiga", composeString(""+frVO.getNumeroFoglio(), ""+frVO.getNumeroRiga(), "/"));

      htmpl.set("accontoDataStampa",""+formatDate(frVO.getDataStampa()));
    }
    htmpl.set("accontoDataAgg",""+formatDate(acVO.getDataAgg()));

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
    htmpl.set("accontoDatiProtocolloIntermediario", dati);
    // Fine Aggiunta

    UtenteIrideVO accontoUtenteIrideVO=(UtenteIrideVO)request.getAttribute("accontoUtenteIrideVO");
    if (accontoUtenteIrideVO!=null)
    {
      htmpl.set("accontoDenominazioneUtente",accontoUtenteIrideVO.getDenominazione());
      htmpl.set("accontoDescrizioneEnte",accontoUtenteIrideVO.getDescrizioneEnteAppartenenza());
    }
    Vector qa=acaVO.getQuantitaAssegnata();
    int jSize=qa==null?0:qa.size();
    for(int j=0;j<jSize;j++)
    {
      QuantitaAssegnataVO qaVO=(QuantitaAssegnataVO) qa.get(j);
      htmpl.newBlock("blkAccontoQuantitaAssegnata");
      htmpl.set("blkAccontoQuantitaAssegnata.descCarburante",qaVO.getDescCarburante());
      htmpl.set("blkAccontoQuantitaAssegnata.assContoProp",""+qaVO.getAssContoProp());
      htmpl.set("blkAccontoQuantitaAssegnata.assContoTer",""+qaVO.getAssContoTer());
      htmpl.set("blkAccontoQuantitaAssegnata.assSerra",""+qaVO.getAssSerra());
      htmpl.set("blkAccontoQuantitaAssegnata.totale",""+(qaVO.getAssContoProp().longValue()+qaVO.getAssContoTer().longValue()+qaVO.getAssSerra().longValue()));
    }
    if (jSize!=0)
    {
      htmpl.newBlock("blkAccontoQuantitaAssegnataBlk");
    }
  }


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
        result += " "+separator+" "+second;
    }
    else if(!"".equals(second) && second != null)
      result = second;
    return result;
  }
%>
