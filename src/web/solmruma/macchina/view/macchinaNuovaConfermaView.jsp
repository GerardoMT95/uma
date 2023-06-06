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
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%!

  public static final String ELENCO="../layout/elencoMacchine.htm";

  public static final String ELENCO_BIS="../layout/elencoMacchineBis.htm";

  public static final String DETTAGLIO_MACCHINA="../layout/dettaglioMacchinaDittaDati.htm";

%>



<%

  SolmrLogger.debug(this,"macchinaNuovaConfermaView.jsp - Begin");



  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();



  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application)

                .getHtmpl("macchina/layout/MacchinaNuovaConferma.htm");
%><%@include file = "/include/menu.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


  SolmrLogger.debug(this,"Recupero oggetti dalla session");

  HashMap vecSession = (HashMap) session.getAttribute("common");

  MovimentiTargaVO movimentiTargaVO = (MovimentiTargaVO) vecSession.get("movimentiTargaVO");



  HtmplUtil.setValues(htmpl,movimentiTargaVO,(String)session.getAttribute("pathToFollow"));



  //Modifica Attestazione Proprietà da macchina nuova - Begin

  Long idMacchina = null;

  if( (Long)vecSession.get("idMacchina")!=null ){

    idMacchina = (Long) vecSession.get("idMacchina");

  }

  else{

    idMacchina = movimentiTargaVO.getIdMacchinaLong();

  }

  if( idMacchina!=null ){

    htmpl.set("idMacchina",""+idMacchina);

  }

  //Modifica Attestazione Proprietà da macchina nuova - End



  if (movimentiTargaVO==null)

  {

    htmpl.newBlock("blkSenzaImmatricolazione");

  }

  else

  {

    htmpl.newBlock("blkImmatricolazione");

    TargaVO targaVO=movimentiTargaVO.getDatiTarga()==null?new TargaVO():movimentiTargaVO.getDatiTarga();

    if (targaVO.getPrimoNumeroDisponibile()==null || targaVO.getPrimoNumeroDisponibile().equals(targaVO.getUltimoNumeroDisponibile()))

    {

      htmpl.newBlock("blkImmatricolazione.blkUtlimoNumero");

    }

    htmpl.set("blkImmatricolazione.descProvinciaUma",dittaUMAAziendaVO.getDescProvinciaUma());

    if (SolmrConstants.TARGA_STRADALE_MA.equals(targaVO.getIdTarga()) || SolmrConstants.TARGA_STRADALE_RA.equals(targaVO.getIdTarga()) || SolmrConstants.TARGA_MAO.equals(targaVO.getIdTarga()))

    {

      htmpl.set("blkImmatricolazione.tipoTarga","Stradale");

    }

    else

    {

      htmpl.set("blkImmatricolazione.tipoTarga","UMA");

    }

    htmpl.set("blkImmatricolazione.dataInizioValidita",DateUtils.formatDate(new Date()));

    SolmrLogger.debug(this,"targaVO.getNumeroTarga()="+targaVO.getNumeroTarga());

    htmpl.set("blkImmatricolazione.numeroTarga",targaVO.getNumeroTarga());

  }

  /*if (session.getAttribute("pageFrom")==null)

  {

    htmpl.set("action",ELENCO);

  }

  else

  {

    htmpl.set("action",ELENCO_BIS);

  }*/

  htmpl.set("action", DETTAGLIO_MACCHINA);



  ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");

  SolmrLogger.debug(this,"errors="+errors);

  HtmplUtil.setErrors(htmpl,errors,request);



  out.print(htmpl.text());

%>