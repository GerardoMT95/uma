
<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<jsp:useBean id="frmAssegnazioneSupplementareVO" scope="request"
 class="it.csi.solmr.dto.uma.FrmAssegnazioneSupplementareVO">
</jsp:useBean>
<%!
  private static final String CURRENT_PAGE="../layout/verificaAssegnazioneSupplementare.htm";
%>
<%
//  frmAssegnazioneSupplementareVO.setIdDomandaassegnazione(new Long(request.getParameter("idDomAss")));
  it.csi.solmr.util.SolmrLogger.debug(this,"  BEGIN verificaAssegnazioneSupplementareView.jsp");
    
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("domass/layout/verificaAssegnazioneSupplementare.htm");
  htmpl.set("exception",exception==null?null:" "+exception.getMessage());
  htmpl.set("idDittaUma",""+session.getAttribute("idDittaUma"));
    
  
%><%@include file = "/include/menu.inc" %><%
  it.csi.solmr.util.SolmrLogger.debug(this,"exception="+exception);

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  it.csi.solmr.util.SolmrLogger.debug(this,"\n\n\n\n\n***************************************************");
  it.csi.solmr.util.SolmrLogger.debug(this,"verificaAssegnazioneView.jsp");

  String pathToFollow=(String)session.getAttribute("pathToFollow");
  ValidationErrors errors=(ValidationErrors) request.getAttribute("errors");
  HtmplUtil.setErrors(htmpl,errors,request);
  it.csi.solmr.util.SolmrLogger.debug(this,"ci sono");
  it.csi.solmr.util.SolmrLogger.debug(this,"pageFrom="+CURRENT_PAGE);
  htmpl.set("pageFrom",CURRENT_PAGE);
  htmpl.set("action",CURRENT_PAGE);
  
  FrmDettaglioAssegnazioneVO daVO=frmAssegnazioneSupplementareVO.getFrmDettaglioAssegnazioneVO();

  /*long altreMacchine = daVO.getAltreMacchine().longValue();
  if (daVO.getAltreMacchine().longValue()!=0)
  {
    htmpl.newBlock("blkAltreMacchine");
  }*/
  //htmpl.set("altreMacchine", altreMacchine);

  StringProcessor sp=htmpl.getStringProcessor();
  htmpl.setStringProcessor(null);
  htmpl.set("initCommento","<!--");
  htmpl.set("endCommento","-->");
  htmpl.setStringProcessor(sp);
  frmAssegnazioneSupplementareVO.formatFields();
  
 //Titolo del Supplemento (Supplemento anno xxxx o Supplemento Maggiorazione)
 SolmrLogger.debug(this,"-- Setto il titolo del Supplemento");
 Hashtable common = (Hashtable) session.getAttribute("common");
 if(common != null){
	  String notifica = (String) common.get("notifica");
	  SolmrLogger.debug(this, "--- notifica: " + notifica);
	  if(notifica.equalsIgnoreCase("supplementare")){
		 htmpl.newBlock("blkTitoloAssSuppl");
		 htmpl.set("blkTitoloAssSuppl.annoCorrente", ""+DateUtils.getCurrentYear());
		 htmpl.set("annoCorrente",""+DateUtils.getCurrentYear());
	  }
	  else if(notifica.equalsIgnoreCase("supplementareMaggiorazione")){
		 htmpl.newBlock("blkTitoloAssSupplementareMaggiorazione");
		 CampagnaMaggiorazioneVO campagnaMaggVo = umaClient.getCampagnaMaggiorazionebySysdate();
		 if(campagnaMaggVo != null){
		   htmpl.set("blkTitoloAssSupplementareMaggiorazione.titoloAssSupplMagg", campagnaMaggVo.getTitoloBreveMaggiorazione().toUpperCase());
		 }
	  }
 }

  /*
  if(request.getAttribute("errors") == null)
  {
    if((frmAssegnazioneSupplementareVO.getRimanenzaContoProprioGasolioLong().longValue() +
        frmAssegnazioneSupplementareVO.getRimanenzaContoTerziGasolioLong().longValue() +
        frmAssegnazioneSupplementareVO.getConsumoContoProprioGasolioLong().longValue() +
        frmAssegnazioneSupplementareVO.getConsumoContoTerziGasolioLong().longValue() == 0)
        &&
        frmAssegnazioneSupplementareVO.getTotDisponibilitaGasolioLong().longValue() != 0)
    {
      frmAssegnazioneSupplementareVO.setConsumoContoProprioGasolio(frmAssegnazioneSupplementareVO.getTotDisponibilitaGasolio());
    }
    if((frmAssegnazioneSupplementareVO.getRimanenzaContoProprioBenzinaLong().longValue() +
        frmAssegnazioneSupplementareVO.getRimanenzaContoTerziBenzinaLong().longValue() +
        frmAssegnazioneSupplementareVO.getConsumoContoProprioBenzinaLong().longValue() +
        frmAssegnazioneSupplementareVO.getConsumoContoTerziBenzinaLong().longValue() == 0)
        &&
        frmAssegnazioneSupplementareVO.getTotDisponibilitaBenzinaLong().longValue() != 0)
    {
      frmAssegnazioneSupplementareVO.setConsumoContoProprioBenzina(frmAssegnazioneSupplementareVO.getTotDisponibilitaBenzina());
    }
  }
  */

  //Valorizzazione Consumi in base al tipo Conduzione Ditta - Begin
  it.csi.solmr.util.SolmrLogger.debug(this,"\n\n\n\n\n***************************************************");

  /*String consumoContoProprioGasolio = frmAssegnazioneSupplementareVO.getConsumoContoProprioGasolio();
  String consumoContoProprioBenzina = frmAssegnazioneSupplementareVO.getConsumoContoProprioBenzina();
  String consumoContoTerziGasolio = frmAssegnazioneSupplementareVO.getConsumoContoTerziGasolio();
  String consumoContoTerziBenzina = frmAssegnazioneSupplementareVO.getConsumoContoTerziBenzina();*/

  if(request.getAttribute("errors") == null)
  {
    it.csi.solmr.util.SolmrLogger.debug(this,"request.getAttribute(\"errors\")==null");
    //Codice svolto al primo caricamento della pagina
    long idConduzione;
    idConduzione = new Long (dittaUMAAziendaVO .getIdConduzione()).longValue();

    if (dittaUMAAziendaVO.getIdConduzione() == null){
      //Nel caso in cui il tipo conduzione non sia impostato,
      // lo assume come conto proprio
      idConduzione = 1;
    }

    it.csi.solmr.util.SolmrLogger.debug(this,"----------------------------------------------------------------------");
    it.csi.solmr.util.SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getRimanenzaContoProprioGasolioLong(): "+ frmAssegnazioneSupplementareVO.getRimanenzaContoProprioGasolioLong());
    it.csi.solmr.util.SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getRimanenzaContoTerziGasolioLong(): "+ frmAssegnazioneSupplementareVO.getRimanenzaContoTerziGasolioLong());
    //it.csi.solmr.util.SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getConsumoContoProprioGasolioLong(): "+ frmAssegnazioneSupplementareVO.getConsumoContoProprioGasolioLong());
    //it.csi.solmr.util.SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getConsumoContoTerziGasolioLong(): "+ frmAssegnazioneSupplementareVO.getConsumoContoTerziGasolioLong());
    it.csi.solmr.util.SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getTotDisponibilitaGasolioLong(): "+ frmAssegnazioneSupplementareVO.getTotDisponibilitaGasolioLong());
    //Controllo x verificare che la domanda non sia già in bozza
    if((frmAssegnazioneSupplementareVO.getRimanenzaContoProprioGasolioLong().longValue() +
        frmAssegnazioneSupplementareVO.getRimanenzaContoTerziGasolioLong().longValue() == 0)
        &&
        frmAssegnazioneSupplementareVO.getTotDisponibilitaGasolioLong().longValue() != 0)
    {
      it.csi.solmr.util.SolmrLogger.debug(this,"Benzina - Rimanenza, Consumi, Disponibilità nulli");
      if ( idConduzione == new Long(""+SolmrConstants.get("IDCONDUZIONECONTOPROPRIO")).longValue()
           || idConduzione == new Long(""+SolmrConstants.get("IDCONDUZIONECONTOPROPRIOETERZI")).longValue()
           )
      {
        it.csi.solmr.util.SolmrLogger.debug(this,"Benzina - Conto proprio");
        //consumoContoProprioGasolio = frmAssegnazioneSupplementareVO.getTotDisponibilitaGasolio();
        //frmAssegnazioneSupplementareVO.setConsumoContoProprioGasolio(frmAssegnazioneSupplementareVO.getTotDisponibilitaGasolio());
      }
      else{
        it.csi.solmr.util.SolmrLogger.debug(this,"Benzina - Conto terzi");
        //consumoContoTerziGasolio = frmAssegnazioneSupplementareVO.getTotDisponibilitaGasolio();
        //frmAssegnazioneSupplementareVO.setConsumoContoTerziGasolio(frmAssegnazioneSupplementareVO.getTotDisponibilitaGasolio());
      }
    }

    it.csi.solmr.util.SolmrLogger.debug(this,"----------------------------------------------------------------------");
    it.csi.solmr.util.SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getRimanenzaContoProprioBenzinaLong(): "+ frmAssegnazioneSupplementareVO.getRimanenzaContoProprioBenzinaLong());
    it.csi.solmr.util.SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getRimanenzaContoTerziBenzinaLong(): "+ frmAssegnazioneSupplementareVO.getRimanenzaContoTerziBenzinaLong());
    //it.csi.solmr.util.SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getConsumoContoProprioBenzinaLong(): "+ frmAssegnazioneSupplementareVO.getConsumoContoProprioBenzinaLong());
    //it.csi.solmr.util.SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getConsumoContoTerziBenzinaLong(): "+ frmAssegnazioneSupplementareVO.getConsumoContoTerziBenzinaLong());
    it.csi.solmr.util.SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getTotDisponibilitaBenzinaLong(): "+ frmAssegnazioneSupplementareVO.getTotDisponibilitaBenzinaLong());
    //Controllo x verificare che la domanda non sia già in bozza
    if((frmAssegnazioneSupplementareVO.getRimanenzaContoProprioBenzinaLong().longValue() +
        frmAssegnazioneSupplementareVO.getRimanenzaContoTerziBenzinaLong().longValue() == 0)
        &&
        frmAssegnazioneSupplementareVO.getTotDisponibilitaBenzinaLong().longValue() != 0)
    {
      it.csi.solmr.util.SolmrLogger.debug(this,"Gasolio - Rimanenza, Consumi, Disponibilità nulli");
      if ( idConduzione == new Long(""+SolmrConstants.get("IDCONDUZIONECONTOPROPRIO")).longValue()
           || idConduzione == new Long(""+SolmrConstants.get("IDCONDUZIONECONTOPROPRIOETERZI")).longValue()
           )
      {
        it.csi.solmr.util.SolmrLogger.debug(this,"Gasolio - Conto proprio");
        //consumoContoProprioBenzina = frmAssegnazioneSupplementareVO.getTotDisponibilitaBenzina();
        //frmAssegnazioneSupplementareVO.setConsumoContoProprioBenzina(frmAssegnazioneSupplementareVO.getTotDisponibilitaBenzina());
      }
      else{
        it.csi.solmr.util.SolmrLogger.debug(this,"Benzina - Conto terzi");
        //consumoContoTerziBenzina = frmAssegnazioneSupplementareVO.getTotDisponibilitaBenzina();
        //frmAssegnazioneSupplementareVO.setConsumoContoTerziBenzina(frmAssegnazioneSupplementareVO.getTotDisponibilitaBenzina());
      }
    }

    //Imposta il tipo conduzione per il JavaScript di calcolo automatico dei consumi
    htmpl.set("tipoConduzione",""+idConduzione);

    /*htmpl.set("consumoContoProprioGasolio", consumoContoProprioGasolio);
    htmpl.set("consumoContoProprioBenzina", consumoContoProprioBenzina);

    htmpl.set("consumoContoTerziGasolio", consumoContoTerziGasolio);
    htmpl.set("consumoContoTerziBenzina", consumoContoTerziBenzina);*/
  }

  //Valorizzazione Consumi in base al tipo Conduzione Ditta - End

  /*it.csi.solmr.util.SolmrLogger.debug(this,"\n\n\n+++++++++++++++++++++++");
  it.csi.solmr.util.SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getQuantMaxAssContoProprio(): "+frmAssegnazioneSupplementareVO.getQuantMaxAssContoProprio());
  it.csi.solmr.util.SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getQuantMaxAssSerre(): "+frmAssegnazioneSupplementareVO.getQuantMaxAssSerre());*/

  HtmplUtil.setValues(htmpl,frmAssegnazioneSupplementareVO,pathToFollow);
  HtmplUtil.setValues(htmpl,daVO,pathToFollow);
  //it.csi.solmr.util.SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getTipiIntermediario()="+frmAssegnazioneSupplementareVO.getTipiIntermediario());
  out.print(htmpl.text());
%>
