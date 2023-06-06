<%
{
  request.setAttribute("iridePageName",iridePageName);
  java.util.HashMap iride2mappings=(java.util.HashMap)application.getAttribute("iride2mappings");
  it.csi.solmr.presentation.security.Autorizzazione autorizzazione=
  (it.csi.solmr.presentation.security.Autorizzazione) iride2mappings.get(iridePageName);
  if (autorizzazione==null)
  {
    it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service] Autorizzazione è null");
    request.setAttribute("errorMessage",it.csi.solmr.etc.uma.UmaErrors.ERRORE_ABILITAZIONE_NO_ABILITAZIONE);
    %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
    return;
  }
  request.setAttribute("__autorizzazione",autorizzazione);
  it.csi.solmr.dto.iride2.Iride2AbilitazioniVO iride2AbilitazioniVO =
  (it.csi.solmr.dto.iride2.Iride2AbilitazioniVO) session.getAttribute("iride2AbilitazioniVO");
  it.csi.solmr.dto.profile.RuoloUtenza ruoloUtenzaAut =(it.csi.solmr.dto.profile.RuoloUtenza)session.getAttribute("ruoloUtenza");
  if (!autorizzazione.isUtenteAbilitato(iride2AbilitazioniVO, ruoloUtenzaAut.isReadWrite()))
  {
    it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::isUtenteAbilitato] utente non abilitato");
    request.setAttribute("errorMessage",it.csi.solmr.etc.uma.UmaErrors.ERRORE_ABILITAZIONE_NO_ABILITAZIONE);
    %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
    return;
  }
  String errorMessage=autorizzazione.hasCompetenzaDato(request,response, ruoloUtenzaAut, new it.csi.solmr.client.uma.UmaFacadeClient());
  if (errorMessage!=null)
  {
    it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::errorMessage!=null] errorMessage ="+errorMessage);
    request.setAttribute("errorMessage",errorMessage);
    %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
    return;
  }
}
%>