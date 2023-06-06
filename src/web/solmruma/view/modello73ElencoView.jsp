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
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%!

  public static final String LAYOUT="layout/modello73Elenco.htm";

%>

<%

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  if (request.getAttribute("errors") != null) {

    HtmplUtil.setErrors(htmpl,(ValidationErrors) request.getAttribute("errors") , request);

  } else {

    if (request.getParameter("confermaStampa") == null) {

      htmpl.set("tipoTarga",request.getParameter("descrizioneTipoTarga"));

      htmpl.set("targaDa",request.getParameter("targaDa"));

      htmpl.set("targaA",request.getParameter("targaA"));

      htmpl.set("dicitura",request.getParameter("dicitura"));

      Vector elencoMacchine = (Vector)request.getAttribute("elencoMacchine");

      if (elencoMacchine.size()>0)

      {

        htmpl.newBlock("blkTabellaTarghe");

        Iterator i = elencoMacchine.iterator();

        String[] macchina;

        while (i.hasNext())

        {

          macchina = (String[])i.next();

          htmpl.newBlock("blkTabellaTarghe.blkRigaTarghe");

          htmpl.set("blkTabellaTarghe.blkRigaTarghe.idNumeroTarga",macchina[0]);

          htmpl.set("blkTabellaTarghe.blkRigaTarghe.numeroTarga",macchina[1]);

          htmpl.set("blkTabellaTarghe.blkRigaTarghe.provincia",macchina[2]);

          htmpl.set("blkTabellaTarghe.blkRigaTarghe.dittaUma",macchina[3]);

          htmpl.set("blkTabellaTarghe.blkRigaTarghe.denominazione",macchina[4]);

        }

      } else {

        htmpl.newBlock("blkNoTarghe");

      }

    }

  }

  HtmplUtil.setValues(htmpl, request, (String) session.getAttribute("pathToFollow"));

  response.setContentType("text/html");

  out.println(htmpl.text());

%>