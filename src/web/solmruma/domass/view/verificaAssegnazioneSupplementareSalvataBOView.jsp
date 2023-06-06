<%@ page language="java"
         contentType="text/html"
         isErrorPage="true"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.etc.uma.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>


<jsp:useBean id="frmAssegnazioneSupplementareVO" scope="request"
 class="it.csi.solmr.dto.uma.FrmAssegnazioneSupplementareVO">
  <jsp:setProperty name="frmAssegnazioneSupplementareVO" property="*" />
</jsp:useBean>
<%!
  private static final String LAYOUT_PAGE="/domass/layout/verificaAssegnazioneSupplementareSalvataBO.htm";
  private static final String PAGE_FROM="../layout/verificaAssegnazioneSupplementareSalvataBO.htm";
%>
<%
  SolmrLogger.debug(this,"verificaAssegnazioneSalvataBOView.jsp -  INIZIO PAGINA");
  Long idDittaUma=(Long)session.getAttribute("idDittaUma");

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  Htmpl htmpl = HtmplFactory.getInstance(application)
              .getHtmpl(LAYOUT_PAGE);
%><%@include file = "/include/menu.inc" %><%

  SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getExtIdIntermediarioLong(): "+
                     frmAssegnazioneSupplementareVO.getExtIdIntermediarioLong());

  //if( idAssCarbIntermediario!=null ) {
  SolmrLogger.debug(this, "------ extIdIntermediario ="+frmAssegnazioneSupplementareVO.getExtIdIntermediarioLong());	  
  if( frmAssegnazioneSupplementareVO.getExtIdIntermediarioLong().longValue()!=0 )
  {   
	htmpl.newBlock("blkPAVALIDARIFIUTA");
	
	htmpl.newBlock("blkPAVALIDA");

    if(request.getParameter("valida.x")==null)
    {
      htmpl.bset("dataConsegnaDoc", DateUtils.getCurrentDateString());
    }
    else
    {
      htmpl.bset("dataConsegnaDoc", request.getParameter("dataConsegnaDoc"));
    }

    //htmpl.set("blkPAVALIDA.extIdIntermediario", ""+frmAssegnazioneSupplementareVO.getExtIdIntermediarioLong());
  }
  else{
    htmpl.newBlock("blkPAASSEGNAZIONE");
  }

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  
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
		 UmaFacadeClient umaClient = new UmaFacadeClient();
		 CampagnaMaggiorazioneVO campagnaMaggVo = umaClient.getCampagnaMaggiorazionebySysdate();
		 if(campagnaMaggVo != null){
		   htmpl.set("blkTitoloAssSupplementareMaggiorazione.titoloAssSupplMagg", campagnaMaggVo.getTitoloBreveMaggiorazione().toUpperCase());
		 }
	  }
 }
  
  
  
  
  ValidationErrors errors=(ValidationErrors) request.getAttribute("errors");
  SolmrLogger.debug(this,"errors="+errors);
  if (errors!=null)
  {
    HtmplUtil.setErrors(htmpl,errors,request);
  }

  htmpl.set("idDittaUma",""+idDittaUma);


  String pathToFollow=(String)session.getAttribute("pathToFollow");
  SolmrLogger.debug(this,"pageFrom="+LAYOUT_PAGE);
  htmpl.set("pageFrom",PAGE_FROM);
  FrmDettaglioAssegnazioneVO daVO=frmAssegnazioneSupplementareVO.getFrmDettaglioAssegnazioneVO();
  if (frmAssegnazioneSupplementareVO.getExtIdIntermediarioLong()!=null && frmAssegnazioneSupplementareVO.getExtIdIntermediarioLong().longValue()==0)
  {
    frmAssegnazioneSupplementareVO.setExtIdIntermediario(null);
  }

  /*SolmrLogger.debug(this,"\n\n\n*-*-*-*-*-*-*-*-*-*-*-*-*");
  frmAssegnazioneSupplementareVO.setQuantMaxAssSerre("2345");
  SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getQuantMaxAssContoProprio(): "+frmAssegnazioneSupplementareVO.getQuantMaxAssContoProprio());
  SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getQuantMaxAssSerre(): "+frmAssegnazioneSupplementareVO.getQuantMaxAssSerre());*/

  frmAssegnazioneSupplementareVO.formatFields();

  /*SolmrLogger.debug(this,"\n\n\n\n\n+-+-+-+--+-+-+-+-+-+-+-+-+-+-+");
  SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getExtIdIntermediario(): "+frmAssegnazioneSupplementareVO.getExtIdIntermediario());*/
  SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getDescTipiSupplemento(): "+frmAssegnazioneSupplementareVO.getDescTipiSupplemento());
  HtmplUtil.setValues(htmpl,frmAssegnazioneSupplementareVO,pathToFollow);
  HtmplUtil.setValues(htmpl,daVO,pathToFollow);

%>
<%=htmpl.text()%>