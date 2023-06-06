  <%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%
  java.io.InputStream layout = application.getResourceAsStream("/ditta/layout/nuovaDittaUmaConfermaInserimento.htm");
  Htmpl htmpl = new Htmpl(layout);
  if (request.getAttribute("__autorizzazione")==null)
  {
    request.setAttribute("__iridePageName","nuovaDittaUmaConfermaInserimentoCtrl.jsp");
  }
%><%@include file = "/include/menu.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  htmpl.set("nomeCognomeUtente",ruoloUtenza.getDenominazione());

  AnagAziendaVO anagAziendaVO = (AnagAziendaVO)session.getAttribute("anagAziendaVO");
  DittaUMAVO dittaUmaVO = (DittaUMAVO)session.getAttribute("dittaUmaVO");

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  if(errors != null) {
    HtmplUtil.setErrors(htmpl, errors, request);
    HtmplUtil.setValues(htmpl, request);
  }
  else {
    htmpl.set("tipiConduzione",dittaUmaVO.getTipiConduzione());
    HtmplUtil.setValues(htmpl, anagAziendaVO);
    HtmplUtil.setValues(htmpl, dittaUmaVO);
  }


%>
<%= htmpl.text()%>


