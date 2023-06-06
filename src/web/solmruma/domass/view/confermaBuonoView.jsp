<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%
  SolmrLogger.debug(this,"- confermaBuonoView.jsp -  INIZIO PAGINA");
  java.io.InputStream layout = application.getResourceAsStream("/domass/layout/confermaBuono.htm");
  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
  htmpl.set("idBuono", ((Long)request.getAttribute("idBuono")).toString());
  htmpl.set("idDomAss", ((Long)request.getAttribute("idDomAss")).toString());
  htmpl.set("azione", (String)request.getAttribute("azione"));
  SolmrLogger.debug(this,"- confermaBuonoView.jsp -  FINE PAGINA");
%>
<%= htmpl.text()%>