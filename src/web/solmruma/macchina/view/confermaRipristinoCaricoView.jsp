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
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>

<%
  SolmrLogger.debug(this,"confermaRipristinoCaricoView.jsp - Begin");

  Htmpl htmpl = HtmplFactory.getInstance(application)
                .getHtmpl("macchina/layout/confermaRipristinoCarico.htm");
%><%@include file = "/include/menu.inc" %><%
  ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");
  SolmrLogger.debug(this,"errors="+errors);
  HtmplUtil.setErrors(htmpl,errors,request);

  out.print(htmpl.text());
%>
