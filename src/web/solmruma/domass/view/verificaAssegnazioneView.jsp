
<%@ page language="java" contentType="text/html" isErrorPage="true"%>

<%@ page import="java.util.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza"%>
<jsp:useBean id="frmVerificaAssegnazioneVO" scope="request"
	class="it.csi.solmr.dto.uma.FrmVerificaAssegnazioneVO">
</jsp:useBean>
<%!private static final String CURRENT_PAGE  = "../layout/verificaAssegnazione.htm";
  private static final String READONLY_GRAY = SolmrConstants.HTML_READONLY
                                                + " style='background-color:gray'";%>
<%
  //System.err
      //.println("frmVerificaAssegnazioneVO.getIdDomandaAssegnazionePrecedente()="
        //  + frmVerificaAssegnazioneVO.getIdDomandaAssegnazionePrecedente());
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(
      "domass/layout/verificaAssegnazione.htm");
%><%@include file="/include/menu.inc"%>
<%
  htmpl.set("exception", exception == null ? null : " "
      + exception.getMessage());
  htmpl.set("idDittaUma", "" + session.getAttribute("idDittaUma"));
  
  htmpl.set("eccedenza", frmVerificaAssegnazioneVO.getEccedenza());    
  

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");

  it.csi.solmr.util.SolmrLogger.debug(this,
      "SONO IN ..... verificaAssegnazioneView.jsp");

  it.csi.solmr.util.SolmrLogger.debug(this,
      "[verificaAssegnazioneview::service] exception=" + exception);
  String pathToFollow = (String) session.getAttribute("pathToFollow");
  ValidationErrors errors = (ValidationErrors) request
      .getAttribute("errors");
  HtmplUtil.setErrors(htmpl, errors, request);
  it.csi.solmr.util.SolmrLogger.debug(this,
      "[verificaAssegnazioneview::service] pageFrom=" + CURRENT_PAGE);
  htmpl.set("pageFrom", CURRENT_PAGE);
  htmpl.set("action", CURRENT_PAGE);
  htmpl.set("annoCorrente", "" + DateUtils.getCurrentYear());
  htmpl.set("annoPrecedente", "" + (DateUtils.getCurrentYear()-1));
  
  
  FrmDettaglioAssegnazioneVO daVO = frmVerificaAssegnazioneVO
      .getFrmDettaglioAssegnazioneVO();
  if (daVO.getAltreMacchine().longValue() != 0)
  {
    htmpl.newBlock("blkAltreMacchine");
  }
  frmVerificaAssegnazioneVO.formatFields();

  //Valorizzazione Consumi in base al tipo Conduzione Ditta - Begin
  it.csi.solmr.util.SolmrLogger
      .debug(
          this,
          "[verificaAssegnazioneview::service] \n\n\n\n\n***************************************************");

  String consumoContoProprioGasolio = frmVerificaAssegnazioneVO
      .getConsumoContoProprioGasolio();
  String consumoContoProprioBenzina = frmVerificaAssegnazioneVO
      .getConsumoContoProprioBenzina();
  String consumoContoTerziGasolio = frmVerificaAssegnazioneVO
      .getConsumoContoTerziGasolio();
  String consumoContoTerziBenzina = frmVerificaAssegnazioneVO
      .getConsumoContoTerziBenzina();

  String consumoSerraGasolio = frmVerificaAssegnazioneVO
      .getConsumoSerraGasolio();
  String consumoSerraBenzina = frmVerificaAssegnazioneVO
      .getConsumoSerraBenzina();
  String totConsumoGasolio = frmVerificaAssegnazioneVO
      .getTotConsumoGasolio();
  String totConsumoBenzina = frmVerificaAssegnazioneVO
      .getTotConsumoBenzina();
      
  String gasolioOggettoFurto = frmVerificaAssegnazioneVO.getGasolioOggettoFurto();
  String benzinaOggettoFurto = frmVerificaAssegnazioneVO.getBenzinaOggettoFurto();    

  if (request.getAttribute("errors") == null)
  {
    it.csi.solmr.util.SolmrLogger
        .debug(this,
            "[verificaAssegnazioneview::service] request.getAttribute(\"errors\")==null");
    //Codice svolto al primo caricamento della pagina
    SolmrLogger.debug(this, "dittaUMAAziendaVO .getIdConduzione() vale: "
        + dittaUMAAziendaVO.getIdConduzione());
    long idConduzione = 1;
    if (dittaUMAAziendaVO.getIdConduzione() != null)
      idConduzione = new Long(dittaUMAAziendaVO.getIdConduzione())
          .longValue();

    /* if (dittaUMAAziendaVO.getIdConduzione() == null){
       //Nel caso in cui il tipo conduzione non sia impostato,
       // lo assume come conto proprio
       idConduzione = 1;
     }*/

    it.csi.solmr.util.SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneview::service] ----------------------------------------------------------------------");
    it.csi.solmr.util.SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneview::service] frmVerificaAssegnazioneVO.getRimanenzaContoProprioGasolioLong(): "
                + frmVerificaAssegnazioneVO
                    .getRimanenzaContoProprioGasolioLong());
    it.csi.solmr.util.SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneview::service] frmVerificaAssegnazioneVO.getRimanenzaContoTerziGasolioLong(): "
                + frmVerificaAssegnazioneVO
                    .getRimanenzaContoTerziGasolioLong());
    it.csi.solmr.util.SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneview::service] frmVerificaAssegnazioneVO.getRimanenzaSerraGasolioLong(): "
                + frmVerificaAssegnazioneVO.getRimanenzaSerraGasolioLong());
    it.csi.solmr.util.SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneview::service] frmVerificaAssegnazioneVO.getConsumoContoProprioGasolioLong(): "
                + frmVerificaAssegnazioneVO
                    .getConsumoContoProprioGasolioLong());
    it.csi.solmr.util.SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneview::service] frmVerificaAssegnazioneVO.getConsumoContoTerziGasolioLong(): "
                + frmVerificaAssegnazioneVO
                    .getConsumoContoTerziGasolioLong());
    it.csi.solmr.util.SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneview::service] frmVerificaAssegnazioneVO.getConsumoSerraGasolioLong(): "
                + frmVerificaAssegnazioneVO.getConsumoSerraGasolioLong());
    it.csi.solmr.util.SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneview::service] frmVerificaAssegnazioneVO.getTotDisponibilitaGasolioLong(): "
                + frmVerificaAssegnazioneVO
                    .getTotDisponibilitaGasolioLong());
    //Controllo x verificare che la domanda non sia già in bozza
    if ((frmVerificaAssegnazioneVO.getRimanenzaContoProprioGasolioLong()
        .longValue()
        + frmVerificaAssegnazioneVO.getRimanenzaContoTerziGasolioLong()
            .longValue()
        + frmVerificaAssegnazioneVO.getRimanenzaSerraGasolioLong()
            .longValue()
        + frmVerificaAssegnazioneVO.getConsumoContoProprioGasolioLong()
            .longValue()
        + frmVerificaAssegnazioneVO.getConsumoContoTerziGasolioLong()
            .longValue()
        + frmVerificaAssegnazioneVO.getConsumoSerraGasolioLong()
            .longValue() == 0)
        && frmVerificaAssegnazioneVO.getTotDisponibilitaGasolioLong()
            .longValue() != 0)
    {
      it.csi.solmr.util.SolmrLogger
          .debug(
              this,
              "[verificaAssegnazioneview::service] Gasolio - Rimanenza, Consumi, Disponibilità nulli");
      if (idConduzione == new Long(""
          + SolmrConstants.get("IDCONDUZIONECONTOPROPRIO")).longValue()
          || idConduzione == new Long(""
              + SolmrConstants.get("IDCONDUZIONECONTOPROPRIOETERZI"))
              .longValue())
      {
        it.csi.solmr.util.SolmrLogger.debug(this,
            "[verificaAssegnazioneview::service] Gasolio - Conto proprio");
        consumoContoProprioGasolio = frmVerificaAssegnazioneVO
            .getTotDisponibilitaNonSerraGasolio();
        frmVerificaAssegnazioneVO
            .setConsumoContoProprioGasolio(frmVerificaAssegnazioneVO
                .getTotDisponibilitaNonSerraGasolio());
      }

      if (frmVerificaAssegnazioneVO.getTotDisponibilitaSerraGasolioLong()
          .longValue() != 0)
      {
        consumoSerraGasolio = frmVerificaAssegnazioneVO
            .getTotDisponibilitaSerraGasolio();
        frmVerificaAssegnazioneVO
            .setConsumoSerraGasolio(frmVerificaAssegnazioneVO
                .getTotDisponibilitaSerraGasolio());
      }

      totConsumoGasolio=String.valueOf(NumberUtils.getLongValueZeroOnNull(consumoContoProprioGasolio)+
      NumberUtils.getLongValueZeroOnNull(consumoContoTerziGasolio)+
      NumberUtils.getLongValueZeroOnNull(consumoSerraGasolio));
      frmVerificaAssegnazioneVO
          .setTotConsumoGasolio(totConsumoGasolio);
    }

    it.csi.solmr.util.SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneview::service] ----------------------------------------------------------------------");
    it.csi.solmr.util.SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneview::service] frmVerificaAssegnazioneVO.getRimanenzaContoProprioBenzinaLong(): "
                + frmVerificaAssegnazioneVO
                    .getRimanenzaContoProprioBenzinaLong());
    it.csi.solmr.util.SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneview::service] frmVerificaAssegnazioneVO.getRimanenzaContoTerziBenzinaLong(): "
                + frmVerificaAssegnazioneVO
                    .getRimanenzaContoTerziBenzinaLong());
    it.csi.solmr.util.SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneview::service] frmVerificaAssegnazioneVO.getRimanenzaSerraBenzinaLong(): "
                + frmVerificaAssegnazioneVO.getRimanenzaSerraBenzinaLong());
    it.csi.solmr.util.SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneview::service] frmVerificaAssegnazioneVO.getConsumoContoProprioBenzinaLong(): "
                + frmVerificaAssegnazioneVO
                    .getConsumoContoProprioBenzinaLong());
    it.csi.solmr.util.SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneview::service] frmVerificaAssegnazioneVO.getConsumoContoTerziBenzinaLong(): "
                + frmVerificaAssegnazioneVO
                    .getConsumoContoTerziBenzinaLong());
    it.csi.solmr.util.SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneview::service] frmVerificaAssegnazioneVO.getConsumoSerraBenzinaLong(): "
                + frmVerificaAssegnazioneVO.getConsumoSerraBenzinaLong());
    it.csi.solmr.util.SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneview::service] frmVerificaAssegnazioneVO.getTotDisponibilitaBenzinaLong(): "
                + frmVerificaAssegnazioneVO
                    .getTotDisponibilitaBenzinaLong());
    //Controllo x verificare che la domanda non sia già in bozza
    if ((frmVerificaAssegnazioneVO.getRimanenzaContoProprioBenzinaLong()
        .longValue()
        + frmVerificaAssegnazioneVO.getRimanenzaContoTerziBenzinaLong()
            .longValue()
        + frmVerificaAssegnazioneVO.getRimanenzaSerraBenzinaLong()
            .longValue()
        + frmVerificaAssegnazioneVO.getConsumoContoProprioBenzinaLong()
            .longValue()
        + frmVerificaAssegnazioneVO.getConsumoContoTerziBenzinaLong()
            .longValue()
        + frmVerificaAssegnazioneVO.getConsumoSerraBenzinaLong()
            .longValue() == 0)
        && frmVerificaAssegnazioneVO.getTotDisponibilitaBenzinaLong()
            .longValue() != 0)
    {
      it.csi.solmr.util.SolmrLogger
          .debug(
              this,
              "[verificaAssegnazioneview::service] Benzina - Rimanenza, Consumi, Disponibilità nulli");
      SolmrLogger.debug(this, "*** idConduzioe vale: " + idConduzione);
      if (idConduzione == new Long(""
          + SolmrConstants.get("IDCONDUZIONECONTOPROPRIO")).longValue()
          || idConduzione == new Long(""
              + SolmrConstants.get("IDCONDUZIONECONTOPROPRIOETERZI"))
              .longValue())
      {
        it.csi.solmr.util.SolmrLogger.debug(this,
            "[verificaAssegnazioneview::service] Benzina - Conto proprio");
        consumoContoProprioBenzina = frmVerificaAssegnazioneVO
            .getTotDisponibilitaNonSerraBenzina();
        frmVerificaAssegnazioneVO
            .setConsumoContoProprioBenzina(frmVerificaAssegnazioneVO
                .getTotDisponibilitaNonSerraBenzina());
      }
      else
      {
        it.csi.solmr.util.SolmrLogger.debug(this,
            "[verificaAssegnazioneview::service] Benzina - Conto terzi");
        consumoContoTerziBenzina = frmVerificaAssegnazioneVO
            .getTotDisponibilitaNonSerraBenzina();
        frmVerificaAssegnazioneVO
            .setConsumoContoTerziBenzina(frmVerificaAssegnazioneVO
                .getTotDisponibilitaNonSerraBenzina());
      }

      if (frmVerificaAssegnazioneVO.getTotDisponibilitaSerraBenzinaLong()
          .longValue() != 0)
      {
        consumoSerraBenzina = frmVerificaAssegnazioneVO
            .getTotDisponibilitaSerraBenzina();
        frmVerificaAssegnazioneVO
            .setConsumoSerraBenzina(frmVerificaAssegnazioneVO
                .getTotDisponibilitaSerraBenzina());
      }

      totConsumoBenzina=String.valueOf(NumberUtils.getLongValueZeroOnNull(consumoContoProprioBenzina)+
      NumberUtils.getLongValueZeroOnNull(consumoContoTerziBenzina)+
      NumberUtils.getLongValueZeroOnNull(consumoSerraBenzina));

      frmVerificaAssegnazioneVO
          .setTotConsumoBenzina(totConsumoBenzina);
    }

    //Imposta il tipo conduzione per il JavaScript di calcolo automatico dei consumi
    htmpl.set("tipoConduzione", "" + idConduzione);

    htmpl.set("consumoContoProprioGasolio", consumoContoProprioGasolio);
    htmpl.set("consumoContoProprioBenzina", consumoContoProprioBenzina);

    htmpl.set("consumoContoTerziGasolio", consumoContoTerziGasolio);
    htmpl.set("consumoContoTerziBenzina", consumoContoTerziBenzina);

    htmpl.set("consumoSerraGasolio", consumoSerraGasolio);
    htmpl.set("consumoSerraBenzina", consumoSerraBenzina);

    htmpl.set("totConsumoGasolio", totConsumoGasolio);
    htmpl.set("totConsumoBenzina", totConsumoBenzina);

  }
  String rimDichAlteAzBenzina = frmVerificaAssegnazioneVO
      .getRimanenzeDichAltreAziendeBenzina();
  String rimDichAlteAzGasolio = frmVerificaAssegnazioneVO
      .getRimanenzeDichAltreAziendeGasolio();
  SolmrLogger.debug(this, "***** nella view rimDichAlteAzBenzina vale: "
      + rimDichAlteAzBenzina);
  SolmrLogger.debug(this, "nella view rimDichAlteAzGasolio vale: "
      + rimDichAlteAzGasolio);
  /*    htmpl.set("rimaDichAltreAzGasolio", rimDichAlteAzGasolio);
   htmpl.set("rimaDichAltreAzBenzina", rimDichAlteAzBenzina);*/
  //061121 Validazione domanda da parte dell'intermediario - Begin
  
  if (ruoloUtenza.isUtenteIntermediario())
  {
    htmpl.newBlock("blkProtocolloIntermediario");
    htmpl.set("blkProtocolloIntermediario.dataProtocollo",
        frmVerificaAssegnazioneVO.getDataProtocollo());
    htmpl.set("blkProtocolloIntermediario.numeroProtocollo",
        frmVerificaAssegnazioneVO.getNumeroProtocollo());
  }
  //061121 Validazione domanda da parte dell'intermediario - End

  //Valorizzazione Consumi in base al tipo Conduzione Ditta - End

  HtmplUtil.setValues(htmpl, frmVerificaAssegnazioneVO, pathToFollow);
  HtmplUtil.setValues(htmpl, daVO, pathToFollow);
 
  // MODIFICATO da EINAUDI 27/01/2010 ==> I consumi conto terzi sono sempre disabilitati
  //htmpl.bset("readonly", READONLY_GRAY, null);
  if(ruoloUtenza.isUtenteRegionale()){
	  htmpl.bset("readonly", READONLY_GRAY, null);
  }
  else{
  	if( 
		/*  idCond.equalsIgnoreCase(String
	      .valueOf(SolmrConstants.IDCONDUZIONECONTOTERZI))
	      || idCond.equalsIgnoreCase(String
	          .valueOf(SolmrConstants.IDCONDUZIONECONTOPROPRIOETERZI))
	      ||*/ Validator.isNotEmpty(request.getAttribute("assegnazioneValidtata"))
	     )
	  {	   
	    htmpl.bset("readonly", READONLY_GRAY, null);	
	  }
   }
  
  
  
  HashMap mapRimanenzeMinime = (HashMap) request
      .getAttribute("mapRimanenzeMinime");
  if (mapRimanenzeMinime != null)
  {
    htmpl.set("rimanenzaMinimaCPBenzina", StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaCPBenzina")));
    htmpl.set("rimanenzaMinimaCTBenzina", StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaCTBenzina")));
    htmpl.set("rimanenzaMinimaCPGasolio", StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaCPGasolio")));
    htmpl.set("rimanenzaMinimaCTGasolio", StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaCTGasolio")));
    
    htmpl.set("rimanenzaMinimaSerreBenzina", StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaSerreBenzina")));        
    htmpl.set("rimanenzaMinimaSerreGasolio", StringUtils
        .checkNull(mapRimanenzeMinime.get("rimanenzaMinimaSerreGasolio")));
  }
  if (request.getAttribute("accontoVO") != null)
  {
    // Esiste un acconto ==> i dati di consumo e rimanenza sono mutuati dall'acconto e non sono
    // modificabili
    htmpl.bset("lockedByAcconto", READONLY_GRAY, null);
  }
  SommeRimanenzeDaCessazioneVO sommeRimanenze = (SommeRimanenzeDaCessazioneVO) request
      .getAttribute("sommeRimanenze");
  if (sommeRimanenze != null)
  {
	SolmrLogger.debug(this, "-- sommeRimanenze != null");  
    htmpl.newBlock("blkRimanenzeDaCessazione");
    
    htmpl.set("blkRimanenzeDaCessazione.rimCessataContoProprioGasolio",String.valueOf(sommeRimanenze.getSommaContoProprioGasolio()));
    htmpl.set("blkRimanenzeDaCessazione.rimCessataContoProprioBenzina",String.valueOf(sommeRimanenze.getSommaContoProprioBenzina()));
    
    htmpl.set("blkRimanenzeDaCessazione.rimCessataContoTerziGasolio",String.valueOf(sommeRimanenze.getSommaContoTerziGasolio()));
    htmpl.set("blkRimanenzeDaCessazione.rimCessataContoTerziBenzina",String.valueOf(sommeRimanenze.getSommaContoTerziBenzina()));
    
    htmpl.set("blkRimanenzeDaCessazione.rimCessataRiscSerraGasolio", String
        .valueOf(sommeRimanenze.getSommaSerraGasolio()));
    htmpl.set("blkRimanenzeDaCessazione.rimCessataRiscSerraBenzina", String
        .valueOf(sommeRimanenze.getSommaSerraBenzina()));
    htmpl.set("blkRimanenzeDaCessazione.totRimCessataGasolio", String
        .valueOf(sommeRimanenze.getSommaGasolio()));
    htmpl.set("blkRimanenzeDaCessazione.totRimCessataBenzina", String
        .valueOf(sommeRimanenze.getSommaBenzina()));
  }


  //attributi aggiunti per la gestione del furto di carburante
  htmpl.set("gasolioOggettoFurto", StringUtils.checkNull(gasolioOggettoFurto));
  htmpl.set("benzinaOggettoFurto", StringUtils.checkNull(benzinaOggettoFurto));
  htmpl.set("numProtocolloDenFurto", StringUtils.checkNull(frmVerificaAssegnazioneVO.getNumProtocolloDenFurto()));
  htmpl.set("estremiDenFurto", StringUtils.checkNull(frmVerificaAssegnazioneVO.getEstremiDenFurto()));
  htmpl.set("dataProtocolloDenFurto", StringUtils.checkNull(frmVerificaAssegnazioneVO.getDataProtocolloDenFurto()));

  Long debitiContoProprio = (Long) request.getAttribute("debitiContoProprio");
  Long debitiContoTerzi = (Long) request.getAttribute("debitiContoTerzi");
  Long debitoSerra = (Long) request.getAttribute("debitiSerra");
  

  if (debitiContoProprio != null)
  {
    // Esiste il debito CP
    SolmrLogger.debug(this, "-- Esiste il debito CP");
    htmpl.newBlock("blkDebitoCP");
    htmpl.set("blkDebitoCP.debitoCP", String.valueOf(debitiContoProprio));
  }
  
  if (debitiContoTerzi != null)
  {
    // Esiste il debito CT
    SolmrLogger.debug(this, "-- Esiste il debito CT");
    htmpl.newBlock("blkDebitoCT");
    htmpl.set("blkDebitoCT.debitoCT", String.valueOf(debitiContoTerzi));
  }

  if (debitoSerra != null)
  {
    // Esiste il debito
    htmpl.newBlock("blkDebitoSerra");
    htmpl.set("blkDebitoSerra.debitoSerra", String
        .valueOf(debitoSerra));
  }

  out.print(htmpl.text());
%><%!private String convertStrintIntoLongBlankOnZero(long value)
  {
    return value == 0 ? "" : String.valueOf(value);
  }%>