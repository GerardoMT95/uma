  <%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.SolmrConstants" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
  SolmrLogger.debug(this,"dettaglioAziendaNoteView inizio ");
  Htmpl htmpl = HtmplFactory.getInstance(application)
                .getHtmpl("/anag/layout/dettaglioAziendaNote.htm");
%><%@include file = "/include/menu.inc" %><%

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  HtmplUtil.setErrors(htmpl, errors, request);

  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
  

  htmpl.set("denominazione", dittaVO.getDenominazione());

  htmpl.set("CUAA", dittaVO.getCuaa());

  htmpl.set("dittaUMA", dittaVO.getDittaUMAstr());

  htmpl.set("umaTipoDitta", dittaVO.getTipiDitta());

  htmpl.set("siglaProvUMA", dittaVO.getDescProvinciaUma());
  

  if(dittaVO!=null)
    htmpl.set("note", dittaVO.getNote());

%>
<%= htmpl.text()%>