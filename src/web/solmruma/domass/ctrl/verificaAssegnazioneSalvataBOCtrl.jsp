<%@ page language="java"

         contentType="text/html"

%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<jsp:useBean id="frmVerificaAssegnazioneVO" scope="request"

 class="it.csi.solmr.dto.uma.FrmVerificaAssegnazioneVO">

  <jsp:setProperty name="frmVerificaAssegnazioneVO" property="*" />

</jsp:useBean>

<%!

  private static final String VIEW_URL="/domass/view/verificaAssegnazioneSalvataBOView.jsp";

  private static final String PAGINA_ANNULLAMENTO="../ctrl/annulloAssegnazioneCtrl.jsp";

  private static final String PAGINA_RIFIUTO="../ctrl/rifiutoAssegnazioneCtrl.jsp";

  private static final String CONFERMA_VALIDA="../ctrl/confermaValidazioneDomandaCtrl.jsp";
  
  private static final String NEXT_PAGE_TRASMISSIONE ="/domass/ctrl/confermaTrasmissioneDomandaCtrl.jsp";

%><%

  String iridePageName = "verificaAssegnazioneSalvataBOCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();



  it.csi.solmr.client.uma.UmaFacadeClient client = new it.csi.solmr.client.uma.UmaFacadeClient();

  SommeRimanenzeDaCessazioneVO sommeRimanenze=client.findRimanenzeDitteCessateByCUAADestinatario(dittaUMAAziendaVO.getCuaa());
  if (sommeRimanenze!=null)
  {
    request.setAttribute("sommeRimanenze",sommeRimanenze);
  }
  
  if (request.getParameter("validaDomAss")!=null)
  {
	SolmrLogger.debug(this, "--- CASO VALIDAZIONE DOMANDA");  
    ValidationErrors errors=null;
    SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getExtIdIntermediario()="+frmVerificaAssegnazioneVO.getExtIdIntermediario());
    if (frmVerificaAssegnazioneVO.getExtIdIntermediario()!= null &&
        frmVerificaAssegnazioneVO.getExtIdIntermediario().longValue()!=0)
    {
      SolmrLogger.debug(this,"\n\n\n\nvalidazione validateValida()\n\n\n\n");
      errors=frmVerificaAssegnazioneVO.validateValida();
    }


    /**
     * 26-10-2004
     * Aggiunto controllo sulla data.
     * La data ricevuta documenti non può essere inferiore alla data consegna documenti
     */
    if(errors == null)
    {
      errors = new ValidationErrors();
    }

    Date dateRicevutaDocumenti = null;
    try
    {
      dateRicevutaDocumenti = DateUtils.parseDate(frmVerificaAssegnazioneVO.getDataRicevutaDocumenti());
    }
    catch (Exception ex)
    {
    }

    if(errors.get("dataRicevutaDocumenti")==null && Validator.isNotEmpty(frmVerificaAssegnazioneVO.getExtIdIntermediario()) && dateRicevutaDocumenti != null)
    {
      DomandaAssegnazione domAssVO = client.findDomAssByPrimaryKey(new Long(request.getParameter("idDomAss")));
      if(dateRicevutaDocumenti.compareTo(domAssVO.getDataTrasmissione()) < 0)
      {
        errors.add("dataRicevutaDocumenti",new ValidationError("La data ricevuta documenti non può essere precedente alla data di trasmissione"));
      }
    }
    /**
     * FINE 26-10-2004
     */


    SolmrLogger.debug(this,"\n\n\n\nerros="+errors+"\n\n\n\n");

    if (errors==null || errors.size()==0)

    {

      try

      {

        SolmrLogger.debug(this,"VALIDAZIONE");

        %><jsp:forward page="<%=CONFERMA_VALIDA%>" /><%

        return;

/**/

      }

      catch(Exception e)

      {

        throwValidation(e.getMessage(),VIEW_URL);

      }

    }

    else

    {

      SolmrLogger.debug(this,"\n\n\n\n\n\n\nTROVATI ERRORI\n\n\n\n\n");

      request.setAttribute("errors",errors);

    }

  }

  if (request.getParameter("annulla.x")!=null)

  {

    try

    {

      SolmrLogger.debug(this,"ANNULLAMENTO");

      client.existsBuonoPrelievoIdDomAss(frmVerificaAssegnazioneVO.getIdDomandaassegnazione());

      %><jsp:forward page ="<%=PAGINA_ANNULLAMENTO%>" /><%

      SolmrLogger.debug(this,"FINE ANNULLAMENTO");

      return;

    }

    catch(Exception e)

    {

      throwValidation(e.getMessage(),VIEW_URL);

    }

  }

  if (request.getParameter("rifiuta.x")!=null)

  {

    try

    {

      SolmrLogger.debug(this,"RIFIUTO");

      %><jsp:forward page ="<%=PAGINA_RIFIUTO%>" /><%

      SolmrLogger.debug(this,"FINE RIFIUTO");

      return;

    }

    catch(Exception e)

    {

      throwValidation(e.getMessage(),VIEW_URL);

    }

  }
  // Caso di trasmissione da parte di un utente Persona fisica
  if (request.getParameter("trasmetti.x")!=null){
	  SolmrLogger.debug(this, "-- CASO di trasmissione da parte di un utente Persona fisica");	  
	    try{
	      SolmrLogger.debug(this, "-- faccio forward alla pagina :"+NEXT_PAGE_TRASMISSIONE);  	
	      %><jsp:forward page ="<%=NEXT_PAGE_TRASMISSIONE%>" /><%
	      return;
	    }
	    catch(Exception e){
	      SolmrLogger.error(this, "-- Exception :"+e.getMessage());	
	      throwValidation(e.getMessage(),VIEW_URL);
	    }	 	  
  }

  // ARRIVA QUI SE STO VISUALIZZANDO LA PAGINA PER LA PRIMA VOLTA

  try

  {

    HashMap provincieValidazioneIntermediario = (HashMap) session.getAttribute("provincieValidazioneIntermediario");
    HashMap formeGiuridicheValidazionePA = (HashMap) session.getAttribute("formeGiuridicheValidazionePA");
    Long idFormaGiuridica = dittaUMAAziendaVO.getIdFormaGiuridica();

    frmVerificaAssegnazioneVO=

        client.getVerificaAssegnazione(idDittaUma, provincieValidazioneIntermediario, idFormaGiuridica, formeGiuridicheValidazionePA);

/*    if ("0".equals(frmVerificaAssegnazioneVO.getNumeroDoc()))

    {

      frmVerificaAssegnazioneVO.setNumeroDoc(null);

    }

    if ("0".equals(frmVerificaAssegnazioneVO.getAssNettaRiscSerraBenzina()))

    {

      frmVerificaAssegnazioneVO.setNumeroDoc(null);

    }*/

    frmVerificaAssegnazioneVO.formatFields();

    request.setAttribute("frmVerificaAssegnazioneVO",frmVerificaAssegnazioneVO);

    Long idAssCarb=client.getIdAssegnazCarbByDomAss(frmVerificaAssegnazioneVO.getIdDomandaassegnazione());
    SolmrLogger.debug(this, "--- idAssCarb ="+idAssCarb);

    if (idAssCarb==null)

    {

      idAssCarb=new Long(-1);

    }

    frmVerificaAssegnazioneVO.setIdAssCarb(idAssCarb.toString());

    if (Validator.isNotEmpty(frmVerificaAssegnazioneVO.getExtIdIntermediarioDocCarta()) && !frmVerificaAssegnazioneVO.getExtIdIntermediarioDocCarta().equals("0"))

    {

      request.setAttribute("denominazioneIntermediario",client.getDenominazioneIntermediario(

          new Long(frmVerificaAssegnazioneVO.getExtIdIntermediarioDocCarta())));

    }



    SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getIdAssCarb()="+frmVerificaAssegnazioneVO.getIdAssCarb());

  }

  catch(SolmrException e)

  {

    throwValidation(e.getMessage(),VIEW_URL);

  }

  catch(Exception e)

  {

    throwValidation((String)it.csi.solmr.etc.SolmrErrors.get("GENERIC_SYSTEM_EXCEPTION"),VIEW_URL);

  }

%><jsp:setProperty name="frmVerificaAssegnazioneVO" property="*" /><%



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
      // Esiste il debito
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

  SolmrLogger.debug(this,"verificaAssegnazioneSalvataBOCtrl.jsp -  FINE PAGINA");

%>

<%!

  private void throwValidation(String msg,String validateUrl) throws ValidationException

  {

    ValidationException valEx = new ValidationException("Errore: eccezione="+msg,validateUrl);

    valEx.addMessage(msg,"exception");

    throw valEx;

  }

%>

