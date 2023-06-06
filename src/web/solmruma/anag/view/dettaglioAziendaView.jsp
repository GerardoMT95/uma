  <%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>



<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.etc.SolmrConstants" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.anag.services.DelegaAnagrafeVO" %>
<%@page import="it.csi.solmr.exception.SolmrException"%>
<%@page import="it.csi.solmr.etc.uma.UmaErrors"%>
<%

  //java.io.InputStream layout = application.getResourceAsStream("anag/layout/dettaglioAzienda.htm");

//  Htmpl htmpl = new Htmpl(layout);

  Htmpl htmpl = HtmplFactory.getInstance(application)
                .getHtmpl("/anag/layout/dettaglioAzienda.htm");
  // Forzo l'oggetto autorizzazione per i menu a quello del cu
  // VISUALIZZA_DATI_DITTA perchè alcune controller di cu differenti dal
  // visualizza dati ditta fanno forward su questa view e quindi il menu non
  // verrebbe generato correttamente
  request.setAttribute("__autorizzazione",it.csi.solmr.util.IrideFileParser.elencoSecurity.get("VISUALIZZA_DATI_DITTA"));
%><%@include file = "/include/menu.inc" %><%

  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  UmaFacadeClient umaClient = new UmaFacadeClient();

  //051212 - Modifica gestione Importa dati in base allo stato ditta e domanda - Begin
  boolean gestioneImportaDati = false;
  try{
    SolmrLogger.debug(this, "Before - isDittaUmaCessata");
    SolmrLogger.debug(this, "dittaVO.getDataCessazioneUMA(): "+dittaVO.getDataCessazioneUMA());
    if(dittaVO.getDataCessazioneUMA()==null){
      //ditta cessata
      gestioneImportaDati=true;
    }
    else{
      gestioneImportaDati=false;
    }
    SolmrLogger.debug(this, "After dittaVO.getDataCessazioneUMA() - gestioneImportaDati: "+gestioneImportaDati);

    if(gestioneImportaDati){
      BloccoDittaVO bloccoDittaVO = umaClient.getDettaglioBlocco(dittaVO.getIdDittaUMA());
      SolmrLogger.debug(this, "bloccoDittaVO: "+bloccoDittaVO);
      if(bloccoDittaVO==null){
        //ditta non bloccata
        gestioneImportaDati = true;
      }
      else{
        gestioneImportaDati = false;
      }
    }
    SolmrLogger.debug(this, "After checkBlocco - gestioneImportaDati: "+gestioneImportaDati);

    SolmrLogger.debug(this, "Before - statoDomAssFunzPAorInt");
    if(gestioneImportaDati){
      umaClient.statoDomAssFunzPAorInt(dittaVO.getIdDittaUMA(), new Long(DateUtils.getCurrentYear().intValue()), ruoloUtenza);
    }
    SolmrLogger.debug(this, "After - statoDomAssFunzPAorInt");
  }catch(it.csi.solmr.exception.SolmrException sExc){
    //stato della domanda non valido in base al profilo
    gestioneImportaDati=false;
    SolmrLogger.debug(this, "catch - statoDomAssFunzPAorInt");
  }
  SolmrLogger.debug(this, "After controlli - gestioneImportaDati: "+gestioneImportaDati);
  session.setAttribute("gestioneImportaDati", new Boolean(gestioneImportaDati));
  //051212 - Modifica gestione Importa dati in base allo stato ditta e domanda - End


  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  if (errors == null)

    errors = new ValidationErrors();



  if (session.getAttribute("notifica")!=null)

  {

    String info=(String)session.getAttribute("notifica");

    session.removeAttribute("notifica");

    ValidationError message = new ValidationError(info);

    errors.add("error", message);

  }



  HtmplUtil.setErrors(htmpl, errors, request);


  try {

    it.csi.solmr.presentation.security.AutorizzazioneDittaUMA.writeHeaderCessaBlocco(
            htmpl, dittaVO,
            umaClient.getDettaglioBlocco(dittaVO.getIdDittaUMA()),
            umaClient.getModificheIntermediario(dittaVO.getIdAzienda(),
            dittaVO.getIdDittaUMA()));

  } catch (Exception exc) {

    SolmrLogger.error(this, "Eccezione: "+exc);

  }




  htmpl.set("denominazione", dittaVO.getDenominazione());

  htmpl.set("CUAA", dittaVO.getCuaa());

  htmpl.set("dittaUMA", dittaVO.getDittaUMAstr());

  htmpl.set("umaTipoDitta", dittaVO.getTipiDitta());

  //htmpl.set("siglaProvUMA", dittaVO.getSiglaProvUMA());

  htmpl.set("siglaProvUMA", dittaVO.getDescProvinciaUma());

  if (dittaVO.getIdDittaUmaProv()!=null)
  {
    htmpl.newBlock("linkDittaProvenienza");
    htmpl.set("linkDittaProvenienza.ditta_provenienza",dittaVO.getDescrizioneDittaUmaProv());
  }

  // Setto l'input type hidden per Vocale....

  htmpl.set("idAzienda", dittaVO.getIdAzienda().toString());



  // Ditta Uma



  htmpl.set("uma_tipo", dittaVO.getTipiDitta());

  htmpl.set("uma_num", dittaVO.getDittaUMAstr());

  htmpl.set("uma_prov", dittaVO.getSiglaProvUMA());

  htmpl.set("uma_dataIsc", dittaVO.getDataIscrizioneUMA());

  if(dittaVO.getDataCessazioneUMA()!= null)

    htmpl.set("uma_dataCess", dittaVO.getDataCessazioneUMA());

  else

    htmpl.set("uma_dataCess", "");

  htmpl.set("uma_stato", dittaVO.getDescStatoDitta());

  htmpl.set("uma_conduzione", dittaVO.getDescConduzione());

  htmpl.set("uma_comuneAtt", dittaVO.getDescComunePrincAttiv());

  htmpl.set("uma_indirizzo_cons_carb", dittaVO.getIndirizzoConsegnaCarburante());

  if(dittaVO.getDenomEnteAppartDitta()!=null && !dittaVO.getDenomEnteAppartDitta().equals(""))

    htmpl.set("uma_data_ultima_mod", dittaVO.getDataAggiornamentoDatiDitta()+" "+dittaVO.getDenomEnteAppartDitta());

  else

    htmpl.set("uma_data_ultima_mod", dittaVO.getDataAggiornamentoDatiDitta());

  if( dittaVO.getNote()==null || dittaVO.getNote().trim().equalsIgnoreCase("") )

  {

    SolmrLogger.debug(this,"\n\n\n+++++++++++++++++++++");

    SolmrLogger.debug(this,"dittaVO.getNote(): "+dittaVO.getNote());

    String strStyleNote = "class='bottone_dis'";

    htmpl.set("styleSheetNotePagina", strStyleNote);

    htmpl.set("disabled", "disabled");

  }

  else

  {

    SolmrLogger.debug(this,"\n\n\n+++++++++++++++++++++");

    SolmrLogger.debug(this,"dittaVO.getNote(): "+dittaVO.getNote());

    String strStyleNote = "class='bottone'";

    htmpl.set("styleSheetNotePagina", strStyleNote);

  }



  // Generalità

  htmpl.set("denom", dittaVO.getDenominazione());

  htmpl.set("cuaa", dittaVO.getCuaa());

  htmpl.set("pIVA", dittaVO.getPartitaIVA());

  htmpl.set("formaGiuridica", dittaVO.getDescFormaGiuridica());

  htmpl.set("tipoAzienda", dittaVO.getDescTipoAzienda());



  // Titolare o rappresentante legale

  /*htmpl.set("cognome", dittaVO.getCognome());

  htmpl.set("nome", dittaVO.getNome());

  htmpl.set("codFiscale", dittaVO.getCodiceFiscale());

  htmpl.set("dataNascita", dittaVO.getDataNascita());

  htmpl.set("sesso", dittaVO.getSesso());

  htmpl.set("luogoNascita", dittaVO.getComuneNascita());

  htmpl.set("istat", dittaVO.getIstatNascita());



  // Sede legale

  htmpl.set("sl_ind", dittaVO.getSedelegIndirizzo());

  if(dittaVO.getSedelegEstero().equals("")){

    htmpl.newBlock("blkStatoItalia");

    htmpl.set("blkStatoItalia.sl_comune", dittaVO.getSedelegComune());

    htmpl.set("blkStatoItalia.sl_prov", dittaVO.getSedelegProvincia());

    htmpl.set("blkStatoItalia.sl_cap", dittaVO.getSedelegCAP());

  }

  else{

    htmpl.newBlock("blkStatoEstero");

    htmpl.set("blkStatoEstero.sl_stato", dittaVO.getSedelegEstero());

  }

*/

  // Iscrizione alla camera di commercio

  if(dittaVO.getDescAttivitaATECO()!=null)

    htmpl.set("cc_ateco", dittaVO.getDescAttivitaATECO()+" ("+dittaVO.getCodiceAttivitaATECO()+")");

  if(dittaVO.getDescAttivitaOTE()!=null)

    htmpl.set("cc_ote", dittaVO.getDescAttivitaOTE()+" ("+dittaVO.getCodiceAttivitaOTE()+")");



  htmpl.set("cc_prov", dittaVO.getSiglaProvREA());



  if(dittaVO != null){

    if(dittaVO.getNumeroREA()==null || dittaVO.getNumeroREA().equals(new Long(0)))

      dittaVO.setNumeroREA("");

  }



  htmpl.set("cc_numero", dittaVO.getNumeroREA());



  htmpl.set("cc_num_reg_impr", dittaVO.getNumRegImprese());

  htmpl.set("cc_anno_iscr", dittaVO.getAnnoIscrizione());

  if(dittaVO.getDataCessAzienda()!=null){

    SolmrLogger.debug(this,"data cessazione azienda is "+dittaVO.getDataCessAzienda());

    htmpl.set("cc_dataCess", dittaVO.getDataCessAzienda());

    if(dittaVO.getCausaleCessAzienda()!=null)

      htmpl.set("cc_causaleCess", dittaVO.getCausaleCessAzienda());

    else

      htmpl.set("cc_causaleCess", "");

  }

  else

   htmpl.set("cc_dataCess", "");



  if(dittaVO.getDenomEnteAppartAnag()!=null && !dittaVO.getDenomEnteAppartAnag().equals(""))

      htmpl.set("cc_data_ult_mod", dittaVO.getDataAggiornamentoAnagrafe()+" "+dittaVO.getDenomEnteAppartAnag());

    else

    htmpl.set("cc_data_ult_mod", dittaVO.getDataAggiornamentoAnagrafe());



  htmpl.set("cc_note", dittaVO.getNoteAnag());

  //htmpl.set("note", dittaVO.getNote());



  // Inserisco l'informazione relativo all'intermediario delegato

  //UMA2 - Begin
  Date dataInizioGestioneFascicolo = (Date)session.getAttribute("dataInizioGestioneFascicolo");
  if (dataInizioGestioneFascicolo!=null) // Se è null ==> sessione scaduta ==> evito la NullPointerException
  {
    SolmrLogger.debug(this, "dataInizioGestioneFascicolo: "+dataInizioGestioneFascicolo);
    String currentDate = DateUtils.getCurrentDateString();
    SolmrLogger.debug(this, "currentDate: "+currentDate);
    Date toDay = new Date();
    SolmrLogger.debug(this, "if (toDay.after(dataInizioGestioneFascicolo))");

    umaClient = new UmaFacadeClient();

    SolmrLogger.debug(this, "dittaVO.getIdAzienda(): "+dittaVO.getIdAzienda());

    DelegaAnagrafeVO delegaAnagrafeVO = umaClient.serviceGetDelega(dittaVO.getIdAzienda(), null, null, null);

    if(delegaAnagrafeVO == null)
    {

      htmpl.set("intermediarioDelegato", "Assente");

    }
    else
    {

      htmpl.set("intermediarioDelegato", delegaAnagrafeVO.getDenominazione());
    }
  }
  //UMA2 - End
  
  // 23/04/2009 Einaudi:
  // Ho messo la chiamata alla business nella view anzichè nella controller perchè la view in questione
  // viene richiamata da controller diverse (ricerca, dettagli vari). Quindi per evitare di duplicare
  // il codice e dimenticarsi dei casi ho preferito questa soluzione che stilisticamente non è molto
  // corretta.
  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
  Date dataRicezDocumAssegnaz=umaClient.getDataPerFlagRicezioneDocumumentiAssegnazione(dittaUMAAziendaVO.getIdDittaUMA().longValue());
  
  if (dataRicezDocumAssegnaz!=null && 
      DateUtils.extractYearFromDate(dataRicezDocumAssegnaz) ==
      DateUtils.extractYearFromDate(new Date()))
  {
    htmpl.set("dataRicezDocumAssegnazChecked",SolmrConstants.HTML_CHECKED, null);
  }
  
  
  //Visualizzo gli allegati salvati sul db
  SolmrLogger.debug(this, " -- recupero l'elenco degli allegati");
  List<FileVO> vElencoFileAllegati = umaClient.getAllegatiByIdDittaUma(dittaUMAAziendaVO.getIdDittaUMA().longValue());
  if(vElencoFileAllegati != null &&  vElencoFileAllegati.size() >0){		 
    SolmrLogger.debug(this, " -- ci sono dei file da visualizzare in elenco, quanti ="+vElencoFileAllegati.size());
	htmpl.newBlock("fileAllegatiBlk");
	for ( int i=0; i<vElencoFileAllegati.size(); i++){
      FileVO fileVO = (FileVO) vElencoFileAllegati.get(i);
	  htmpl.newBlock("fileAllegatiBlk.fileBlk");
	  SolmrLogger.debug(this, " -- idAllegato ="+fileVO.getIdAllegato());
	      
	  htmpl.set("fileAllegatiBlk.fileBlk.idFile",fileVO.getIdAllegato().toString()); 	      
	  htmpl.set("fileAllegatiBlk.fileBlk.nome",fileVO.getNomeFisico());    
	  if(fileVO.getDescrizione() != null)
	    htmpl.set("fileAllegatiBlk.fileBlk.note", fileVO.getDescrizione());
	  }
   }
   else{
	 SolmrLogger.debug(this, " -- NON ci sono dei file da visualizzare in elenco");
   }
  
  
%>

<%= htmpl.text()%>