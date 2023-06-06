

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
  private static final String VIEW_URL="/domass/view/verificaAssegnazioneBOView.jsp";
  private static final String NEXT_PAGE="/domass/layout/verificaAssegnazioneSalvataBO.htm";
%>
<%

  String iridePageName = "verificaAssegnazioneBOCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "BEGIN verificaAssegnazioneBOCtrl");		  
		  
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  UmaFacadeClient client = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  SommeRimanenzeDaCessazioneVO sommeRimanenze=client.findRimanenzeDitteCessateByCUAADestinatario(dittaUMAAziendaVO.getCuaa());
  if (sommeRimanenze!=null)
  {
    request.setAttribute("sommeRimanenze",sommeRimanenze);
  }      
  DebitoVO debitoVO = client.getDebitoDitta(dittaUMAAziendaVO.getIdDittaUMA().longValue(),
      DateUtils.getCurrentYear().intValue() - 1);
  if (request.getParameter("conferma.x")!=null)
  {
    try
    {
      SolmrLogger.debug(this,"\n\n\n\n\n\n\n\n\n1");
      FrmDettaglioAssegnazioneVO daVO=new FrmDettaglioAssegnazioneVO();
      SolmrLogger.debug(this,"2");
      daVO.setAltreMacchine(new Long(request.getParameter("altreMacchine")));
      SolmrLogger.debug(this,"3");
      frmVerificaAssegnazioneVO.setFrmDettaglioAssegnazioneVO(daVO);
      SolmrLogger.debug(this,"4");
      //      frmVerificaAssegnazioneVO.formatFields();
      SolmrLogger.debug(this,"5");
      SolmrLogger.debug(this,"frmVerificaAssegnazioneVO="+frmVerificaAssegnazioneVO);
      ValidationErrors errors = client.controllaVerificaAssegnazione(frmVerificaAssegnazioneVO,ruoloUtenza, sommeRimanenze);
      SolmrLogger.debug(this,"6");

      SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getIdAssCarb()="+frmVerificaAssegnazioneVO.getIdAssCarb());
      //      frmVerificaAssegnazioneVO.formatFields();
      SolmrLogger.debug(this,"7");
      if (errors!=null && errors.size()>0)
      {
        SolmrLogger.debug(this,"8");
        request.setAttribute("errors",errors);
        SolmrLogger.debug(this,"9");
        SolmrLogger.debug(this,"errors="+errors);
      }
      else
      {
        SolmrLogger.debug(this,"10");
        SolmrLogger.debug(this,"--- NEXT_PAGE ="+NEXT_PAGE);
        %>
          <jsp:forward page="<%=NEXT_PAGE%>" />
        <%
        return;
      }
    }
    catch(Exception e)
    {
      SolmrLogger.error(this, " --- Exception in verificaAssegnazioneBOCtrl ="+e.getMessage());
      throwValidation(e.getMessage(),VIEW_URL);
    }
  }
  else
  {
    try
    {
      SolmrLogger.debug(this,"idDittaUma="+idDittaUma);
      HashMap provincieValidazioneIntermediario = (HashMap) session.getAttribute("provincieValidazioneIntermediario");
      HashMap formeGiuridicheValidazionePA = (HashMap) session.getAttribute("formeGiuridicheValidazionePA");
      Long idFormaGiuridica = dittaUMAAziendaVO.getIdFormaGiuridica();

      frmVerificaAssegnazioneVO=
          client.getVerificaAssegnazione(idDittaUma, provincieValidazioneIntermediario, idFormaGiuridica, formeGiuridicheValidazionePA);

      SolmrLogger.debug(this, "frmVerificaAssegnazioneVO: "+frmVerificaAssegnazioneVO);
      SolmrLogger.debug(this, "frmVerificaAssegnazioneVO.getConsumoSerraBenzina(): "+frmVerificaAssegnazioneVO.getConsumoSerraBenzina());
      SolmrLogger.debug(this, "frmVerificaAssegnazioneVO.getConsumoSerraBenzinaLong(): "+frmVerificaAssegnazioneVO.getConsumoSerraBenzinaLong());
      SolmrLogger.debug(this, "frmVerificaAssegnazioneVO.getConsumoSerraGasolio(): "+frmVerificaAssegnazioneVO.getConsumoSerraGasolio());
      SolmrLogger.debug(this, "frmVerificaAssegnazioneVO.getConsumoSerraGasolioLong(): "+frmVerificaAssegnazioneVO.getConsumoSerraGasolioLong());

      if ("0".equals(frmVerificaAssegnazioneVO.getNumeroDoc()))
      {
        frmVerificaAssegnazioneVO.setNumeroDoc(null);
      }
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
    request.setAttribute("debiti", debitoVO);
    
    /*long debitiContoProprioTerzi = CarburanteUtil
        .getDebitoContoProprioTerzi(debitoVO, NumberUtils
            .getLongValueZeroOnNull(frmVerificaAssegnazioneVO
                .getPrelevatoGasolio()) + NumberUtils
            .getLongValueZeroOnNull(frmVerificaAssegnazioneVO
                .getPrelevatoBenzina()));*/
                
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
        request.setAttribute("debitoSerra",new Long(debitiSerra));
      }
    }
  }
  
  //Usata per disabilitare i blocchi se nn è ne conduzione conto terzi ne conduzione conto terzi e propieari
  //in pratica era conto terzi nell'ultima assegnazione valida 
  if(client.hasAssegnazioneValidataContoTerzi(dittaUMAAziendaVO.getIdDittaUMA()))
  {
    request.setAttribute("assegnazioneValidtata", "true");
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
