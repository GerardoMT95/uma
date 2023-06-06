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
<%@ page import="it.csi.solmr.dto.anag.*" %>

<%

  java.io.InputStream layout = application.getResourceAsStream("layout/confirmModResidenza.htm");
  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
  String form = (String)request.getAttribute("urlForm");
  htmpl.set("form", form);

  PersonaFisicaVO personaFisicaVO = (PersonaFisicaVO)session.getAttribute("personaVO");


%>

<%= htmpl.text()%>