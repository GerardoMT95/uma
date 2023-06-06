<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>

<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.Vector" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!

  public static final String LAYOUT="macchina/layout/Modello49.htm";

%>

<%

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  HtmplUtil.setValues(htmpl, request, (String) session.getAttribute("pathToFollow"));

  htmpl.set("annoModello", (String) request.getAttribute("annoModello"));

  htmpl.set("numeroModello", (String) request.getAttribute("numeroModello"));

  htmpl.set("dataProtocollo", (String) request.getAttribute("dataProtocollo"));

  htmpl.set("numeroProtocollo", (String) request.getAttribute("numeroProtocollo"));

  if (request.getAttribute("errors") != null) {

    HtmplUtil.setErrors(htmpl,(ValidationErrors) request.getAttribute("errors") , request);

  } else {

    if (request.getParameter("conferma") != null) {

      htmpl.set("scriptModello49", "stampaModello49A()");

    }

  }

  response.setContentType("text/html");

  out.println(htmpl.text());

%>