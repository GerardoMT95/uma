
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
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%!
  private static final String NEXT_PAGE="../layout/verificaAssegnazioneSupplementareTrasmessa.htm";
  private static final String PREV_PAGE="../layout/verificaAssegnazioneSupplementareSalvata.htm";
%>
<jsp:useBean id="frmAssegnazioneSupplementareVO" scope="request"
 class="it.csi.solmr.dto.uma.FrmAssegnazioneSupplementareVO">
  <jsp:setProperty name="frmAssegnazioneSupplementareVO" property="*" />
</jsp:useBean>
<%
  Htmpl htmpl = HtmplFactory.getInstance(application)
                .getHtmpl("domass/layout/confermaValidazioneAssegnazioneSuppl.htm");
%><%@include file = "/include/menu.inc" %>
<%  
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  UmaFacadeClient client = new UmaFacadeClient();
  htmpl.set("idDomandaAssegnazione",request.getParameter("idDomandaassegnazione"));
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
  htmpl.set("messaggio",UmaErrors.MSGFOGLIORIGAASSCARBSUPP);

  HtmplUtil.setValues(htmpl,frmAssegnazioneSupplementareVO,(String)session.getAttribute("pathToFollow"));
  out.print(htmpl.text());
%>

