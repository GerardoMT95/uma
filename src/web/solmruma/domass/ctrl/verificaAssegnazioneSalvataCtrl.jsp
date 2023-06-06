<%@ page language="java"
         contentType="text/html"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<jsp:useBean id="frmVerificaAssegnazioneVO" scope="request"
 class="it.csi.solmr.dto.uma.FrmVerificaAssegnazioneVO">
  <jsp:setProperty name="frmVerificaAssegnazioneVO" property="*" />
</jsp:useBean>
<%!
  private static final String VIEW_URL="/domass/view/verificaAssegnazioneSalvataView.jsp";
  private static final String NEXT_PAGE="/domass/ctrl/confermaTrasmissioneDomandaCtrl.jsp";
  private static final String NEXT_PAGE_VALIDA="/domass/ctrl/confermaValidazioneDomandaCtrl.jsp";
  //  private static final String NEXT_PAGE="/domass/ctrl/verificaAssegnazioneTrasmessaCtrl.jsp";
%>
<%

  String iridePageName = "verificaAssegnazioneSalvataCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  UmaFacadeClient client = new UmaFacadeClient();
  SommeRimanenzeDaCessazioneVO sommeRimanenze=client.findRimanenzeDitteCessateByCUAADestinatario(dittaUMAAziendaVO.getCuaa());
  if (sommeRimanenze!=null)
  {
    request.setAttribute("sommeRimanenze",sommeRimanenze);
  }

  DebitoVO debiti = client.getDebitoDitta(dittaUMAAziendaVO
      .getIdDittaUMA().longValue(),
      DateUtils.getCurrentYear().intValue() - 1);

  if (request.getParameter("trasmetti.x")!=null)
  {
    try
    {
      %><jsp:forward page ="<%=NEXT_PAGE%>" /><%
      return;
    }
    catch(Exception e)
    {
      throwValidation(e.getMessage(),VIEW_URL);
    }
  }
  else
  {
    if (request.getParameter("valida.x")!=null)
    {
      try
      {
        %><jsp:forward page ="<%=NEXT_PAGE_VALIDA%>" /><%
        return;
      }
      catch(Exception e)
      {
        throwValidation(e.getMessage(),VIEW_URL);
      }
    }

    try
    {
      HashMap provincieValidazioneIntermediario = (HashMap) session.getAttribute("provincieValidazioneIntermediario");
      HashMap formeGiuridicheValidazionePA = (HashMap) session.getAttribute("formeGiuridicheValidazionePA");
      Long idFormaGiuridica = dittaUMAAziendaVO.getIdFormaGiuridica();

      frmVerificaAssegnazioneVO=
          client.getVerificaAssegnazione(idDittaUma, provincieValidazioneIntermediario, idFormaGiuridica, formeGiuridicheValidazionePA);
      frmVerificaAssegnazioneVO.formatFields();

      request.setAttribute("frmVerificaAssegnazioneVO",frmVerificaAssegnazioneVO);
    }
    catch(SolmrException e)
    {
      throwValidation(e.getMessage(),VIEW_URL);
    }
    catch(Exception e)
    {
      throwValidation((String)it.csi.solmr.etc.SolmrErrors.get("GENERIC_SYSTEM_EXCEPTION"),VIEW_URL);
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
  
  request.setAttribute("mapRimanenzeMinime",mapRimanenzeMinime);
  
  
  
  
  DebitoVO debitoVO = client.getDebitoDitta(dittaUMAAziendaVO
      .getIdDittaUMA().longValue(),
      DateUtils.getCurrentYear().intValue() - 1);
  if (debitoVO != null)
  {
    request.setAttribute("debiti", debitoVO);
    
    
    //long debitiContoProprioTerzi = CarburanteUtil.getDebitoContoProprioTerzi(debitoVO, NumberUtils.getLongValueZeroOnNull(frmVerificaAssegnazioneVO.getPrelevatoGasolio()) + NumberUtils.getLongValueZeroOnNull(frmVerificaAssegnazioneVO.getPrelevatoBenzina()));
    
    
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
      if (debitiContoProprio > 0)
      {        
        request.setAttribute("debitiContoProprio",new Long(debitiContoProprio));
      }
      if (debitiContoTerzi > 0)
      {       
        request.setAttribute("debitiContoTerzi",new Long(debitiContoTerzi));
      }
      if (debitiSerra > 0)
      {
        // debitiSerra[0] ==> gasolio, debitiSerra[1] ==> benzina.
        request.setAttribute("debitiSerra",new Long(debitiSerra));
      }
    }
  }
%><jsp:forward page ="<%=VIEW_URL%>" /><%
  SolmrLogger.debug(this,"verificaAssegnazioneSalvataCtrl.jsp -  FINE PAGINA");
%>
<%!
  private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException("Errore: eccezione="+msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }
%>
