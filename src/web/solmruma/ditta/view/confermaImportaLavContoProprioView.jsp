<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>


<%

  SolmrLogger.debug(this,"  BEGIN confermaImportaLavContoProprioView");

  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/ditta/layout/confermaImportaLavContoProprio.htm");
%><%@include file = "/include/menu.inc" %><%

  htmpl.set("pageFrom",request.getParameter("pageFrom"));  
  //htmpl.set("idSerra",request.getParameter("radiobutton"));
  
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

%>
<%= htmpl.text()%>
