<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@page import="it.csi.jsf.htmpl.Htmpl"%>
<%@page import="it.csi.jsf.htmpl.HtmplFactory"%>
<%@page import="it.csi.solmr.util.DateUtils"%>
<%@page import="it.csi.solmr.util.HtmplUtil"%>
<%@page import="it.csi.solmr.util.ValidationErrors"%>
<%@page import="it.csi.solmr.util.SolmrLogger"%>

<%
  //SolmrLogger.debug(this,"verificaAssegnazioneTrasmessaView.jsp -  INIZIO PAGINA");
//  Long idDittaUma=(Long)session.getAttribute("idDittaUma");
 // ValidationErrors errors = new ValidationErrors();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/domass/layout/verificaAssegnazioneTrasmessa.htm");
%><%@include file = "/include/menu.inc" %>
<% 
  htmpl.set("annoCorrente",""+DateUtils.getCurrentYear());
  it.csi.solmr.dto.uma.DomandaAssegnazione dA = (it.csi.solmr.dto.uma.DomandaAssegnazione)request.getAttribute("domandaAssegnazione");
  htmpl.set("dataRiferimento",DateUtils.formatDate(dA.getDataRiferimento()));
  htmpl.set("idDomAss",(String)request.getParameter("idDomandaassegnazione"));
  SolmrLogger.debug(this,"verificaAssegnazioneTrasmessaView.jsp -  FINE PAGINA");
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
  
  out.print(htmpl.text());
%>