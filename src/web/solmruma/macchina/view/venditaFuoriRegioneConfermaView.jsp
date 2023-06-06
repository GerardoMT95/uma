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

  public static final String ELENCO="../layout/dettaglioMacchinaDittaImmatricolazioni.htm";

%>



<%



  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();



  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("macchina/layout/venditaFuoriRegioneConferma.htm");
%><%@include file = "/include/menu.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  MovimentiTargaVO movimentiTargaVO = (MovimentiTargaVO) request.getAttribute("movimentiTargaVO");

  HtmplUtil.setValues(htmpl,movimentiTargaVO,(String)session.getAttribute("pathToFollow"));

  if (movimentiTargaVO==null)

  {

    htmpl.newBlock("blkSenzaImmatricolazione");

  }

  else

  {



    TargaVO targaVO=movimentiTargaVO.getDatiTarga()==null?new TargaVO():movimentiTargaVO.getDatiTarga();

    htmpl.set("idMacchina", targaVO.getIdMacchina());



    htmpl.newBlock("blkImmatricolazione");

    /*if (targaVO.getPrimoNumeroDisponibile()==null || targaVO.getPrimoNumeroDisponibile().equals(targaVO.getUltimoNumeroDisponibile()))

    {

      htmpl.newBlock("blkImmatricolazione.blkUtlimoNumero");

    }*/

    //htmpl.set("blkImmatricolazione.descProvinciaUma",dittaUMAAziendaVO.getDescProvinciaUma());

    htmpl.set("blkImmatricolazione.descProvinciaUma",movimentiTargaVO.getSiglaProvincia());

    if (SolmrConstants.TARGA_STRADALE_MA.equals(targaVO.getIdTarga()) || SolmrConstants.TARGA_STRADALE_RA.equals(targaVO.getIdTarga()) || SolmrConstants.TARGA_MAO.equals(targaVO.getIdTarga()))

    {

      htmpl.set("blkImmatricolazione.tipoTarga","Stradale");

    }

    else

    {

      htmpl.set("blkImmatricolazione.tipoTarga","UMA");

    }

    //htmpl.set("blkImmatricolazione.dataInizioValidita",DateUtils.formatDate(new Date()));

    htmpl.set("blkImmatricolazione.dittaUma",movimentiTargaVO.getDittaUma());

    SolmrLogger.debug(this,"targaVO.getNumeroTarga()="+targaVO.getNumeroTarga());

    htmpl.set("blkImmatricolazione.numeroTarga",targaVO.getNumeroTarga());

  }

  htmpl.set("action",ELENCO);



  ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");

  SolmrLogger.debug(this,"errors="+errors);

  HtmplUtil.setErrors(htmpl,errors,request);



  out.print(htmpl.text());

%>