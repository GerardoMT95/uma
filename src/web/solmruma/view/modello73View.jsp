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
  public static final String LAYOUT="layout/modello73.htm";
%>
<%
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  if (request.getAttribute("errors") != null) {
    HtmplUtil.setErrors(htmpl,(ValidationErrors) request.getAttribute("errors") , request);
  }

  String descrizioneTipoTarga = request.getParameter("descrizioneTipoTarga");
  htmpl.set("descrizioneTipoTarga",(descrizioneTipoTarga==null?"":descrizioneTipoTarga));
  UmaFacadeClient umaClient = new UmaFacadeClient();

  //==============================================================
  // Gestione annullamento stampa
  //==============================================================
  String strPagina = "";
  StringTokenizer st = new StringTokenizer(request.getHeader("Referer"),"/",false);
  while (st.hasMoreTokens()) { strPagina = st.nextToken(); }
  if ((session.getAttribute("paginaAnnulla") == null) || ("".equals((String) session.getAttribute("paginaAnnulla")))) {
    session.setAttribute("paginaAnnulla", strPagina);
  } else {
    strPagina = (String) session.getAttribute("paginaAnnulla");
  }
  htmpl.set("paginaAnnulla", strPagina);
  //==============================================================

  Vector tipiTarga = umaClient.getTipiTarga();
  Iterator i = tipiTarga.iterator();
  CodeDescr tipoTarga;
  while (i.hasNext())
  {
    tipoTarga = (CodeDescr)i.next();
    if (tipoTarga.getCode().intValue()!=1)
    {
      htmpl.newBlock("blkTipoTarga");
      htmpl.set("blkTipoTarga.idTipoTarga",tipoTarga.getCode().toString());
      htmpl.set("blkTipoTarga.descrizioneTipoTarga","Targa "+tipoTarga.getDescription());
    }
  }

  HtmplUtil.setValues(htmpl, request, (String) session.getAttribute("pathToFollow"));
  response.setContentType("text/html");
  out.println(htmpl.text());
%>