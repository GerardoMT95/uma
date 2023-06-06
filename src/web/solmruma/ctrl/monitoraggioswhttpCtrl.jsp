<%@ page language="java"
    contentType="text/html"
    isErrorPage="false"
%>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.etc.SolmrConstants" %>
<%@page import="it.csi.solmr.client.uma.UmaFacadeClient"%>
<%@ page import="java.util.Date" %>
<%!
  private static final String VIEW="/view/monitoraggioswhttpView.jsp";

%>
<%
String iridePageName = "monitoraggioswhttpCtrl.jsp";
%>
<%@include file = "/include/autorizzazione.inc" %>
<%
  SolmrLogger.info(this, "monitoraggioswhttpCtrl.jsp - Begin");

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  String resultMonitoraggio = SolmrConstants.MONITORAGGIO_OK;
  try{
    Date dataCorrente = umaFacadeClient.getSysdate();
  }
  catch(Exception ex){
    resultMonitoraggio = SolmrConstants.MONITORAGGIO_KO;  
  }
  request.setAttribute("resultMonitoraggio", resultMonitoraggio);
  
  SolmrLogger.info(this, "monitoraggioswhttpCtrl.jsp - End");
%>

<jsp:forward page="<%=VIEW%>"/>