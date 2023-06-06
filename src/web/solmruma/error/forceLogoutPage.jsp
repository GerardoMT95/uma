<%@ page language="java" contentType="text/html" isErrorPage="true" %>

<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.papua.papuaserv.exception.messaggistica.LogoutException" %>
<%@ page import="it.csi.solmr.util.Validator" %>
<%@ page import="java.net.URL" %>
<%@ page import="it.csi.solmr.util.*" %>

<%

  SolmrLogger.debug(this,"   BEGIN forceLogoutPage.jsp");
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/layout/force_logout.htm");

  LogoutException e = (LogoutException)session.getAttribute("LogoutException");
  
  SolmrLogger.debug(this," -- session.invalidate()");
  session.invalidate();

  /**
   * Setta i messaggi di errore sul layout force_logout.htm
   */
  htmpl.set("titolo", "Forzatura logout");
  
  String msgErrore = "E' avvenuto il logout per il seguente motivo: " + e.getMessage();
  if (Validator.isNotEmpty(msgErrore)) {
    htmpl.set("messaggioErrore", msgErrore);
  }
  if (e.getTestoMessaggio()!=null) {
    htmpl.set("messaggioCompleto", e.getTestoMessaggio());
  }
  htmpl.set("pulsante", "esci");

  URL url = new URL(request.getRequestURL().toString());
  String s = "http://"+url.getHost()+":"+url.getPort()+"/";
  htmpl.set("hrefPulsante", s);
  
  
  SolmrLogger.debug(this,"   END forceLogoutPage.jsp");
%>

<%= htmpl.text() %>