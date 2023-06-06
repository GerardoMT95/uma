  <%@page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
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
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>

<%!
  public static String URL="/ditta/view/elencoSuperficiCpView.jsp";
%>
<%

  String iridePageName = "elencoSuperficiCpCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "   BEGIN elencoSuperficiCpCtrl");
  
  UmaFacadeClient umaClient = new UmaFacadeClient();      
  String operazione = (String)request.getParameter("operazione");
  SolmrLogger.debug(this, " --- operazione ="+operazione);
  
  // -------- Prima volta che si fa accesso alla pagina
  if(operazione == null || operazione.equals("")){ 
    SolmrLogger.debug(this, "--- CASO DI primo caricamento della pagina");
    
    // rimuovo oggetto in sessione dove vengono memorizzate le uv associate alla scheda rilievo
	removeSessionAttribute(session);
	
	// Carico i valori per 'Tipo riepilogo'
	Vector<CodeDescr> tipiRiepilogo = getTipiRiepilogo();
	session.setAttribute("tipiRiepilogo", tipiRiepilogo);
	  
	// Ricerca dati da caricare nella combo 'Anno riferimento'
	Vector<CodeDescr> anniRiferimento = getAnniRiferimento();
	session.setAttribute("anniRiferimento", anniRiferimento);
	
	// Ricerca i dati da caricare nella combo 'Uso del suolo'
	Vector<CodeDescr> usiDelSuolo = getUsiDelSuolo(umaClient);
	session.setAttribute("usiDelSuolo", usiDelSuolo);
  }
  // --------- CASO ricerca CUAA
  else if(operazione.equals("cercaCuaa")){
    SolmrLogger.debug(this, "--- CASO DI cerca cuaa");
    
    // rimuovo il valore selezionato con il radio    
    request.removeAttribute("idAziendaSel");
    
    // Controllo che l'utente abbia indicato un cuaa e che sia valido
    String cuaa = request.getParameter("cuaa");
    SolmrLogger.debug(this, "-- cuaa ="+cuaa);
    request.setAttribute("cuaa", cuaa);
    ValidationErrors errors = new ValidationErrors();
    errors = validazioneCuaa(cuaa,errors);   
    
    // se è stato inserito un cuaa valido, chiamo i servizi di anagrafe per avere la/e azienda/e con il cuaa indicato
    if(errors.size() == 0){
      SolmrLogger.debug(this, "-- il cuaa inserito e' valido, proseguire con la ricerca");
      AnagAziendaVO[] elencoAziendeAnagrafe = getElencoAziendeAnagByCuaa(session,cuaa,umaClient);
      
      // mermorizzo in sessione l'elenco delle aziende di anagrafe trovate dalla ricerca
      session.setAttribute("elencoAziendeAnagrafe", elencoAziendeAnagrafe);      
      // memorizzo in sessione il fatto che è stata effettuata la ricerca su anagrafe
      session.setAttribute("ricercaAnagrafe", "YES");      
      // ripulisco l'elenco dei dati delle superfici (nel caso in cui sia stata effettuata una ricerca precedente)
      session.removeAttribute("elencoSuperficiCp");      
      // ripulisco la variabile in sessione che registra il fatto che è stata effettuata la ricerca per le superfici
      session.removeAttribute("ricercaSuperfici");
      
      // --- CASO in cui sia stata trovata solo un'azienda da anagrafe : effettuare direttamente la ricerca delle superfici
      // Attenzione : verificare se è stato selezionato un uso del suolo
      if(elencoAziendeAnagrafe != null && elencoAziendeAnagrafe.length == 1){
        SolmrLogger.debug(this, "-- e' stata trovata 1 SOLA AZIENDA dai servizi di anagrafe, effettaure anche la ricerca superfici");
        
        // Dati selezionati dall'utente
        String tipoRiepilogo = request.getParameter("tipoRiepilogo");
        SolmrLogger.debug(this, "-- tipoRiepilogo ="+tipoRiepilogo);
        String annoRiferimento = request.getParameter("annoRiferimento");
        SolmrLogger.debug(this, "-- annoRiferimento ="+annoRiferimento);
        
        // idAzienda trovata dal servizio di anagrafe
        String idAzienda = elencoAziendeAnagrafe[0].getIdAzienda().toString();
        SolmrLogger.debug(this, "-- idAzienda ="+idAzienda);
         // memorizzo il radio button selezionato       
        request.setAttribute("idAziendaSel", idAzienda);
                
        String usoDelSuolo = request.getParameter("usoDelSuolo");    
        SolmrLogger.debug(this, "-- usoDelSuolo ="+usoDelSuolo); 
        // Effettuare Validazione : deve essere stato selezionato un 'Uso del Suolo'        
        if(usoDelSuolo == null || usoDelSuolo.trim().equals("")){
          SolmrLogger.debug(this, " -- Filtro uso del suolo obbligatorio!"); 
          errors.add("usoDelSuolo", new ValidationError("Filtro obbligatorio"));
          request.setAttribute("errors", errors);
        }
        else{        
	        // Costruisco il filtro per la ricerca
	        SuperficieCpFilterVO filterVO = new SuperficieCpFilterVO();
	        filterVO.setTipoRiepilogo(tipoRiepilogo);
	        filterVO.setAnnoRiferimento(annoRiferimento);
	        filterVO.setIdAziendaAnagrafe(idAzienda);
	        filterVO.setUsoDelSuolo(usoDelSuolo);
	        
	        SolmrLogger.debug(this, "-- Effettuo la ricerca delle superfici");
	        Vector<SuperficieAziendaVO> elencoSuperficiCp = umaClient.ricercaDatiSuperficiContoProprio(filterVO);
	        session.setAttribute("elencoSuperficiCp", elencoSuperficiCp);
	        session.setAttribute("tipoRiepilogoSel", tipoRiepilogo);
	    
	        // memorizzo in sessione il fatto che è stata effettuata la ricerca per le superfici
	        session.setAttribute("ricercaSuperfici", "YES");
	   }       
      } // fine caso : anagrafe ha trovato una sola azienda

    } // fine il cuaa inserito e' valido    
    else{
      SolmrLogger.debug(this, "-- il cuaa inserito NON e' valido, NON si puo' proseguire con la ricerca");
      
      // ripulisco l'elenco dei dati delle superfici (nel caso in cui sia stata effettuata una ricerca precedente)
      session.removeAttribute("elencoDatiSuperfici");
      
      request.setAttribute("errors", errors);
      SolmrLogger.debug(this, "   END elencoSuperficiCpCtrl");
      %>
        <jsp:forward page="<%=URL%>" />
     <%
    }
  }
  // --------- CASO ricerca DATI superfici
  else if(operazione.equals("ricercaSuperfici")){
    SolmrLogger.debug(this, "--- CASO DI ricerca superfici");       
    
    // Dati selezionati dall'utente
    String tipoRiepilogo = request.getParameter("tipoRiepilogo");
    SolmrLogger.debug(this, "-- tipoRiepilogo ="+tipoRiepilogo);
    String annoRiferimento = request.getParameter("annoRiferimento");
    SolmrLogger.debug(this, "-- annoRiferimento ="+annoRiferimento);
    String idAzienda = request.getParameter("idAziendaAnagrafe");
    SolmrLogger.debug(this, "-- idAzienda ="+idAzienda);
    
     // memorizzo il radio button selezionato
    String idAziendaSel = request.getParameter("idAziendaAnagrafe");
    SolmrLogger.debug(this, "-- idAziendaSel = "+idAziendaSel);
    request.setAttribute("idAziendaSel", idAziendaSel);
    
    // memorizzo il cuaa inserito
    String cuaa = request.getParameter("cuaa");
    SolmrLogger.debug(this, "-- cuaa ="+cuaa);
    request.setAttribute("cuaa", cuaa);
    
    String usoDelSuolo = request.getParameter("usoDelSuolo");    
    SolmrLogger.debug(this, " -- usoDelSuolo ="+usoDelSuolo);
    
    // Effettuare Validazione : deve essere stato selezionato un 'Uso del Suolo'
    ValidationErrors errors = new ValidationErrors();
    if(usoDelSuolo == null || usoDelSuolo.trim().equals("")){
      SolmrLogger.debug(this, " -- Filtro uso del suolo obbligatorio!"); 
      errors.add("usoDelSuolo", new ValidationError("Filtro obbligatorio"));
      request.setAttribute("errors", errors);
    }
    else{    
      // Costruisco il filtro per la ricerca
      SuperficieCpFilterVO filterVO = new SuperficieCpFilterVO();
      filterVO.setTipoRiepilogo(tipoRiepilogo);
      filterVO.setAnnoRiferimento(annoRiferimento);
      filterVO.setIdAziendaAnagrafe(idAzienda);
      filterVO.setUsoDelSuolo(usoDelSuolo);
        
      SolmrLogger.debug(this, "-- Effettuo la ricerca delle superfici");
      Vector<SuperficieAziendaVO> elencoSuperficiCp = umaClient.ricercaDatiSuperficiContoProprio(filterVO);
      session.setAttribute("elencoSuperficiCp", elencoSuperficiCp);
      session.setAttribute("tipoRiepilogoSel", tipoRiepilogo);
    
      // memorizzo in sessione il fatto che è stata effettuata la ricerca per le superfici
      session.setAttribute("ricercaSuperfici", "YES");
    }
   
        
  }
    
    
  
  SolmrLogger.debug(this, "   END elencoSuperficiCpCtrl");
  %>
    <jsp:forward page="<%=URL%>" />
  <%
  
%>

<%!

  // -- Ricerca della/e azienda/e di Anagrafe con il cuaa passato in input
  private AnagAziendaVO[] getElencoAziendeAnagByCuaa(HttpSession session, String cuaa,UmaFacadeClient umaClient) throws Exception{
    SolmrLogger.debug(this, "  BEGIN getElencoAziendeAnagByCuaa");
    
    AnagAziendaVO[] elencoAziendeAnagrafe = null;
    AnagAziendaVO anagAz = new AnagAziendaVO();
    anagAz.setCUAA(cuaa.trim());
    SolmrLogger.debug(this, "-- chiamata al servizio serviceGetListIdAziende() con cuaa ="+cuaa);
    Vector<Long> elencoIdAziende = umaClient.serviceGetListIdAziende(anagAz, new Boolean(false), new Boolean(false));
   
    if(elencoIdAziende != null && elencoIdAziende.size()>0){
      SolmrLogger.debug(this, "-- sono stati trovati degli idAziende su Anagrafe, quanti ="+elencoIdAziende.size());
      
      SolmrLogger.debug(this, "-- chiamata al servizio serviceGetListAziendeByIdRange()");
      elencoAziendeAnagrafe = umaClient.serviceGetListAziendeByIdRange(elencoIdAziende);      
    }
    else{
      SolmrLogger.debug(this, "-- NON sono stati trovati degli idAziende su Anagrafe");      
    }
    
     
    SolmrLogger.debug(this, "  END getElencoAziendeAnagByCuaa");
    return elencoAziendeAnagrafe;
  }


  // --- Validazione campo cuaa
  private ValidationErrors validazioneCuaa(String cuaa,ValidationErrors errors) throws Exception{
    SolmrLogger.debug(this, "  BEGIN validazioneCuaa");    
    
    if(Validator.isNotEmpty(cuaa)){
	   if(cuaa.trim().length() != 11 && cuaa.trim().length() != 16){
	     errors.add("cuaa", new ValidationError("CUAA errato"));
	   }	      
	   else if(cuaa.trim().length()==11 && !Validator.isNumericInteger(cuaa.trim())){
	     errors.add("cuaa",new ValidationError("CUAA errato"));
	   }
	}
	else{
	  errors.add("cuaa",new ValidationError("campo obbligatorio"));
	}
    
    SolmrLogger.debug(this, "  END validazioneCuaa");
    return errors;
  }


  // ---- Elenco anni di riferimento : anno in corso + anno precedente
  private Vector<CodeDescr> getAnniRiferimento() throws Exception{
    SolmrLogger.debug(this, "  BEGIN getAnniRiferimento");
    
    String annoAttuale = String.valueOf(UmaDateUtils.getCurrentYear().intValue());
    String annoPrec = String.valueOf((UmaDateUtils.getCurrentYear().intValue()-1));
    
    CodeDescr codeDescr1 = new CodeDescr(new Integer(annoAttuale),annoAttuale);
    CodeDescr codeDescr2 = new CodeDescr(new Integer(annoPrec),annoPrec);
    
    Vector<CodeDescr> elencoAnni = new Vector<CodeDescr>();
    elencoAnni.add(codeDescr1);
    elencoAnni.add(codeDescr2);
   
    SolmrLogger.debug(this, "  END getAnniRiferimento");
    return elencoAnni;
  }
  
  
  // ---- Elenco tipo di riepilogo
  private Vector<CodeDescr> getTipiRiepilogo() throws Exception{
    SolmrLogger.debug(this, "  BEGIN getTipiRiepilogo");        
    
    CodeDescr codeDescr1 = new CodeDescr(new Integer(SolmrConstants.ID_TIPO_RIEP_COMUNE), SolmrConstants.DESCR_TIPO_RIEP_COMUNE);
    CodeDescr codeDescr2 = new CodeDescr(new Integer(SolmrConstants.ID_TIPO_RIEP_LAV_SUOLO), SolmrConstants.DESCR_TIPO_RIPEP_LAV_SUOLO);
    
    Vector<CodeDescr> elencoTipiRiepilogo = new Vector<CodeDescr>();
    elencoTipiRiepilogo.add(codeDescr1);
    elencoTipiRiepilogo.add(codeDescr2);
   
    SolmrLogger.debug(this, "  END getTipiRiepilogo");
    return elencoTipiRiepilogo;
  }
  
  
  // ---- Elenco Usi del Suolo
  private Vector<CodeDescr> getUsiDelSuolo(UmaFacadeClient umaClient)throws Exception{
    SolmrLogger.debug(this, "   BEGIN getUsiDelSuolo");
    Vector<CodeDescr> elencoUsiDelSuolo = null;
    try{
      elencoUsiDelSuolo = umaClient.getUsiDelSuoloSuperfCT();      
    }    
    catch(Exception e){
      SolmrLogger.error(this, " --- Exception in getUsiDelSuolo ="+e.getMessage());
      throw e;
    }
    finally{
      SolmrLogger.debug(this, "   END getUsiDelSuolo");
    }
    return elencoUsiDelSuolo;
  }
  
  
  
  // ---- Rimuove gli attributi dalla sessione
  private void removeSessionAttribute(HttpSession session) throws Exception{
    SolmrLogger.debug(this, "   BEGIN removeSessionAttribute");
    
    session.removeAttribute("tipiRiepilogo");
    session.removeAttribute("tipoRiepilogoSel");
    
    session.removeAttribute("anniRiferimento");
    
    session.removeAttribute("usiDelSuolo");
    
    session.removeAttribute("elencoAziendeAnagrafe");
    session.removeAttribute("ricercaAnagrafe");
    session.removeAttribute("ricercaSuperfici");
    session.removeAttribute("elencoSuperficiCp");
    
    
    SolmrLogger.debug(this, "   END removeSessionAttribute");
  }
%>
