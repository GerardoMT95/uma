<%!
  private static final String VIEW="/view/indexView.jsp";
  private static final String ELENCO_DITTE="../anag/layout/elencoAziendeRapLegaleswhttp.htm";
  private static final String DETTAGLIO="../anag/layout/dettaglioAziendaswhttp.htm";
%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String iridePageName = "indexCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  if (ruoloUtenza.isUtenteLegaleRappresentante() || ruoloUtenza.isUtenteTitolareCf()
  || ruoloUtenza.isUtenteNonIscrittoCIIA() || ruoloUtenza.isUtenteAziendaAgricola())
  {
    // Legale rappresentante o titolare CF ==> Mando sull'elenco delle ditte di
    // cui sono rappresentanti
    response.sendRedirect(ELENCO_DITTE);
    return;
  }
  // In tutti gli altri casi visualizzo la home page
%><jsp:forward page="<%=VIEW%>" />