<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  public static final String LAYOUT="macchina/layout/nuovaImmatricolazioneConferma.htm";
%>
<%
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

  MovimentiTargaVO movo = (MovimentiTargaVO)request.getAttribute("movo");
  TargaVO tvo = movo.getDatiTarga();

  htmpl.set("descMovimentazione", movo.getDescMovimentazione());
  htmpl.set("descrizioneTipoTarga", tvo.getDescrizioneTipoTarga());
  htmpl.set("dataInizioValidita", movo.getDataInizioValidita());
  htmpl.set("numeroTarga", tvo.getNumeroTarga());
  htmpl.set("siglaProvincia", tvo.getSiglaProvincia());

  if(tvo.isLastTarga()!=null && tvo.isLastTarga().booleanValue())
    htmpl.newBlock("blkUltimaTarga");

  out.print(htmpl.text());
%>
