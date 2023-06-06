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
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%!
  private static final String VIEW="/macchina/view/macchinaUsataConfermaView.jsp";
  private static final String NUOVO_ATTESTATO_PROPRIETA="../layout/dettaglioMacchinaDittaNuovaAttestazione.htm";
%>
<%

  String iridePageName = "macchinaUsataConfermaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  if(request.getParameter("nuovaAttestazione")!=null){
    %><jsp:forward page="<%=NUOVO_ATTESTATO_PROPRIETA%>"/><%
  }

  DittaUMAVO dittaUmaVO=(DittaUMAVO)session.getAttribute("dittaUmaVO");
  UmaFacadeClient umaClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  SolmrLogger.debug(this,"");
%>
<jsp:forward page="<%=VIEW%>"/>
<%!
  private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException("Errore: eccezione="+msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }
%>

