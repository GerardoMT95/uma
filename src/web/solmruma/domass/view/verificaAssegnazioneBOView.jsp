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
<%!private static final String CURRENT_PAGE  = "../layout/verificaAssegnazioneBO.htm";
  private static final String READONLY_GRAY = SolmrConstants.HTML_READONLY
                                                + " style='background-color:gray'";%>
<%
  //  frmVerificaAssegnazioneVO.setIdDomandaassegnazione(new Long(request.getParameter("idDomAss")));

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("domass/layout/verificaAssegnazione.htm");
%><%@include file="/include/menu.inc"%>
<%
  htmpl.set("exception", exception == null ? null : " "
      + exception.getMessage());
  htmpl.set("idDittaUma", "" + session.getAttribute("idDittaUma"));

  SolmrLogger.debug(this,"exception=" + exception);

  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");
  SolmrLogger.debug(this,"\n\n\n\n\n***************************************************");
  SolmrLogger.debug(this,"verificaAssegnazioneBOView.jsp");

  String pathToFollow = (String) session.getAttribute("pathToFollow");
  ValidationErrors errors = (ValidationErrors) request
      .getAttribute("errors");
  HtmplUtil.setErrors(htmpl, errors, request);
  SolmrLogger.debug(this,"pageFrom=" + CURRENT_PAGE);
  htmpl.set("pageFrom", CURRENT_PAGE);
  htmpl.set("action", CURRENT_PAGE);
  htmpl.set("annoCorrente", "" + DateUtils.getCurrentYear());
  htmpl.set("annoPrecedente", "" + (DateUtils.getCurrentYear()-1));

  FrmDettaglioAssegnazioneVO daVO = frmVerificaAssegnazioneVO
      .getFrmDettaglioAssegnazioneVO();
      
  htmpl.set("eccedenza", frmVerificaAssegnazioneVO.getEccedenza());    

  if (daVO.getAltreMacchine().longValue() != 0)
  {
    htmpl.newBlock("blkAltreMacchine");
  }
  StringProcessor sp = htmpl.getStringProcessor();
  htmpl.setStringProcessor(null);
  
  // Non visalizzare 'Ricezione documenti da parte dell'intermediario' e 'Ricezione documenti da parte dell'azienda' se il ruolo è Persona fisica
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  if (ruoloUtenza.isUtenteProvinciale() || ruoloUtenza.isUtenteRegionale()){
	SolmrLogger.debug(this, "-- Visualizzare nella pagina la parte da compilare se il ruolo è provinciale o regionale");  
  	htmpl.set("initCommento", "<!--");
  	htmpl.set("endCommento", "-->");
  }
  
  
  
  htmpl.setStringProcessor(sp);
  frmVerificaAssegnazioneVO.formatFields();

  //Valorizzazione Consumi in base al tipo Conduzione Ditta - Begin
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

  if (request.getAttribute("errors") == null)
  {
    SolmrLogger.debug(this,"request.getAttribute(\"errors\")==null");
    //Codice svolto al primo caricamento della pagina
    long idConduzione;
    idConduzione = new Long(dittaUMAAziendaVO.getIdConduzione())
        .longValue();

    if (dittaUMAAziendaVO.getIdConduzione() == null)
    {
      //Nel caso in cui il tipo conduzione non sia impostato,
      // lo assume come conto proprio
      idConduzione = 1;
    }

    it.csi.solmr.util.SolmrLogger
        .debug(this,
            "----------------------------------------------------------------------");
    it.csi.solmr.util.SolmrLogger.debug(this,
        "frmVerificaAssegnazioneVO.getRimanenzaContoProprioGasolioLong(): "
            + frmVerificaAssegnazioneVO
                .getRimanenzaContoProprioGasolioLong());
    it.csi.solmr.util.SolmrLogger
        .debug(this,
            "frmVerificaAssegnazioneVO.getRimanenzaContoTerziGasolioLong(): "
                + frmVerificaAssegnazioneVO
                    .getRimanenzaContoTerziGasolioLong());
    it.csi.solmr.util.SolmrLogger.debug(this,
        "frmVerificaAssegnazioneVO.getRimanenzaSerraGasolioLong(): "
            + frmVerificaAssegnazioneVO.getRimanenzaSerraGasolioLong());
    it.csi.solmr.util.SolmrLogger.debug(this,
        "frmVerificaAssegnazioneVO.getTotDisponibilitaGasolioLong(): "
            + frmVerificaAssegnazioneVO.getTotDisponibilitaGasolioLong());

    it.csi.solmr.util.SolmrLogger.debug(this,
        "frmVerificaAssegnazioneVO.getConsumoContoProprioGasolio(): "
            + frmVerificaAssegnazioneVO.getConsumoContoProprioGasolio());
    it.csi.solmr.util.SolmrLogger.debug(this,
        "frmVerificaAssegnazioneVO.getConsumoContoTerziGasolio(): "
            + frmVerificaAssegnazioneVO.getConsumoContoTerziGasolio());
    it.csi.solmr.util.SolmrLogger.debug(this,
        "frmVerificaAssegnazioneVO.getConsumoSerraGasolio(): "
            + frmVerificaAssegnazioneVO.getConsumoSerraGasolio());
    it.csi.solmr.util.SolmrLogger.debug(this,
        "frmVerificaAssegnazioneVO.getTotDisponibilitaGasolio(): "
            + frmVerificaAssegnazioneVO.getTotDisponibilitaGasolio());

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
      SolmrLogger.debug(this,"Gasolio - Rimanenza, Consumi, Disponibilità nulli");
      if (idConduzione == new Long(""
          + SolmrConstants.get("IDCONDUZIONECONTOPROPRIO")).longValue()
          || idConduzione == new Long(""
              + SolmrConstants.get("IDCONDUZIONECONTOPROPRIOETERZI"))
              .longValue())
      {
        SolmrLogger.debug(this,"Gasolio - Conto proprio");
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
        .debug(this,
            "----------------------------------------------------------------------");
    it.csi.solmr.util.SolmrLogger.debug(this,
        "frmVerificaAssegnazioneVO.getRimanenzaContoProprioBenzinaLong(): "
            + frmVerificaAssegnazioneVO
                .getRimanenzaContoProprioBenzinaLong());
    it.csi.solmr.util.SolmrLogger
        .debug(this,
            "frmVerificaAssegnazioneVO.getRimanenzaContoTerziBenzinaLong(): "
                + frmVerificaAssegnazioneVO
                    .getRimanenzaContoTerziBenzinaLong());
    it.csi.solmr.util.SolmrLogger.debug(this,
        "frmVerificaAssegnazioneVO.getRimanenzaSerraBenzinaLong(): "
            + frmVerificaAssegnazioneVO.getRimanenzaSerraBenzinaLong());
    it.csi.solmr.util.SolmrLogger.debug(this,
        "frmVerificaAssegnazioneVO.getTotDisponibilitaBenzinaLong(): "
            + frmVerificaAssegnazioneVO.getTotDisponibilitaBenzinaLong());

    it.csi.solmr.util.SolmrLogger.debug(this,
        "frmVerificaAssegnazioneVO.getConsumoContoProprioBenzina(): "
            + frmVerificaAssegnazioneVO.getConsumoContoProprioBenzina());
    it.csi.solmr.util.SolmrLogger.debug(this,
        "frmVerificaAssegnazioneVO.getConsumoContoTerziBenzina(): "
            + frmVerificaAssegnazioneVO.getConsumoContoTerziBenzina());
    it.csi.solmr.util.SolmrLogger.debug(this,
        "frmVerificaAssegnazioneVO.getConsumoSerraBenzina(): "
            + frmVerificaAssegnazioneVO.getConsumoSerraBenzina());
    it.csi.solmr.util.SolmrLogger.debug(this,
        "frmVerificaAssegnazioneVO.getTotDisponibilitaBenzina(): "
            + frmVerificaAssegnazioneVO.getTotDisponibilitaBenzina());
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
      SolmrLogger.debug(this,"Benzina - Rimanenza, Consumi, Disponibilità nulli");
      if (idConduzione == new Long(""
          + SolmrConstants.get("IDCONDUZIONECONTOPROPRIO")).longValue()
          || idConduzione == new Long(""
              + SolmrConstants.get("IDCONDUZIONECONTOPROPRIOETERZI"))
              .longValue())
      {
        SolmrLogger.debug(this, "Benzina - Conto proprio");
        consumoContoProprioBenzina = frmVerificaAssegnazioneVO
            .getTotDisponibilitaNonSerraBenzina();
        frmVerificaAssegnazioneVO
            .setConsumoContoProprioBenzina(frmVerificaAssegnazioneVO
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

    SolmrLogger.debug(this,
        "Nella vieww daVO.getRimanenzeDichAltreAziendeBenzina() vale: "
            + daVO.getRimanenzeDichAltreAziendeBenzina());
    SolmrLogger.debug(this,
        "Nella vieww daVO.getRimanenzeDichAltreAziendeGasolio() vale: "
            + daVO.getRimanenzeDichAltreAziendeGasolio());

    htmpl.set("rimaDichAltreAzGasolio", daVO
        .getRimanenzeDichAltreAziendeGasolio());
    htmpl.set("rimaDichAltreAzBenzina", daVO
        .getRimanenzeDichAltreAziendeBenzina());

  }

  //Valorizzazione Consumi in base al tipo Conduzione Ditta - End
  HtmplUtil.setValues(htmpl, frmVerificaAssegnazioneVO, pathToFollow);

  HtmplUtil.setValues(htmpl, daVO, pathToFollow);

  SolmrLogger.debug(this,
      "frmVerificaAssegnazioneVO.getTipiIntermediario()="
          + frmVerificaAssegnazioneVO.getTipiIntermediario());

  HashMap mapRimanenzeMinime = (HashMap) request
      .getAttribute("mapRimanenzeMinime");
  if (mapRimanenzeMinime != null)
  {
    htmpl.set("rimanenzaMinimaCPBenzina", StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaCPBenzina")));
    htmpl.set("rimanenzaMinimaCTBenzina", StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaCTBenzina")));
    htmpl.set("rimanenzaMinimaCPGasolio", StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaCPGasolio")));
    htmpl.set("rimanenzaMinimaCTGasolio", StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaCTGasolio")));
    
    htmpl.set("rimanenzaMinimaSerreBenzina", StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaSerreBenzina")));    
    htmpl.set("rimanenzaMinimaSerreGasolio", StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaSerreGasolio")));
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

  //inzio cris
  String idCond = dittaUMAAziendaVO.getIdConduzione();
  
  /* 
   - Se l'utente è un utente Regionale :
         campi 'Consumo Conto Terzi' sempre disabilitati
   - Negli altri casi :
   		 campi 'Consumo Conto Terzi' disabilitati se ci sono domande in stato validato
    	  Note : tolto il controllo sull'idConduzione = 2(conto terzi) o 3(conto proprio conto terzi)
     
  */
  
  
  // NOTE : PER LA VERSIONE TOBECONFIG COMMENTATA LA PARTE IN MODO CHE I CAMPI SIANO SEMPRE ABILITATI
  //if(ruoloUtenza.isUtenteRegionale()){
	//  htmpl.bset("readonly", READONLY_GRAY, null);
  //}
  //else{
  	//if( 
		/*  idCond.equalsIgnoreCase(String
	      .valueOf(SolmrConstants.IDCONDUZIONECONTOTERZI))
	      || idCond.equalsIgnoreCase(String
	          .valueOf(SolmrConstants.IDCONDUZIONECONTOPROPRIOETERZI))
	      ||*/
	      //Validator.isNotEmpty(request.getAttribute("assegnazioneValidtata"))
	     //)
	  //{	   
	    //htmpl.bset("readonly", READONLY_GRAY, null);	
	  //}
   //} 
   
  
  
  
  

 
  Long debitoSerra = (Long) request.getAttribute("debitoSerra");
  Long debitiContoProprio = (Long) request.getAttribute("debitiContoProprio");
  Long debitiContoTerzi = (Long) request.getAttribute("debitiContoTerzi");
  

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
%>

