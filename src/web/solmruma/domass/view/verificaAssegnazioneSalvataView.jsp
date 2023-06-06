<%@ page language="java"
         contentType="text/html"
         isErrorPage="true"
%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<jsp:useBean id="frmVerificaAssegnazioneVO" scope="request"
 class="it.csi.solmr.dto.uma.FrmVerificaAssegnazioneVO">
  <jsp:setProperty name="frmVerificaAssegnazioneVO" property="*" />
</jsp:useBean>
<%!
  private static final String LAYOUT_PAGE="/domass/layout/verificaAssegnazioneSalvata.htm";
  private static final String PAGE_FROM="../layout/verificaAssegnazioneSalvata.htm";
  private static final String PAGE_PREV="../layout/verificaAssegnazione.htm";
%>
<%
  Long idDittaUma=(Long)session.getAttribute("idDittaUma");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT_PAGE);
%><%@include file = "/include/menu.inc" %><%
  htmpl.set("annoCorrente",""+DateUtils.getCurrentYear());
  htmpl.set("annoPrecedente", "" + (DateUtils.getCurrentYear()-1));
  htmpl.set("idDittaUma",""+idDittaUma);
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

  String pathToFollow=(String)session.getAttribute("pathToFollow");
  SolmrLogger.debug(this,"pageFrom="+LAYOUT_PAGE);
  htmpl.set("pageFrom",PAGE_FROM);
  FrmDettaglioAssegnazioneVO daVO=frmVerificaAssegnazioneVO.getFrmDettaglioAssegnazioneVO();
  frmVerificaAssegnazioneVO.formatFields();

  //061121 Validazione domanda da parte dell'intermediario - Begin
  
  if(ruoloUtenza.isUtenteIntermediario()){
    htmpl.newBlock("blkProtocolloIntermediario");
    htmpl.set("blkProtocolloIntermediario.dataProtocollo", frmVerificaAssegnazioneVO.getDataProtocollo());
    htmpl.set("blkProtocolloIntermediario.numeroProtocollo", frmVerificaAssegnazioneVO.getNumeroProtocollo());
  }
  //061121 Validazione domanda da parte dell'intermediario - End

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
	
    ////htmpl.set("rimanenzaMinimaCPTBenzina",StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaCPTBenzina")));    
    //htmpl.set("rimanenzaMinimaCPTGasolio",StringUtils.checkNull(mapRimanenzeMinime.get("rimanenzaMinimaCPTGasolio")));    
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
    if (sommeRimanenze.isTrasmissioneNecessaria(frmVerificaAssegnazioneVO.getQuantMaxAssContoProprioLong().intValue(),
      frmVerificaAssegnazioneVO.getQuantMaxAssSerreLong().intValue()))
    {
      frmVerificaAssegnazioneVO.setDomandaValidabileDaIntermediario(false);
    }
  }

  //061204 Gestione validazione intermediario - Begin
  if(ruoloUtenza.isUtenteIntermediario()){
    /* Effettuo il controllo solo se mapRimanenzeMinime è valorizzato 
      (non è valorizzato quando si lavora su una ditta nuova, che non ha un'idDomandaAssegnazionePrecedente)
       -> in questo caso visualizzare il pulsante 'Valida'
    */ 
    if(mapRimanenzeMinime != null){
		SolmrLogger.debug(this," ----- Effettuo controlli isRimanenzaDichiarataNonConformeRimanenzaMinima");
	    boolean isRimanenzaNonConforme=frmVerificaAssegnazioneVO.isRimanenzaDichiarataNonConformeRimanenzaMinima(mapRimanenzeMinime,session);
/*         
	    if(frmVerificaAssegnazioneVO.isDomandaValidabileDaIntermediario() &&
	       !isRimanenzaNonConforme)
	    {
	      htmpl.newBlock("blk_FO.blkValida");
	    }
	    else{ */
	      htmpl.newBlock("blk_FO.blkTrasmetti");
	      if (isRimanenzaNonConforme)
	      {
	        htmpl.newBlock("blkRimanenzeNonConformi");
	      }
/* 	    } */
    }
    else{
      SolmrLogger.debug(this," ----- Non e' necessario effettuare i controlli isRimanenzaDichiarataNonConformeRimanenzaMinima, visualizzare 'Valida'");
     // htmpl.newBlock("blk_FO.blkValida");
      htmpl.newBlock("blk_FO.blkTrasmetti");
    }
  }
  //061204 Gestione validazione intermediario - End
  htmpl.bset("pagePrev",PAGE_PREV);
  
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
%><%=htmpl.text() %>
