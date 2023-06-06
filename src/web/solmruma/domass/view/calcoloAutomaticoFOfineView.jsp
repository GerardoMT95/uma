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
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();



  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("domass/layout/calcoloAutomaticoFine.htm");
%><%@include file = "/include/menu.inc" %><%

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

  htmpl.set("action","../layout/verificaAssegnazione.htm");

  htmpl.set("idDittaUma",idDittaUma==null?null:idDittaUma.toString());

  htmpl.set("idDomAss",request.getParameter("idDomAss"));

  htmpl.set("anno",""+DateUtils.getCurrentYear());

  out.print(htmpl.text());

%>

