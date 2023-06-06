<%@page import="it.csi.jsf.htmpl.Htmpl"%>
<%@page import="it.csi.jsf.htmpl.HtmplFactory"%>
<%@page import="it.csi.solmr.util.DateUtils"%>
<%@page import="it.csi.solmr.util.StringUtils"%>
<%@page import="it.csi.solmr.dto.uma.DatiDisponibilitaPerAccontoVO"%>
<%@page import="it.csi.solmr.util.HtmplUtil"%>
<%@page import="it.csi.solmr.util.ValidationErrors"%>
<%@page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO"%>
<%@page import="it.csi.solmr.util.NumberUtils"%>
<%@page import="it.csi.solmr.dto.uma.AssegnazioneCarburanteAggrVO"%>
<%@page import="java.util.Vector"%>
<%@page import="it.csi.solmr.dto.uma.QuantitaAssegnataVO"%>
<%@page import="it.csi.solmr.etc.SolmrConstants"%>
<%@page import="it.csi.solmr.dto.profile.RuoloUtenza"%>
<%@page import="it.csi.solmr.dto.uma.SommeRimanenzeDaCessazioneVO"%>
<%@page import="it.csi.solmr.util.SolmrLogger"%>
<%!// Costanti
  private static final String LAYOUT = "/domass/layout/verificaAssegnazioneAcconto.htm";%>
<%
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
  int annoCorrente = DateUtils.getCurrentYear().intValue();
  int annoPrecedente = annoCorrente - 1;
%><%@include file="/include/menu.inc"%>
<%
  htmpl.set("annoCorrente", String.valueOf(annoCorrente));
  htmpl.set("annoPrecedente", String.valueOf(annoPrecedente));
  DatiDisponibilitaPerAccontoVO datiDisponibilitaPerAccontoVO = (DatiDisponibilitaPerAccontoVO) request
      .getAttribute("datiDisponibilitaPerAccontoVO");
  // Visualizzo le rimanenze conto proprio, conto terzi e serre per gasolio
  htmpl.set("rimanenzaPrecContoProprioGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzaPrecContoProprioGasolio()));
  htmpl.set("rimanenzaPrecContoTerziGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzaPrecContoTerziGasolio()));
  htmpl.set("rimanenzaPrecSerraGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzaPrecSerraGasolio()));
  // Visualizzo le rimanenze conto proprio, conto terzi e serre per benzina
  htmpl.set("rimanenzaPrecContoProprioBenzina", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzaPrecContoProprioBenzina()));
  htmpl.set("rimanenzaPrecContoTerziBenzina", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzaPrecContoTerziBenzina()));
  htmpl.set("rimanenzaPrecSerraBenzina", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzaPrecSerraBenzina()));

  htmpl.set("rimanenzaPrecContoProprioGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzaPrecContoProprioGasolio()));
          
  htmpl.set("eccedenza", StringUtils.checkNull(datiDisponibilitaPerAccontoVO.getEccedenza()));        

  boolean isFirstTime = request.getParameter("confermaConsumato") == null;
  htmpl.set("rimanenzaContoTerziBenzina", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzaContoTerziBenzina()));
  htmpl.set("rimanenzaSerraGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO.getRimanenzaSerraGasolio()));
  htmpl.set("rimanenzaSerraBenzina", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO.getRimanenzaSerraBenzina()));
  htmpl.set("rimanenzaContoProprioGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzaContoProprioGasolio()));
  htmpl.set("rimanenzaContoProprioBenzina", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzaContoProprioBenzina()));
  htmpl.set("rimanenzaContoTerziGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzaContoTerziGasolio()));
  htmpl.set("consumoContoProprioGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getConsumoContoProprioGasolio()));
  htmpl.set("consumoContoProprioBenzina", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getConsumoContoProprioBenzina()));
  htmpl.set("consumoContoTerziGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getConsumoContoTerziGasolio()));
  htmpl.set("consumoContoTerziBenzina", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getConsumoContoTerziBenzina()));
  htmpl.set("consumoSerraGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO.getConsumoSerraGasolio()));
  htmpl.set("consumoSerraBenzina", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO.getConsumoSerraBenzina()));
  htmpl.set("totRimanenzaGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO.getTotRimanenzaGasolio()));
  htmpl.set("totRimanenzaBenzina", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO.getTotRimanenzaBenzina()));
  htmpl.set("totConsumoGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO.getTotConsumoGasolio()));
  htmpl.set("totConsumoBenzina", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO.getTotConsumoBenzina()));

  htmpl.set("totDisponibilitaGasolio",
      StringUtils.checkNull(datiDisponibilitaPerAccontoVO
          .getTotDisponibilitaGasolio()));
  htmpl.set("totDisponibilitaBenzina",
      StringUtils.checkNull(datiDisponibilitaPerAccontoVO
          .getTotDisponibilitaBenzina()));

  htmpl.set("rimanenzaMinimaCPTGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzaMinimaCPTGasolio()));
  htmpl.set("rimanenzaMinimaCPTBenzina", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzaMinimaCPTBenzina()));

  htmpl.set("rimanenzaMinimaSerreGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzaMinimaSerreGasolio()));
  htmpl.set("rimanenzaMinimaSerreBenzina", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzaMinimaSerreBenzina()));

  // Visualizzo le Prelevato conto proprio e terzi e serre per gasolio
  htmpl.set("prelevatoGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO.getPrelevatoGasolio()));
  htmpl.set("prelevatoSerraGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO.getPrelevatoSerraGasolio()));

  // Visualizzo le Prelevato conto proprio e terzi e serre per benzina      
  htmpl.set("prelevatoBenzina", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO.getPrelevatoBenzina()));
  htmpl.set("prelevatoSerraBenzina", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO.getPrelevatoSerraBenzina()));
  //rimAltreAziendeGasolio    
  htmpl.set("rimAltreAziendeGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzeDichAltreAziendeGasolio()));
  htmpl.set("rimAltreAziendeBenzina", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzeDichAltreAziendeBenzina()));
  HtmplUtil.setErrors(htmpl, (ValidationErrors) request
      .getAttribute("errors"), request);
  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");
  String idConduzione = dittaUMAAziendaVO.getIdConduzione();
  htmpl.set("tipoConduzione", idConduzione);
  
  String quantMaxAssContoProprio = ""
      + NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
          .getMassimoAssegnabileContoProprio());
  SolmrLogger.debug(this, " --- -quantMaxAssContoProprio ="+quantMaxAssContoProprio);        
  htmpl.set("quantMaxAssContoProprio", quantMaxAssContoProprio);
  
  String quantMaxAssContoTerzi = ""
      + NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
          .getMassimoAssegnabileContoTerzi());
  SolmrLogger.debug(this, " --- -quantMaxAssContoTerzi ="+quantMaxAssContoTerzi);          
  htmpl.set("quantMaxAssContoTerzi", quantMaxAssContoTerzi);
  
  String quantMaxAssSerre = ""
      + NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
          .getMassimoAssegnabileSerre());          
  SolmrLogger.debug(this, " --- -quantMaxAssSerre ="+quantMaxAssSerre);        
  htmpl.set("quantMaxAssSerre", quantMaxAssSerre);
  
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  
  
  //attributi aggiunti per la gestione del furto di carburante
  htmpl.set("gasolioOggettoFurto", StringUtils.checkNull(datiDisponibilitaPerAccontoVO.getGasolioOggettoFurto()));
  htmpl.set("benzinaOggettoFurto", StringUtils.checkNull(datiDisponibilitaPerAccontoVO.getBenzinaOggettoFurto()));
  htmpl.set("numProtocolloDenFurto", StringUtils.checkNull(datiDisponibilitaPerAccontoVO.getNumProtocolloDenFurto()));
  htmpl.set("estremiDenFurto", StringUtils.checkNull(datiDisponibilitaPerAccontoVO.getEstremiDenFurto()));
  htmpl.set("dataProtocolloDenFurto", StringUtils.checkNull(datiDisponibilitaPerAccontoVO.getDataProtocolloDenFurto()));

  if (isFirstTime)
  {
    AssegnazioneCarburanteAggrVO assegnazioneCarburanteAggrVO = (AssegnazioneCarburanteAggrVO) request
        .getAttribute("assegnazioneCarburanteAggrVO");
    if (assegnazioneCarburanteAggrVO != null)
    {
      writeAssegnazioneCarburanteFromDB(htmpl,
          assegnazioneCarburanteAggrVO, ruoloUtenza, request);
    }
  }
  else
  {
    writeAssegnazioneCarburanteFromRequest(htmpl, request, ruoloUtenza);
  }
  String messaggio = (String) request.getAttribute("ERRORE_GRAVE");
  if (messaggio == null)
  {
    htmpl.newBlock("blkBottoneAvanti");
  }
  else
  {
    htmpl.newBlock("blkErrore");

    htmpl.set("blkErrore.messaggio", messaggio, null);
    if (ruoloUtenza.isUtenteIntermediario())
    {
      htmpl.set("blkProtocolloIntermediario.disabled",
          SolmrConstants.HTML_DISABLED + " style='background-color:gray'",
          null);
    }
  }

  Boolean disabled_CP = (Boolean) request.getAttribute("CP_DISABLED");
  Boolean disabled_CT = (Boolean) request.getAttribute("CT_DISABLED");
  Boolean disabled_S = (Boolean) request.getAttribute("SERRE_DISABLED");
  if (disabled_CP != null && disabled_CP.booleanValue())
  {
    htmpl.set("disabled_CP", SolmrConstants.HTML_DISABLED
        + " style='background-color:gray'", null);
  }
  if (disabled_CT != null && disabled_CT.booleanValue())
  {
    htmpl.set("disabled_CT", SolmrConstants.HTML_DISABLED
        + " style='background-color:gray'", null);
  }
  if (disabled_S != null && disabled_S.booleanValue())
  {
    htmpl.set("disabled_Serre", SolmrConstants.HTML_DISABLED
        + " style='background-color:gray'", null);
  }

  SommeRimanenzeDaCessazioneVO sommeRimanenze = (SommeRimanenzeDaCessazioneVO) request
      .getAttribute("sommeRimanenze");
  if (sommeRimanenze != null)
  {
    htmpl.newBlock("blkRimanenzeDaCessazione");
    htmpl.set(
        "blkRimanenzeDaCessazione.rimCessataContoProprioTerziGasolio",
        String.valueOf(sommeRimanenze.getSommaContoProprioTerziGasolio()));
    htmpl.set(
        "blkRimanenzeDaCessazione.rimCessataContoProprioTerziBenzina",
        String.valueOf(sommeRimanenze.getSommaContoProprioTerziBenzina()));
    htmpl.set("blkRimanenzeDaCessazione.rimCessataRiscSerraGasolio", String
        .valueOf(sommeRimanenze.getSommaSerraGasolio()));
    htmpl.set("blkRimanenzeDaCessazione.rimCessataRiscSerraBenzina", String
        .valueOf(sommeRimanenze.getSommaSerraBenzina()));
    htmpl.set("blkRimanenzeDaCessazione.totRimCessataGasolio", String
        .valueOf(sommeRimanenze.getSommaGasolio()));
    htmpl.set("blkRimanenzeDaCessazione.totRimCessataBenzina", String
        .valueOf(sommeRimanenze.getSommaBenzina()));
  }

  Long debitiContoProprioTerzi = (Long) request
      .getAttribute("debitoContoProprioTerzi");
  Long debitoSerra = (Long) request.getAttribute("debitoSerra");

  if (debitiContoProprioTerzi != null)
  {
    // Esiste il debito
    htmpl.newBlock("blkDebitoCPT");
    htmpl.set("blkDebitoCPT.debitoCPT", String
        .valueOf(debitiContoProprioTerzi));
  }

  if (debitoSerra != null)
  {
    // Esiste il debito
    htmpl.newBlock("blkDebitoSerra");
    htmpl.set("blkDebitoSerra.debitoSerra", String.valueOf(debitoSerra));
  }
%><%=htmpl.text()%><%!//
  public void writeAssegnazioneCarburanteFromDB(Htmpl htmpl,
      AssegnazioneCarburanteAggrVO assegnazioneCarburanteAggrVO,
      RuoloUtenza ruoloUtenza, HttpServletRequest request)
  {
    Vector qtaVector = assegnazioneCarburanteAggrVO.getQuantitaAssegnata();
    int size = qtaVector == null ? 0 : qtaVector.size();
    long totAssNettaGasolio = 0;
    long totAssNettaBenzina = 0;
    Boolean disabled_CP = (Boolean) request.getAttribute("CP_DISABLED");
    boolean enabledCP = disabled_CP == null || !disabled_CP.booleanValue();
    Boolean disabled_CT = (Boolean) request.getAttribute("CT_DISABLED");
    boolean enabledCT = disabled_CT == null || !disabled_CT.booleanValue();
    Boolean disabled_S = (Boolean) request.getAttribute("SERRE_DISABLED");
    boolean enabledS = disabled_S == null || !disabled_S.booleanValue();

    for (int i = 0; i < size; ++i)
    {
      QuantitaAssegnataVO qtaAssegnataVO = (QuantitaAssegnataVO) qtaVector
          .get(i);
      String idCarburanteAssegnazione = StringUtils.checkNull(qtaAssegnataVO
          .getIdCarburante());
      if (idCarburanteAssegnazione.equals(SolmrConstants.ID_BENZINA))
      {
        if (enabledCP)
        {
          totAssNettaBenzina += NumberUtils
              .getLongValueZeroOnNull(qtaAssegnataVO.getAssContoProp());
          htmpl.set("assNettaContoProprioBenzina", StringUtils
              .checkNull(qtaAssegnataVO.getAssContoProp()));
        }
        if (enabledCT)
        {
          totAssNettaBenzina += NumberUtils
              .getLongValueZeroOnNull(qtaAssegnataVO.getAssContoTer());
          htmpl.set("assNettaContoTerziBenzina", StringUtils
              .checkNull(qtaAssegnataVO.getAssContoTer()));
        }
        if (enabledS)
        {
          totAssNettaBenzina += NumberUtils
              .getLongValueZeroOnNull(qtaAssegnataVO.getAssSerra());
          htmpl.set("assNettaRiscSerraBenzina", StringUtils
              .checkNull(qtaAssegnataVO.getAssSerra()));
        }
      }
      else
      {
        if (idCarburanteAssegnazione.equals(SolmrConstants.ID_GASOLIO))
        {
          if (enabledCP)
          {
            totAssNettaGasolio += NumberUtils
                .getLongValueZeroOnNull(qtaAssegnataVO.getAssContoProp());
            htmpl.set("assNettaContoProprioGasolio", StringUtils
                .checkNull(qtaAssegnataVO.getAssContoProp()));
          }
          if (enabledCT)
          {
            totAssNettaGasolio += NumberUtils
                .getLongValueZeroOnNull(qtaAssegnataVO.getAssContoTer());
            htmpl.set("assNettaContoTerziGasolio", StringUtils
                .checkNull(qtaAssegnataVO.getAssContoTer()));
          }
          if (enabledS)
          {
            totAssNettaGasolio += NumberUtils
                .getLongValueZeroOnNull(qtaAssegnataVO.getAssSerra());
            htmpl.set("assNettaRiscSerraGasolio", StringUtils
                .checkNull(qtaAssegnataVO.getAssSerra()));
          }
        }
      }
    }
    htmpl.set("totAssNettaBenzina", String.valueOf(totAssNettaBenzina));
    htmpl.set("totAssNettaGasolio", String.valueOf(totAssNettaGasolio));
    if (ruoloUtenza.isUtenteIntermediario())
    {
      htmpl.newBlock("blkProtocolloIntermediario");
      htmpl.set("blkProtocolloIntermediario.numeroProtocollo",
          assegnazioneCarburanteAggrVO.getAssegnazioneCarburante()
              .getNumeroProtocollo());
      htmpl.set("blkProtocolloIntermediario.dataProtocollo",
          assegnazioneCarburanteAggrVO.getAssegnazioneCarburante()
              .getDataProtocollo());
    }
  }

  public void writeAssegnazioneCarburanteFromRequest(Htmpl htmpl,
      HttpServletRequest request, RuoloUtenza ruoloUtenza)
  {
    String assNettaContoProprioBenzina = request
        .getParameter("assNettaContoProprioBenzina");
    String assNettaContoTerziBenzina = request
        .getParameter("assNettaContoTerziBenzina");
    String assNettaRiscSerraBenzina = request
        .getParameter("assNettaRiscSerraBenzina");
    long totAssNettaBenzina = NumberUtils
        .getLongValueZeroOnNull(assNettaContoProprioBenzina)
        + NumberUtils.getLongValueZeroOnNull(assNettaRiscSerraBenzina)
        + NumberUtils.getLongValueZeroOnNull(assNettaContoTerziBenzina);

    String assNettaContoProprioGasolio = request
        .getParameter("assNettaContoProprioGasolio");
    String assNettaContoTerziGasolio = request
        .getParameter("assNettaContoTerziGasolio");
    String assNettaRiscSerraGasolio = request
        .getParameter("assNettaRiscSerraGasolio");
    long totAssNettaGasolio = NumberUtils
        .getLongValueZeroOnNull(assNettaContoProprioGasolio)
        + NumberUtils.getLongValueZeroOnNull(assNettaRiscSerraGasolio)
        + NumberUtils.getLongValueZeroOnNull(assNettaContoTerziGasolio);

    htmpl.set("totAssNettaBenzina", String.valueOf(totAssNettaBenzina));
    htmpl.set("totAssNettaGasolio", String.valueOf(totAssNettaGasolio));

    htmpl.set("assNettaContoProprioBenzina", assNettaContoProprioBenzina);
    htmpl.set("assNettaContoTerziBenzina", assNettaContoTerziBenzina);
    htmpl.set("assNettaRiscSerraBenzina", assNettaRiscSerraBenzina);

    htmpl.set("assNettaContoProprioGasolio", assNettaContoProprioGasolio);
    htmpl.set("assNettaContoTerziGasolio", assNettaContoTerziGasolio);
    htmpl.set("assNettaRiscSerraGasolio", assNettaRiscSerraGasolio);
    if (ruoloUtenza.isUtenteIntermediario())
    {
      htmpl.newBlock("blkProtocolloIntermediario");
      htmpl.set("blkProtocolloIntermediario.numeroProtocollo", request
          .getParameter("numeroProtocollo"));
      htmpl.set("blkProtocolloIntermediario.dataProtocollo", request
          .getParameter("dataProtocollo"));
    }
  }%>
