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

  SolmrLogger.debug(this,"\n\n\n confermaImportaLavContoTerziView - Begin");

  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/ditta/layout/confermaImportaLavContoTerzi.htm");
%><%@include file = "/include/menu.inc" %><%

  htmpl.set("pageFrom",request.getParameter("pageFrom"));
  SolmrLogger.debug(this,"\n\n\n\n\n####################");
  SolmrLogger.debug(this,"request.getParameter(\"radiobutton\"): "+request.getParameter("radiobutton"));
  htmpl.set("idSerra",request.getParameter("radiobutton"));

  //this.errErrorValExc(htmpl, request, exception);
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

%>
<%= htmpl.text()%>
