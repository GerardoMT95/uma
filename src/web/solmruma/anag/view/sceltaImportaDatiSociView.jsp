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
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%!
  
  public static final String LAYOUT_SCELTA = "/anag/layout/sceltaImportaDatiSoci.htm";
%>

<%
  SolmrLogger.debug(this, "    BEGIN sceltaImportaDatiSociView.jsp");
 
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  
  // Visualizzare la pagina di scelta
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT_SCELTA);  
%><%@include file = "/include/menu.inc" %><%
 
  SolmrLogger.debug(this, "  END sceltaImportaDatiSociView.jsp");
%>
<%= htmpl.text()%>
