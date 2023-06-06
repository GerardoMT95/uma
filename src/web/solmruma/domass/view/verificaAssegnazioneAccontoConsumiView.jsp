<%@page import="it.csi.solmr.etc.SolmrConstants"%>
<%@page import="it.csi.jsf.htmpl.Htmpl"%>
<%@page import="it.csi.jsf.htmpl.HtmplFactory"%>
<%@page import="it.csi.solmr.util.DateUtils"%>
<%@page import="it.csi.solmr.util.StringUtils"%>
<%@page import="it.csi.solmr.dto.uma.DatiDisponibilitaPerAccontoVO"%>
<%@page import="it.csi.solmr.util.HtmplUtil"%>
<%@page import="it.csi.solmr.util.ValidationErrors"%>
<%@page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO"%>
<%@page import="it.csi.solmr.dto.uma.SommeRimanenzeDaCessazioneVO"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="java.util.*"%>
<%!// Costanti
  private static final String LAYOUT = "/domass/layout/verificaAssegnazioneAccontoConsumi.htm";%>
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
  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");
  String idConduzione = dittaUMAAziendaVO.getIdConduzione();

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
  SolmrLogger.debug(this, "VIEW PRIMAAAA isFirstTime: " + isFirstTime);
  if (isFirstTime)
  {
    htmpl.set("rimanenzaContoTerziBenzina", StringUtils
        .checkNull(datiDisponibilitaPerAccontoVO
            .getRimanenzaContoTerziBenzina()));
    htmpl.set("rimanenzaSerraGasolio",
        StringUtils.checkNull(datiDisponibilitaPerAccontoVO
            .getRimanenzaSerraGasolio()));
    htmpl.set("rimanenzaSerraBenzina",
        StringUtils.checkNull(datiDisponibilitaPerAccontoVO
            .getRimanenzaSerraBenzina()));
    htmpl.set("rimanenzaContoProprioGasolio", StringUtils
        .checkNull(datiDisponibilitaPerAccontoVO
            .getRimanenzaContoProprioGasolio()));
    htmpl.set("rimanenzaContoProprioBenzina", StringUtils
        .checkNull(datiDisponibilitaPerAccontoVO
            .getRimanenzaContoProprioBenzina()));
    htmpl.set("rimanenzaContoTerziGasolio", StringUtils
        .checkNull(datiDisponibilitaPerAccontoVO
            .getRimanenzaContoTerziGasolio()));

    SolmrLogger.debug(this, "VIEW PRIMAAAA getConsumoContoTerziGasolio: "
        + datiDisponibilitaPerAccontoVO.getConsumoContoTerziGasolio());

    SolmrLogger.debug(this, "VIEW getConsumoContoTerziGasolio: "
        + datiDisponibilitaPerAccontoVO.getConsumoContoTerziGasolio());
    SolmrLogger.debug(this, "VIEW getConsumoContoTerziBenzina: "
        + datiDisponibilitaPerAccontoVO.getConsumoContoTerziBenzina());
    /*if(datiDisponibilitaPerAccontoVO.getConsumoContoTerziGasolio() == null || 
       datiDisponibilitaPerAccontoVO.getConsumoContoTerziGasolio().longValue() <= 0 ||
       datiDisponibilitaPerAccontoVO.getConsumoContoTerziBenzina() == null ||
       datiDisponibilitaPerAccontoVO.getConsumoContoTerziBenzina().longValue() <= 0 
         )*/

    htmpl.newBlock("blkNonEditabile");
    htmpl.set("blkNonEditabile.consumoContoTerziGasolio", StringUtils
        .checkNull(datiDisponibilitaPerAccontoVO
            .getConsumoContoTerziGasolio()));
    htmpl.set("blkNonEditabile.consumoContoTerziBenzina", StringUtils
        .checkNull(datiDisponibilitaPerAccontoVO
            .getConsumoContoTerziBenzina()));

    htmpl.set("consumoContoProprioGasolio", StringUtils
        .checkNull(datiDisponibilitaPerAccontoVO
            .getConsumoContoProprioGasolio()));
    htmpl.set("consumoContoProprioBenzina", StringUtils
        .checkNull(datiDisponibilitaPerAccontoVO
            .getConsumoContoProprioBenzina()));
    htmpl.set("consumoSerraGasolio", StringUtils
        .checkNull(datiDisponibilitaPerAccontoVO.getConsumoSerraGasolio()));
    htmpl.set("consumoSerraBenzina", StringUtils
        .checkNull(datiDisponibilitaPerAccontoVO.getConsumoSerraBenzina()));
  }
  else
  {
    htmpl.set("rimanenzaContoTerziBenzina", request
        .getParameter("rimanenzaContoTerziBenzina"));
    htmpl.set("rimanenzaSerraGasolio", request
        .getParameter("rimanenzaSerraGasolio"));
    htmpl.set("rimanenzaSerraBenzina", request
        .getParameter("rimanenzaSerraBenzina"));
    htmpl.set("rimanenzaContoProprioGasolio", request
        .getParameter("rimanenzaContoProprioGasolio"));
    htmpl.set("rimanenzaContoProprioBenzina", request
        .getParameter("rimanenzaContoProprioBenzina"));
    htmpl.set("rimanenzaContoTerziGasolio", request
        .getParameter("rimanenzaContoTerziGasolio"));
    htmpl.set("consumoContoProprioGasolio", request
        .getParameter("consumoContoProprioGasolio"));
    htmpl.set("consumoContoProprioBenzina", request
        .getParameter("consumoContoProprioBenzina"));

      htmpl.newBlock("blkNonEditabile");
      htmpl.set("blkNonEditabile.consumoContoTerziGasolio", StringUtils
          .checkNull(datiDisponibilitaPerAccontoVO
              .getConsumoContoTerziGasolio()));
      htmpl.set("blkNonEditabile.consumoContoTerziBenzina", StringUtils
          .checkNull(datiDisponibilitaPerAccontoVO
              .getConsumoContoTerziBenzina()));

    htmpl.set("consumoSerraGasolio", request
        .getParameter("consumoSerraGasolio"));
    htmpl.set("consumoSerraBenzina", request
        .getParameter("consumoSerraBenzina"));
  }
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

  htmpl.set("rimAltreAziendeGasolio", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzeDichAltreAziendeGasolio()));
  htmpl.set("rimAltreAziendeBenzina", StringUtils
      .checkNull(datiDisponibilitaPerAccontoVO
          .getRimanenzeDichAltreAziendeBenzina()));

  HtmplUtil.setErrors(htmpl, (ValidationErrors) request
      .getAttribute("errors"), request);

  htmpl.set("tipoConduzione", idConduzione);
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
  //attributi aggiunti per la gestione del furto di carburante
  htmpl.set("gasolioOggettoFurto", StringUtils.checkNull(datiDisponibilitaPerAccontoVO.getGasolioOggettoFurto()));
  htmpl.set("benzinaOggettoFurto", StringUtils.checkNull(datiDisponibilitaPerAccontoVO.getBenzinaOggettoFurto()));
  htmpl.set("numProtocolloDenFurto", StringUtils.checkNull(datiDisponibilitaPerAccontoVO.getNumProtocolloDenFurto()));
  htmpl.set("estremiDenFurto", StringUtils.checkNull(datiDisponibilitaPerAccontoVO.getEstremiDenFurto()));
  htmpl.set("dataProtocolloDenFurto", StringUtils.checkNull(datiDisponibilitaPerAccontoVO.getDataProtocolloDenFurto()));



%><%=htmpl.text()%>