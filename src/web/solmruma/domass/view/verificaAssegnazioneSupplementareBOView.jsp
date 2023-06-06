
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
  private static final String CURRENT_PAGE="../layout/verificaAssegnazioneSupplementareBO.htm";
%>
<%
//  frmAssegnazioneSupplementareVO.setIdDomandaassegnazione(new Long(request.getParameter("idDomAss")));
  SolmrLogger.debug(this,"  BEGIN verificaAssegnazioneSupplementareBOView.jsp");
   
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("domass/layout/verificaAssegnazioneSupplementare.htm");
  htmpl.set("exception",exception==null?null:" "+exception.getMessage());
  htmpl.set("idDittaUma",""+session.getAttribute("idDittaUma"));
    
  
%><%@include file = "/include/menu.inc" %><%  SolmrLogger.debug(this,"exception="+exception);

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  SolmrLogger.debug(this,"\n\n\n\n\n***************************************************");
  SolmrLogger.debug(this,"verificaAssegnazioneSupplementareBOView.jsp");

  String pathToFollow=(String)session.getAttribute("pathToFollow");
  ValidationErrors errors=(ValidationErrors) request.getAttribute("errors");
  HtmplUtil.setErrors(htmpl,errors,request);
  SolmrLogger.debug(this,"pageFrom="+CURRENT_PAGE);
  htmpl.set("pageFrom",CURRENT_PAGE);
  htmpl.set("action",CURRENT_PAGE);
  
  FrmDettaglioAssegnazioneVO daVO=frmAssegnazioneSupplementareVO.getFrmDettaglioAssegnazioneVO();


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

 

  //Valorizzazione Consumi in base al tipo Conduzione Ditta - Begin 
  if(request.getAttribute("errors") == null)
  {
    SolmrLogger.debug(this,"request.getAttribute(\"errors\")==null");
    //Codice svolto al primo caricamento della pagina
    long idConduzione;
    idConduzione = new Long (dittaUMAAziendaVO .getIdConduzione()).longValue();

    if (dittaUMAAziendaVO.getIdConduzione() == null){
      //Nel caso in cui il tipo conduzione non sia impostato,
      // lo assume come conto proprio
      idConduzione = 1;
    }

    SolmrLogger.debug(this,"----------------------------------------------------------------------");
    SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getRimanenzaContoProprioGasolioLong(): "+ frmAssegnazioneSupplementareVO.getRimanenzaContoProprioGasolioLong());
    SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getRimanenzaContoTerziGasolioLong(): "+ frmAssegnazioneSupplementareVO.getRimanenzaContoTerziGasolioLong());
    //SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getConsumoContoProprioGasolioLong(): "+ frmAssegnazioneSupplementareVO.getConsumoContoProprioGasolioLong());
    //SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getConsumoContoTerziGasolioLong(): "+ frmAssegnazioneSupplementareVO.getConsumoContoTerziGasolioLong());
    SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getTotDisponibilitaGasolioLong(): "+ frmAssegnazioneSupplementareVO.getTotDisponibilitaGasolioLong());
    //Controllo x verificare che la domanda non sia già in bozza
    if((frmAssegnazioneSupplementareVO.getRimanenzaContoProprioGasolioLong().longValue() +
        frmAssegnazioneSupplementareVO.getRimanenzaContoTerziGasolioLong().longValue() == 0)
        &&
        frmAssegnazioneSupplementareVO.getTotDisponibilitaGasolioLong().longValue() != 0)
    {
      SolmrLogger.debug(this,"Benzina - Rimanenza, Consumi, Disponibilità nulli");
      if ( idConduzione == new Long(""+SolmrConstants.get("IDCONDUZIONECONTOPROPRIO")).longValue()
           || idConduzione == new Long(""+SolmrConstants.get("IDCONDUZIONECONTOPROPRIOETERZI")).longValue()
           )
      {
        SolmrLogger.debug(this,"Benzina - Conto proprio");
        //consumoContoProprioGasolio = frmAssegnazioneSupplementareVO.getTotDisponibilitaGasolio();
        //frmAssegnazioneSupplementareVO.setConsumoContoProprioGasolio(frmAssegnazioneSupplementareVO.getTotDisponibilitaGasolio());
      }
      else{
        SolmrLogger.debug(this,"Benzina - Conto terzi");
        //consumoContoTerziGasolio = frmAssegnazioneSupplementareVO.getTotDisponibilitaGasolio();
        //frmAssegnazioneSupplementareVO.setConsumoContoTerziGasolio(frmAssegnazioneSupplementareVO.getTotDisponibilitaGasolio());
      }
    }

    SolmrLogger.debug(this,"----------------------------------------------------------------------");
    SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getRimanenzaContoProprioBenzinaLong(): "+ frmAssegnazioneSupplementareVO.getRimanenzaContoProprioBenzinaLong());
    SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getRimanenzaContoTerziBenzinaLong(): "+ frmAssegnazioneSupplementareVO.getRimanenzaContoTerziBenzinaLong());
    //SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getConsumoContoProprioBenzinaLong(): "+ frmAssegnazioneSupplementareVO.getConsumoContoProprioBenzinaLong());
    //SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getConsumoContoTerziBenzinaLong(): "+ frmAssegnazioneSupplementareVO.getConsumoContoTerziBenzinaLong());
    SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getTotDisponibilitaBenzinaLong(): "+ frmAssegnazioneSupplementareVO.getTotDisponibilitaBenzinaLong());
    //Controllo x verificare che la domanda non sia già in bozza
    if((frmAssegnazioneSupplementareVO.getRimanenzaContoProprioBenzinaLong().longValue() +
        frmAssegnazioneSupplementareVO.getRimanenzaContoTerziBenzinaLong().longValue() == 0)
        &&
        frmAssegnazioneSupplementareVO.getTotDisponibilitaBenzinaLong().longValue() != 0)
    {
      SolmrLogger.debug(this,"Gasolio - Rimanenza, Consumi, Disponibilità nulli");
      if ( idConduzione == new Long(""+SolmrConstants.get("IDCONDUZIONECONTOPROPRIO")).longValue()
           || idConduzione == new Long(""+SolmrConstants.get("IDCONDUZIONECONTOPROPRIOETERZI")).longValue()
           )
      {
        SolmrLogger.debug(this,"Gasolio - Conto proprio");
        //consumoContoProprioBenzina = frmAssegnazioneSupplementareVO.getTotDisponibilitaBenzina();
        //frmAssegnazioneSupplementareVO.setConsumoContoProprioBenzina(frmAssegnazioneSupplementareVO.getTotDisponibilitaBenzina());
      }
      else{
        SolmrLogger.debug(this,"Benzina - Conto terzi");
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

  /*SolmrLogger.debug(this,"\n\n\n+++++++++++++++++++++++");
  SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getQuantMaxAssContoProprio(): "+frmAssegnazioneSupplementareVO.getQuantMaxAssContoProprio());
  SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getQuantMaxAssSerre(): "+frmAssegnazioneSupplementareVO.getQuantMaxAssSerre());*/

  HtmplUtil.setValues(htmpl,frmAssegnazioneSupplementareVO,pathToFollow);
  HtmplUtil.setValues(htmpl,daVO,pathToFollow);
  //SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getTipiIntermediario()="+frmAssegnazioneSupplementareVO.getTipiIntermediario());
  out.print(htmpl.text());
%>
