  <%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%

  java.io.InputStream layout = application.getResourceAsStream("/layout/dati_sistema.htm");

  Htmpl htmpl = new Htmpl(layout);

  it.csi.solmr.util.SolmrLogger.debug(this, "__iridePageName: "+request.getAttribute("iridePageName"));
%><%@include file = "/include/menu.inc" %><%

  session.removeAttribute("dittaUMAAziendaVO");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

%>

<%= htmpl.text() %>

