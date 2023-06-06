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
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String iridePageName = "modificaUtilizzoCtrl.jsp";%>
  
  <%


 SolmrLogger.debug(this, "   BEGIN modificaUtilizzoCtrl");
 
 
 // ----------- inizio CONTROLLI DI ABILITAZIONE AL CU -----------
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
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  if (!autorizzazione.isUtenteAbilitato(iride2AbilitazioniVO,ruoloUtenza.isReadWrite()))
  {
    it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::isUtenteAbilitato] utente non abilitato");
    request.setAttribute("errorMessage",it.csi.solmr.etc.uma.UmaErrors.ERRORE_ABILITAZIONE_NO_ABILITAZIONE);
    %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
    return;
  }
  String errorMessage=hasCompetenzaDatoModificaUtilizzo(request,response, ruoloUtenza, new it.csi.solmr.client.uma.UmaFacadeClient(),autorizzazione);
  if (errorMessage!=null)
  {
    it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::errorMessage!=null] utente non abilitato");
    request.setAttribute("errorMessage",errorMessage);
    %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
    return;
  }
  // ----------- fine CONTROLLI DI ABILITAZIONE AL CU -----------

  UmaFacadeClient umaClient = new UmaFacadeClient();
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  ValidationErrors errors = new ValidationErrors();

  
  AnagFacadeClient anagClient = new AnagFacadeClient();
  String viewUrl="/macchina/view/modificaUtilizzoView.jsp";
  String annullaUrl="/macchina/layout/dettaglioMacchinaDittaUtilizzo.htm";
  String salvaUrl="/macchina/layout/dettaglioMacchinaDittaUtilizzo.htm";
  String errorCtrl = "/ctrl/dettaglioMacchinaDittaUtilizzoCtrl.jsp";
  String errorPage = "/macchina/view/modificaUtilizzoView.jsp";
  String url = "";

  if(request.getParameter("salva")!=null)
  {
    MacchinaVO mVO = (MacchinaVO)session.getAttribute("modificaMacchinaVO");
	  if (mVO!=null && umaClient.isBloccoMacchinaImportataAnagrafe(mVO)) 
	  {  
	    it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::errorMessage!=null] utente non abilitato: "+it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
	    request.setAttribute("errorMessage",it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
	    %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
	    return;
	  }
  
  
    SolmrLogger.debug(this, "--- CASO salva");
    url = salvaUrl;
    PossessoVO pVO = null;
    
    if(mVO.getUtilizzoVO()!=null)
      pVO = mVO.getUtilizzoVO().getLastPossessoVO();
    
    // --------------- SETTO I CAMPI da salvare sul db -----------------------------
    if(pVO!=null)
    {
      /* -- Setto la data scarico per poterla controllare al momento del salvataggio dati sul db 
           (se è valorizzata non si deve fare l'aggiornamento su DB_POSSESSO)
      */     
      if(mVO.getUtilizzoVO() != null)
      {
        SolmrLogger.debug(this, "-- *** dataScarico *** -- ="+mVO.getUtilizzoVO().getDataScaricoDate());
        pVO.setDataScarico(mVO.getUtilizzoVO().getDataScaricoDate());
      }   
          
      // Se idFormaPossesso è modificabile (data scarico non valorizzata) -> setto i valori inseriti dall'utente
      if(mVO.getUtilizzoVO() != null && mVO.getUtilizzoVO().getDataScaricoDate() == null)
      {
         SolmrLogger.debug(this, "--- la forma di possesso è MODIFICABILE");        
         pVO.setIdFormaPossesso(request.getParameter("idFormaPossesso"));
         pVO.setDataScadenzaLeasing(request.getParameter("dataScadenzaLeasing"));
         pVO.setExtIdAzienda(request.getParameter("idSocietaLeasing"));
          
        
         // Se FormaPossesso = 'Leasing' -> è anche stata indicata l'idSocietà Leasing 
         if(!request.getParameter("idSocietaLeasing").equals(""))
         {
           SolmrLogger.debug(this, "-- ricerca ditta Leasing");
           Long idAziendaLong = new Long(mVO.getUtilizzoVO().getLastPossessoVO().getExtIdAzienda());
           AnagAziendaVO aaVO = anagClient.findAziendaAttiva(idAziendaLong);
           String rappLegale = anagClient.getRappLegaleTitolareByIdAzienda(idAziendaLong);
           aaVO.setRappresentanteLegale(rappLegale);
           request.setAttribute("dittaLeasing", aaVO);
        }
      }  
      // Se idFormaPossesso NON è modificabile (data scarico valorizzata) -> setto i valori del db
      else if(mVO.getUtilizzoVO() != null && mVO.getUtilizzoVO().getDataScaricoDate() != null)
      {
        SolmrLogger.debug(this, "--- la forma di possesso NON è MODIFICABILE");      
        pVO.setIdFormaPossesso(mVO.getUtilizzoVO().getLastPossessoVO().getIdFormaPossesso());
        pVO.setDataScadenzaLeasing(mVO.getUtilizzoVO().getLastPossessoVO().getDataScadenzaLeasing());
        pVO.setExtIdAzienda(mVO.getUtilizzoVO().getLastPossessoVO().getExtIdAzienda());
        
        // Se FormaPossesso = 'Leasing' -> settto i valori dell'idSocietà Leasing del db
        if(pVO.getExtIdAzienda() != null && !pVO.getExtIdAzienda().trim().equals(""))
        {
          SolmrLogger.debug(this, "-- ricerca ditta Leasing");
          AnagAziendaVO aaVO = anagClient.findAziendaAttiva(new Long(pVO.getExtIdAzienda()));
          String rappLegale = anagClient.getRappLegaleTitolareByIdAzienda(new Long(pVO.getExtIdAzienda()));
          aaVO.setRappresentanteLegale(rappLegale);
          request.setAttribute("dittaLeasing", aaVO);
        } 
         
      }
      SolmrLogger.debug(this, " --- idFormaPossesso ="+pVO.getIdFormaPossessoLong());
      SolmrLogger.debug(this, " --- dataScadenza ="+pVO.getDataScadenzaLeasing());
      SolmrLogger.debug(this, " --- extIdAzienda ="+pVO.getExtIdAzienda());
           
      // Setto dataScadenza con il valore del db (campo non modificabile)      
      if(mVO.getUtilizzoVO() != null)
        pVO.setDataScarico(mVO.getUtilizzoVO().getDataScaricoDate());
      SolmrLogger.debug(this, " --- dataScarico ="+pVO.getDataScarico());  

      // -- Se data scarico è valorizzata -> memorizzo 'Motivo scarico' selezionato dall'utente
      if(mVO.getUtilizzoVO() != null && mVO.getUtilizzoVO().getDataScaricoDate() != null)
      {
        String idMotivoScarico = request.getParameter("idMotivoScarico");
        SolmrLogger.debug(this, "--- idMotivoScarico ="+idMotivoScarico);
        pVO.setIdMotivoScarico(idMotivoScarico);                
      }
      SolmrLogger.debug(this, " --- idMotivoScarico ="+pVO.getIdMotivoScarico());
      // ---------------
      
      
      
      SolmrLogger.debug(this, "--- Effettuo VALIDAZIONE DEI CAMPI");       
      errors = pVO.validateModificaUtilizzo();
            
      
      if (!(errors == null || errors.size() == 0)) {
         SolmrLogger.debug(this, "-- ci sono errori di validazione");
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(errorPage).forward(request, response);
        return;
      }
      
      try{
        SolmrLogger.debug(this, " ----- MODIFICA DATI utilizzo macchina SU DB  ----");
        umaClient.modificaUtilizzo(ruoloUtenza, pVO);
        session.removeAttribute("modificaMacchinaVO");
      }
      catch(SolmrException sex){
        SolmrLogger.error(this, "-- SolmrException durante modificaUtilizzo() ="+sex.getMessage());
        ValidationError error = new ValidationError(sex.getMessage());
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(errorCtrl).forward(request, response);
        return;
      }
    }
  }
  else if(request.getParameter("annulla")!=null){
    url = annullaUrl;
  }
  else{
    session.removeAttribute("modificaMacchinaVO");
    url = viewUrl;
    UtilizzoVO uVO = (UtilizzoVO)session.getAttribute("dittaUtilizzoVO");
    String idUtilizzoStr = null;
    if(uVO!=null)
      idUtilizzoStr = uVO.getIdUtilizzo();
    else
      idUtilizzoStr = request.getParameter("idUtilizzo");

    Long idUtilizzo = null;
    if(idUtilizzoStr!=null && !idUtilizzoStr.equals("")){
      idUtilizzo = new Long(idUtilizzoStr);
    }
    try{
      SolmrLogger.debug(this, " -- controlli per verificare se l'utilizzo della macchina e' modificabile");
      MacchinaVO mVO = umaClient.checkModificaUtilizzo(ruoloUtenza,idDittaUma, idUtilizzo);
      
      if (mVO!=null && umaClient.isBloccoMacchinaImportataAnagrafe(mVO)) 
		  {  
		    it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::errorMessage!=null] utente non abilitato: "+it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
		    request.setAttribute("errorMessage",it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
		    %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
		    return;
		  }
      
      session.setAttribute("modificaMacchinaVO", mVO);
      
      AnagAziendaVO aaVO = null;
      if(mVO.getUtilizzoVO()!=null &&
         mVO.getUtilizzoVO().getLastPossessoVO()!=null &&
         mVO.getUtilizzoVO().getLastPossessoVO().getExtIdAzienda()!=null &&
         !mVO.getUtilizzoVO().getLastPossessoVO().getExtIdAzienda().equals("")){
        Long idAziendaLong = new Long(mVO.getUtilizzoVO().getLastPossessoVO().getExtIdAzienda());
        aaVO = anagClient.findAziendaAttiva(idAziendaLong);
        String rappLegale = anagClient.getRappLegaleTitolareByIdAzienda(idAziendaLong);
        aaVO.setRappresentanteLegale(rappLegale);
        request.setAttribute("dittaLeasing", aaVO);
      }
    }
    catch(SolmrException sex){
      SolmrLogger.debug(this,sex.getMessage());
      ValidationError error = new ValidationError(sex.getMessage());
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(errorCtrl).forward(request, response);
      return;
    }
  }

 %><jsp:forward page="<%=url%>" /><%
%>
<%!
  // Attenzione : 'modifica utilizzo' NON deve controllare se la ditta è cessata
  public String hasCompetenzaDatoModificaUtilizzo(HttpServletRequest request,
          HttpServletResponse response,
          RuoloUtenza ruoloUtenza,
          UmaFacadeClient umaFacadeClient,it.csi.solmr.presentation.security.Autorizzazione autorizzazione){
  DittaUMAAziendaVO dittaUmaAziendaVO = (DittaUMAAziendaVO) request.getSession().getAttribute("dittaUMAAziendaVO");

  try{
	SolmrLogger.debug(this, "   BEGIN hasCompetenzaDatoModificaUtilita");  
    umaFacadeClient.isDittaUmaBloccata(dittaUmaAziendaVO.getIdDittaUMA());    
  }
  catch (SolmrException ex)
  {
    // Ditta bloccata errore di sistema (vedi log per errroe di sistema)
	SolmrLogger.error(this, "-- SolmrException ="+ex.getMessage());
    return ex.getMessage();
  }
  finally{
	  SolmrLogger.debug(this, "   END hasCompetenzaDatoModificaUtilita");
  }
  // Validazioni standard per l'utente
  return autorizzazione.validateGenericUser(ruoloUtenza, dittaUmaAziendaVO,umaFacadeClient, request);
 }
%>