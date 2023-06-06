<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>

<%

  String layout = "/ditta/layout/confermaEliminaLavConsorzi.htm";
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layout);
  SolmrLogger.info(this, "Found layout: "+layout);

%><%@include file = "/include/menu.inc" %><%
   htmpl.set("pageFrom",request.getParameter("pageFrom"));
  SolmrLogger.debug(this,"\n\n\n\n\n####################");
  SolmrLogger.debug(this,"request.getParameter(\"checkbox\"): "+request.getParameter("checkbox"));
  Long[] idLavConsorzi= (Long[])session.getAttribute("vLavConsorzi");
  SolmrLogger.debug(this,"\n\n\n\n\n####################idLavConsorzi.length: "+idLavConsorzi.length);
  SolmrLogger.debug(this,"\n\n\n\n\n####################idLavConsorzi: "+idLavConsorzi);

  //this.errErrorValExc(htmpl, request, exception);
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

%>
<%= htmpl.text()%>