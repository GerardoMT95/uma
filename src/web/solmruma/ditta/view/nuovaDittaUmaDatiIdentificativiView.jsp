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
<%@ page import="it.csi.papua.papuaserv.presentation.ws.profilazione.axis.UtenteAbilitazioni" %>


<%
  java.io.InputStream layout = application.getResourceAsStream("/ditta/layout/nuovaDittaUmaDatiIdentificativi.htm");
  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  UtenteAbilitazioni utenteAbilitazioni = (UtenteAbilitazioni) session.getAttribute("utenteAbilitazioni");

  htmpl.set("nomeCognomeUtente", ruoloUtenza.getDenominazione());

  AnagAziendaVO anagAziendaVO = (AnagAziendaVO)session.getAttribute("anagAziendaVO");

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  UmaFacadeClient umaClient = new UmaFacadeClient();
  //SolmrLogger.debug(this,"Valore vettore: "+umaClient.getSiglaProvinceTOBECONFIGsi().size());

  if(ruoloUtenza.isUtenteProvinciale()) {
    htmpl.newBlock("labelProvincia");
    htmpl.set("labelProvincia.ente",utenteAbilitazioni.getEnteAppartenenza().getAmmCompetenza().getDenominazioneEnte());
    htmpl.set("divHidden","style='display:none'");
  }
  else {
    htmpl.newBlock("blkCombo");
  }

  if(errors != null) {
    HtmplUtil.setErrors(htmpl, errors, request);
    HtmplUtil.setValues(htmpl, request);
    HtmplUtil.setValues(htmpl, anagAziendaVO);
  }
  else {
    htmpl.set("descComune","");
    htmpl.set("dataIscrizione",DateUtils.formatDate(new Date(System.currentTimeMillis())));
    HtmplUtil.setValues(htmpl, anagAziendaVO);
  }


%>
<%= htmpl.text()%>


