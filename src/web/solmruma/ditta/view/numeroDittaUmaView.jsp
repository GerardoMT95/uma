  <%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>


<%

  UmaFacadeClient umaClient = new UmaFacadeClient();
  java.io.InputStream layout = application.getResourceAsStream("uma/ditta/layout/numeroDittaUma.htm");
  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
  AnagAziendaVO anagAziendaVO = (AnagAziendaVO)session.getAttribute("anagAziendaVO");

  DittaUMAVO dittaUma = (DittaUMAVO)session.getAttribute("dittaUma");
  session.removeAttribute("dittaUma");

  htmpl.set("denominazione",anagAziendaVO.getDenominazione());
  htmpl.set("cuaa",anagAziendaVO.getCUAA());
  htmpl.set("provinciaCompetenza",anagAziendaVO.getSedelegProv());
  htmpl.set("idAzienda",String.valueOf(anagAziendaVO.getIdAzienda()));

  htmpl.set("dittaUma",dittaUma.getDittaUMA());
  htmpl.set("tipoDitta",dittaUma.getTipoDitta());
  htmpl.set("provinciaDitta",dittaUma.getProvinciaComuneAttivita());

  String inserimento = (String)session.getAttribute("ins");
  session.removeAttribute("ins");
  htmpl.set("ins",inserimento);

 it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
%>
<%= htmpl.text()%>


