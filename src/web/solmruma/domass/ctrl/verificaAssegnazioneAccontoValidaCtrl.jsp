<%@ page language="java" contentType="text/html" isErrorPage="false"%> 
<%@page import="it.csi.solmr.client.uma.UmaFacadeClient"%>
<%@page import="it.csi.solmr.dto.uma.DomandaAssegnazione"%>
<%@page import="it.csi.solmr.etc.SolmrConstants"%>
<%@page import="it.csi.solmr.dto.uma.DatiDisponibilitaPerAccontoVO"%>
<%@page import="it.csi.solmr.etc.uma.UmaErrors"%>
<%@page import="it.csi.solmr.util.CarburanteUtil"%>
<%@page import="java.util.Vector"%>
<%@page import="it.csi.solmr.exception.SolmrException"%>
<%@page import="it.csi.solmr.dto.uma.AssegnazioneCarburanteAggrVO"%>
<%@page import="it.csi.solmr.dto.uma.SommeRimanenzeDaCessazioneVO"%>
<%@page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO"%>
<%@page import="it.csi.solmr.dto.uma.DebitoVO"%>
<%@page import="it.csi.solmr.util.*"%>
<%@page import="it.csi.solmr.dto.profile.RuoloUtenza"%>

<%!// Costanti
  public static final Long    ZERO      = new Long(0);
  private static final String VIEW      = "/domass/view/verificaAssegnazioneAccontoValidaView.jsp";
  public final static String  CLOSE_URL = "../layout/assegnazioniAcconto.htm";
%>
<%
  request.setAttribute("closeUrl", CLOSE_URL);
  String iridePageName = "verificaAssegnazioneAccontoValidaCtrl.jsp";
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

  Vector assegnazioneCorrente = umaFacadeClient.getAssegnazioniCarburante(accontoVO
      .getIdDomandaAssegnazione(), SolmrConstants.ID_TIPO_ASSEGNAZIONE);
  if (assegnazioneCorrente != null && assegnazioneCorrente.size() == 1)
  {
    AssegnazioneCarburanteAggrVO assegnazioneCarburanteAggrVO = (AssegnazioneCarburanteAggrVO) assegnazioneCorrente
        .get(0);
    request.setAttribute("assegnazioneCarburanteAggrVO",
        assegnazioneCarburanteAggrVO);
  }

  String strPercentualeContoProprioPerAcconto = umaFacadeClient
      .getParametro(SolmrConstants.PARAMETRO_PERCENTUALE_CONTO_PROPRIO_ACCONTO);
  String strPercentualeContoTerziPerAcconto = umaFacadeClient
      .getParametro(SolmrConstants.PARAMETRO_PERCENTUALE_CONTO_TERZI_ACCONTO);
  long percentualeContoProprioPerAcconto = 0;
  long percentualeContoTerziPerAcconto = 0;
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
    throw new SolmrException(UmaErrors.ERRORE_PARAMETRO_PRAC_NON_VALIDO);
  }
  Long idDomandaAssegnazioneAnniPrecedenti = domandaAnniPrecedentiVO != null ? domandaAnniPrecedentiVO
      .getIdDomandaAssegnazione()
      : null;

  DatiDisponibilitaPerAccontoVO datiDisponibilitaPerAccontoVO = umaFacadeClient
      .getDatiDisponibilitaPerAcconto(idDomandaAssegnazioneAnniPrecedenti,
          accontoVO.getIdDomandaAssegnazione());
          
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
 

  if (datiDisponibilitaPerAccontoVO != null)
  {
    // Metto i datiDisponibilitaPerAccontoVO in request
    request.setAttribute("datiDisponibilitaPerAccontoVO",
        datiDisponibilitaPerAccontoVO);
  }
  
  /*
    sostituito con una chiamata ad un plsql PCK_SMRUMA_ASSEGNAZ_CARB.calcolo_assegnazione_acconto 
    datiDisponibilitaPerAccontoVO.calcolaMaxAssegnabileAcconto(percentualeContoProprioPerAcconto,percentualeContoTerziPerAcconto);
  */
  
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  datiDisponibilitaPerAccontoVO=umaFacadeClient.calcoloAssAcconto(datiDisponibilitaPerAccontoVO,accontoVO.getIdDomandaAssegnazione(),ruoloUtenza.getIdUtente());      
        
        
  // Calcolo delle eventuali rimanenze da cessazione di altre ditte      
  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");
  SommeRimanenzeDaCessazioneVO sommeRimanenze=umaFacadeClient.findRimanenzeDitteCessateByCUAADestinatario(dittaUMAAziendaVO.getCuaa());
  if (sommeRimanenze!=null)
  {
    request.setAttribute("sommeRimanenze",sommeRimanenze);
  }
  
  int annoriferimento=DateUtils.getCurrentYear().intValue() - 1;
  try
  {
    annoriferimento=UmaDateUtils.extractYearFromDate(domandaAnniPrecedentiVO.getDataRiferimento());
  }
  catch(Exception e){}
  
  DebitoVO debitoVO = umaFacadeClient.getDebitoDitta(dittaUMAAziendaVO.getIdDittaUMA().longValue(),annoriferimento);
  long debitoContoProprioTerzi =0;
  long debitoSerra = 0;
  if (debitoVO != null)
  {
    request.setAttribute("debitoVO", debitoVO);
    debitoContoProprioTerzi = CarburanteUtil
        .getDebitoContoProprioTerzi(debitoVO, NumberUtils
            .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
                .getPrelevatoGasolio()) + NumberUtils
            .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
                .getPrelevatoBenzina()));
    debitoSerra = CarburanteUtil.getDebitoSerra(debitoVO, NumberUtils
        .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
            .getPrelevatoSerraGasolio()) + NumberUtils
        .getLongValueZeroOnNull(datiDisponibilitaPerAccontoVO
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
        request.setAttribute("debitoContoProprioTerzi",new Long(debitoContoProprioTerzi));
      }
      if (debitoSerra > 0)
      {
        // debitoSerra[0] ==> gasolio, debitoSerra[1] ==> benzina.
        request.setAttribute("debitoSerra",new Long(debitoSerra));
      }
    }
  }
%><jsp:forward page="<%=VIEW%>" />