
<%@ page language="java"
    contentType="text/html"
    isErrorPage="false"
%>
<%@ page import="it.csi.jsf.htmpl.*" %>

<%@ page import="it.csi.solmr.etc.SolmrConstants" %>
<%@page import="it.csi.solmr.util.*"%>
<%!
  public static final String LAYOUT = "layout/monitoraggioswhttp.htm";
%>

<%
  SolmrLogger.info(this, "monitoraggioswhttpView.jsp - Begin");

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%>
<%@include file = "/include/menu.inc" %>
<%  
  String resultMonitoraggio = (String) request.getAttribute("resultMonitoraggio");
  String strMonitoraggio = "";
  if(resultMonitoraggio.equalsIgnoreCase(SolmrConstants.MONITORAGGIO_OK)){
    strMonitoraggio = SolmrConstants.MONITORAGGIO_MSG_OK;
  }
  else{
    strMonitoraggio = SolmrConstants.MONITORAGGIO_MSG_KO+
    " " + SolmrConstants.MONITORAGGIO_MSG_KO_DB;
  }
  htmpl.set("strMonitoraggio", strMonitoraggio);

  SolmrLogger.info(this, "monitoraggioswhttpView.jsp - End");
%>
<%= htmpl.text() %>