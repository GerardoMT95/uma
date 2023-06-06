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
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%!

  public static final String LAYOUT="layout/stampaElenchi.htm";

%>

<%

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  session.removeAttribute("paginaAnnulla");


  if (session.getAttribute("erroreUtente")!=null) {

    ValidationErrors vError = new ValidationErrors();

    vError.add("error", new ValidationError((String) session.getAttribute("erroreUtente")));

    HtmplUtil.setErrors(htmpl, vError, request);

    session.removeAttribute("erroreUtente");

  }



  session.removeAttribute("dittaUMAAziendaVO");

  response.setContentType("text/html");

  out.println(htmpl.text());

%>