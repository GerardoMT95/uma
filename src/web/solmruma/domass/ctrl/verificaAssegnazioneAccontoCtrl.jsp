<%@ page language="java" contentType="text/html" isErrorPage="false"%>
<%@page import="it.csi.solmr.client.uma.UmaFacadeClient"%>
<%@page import="it.csi.solmr.dto.uma.DomandaAssegnazione"%>
<%@page import="it.csi.solmr.etc.SolmrConstants"%>
<%@page import="it.csi.solmr.dto.uma.DatiDisponibilitaPerAccontoVO"%>
<%@page import="it.csi.solmr.util.ValidationErrors"%>
<%@page import="it.csi.solmr.etc.uma.UmaErrors"%>
<%@page import="it.csi.solmr.util.ValidationError"%>
<%@page import="it.csi.solmr.util.Validator"%>
<%@page import="it.csi.solmr.util.CarburanteUtil"%>
<%@page import="java.util.Vector"%>
<%@page import="it.csi.solmr.exception.SolmrException"%>
<%@page import="it.csi.solmr.dto.uma.AssegnazioneCarburanteAggrVO"%>
<%@page import="it.csi.solmr.util.NumberUtils"%>
<%@page import="it.csi.solmr.dto.uma.QuantitaAssegnataVO"%>
<%@page import="it.csi.solmr.dto.uma.AssegnazioneCarburanteVO"%>
<%@page import="it.csi.solmr.dto.profile.RuoloUtenza"%>
<%@page import="java.util.Date"%>
<%@page import="it.csi.solmr.util.StringUtils"%>
<%@page import="it.csi.solmr.dto.uma.SommeRimanenzeDaCessazioneVO"%>
<%@page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO"%>
<%@page import="it.csi.solmr.dto.uma.DebitoVO"%>
<%@page import="it.csi.solmr.util.*"%>

<%!// Costanti
  public static final Long    ZERO      = new Long(0);
  private static final String VIEW      = "/domass/view/verificaAssegnazioneAccontoView.jsp";
  public final static String  CLOSE_URL = "../layout/assegnazioni.htm";
  private static final String NEXT      = "../layout/verificaAssegnazioneAccontoSalvata.htm";%>
<%
  session.removeAttribute("ASSEGNAZIONE_VALIDA");
  request.setAttribute("closeUrl", CLOSE_URL);
  request.setAttribute("noValidazione", new Boolean(true));
  String iridePageName = "verificaAssegnazioneAccontoCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%
  /********************************************************************************/
  // Se sono arrivato qui, vuol dire che ho superato i controlli di abilitazioni
  // ed in request mi trovo l'acconto e la domanda dell'anno precedente (ovviamente
  // solo se esistono!)
  /********************************************************************************/

  DomandaAssegnazione accontoVO = (DomandaAssegnazione) request
      .getAttribute("accontoVO");
  DomandaAssegnazione domandaAnniPrecedentiVO = (DomandaAssegnazione) request
      .getAttribute("domandaAnniPrecedentiVO");

  UmaFacadeClient umaFacadeClient = (UmaFacadeClient) request
      .getAttribute("umaFacadeClient");
      
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  Vector assegnazioneCorrente = umaFacadeClient.getAssegnazioniCarburante(
      accontoVO.getIdDomandaAssegnazione(),
      SolmrConstants.ID_TIPO_ASSEGNAZIONE);
  if (assegnazioneCorrente != null && assegnazioneCorrente.size() == 1)
  {
    AssegnazioneCarburanteAggrVO assegnazioneCarburanteAggrVO = (AssegnazioneCarburanteAggrVO) assegnazioneCorrente
        .get(0);
    request.setAttribute("assegnazioneCarburanteAggrVO",
        assegnazioneCarburanteAggrVO);
  }

  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");
          

  int annoriferimento=DateUtils.getCurrentYear().intValue() - 1;
  try
  {
    annoriferimento=UmaDateUtils.extractYearFromDate(domandaAnniPrecedentiVO.getDataRiferimento());
  }
  catch(Exception e){}

  DebitoVO debitoVO = umaFacadeClient.getDebitoDitta(dittaUMAAziendaVO.getIdDittaUMA().longValue(), annoriferimento);

  String strPercentualeContoProprioPerAcconto = umaFacadeClient
      .getParametro(SolmrConstants.PARAMETRO_PERCENTUALE_CONTO_PROPRIO_ACCONTO);
  String strPercentualeContoTerziPerAcconto = umaFacadeClient
      .getParametro(SolmrConstants.PARAMETRO_PERCENTUALE_CONTO_TERZI_ACCONTO);
  /*
      SMRUMA-577 START
    */    
  String strPercentualeAccontoSenzaPrelievo = umaFacadeClient
      .getParametro(SolmrConstants.PARAMETRO_PERCENTUALE_ACCONTO_SENZA_PRELIEVO);
  String strMassimoAssegnabileDitteNuove = umaFacadeClient
      .getParametro(SolmrConstants.PARAMETRO_MASSIMO_ASSEGNABILE_DITTE_NUOVE);    
      
      
  boolean serre=umaFacadeClient.isDittaUmaConSerre(dittaUMAAziendaVO.getIdDittaUMA().longValue());    
      
  long percentualeContoProprioPerAcconto = 0;
  long percentualeContoTerziPerAcconto = 0;
  long percentualeAccontoSenzaPrelievo = 0;
  long massimoAssegnabileDitteNuove = 0;
  
  try
  {
    percentualeContoProprioPerAcconto = new Long(
        strPercentualeContoProprioPerAcconto).longValue();
  }
  catch (Exception e)
  {
    throw new SolmrException(UmaErrors.ERRORE_PARAMETRO_PRAC_NON_VALIDO);
  }
  try
  {
    percentualeContoTerziPerAcconto = new Long(
        strPercentualeContoTerziPerAcconto).longValue();
  }
  catch (Exception e)
  {
    throw new SolmrException(UmaErrors.ERRORE_PARAMETRO_PRAT_NON_VALIDO);
  }
  
  try
  {
    percentualeAccontoSenzaPrelievo = new Long(
        strPercentualeAccontoSenzaPrelievo).longValue();
  }
  catch (Exception e)
  {
    throw new SolmrException(UmaErrors.ERRORE_PARAMETRO_PRAP_NON_VALIDO);
  }
  
  try
  {
    massimoAssegnabileDitteNuove = new Long(
        strMassimoAssegnabileDitteNuove).longValue();
  }
  catch (Exception e)
  {
    throw new SolmrException(UmaErrors.ERRORE_PARAMETRO_UMAM_NON_VALIDO);
  }
  
  /*
      SMRUMA-577 END
  */
  
  Long idDomandaAssegnazioneAnniPrecedenti = domandaAnniPrecedentiVO != null ? domandaAnniPrecedentiVO
      .getIdDomandaAssegnazione()
      : null;

  DatiDisponibilitaPerAccontoVO datiDisponibilitaPerAccontoVO = umaFacadeClient.getDatiDisponibilitaPerAcconto(idDomandaAssegnazioneAnniPrecedenti,accontoVO.getIdDomandaAssegnazione());

  //aggiungo i dati relativi al furto
  if (accontoVO.getDataProtocolloFurto()!=null)
    datiDisponibilitaPerAccontoVO.setDataProtocolloDenFurto(it.csi.solmr.util.UmaDateUtils.formatDate(accontoVO.getDataProtocolloFurto()));
  
  datiDisponibilitaPerAccontoVO.setEstremiDenFurto(accontoVO.getEstremiDenFurto());
  datiDisponibilitaPerAccontoVO.setNumProtocolloDenFurto(accontoVO.getNumProtocolloDenFurto());
  
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
  }
  else{
    SolmrLogger.debug(this, "--- idDomandaAssegnazioneAnniPrecedenti NON valorizzata");
  }
  
  
  
  // Calcolo delle eventuali rimanenze da cessazione di altre ditte      
  SommeRimanenzeDaCessazioneVO sommeRimanenze = umaFacadeClient
      .findRimanenzeDitteCessateByCUAADestinatario(dittaUMAAziendaVO
          .getCuaa());
  if (sommeRimanenze != null)
  {
    request.setAttribute("sommeRimanenze", sommeRimanenze);
  }

  if (datiDisponibilitaPerAccontoVO != null)
  {
    

    //datiDisponibilitaPerAccontoVO.setRimAltreAziendeBenzina(fdaVO.getRimanenzeDichAltreAziendeBenzina());
    //datiDisponibilitaPerAccontoVO.setRimAltreAziendeGasolio(fdaVO.getRimanenzeDichAltreAziendeGasolio());

   /*
    sostituito con una chiamata ad un plsql PCK_SMRUMA_ASSEGNAZ_CARB.calcolo_assegnazione_acconto 
    datiDisponibilitaPerAccontoVO.calcolaMaxAssegnabileAccontopercentualeContoProprioPerAcconto, percentualeContoTerziPerAcconto);
   */
   
    datiDisponibilitaPerAccontoVO=umaFacadeClient.calcoloAssAcconto(datiDisponibilitaPerAccontoVO,accontoVO.getIdDomandaAssegnazione(),ruoloUtenza.getIdUtente());
    
    
    // Metto i datiDisponibilitaPerAccontoVO in request
    request.setAttribute("datiDisponibilitaPerAccontoVO",
        datiDisponibilitaPerAccontoVO);
    
    /*
      SMRUMA-577 START
    */
    boolean dittaSenzaPrelievo=false;

    /* 
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
        
    DittaUMAAziendaVO dittaUmaAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
    
    String strIdConduzione=dittaUmaAziendaVO.getIdConduzione();
    Long idConduzione=null;
    
    try
    {
      idConduzione=Long.parseLong(strIdConduzione);
    }
    catch(Exception e)
    {}
 
    
    Long condContoProprio=(Long)SolmrConstants.get("IDCONDUZIONECONTOPROPRIO");
    Long condContoTerzi=(Long)SolmrConstants.get("IDCONDUZIONECONTOTERZI");
    Long condContoProprioTerzi=(Long)SolmrConstants.get("IDCONDUZIONECONTOPROPRIOETERZI");
        
    /*
      Ora il massimo assegnabile lo determina sempre il pl, quindi le linee seguenti non servono più
    if (ruoloUtenza.isUtentePA() && (domandaAnniPrecedentiVO==null))
    {
      if (condContoProprio.equals(idConduzione))
        datiDisponibilitaPerAccontoVO.setMassimoAssegnabileContoProprio(massimoAssegnabileDitteNuove);
        
      if (condContoTerzi.equals(idConduzione))
        datiDisponibilitaPerAccontoVO.setMassimoAssegnabileContoTerzi(massimoAssegnabileDitteNuove);
        
      if (condContoProprioTerzi.equals(idConduzione))
      {
        datiDisponibilitaPerAccontoVO.setMassimoAssegnabileContoProprio(massimoAssegnabileDitteNuove);
        datiDisponibilitaPerAccontoVO.setMassimoAssegnabileContoTerzi(massimoAssegnabileDitteNuove);    
      } 
      if (serre)
        datiDisponibilitaPerAccontoVO.setMassimoAssegnabileSerre(massimoAssegnabileDitteNuove);
    }
    
    if (ruoloUtenza.isUtentePA() && (domandaAnniPrecedentiVO!=null) && dittaSenzaPrelievo)
    {
       long assegnazioneContoProprio = NumberUtils.getLongValueZeroOnNull(debitoVO.getAssegnazioneContoProprio());
       datiDisponibilitaPerAccontoVO.setMassimoAssegnabileContoProprio(
          new Long(NumberUtils.round((assegnazioneContoProprio * percentualeAccontoSenzaPrelievo) / 100.0)));
    
       long assegnazioneContoTerzi = NumberUtils.getLongValueZeroOnNull(debitoVO.getAssegnazioneContoTerzi());
       datiDisponibilitaPerAccontoVO.setMassimoAssegnabileContoTerzi(
          new Long(NumberUtils.round((assegnazioneContoTerzi * percentualeAccontoSenzaPrelievo) / 100.0)));
       
       long assegnazioneSerra = NumberUtils.getLongValueZeroOnNull(debitoVO.getAssegnazioneSerra());
       datiDisponibilitaPerAccontoVO.setMassimoAssegnabileSerre(
          new Long(NumberUtils.round((assegnazioneSerra * percentualeAccontoSenzaPrelievo) / 100.0)));
      
    }
    */
    /*
      SMRUMA-577 END
    */
    
    long totRimanenzeNonSerreContoProprio = NumberUtils
        .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
            .getRimanenzaContoProprioBenzina())
        + NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
            .getRimanenzaContoProprioGasolio());
            
    long totRimanenzeNonSerreContoTerzi = NumberUtils
        .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
            .getRimanenzaContoTerziBenzina())
        + NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
            .getRimanenzaContoTerziGasolio());
            
    long totRimanenzePerSerre = NumberUtils
        .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
            .getRimanenzaSerraBenzina())
        + NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
            .getRimanenzaSerraGasolio());
            
    boolean isRimanenzeSuperioriMaxAssCP = totRimanenzeNonSerreContoProprio >= NumberUtils
        .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
            .getMassimoAssegnabileContoProprio());
            
    boolean isRimanenzeSuperioriMaxAssCT = totRimanenzeNonSerreContoTerzi >= NumberUtils
        .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
            .getMassimoAssegnabileContoTerzi());
            
    boolean isRimanenzeSuperioriMaxSerre = totRimanenzePerSerre >= NumberUtils
        .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
            .getMassimoAssegnabileSerre());
            
    if (isRimanenzeSuperioriMaxAssCP && isRimanenzeSuperioriMaxAssCT
        && isRimanenzeSuperioriMaxSerre)
    {
      addErroreGrave(request,
          UmaErrors.ERR_VAL_RIMANENZE_ATTUALI_MAGGIORI_MASSIMO_ASSEGNABILE);
    }
    else
    {
      setInRequestIfTrue(request, "CP_DISABLED",
          isRimanenzeSuperioriMaxAssCP);
      setInRequestIfTrue(request, "CT_DISABLED",
          isRimanenzeSuperioriMaxAssCT);
      setInRequestIfTrue(request, "SERRE_DISABLED",
          isRimanenzeSuperioriMaxSerre);
    }
    if (sommeRimanenze != null)
    {
      long maxAssegnabileNonSerra = NumberUtils
          .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
              .getMassimoAssegnabileContoProprio())
          + NumberUtils
              .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
                  .getMassimoAssegnabileContoTerzi());
      long sommaRimanenzeDaCessazioneCPT = sommeRimanenze
          .getSommaContoProprioTerziBenzina()
          + sommeRimanenze.getSommaContoProprioTerziGasolio();
      if (maxAssegnabileNonSerra < sommaRimanenzeDaCessazioneCPT)
      {
        request.setAttribute("CP_DISABLED", Boolean.TRUE);
        request.setAttribute("CT_DISABLE", Boolean.TRUE);
        request.setAttribute("SERRE_DISABLE", Boolean.TRUE);
        addErroreGrave(
            request,
            UmaErrors.ERR_VAL_RIMANENZE_DA_CESSAZIONE_SUPERIORI_MASSIMO_ASSEGNABILE);
      }
      else
      {
        long maxAssegnabileSerra = NumberUtils
            .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
                .getMassimoAssegnabileSerre());
        long sommaRimanenzeDaCessazioneSerra = sommeRimanenze
            .getSommaSerraBenzina()
            + sommeRimanenze.getSommaSerraGasolio();
        if (maxAssegnabileSerra < sommaRimanenzeDaCessazioneSerra)
        {
          request.setAttribute("CP_DISABLED", Boolean.TRUE);
          request.setAttribute("CT_DISABLE", Boolean.TRUE);
          request.setAttribute("SERRE_DISABLE", Boolean.TRUE);
          addErroreGrave(
              request,
              UmaErrors.ERR_VAL_RIMANENZE_DA_CESSAZIONE_SUPERIORI_MASSIMO_ASSEGNABILE);
        }
      }
    }
  }
  long massimoAssegnabileContoProprioTerzi = NumberUtils
      .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
          .getMassimoAssegnabileContoProprio())
      + NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
          .getMassimoAssegnabileContoTerzi());
  long debitoContoProprioTerzi = 0;
  long debitoSerra = 0;
  if (debitoVO != null)
  {
    request.setAttribute("debitoVO", debitoVO);
    debitoContoProprioTerzi = CarburanteUtil.getDebitoContoProprioTerzi(
        debitoVO, NumberUtils
            .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
                .getPrelevatoGasolio())
            + NumberUtils
                .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
                    .getPrelevatoBenzina()));
    debitoSerra = CarburanteUtil.getDebitoSerra(debitoVO, NumberUtils
        .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
            .getPrelevatoSerraGasolio())
        + NumberUtils.getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
            .getPrelevatoSerraBenzina()));
    // Testo se almeno uno dei 2 debiti è diverso da null. I metodi getDebitoContoProprioTerzi
    // e getDebitoSerra ritornano un valore se e solo se esiste almeno un valore di debito per
    // il conto proprio/terzi e per le serre. Il fatto che esista un record di debito non 
    // implica che esista un debito effettivo. Il record rappresenta solo un debito teorico,
    // il debito vero esiste solo nel caso che la formuletta:
    // QTA_PRELEVATA - QTA_ASS_NETTA_PRECEDENTE + DEBITO_PRECEDENTE 
    // restituisca una valore > 0 (calcolo effettuato dai 2 metodi sopra indicati)              
    if (debitoContoProprioTerzi + debitoSerra > 0)
    {
      // Esiste il debito
      if (debitoContoProprioTerzi > 0)
      {
        // debitoContoProprioTerzi[0] ==> gasolio, debitoContoProprioTerzi[1] ==> benzina.
        request.setAttribute("debitoContoProprioTerzi", new Long(
            debitoContoProprioTerzi));
      }
      if (debitoSerra > 0)
      {
        // debitoSerra[0] ==> gasolio, debitoSerra[1] ==> benzina.
        request.setAttribute("debitoSerra", new Long(debitoSerra));
      }
    }
    if (debitoContoProprioTerzi > 0
        && debitoContoProprioTerzi >= massimoAssegnabileContoProprioTerzi)
    {
      addErroreGrave(request,
          UmaErrors.ERRORE_DEBITO_CPT_TROPPO_GRANDE_PER_ACCONTO);
    }
    if (debitoSerra > 0
        && debitoSerra >= NumberUtils
            .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
                .getMassimoAssegnabileSerre()))
    {
      addErroreGrave(request,
          UmaErrors.ERRORE_DEBITO_SERRA_TROPPO_GRANDE_PER_ACCONTO);
    }
  }

  if (request.getParameter("confermaConsumato") != null
      && request.getAttribute("ERRORE_GRAVE") == null)
  {
    Vector assegnazioniVect = new Vector();
    Long idDomandaAssegnazione = accontoVO.getIdDomandaAssegnazione();
    SolmrLogger.debug(this, "-- idDomandaAssegnazione ="+idDomandaAssegnazione);
    Date dataRiferimentoDomandaAssegnaz = accontoVO.getDataRiferimento();
    SolmrLogger.debug(this, "-- dataRiferimentoDomandaAssegnaz ="+dataRiferimentoDomandaAssegnaz);
    ValidationErrors errors = validate(request, idDomandaAssegnazione,
        datiDisponibilitaPerAccontoVO, assegnazioniVect, umaFacadeClient,
        debitoContoProprioTerzi, debitoSerra);
    if (errors != null && errors.size() > 0)
    {
      request.setAttribute("errors", errors);
    }
    else
    {      
      AssegnazioneCarburanteAggrVO acaVO = new AssegnazioneCarburanteAggrVO();
      AssegnazioneCarburanteVO acVO = new AssegnazioneCarburanteVO();
      // Inserisco i dati del protocollo
      String numeroProtocollo = request.getParameter("numeroProtocollo");
      if (Validator.isNotEmpty(numeroProtocollo))
      {
        // Se almeno 1 dei 2 campi è valorizzato sono entrambi valorizzati e 
        // quindi li registro sul db (se non è valorizzato neanche l'altro lo è)
        acVO.setNumeroProtocollo(numeroProtocollo);
        acVO.setDataProtocollo(request.getParameter("dataProtocollo"));
      }
      acVO.setIdDomandaAssegnazione(idDomandaAssegnazione);
      acVO.setDataRiferimentoDomandaAssegnazione(dataRiferimentoDomandaAssegnaz);
      acVO.setIdTipoAssegnazione(SolmrConstants.ID_TIPO_ASSEGNAZIONE);
      acVO.setNumSupplemento(new Integer(
          SolmrConstants.NUMERO_SUPPLEMENTO_PER_ASSEGNAZIONE_BASE));
      acVO.setIdUtenteAgg(ruoloUtenza.getIdUtente());
      acaVO.setAssegnazioneCarburante(acVO);
      acaVO.setQuantitaAssegnata(assegnazioniVect);
      
      
      SolmrLogger.debug(this, " ----- DELETE / INSERT sul db : Assegnazione carburante,Quantita assegnata ----");
      SolmrLogger.debug(this, " ----- e UPDATE sul db : Domanda assegnazione ----");
      
      Long massimoAssegnCP = datiDisponibilitaPerAccontoVO.getMassimoAssegnabileContoProprio();
      SolmrLogger.debug(this, "--- massimoAssegnCP ="+massimoAssegnCP);
      Long massimoAssegnSerra = datiDisponibilitaPerAccontoVO.getMassimoAssegnabileSerre();
      SolmrLogger.debug(this, "--- massimoAssegnSerra ="+massimoAssegnSerra);
      Long massimoAssegnCT = datiDisponibilitaPerAccontoVO.getMassimoAssegnabileContoTerzi();
      SolmrLogger.debug(this, "--- massimoAssegnCT ="+massimoAssegnCT);
      
      acaVO.setMassimoAssegnabileContoProprio(massimoAssegnCP);
      acaVO.setMassimoAssegnabileSerra(massimoAssegnSerra);
      acaVO.setMassimoAssegnabileContoTerzi(massimoAssegnCT);
      
      
      if (accontoVO.getDataProtocolloFurto()!=null)
      {
	      acaVO.setDataProtocolloDenFurto(it.csi.solmr.util.UmaDateUtils.formatDate(accontoVO.getDataProtocolloFurto()));
			  acaVO.setEstremiDenFurto(accontoVO.getEstremiDenFurto());
			  acaVO.setNumProtocolloDenFurto(accontoVO.getNumProtocolloDenFurto());
      }
      
      umaFacadeClient.replaceOrInsertAssegnazioneCarburante(acaVO,ruoloUtenza);
      
      
      session.setAttribute("ASSEGNAZIONE_VALIDA", Boolean.TRUE);
      response.sendRedirect(NEXT);
      return;
    }
  }
%><jsp:forward page="<%=VIEW%>" /><%!public void validateAssegnazioniPerFormaGiuridica(ValidationErrors errors,
      DittaUMAAziendaVO duVO, Long assNettaContoProprioBenzina,
      Long assNettaContoProprioGasolio, Long assNettaContoTerziBenzina,
      Long assNettaContoTerziGasolio)
  {
    long idConduzione = NumberUtils.getLongValueZeroOnNull(duVO
        .getIdConduzione());
    if (SolmrConstants.IDCONDUZIONECONTOPROPRIO.longValue() == idConduzione)
    {
      if ((assNettaContoTerziBenzina != null && assNettaContoTerziBenzina
          .longValue() > 0)
          || (assNettaContoTerziGasolio != null && assNettaContoTerziGasolio
              .longValue() > 0))
      {
        ValidationError error = new ValidationError(
            UmaErrors.ERR_VAL_ASS_NETTA_CONTO_TERZI_SU_DITTA_CONTO_PROPRIO);
        if (assNettaContoTerziBenzina != null
            && assNettaContoTerziBenzina.longValue() > 0)
        {
          errors.add("assNettaContoTerziBenzina", error);
        }
        if (assNettaContoTerziGasolio != null
            && assNettaContoTerziGasolio.longValue() > 0)
        {
          errors.add("assNettaContoTerziGasolio", error);
        }
      }
    }

    if (SolmrConstants.IDCONDUZIONECONTOTERZI.longValue() == idConduzione)
    {
      if ((assNettaContoProprioBenzina != null && assNettaContoProprioBenzina
          .longValue() > 0)
          || (assNettaContoProprioGasolio != null && assNettaContoProprioGasolio
              .longValue() > 0))
      {
        ValidationError error = new ValidationError(
            UmaErrors.ERR_VAL_ASS_NETTA_CONTO_TERZI_SU_DITTA_CONTO_PROPRIO);
        if (assNettaContoProprioBenzina != null
            && assNettaContoProprioBenzina.longValue() > 0)
        {
          errors.add("assNettaContoProprioBenzina", error);
        }
        if (assNettaContoProprioGasolio != null
            && assNettaContoProprioGasolio.longValue() > 0)
        {
          errors.add("assNettaContoProprioGasolio", error);
        }
      }
    }

  }

  private ValidationErrors validate(HttpServletRequest request,
      Long idDomandaAssegnazione,
      DatiDisponibilitaPerAccontoVO datiDisponibilitaPerAccontoVO,
      Vector assegnazioni, UmaFacadeClient umaFacadeClient,
      long debitoContoProprioTerzi, long debitoSerra) throws SolmrException
  {

    ValidationErrors errors = new ValidationErrors();

    Long assNettaContoProprioBenzina = validateGenericLongField(request,
        "assNettaContoProprioBenzina", errors);
    Long assNettaContoProprioGasolio = validateGenericLongField(request,
        "assNettaContoProprioGasolio", errors);

    Long assNettaContoTerziGasolio = validateGenericLongField(request,
        "assNettaContoTerziGasolio", errors);
    Long assNettaContoTerziBenzina = validateGenericLongField(request,
        "assNettaContoTerziBenzina", errors);

    Long assNettaRiscSerraBenzina = validateGenericLongField(request,
        "assNettaRiscSerraBenzina", errors);
    Long assNettaRiscSerraGasolio = validateGenericLongField(request,
        "assNettaRiscSerraGasolio", errors);
    validateAssegnazioniPerFormaGiuridica(errors, (DittaUMAAziendaVO) request
        .getSession().getAttribute("dittaUMAAziendaVO"),
        assNettaContoProprioBenzina, assNettaContoProprioGasolio,
        assNettaContoTerziBenzina, assNettaContoTerziGasolio);
    long maxAssegnabileCPT = datiDisponibilitaPerAccontoVO
        .getMassimoAssegnabileContoProprio().longValue()
        + datiDisponibilitaPerAccontoVO.getMassimoAssegnabileContoTerzi()
            .longValue();
    boolean checkDebitoCPT = true;
    if (!checkAssegnazioneAndDisponibilita(datiDisponibilitaPerAccontoVO
        .getTotRimanenzaContoProprio()
        + datiDisponibilitaPerAccontoVO.getTotRimanenzaContoTerzi(),
        maxAssegnabileCPT, assNettaContoProprioGasolio,
        assNettaContoProprioBenzina))
    {
      checkDebitoCPT = false;
      ValidationError error = new ValidationError(
          UmaErrors.ERR_VAL_ASS_NETTA_PIU_DISPONIBILITA_NON_CONFORMI_ACCONTO);
      if (!ZERO.equals(assNettaContoProprioGasolio))
      {
        errors.add("assNettaContoProprioGasolio", error);
      }
      if (!ZERO.equals(assNettaContoProprioBenzina))
      {
        errors.add("assNettaContoProprioBenzina", error);
      }
    }
    if (!checkAssegnazioneAndDisponibilita(datiDisponibilitaPerAccontoVO
        .getTotRimanenzaContoTerzi(), datiDisponibilitaPerAccontoVO
        .getMassimoAssegnabileContoTerzi().longValue(),
        assNettaContoTerziGasolio, assNettaContoTerziBenzina))
    {
      checkDebitoCPT = false;
      ValidationError error = new ValidationError(
          UmaErrors.ERR_VAL_ASS_NETTA_PIU_DISPONIBILITA_NON_CONFORMI_ACCONTO);
      if (!ZERO.equals(assNettaContoTerziGasolio))
      {
        errors.add("assNettaContoTerziGasolio", error);
      }
      if (!ZERO.equals(assNettaContoTerziBenzina))
      {
        errors.add("assNettaContoTerziBenzina", error);
      }
    }

    if (checkDebitoCPT)
    {
      if (!checkAssegnazioneCPT(debitoContoProprioTerzi, maxAssegnabileCPT,
          assNettaContoProprioGasolio, assNettaContoProprioBenzina,
          assNettaContoTerziGasolio, assNettaContoTerziBenzina))
      {
        ValidationError error = new ValidationError(
            UmaErrors.ERR_VAL_ASS_NETTA_CPT_PIU_DEBITO_NON_CONFORMI_ACCONTO);
        if (!ZERO.equals(assNettaContoProprioGasolio))
        {
          errors.add("assNettaContoProprioGasolio", error);
        }
        if (!ZERO.equals(assNettaContoProprioBenzina))
        {
          errors.add("assNettaContoProprioBenzina", error);
        }
        if (!ZERO.equals(assNettaContoTerziGasolio))
        {
          errors.add("assNettaContoTerziGasolio", error);
        }
        if (!ZERO.equals(assNettaContoTerziBenzina))
        {
          errors.add("assNettaContoTerziBenzina", error);
        }
      }
    }

    if (!checkAssegnazioneAndDisponibilita(datiDisponibilitaPerAccontoVO
        .getTotRimanenzaSerre(), datiDisponibilitaPerAccontoVO
        .getMassimoAssegnabileSerre().longValue(), assNettaRiscSerraGasolio,
        assNettaRiscSerraBenzina))
    {
      ValidationError error = new ValidationError(
          UmaErrors.ERR_VAL_ASS_NETTA_PIU_DISPONIBILITA_NON_CONFORMI_ACCONTO);
      if (!ZERO.equals(assNettaRiscSerraGasolio))
      {
        errors.add("assNettaRiscSerraGasolio", error);
      }
      if (!ZERO.equals(assNettaRiscSerraBenzina))
      {
        errors.add("assNettaRiscSerraBenzina", error);
      }
    }
    else
    {
      if (!checkAssegnazioneAndDisponibilita(debitoSerra,
          datiDisponibilitaPerAccontoVO.getMassimoAssegnabileSerre()
              .longValue(), assNettaRiscSerraGasolio, assNettaRiscSerraBenzina))
      {
        ValidationError error = new ValidationError(
            UmaErrors.ERR_VAL_ASS_NETTA_SERRA_PIU_DEBITO_NON_CONFORMI_ACCONTO);
        if (!ZERO.equals(assNettaRiscSerraGasolio))
        {
          errors.add("assNettaRiscSerraGasolio", error);
        }
        if (!ZERO.equals(assNettaRiscSerraBenzina))
        {
          errors.add("assNettaRiscSerraBenzina", error);
        }
      }
    }

    // Se l'utente ha inserito assegnazione CP BENZINA ==> la ditta uma DEVE AVERE in carico una macchina a Benzina
    if (!checkMacchina(assNettaContoProprioBenzina, SolmrConstants.ID_BENZINA,
        umaFacadeClient, idDomandaAssegnazione))
    {
      errors
          .add(
              "assNettaContoProprioBenzina",
              new ValidationError(
                  UmaErrors.ERR_VAL_NECESSARIA_MACCHINA_BENZINA_PER_ASSEGNAZIONE_BENZINA));
    }

    // Se l'utente ha inserito assegnazione CP GASOLIO ==> la ditta uma DEVE AVERE in carico una macchina a Gasolio
    if (!checkMacchina(assNettaContoProprioGasolio, SolmrConstants.ID_GASOLIO,
        umaFacadeClient, idDomandaAssegnazione))
    {
      errors
          .add(
              "assNettaContoProprioBenzina",
              new ValidationError(
                  UmaErrors.ERR_VAL_NECESSARIA_MACCHINA_GASOLIO_PER_ASSEGNAZIONE_GASOLIO));
    }

    // Se l'utente ha inserito assegnazione SERRA BENZINA ==> la ditta uma DEVE AVERE in carico una macchina a Benzina
    if (!checkBruciatore(assNettaRiscSerraBenzina, SolmrConstants.ID_BENZINA,
        umaFacadeClient, idDomandaAssegnazione))
    {
      errors
          .add(
              "assNettaRiscSerraBenzina",
              new ValidationError(
                  UmaErrors.ERR_VAL_NECESSARIA_MACCHINA_BENZINA_PER_ASSEGNAZIONE_BENZINA));
    }

    // Se l'utente ha inserito assegnazione SERRA GASOLIO ==> la ditta uma DEVE AVERE in carico una macchina a Gasolio
    if (!checkBruciatore(assNettaRiscSerraGasolio, SolmrConstants.ID_GASOLIO,
        umaFacadeClient, idDomandaAssegnazione))
    {
      errors
          .add(
              "assNettaRiscSerraGasolio",
              new ValidationError(
                  UmaErrors.ERR_VAL_NECESSARIA_MACCHINA_GASOLIO_PER_ASSEGNAZIONE_GASOLIO));
    }

    String numeroProtocollo = StringUtils.checkNull(
        request.getParameter("numeroProtocollo")).trim();
    String dataProcollo = request.getParameter("dataProtocollo");
    int size = errors.size();
    if (Validator.isNotEmpty(numeroProtocollo))
    {
      if (numeroProtocollo.length() > 50)
      {
        errors.add("numeroProtocollo", new ValidationError(
            UmaErrors.ERR_VAL_CAMPO_TROPPO_LUNGO_INSERIRE_MAX_CARATTERI
                + " 50 caratteri"));
      }
    }
    Date date = Validator.validateDateAll(dataProcollo, "dataProtocollo",
        "data protocollo", errors, false, true);
    if (errors.size() == size
        && (Validator.isNotEmpty(numeroProtocollo) != (date != null)))
    {
      // se non ci sono altri errori oltre a quelli precedenti alla validazione del protocollo e i
      // dati del protocollo non sono entrambi valorizzati/non valorizzati segnalo errore
      ValidationError error = new ValidationError(
          UmaErrors.ERR_VAL_DATA_E_NUMERO_PROTOCOLLO_ACCONTO_NON_COERENTI);
      errors.add("dataProtocollo", error);
      errors.add("numeroProtocollo", error);
    }

    long assNettaCPBenzina = NumberUtils
        .getLongValueZeroOnNull(assNettaContoProprioBenzina);
    long assNettaCTBenzina = NumberUtils
        .getLongValueZeroOnNull(assNettaContoTerziBenzina);
    long assNettaSerraBenzina = NumberUtils
        .getLongValueZeroOnNull(assNettaRiscSerraBenzina);
    long assNettaCPGasolio = NumberUtils
        .getLongValueZeroOnNull(assNettaContoProprioGasolio);
    long assNettaCTGasolio = NumberUtils
        .getLongValueZeroOnNull(assNettaContoTerziGasolio);
    long assNettaSerraGasolio = NumberUtils
        .getLongValueZeroOnNull(assNettaRiscSerraGasolio);
    if (assNettaContoProprioBenzina != null
        && assNettaContoTerziBenzina != null
        && assNettaRiscSerraBenzina != null
        && assNettaContoProprioGasolio != null
        && assNettaContoTerziGasolio != null
        && assNettaRiscSerraGasolio != null
        && (assNettaCPBenzina + assNettaCPGasolio + assNettaCTBenzina
            + assNettaCTGasolio + assNettaSerraBenzina + assNettaSerraGasolio == 0))
    {
      ValidationError error = new ValidationError(
          UmaErrors.ERR_ASSEGNAZIONE_A_ZERO_NON_PERMESSA_IN_ACCONTO);
      errors.add("assNettaRiscSerraGasolio", error);
      errors.add("assNettaRiscSerraBenzina", error);
      errors.add("assNettaContoProprioGasolio", error);
      errors.add("assNettaContoProprioBenzina", error);
      errors.add("assNettaContoTerziGasolio", error);
      errors.add("assNettaContoTerziBenzina", error);
    }

    if (errors.size() == 0)
    {
      if (assNettaCPBenzina > 0 || assNettaSerraBenzina > 0
          || assNettaCTBenzina > 0)
      {
        QuantitaAssegnataVO qtaVO = new QuantitaAssegnataVO();
        qtaVO.setAssContoProp(new Long(assNettaCPBenzina));
        qtaVO.setAssSerra(new Long(assNettaSerraBenzina));
        qtaVO.setAssContoTer(new Long(assNettaCTBenzina));
        qtaVO.setIdCarburante(new Integer(SolmrConstants.ID_BENZINA));
        assegnazioni.add(qtaVO);
      }

      if (assNettaCPGasolio > 0 || assNettaSerraGasolio > 0
          || assNettaCTGasolio > 0)
      {
        QuantitaAssegnataVO qtaVO = new QuantitaAssegnataVO();
        qtaVO.setAssContoProp(new Long(assNettaCPGasolio));
        qtaVO.setAssSerra(new Long(assNettaSerraGasolio));
        qtaVO.setAssContoTer(new Long(assNettaCTGasolio));
        qtaVO.setIdCarburante(new Integer(SolmrConstants.ID_GASOLIO));
        assegnazioni.add(qtaVO);
      }
    }
    return errors;
  }

  private boolean checkMacchina(Long assegnazione, String idCarburante,
      UmaFacadeClient umaFacadeClient, Long idDomandaAssegnazione)
      throws SolmrException
  {
    if (assegnazione != null && assegnazione.longValue() > 0)
    {
      return umaFacadeClient.esisteMacchina(idDomandaAssegnazione, new Integer(
          idCarburante));
    }
    return true; // Il campo interessato è errato (cioè inserito non correttamente
    // dall'utente ==> non faccio il controllo ==> ritorno true in modo da non visualizzare
    // nessun errore (verrà visualizzato l'errore per il campo sbagliato)
  }

  private boolean checkBruciatore(Long assegnazione, String idCarburante,
      UmaFacadeClient umaFacadeClient, Long idDomandaAssegnazione)
      throws SolmrException
  {
    if (assegnazione != null && assegnazione.longValue() > 0)
    {
      return umaFacadeClient.esisteBruciatore(idDomandaAssegnazione,
          new Integer(idCarburante));
    }
    return true; // Il campo interessato è errato (cioè inserito non correttamente
    // dall'utente ==> non faccio il controllo ==> ritorno true in modo da non visualizzare
    // nessun errore (verrà visualizzato l'errore per il campo sbagliato)
  }

  private boolean checkAssegnazioneAndDisponibilita(long totaleDisponibilita,
      long massimoAssegnabile, Long assegnazioneNettaGasolio,
      Long assegnazioneNettaBenzina)
  {
    if (assegnazioneNettaGasolio != null && assegnazioneNettaBenzina != null)
    {
      long totaleAssegnazione = assegnazioneNettaGasolio.longValue()
          + assegnazioneNettaBenzina.longValue();
      return totaleDisponibilita + totaleAssegnazione <= massimoAssegnabile; // TRUE Se sono UGUALI
    }
    return true; // Almeno uno dei campi interessati è errato (cioè inserito non correttamente
    // dall'utente ==> non faccio il controllo ==> ritorno true in modo da non visualizzare
    // nessun errore (verrà visualizzato l'errore per il campo sbagliato)
  }

  private boolean checkAssegnazioneCPT(long totaleDisponibilita,
      long massimoAssegnabile, Long assegnazioneNettaContoProprioGasolio,
      Long assegnazioneNettaContoProprioBenzina,
      Long assegnazioneNettaContoTerziGasolio,
      Long assegnazioneNettaContoTerziBenzina)
  {
    if (assegnazioneNettaContoProprioGasolio != null
        && assegnazioneNettaContoProprioBenzina != null
        && assegnazioneNettaContoTerziGasolio != null
        && assegnazioneNettaContoTerziBenzina != null)
    {
      long totaleAssegnazione = assegnazioneNettaContoProprioGasolio
          .longValue()
          + assegnazioneNettaContoProprioBenzina.longValue()
          + assegnazioneNettaContoTerziGasolio.longValue()
          + assegnazioneNettaContoTerziBenzina.longValue();
      return totaleDisponibilita + totaleAssegnazione <= massimoAssegnabile; // TRUE Se sono UGUALI
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

  private void addErroreGrave(HttpServletRequest request, String messaggio)
  {
    String errore = (String) request.getAttribute("ERRORE_GRAVE");
    if (errore == null)
    {
      errore = messaggio;
    }
    else
    {
      errore = new StringBuffer().append(errore).append("<br />").append(
          messaggio).toString();
    }
    request.setAttribute("ERRORE_GRAVE",messaggio);
    request.setAttribute("CP_DISABLED",Boolean.TRUE);
    request.setAttribute("CT_DISABLED",Boolean.TRUE);
    request.setAttribute("SERRE_DISABLED",Boolean.TRUE);
  }
  
  public void setInRequestIfTrue(HttpServletRequest request, String name,
      boolean value)
  {
    if (value)
    {
      request.setAttribute(name, Boolean.TRUE);
    }
  }%>