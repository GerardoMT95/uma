<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
  SolmrLogger.info(this, " - importaDatiView.jsp - INIZIO PAGINA");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/anag/layout/importaDati.htm");
  %><%@include file = "/include/menu.inc" %><%
  Hashtable common = (Hashtable)session.getAttribute("common");
  String risCreazione = (String) common.get("risCreazione");
  SolmrLogger.debug(this, "risCreazione: " + risCreazione);

  htmpl.newBlock("blkErrore");
  String msgCreazione = (String) common.get("msgCreazione");
  SolmrLogger.debug(this, "msgCreazione: " + msgCreazione);
  htmpl.newBlock("blkErrore");
  htmpl.set("blkErrore.msg", msgCreazione);

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  HtmplUtil.setErrors(htmpl, errors, request);

  SolmrLogger.info(this, " - importaDatiView.jsp - FINE PAGINA");
%>
<%= htmpl.text()%>