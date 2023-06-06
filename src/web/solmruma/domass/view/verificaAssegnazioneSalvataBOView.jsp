<%@ page language="java"

         contentType="text/html"

         isErrorPage="true"

%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.etc.uma.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza"%>
<jsp:useBean id="frmVerificaAssegnazioneVO" scope="request"
 class="it.csi.solmr.dto.uma.FrmVerificaAssegnazioneVO">
  <jsp:setProperty name="frmVerificaAssegnazioneVO" property="*" />
</jsp:useBean>
<%!

  private static final String LAYOUT_PAGE="/domass/layout/verificaAssegnazioneSalvataBO.htm";

  private static final String PAGE_FROM="../layout/verificaAssegnazioneSalvataBO.htm";

%>
<%

  SolmrLogger.debug(this,"verificaAssegnazioneSalvataBOView.jsp -  INIZIO PAGINA");

  Long idDittaUma=(Long)session.getAttribute("idDittaUma");

  Htmpl htmpl = HtmplFactory.getInstance(application)

              .getHtmpl(LAYOUT_PAGE);
%><%@include file = "/include/menu.inc" %><%
  htmpl.set("annoCorrente",""+DateUtils.getCurrentYear());
  htmpl.set("annoPrecedente", "" + (DateUtils.getCurrentYear()-1));

  ValidationErrors errors=(ValidationErrors) request.getAttribute("errors");

  SolmrLogger.debug(this,"errors="+errors);
  
  
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  // Controllo il ruolo dell'utente per visualizzare il messaggio corretto ed il pulsante 'valida' o 'trasmetti'(Caso di Persona fisica)
  if(ruoloUtenza.isUtenteProvinciale() || ruoloUtenza.isUtenteRegionale()){
	  SolmrLogger.debug(this, "-- CASO DI RUOLO PROVINCIALE O REGIONALE"); 
	  htmpl.newBlock("blkMessaggioProvReg");
	  htmpl.newBlock("blkValida");
  }
  else{
	 SolmrLogger.debug(this, "-- CASO DI RUOLO PERSONA FISICA"); 
	 htmpl.newBlock("blkMessaggioPersonaFisica");
	 htmpl.newBlock("blkTrasmetti");	 
  }

  if (errors!=null)

  {

    SolmrLogger.debug(this,"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nView errors="+errors);

    HtmplUtil.setErrors(htmpl,errors,request);

  }
  else
  {
    if (frmVerificaAssegnazioneVO.getExtIdIntermediario()!=null &&
        frmVerificaAssegnazioneVO.getExtIdIntermediario().longValue()!=0 &&
        request.getParameter("validaDomAss")==null)
    {
      long qMax=longValue(frmVerificaAssegnazioneVO.getQuantMaxAssContoProprio());
      long acpg=longValue(frmVerificaAssegnazioneVO.getAssNettaContoProprioGasolio());
      long acpb=longValue(frmVerificaAssegnazioneVO.getAssNettaContoProprioBenzina());
      long rcpg=longValue(frmVerificaAssegnazioneVO.getRimanenzaContoProprioGasolio());
      long rcpb=longValue(frmVerificaAssegnazioneVO.getRimanenzaContoProprioBenzina());
      long total=qMax-(acpg+acpb+rcpg+rcpb);
      if (total<0)
      {
        errors=new ValidationErrors();
        String msgError="Attenzione: e' stato assegnato carburante in quantità "+
                                       "superiore al quantitativo massimo calcolato dovuto alla presenza "+
                                       "di macchine non considerate nel calcolo o alla presenza di rimanenze da cessazione di ditte uma";
        htmpl.set("err_error","alert(\""+msgError+"\")");
      }
    }
  }



  htmpl.set("idDittaUma",""+idDittaUma);





  String pathToFollow=(String)session.getAttribute("pathToFollow");

  SolmrLogger.debug(this,"pageFrom="+LAYOUT_PAGE);

  htmpl.set("pageFrom",PAGE_FROM);

  FrmDettaglioAssegnazioneVO daVO=frmVerificaAssegnazioneVO.getFrmDettaglioAssegnazioneVO();

  if (frmVerificaAssegnazioneVO.getExtIdIntermediario()!=null && frmVerificaAssegnazioneVO.getExtIdIntermediario().longValue()==0)

  {

    frmVerificaAssegnazioneVO.setExtIdIntermediario(null);

  }

  frmVerificaAssegnazioneVO.formatFields();
  
 //Se la Domanda Assegnazione è stata presentata dall'intermediario
 if (frmVerificaAssegnazioneVO.getExtIdIntermediario() !=null && frmVerificaAssegnazioneVO.getExtIdIntermediario().longValue() !=0)
 {
   // Domanda creata da intermediario
   htmpl.newBlock("blk_Indietro");
   htmpl.newBlock("blk_HideDatiDocumentiIntermediario");  
   
   if (request.getParameter("validaDomAss")==null){
     htmpl.set("blk_HideDatiDocumentiIntermediario.dataRicevutaDocumenti", DateUtils.getCurrentDateString());
   }
 }

  HtmplUtil.setValues(htmpl,frmVerificaAssegnazioneVO,pathToFollow);

  HtmplUtil.setValues(htmpl,daVO,pathToFollow);

  htmpl.newBlock("blk_FO");

  HashMap mapRimanenzeMinime=(HashMap)request.getAttribute("mapRimanenzeMinime");
  if (mapRimanenzeMinime!=null)
  {
	 htmpl.set("rimanenzaMinimaCPBenzina", StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaCPBenzina")));
	 htmpl.set("rimanenzaMinimaCTBenzina", StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaCTBenzina")));
	 htmpl.set("rimanenzaMinimaCPGasolio", StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaCPGasolio")));
	 htmpl.set("rimanenzaMinimaCTGasolio", StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaCTGasolio")));
	 
	 htmpl.set("rimanenzaMinimaSerreBenzina",StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaSerreBenzina")));
	 htmpl.set("rimanenzaMinimaSerreGasolio",StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaSerreGasolio")));
    //htmpl.set("rimanenzaMinimaCPTBenzina",StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaCPTBenzina")));    
    //htmpl.set("rimanenzaMinimaCPTGasolio",StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaCPTGasolio")));    
  }

  SolmrLogger.debug(this, " --- supplemento ="+request.getParameter("supplemento"));
  if (request.getParameter("supplemento")==null)

  {

    htmpl.set("msgConfirm",UmaErrors.MSGFOGLIORIGAASSCARBBASE);

  }

  else

  {

    htmpl.set("msgConfirm",UmaErrors.MSGFOGLIORIGAASSCARBSUPP);

  }

  SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getExtIdIntermediario()="+frmVerificaAssegnazioneVO.getExtIdIntermediario());



  //28/05/2004 - Documenti Azienda - Begin

  /*SolmrLogger.debug(this,"\n\n\n\n/-----------------------------------------------------/");

  SolmrLogger.debug(this,"request.getParameter(\"annullaValida\"): "+request.getParameter("annullaValida"));

  SolmrLogger.debug(this,"Before - if (frmVerificaAssegnazioneVO.getNumeroDoc()==null)");

  if (request.getParameter("annullaValida")!=null

      && frmVerificaAssegnazioneVO.getNumeroDoc()==null){

     SolmrLogger.debug(this,"if (frmVerificaAssegnazioneVO.getNumeroDoc()==null)");

     frmVerificaAssegnazioneVO.setDataRicevutaDocumentiAzienda(frmVerificaAssegnazioneVO.getDataRicevutaDocumenti());

  }

  SolmrLogger.debug(this,"After - if (frmVerificaAssegnazioneVO.getNumeroDoc()==null)");*/

  //28/05/2004 - Documenti Azienda - End

 /* if (frmVerificaAssegnazioneVO.getExtIdIntermediario()==null || frmVerificaAssegnazioneVO.getExtIdIntermediario().longValue()==0)
  {
    // Domanda non creata da intermediario
    htmpl.newBlock("blk_Indietro");
    htmpl.newBlock("blk_HideDatiDocumentiIntermediario");
    htmpl.newBlock("blkIntermediarioDocCarta");
    htmpl.set("blkIntermediarioDocCarta.denominazioneIntermediario",(String) request.getAttribute("denominazioneIntermediario"));
    htmpl.set("blkIntermediarioDocCarta.dataRicevutaDocumenti",frmVerificaAssegnazioneVO.getDataRicevutaDocumenti());
    htmpl.set("blkIntermediarioDocCarta.numeroRicevutaDocumenti",frmVerificaAssegnazioneVO.getNumeroRicevutaDocumenti());
    htmpl.set("blkIntermediarioDocCarta.dataRicevutaDocumentiAzienda",frmVerificaAssegnazioneVO.getDataRicevutaDocumentiAzienda());
  }
  else 
  {
    // Domanda creata da intermediario
    htmpl.newBlock("blk_Rifiuta");
    htmpl.newBlock("blk_Annulla");
  }*/
  
 
  
  /* Se siamo in caso di Ruolo Regionale : dobbiamo vedere i pulsanti : valida, rifiuta e annulla 
  	(Note : in TOBECONFIG le Domande possono essere presentate da ruolo Intermediario o ruolo dalla Persona fisica)
  */
  if(ruoloUtenza.isUtenteProvinciale() || ruoloUtenza.isUtenteRegionale()){
    htmpl.newBlock("blk_Rifiuta");
	htmpl.newBlock("blk_Annulla");
  }
  
  SommeRimanenzeDaCessazioneVO sommeRimanenze=(SommeRimanenzeDaCessazioneVO)
    request.getAttribute("sommeRimanenze");
  if (sommeRimanenze!=null)
  {
    htmpl.newBlock("blkRimanenzeDaCessazione");
    
    htmpl.set("blkRimanenzeDaCessazione.rimCessataContoProprioGasolio",String.valueOf(sommeRimanenze.getSommaContoProprioGasolio()));
    htmpl.set("blkRimanenzeDaCessazione.rimCessataContoProprioBenzina",String.valueOf(sommeRimanenze.getSommaContoProprioBenzina()));
    
    htmpl.set("blkRimanenzeDaCessazione.rimCessataContoTerziGasolio",String.valueOf(sommeRimanenze.getSommaContoTerziGasolio()));
    htmpl.set("blkRimanenzeDaCessazione.rimCessataContoTerziBenzina",String.valueOf(sommeRimanenze.getSommaContoTerziBenzina()));
    
    htmpl.set("blkRimanenzeDaCessazione.rimCessataRiscSerraGasolio",String.valueOf(sommeRimanenze.getSommaSerraGasolio()));
    htmpl.set("blkRimanenzeDaCessazione.rimCessataRiscSerraBenzina",String.valueOf(sommeRimanenze.getSommaSerraBenzina()));
    htmpl.set("blkRimanenzeDaCessazione.totRimCessataGasolio",String.valueOf(sommeRimanenze.getSommaGasolio()));
    htmpl.set("blkRimanenzeDaCessazione.totRimCessataBenzina",String.valueOf(sommeRimanenze.getSommaBenzina()));
  }

  Long debitiContoProprio = (Long) request.getAttribute("debitiContoProprio");
  Long debitiContoTerzi = (Long) request.getAttribute("debitiContoTerzi");
  
  Long debitoSerra = (Long) request.getAttribute("debitiSerra");

  if (debitiContoProprio != null)
  {
    // Esiste il debito CP
    SolmrLogger.debug(this, "-- Esiste il debito CP");
    htmpl.newBlock("blkDebitoCP");
    htmpl.set("blkDebitoCP.debitoCP", String.valueOf(debitiContoProprio));
  }
  
  if (debitiContoTerzi != null)
  {
    // Esiste il debito CT
    SolmrLogger.debug(this, "-- Esiste il debito CT");
    htmpl.newBlock("blkDebitoCT");
    htmpl.set("blkDebitoCT.debitoCT", String.valueOf(debitiContoTerzi));
  }

  if (debitoSerra != null)
  {
    // Esiste il debito
    htmpl.newBlock("blkDebitoSerra");
    htmpl.set("blkDebitoSerra.debitoSerra", String
        .valueOf(debitoSerra));
  }
%>
<%!
  private long longValue(String str)
  {
    if (!Validator.isNotEmpty(str))
    {
      return 0;
    }
    return new Long(str).longValue();
  }
  
  private String convertStrintIntoLongBlankOnZero(long value)
  {
    return value == 0 ? "" : String.valueOf(value);
  }
%>
<%=htmpl.text()%>

