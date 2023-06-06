  <%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>



<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>





<%

  java.io.InputStream layout = application.getResourceAsStream("/ditta/layout/nuovaDittaUmaAnagrafica.htm");

  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  htmpl.set("nomeCognomeUtente",ruoloUtenza.getDenominazione());



  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");



  if(errors != null) {

    HtmplUtil.setErrors(htmpl, errors, request);

    HtmplUtil.setValues(htmpl, request);

  }

  else {

    HtmplUtil.setValues(htmpl, request);

  }

  Vector provincie=(Vector)request.getAttribute("province");
  htmpl.set("provinciaDittaUma", (String)request.getAttribute("siglaProvincia"));
%>

<%= htmpl.text()%>





