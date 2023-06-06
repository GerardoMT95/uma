
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
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%!
  private static final String NEXT_PAGE="../layout/verificaAssegnazioneTrasmessa.htm";
  private static final String PREV_PAGE="../layout/verificaAssegnazioneSalvata.htm";
%>
<jsp:useBean id="frmVerificaAssegnazioneVO" scope="request"
 class="it.csi.solmr.dto.uma.FrmVerificaAssegnazioneVO">
  <jsp:setProperty name="frmVerificaAssegnazioneVO" property="*" />
</jsp:useBean>
<%
  Htmpl htmpl = HtmplFactory.getInstance(application)
                .getHtmpl("domass/layout/confermaTrasmissioneDomanda.htm");
%><%@include file = "/include/menu.inc" %>
<%  
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  UmaFacadeClient client = new UmaFacadeClient();
  htmpl.set("idDomandaassegnazione",request.getParameter("idDomandaassegnazione"));
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
  out.print(htmpl.text());
%>

