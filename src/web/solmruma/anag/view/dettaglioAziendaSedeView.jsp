  <%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>



<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.SolmrConstants" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%

  Htmpl htmpl = HtmplFactory.getInstance(application)

                .getHtmpl("/anag/layout/dettaglioAziendaSede.htm");
%><%@include file = "/include/menu.inc" %><%

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  HtmplUtil.setErrors(htmpl, errors, request);



  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

  htmpl.set("idAzienda", dittaVO.getIdAzienda().toString());



  // Ditta Uma


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



  // Sede legale

  htmpl.set("sl_indirizzo", dittaVO.getSedelegIndirizzo());

  if(dittaVO.getSedelegEstero().equals("")){

    htmpl.newBlock("blkStatoItalia");

    htmpl.set("blkStatoItalia.sl_comune", dittaVO.getSedelegComune());

    htmpl.set("blkStatoItalia.sl_prov", dittaVO.getSedelegProvincia());

    htmpl.set("blkStatoItalia.sl_cap", dittaVO.getSedelegCAP());

  }

  else{

    htmpl.newBlock("blkStatoEstero");

    htmpl.set("blkStatoEstero.sl_stato_estero", dittaVO.getSedelegEstero());

    htmpl.set("blkStatoEstero.sl_citta", dittaVO.getSedelegCittaEstero());
  }

  htmpl.set("sl_sito_web", dittaVO.getSedelegSitoWeb());

  htmpl.set("sl_mail", dittaVO.getSedelegMail());



  htmpl.set("denominazione", dittaVO.getDenominazione());

  htmpl.set("CUAA", dittaVO.getCuaa());

  htmpl.set("dittaUMA", dittaVO.getDittaUMAstr());

  htmpl.set("umaTipoDitta", dittaVO.getTipiDitta());

  htmpl.set("siglaProvUMA", dittaVO.getDescProvinciaUma());



  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  // Ditta di provenienza
  if (dittaVO.getIdDittaUmaProv()!=null)
  {
    htmpl.newBlock("linkDittaProvenienza");
    htmpl.set("linkDittaProvenienza.ditta_provenienza",dittaVO.getDescrizioneDittaUmaProv());
  }


  try {

    UmaFacadeClient umaClient = new UmaFacadeClient();

    it.csi.solmr.presentation.security.AutorizzazioneDittaUMA.writeHeaderCessaBlocco(
            htmpl, dittaVO,
            umaClient.getDettaglioBlocco(dittaVO.getIdDittaUMA()),
            umaClient.getModificheIntermediario(dittaVO.getIdAzienda(),
            dittaVO.getIdDittaUMA()));

  } catch (Exception exc) {

  }

  //Visualizzo gli allegati salvati sul db
  SolmrLogger.debug(this, " -- recupero l'elenco degli allegati");
  UmaFacadeClient umaClient = new UmaFacadeClient();
  List<FileVO> vElencoFileAllegati = umaClient.getAllegatiByIdDittaUma(dittaVO.getIdDittaUMA().longValue());
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