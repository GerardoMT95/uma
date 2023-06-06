
<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<jsp:useBean id="frmVerificaAssegnazioneVO" scope="request"
 class="it.csi.solmr.dto.uma.FrmVerificaAssegnazioneVO">
  <jsp:setProperty name="frmVerificaAssegnazioneVO" property="*" />
</jsp:useBean>
<%!
  private static final String VIEW_URL="/domass/view/verificaAssegnazioneView.jsp";
  private static final String NEXT_PAGE="../layout/verificaAssegnazioneSalvata.htm";
%>
<%

  String iridePageName = "verificaAssegnazioneCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "BEGIN verificaAssegnazioneCtrl");		  
		  
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  UmaFacadeClient client = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  SommeRimanenzeDaCessazioneVO sommeRimanenze=client.findRimanenzeDitteCessateByCUAADestinatario(dittaUMAAziendaVO.getCuaa());
  if (sommeRimanenze!=null)
  {
    request.setAttribute("sommeRimanenze",sommeRimanenze);
  }      
  DebitoVO debitoVO = client.getDebitoDitta(dittaUMAAziendaVO
      .getIdDittaUMA().longValue(),
      DateUtils.getCurrentYear().intValue() - 1);
        
  if (request.getParameter("conferma.x")!=null)
  {
    FrmDettaglioAssegnazioneVO daVO=new FrmDettaglioAssegnazioneVO();
    daVO.setAltreMacchine(new Long(request.getParameter("altreMacchine")));
    frmVerificaAssegnazioneVO.setFrmDettaglioAssegnazioneVO(daVO);
    frmVerificaAssegnazioneVO.formatFields();
    ValidationErrors errors=
        client.controllaVerificaAssegnazione(frmVerificaAssegnazioneVO,ruoloUtenza, sommeRimanenze);
//    frmVerificaAssegnazioneVO.formatFields();
    SolmrLogger.debug(this,"errors="+errors);
    if (errors!=null && errors.size()>0)
    {
      request.setAttribute("errors",errors);
    }
    else
    {
      response.sendRedirect(NEXT_PAGE);
      return;
    }
  }
  else
  {
    try
    {
      HashMap provincieValidazioneIntermediario = (HashMap) session.getAttribute("provincieValidazioneIntermediario");
      HashMap formeGiuridicheValidazionePA = (HashMap) session.getAttribute("formeGiuridicheValidazionePA");
      Long idFormaGiuridica = dittaUMAAziendaVO.getIdFormaGiuridica();

      frmVerificaAssegnazioneVO=
          client.getVerificaAssegnazione(idDittaUma, provincieValidazioneIntermediario, idFormaGiuridica, formeGiuridicheValidazionePA);

      SolmrLogger.debug(this, "\n\n\n\n\n\n***##***##***##***##***##***##***##***##***##");
      SolmrLogger.debug(this, "frmVerificaAssegnazioneVO: "+frmVerificaAssegnazioneVO);
      SolmrLogger.debug(this, "frmVerificaAssegnazioneVO.getConsumoSerraBenzina(): "+frmVerificaAssegnazioneVO.getConsumoSerraBenzina());
      SolmrLogger.debug(this, "frmVerificaAssegnazioneVO.getConsumoSerraBenzinaLong(): "+frmVerificaAssegnazioneVO.getConsumoSerraBenzinaLong());
      SolmrLogger.debug(this, "frmVerificaAssegnazioneVO.getConsumoSerraGasolio(): "+frmVerificaAssegnazioneVO.getConsumoSerraGasolio());
      SolmrLogger.debug(this, "frmVerificaAssegnazioneVO.getConsumoSerraGasolioLong(): "+frmVerificaAssegnazioneVO.getConsumoSerraGasolioLong());
       SolmrLogger.debug(this, "frmVerificaAssegnazioneVO.getRimanenzeDichAltreAziendeBenzina(): "+frmVerificaAssegnazioneVO.getRimanenzeDichAltreAziendeBenzina());
        SolmrLogger.debug(this, "frmVerificaAssegnazioneVO.getRimanenzeDichAltreAziendeGasolio(): "+frmVerificaAssegnazioneVO.getRimanenzeDichAltreAziendeGasolio());
        SolmrLogger.debug(this, "frmVerificaAssegnazioneVO.getTotDisponibilitaBenzina(): "+frmVerificaAssegnazioneVO.getTotDisponibilitaBenzina());
        SolmrLogger.debug(this, "frmVerificaAssegnazioneVO.getTotDisponibilitaGasolio(): "+frmVerificaAssegnazioneVO.getTotDisponibilitaGasolio());
      SolmrLogger.debug(this, "***##***##***##***##***##***##***##***##***##\n\n\n\n\n\n");

      request.setAttribute("frmVerificaAssegnazioneVO",frmVerificaAssegnazioneVO);
    }
    catch(Exception e)
    {
      throwValidation(e.getMessage(),VIEW_URL);
    }
  }
  frmVerificaAssegnazioneVO.makeTotals();
 
 
  // -------- CALCOLO RIMANENZA MINIMA STIMATA AL 31/12 ------------
  HashMap mapRimanenzeMinime = null;
  if (frmVerificaAssegnazioneVO.getIdDomandaAssegnazionePrecedente()!=null){
    SolmrLogger.debug(this, "--- idDomandaAssegnazioneAnniPrecedenti valorizzata");

    Vector<Long> idDomandaAssegnazAnniPrecVect = new Vector<Long>(); 
    idDomandaAssegnazAnniPrecVect.add(frmVerificaAssegnazioneVO.getIdDomandaAssegnazionePrecedente());
    SolmrLogger.debug(this, "-- Controllo se c'è un ACCONTO anni precedenti");
    DomandaAssegnazione accontoAnniPrecedentiVO = client.findAccontoNonAnnullatoByIdDomandaBase(frmVerificaAssegnazioneVO.getIdDomandaAssegnazionePrecedente());
    // Se è stato trovato il record, memorizzo l'idDomandaAssegnazione
    if (accontoAnniPrecedentiVO != null){
      SolmrLogger.debug(this, "-- e' stato trovato l'acconto anni precedenti");
      idDomandaAssegnazAnniPrecVect.add(accontoAnniPrecedentiVO.getIdDomandaAssegnazione());
    }  
    // Query con gli idDomandaAssegnazione anni precedenti
    SolmrLogger.debug(this, "-- ricerca delle quantita' su DB_PRELIEVO");
    Vector dettaglioCarburanteVector = client.getDettaglioCarburanteByIdDomandaAssegnazione(idDomandaAssegnazAnniPrecVect);
    
    // --- Calcolo Rimanenza minima stimata al 31/12
    SolmrLogger.debug(this, "--- Calcolo Rimanenza minima stimata al 31/12");
    Long dateULTP=CarburanteUtil.getParametroDataUltimoPrelievoRimanenzaMinima(session);
    mapRimanenzeMinime=CarburanteUtil.processBuoniCarburanteForRimanenzaMinima((Vector)dettaglioCarburanteVector,frmVerificaAssegnazioneVO,dateULTP);
    
  }
  else{
    SolmrLogger.debug(this, "--- idDomandaAssegnazionePrecedente NON valorizzata");
  }

  if (mapRimanenzeMinime!=null){
    request.setAttribute("mapRimanenzeMinime",mapRimanenzeMinime);
  }

  if (debitoVO != null)
  {
	SolmrLogger.debug(this, "--debitoVO != null");
    request.setAttribute("debiti", debitoVO);
    
    long debitiContoProprio = CarburanteUtil.getDebitoContoProprio(debitoVO, 
        		                    NumberUtils.getLongValueZeroOnNull(frmVerificaAssegnazioneVO.getPrelevatoCPGasolio()) 
        		                    //+ NumberUtils.getLongValueZeroOnNull(frmVerificaAssegnazioneVO.getPrelevatoCTGasolio())
        							+ NumberUtils.getLongValueZeroOnNull(frmVerificaAssegnazioneVO.getPrelevatoCPBenzina()));
    								//+ NumberUtils.getLongValueZeroOnNull(frmVerificaAssegnazioneVO.getPrelevatoCTBenzina());
    long debitiContoTerzi =   CarburanteUtil.getDebitoContoTerzi(debitoVO, 
            									 NumberUtils.getLongValueZeroOnNull(frmVerificaAssegnazioneVO.getPrelevatoCTGasolio())			
												 + NumberUtils.getLongValueZeroOnNull(frmVerificaAssegnazioneVO.getPrelevatoCTBenzina()));  								
    
    long debitiSerra = CarburanteUtil.getDebitoSerra(debitoVO, NumberUtils
        .getLongValueZeroOnNull(frmVerificaAssegnazioneVO
            .getPrelevatoSerraGasolio()) + NumberUtils
        .getLongValueZeroOnNull(frmVerificaAssegnazioneVO
            .getPrelevatoSerraBenzina()));
    // Testo se almeno uno dei 2 debiti è diverso da null. I metodi getDebitoContoProprioTerzi
    // e getDebitoSerra ritornano un valore se e solo se esiste almeno un valore di debito per
    // il conto proprio/terzi e per le serre. Il fatto che esista un record di debito non 
    // implica che esista un debito effettivo. Il record rappresenta solo un debito teorico,
    // il debito vero esiste solo nel caso che la formuletta:
    // QTA_PRELEVATA - QTA_ASS_NETTA_PRECEDENTE + DEBITO_PRECEDENTE 
    // restituisca una valore > 0 (calcolo effettuato dai 2 metodi sopra indicati)              
    if (debitiContoProprio + debitiContoTerzi + debitiSerra > 0)
    {
      SolmrLogger.debug(this, "-- debitiContoProprio ="+debitiContoProprio);
      SolmrLogger.debug(this, "-- debitiContoTerzi ="+debitiContoTerzi);
      SolmrLogger.debug(this, "-- debitiSerra ="+debitiSerra);
      // Esiste il debito
      if (debitiContoProprio > 0)
      {
        // debitiContoProprioTerzi[0] ==> gasolio, debitiContoProprioTerzi[1] ==> benzina.
        request.setAttribute("debitiContoProprio",new Long(debitiContoProprio));
      }
      if (debitiContoTerzi > 0)
      {
        // debitiContoProprioTerzi[0] ==> gasolio, debitiContoProprioTerzi[1] ==> benzina.
        request.setAttribute("debitiContoTerzi",new Long(debitiContoTerzi));
      }
      if (debitiSerra > 0)
      {
        // debitiSerra[0] ==> gasolio, debitiSerra[1] ==> benzina.
        request.setAttribute("debitiSerra",new Long(debitiSerra));
      }
    }
  }  
%>
<jsp:forward page="<%=VIEW_URL%>" />
<%!
  private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException(msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }
%>
