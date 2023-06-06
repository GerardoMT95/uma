<%@page import="it.csi.solmr.dto.CodeDescr"%>
<%@page import="it.csi.solmr.dto.CodeDescriptionLong"%>
<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.filter.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="javax.servlet.http.HttpSession"%>


<%
	String iridePageName = "elencoLavContoProprioCtrl.jsp";
%>
  <%@include file = "/include/autorizzazione.inc" %>
<%
  
 SolmrLogger.debug(this, "   BEGIN elencoLavContoProprioCtrl");
  
  
  
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma = dittaUMAAziendaVO.getIdDittaUMA();
  SolmrLogger.debug(this," ---- idDittaUma "+idDittaUma);
  
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  UmaFacadeClient umaClient = new UmaFacadeClient();
  String view = "/ditta/view/elencoLavContoProprioView.jsp";
  String modificaUrl="/ditta/ctrl/modificaLavContoProprioCtrl.jsp";  
  String insertUrl="/ditta/ctrl/nuovaLavContoProprioCtrl.jsp";
  String deleteUrl="/ditta/ctrl/confermaEliminaLavContoProprioCtrl.jsp";  
  
  String operation = (String)request.getParameter("operation");
  request.setAttribute("operation", operation);
  SolmrLogger.debug(this, "----- operation ="+operation);
  
  // E' valorizzato nel caso in cui di arrivi da 'elimina', 'modifica', 'inserisci', 'importa'
  String paginaChiamante = (String)session.getAttribute("paginaChiamante");
  SolmrLogger.debug(this, "----- paginaChiamante ="+paginaChiamante);
  
  if(operation == null || operation.equals("")){  
    LavContoProprioFilter filter = new LavContoProprioFilter();
	// -------- CASO IN CUI SI STA ARRIVANDO DA 'ELIMINA', 'INSERISCI', 'MODIFICA' -----
	if(paginaChiamante != null && !paginaChiamante.equals("") && !paginaChiamante.equals("importa")){	  	  
		  SolmrLogger.debug(this, "----- CASO IN CUI SI STA ARRIVANDO DA 'ELIMINA', 'INSERISCI', 'MODIFICA'");	       
		  // recupero i filtri con i quali effettuare la ricerca Lavorazioni Conto Proprio
		  filter = (LavContoProprioFilter)session.getAttribute("filterRicercaLavContoProprio");    
		  
		  // ricaricare i valori della combo 'Assegnazione carburante'	
		  SolmrLogger.debug(this, "---- Ricaricamento combo 'Assegnazione carburante'");
		  getDatiPerComboAssegnazCarburante(session, umaClient, idDittaUma, filter.getAnnoDiRiferimento());
		  // ripulisco la sessione
	      session.removeAttribute("paginaChiamante");	
	}      	      
    // ----- CASO DI PRIMO CARICAMENTO DELLA PAGINA o dopo aver effettuato 'IMPORTA' (Precaricamento lavorazioni)
    // Se sono al primo caricamento della pagina, effettuo la ricerca con 'Anno di riferimento' = anno attuale e no variazioni storiche
    else{
	    SolmrLogger.debug(this, "----- CASO DI PRIMO CARICAMENTO DELLA PAGINA o CARICAMENTO DOPO IMPORTA");
		// rimuovo gli eventuali dati memorizzati in sessione precedentemente per questa pagina 
		removeValSession(session);
		session.removeAttribute("paginaChiamante");
		
		GregorianCalendar gc = new GregorianCalendar();    
		int annoCorrente = gc.get(gc.YEAR);
		String annoRiferimento = new Integer(annoCorrente).toString();
		SolmrLogger.debug(this, "- annoRiferimento ="+annoRiferimento);
		boolean variazioniStoriche = false;
		SolmrLogger.debug(this, "- variazioniStoriche ="+variazioniStoriche);	    
		filter.setAnnoDiRiferimento(annoRiferimento);
		filter.setVariazioniStoriche(variazioniStoriche);
		filter.setIdDittaUma(idDittaUma);	
		
		// Popolamento combo 'Anno di riferimento'
		SolmrLogger.debug(this, "---- Popolamento combo 'Anno di riferimento'");
		getDatiPerComboAnnoRiferimento(session, umaClient, idDittaUma);
		
		// Popolamento combo 'Assegnazione carburante'
		SolmrLogger.debug(this, "---- Popolamento combo 'Assegnazione carburante'");
		getDatiPerComboAssegnazCarburante(session, umaClient, idDittaUma, filter.getAnnoDiRiferimento());
		
		// selezionare come default il primo valore tornato dalla query
		String idAssegnazCarbDaSel = "";
		Vector<CodeDescriptionLong> elencoAssegnazCarburante = (Vector<CodeDescriptionLong>)session.getAttribute("elencoAssegnazCarburante");
		if(elencoAssegnazCarburante != null && elencoAssegnazCarburante.size()>0){
		  Long idAssegnazCarb = elencoAssegnazCarburante.get(0).getCode();
		  SolmrLogger.debug(this, "--- idAssegnazCarb ="+idAssegnazCarb);
		  idAssegnazCarbDaSel = idAssegnazCarb.toString();
		}
		SolmrLogger.debug(this, "--- idAssegnazCarbDaSel ="+idAssegnazCarbDaSel);	
		filter.setIdAssegnazioneCarburante(idAssegnazCarbDaSel);
		
		// Popolamento combo 'Uso del suolo'
		SolmrLogger.debug(this, "---- Popolamento combo 'Uso del suolo'");
		getDatiPerComboUsoDelSuolo(session, umaClient, idDittaUma);
		
		// Popolamento combo 'Lavorazione'
		SolmrLogger.debug(this, "---- Popolamento combo 'Lavorazione'");
		getDatiPerComboLavorazione(session, umaClient, idDittaUma);
		
		
		session.setAttribute("filterRicercaLavContoProprio", filter);
    }
    
  // --- effettua la ricerca con i filtri forzati
  SolmrLogger.debug(this, "---- effettua la ricerca con i filtri forzati");
  try{ 
    Vector<LavContoProprioVO> elencoLavContoProprio = umaClient.findLavorazioniContoProprioByFilter(filter);
    session.setAttribute("elencoLavContoProprio", elencoLavContoProprio);
  }
  catch(Exception ex){
    SolmrLogger.error(this, "--- Exception in elencoLavContoProprioCtrl con findLavorazioniContoProprioByFilter ="+ex.getMessage());
    request.setAttribute("errorMessage",ex.getMessage());
    %>
	  <jsp:forward page = "<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
	<%
	return;
  }
    
  // Se info è valorizzato, si sta arrivando da altre pagine (inserisci, elimina, modifica)
  String info=(String)session.getAttribute("notifica");
  SolmrLogger.debug(this," --- info ="+info);
  if (info!=null){       
    session.removeAttribute("notifica");
    throwValidation(info,view);
  }  
    
 %>
  <jsp:forward page="<%=view%>" />
 <%	
	return;
  }
  else if(operation != null){
    // ----- CASO PAGINAZIONE ----   
    // ----- CASO RICERCA ----
    if(operation.equals("ricerca") || operation.equals("paginazione")){
       if(operation.equals("paginazione")){
         String startRowStr=request.getParameter("startRow");
         request.setAttribute("startRow", startRowStr);	     
	    } 
           
      String annoRiferimento = request.getParameter("annoRiferimento");
      String checkStorico = request.getParameter("variazStoriche");
      String usoSuolo = request.getParameter("idCategoriaUtilizzoUma");
      String lavorazione = request.getParameter("idLavorazione");
      String idAssegnazioneCarburante = request.getParameter("assegnazCarburante");
      
      // Effettuo la ricerca con i filtri impostati                 
      LavContoProprioFilter filter = new LavContoProprioFilter();
      filter.setAnnoDiRiferimento(annoRiferimento);
      filter.setIdAssegnazioneCarburante(idAssegnazioneCarburante); // facoltativo
      filter.setIdCategoriaUtilizzoUma(usoSuolo); // facoltativo
      filter.setIdLavorazioni(lavorazione); // facoltativo      
      
      if(checkStorico != null && !checkStorico.equals(""))
        filter.setVariazioniStoriche(true);   
      filter.setIdDittaUma(idDittaUma);        
         
      try{   
	      SolmrLogger.debug(this, "-- effettuo la ricerca delle lavorazioni conto proprio");   
	      Vector<LavContoProprioVO> elencoLavContoProprio = umaClient.findLavorazioniContoProprioByFilter(filter);
	      session.setAttribute("elencoLavContoProprio", elencoLavContoProprio);
	      session.setAttribute("filterRicercaLavContoProprio", filter);
      }
      catch(Exception ex){
          SolmrLogger.error(this, "--- Exception in elencoLavContoProprioCtrl con findLavorazioniContoProprioByFilter ="+ex.getMessage());
    	  request.setAttribute("errorMessage",ex.getMessage());
    	  %>
	  		<jsp:forward page = "<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
		  <%
		  return;
      }
      
      request.setAttribute("annoRiferimento", annoRiferimento);
      request.setAttribute("checkStorico", checkStorico);      
      
      %>
	    <jsp:forward page="<%=view%>" />
	 <%	
	    return;
    }
    // ----- CASO MODIFICA ----
    // Prima di andare nella pagina di modifica, controlla che non siano stati selezionati dati storicizzati
    else if(operation.equals("modifica")){
        SolmrLogger.debug(this, "----------- CASO di MODIFICA");
      	String[] checkBoxSel = request.getParameterValues("idLavContoProprio");
      	Long[] vIdLav = new Long[checkBoxSel.length];
      	for(int i = 0;i < checkBoxSel.length;i++){
      		vIdLav[i] = new Long(checkBoxSel[i]);
      	}
      	SolmrLogger.debug(this, " --- Ricerco le lavorazioni da modificare");
      	Vector<LavContoProprioVO> lavContoProprioMod = umaClient.findLavorazioneContoProprioByIdRange(vIdLav);
      	for(int i = 0; i < lavContoProprioMod.size();i++){
      		LavContoProprioVO lavContoProprioVO = (LavContoProprioVO)lavContoProprioMod.get(i);
	        if (lavContoProprioVO.getDataFineValidita()!=null || lavContoProprioVO.getDataCessazione() != null){
	          SolmrLogger.debug(this, " -- La Lavorazione con id_lavorazione_conto_proprio ="+lavContoProprioVO.getIdLavorazioneContoProprio()+" e' storicizzata, NON si può modificare");
	          throw new Exception("Una delle lavorazioni non è modificabile perchè si riferisce ad un dato storicizzato");
	        }
      	}
      	
      	/* Controllare che le lavorazioni non siano collegate ad una domanda di assegnazione (base o /saldo oppure supplementare) 
    	   attiva (in presenza solo di un acconto è possibile eliminare le lavorazioni).
    	*/ 
    	SolmrLogger.debug(this, "---- Controllare che le lavorazioni non siano collegate ad una domanda di assegnazione");		 
	    Long numLavCpConAssegnazCarburante = umaClient.countLavCpConAssegnazCarburante(vIdLav);
	    SolmrLogger.debug(this, "-- numLavCpConAssegnazCarburante ="+numLavCpConAssegnazCarburante);
		if(numLavCpConAssegnazCarburante != null && numLavCpConAssegnazCarburante.longValue()>0){
		  SolmrLogger.debug(this, "--- Ci sono lavorazini con una domanda di assegnazione collegata, non è possibile eliminare!");
		  throw new Exception("Operazione non permessa. Una o più lavorazioni selezionate sono collegate ad un'assegnazione di carburante già effettuata.");
		}  
      	
      	
      	// memorizzo le Lavorazioni da modificare
        session.setAttribute("lavContoProprioMod",lavContoProprioMod);      
	    %>
	      <jsp:forward page="<%=modificaUrl%>" />
	    <%	    
    }
    else if(operation.equals("inserisci")){
      SolmrLogger.debug(this, "----------- CASO di INSERISCI");
      
      /* Forzo il filtro con 'anno di riferimento' = anno corrente  e 'Assegnazione carburante' = 'Nessuna assegnazione'
           ---> (l'inserimento viene effettuato SOLO sull'anno corrente e su 'Nessuna assegnazione')
           ---> dopo aver effettuato l'inserimento si tornerà nella pagina di elenco lavorazioni con questo filtro settato per la ricerca
       */
      LavContoProprioFilter filter = new LavContoProprioFilter();
      GregorianCalendar gc = new GregorianCalendar();    
	  int annoCorrente = gc.get(gc.YEAR);	        
	  String annoRiferimento = new Integer(annoCorrente).toString();
	  filter.setAnnoDiRiferimento(annoRiferimento);
	  filter.setIdDittaUma(idDittaUma);
	  
	  String usoSuolo = request.getParameter("idCategoriaUtilizzoUma");
      String lavorazione = request.getParameter("idLavorazione");
      filter.setIdCategoriaUtilizzoUma(usoSuolo);
      filter.setIdLavorazioni(lavorazione);
      filter.setIdAssegnazioneCarburante("9999999999"); // 9999999999 -> valore attribuito all'elemento 'Nessuna assegnazione' nella combo di ricerca 'Assegnazione carburante'
      
      session.setAttribute("filterRicercaLavContoProprio",filter);
      %>
		 <jsp:forward page="<%=insertUrl%>" />
	  <%
	  return;
    }
    else if(operation.equals("elimina")){
      SolmrLogger.debug(this, "----------- CASO di ELIMINA");      
      Long[] vIdLav = null;
      
      // --- Controllo che le lavorazioni selezionate siano TUTTE ATTIVE 
      // Note : gli altri controlli vengono effettuati in AggiornaLavContoProprioCU
      try{
	    String[] idLavContoProprioSel = request.getParameterValues("idLavContoProprio");
	    vIdLav = new Long[idLavContoProprioSel.length];
	    for(int i = 0;i < idLavContoProprioSel.length;i++){
	     vIdLav[i] = new Long(idLavContoProprioSel[i]);
	    }
	    Vector<LavContoProprioVO> lavContoProprioSel = umaClient.findLavorazioneContoProprioByIdRange(vIdLav);
	    for(int i = 0; i < lavContoProprioSel.size();i++){
	      LavContoProprioVO lavContoProprioVO = (LavContoProprioVO)lavContoProprioSel.get(i);
		   if (lavContoProprioVO.getDataFineValidita() != null ||
		       lavContoProprioVO.getDataCessazione() != null){
		          SolmrLogger.debug(this, " --- Sono state selezionate delle lavorazioni NON ATTIVE");
		          throw new Exception("Una o più lavorazioni tra quelle selezionate non sono modificabili perchè si riferiscono a dati storicizzati.");
	        }
      	}
        session.setAttribute("idLavContoProprioSel",vIdLav);
        
        
        
        /* -- Controllo lavorazioni vincolate (madre/figlia) :
           se si sta cercando di eliminare una lavorazione "madre" con "figli", controllare se uno di questi figli sono già
           stati inseriti. In tal caso : ERRORE (non si può eliminare la lavorazione)        
        */ 
        SolmrLogger.debug(this, " --- Controllo lavorazioni vincolate (madre/figlia)");
                 
        // - Controllo se la lavorazione è una "madre"
        // scorro le lavorazioni che si vogliono eliminare
        SolmrLogger.debug(this, " --- numero di lavorazioni selezionate ="+vIdLav.length);
        for(int i=0;i<vIdLav.length;i++){
          Long idLavSel = vIdLav[i];          
          SolmrLogger.debug(this, "--- ID_LAVORAZIONE_CONTO_PROPRIO che si vuole eliminare ="+idLavSel);
          
          // -- ricerco i dati della lavorazione conto proprio (per avere id_lavorazioni e id_categoria_utilizzo_uma)
          SolmrLogger.debug(this, "--  ricerco i dati della lavorazione conto proprio che si vuole eliminare");
          LavContoProprioVO lavCPVO = umaClient.getDettaglioLavContoProprio(idLavSel);
          
          // -- controllo se ci sono delle lavorazioni figlie legate alla lavorazione in esame
          SolmrLogger.debug(this, "--  controllo se l'id_lavorazioni ha delle figlie legate");
          // ottengo un elenco di id_lavorazioni
          Vector<Long> elencoIdLavFiglie = umaClient.getLavorazFiglieByIdLavorazMadre(new Long(lavCPVO.getLavorazione()), new Long(lavCPVO.getUsoDelSuolo()));
          
          if(elencoIdLavFiglie != null && elencoIdLavFiglie.size() >0){
            SolmrLogger.debug(this, "--- ci sono delle lavorazioni figlie legate all'id_lavorazione ="+idLavSel);
            SolmrLogger.debug(this, "--- numero di figlie trovate ="+elencoIdLavFiglie.size());
            // -- se almeno una delle lavorazioni figlie è stata inserita -> bloccare l'elimina
            Vector<Long> elencoLavFiglieInserite = umaClient.findLavCPByIdLavorazioniRange(elencoIdLavFiglie.toArray(new Long[elencoIdLavFiglie.size()]), idDittaUma, new Long(lavCPVO.getUsoDelSuolo()));
	        if(elencoLavFiglieInserite != null && elencoLavFiglieInserite.size()>0){
	          SolmrLogger.debug(this, "--- sono già state inserite delle lavorazioni figlie, non si può procedere con l'elimina");
	          throw new Exception("Una o più lavorazioni tra quelle selezionate non si possono eliminare, eliminare prima le lavorazioni vincolate");	          
	        }    
          }
          
        }// fine ciclo sulle lavorazioni selezionate, da eliminare
        
        
        /* Controllare che le lavorazioni non siano collegate ad una domanda di assegnazione (base o /saldo oppure supplementare) 
    	   attiva (in presenza solo di un acconto è possibile eliminare le lavorazioni).
    	*/ 
    	SolmrLogger.debug(this, "---- Controllare che le lavorazioni non siano collegate ad una domanda di assegnazione");		 
	    Long numLavCpConAssegnazCarburante = umaClient.countLavCpConAssegnazCarburante(vIdLav);
	    SolmrLogger.debug(this, "-- numLavCpConAssegnazCarburante ="+numLavCpConAssegnazCarburante);
		if(numLavCpConAssegnazCarburante != null && numLavCpConAssegnazCarburante.longValue()>0){
		  SolmrLogger.debug(this, "--- Ci sono lavorazini con una domanda di assegnazione collegata, non è possibile eliminare!");
		  throw new Exception("Operazione non permessa. Una o più lavorazioni selezionate sono collegate ad un'assegnazione di carburante già effettuata.");
		}  	  
        
	  }
      catch(Exception e){
          request.setAttribute("errorMessage",e.getMessage());
          SolmrLogger.error(this, "--- Exception in fase dei controlli per elimina Lavorazioni Conto Proprio ="+e.getMessage());
          %>
            <jsp:forward page = "<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
          <%
	        return;
      }
        %>
          <jsp:forward page="<%=deleteUrl%>" />
	   <%
    }
    else if(operation.equals("importa")){
        SolmrLogger.debug(this, "----------- CASO di IMPORTA");      
               
		String urlConferma="/ditta/ctrl/confermaImportaLavContoProprioCtrl.jsp";
		SolmrLogger.debug(this, "   END elencoLavContoProprioCtrl");
      %>
        <jsp:forward page="<%=urlConferma%>" />
      <%
	    return; 
    }
    else if(operation.equals("changeAnno")){
      SolmrLogger.debug(this, "----------- CASO di changeAnno");
      // deve essere ricaricata la combo 'Assegnazione carburante', filtrata per l'anno selezionato
      String annoRiferimento = request.getParameter("annoRiferimento");
      SolmrLogger.debug(this, "-- anno di riferimento selezionato ="+annoRiferimento);
      LavContoProprioFilter filter = (LavContoProprioFilter)session.getAttribute("filterRicercaLavContoProprio");
      filter.setAnnoDiRiferimento(annoRiferimento);
      
      String checkStorico = request.getParameter("variazStoriche");
      String usoSuolo = request.getParameter("idCategoriaUtilizzoUma");
      String lavorazione = request.getParameter("idLavorazione");
      String idAssegnazioneCarburante = request.getParameter("assegnazCarburante");
      // setto i filtri per le eventuali altre selezioni nelle combo
      filter.setIdAssegnazioneCarburante(idAssegnazioneCarburante);
      filter.setIdCategoriaUtilizzoUma(usoSuolo);
      filter.setIdLavorazioni(lavorazione);      
      
      if(checkStorico != null && !checkStorico.equals(""))
        filter.setVariazioniStoriche(true);	  
      
      
      getDatiPerComboAssegnazCarburante(session, umaClient, idDittaUma, annoRiferimento);
      
      %>
	    <jsp:forward page="<%=view%>" />
	  <%	
	  return;
    }
    
    
  }
  
 	
  
%>

<%!

 // Ricerca gli anni da caricare nella combo 'Anno di riferimento' 
 private void getDatiPerComboAnnoRiferimento(HttpSession session, UmaFacadeClient umaClient, Long idDittaUma) throws Exception{
   SolmrLogger.debug(this, "   BEGIN getDatiPerComboAnnoRiferimento");
      
   Vector<CodeDescr> elencoAnniDiRiferimento = umaClient.getElencoAnniRifContoProprio(idDittaUma);
   SolmrLogger.debug(this, " --- numero di anni da caricare nella combo ="+elencoAnniDiRiferimento.size());
   session.setAttribute("elencoAnniRiferimento", elencoAnniDiRiferimento);
       
   SolmrLogger.debug(this, "   END getDatiPerComboAnnoRiferimento");
 }
 
 
 // Ricerca le Assegnazione carburante da caricare nella combo 'Assegnazione carburante'
 private void getDatiPerComboAssegnazCarburante(HttpSession session, UmaFacadeClient umaClient, Long idDittaUma, String annoDiRiferimento) throws Exception{
   SolmrLogger.debug(this, "   BEGIN getDatiPerComboAssegnazCarburante");
   
   Vector<CodeDescriptionLong> elencoAssegnazCarburante = umaClient.getElencoAssegnazCarbByIdDittaUmaAnnoCamp(idDittaUma, new Long(annoDiRiferimento));
   SolmrLogger.debug(this, " --- numero di assegnazioni carburante da caricare nella combo ="+elencoAssegnazCarburante.size());
   session.setAttribute("elencoAssegnazCarburante", elencoAssegnazCarburante);
         
   SolmrLogger.debug(this, "   END getDatiPerComboAssegnazCarburante");
 } 
 
  
 // Ricerca gli Usi del suolo da caricare nella combo 'Uso del suolo'
 private void getDatiPerComboUsoDelSuolo(HttpSession session, UmaFacadeClient umaClient, Long idDittaUma) throws Exception{
   SolmrLogger.debug(this, "   BEGIN getDatiPerComboUsoDelSuolo");
   
   Vector<CodeDescr> elencoUsiDelSuolo = umaClient.getAllUsoDelSuoloContoProprio(idDittaUma);
   SolmrLogger.debug(this, " --- numero di usi del suolo da caricare nella combo ="+elencoUsiDelSuolo.size());
   session.setAttribute("elencoUsiDelSuolo", elencoUsiDelSuolo);
   
   SolmrLogger.debug(this, "   END getDatiPerComboUsoDelSuolo");
 }
 
 
 private void getDatiPerComboLavorazione(HttpSession session, UmaFacadeClient umaClient, Long idDittaUma) throws Exception{
   SolmrLogger.debug(this, "   BEGIN getDatiPerComboLavorazione");
   
   Vector<CodeDescr> elencoLavorazioni = umaClient.getAllLavorazioneContoProprio(idDittaUma);
   SolmrLogger.debug(this, " --- numero di lavorazioni da caricare nella combo ="+elencoLavorazioni.size());
   session.setAttribute("elencoLavorazioni", elencoLavorazioni);
   
   SolmrLogger.debug(this, "   END getDatiPerComboLavorazione");
 }
  

  private void removeValSession(HttpSession session) throws Exception{
    SolmrLogger.debug(this, "   BEGIN removeValSession");
    
    session.removeAttribute("filterRicercaLavContoProprio");
    session.removeAttribute("elencoLavContoProprio");
    session.removeAttribute("elencoAnniRiferimento");
    session.removeAttribute("elencoAssegnazCarburante");
    session.removeAttribute("elencoUsiDelSuolo");
    session.removeAttribute("elencoLavorazioni");
    session.removeAttribute("idLavContoProprioSel");
    session.removeAttribute("lavContoTerziMod");
        
    SolmrLogger.debug(this, "   END removeValSession");
  }
  
   private void throwValidation(String msg,String validateUrl) throws ValidationException{
    ValidationException valEx = new ValidationException(msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }
  
 %>
