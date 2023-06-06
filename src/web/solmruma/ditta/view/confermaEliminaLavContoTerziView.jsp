<%@page import="it.csi.solmr.dto.uma.MacchinaVO"%>
<%@page import="it.csi.solmr.dto.profile.RuoloUtenza"%>
<%@page import="it.csi.solmr.client.uma.UmaFacadeClient"%>
<%@page import="it.csi.solmr.dto.uma.LavContoTerziVO"%>
<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>

<%

  String layout = "/ditta/layout/confermaEliminaLavContoTerzi.htm";
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layout);
  SolmrLogger.info(this, "Found layout: "+layout);

%><%@include file = "/include/menu.inc" %><%
   htmpl.set("pageFrom",request.getParameter("pageFrom"));
  SolmrLogger.debug(this,"\n\n\n\n\n####################");
  SolmrLogger.debug(this,"request.getParameter(\"checkbox\"): "+request.getParameter("checkbox"));
  Long[] idLavContoTerzi= (Long[])session.getAttribute("vLavContoTerzi");
  SolmrLogger.debug(this,"\n\n\n\n\n####################idLavContoTerzi.length: "+idLavContoTerzi.length);
  SolmrLogger.debug(this,"\n\n\n\n\n####################idLavContoTerzi: "+idLavContoTerzi);

  //this.errErrorValExc(htmpl, request, exception);
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

%>
<%= htmpl.text()%>