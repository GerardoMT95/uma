<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>

<%@ page import="it.csi.solmr.business.uma.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

//java.io.InputStream layout = application.getResourceAsStream("/uma/anag/layout/elencoAziende.htm");

//SolmrLogger.info(this, "Found layout: "+layout);

//Htmpl htmpl = new Htmpl(layout);

Htmpl htmpl = HtmplFactory.getInstance(application)

              .getHtmpl("/anag/layout/autocertificazioneDelega.htm");

%><%@include file = "/include/menu.inc" %><%

ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");



RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");



if(dittaVO!=null){



  htmpl.set("uma_num", dittaVO.getDittaUMAstr());

  htmpl.set("uma_prov", dittaVO.getSiglaProvUMA());



  htmpl.set("denominazione", dittaVO.getDenominazione());

  htmpl.set("cuaa", dittaVO.getCuaa());

  htmpl.set("partitaIVA", dittaVO.getPartitaIVA());

  if(dittaVO!=null && dittaVO.getSedelegEstero()!=null && !dittaVO.getSedelegEstero().equals("")){

    htmpl.newBlock("blkEstero");

    htmpl.set("blkEstero.sedelegStatoEstero",StringUtils.checkNull(dittaVO.getSedelegEstero()));

    htmpl.set("blkEstero.sedelegCittaEstero",StringUtils.checkNull(dittaVO.getSedelegCittaEstero()));

  }

  else{

    htmpl.newBlock("blkItalia");

    htmpl.set("blkItalia.sedelegComune",StringUtils.checkNull(dittaVO.getSedelegComune()));

    htmpl.set("blkItalia.sedelegProv",StringUtils.checkNull(dittaVO.getSedelegProv()));

  }

}

if(errors!=null)

  HtmplUtil.setErrors(htmpl, errors, request);

it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

%>

<%= htmpl.text()%>