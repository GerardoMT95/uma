<%@ page language="java" contentType="text/html" isErrorPage="false"%>
<%@page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO"%>
<%@page import="it.csi.solmr.client.uma.UmaFacadeClient"%>
<%@page import="it.csi.solmr.dto.uma.DomandaAssegnazione"%>
<%@page import="it.csi.solmr.etc.SolmrConstants"%>
<%@page import="it.csi.solmr.dto.profile.RuoloUtenza"%>
<%@page import="it.csi.solmr.dto.uma.DatiDisponibilitaPerAccontoVO"%>
<%@page import="it.csi.solmr.util.ValidationErrors"%>
<%@page import="it.csi.solmr.etc.uma.UmaErrors"%>
<%@page import="it.csi.solmr.util.ValidationError"%>
<%@page import="it.csi.solmr.util.Validator"%>
<%@page import="it.csi.solmr.util.CarburanteUtil"%>
<%@page import="java.util.Vector"%>
<%@page import="it.csi.solmr.exception.SolmrException"%>
<%@page import="it.csi.solmr.dto.uma.ConsumoRimanenzaVO"%>
<%@page import="it.csi.solmr.util.NumberUtils"%>
<%@page import="it.csi.solmr.dto.uma.SommeRimanenzeDaCessazioneVO"%>
<%@page import="it.csi.solmr.util.SolmrLogger"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%!// Costanti
  public static final Long    ZERO      = new Long(0);
  private static final String VIEW      = "/domass/view/verificaAssegnazioneAccontoConsumiView.jsp";
  public final static String  CLOSE_URL = "../layout/assegnazioni.htm";
  private static final String NEXT      = "../layout/verificaAssegnazioneAcconto.htm";
  
  private static final String MSG_NO_DOMANDA_BASE_PRESENTE_ANNI_PRECEDENTI = "Non è possibile eseguire l'acconto in quanto non esistono assegnazioni per l'anno precedente.";%>
<%
  session.removeAttribute("ASSEGNAZIONE_VALIDA");
  request.setAttribute("closeUrl", CLOSE_URL);
  String iridePageName = "verificaAssegnazioneAccontoConsumiCtrl.jsp";
  request.setAttribute("noValidazione",new Boolean(true));
%><%@include file="/include/autorizzazione.inc"%>
<%
  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");

  /********************************************************************************/
  // Se sono arrivato qui, vuol dire che ho superato i controlli di abilitazioni
  // ed in request mi trovo l'acconto e la domanda dell'anno precedente (ovviamente
  // solo se esistono!)
  /********************************************************************************/

  DomandaAssegnazione accontoVO = (DomandaAssegnazione) request
      .getAttribute("accontoVO");
  DomandaAssegnazione domandaAnniPrecedentiVO = (DomandaAssegnazione) request
      .getAttribute("domandaAnniPrecedentiVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
      
  
  //Se non esistono domande per gli anni precedenti, non si può presentare la domanda
  //di acconto per l'anno corrente
  SolmrLogger.debug(this, "domandaAnniPrecedentiVO: " + domandaAnniPrecedentiVO);
  //System.err.println("domandaAnniPrecedentiVO: " + domandaAnniPrecedentiVO);  
  
  /* 
     SMRUMA-577 
     Se l'utente connesso è un utente PA in caso di ditta Uma nuova (senza assegnazione precedente) 
     oppure di ditta Uma senza prelevato sull'assegnazione precedente il sistema consente di proseguire con l'acconto.
  */
  if(!ruoloUtenza.isUtentePA())
	  if(domandaAnniPrecedentiVO==null)
	  {
		  request.setAttribute("errorMessage", MSG_NO_DOMANDA_BASE_PRESENTE_ANNI_PRECEDENTI);
	    SolmrLogger.debug(this, "errorMessage: " + MSG_NO_DOMANDA_BASE_PRESENTE_ANNI_PRECEDENTI);
			%><jsp:forward
				page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
	      return;
	  }

  UmaFacadeClient umaFacadeClient = (UmaFacadeClient) request
      .getAttribute("umaFacadeClient");
  if (accontoVO == null)
  {
    // Nessun acconto trovato ==> Inserisco un nuovo acconto
    // Creo la struttura dati
    accontoVO = creaAccontoVO(domandaAnniPrecedentiVO, dittaUMAAziendaVO,
        ruoloUtenza);
    // Eseguo l'insert su db
    Long idDomandaAssegnazione = umaFacadeClient.insertAcconto(accontoVO);
    accontoVO.setIdDomandaAssegnazione(idDomandaAssegnazione);
  }
  Long idDomandaAssegnazioneAnniPrecedenti = domandaAnniPrecedentiVO != null ? domandaAnniPrecedentiVO
      .getIdDomandaAssegnazione()
      : null;
  SolmrLogger.debug(this, " -- idDomandaAssegnazioneAnniPrecedenti ="+idDomandaAssegnazioneAnniPrecedenti);    


  DatiDisponibilitaPerAccontoVO datiDisponibilitaPerAccontoVO = umaFacadeClient.getDatiDisponibilitaPerAcconto(idDomandaAssegnazioneAnniPrecedenti,accontoVO.getIdDomandaAssegnazione());

  //aggiungo i dati relativi al furto
  if (accontoVO.getDataProtocolloFurto()!=null)
    datiDisponibilitaPerAccontoVO.setDataProtocolloDenFurto(it.csi.solmr.util.UmaDateUtils.formatDate(accontoVO.getDataProtocolloFurto()));
  
  datiDisponibilitaPerAccontoVO.setEstremiDenFurto(accontoVO.getEstremiDenFurto());
  datiDisponibilitaPerAccontoVO.setNumProtocolloDenFurto(accontoVO.getNumProtocolloDenFurto());  

  Vector<String> vCarburanteAssCTAssPrec = null;
  
// -------- CALCOLO RIMANENZA MINIMA STIMATA AL 31/12 ------------
  if (idDomandaAssegnazioneAnniPrecedenti != null){
    SolmrLogger.debug(this, "--- idDomandaAssegnazioneAnniPrecedenti valorizzata");

    Vector<Long> idDomandaAssegnazAnniPrecVect = new Vector<Long>(); 
    idDomandaAssegnazAnniPrecVect.add(idDomandaAssegnazioneAnniPrecedenti);
        
   
    SolmrLogger.debug(this, "-- controllo se c'è un ACCONTO anni precedenti");
    DomandaAssegnazione accontoAnniPrecedentiVO = umaFacadeClient.findAccontoNonAnnullatoByIdDomandaBase(idDomandaAssegnazioneAnniPrecedenti.longValue());
    // Se è stato trovato il record, memorizzo l'idDomandaAssegnazione
    if (accontoAnniPrecedentiVO != null){
      SolmrLogger.debug(this, "-- e' stato trovato l'acconto anni precedenti");
      idDomandaAssegnazAnniPrecVect.add(accontoAnniPrecedentiVO.getIdDomandaAssegnazione());
    }        
 
    // Query con gli idDomandaAssegnazione anni precedenti
    SolmrLogger.debug(this, "-- ricerca delle quantita' su DB_PRELIEVO");
    Vector elencoBuoniCarburante = umaFacadeClient.getDettaglioCarburanteByIdDomandaAssegnazione(idDomandaAssegnazAnniPrecVect);
   
    // --- Calcolo Rimanenza minima stimata al 31/12
    SolmrLogger.debug(this, "--- Calcolo Rimanenza minima stimata al 31/12");
    datiDisponibilitaPerAccontoVO = CarburanteUtil.processBuoniCarburanteForRimanenzaMinima((Vector) elencoBuoniCarburante,datiDisponibilitaPerAccontoVO, session);
    
    /* Per fare la validazione :
        verificare se è valorizzata almeno una rimanenza o un consumo di carburante,
        se è valorizzato un'assegnazione conto terrzi dell'ultima assegnazione validata
    */  
    SolmrLogger.debug(this, "--- controllo se c'è un'assegnazione conto terzi dell'ultima assegnazione validata");
    vCarburanteAssCTAssPrec = umaFacadeClient.hasAssegnazioneCarburanteUltimoAnno(idDomandaAssegnazioneAnniPrecedenti);
  }
  else{
    SolmrLogger.debug(this, "--- idDomandaAssegnazioneAnniPrecedenti NON valorizzata");
  }

  if (datiDisponibilitaPerAccontoVO != null){
    // Metto i datiDisponibilitaPerAccontoVO in request
    request.setAttribute("datiDisponibilitaPerAccontoVO",datiDisponibilitaPerAccontoVO);
  }

  if (request.getParameter("confermaConsumato") != null)
  {
    SolmrLogger.debug(this, " ------ CASO confermaConsumato");
    ValidationErrors errors = validate(request,
        datiDisponibilitaPerAccontoVO, ruoloUtenza,
        dittaUMAAziendaVO.getIdConduzione(),vCarburanteAssCTAssPrec,domandaAnniPrecedentiVO);

    datiDisponibilitaPerAccontoVO.makeTotals();
    if (errors != null && errors.size() > 0)
    {
      request.setAttribute("errors", errors);
    }
    else
    {
      ConsumoRimanenzaVO consumoRimanenzaBenzinaVO = new ConsumoRimanenzaVO();
      ConsumoRimanenzaVO consumoRimanenzaGasolioVO = new ConsumoRimanenzaVO();
      consumoRimanenzaBenzinaVO
          .setConsContoProp(datiDisponibilitaPerAccontoVO
              .getConsumoContoProprioBenzina());
      consumoRimanenzaBenzinaVO
          .setConsContoTer(datiDisponibilitaPerAccontoVO
              .getConsumoContoTerziBenzina());
      consumoRimanenzaBenzinaVO.setConsSerra(datiDisponibilitaPerAccontoVO
          .getConsumoSerraBenzina());
      consumoRimanenzaBenzinaVO
          .setConsContoProp(datiDisponibilitaPerAccontoVO
              .getRimanenzaContoProprioBenzina());
      consumoRimanenzaBenzinaVO
          .setConsContoTer(datiDisponibilitaPerAccontoVO
              .getRimanenzaContoTerziBenzina());
      consumoRimanenzaBenzinaVO.setConsSerra(datiDisponibilitaPerAccontoVO
          .getRimanenzaSerraBenzina());
      SolmrLogger.debug(this, " --- rimanenzeDichAltreAziendeBenzina ="+datiDisponibilitaPerAccontoVO.getRimanenzeDichAltreAziendeBenzina());    
      consumoRimanenzaBenzinaVO.setRimDichAltreAz(new Long(datiDisponibilitaPerAccontoVO.getRimanenzeDichAltreAziendeBenzina()));

      consumoRimanenzaGasolioVO
          .setConsContoProp(datiDisponibilitaPerAccontoVO
              .getConsumoContoProprioGasolio());
      consumoRimanenzaGasolioVO
          .setConsContoTer(datiDisponibilitaPerAccontoVO
              .getConsumoContoTerziGasolio());
      consumoRimanenzaGasolioVO.setConsSerra(datiDisponibilitaPerAccontoVO
          .getConsumoSerraGasolio());
      consumoRimanenzaGasolioVO
          .setConsContoProp(datiDisponibilitaPerAccontoVO
              .getRimanenzaContoProprioGasolio());
      consumoRimanenzaGasolioVO
          .setConsContoTer(datiDisponibilitaPerAccontoVO
              .getRimanenzaContoTerziGasolio());
      consumoRimanenzaGasolioVO.setConsSerra(datiDisponibilitaPerAccontoVO
          .getRimanenzaSerraGasolio());
      consumoRimanenzaGasolioVO.setRimDichAltreAz(new Long(
          datiDisponibilitaPerAccontoVO
              .getRimanenzeDichAltreAziendeGasolio()));

      SolmrLogger.debug(this, "AAAAAAAAAAAAAAA GAS: "
          + datiDisponibilitaPerAccontoVO
              .getRimanenzeDichAltreAziendeGasolio());
      SolmrLogger.debug(this, "AAAAAAAAAAAAAAA BENZ: "
          + datiDisponibilitaPerAccontoVO
              .getRimanenzeDichAltreAziendeBenzina());
     
      DomandaAssegnazione domandaAssegnazioneUpdate=new DomandaAssegnazione();  
      domandaAssegnazioneUpdate.setUtenteAggiornamento(ruoloUtenza.getIdUtente());
      domandaAssegnazioneUpdate.setIdDomandaAssegnazione(accontoVO.getIdDomandaAssegnazione());
      if ((Validator.isNotEmpty(datiDisponibilitaPerAccontoVO.getBenzinaOggettoFurto())
          && !"0".equals(datiDisponibilitaPerAccontoVO.getBenzinaOggettoFurto()))
      || (Validator.isNotEmpty(datiDisponibilitaPerAccontoVO.getGasolioOggettoFurto())
         && !"0".equals(datiDisponibilitaPerAccontoVO.getGasolioOggettoFurto())))
      {
        domandaAssegnazioneUpdate.setDataProtocolloFurto(it.csi.solmr.util.UmaDateUtils.parseDate(datiDisponibilitaPerAccontoVO.getDataProtocolloDenFurto()));
	      domandaAssegnazioneUpdate.setEstremiDenFurto(datiDisponibilitaPerAccontoVO.getEstremiDenFurto());
	      domandaAssegnazioneUpdate.setNumProtocolloDenFurto(datiDisponibilitaPerAccontoVO.getNumProtocolloDenFurto());        
      } 
              
      umaFacadeClient.insertConsumoRimanenza(creaArrayConsumoRimanenza(
          datiDisponibilitaPerAccontoVO, accontoVO.getIdDomandaAssegnazione(), ruoloUtenza.getIdUtente()),
          domandaAssegnazioneUpdate);
      response.sendRedirect(NEXT);
      return;
    }
  }

  SommeRimanenzeDaCessazioneVO sommeRimanenze = umaFacadeClient
      .findRimanenzeDitteCessateByCUAADestinatario(dittaUMAAziendaVO
          .getCuaa());
  if (sommeRimanenze != null)
  {
    request.setAttribute("sommeRimanenze", sommeRimanenze);
  }
%><jsp:forward page="<%=VIEW%>" />
<%!private ValidationErrors validate(HttpServletRequest request,
      DatiDisponibilitaPerAccontoVO datiDisponibilitaPerAccontoVO,
      RuoloUtenza ruoloUtenza, String idConduzione, Vector<String> vCarburanteAssCTAssPrec, DomandaAssegnazione domandaAnniPrecedentiVO) throws SolmrException
  {
    SolmrLogger.debug(this, "   BEGIN validate");
  
    ValidationErrors errors = new ValidationErrors();
    
    datiDisponibilitaPerAccontoVO.setGasolioOggettoFurto(request.getParameter("gasolioOggettoFurto"));
    datiDisponibilitaPerAccontoVO.setBenzinaOggettoFurto(request.getParameter("benzinaOggettoFurto"));
    datiDisponibilitaPerAccontoVO.setNumProtocolloDenFurto(request.getParameter("numProtocolloDenFurto"));
    datiDisponibilitaPerAccontoVO.setEstremiDenFurto(request.getParameter("estremiDenFurto"));
    datiDisponibilitaPerAccontoVO.setDataProtocolloDenFurto(request.getParameter("dataProtocolloDenFurto"));
    
    Long totDisponibilitaGasolio = datiDisponibilitaPerAccontoVO.getTotDisponibilitaGasolio();
    Long totDisponibilitaBenzina = datiDisponibilitaPerAccontoVO.getTotDisponibilitaBenzina();
    
    Long rimanenzaMinimaCPTGasolio = datiDisponibilitaPerAccontoVO.getRimanenzaMinimaCPTGasolio();
    Long rimanenzaMinimaCPTBenzina = datiDisponibilitaPerAccontoVO.getRimanenzaMinimaCPTBenzina();
    
    Long rimanenzaMinimaSerreBenzina = datiDisponibilitaPerAccontoVO.getRimanenzaMinimaSerreBenzina();
    Long rimanenzaMinimaSerreGasolio = datiDisponibilitaPerAccontoVO.getRimanenzaMinimaSerreGasolio();
    
    Long rimanenzaContoProprioGasolio = validateGenericLongField(request,"rimanenzaContoProprioGasolio", errors);
    Long rimanenzaContoProprioBenzina = validateGenericLongField(request,"rimanenzaContoProprioBenzina", errors);
    
    Long rimanenzaContoTerziGasolio = validateGenericLongField(request,"rimanenzaContoTerziGasolio", errors);
    SolmrLogger.debug(this, "--- rimanenzaContoTerziGasolio ="+rimanenzaContoTerziGasolio);
    Long rimanenzaContoTerziBenzina = validateGenericLongField(request,"rimanenzaContoTerziBenzina", errors);
    SolmrLogger.debug(this, "--- rimanenzaContoTerziBenzina ="+rimanenzaContoTerziBenzina);
    
    Long rimanenzaSerraGasolio = validateGenericLongField(request,"rimanenzaSerraGasolio", errors);
    Long rimanenzaSerraBenzina = validateGenericLongField(request,"rimanenzaSerraBenzina", errors);
    
    Long consumoContoProprioGasolio = validateGenericLongField(request,"consumoContoProprioGasolio", errors);
    Long consumoContoProprioBenzina = validateGenericLongField(request,"consumoContoProprioBenzina", errors);

    Long consumoContoTerziGasolio = NumberUtils.nvl(datiDisponibilitaPerAccontoVO.getConsumoContoTerziGasolio(),ZERO);
    Long consumoContoTerziBenzina = NumberUtils.nvl(datiDisponibilitaPerAccontoVO.getConsumoContoTerziBenzina(),ZERO);    
    SolmrLogger.debug(this, "--- consumoContoTerziGasolio: "+ datiDisponibilitaPerAccontoVO.getConsumoContoTerziGasolio());
    SolmrLogger.debug(this, "--- consumoContoTerziBenzina: "+ datiDisponibilitaPerAccontoVO.getConsumoContoTerziBenzina());

    Long consumoSerraGasolio = validateGenericLongField(request,"consumoSerraGasolio", errors);
    Long consumoSerraBenzina = validateGenericLongField(request,"consumoSerraBenzina", errors);
    
    Long gasolioOggettoFurto = validateGenericLongField(request,"gasolioOggettoFurto", errors);
    Long benzinaOggettoFurto = validateGenericLongField(request,"benzinaOggettoFurto", errors);
    
    // Faccio i totali
    datiDisponibilitaPerAccontoVO.setRimanenzaContoProprioGasolio(rimanenzaContoProprioGasolio);
    datiDisponibilitaPerAccontoVO.setRimanenzaContoProprioBenzina(rimanenzaContoProprioBenzina);
    datiDisponibilitaPerAccontoVO.setRimanenzaContoTerziGasolio(rimanenzaContoTerziGasolio);
    datiDisponibilitaPerAccontoVO.setRimanenzaContoTerziBenzina(rimanenzaContoTerziBenzina);
    datiDisponibilitaPerAccontoVO.setRimanenzaSerraGasolio(rimanenzaSerraGasolio);
    datiDisponibilitaPerAccontoVO.setRimanenzaSerraBenzina(rimanenzaSerraBenzina);
    datiDisponibilitaPerAccontoVO.setConsumoContoProprioGasolio(consumoContoProprioGasolio);
    datiDisponibilitaPerAccontoVO.setConsumoContoProprioBenzina(consumoContoProprioBenzina);
    datiDisponibilitaPerAccontoVO.setConsumoSerraGasolio(consumoSerraGasolio);
    datiDisponibilitaPerAccontoVO.setConsumoSerraBenzina(consumoSerraBenzina);
    
    String dataProtocollo=request.getParameter("dataProtocolloDenFurto");
    String numProtocolloDenFurto=request.getParameter("numProtocolloDenFurto");
    String estremiDenFurto=request.getParameter("estremiDenFurto");
    
    if (Validator.isNotEmpty(request.getParameter("gasolioOggettoFurto")) || 
      Validator.isNotEmpty(request.getParameter("benzinaOggettoFurto")))
    {
      // se il gasolio o la benzina sono valorizzati devono esserlo anche la data protocollo,
      // il num. protocollo e gli estremi della denuncia
      if (Validator.isEmpty(numProtocolloDenFurto))
        errors.add("numProtocolloDenFurto", new ValidationError("Campo obbligatorio se valorizzato il carburante oggetto di furto"));
      else
        if (numProtocolloDenFurto.length()>200)  
          errors.add("numProtocolloDenFurto", new ValidationError("Inserire al massimo 200 caratteri"));
      if (Validator.isEmpty(dataProtocollo))
        errors.add("dataProtocolloDenFurto", new ValidationError("Campo obbligatorio se valorizzato il carburante oggetto di furto"));
      if (Validator.isEmpty(estremiDenFurto))
        errors.add("estremiDenFurto", new ValidationError("Campo obbligatorio se valorizzato il carburante oggetto di furto"));    
      else if (estremiDenFurto.length()>500)  
             errors.add("estremiDenFurto", new ValidationError("Inserire al massimo 500 caratteri"));  
    }
    if (Validator.isNotEmpty(dataProtocollo))
    {
      //Verifico che la data sia valida
      if (!it.csi.solmr.util.UmaDateUtils.isValideDate(dataProtocollo))
        errors.add("dataProtocolloDenFurto", new ValidationError("Inserire una data nel formato gg/mm/aaaa"));
    }
    
    

    // Il totale delle disponibilità deve essere uguale alla somma  delle rimanenze attuali
    // e del consumo (relativamente al tipo di carburante) 
    if (!checkRimanenzaAttuale(rimanenzaContoProprioGasolio,
        rimanenzaContoTerziGasolio, rimanenzaSerraGasolio,
        consumoContoProprioGasolio, consumoContoTerziGasolio,
        consumoSerraGasolio, totDisponibilitaGasolio.longValue(),gasolioOggettoFurto))
    {
      SolmrLogger.debug(this, "CTRL checkRimanenzaAttuale");

      ValidationError error = new ValidationError(
          UmaErrors.ERR_VAL_DISPONIBILITA_NON_UGUALE_RIMANENZA_CONSUMO_GASOLIO);
      errors.add("rimanenzaContoProprioGasolio", error);
      errors.add("rimanenzaContoTerziGasolio", error);
      errors.add("rimanenzaSerraGasolio", error);
      errors.add("consumoContoProprioGasolio", error);
      errors.add("consumoSerraGasolio", error);
      errors.add("gasolioOggettoFurto", error);
    }
    else
    {
      long prelevatoPiuRimanenza = NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO.getPrelevatoGasolio())+ NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO.getRimanenzaPrecContoProprioGasolio())+ NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO.getRimanenzaPrecContoTerziGasolio());
      long prelevatoPiuRimanenzaS = NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO.getPrelevatoSerraGasolio())+ NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO.getRimanenzaPrecSerraGasolio());
      
      if (gasolioOggettoFurto!=null && gasolioOggettoFurto.longValue()!=0 &&
        prelevatoPiuRimanenza!=0 && prelevatoPiuRimanenzaS!=0)
      {
        //se ho inserito il carburante per furto ed ho il prelevato sia per serre che per conto terzi/proprio
        //non saprei a chi asociare il carburante per furto, quindi faccio un controllo globale
        
        if (!checkConsumiSerreContoProprioTerzi(prelevatoPiuRimanenza, prelevatoPiuRimanenzaS,
                                                rimanenzaContoProprioGasolio,rimanenzaContoTerziGasolio, consumoContoProprioGasolio,consumoContoTerziGasolio,
                                                rimanenzaSerraGasolio, consumoSerraGasolio, gasolioOggettoFurto.longValue()))
        {
          SolmrLogger.debug(this, "CTRL checkConsumiSerreContoProprioTerzi");
          ValidationError error = new ValidationError(
              UmaErrors.ERR_CONSUMO_CPT_SUPERIORE_RIMANENZE_PRELEVATO);
          errors.add("rimanenzaContoProprioGasolio", error);
          errors.add("rimanenzaContoTerziGasolio", error);
          errors.add("consumoContoProprioGasolio", error);
          errors.add("rimanenzaSerraGasolio", error);
          errors.add("consumoSerraGasolio", error);
          errors.add("gasolioOggettoFurto", error);
        }
      }
      else
      {
	      if (!checkConsumi(prelevatoPiuRimanenza, rimanenzaContoProprioGasolio,
	          rimanenzaContoTerziGasolio, consumoContoProprioGasolio,
	          consumoContoTerziGasolio,gasolioOggettoFurto))
	      {
	        SolmrLogger.debug(this, "CTRL checkConsumi");
	        ValidationError error = new ValidationError(
	            UmaErrors.ERR_CONSUMO_CPT_SUPERIORE_RIMANENZE_PRELEVATO);
	        errors.add("rimanenzaContoProprioGasolio", error);
	        errors.add("rimanenzaContoTerziGasolio", error);
	        errors.add("consumoContoProprioGasolio", error);
	      }
	      if (!checkConsumi(prelevatoPiuRimanenzaS, rimanenzaSerraGasolio, ZERO,
	          consumoSerraGasolio, ZERO,gasolioOggettoFurto))
	      {
	        ValidationError error = new ValidationError(
	            UmaErrors.ERR_CONSUMO_SERRE_SUPERIORE_RIMANENZE_PRELEVATO);
	        errors.add("rimanenzaSerraGasolio", error);
	        errors.add("consumoSerraGasolio", error);
	      }
      }
    }

    if (!checkRimanenzaAttuale(rimanenzaContoProprioBenzina,
        rimanenzaContoTerziBenzina, rimanenzaSerraBenzina,
        consumoContoProprioBenzina, consumoContoTerziBenzina,
        consumoSerraBenzina, totDisponibilitaBenzina.longValue(),benzinaOggettoFurto))
    {
      SolmrLogger.debug(this, "CTRL checkRimanenzaAttuale 2");
      ValidationError error = new ValidationError(
          UmaErrors.ERR_VAL_DISPONIBILITA_NON_UGUALE_RIMANENZA_CONSUMO_BENZINA);
      errors.add("rimanenzaContoProprioBenzina", error);
      errors.add("rimanenzaContoTerziBenzina", error);
      errors.add("rimanenzaSerraBenzina", error);
      errors.add("consumoContoProprioBenzina", error);
      errors.add("consumoSerraBenzina", error);
      errors.add("benzinaOggettoFurto", error);
    }
    else
    {
      long prelevatoPiuRimanenza = NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO.getPrelevatoBenzina())+ NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO.getRimanenzaPrecContoProprioBenzina())+ NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO.getRimanenzaPrecContoTerziBenzina());
      long prelevatoPiuRimanenzaS = NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO.getPrelevatoSerraBenzina())+ NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO.getRimanenzaPrecSerraBenzina());
      
      if (benzinaOggettoFurto!=null && benzinaOggettoFurto.longValue()!=0 &&
        prelevatoPiuRimanenza!=0 && prelevatoPiuRimanenzaS!=0)
      {
        //se ho inserito il carburante per furto ed ho il prelevato sia per serre che per conto terzi/proprio
        //non saprei a chi asociare il carburante per furto, quindi faccio un controllo globale
        
        if (!checkConsumiSerreContoProprioTerzi(prelevatoPiuRimanenza, prelevatoPiuRimanenzaS,
                                                rimanenzaContoProprioBenzina,rimanenzaContoTerziBenzina, consumoContoProprioBenzina,consumoContoTerziBenzina,
                                                rimanenzaSerraBenzina, consumoSerraBenzina, benzinaOggettoFurto.longValue()))
        {
          SolmrLogger.debug(this, "CTRL checkConsumiSerreContoProprioTerzi");
          ValidationError error = new ValidationError(
              UmaErrors.ERR_CONSUMO_CPT_SUPERIORE_RIMANENZE_PRELEVATO);
          errors.add("rimanenzaContoProprioBenzina", error);
		      errors.add("rimanenzaContoTerziBenzina", error);
		      errors.add("rimanenzaSerraBenzina", error);
		      errors.add("consumoContoProprioBenzina", error);
		      errors.add("consumoSerraBenzina", error);
		      errors.add("benzinaOggettoFurto", error);
        }
      }
      else
      {
	      if (!checkConsumi(prelevatoPiuRimanenza, rimanenzaContoProprioBenzina,
	          rimanenzaContoTerziBenzina, consumoContoProprioBenzina,
	          consumoContoTerziBenzina,benzinaOggettoFurto))
	      {
	        SolmrLogger.debug(this, "CTRL checkConsumi 2");
	        ValidationError error = new ValidationError(
	            UmaErrors.ERR_CONSUMO_CPT_SUPERIORE_RIMANENZE_PRELEVATO);
	        errors.add("rimanenzaContoProprioBenzina", error);
	        errors.add("rimanenzaContoTerziBenzina", error);
	        errors.add("consumoContoProprioBenzina", error);
	      }
	      
	      if (!checkConsumi(prelevatoPiuRimanenzaS, rimanenzaSerraBenzina, ZERO,
	          consumoSerraBenzina, ZERO,benzinaOggettoFurto))
	      {
	        ValidationError error = new ValidationError(
	            UmaErrors.ERR_CONSUMO_SERRE_SUPERIORE_RIMANENZE_PRELEVATO);
	        errors.add("consumoSerraBenzina", error);
	      }
      }
    }
    HttpSession sessione = request.getSession();
    // La serre e non serre deve essere superiore o uguale alla rimanenza minima
    // stimata (per tipo di carburante
    if (rimanenzaMinimaCPTBenzina==null) rimanenzaMinimaCPTBenzina=new Long(0);
    if (!checkRimanenzaMinimaNonSerre(rimanenzaContoProprioBenzina,
        rimanenzaContoTerziBenzina, rimanenzaMinimaCPTBenzina.longValue(),
        sessione))
    {
      if (!ruoloUtenza.isUtentePA())
      {
        ValidationError error = new ValidationError(
            UmaErrors.ERR_VAL_MANCATO_RISPETTO_RIMANENZA_MINIMA_STIMATA);
        errors.add("rimanenzaContoTerziBenzina", error);
        errors.add("rimanenzaContoProprioBenzina", error);
      }
    }

    if (rimanenzaMinimaCPTGasolio==null) rimanenzaMinimaCPTGasolio=new Long(0);
    if (!checkRimanenzaMinimaNonSerre(rimanenzaContoProprioGasolio,
        rimanenzaContoTerziGasolio, rimanenzaMinimaCPTGasolio.longValue(),
        sessione))
    {
      if (!ruoloUtenza.isUtentePA())
      {
        ValidationError error = new ValidationError(
            UmaErrors.ERR_VAL_MANCATO_RISPETTO_RIMANENZA_MINIMA_STIMATA);
        errors.add("rimanenzaContoTerziGasolio", error);
        errors.add("rimanenzaContoProprioGasolio", error);
      }
    }

    if (rimanenzaMinimaSerreBenzina==null) rimanenzaMinimaSerreBenzina=new Long(0); 
    if (!checkRimanenzaMinimaSerre(rimanenzaSerraBenzina,
        rimanenzaMinimaSerreBenzina.longValue(), sessione))
    {
      if (!ruoloUtenza.isUtentePA())
      {
        ValidationError error = new ValidationError(
            UmaErrors.ERR_VAL_MANCATO_RISPETTO_RIMANENZA_MINIMA_STIMATA);
        errors.add("rimanenzaSerreBenzina", error);
      }
    }

    if (rimanenzaMinimaSerreGasolio==null) rimanenzaMinimaSerreGasolio=new Long(0); 
    if (!checkRimanenzaMinimaSerre(rimanenzaSerraGasolio,
        rimanenzaMinimaSerreGasolio.longValue(), sessione))
    {
      if (!ruoloUtenza.isUtentePA())
      {
        ValidationError error = new ValidationError(
            UmaErrors.ERR_VAL_MANCATO_RISPETTO_RIMANENZA_MINIMA_STIMATA);
        errors.add("rimanenzaSerraGasolio", error);
      }
    }
    
    boolean dittaSenzaPrelievo=false;

    /* SMRUMA-577
      In caso di ditta Uma nuova (senza assegnazione precedente) oppure di ditta Uma senza prelevato sull'assegnazione 
      precedente il sistema consente di proseguire con l'acconto.
    */
    if (( datiDisponibilitaPerAccontoVO.getPrelevatoBenzina()==null ||
          datiDisponibilitaPerAccontoVO.getPrelevatoBenzina().longValue()==0)
        && (datiDisponibilitaPerAccontoVO.getPrelevatoSerraBenzina()==null ||
            datiDisponibilitaPerAccontoVO.getPrelevatoSerraBenzina().longValue()==0)
        && (datiDisponibilitaPerAccontoVO.getPrelevatoGasolio()==null ||
            datiDisponibilitaPerAccontoVO.getPrelevatoGasolio().longValue()==0)
        && (datiDisponibilitaPerAccontoVO.getPrelevatoSerraGasolio()==null ||
            datiDisponibilitaPerAccontoVO.getPrelevatoSerraGasolio().longValue()==0)
        )
        dittaSenzaPrelievo=true;
    
    if(ruoloUtenza.isUtentePA() && (domandaAnniPrecedentiVO==null || dittaSenzaPrelievo))
    {
      //non controllo e lascio proseguire
    }
    else  
	    if (!checkInserimentoConsumi(consumoContoProprioGasolio,
	        consumoContoProprioBenzina, datiDisponibilitaPerAccontoVO
	            .getConsumoContoTerziGasolio(), datiDisponibilitaPerAccontoVO
	            .getConsumoContoTerziBenzina(), consumoSerraGasolio,
	        consumoSerraBenzina))
	    {
	      ValidationError error = new ValidationError(
	          UmaErrors.ERR_ACCONTO_CON_CONSUMO_ZERO);
	
	      errors.add("consumoContoProprioGasolio", error);
	      errors.add("consumoContoProprioBenzina", error);
	      errors.add("consumoSerraGasolio", error);
	      errors.add("consumoSerraBenzina", error);
	    } 
    
    
    // CONTROLLI COMMENTATI PER TOBECONFIG
    /* Verificare se effettuare i controlli su :
        'Rimanenza Conto Terzi Gasolio' + 'Consumo Conto Terzi Gasolio' e
        'Rimanenza Conto Terzi Benzina' + 'Consumo Conto Terzi Benzina'
        -> non deve essere uguale a zero
    */
   /* if(vCarburanteAssCTAssPrec != null && vCarburanteAssCTAssPrec.contains(SolmrConstants.ID_GASOLIO)){
      SolmrLogger.debug(this, "-- E' valorizzata l'assegnazione conto terrzi GASOLIO dell'ultima assegnazione validata");
      // controllo se i campi 'Rimanenza Conto Terzi Gasolio' e 'Consumo Conto Terzi Gasolio' è valorizzato
      SolmrLogger.debug(this, "--- rimanenzaContoTerziGasolio ="+rimanenzaContoTerziGasolio);
      SolmrLogger.debug(this, "--- consumoContoTerziGasolio ="+consumoContoTerziGasolio);
      if(rimanenzaContoTerziGasolio != null && consumoContoTerziGasolio != null){
        if(rimanenzaContoTerziGasolio.longValue() + consumoContoTerziGasolio.longValue() == 0){
            ValidationError errAss = new ValidationError("La somma di rimanenza e consumo di gasolio conto terzi deve essere maggiore di zero");
            errors.add("rimanenzaContoTerziGasolio", errAss);            
        }
      }
    }
    
    if(vCarburanteAssCTAssPrec != null && vCarburanteAssCTAssPrec.contains(SolmrConstants.ID_BENZINA)){
      SolmrLogger.debug(this, "-- E' valorizzata l'assegnazione conto terrzi BENZINA dell'ultima assegnazione validata");
      SolmrLogger.debug(this, "--- rimanenzaContoTerziBenzina ="+rimanenzaContoTerziBenzina);
      SolmrLogger.debug(this, "--- consumoContoTerziBenzina ="+consumoContoTerziBenzina);
      if(rimanenzaContoTerziBenzina != null && consumoContoTerziBenzina != null){
        if(rimanenzaContoTerziBenzina.longValue() + consumoContoTerziBenzina.longValue() == 0){
            ValidationError errAss = new ValidationError("La somma di rimanenza e consumo di benzina conto terzi deve essere maggiore di zero");
            errors.add("rimanenzaContoTerziBenzina", errAss);            
        }
      }
    }*/
        
        
    SolmrLogger.debug(this, "   END validate");
    return errors;
  }

  private boolean checkInserimentoConsumi(Long consumoContoProprioGasolio,
      Long consumoContoProprioBenzina, Long consumoContoTerziGasolio,
      Long consumoContoTerziBenzina, Long consumoSerraGasolio,
      Long consumoSerraBenzina) throws SolmrException
  {
    SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneAccontoConsumiCtrl::checkInserimentoConsumi] consumoContoProprioGasolio  = "
                + consumoContoProprioGasolio);
    SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneAccontoConsumiCtrl::checkInserimentoConsumi] consumoContoProprioBenzina  = "
                + consumoContoProprioBenzina);
    SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneAccontoConsumiCtrl::checkInserimentoConsumi] consumoSerraGasolio  = "
                + consumoSerraGasolio);
    SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneAccontoConsumiCtrl::checkInserimentoConsumi] consumoSerraBenzina  = "
                + consumoSerraBenzina);
    // dato che consumoContoTerziGasolio e consumoContoTerziBenzina sono calcolati dal sistema 
    // non ne verifico la validità e li utilizzo direttamente 
    if (consumoContoProprioGasolio != null
        && consumoContoProprioBenzina != null && consumoSerraGasolio != null
        && consumoSerraBenzina != null)
    {
      long totale = consumoContoProprioBenzina.longValue()
          + consumoContoProprioGasolio.longValue()
          + consumoSerraBenzina.longValue() + consumoSerraGasolio.longValue()
          + NumberUtils.nvl(consumoContoTerziGasolio, ZERO).longValue()
          + NumberUtils.nvl(consumoContoTerziBenzina, ZERO).longValue();
      return totale > 0; // L'utente deve aver inserito un consumo > 0
    }
    else
    {
      return true;// Almeno uno dei campi interessati è errato (cioè inserito non correttamente
      // dall'utente ==> non faccio il controllo ==> ritorno true in modo da non visualizzare
      // nessun errore (verrà visualizzato l'errore per il campo sbagliato)
    }
  }

  private boolean checkConsumi(long prelevato, Long rimanenza1,
      Long rimanenza2, Long consumo1, Long consumo2, Long carburanteRubato) throws SolmrException
  {
    SolmrLogger.debug(this,
        "[verificaAssegnazioneAccontoConsumiCtrl::checkConsumi] prelevato  = "
            + prelevato);
    SolmrLogger.debug(this,
        "[verificaAssegnazioneAccontoConsumiCtrl::checkConsumi] rimanenza1 = "
            + rimanenza1);
    SolmrLogger.debug(this,
        "[verificaAssegnazioneAccontoConsumiCtrl::checkConsumi] rimanenza2 = "
            + rimanenza2);
    SolmrLogger.debug(this,
        "[verificaAssegnazioneAccontoConsumiCtrl::checkConsumi] consumo1 = "
            + consumo1);
    SolmrLogger.debug(this,
        "[verificaAssegnazioneAccontoConsumiCtrl::checkConsumi] consumo2 = "
            + consumo2);
    if (rimanenza1 != null && rimanenza2 != null && consumo1 != null
        && consumo2 != null)
    {
      long totale = prelevato - rimanenza1.longValue() - rimanenza2.longValue()
          - consumo1.longValue() - consumo2.longValue();
      if (carburanteRubato!=null && prelevato!=0)
        totale-=carburanteRubato.longValue();
      //          System.err.println("prelevato="+prelevato);
      //          System.err.println("rimanenza1="+rimanenza1);
      //          System.err.println("rimanenza2="+rimanenza2);
      //          System.err.println("consumo1="+consumo1);
      //          System.err.println("consumo2="+consumo2);
      //          System.err.println("totale="+totale);
      return totale == 0; // prelevato + rimanenza deve essere > consumo
    }
    else
    {
      return true;// Almeno uno dei campi interessati è errato (cioè inserito non correttamente
      // dall'utente ==> non faccio il controllo ==> ritorno true in modo da non visualizzare
      // nessun errore (verrà visualizzato l'errore per il campo sbagliato)
    }
  }
  
  private boolean checkConsumiSerreContoProprioTerzi(long prelevatoPiuRimanenza, long prelevatoPiuRimanenzaS,
			                                               Long rimanenzaContoProprioGasolio,
			                                               Long rimanenzaContoTerziGasolio, 
			                                               Long consumoContoProprioGasolio,
			                                               Long consumoContoTerziGasolio,
			                                               Long rimanenzaSerraGasolio, 
			                                               Long consumoSerraGasolio, 
			                                               long gasolioOggettoFurto) throws SolmrException
  {

    if (rimanenzaContoProprioGasolio != null && rimanenzaContoTerziGasolio != null && consumoContoProprioGasolio != null
        && consumoContoTerziGasolio != null && rimanenzaSerraGasolio!=null && consumoSerraGasolio!=null)
    {
      long totale = prelevatoPiuRimanenza + prelevatoPiuRimanenzaS - rimanenzaContoProprioGasolio.longValue() 
                  - rimanenzaContoTerziGasolio.longValue() - consumoContoProprioGasolio.longValue() 
                  - consumoContoTerziGasolio.longValue() - rimanenzaSerraGasolio.longValue() - consumoSerraGasolio.longValue()
                  - gasolioOggettoFurto;
      return totale == 0; // prelevato + rimanenza deve essere > consumo
    }
    else
    {
      return true;// Almeno uno dei campi interessati è errato (cioè inserito non correttamente
      // dall'utente ==> non faccio il controllo ==> ritorno true in modo da non visualizzare
      // nessun errore (verrà visualizzato l'errore per il campo sbagliato)
    }
  }

  private boolean checkRimanenzaMinimaNonSerre(Long rimanenzaContoProprio,
      Long rimanenzaContotTerzi, long rimanenzaMinimaStimata,
      HttpSession sessione) throws SolmrException
  {
    SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneAccontoConsumiCtrl::checkRimanenzaMinimaNonSerre] rimanenzaContoProprio  = "
                + rimanenzaContoProprio);
    SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneAccontoConsumiCtrl::checkRimanenzaMinimaNonSerre] rimanenzaContotTerzi = "
                + rimanenzaContotTerzi);
    SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneAccontoConsumiCtrl::checkRimanenzaMinimaNonSerre] rimanenzaMinimaStimata = "
                + rimanenzaMinimaStimata);
    if (rimanenzaContoProprio != null && rimanenzaContotTerzi != null)
    {
      long tolleranzaPT = CarburanteUtil
          .getParametroRimanenzaMinimaPT(sessione).longValue();
      return rimanenzaContoProprio.longValue()
          + rimanenzaContotTerzi.longValue() + tolleranzaPT >= rimanenzaMinimaStimata;
    }
    else
    {
      return true;// Almeno uno dei campi interessati è errato (cioè inserito non correttamente
      // dall'utente ==> non faccio il controllo ==> ritorno true in modo da non visualizzare
      // nessun errore (verrà visualizzato l'errore per il campo sbagliato)
    }
   
  }

  private boolean checkRimanenzaMinimaSerre(Long rimanenzaSerre,
      long rimanenzaMinimaStimata, HttpSession sessione) throws SolmrException
  {
    SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneAccontoConsumiCtrl::checkRimanenzaMinimaSerre] rimanenzaSerre  = "
                + rimanenzaSerre);
    SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneAccontoConsumiCtrl::checkRimanenzaMinimaSerre] consumoContoTerzi = "
                + rimanenzaMinimaStimata);

    if (rimanenzaSerre != null)
    {
      long tolleranzaSE = CarburanteUtil
          .getParametroRimanenzaMinimaSE(sessione).longValue();
      return rimanenzaSerre.longValue() + tolleranzaSE >= rimanenzaMinimaStimata;
    }
    else
    {
      return true;// Almeno uno dei campi interessati è errato (cioè inserito non correttamente
      // dall'utente ==> non faccio il controllo ==> ritorno true in modo da non visualizzare
      // nessun errore (verrà visualizzato l'errore per il campo sbagliato)
    }
  }

  private boolean checkRimanenzaAttuale(Long rimanenzaContoProprio,
      Long rimanenzaContoTerzi, Long rimanenzaSerra, Long consumoContoProprio,
      Long consumoContoTerzi, Long consumoSerra, long totaleDisponibilita, Long carburanteOggettoFurto)
  {
    SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneAccontoConsumiCtrl::checkRimanenzaAttuale] rimanenzaContoProprio  = "
                + rimanenzaContoProprio);
    SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneAccontoConsumiCtrl::checkRimanenzaAttuale] rimanenzaContoTerzi  = "
                + rimanenzaContoTerzi);
    SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneAccontoConsumiCtrl::checkRimanenzaAttuale] rimanenzaSerra  = "
                + rimanenzaSerra);
    SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneAccontoConsumiCtrl::checkRimanenzaAttuale] consumoContoProprio  = "
                + consumoContoProprio);
    SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneAccontoConsumiCtrl::checkRimanenzaAttuale] consumoContoTerzi = "
                + consumoContoTerzi);
    SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneAccontoConsumiCtrl::checkRimanenzaAttuale] consumoSerra  = "
                + consumoSerra);
    SolmrLogger
        .debug(
            this,
            "[verificaAssegnazioneAccontoConsumiCtrl::checkRimanenzaAttuale]  totaleDisponibilita = "
                + totaleDisponibilita);
    if (rimanenzaContoProprio != null && rimanenzaContoTerzi != null
        && rimanenzaSerra != null && consumoContoProprio != null
        && consumoContoTerzi != null && consumoSerra != null)
    {
      if (carburanteOggettoFurto==null) carburanteOggettoFurto=new Long(0);
      long totaleConsumiRimanenze = rimanenzaContoProprio.longValue()
          + rimanenzaContoTerzi.longValue() + rimanenzaSerra.longValue()
          + consumoContoProprio.longValue() + consumoContoTerzi.longValue()
          + consumoSerra.longValue()+carburanteOggettoFurto.longValue();
      return totaleDisponibilita == totaleConsumiRimanenze; // TRUE Se sono UGUALI
    }
    return true; // Almeno uno dei campi interessati è errato (cioè inserito non correttamente
    // dall'utente ==> non faccio il controllo ==> ritorno true in modo da non visualizzare
    // nessun errore (verrà visualizzato l'errore per il campo sbagliato)
  }

  private Long validateGenericLongField(HttpServletRequest request,
      String fieldName, ValidationErrors errors)
  {
    try
    {
      String sValue = request.getParameter(fieldName);
      if (Validator.isEmpty(sValue))
      {
        return ZERO;
      }
      Long value = new Long(sValue.trim());
      if (value.longValue() < 0)
      {
        errors.add(fieldName, new ValidationError(
            UmaErrors.ERR_VAL_VALORE_NEGATIVO));
        return null;
      }
      return value;
    }
    catch (Exception e)
    {
      errors.add(fieldName, new ValidationError(
          UmaErrors.ERR_VAL_VALORE_NON_NUMERICO_INTERO));
      return null;
    }
  }

  private DomandaAssegnazione creaAccontoVO(
      DomandaAssegnazione domandaAnniPrecedentiVO,
      DittaUMAAziendaVO dittaUMAAziendaVO, RuoloUtenza ruoloUtenza)
  {
    DomandaAssegnazione accontoVO = new DomandaAssegnazione();
    
    
    //SMRUMA-577 INIZIO
    if (domandaAnniPrecedentiVO!=null)
    {
    //SMRUMA-577 FINE
	    accontoVO.setExtIdConsistenza(domandaAnniPrecedentiVO.getExtIdConsistenza());
	    accontoVO.setDataConsistenza(domandaAnniPrecedentiVO.getDataConsistenza());
    }
    accontoVO.setIdStatoDomanda(new Long(SolmrConstants.ID_STATO_DOMANDA_ACCONTO_IN_BOZZA));
    accontoVO.setIdDitta(dittaUMAAziendaVO.getIdDittaUMA().longValue());
    accontoVO.setTipoDomanda(SolmrConstants.TIPO_DOMANDA_ACCONTO);
    if (!ruoloUtenza.isUtentePA())
    {
      accontoVO.setExtIdIntermediario(ruoloUtenza.getIdUtente());
    }
    accontoVO.setRuoloUtenza(ruoloUtenza);
    return accontoVO;
  }

  private boolean isNotNullAndNotZero(Long value)
  {
    return value != null && !ZERO.equals(value);
  }

  private ConsumoRimanenzaVO[] creaArrayConsumoRimanenza(
      DatiDisponibilitaPerAccontoVO datiDisponibilitaPerAccontoVO,
      Long idDomandaAssegnazione, Long idUtenteAggiornamento)
  {
    Vector consumiRimanenze = new Vector();

    Long rimanenzaContoProprioGasolio = datiDisponibilitaPerAccontoVO
        .getRimanenzaContoProprioGasolio();
    Long rimanenzaContoProprioBenzina = datiDisponibilitaPerAccontoVO
        .getRimanenzaContoProprioBenzina();
    Long rimanenzaContoTerziGasolio = datiDisponibilitaPerAccontoVO
        .getRimanenzaContoTerziGasolio();
    Long rimanenzaContoTerziBenzina = datiDisponibilitaPerAccontoVO
        .getRimanenzaContoTerziBenzina();
    Long rimanenzaSerraGasolio = datiDisponibilitaPerAccontoVO
        .getRimanenzaSerraGasolio();
    Long rimanenzaSerraBenzina = datiDisponibilitaPerAccontoVO
        .getRimanenzaSerraBenzina();
    Long consumoContoProprioGasolio = datiDisponibilitaPerAccontoVO
        .getConsumoContoProprioGasolio();
    Long consumoContoProprioBenzina = datiDisponibilitaPerAccontoVO
        .getConsumoContoProprioBenzina();
    Long consumoContoTerziGasolio = datiDisponibilitaPerAccontoVO
        .getConsumoContoTerziGasolio();
    Long consumoContoTerziBenzina = datiDisponibilitaPerAccontoVO
        .getConsumoContoTerziBenzina();
    Long consumoSerraGasolio = datiDisponibilitaPerAccontoVO
        .getConsumoSerraGasolio();
    Long consumoSerraBenzina = datiDisponibilitaPerAccontoVO
        .getConsumoSerraBenzina();
        
    Long gasolioOggettoFurto=null;
    Long benzinaOggettoFurto=null;
    
    if (!Validator.isEmpty(datiDisponibilitaPerAccontoVO.getGasolioOggettoFurto()))
      gasolioOggettoFurto=new Long(datiDisponibilitaPerAccontoVO.getGasolioOggettoFurto());
      
    if (!Validator.isEmpty(datiDisponibilitaPerAccontoVO.getBenzinaOggettoFurto()))
      benzinaOggettoFurto=new Long(datiDisponibilitaPerAccontoVO.getBenzinaOggettoFurto());  

    Long rimanenzeDichAltreAziendeGasolio = new Long(
        datiDisponibilitaPerAccontoVO.getRimanenzeDichAltreAziendeGasolio());

    Long rimanenzeDichAltreAziendeBenzina = new Long(
        datiDisponibilitaPerAccontoVO.getRimanenzeDichAltreAziendeBenzina());

    if (isNotNullAndNotZero(rimanenzaContoProprioBenzina)
        || isNotNullAndNotZero(rimanenzaContoTerziBenzina)
        || isNotNullAndNotZero(rimanenzaSerraBenzina)
        || isNotNullAndNotZero(consumoContoProprioBenzina)
        || isNotNullAndNotZero(consumoContoTerziBenzina)
        || isNotNullAndNotZero(consumoSerraBenzina)
        || isNotNullAndNotZero(benzinaOggettoFurto))
    {
      ConsumoRimanenzaVO crVO = new ConsumoRimanenzaVO();
      crVO.setIdCarburante(new Integer(SolmrConstants.ID_BENZINA));
      crVO.setIdDomandaAssegnazione(idDomandaAssegnazione);
      crVO.setConsContoProp(NumberUtils.nvl(consumoContoProprioBenzina, ZERO));
      crVO.setConsContoTer(NumberUtils.nvl(consumoContoTerziBenzina, ZERO));
      crVO.setConsSerra(NumberUtils.nvl(consumoSerraBenzina, ZERO));
      crVO.setRimContoProp(NumberUtils.nvl(rimanenzaContoProprioBenzina, ZERO));
      crVO.setRimContoTer(NumberUtils.nvl(rimanenzaContoTerziBenzina, ZERO));
      crVO.setRimSerra(NumberUtils.nvl(rimanenzaSerraBenzina, ZERO));
      crVO.setIdUtenteAgg(idUtenteAggiornamento);
      crVO.setRimDichAltreAz(rimanenzeDichAltreAziendeBenzina);
      crVO.setCarburanteRubato(benzinaOggettoFurto);
      consumiRimanenze.add(crVO);
    }

    if (isNotNullAndNotZero(rimanenzaContoProprioGasolio)
        || isNotNullAndNotZero(rimanenzaContoTerziGasolio)
        || isNotNullAndNotZero(rimanenzaSerraGasolio)
        || isNotNullAndNotZero(consumoContoProprioGasolio)
        || isNotNullAndNotZero(consumoContoTerziGasolio)
        || isNotNullAndNotZero(consumoSerraGasolio)
        || isNotNullAndNotZero(gasolioOggettoFurto))
    {
      ConsumoRimanenzaVO crVO = new ConsumoRimanenzaVO();
      crVO.setIdDomandaAssegnazione(idDomandaAssegnazione);
      crVO.setIdCarburante(new Integer(SolmrConstants.ID_GASOLIO));
      crVO.setConsContoProp(NumberUtils.nvl(consumoContoProprioGasolio, ZERO));
      crVO.setConsContoTer(NumberUtils.nvl(consumoContoTerziGasolio, ZERO));
      crVO.setConsSerra(NumberUtils.nvl(consumoSerraGasolio, ZERO));
      crVO.setRimContoProp(NumberUtils.nvl(rimanenzaContoProprioGasolio, ZERO));
      crVO.setRimContoTer(NumberUtils.nvl(rimanenzaContoTerziGasolio, ZERO));
      crVO.setRimSerra(NumberUtils.nvl(rimanenzaSerraGasolio, ZERO));
      crVO.setIdUtenteAgg(idUtenteAggiornamento);
      crVO.setRimDichAltreAz(rimanenzeDichAltreAziendeGasolio);
      crVO.setCarburanteRubato(gasolioOggettoFurto);
      consumiRimanenze.add(crVO);
    }

    return (ConsumoRimanenzaVO[]) consumiRimanenze
        .toArray(new ConsumoRimanenzaVO[consumiRimanenze.size()]);
  }%>