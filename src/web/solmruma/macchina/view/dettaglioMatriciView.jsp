<%@
  page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.etc.*"%>

<%



  java.io.InputStream layout = application.getResourceAsStream("/macchina/layout/dettaglioMatrici.htm");

  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


  if(!ruoloUtenza.isUtenteIntermediario()) {

    htmpl.newBlock("bloccoDettaglio");

    htmpl.newBlock("bloccoRicerca");

  }



  MatriceVO matriceVO = (MatriceVO)session.getAttribute("matriceVO");

  HtmplUtil.setValues(htmpl,matriceVO);



  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  HtmplUtil.setErrors(htmpl,errors,request);



%>

<%= htmpl.text()%>