<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
  SolmrLogger.debug(this, " BEGIN importaDatiFineView.jsp");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/anag/layout/importaDati.htm");
%><%@include file = "/include/menu.inc" %><%
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  Hashtable common = (Hashtable)session.getAttribute("common");

  String risCreazione = (String) common.get("risCreazione");
  SolmrLogger.debug(this, "\n\n\n\n#####################");
  SolmrLogger.debug(this, "risCreazione: " + risCreazione);

  if (risCreazione.equals((String) SolmrConstants.RISULTATO_PL_IMPORTA_DATI_NESSUN_ERRORE))
  {
    SolmrLogger.debug(this, "if (!risCreazione.equals((String) SolmrConstants.RISULTATO_PL_IMPORTA_DATI_NESSUN_ERRORE))");
    htmpl.newBlock("blkNoErrore");
  }
  else
  {
    SolmrLogger.debug(this, "else (!risCreazione.equals((String) SolmrConstants.RISULTATO_PL_IMPORTA_DATI_NESSUN_ERRORE))");
    htmpl.newBlock("blkErrore");

    String msgCreazione = (String) common.get("msgCreazione");
    SolmrLogger.debug(this, "-- msgCreazione: " + msgCreazione);
    htmpl.set("blkErrore.msg", msgCreazione,null);
  }

  HtmplUtil.setErrors(htmpl, errors, request);

  SolmrLogger.debug(this, "  END importaDatiFineView.jsp");
%>
<%= htmpl.text()%>