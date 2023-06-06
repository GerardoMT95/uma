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
  SolmrLogger.debug(this, "    BEGIN confermaEliminaLavContoProprioView");
  
  String layout = "/ditta/layout/confermaEliminaLavContoProprio.htm";
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layout);
  SolmrLogger.info(this, "Found layout: "+layout);

%><%@include file = "/include/menu.inc" %><%
  
  htmpl.set("pageFrom",request.getParameter("pageFrom"));    
 
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
  
  SolmrLogger.debug(this, "    END confermaEliminaLavContoProprioView");

%>
<%= htmpl.text()%>