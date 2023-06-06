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
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>

<%



  java.io.InputStream layout = application.getResourceAsStream("/macchina/layout/modificaMatrici.htm");

  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();



  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");



  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  MatriceVO modificaMatriceVO = (MatriceVO)session.getAttribute("matriceVO");

  if(errors == null) {

    HtmplUtil.setValues(htmpl, modificaMatriceVO);

  }

  else {

    HtmplUtil.setErrors(htmpl,errors,request);

    HtmplUtil.setValues(htmpl, modificaMatriceVO);

  }



%>

<%= htmpl.text()%>