<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%
  Htmpl htmpl = HtmplFactory.getInstance(application)
                .getHtmpl("domass/layout/confermaTrasmissioneAcconto.htm");
%><%@include file = "/include/menu.inc" %><%  
  out.print(htmpl.text());
%>