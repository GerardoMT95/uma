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
<%@page import="it.csi.solmr.dto.uma.DomandaAssegnazione"%>
<%@page import="it.csi.solmr.dto.uma.SommeRimanenzeDaCessazioneVO"%>
<%!// Costanti
  private static final String LAYOUT = "/domass/layout/verificaAssegnazioneAccontoValida.htm";%>
<%
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
  int annoCorrente = DateUtils.getCurrentYear().intValue();
  int annoPrecedente = annoCorrente - 1;
%><%@include file="/include/menu.inc"%>
<%
  htmpl.set("annoCorrente", String.valueOf(annoCorrente));
  htmpl.set("annoPrecedente", String.valueOf(annoPrecedente));
  
    DomandaAssegnazione accontoVO = (DomandaAssegnazione) request
      .getAttribute("accontoVO");
  htmpl.set("idDomandaassegnazione",accontoVO.getIdDomandaAssegnazione().toString());
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
  
  htmpl.set("eccedenza", StringUtils.checkNull(datiDisponibilitaPerAccontoVO.getEccedenza()));        

  htmpl.set("rimanenzaPrecContoProprioGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzaPrecContoProprioGasolio()));

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
  String quantMaxAssContoProprio = String.valueOf(
      + NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
          .getMassimoAssegnabileContoProprio()));
  htmpl.set("quantMaxAssContoProprio", quantMaxAssContoProprio);
  String quantMaxAssContoTerzi = String.valueOf(
       NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
          .getMassimoAssegnabileContoTerzi()));
  htmpl.set("quantMaxAssContoTerzi", quantMaxAssContoTerzi);
  String quantMaxAssSerre = ""
      + NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
          .getMassimoAssegnabileSerre());
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
          assegnazioneCarburanteAggrVO, ruoloUtenza);
    }
  }
  else
  {
    writeAssegnazioneCarburanteFromRequest(htmpl, request, ruoloUtenza);
  }
  SommeRimanenzeDaCessazioneVO sommeRimanenze=(SommeRimanenzeDaCessazioneVO)
    request.getAttribute("sommeRimanenze");
  if (sommeRimanenze!=null)
  {
    htmpl.newBlock("blkRimanenzeDaCessazione");
    htmpl.set("blkRimanenzeDaCessazione.rimCessataContoProprioTerziGasolio",String.valueOf(sommeRimanenze.getSommaContoProprioTerziGasolio()));
    htmpl.set("blkRimanenzeDaCessazione.rimCessataContoProprioTerziBenzina",String.valueOf(sommeRimanenze.getSommaContoProprioTerziBenzina()));
    htmpl.set("blkRimanenzeDaCessazione.rimCessataRiscSerraGasolio",String.valueOf(sommeRimanenze.getSommaSerraGasolio()));
    htmpl.set("blkRimanenzeDaCessazione.rimCessataRiscSerraBenzina",String.valueOf(sommeRimanenze.getSommaSerraBenzina()));
    htmpl.set("blkRimanenzeDaCessazione.totRimCessataGasolio",String.valueOf(sommeRimanenze.getSommaGasolio()));
    htmpl.set("blkRimanenzeDaCessazione.totRimCessataBenzina",String.valueOf(sommeRimanenze.getSommaBenzina()));
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
    htmpl.set("blkDebitoSerra.debitoSerra", String
        .valueOf(debitoSerra));
  }
  if (ruoloUtenza.isUtenteIntermediario())
  {
/*     if (SolmrConstants.IDCONDUZIONECONTOPROPRIO.equals(dittaUMAAziendaVO.getIdConduzione()))
    {
      htmpl.set("label","valida");
      htmpl.set("action","../layout/confermaValidazioneAcconto.htm");
    }
    else
    { */
      htmpl.set("label","trasmetti a PA");
      htmpl.set("action","../layout/confermaTrasmissioneAcconto.htm");
/*     } */
  }
  else
  {
    htmpl.set("label","valida");
    htmpl.set("action","../layout/confermaValidazioneAcconto.htm");
  }
%><%=htmpl.text()%>
<%!
  public void writeAssegnazioneCarburanteFromDB(Htmpl htmpl,
      AssegnazioneCarburanteAggrVO assegnazioneCarburanteAggrVO,
      RuoloUtenza ruoloUtenza)
  {
    Vector qtaVector = assegnazioneCarburanteAggrVO.getQuantitaAssegnata();
    int size = qtaVector == null ? 0 : qtaVector.size();
    long totAssNettaGasolio=0;
    long totAssNettaBenzina=0;
    for (int i = 0; i < size; ++i)
    {
      QuantitaAssegnataVO qtaAssegnataVO = (QuantitaAssegnataVO) qtaVector
          .get(i);
      String idCarburanteAssegnazione = StringUtils.checkNull(qtaAssegnataVO
          .getIdCarburante());
      if (idCarburanteAssegnazione.equals(SolmrConstants.ID_BENZINA))
      {
        htmpl.set("assNettaContoProprioBenzina", StringUtils
            .checkNull(qtaAssegnataVO.getAssContoProp()));
        htmpl.set("assNettaContoTerziBenzina", StringUtils
            .checkNull(qtaAssegnataVO.getAssContoTer()));
        htmpl.set("assNettaRiscSerraBenzina", StringUtils
            .checkNull(qtaAssegnataVO.getAssSerra()));
        totAssNettaBenzina+=NumberUtils.getLongValueZeroOnNull(qtaAssegnataVO.getAssContoProp());
        totAssNettaBenzina+=NumberUtils.getLongValueZeroOnNull(qtaAssegnataVO.getAssContoTer());
        totAssNettaBenzina+=NumberUtils.getLongValueZeroOnNull(qtaAssegnataVO.getAssSerra());
      }
      else
      {
        if (idCarburanteAssegnazione.equals(SolmrConstants.ID_GASOLIO))
        {
          htmpl.set("assNettaContoProprioGasolio", StringUtils
              .checkNull(qtaAssegnataVO.getAssContoProp()));
        htmpl.set("assNettaContoTerziGasolio", StringUtils
            .checkNull(qtaAssegnataVO.getAssContoTer()));
          htmpl.set("assNettaRiscSerraGasolio", StringUtils
              .checkNull(qtaAssegnataVO.getAssSerra()));
          totAssNettaGasolio+=NumberUtils.getLongValueZeroOnNull(qtaAssegnataVO.getAssContoProp());
          totAssNettaGasolio+=NumberUtils.getLongValueZeroOnNull(qtaAssegnataVO.getAssContoTer());
          totAssNettaGasolio+=NumberUtils.getLongValueZeroOnNull(qtaAssegnataVO.getAssSerra());
        }
      }
    }
    htmpl.set("totAssNettaBenzina",String.valueOf(totAssNettaBenzina));
    htmpl.set("totAssNettaGasolio",String.valueOf(totAssNettaGasolio));
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
    long totAssNettaBenzina=NumberUtils.getLongValueZeroOnNull(request
        .getParameter("assNettaContoProprioBenzina"))+
        NumberUtils.getLongValueZeroOnNull(request
        .getParameter("assNettaRiscSerraBenzina"));

    long totAssNettaGasolio=NumberUtils.getLongValueZeroOnNull(request
        .getParameter("assNettaContoProprioGasolio"))+
        NumberUtils.getLongValueZeroOnNull(request
        .getParameter("assNettaRiscSerraGasolio"));
    htmpl.set("totAssNettaBenzina",String.valueOf(totAssNettaBenzina));
    htmpl.set("totAssNettaGasolio",String.valueOf(totAssNettaGasolio));

    htmpl.set("assNettaContoProprioBenzina", request
        .getParameter("assNettaContoProprioBenzina"));
    htmpl.set("assNettaRiscSerraBenzina", request
        .getParameter("assNettaRiscSerraBenzina"));
    htmpl.set("assNettaContoProprioGasolio", request
        .getParameter("assNettaContoProprioGasolio"));
    htmpl.set("assNettaRiscSerraGasolio", request
        .getParameter("assNettaRiscSerraGasolio"));
    if (ruoloUtenza.isUtenteIntermediario())
    {
      htmpl.newBlock("blkProtocolloIntermediario");
      htmpl.set("blkProtocolloIntermediario.numeroProtocollo", request
          .getParameter("numeroProtocollo"));
      htmpl.set("blkProtocolloIntermediario.dataProtocollo", request
          .getParameter("dataProtocollo"));
    }
  }%>
