<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="it.csi.solmr.business.uma.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>

<jsp:useBean id="serraVO" scope="page" class="it.csi.solmr.dto.uma.SerraVO">
  <jsp:setProperty name="serraVO" property="*" />
</jsp:useBean>

<%
java.io.InputStream layout = application.getResourceAsStream("/uma/gestioni/layout/elencoSerrePOP.htm");
SolmrLogger.info(this, "Found layout: "+layout);
Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%

Vector elencoSerre = (Vector)request.getAttribute("elencoSerre");

this.errErrorValExc(htmpl, request, exception);
%>
<%= htmpl.text()%>
<%!
  private void errErrorValExc(Htmpl htmpl, HttpServletRequest request, Throwable exc)
  {
    SolmrLogger.debug(this,"\n\n\n\n *********************************** 2");
    SolmrLogger.debug(this,"errErrorValExc()");

    if (exc instanceof it.csi.solmr.exception.ValidationException){

      ValidationErrors valErrs = new ValidationErrors();
      valErrs.add("error", new ValidationError(exc.getMessage()) );

      HtmplUtil.setErrors(htmpl, valErrs, request);
    }
  }
%>
