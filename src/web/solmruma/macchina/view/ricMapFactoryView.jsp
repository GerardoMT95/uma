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
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%
  SolmrLogger.debug(this,"ricMapFactory started");

  String LAYOUT ="macchina/layout/ricMapFactory.htm";
  //LAYOUT ="macchina/layout/nuovaImmatricolazioneConferma.htm";

  SolmrLogger.debug(this,"LAYOUT: "+LAYOUT);
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  String pathToFollow=(String)request.getAttribute("pathToFollow");

  SolmrLogger.debug(this,"request: "+request);
  //HtmplUtil.clearCachedEntity("tipiFormaSerra", request);
  //HtmplUtil.clearAllEntities(request);
  HtmplUtil.setValues(htmpl, request);
  out.print(htmpl.text());
%>
