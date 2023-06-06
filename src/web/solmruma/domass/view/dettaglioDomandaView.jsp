<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>

<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.dto.comune.IntermediarioVO" %>

<%
    SolmrLogger.debug(this,"dettaglioDomandaView");
    String layoutUrl = "/domass/layout/dettaglioDomanda.htm";
    ValidationException valEx;
    Validator validator = new Validator(layoutUrl);
    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
    Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layoutUrl);
    // A causa del fatto che questa pagina ha il menu della assegnazione base
    // ma è inserita nel CU del dettaglio azienda (che è di pertinenza di un
    // altro menu) viene cambiata al volo la classe Autorizzazione per
    // permettere l'utilizzo del gestore di menu corretto.
    it.csi.solmr.presentation.security.Autorizzazione autAssegnazioneBase=
    (it.csi.solmr.presentation.security.Autorizzazione)
    it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ASSEGNAZIONE_BASE");
    request.setAttribute("__autorizzazione",autAssegnazioneBase);
%><%@include file = "/include/menu.inc" %><%    SolmrLogger.info(this, "Found layout: "+layoutUrl);

    UmaFacadeClient umaClient = new UmaFacadeClient();

    DomandaAssegnazione da = (DomandaAssegnazione) request.getAttribute("DomandaAssegnazione");
    DittaUMAVO du = (DittaUMAVO) request.getAttribute("DittaUMAVO");

    UtenteIrideVO utenteIrideVO = (UtenteIrideVO) request.getAttribute("utenteIrideVO");
    UtenteIrideVO utenteAggiornamentoIrideVO = (UtenteIrideVO) request.getAttribute("utenteAggiornamentoIrideVO");

    DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

    it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
    //this.errErrorValExc(htmpl,request,exception);
    HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

    StoricoAssegnazioniVO stor;

    htmpl.set("annoDiRiferimento", ""+DateUtils.getCurrentYear());

    Long idDomAss=null;
    if( request.getParameter("idDomAss")!=null )
    {
      SolmrLogger.debug(this,"\n\n\n\n*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*");
      SolmrLogger.debug(this,"if( request.getParameter(\"idDomAss\")!=null )");
      idDomAss = new Long(request.getParameter("idDomAss"));
    }else
    if( request.getAttribute("idDomAss")!=null )
    {
      SolmrLogger.debug(this,"\n\n\n\n*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*");
      SolmrLogger.debug(this,"if( request.getAttribute(\"idDomAss\")!=null )");
      idDomAss = new Long((String) request.getAttribute("idDomAss"));
    }
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

    if ( da!=null )
    {
      SolmrLogger.debug(this,"da!=null");
      //hidden
      htmpl.set("idDomAss", ""+da.getIdDomandaAssegnazione() );
      //Inizio pagina
      htmpl.set("statoDomAss", da.getStatoDomanda().getDescription() ); //anche hidden
      htmpl.set("dataCreazioneDomAss", "" + formatDate(da.getDataRiferimento()) );
      htmpl.set("dataTrasmisDomAss", "" + formatDate(da.getDataTrasmissione() ));
      htmpl.set("dataRicezioneDomAss", "" + formatDate(da.getDataRicevutaDocumenti()) );
      long numeroRicevutaDocumentiLong=da.getNumeroRicevutaDocumenti()==null?0:da.getNumeroRicevutaDocumenti().longValue();
      String numeroRicevutaDocumenti=numeroRicevutaDocumentiLong==0?null:""+numeroRicevutaDocumentiLong;
      htmpl.set("numProtDomAss", numeroRicevutaDocumenti );
      htmpl.set("dataValidazDomAss", "" + formatDate(da.getDataValidazione()) );
      //Fine pagina
      String numeroDocumenti=da.getNumeroDocumenti()==0?null:""+da.getNumeroDocumenti();
      htmpl.set("numDocDomAss", numeroDocumenti);
      htmpl.set("dataDocDomAss", "" + formatDate(da.getDataDocumentazione()) );
      htmpl.set("motAnnullRifDomAss", da.getNote() );
      htmpl.set("ultimaModDomAss", "" + formatDate(da.getDataAggiornamento()) );
      if(da.getExtIdIntermediarioDocCarta() != null && !"".equalsIgnoreCase(da.getExtIdIntermediarioDocCarta().toString().trim()))
      {
        String intermediarioCarta = umaClient.getDenominazioneIntermediario(da.getExtIdIntermediarioDocCarta());
        if(intermediarioCarta != null)
        htmpl.set("nomeIntermediarioDocCarta", intermediarioCarta);
      }
    }
    else{
      SolmrLogger.debug(this,"da==null");
    }

    if ( du!=null )
    {
      SolmrLogger.debug(this,"du!=null");
      //hidden
      htmpl.set("idDittaUma", ""+du.getIdDitta() );
      //Metà pagina
      htmpl.set("tipoConduzDittaUma", du.getDescTipoConduzione() );
      htmpl.set("comPrincDittaUma",  du.getComune() );
      htmpl.set("indConsCarbDittaUma", du.getIndirizzoConsegna() );
      htmpl.set("noteDittaUma", du.getNoteDitta() );
    }
    else{
      SolmrLogger.debug(this,"du==null");
    }

    SolmrLogger.debug(this,"\n\n\n\n\n-------------------------");
    if (utenteIrideVO!=null)
    {
      SolmrLogger.debug(this,"if utenteIrideVO!=null");
      SolmrLogger.debug(this,"utenteIrideVO.getDenominazione(): "+utenteIrideVO.getDenominazione());
      htmpl.set("denominazioneIntermediario",utenteIrideVO.getDenominazione());
      if ( utenteIrideVO.getDescrizioneEnteAppartenenza()!=null ){
        SolmrLogger.debug(this,"if utenteIrideVO.getDescrizioneEnteAppartenenza()!=null");
        SolmrLogger.debug(this,"utenteIrideVO.getDescrizioneEnteAppartenenza(): "+utenteIrideVO.getDescrizioneEnteAppartenenza());
        htmpl.set("enteIntermediario"," - "+utenteIrideVO.getDescrizioneEnteAppartenenza());
      }
    }
    else{
      SolmrLogger.debug(this,"else utenteIrideVO!=null");
    }

    // Aggiunta Andrea 24/11/2006 per CU-GUMA-20 (elenco assegnazioni effettuate)
    if(da.getDataValidazione()!=null){
      if(da.getExtIdIntermediarioValida() == null) {
        htmpl.set("validatore", "Ufficio UMA Provinciale");
      }
      else {
        IntermediarioVO intermediarioVO = (IntermediarioVO)request.getAttribute("intermediarioVOValida");
        String cf = intermediarioVO.getCodiceFiscale();
        String de = intermediarioVO.getDenominazione();
        if(cf == null) {
          cf = "";
        }
        if(de == null) {
          de = "";
        }
        htmpl.set("validatore", cf + " - " + de);
      }
    }


    if (utenteAggiornamentoIrideVO!=null)
    {
      htmpl.newBlock("blk_utenteAgg");
      htmpl.set("blk_utenteAgg.nomeUtenteAggiornamento",utenteAggiornamentoIrideVO.getDenominazione());
      if ( utenteAggiornamentoIrideVO.getDescrizioneEnteAppartenenza()!=null ){
        htmpl.set("blk_utenteAgg.enteUtenteAggiornamento"," - "+utenteAggiornamentoIrideVO.getDescrizioneEnteAppartenenza());
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
%>
