<%@ page language="java"
         contentType="text/html"
 %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.SolmrConstants" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.dto.comune.IntermediarioVO" %>
<%@ page import="it.csi.papua.papuaserv.dto.legacy.axis.RuoloUtenzaPapua" %>
<%@ page import="it.csi.papua.papuaserv.presentation.ws.profilazione.axis.UtenteAbilitazioni" %>

<%
 SolmrLogger.debug(this, "buoniPrelievoCtrl.jsp - Begin");

 //Usato nella stampa delle voci di menù del buono
 if(request.getParameter("select")!=null){
   Long idDomAssSelected = new Long(request.getParameter("select"));
   request.setAttribute("idDomAssSelected", idDomAssSelected);
 }

  String iridePageName = "buoniPrelievoCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

 UmaFacadeClient client = new UmaFacadeClient();
 ValidationException valEx = null;
 ValidationError error = null;
 ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

 String url = "/domass/view/buoniPrelievoView.jsp";
 RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
 SolmrLogger.debug(this, "Valore DittaUmaVO "+session.getAttribute("dittaUMAAziendaVO"));
 DittaUMAVO dittaUMAVO = (DittaUMAVO)session.getAttribute("umaVO");
 DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
 BuonoPrelievoVO buonoVO = null;
 BloccoDittaVO bloccoVO = null;
 Vector v_domass = null;
 Vector v_buoni = null;
 Vector v_carb = null;
 Long idBuonoPrelievo = null;
 Long idStatoDomanda = null;
 String msg ="";

 if(request.getParameter("operazione")!= null && request.getParameter("operazione").equals("dettaglio1")){
   SolmrLogger.debug(this, "Entro in dettaglio1");
   Long idDomAss = new Long(request.getParameter("select"));
   idBuonoPrelievo = null;
   if(request.getParameter("radiobuttonPrelievo")!=null){
     idBuonoPrelievo = new Long(request.getParameter("radiobuttonPrelievo"));
     try {
       Vector vec = client.getStampaBuono(idBuonoPrelievo);
       if(vec == null) {
         vec = new Vector();
       }
       session.setAttribute("stampe", vec);
       HashMap hm = new HashMap();
       if(vec != null) 
       {
         for(int i = 0; i < vec.size(); i ++) 
         {
           StampaBuonoVO sbvo = (StampaBuonoVO)vec.get(i);
           Long idUtente = new Long((String)sbvo.getExtIdUtenteStampa());
           UtenteAbilitazioni utenteAbilitazioni = client.getUtenteAbilitazioniByIdUtenteLogin(idUtente);
           RuoloUtenza ru = new RuoloUtenzaPapua(utenteAbilitazioni); 
           //RuoloUtenza ru = client.serviceGetRuoloUtenzaByIdUtente(idUtente);
           hm.put(idUtente, ru);
         }
         session.setAttribute("ruoloUtenzaLocal", hm);
       }
       buonoVO = client.getDettaglioBuono(idBuonoPrelievo);
       String idUtEm = buonoVO.getExtIdUtenteEmissione();
       RuoloUtenza ruUt = null;
       if(idUtEm != null) 
       {
         UtenteAbilitazioni utenteAbilitazioni = client.getUtenteAbilitazioniByIdUtenteLogin(new Long(idUtEm));
         ruUt = new RuoloUtenzaPapua(utenteAbilitazioni);
         //ruUt = client.serviceGetRuoloUtenzaByIdUtente(new Long(idUtEm));
       }
       String idInEm = buonoVO.getExtIdIntermediarioEmissione();
       IntermediarioVO intermediarioVO = null;
       if(idInEm != null) {
         intermediarioVO = client.serviceFindIntermediarioByIdIntermediario(new Long(idInEm));
       }

       v_carb = client.getDettaglioCarburante(idBuonoPrelievo);

       SolmrLogger.debug(this, "Valori di buonoVO e v_carb... "+buonoVO+" - "+v_carb);
       if(buonoVO!=null&&v_carb!=null){
         buonoVO.setIdBuonoPrelievo(idBuonoPrelievo);
         SolmrLogger.debug(this, "Valore di idBuonoPrelievo... "+buonoVO.getIdBuonoPrelievo());
         buonoVO.setIdDomandaAssegnazione(idDomAss);
         session.setAttribute("buonoVO", buonoVO);
         session.setAttribute("v_carb", v_carb);
         if(ruUt != null) {
           session.setAttribute("ruUt", ruUt);
         }
         if(intermediarioVO != null) {
           session.setAttribute("intermediarioVOEmissione", intermediarioVO);
         }
         url = "/domass/layout/dettaglioBuonoPOP.htm";
       }
     }
     catch (SolmrException ex) {
       error = new ValidationError(ex.getMessage());
       errors = new ValidationErrors();
       errors.add("error", error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
       return;
     }
   }
 }

 else if(request.getParameter("operazione")!= null && request.getParameter("operazione").equals("dettaglio2")){
   SolmrLogger.debug(this, "Entro in dettaglio2");
   idBuonoPrelievo = new Long(request.getParameter("radiobuttonRest"));
   Long idDomAss = new Long(request.getParameter("select"));
   try {
     buonoVO = client.getDettaglioBuono(idBuonoPrelievo);
     v_carb = client.getDettaglioCarburante(idBuonoPrelievo);
     if(buonoVO!=null&&v_carb!=null){
       buonoVO.setIdDomandaAssegnazione(idDomAss);
       session.setAttribute("buonoVO", buonoVO);
       session.setAttribute("v_carb", v_carb);
       request.setAttribute("reso", "true");
       url = "/domass/layout/dettaglioBuonoPOP.htm";
     }
   }
   catch (SolmrException ex) {
     error = new ValidationError(ex.getMessage());
     errors = new ValidationErrors();
     errors.add("error", error);
     request.setAttribute("errors", errors);
     request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
     return;
   }

 }

 else if(request.getParameter("operazione")!= null && request.getParameter("operazione").equals("restituisci")){
   SolmrLogger.debug(this, "Entro in restituisci");
   Long idDomAss = null;
   buonoVO = (BuonoPrelievoVO)session.getAttribute("buonoVO");
   if(request.getParameter("radiobuttonPrelievo")!=null&&request.getParameter("select")!=null){
     idBuonoPrelievo = new Long(request.getParameter("radiobuttonPrelievo"));
     idDomAss = new Long(request.getParameter("select"));
   }
   else {
     idBuonoPrelievo = buonoVO.getIdBuonoPrelievo();
     idDomAss = buonoVO.getIdDomandaAssegnazione();
   }
   request.setAttribute("idDomAss", idDomAss);
   try {
     buonoVO = client.getDettaglioBuono(idBuonoPrelievo);
     buonoVO.setIdBuonoPrelievo(idBuonoPrelievo);
     buonoVO.setIdDomandaAssegnazione(idDomAss);
     v_buoni = client.findBuonoPrelievo(idDomAss);
     request.setAttribute("v_buoni",v_buoni);
     SolmrLogger.debug(this, "Parametri passati a existNextDomAss "+idDomAss+" - "+dittaUMAAziendaVO.getIdDittaUMA());
     client.rilanciaErroreSeEsisteDomandaBaseOAccontoAnnoSuccessivo(idDomAss, dittaUMAAziendaVO.getIdDittaUMA());
     client.esistePrelievo(idBuonoPrelievo);
     // Controllo che i buoni non siano già stati annullati
     if(buonoVO.getAnnullato()!=null && buonoVO.getAnnullato().equals(SolmrConstants.FLAG_SI)){
       error = new ValidationError(""+UmaErrors.get("RESTITUZIONE_BUONO_ANNULLATO"));
       errors = new ValidationErrors();
       errors.add("error", error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
       return;
     }
     if (buonoVO.getDataRestituzione()!=null)
           {
            error = new ValidationError(UmaErrors.ERR_BUONO_PRELIEVO_GIA_RESTITUITO);
            errors = new ValidationErrors();
            errors.add("error", error);
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
            return;
           }           
     
     v_carb = client.getDettaglioCarburante(idBuonoPrelievo);
     session.setAttribute("buonoVO",buonoVO);
     session.setAttribute("v_carb", v_carb);
   }
   catch (SolmrException ex) {
     SolmrLogger.debug(this, " ::::::::::::: Ecceziooooone "+ex+" - "+ex.getMessage());
     error = new ValidationError(ex.getMessage());
     errors = new ValidationErrors();
     errors.add("error", error);
     request.setAttribute("errors", errors);
     request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
     return;
   }
   try {
     bloccoVO = client.getDettaglioBlocco(dittaUMAAziendaVO.getIdDittaUMA());
   }
   catch (SolmrException ex) {
     error = new ValidationError(ex.getMessage());
     errors = new ValidationErrors();
     errors.add("error", error);
     request.setAttribute("errors", errors);
     request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
     return;
   }
   if(bloccoVO!=null){
     error = new ValidationError(""+UmaErrors.get("DITTA_BLOCCATA"));
     errors = new ValidationErrors();
     errors.add("error", error);
     request.setAttribute("errors", errors);
     request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
     return;
   }
   url = "/domass/layout/restituzioneBuono.htm";
 }

 else if(request.getParameter("operazione")!= null && request.getParameter("operazione").equals("annulla")){
   SolmrLogger.debug(this, "Entro in annulla");
   buonoVO = (BuonoPrelievoVO)session.getAttribute("buonoVO");
   Long idDomAss = null;

   SolmrLogger.debug(this,"\n\n\n\n\nSOLO UNA PROVA\n*********************");
   SolmrLogger.debug(this,"Buono prelievo (da idBuonoPrelievo): " + request.getParameter("idBuonoPrelievo"));

   if(request.getParameter("radiobuttonPrelievo")!=null&&request.getParameter("select")!=null){
     idBuonoPrelievo = new Long(request.getParameter("radiobuttonPrelievo"));
     idDomAss = new Long(request.getParameter("select"));
   }
   else {
     idBuonoPrelievo = buonoVO.getIdBuonoPrelievo();
     idDomAss = buonoVO.getIdDomandaAssegnazione();
   }

   SolmrLogger.debug(this,"\nidDomAss: " +idDomAss);
   SolmrLogger.debug(this,"\nidBuonoPrelievo: " + idBuonoPrelievo);
   SolmrLogger.debug(this,"\n*******************\n\n\n\n\n");

   request.setAttribute("idDomAss", idDomAss);
   try {
     v_buoni = client.findBuonoPrelievo(idDomAss);     
     request.setAttribute("v_buoni",v_buoni);
     
     SolmrLogger.debug(this, "radiobuttonPrelievo "+idBuonoPrelievo);
     
     buonoVO = client.getDettaglioBuono(idBuonoPrelievo);
     
     buonoVO.setIdBuonoPrelievo(idBuonoPrelievo);
     buonoVO.setIdDomandaAssegnazione(idDomAss);
     
     SolmrLogger.debug(this, "buonoVO "+buonoVO);
     String numeroBlocco=StringUtils.checkNull(buonoVO.getNumeroBlocco());
     String numeroBuono=StringUtils.checkNull(buonoVO.getNumeroBuono());
     if (SolmrConstants.NUMERO_BLOCCO.equals(numeroBlocco) &&
     SolmrConstants.NUMERO_BUONO.equals(numeroBuono))
     {
       error = new ValidationError(UmaErrors.ERR_ELIMINAZIONE_BUONO_999);
       errors = new ValidationErrors();
       errors.add("error", error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
       return;
     }
     if(buonoVO.getAnnullato()!=null && buonoVO.getAnnullato().equals(SolmrConstants.FLAG_SI)){
       error = new ValidationError(""+UmaErrors.get("BUONO_PRELIEVO_ANNULLATO"));
       errors = new ValidationErrors();
       errors.add("error", error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
       return;
     }
     request.setAttribute("idBuono", idBuonoPrelievo);
     request.setAttribute("azione", "annulla");
     session.setAttribute("buonoVO", buonoVO);
     
     client.isDittaUmaBloccata(dittaUMAAziendaVO.getIdDittaUMA());
   }
   catch (SolmrException ex) {
     if(buonoVO.getAnnullato()!=null && buonoVO.getAnnullato().equals(SolmrConstants.FLAG_SI)){
       error = new ValidationError(""+UmaErrors.get("BUONO_PRELIEVO_ANNULLATO"));
       errors = new ValidationErrors();
       errors.add("error", error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
       return;
     }
   }
   try {
     bloccoVO = client.getDettaglioBlocco(dittaUMAAziendaVO.getIdDittaUMA());
   }
   catch (SolmrException ex) {
     error = new ValidationError(ex.getMessage());
     errors = new ValidationErrors();
     errors.add("error", error);
     request.setAttribute("errors", errors);
     request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
     return;
   }
   if(bloccoVO!=null){
     error = new ValidationError(""+UmaErrors.get("DITTA_BLOCCATA"));
     errors = new ValidationErrors();
     errors.add("error", error);
     request.setAttribute("errors", errors);
     request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
     return;
   }

   //061220 - Gestione annullamento buoni da parte PA - Begin
   String ANNULLA_BUONO_PA = "annullaBuonoPA";
   request.setAttribute(ANNULLA_BUONO_PA, ANNULLA_BUONO_PA);
   //061220 - Gestione annullamento buoni da parte PA - End   
   url = "/domass/layout/confermaBuono.htm";
 }

 else if(request.getParameter("operazione")!= null && request.getParameter("operazione").equals("elimina")){
   SolmrLogger.debug(this, "Entro in cancella");
   Long idDomAss = null;
   buonoVO = (BuonoPrelievoVO)session.getAttribute("buonoVO");
   //Codice con problemi - annulla la restituzione dell'ultimo buono di cui si
   //è visto il dettaglio, se l'utente esce dal sistema senza pasare dalla voce di
   //menù buoni di prelievo
   //if(buonoVO!=null){
     //idBuonoPrelievo = buonoVO.getIdBuonoPrelievo();
     //idDomAss = buonoVO.getIdDomandaAssegnazione();
   //}
   //else{
     //if(request.getParameter("radiobuttonPrelievo")!=null){
       //idBuonoPrelievo = new Long(request.getParameter("radiobuttonPrelievo"));
     //}
     //idDomAss = new Long(request.getParameter("select"));
   //}
   if(request.getParameter("radiobuttonPrelievo")!=null&&request.getParameter("select")!=null){
     idBuonoPrelievo = new Long(request.getParameter("radiobuttonPrelievo"));
     idDomAss = new Long(request.getParameter("select"));
   }
   else {
     idBuonoPrelievo = buonoVO.getIdBuonoPrelievo();
     idDomAss = buonoVO.getIdDomandaAssegnazione();
   }
   request.setAttribute("idBuono", idBuonoPrelievo);
   SolmrLogger.debug(this, "Valore di idBuonoPrelievo "+idBuonoPrelievo);
   request.setAttribute("idDomAss", idDomAss);
   SolmrLogger.debug(this, "Valore di idDomAss "+idDomAss);
   request.setAttribute("azione", "cancella restituzione");
   try {
     v_buoni = client.findBuonoPrelievo(idDomAss);
     request.setAttribute("v_buoni", v_buoni);
   }
   catch (SolmrException ex) {
     error = new ValidationError(ex.getMessage());
     errors = new ValidationErrors();
     errors.add("error", error);
     request.setAttribute("errors", errors);
     request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
     return;
   }

   try {
     client.rilanciaErroreSeEsisteDomandaBaseOAccontoAnnoSuccessivo(idDomAss, dittaUMAAziendaVO.getIdDittaUMA());
   }
   catch (SolmrException ex) {
     error = new ValidationError(ex.getMessage());
     errors = new ValidationErrors();
     errors.add("error", error);
     request.setAttribute("errors", errors);
     request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
     return;
   }
   try {
     bloccoVO = client.getDettaglioBlocco(dittaUMAAziendaVO.getIdDittaUMA());
   }
   catch (SolmrException ex) {
     error = new ValidationError(ex.getMessage());
     errors = new ValidationErrors();
     errors.add("error", error);
     request.setAttribute("errors", errors);
     request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
     return;
   }
   if(bloccoVO!=null){
     error = new ValidationError(""+UmaErrors.get("DITTA_BLOCCATA"));
     errors = new ValidationErrors();
     errors.add("error", error);
     request.setAttribute("errors", errors);
     request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
     return;
   }
   
   //18-11-2008 - Nick - CU-GUMA-15 gestione buoni emessi.        
   BuonoPrelievoVO buonoCtrlVO = null;    
   String strDataRiferimento = client.getParametro(SolmrConstants.PARAMETRO_DTBP);    
   Date dataRiferimento = DateUtils.parseDate(strDataRiferimento);
         
   if (v_buoni != null) {
       Iterator i = v_buoni.iterator();
       boolean ok=false;
   	   while(i.hasNext()){
   	   		 buonoCtrlVO = new BuonoPrelievoVO();
       		 buonoCtrlVO = (BuonoPrelievoVO)i.next();
       		 if (!idBuonoPrelievo.equals(buonoCtrlVO.getIdBuonoPrelievo()))
       		 {
       		   continue;
       		 }
       		 ok=true;
       		 if (buonoCtrlVO.getDataRestituzione()==null)
           {
            error = new ValidationError(UmaErrors.PRELIEVO_NON_ESISTENTE);
            errors = new ValidationErrors();
            errors.add("error", error);
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
            return;
           }      
       		 if (buonoCtrlVO.getDataEmissione().after(dataRiferimento) && buonoCtrlVO.getNumeroBlocco().longValue() != 99999  && buonoCtrlVO.getQtaPrelevata().longValue() > 0) {
       		   
       		   Date nextDate=CustomDateUtils.getNextDate(CustomDateUtils.getDateParameter(SolmrConstants.PARAMETRO_DTBP,client,true));
       		   String nextDateStr=DateUtils.formatDate(nextDate);
       		 	 error = new ValidationError(
       		 	   UmaErrors.ERR_CANCELLAZIONE_RESTITUZIONE_BUONO_CAUSA_PRELIEVO_NEWMA_BEGIN
       		 	   +nextDateStr+ UmaErrors.ERR_CANCELLAZIONE_RESTITUZIONE_BUONO_CAUSA_PRELIEVO_NEWMA_END);
			     errors = new ValidationErrors();
			     errors.add("error", error);
			     request.setAttribute("errors", errors);
			     request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
			     return;
       		 }
       }
       if (!ok)
       {
           errors = new ValidationErrors();
           error = new ValidationError("Errore: dati incongruenti. Si prega di ricaricare la pagina di elenco buoni");
           errors.add("error", error);
           request.setAttribute("errors", errors);
           request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
           return;
       }	
   }
   /////////

   url = "/domass/layout/confermaBuono.htm";
   /*request.setAttribute("idBuono", idBuonoPrelievo);
   SolmrLogger.debug(this, "Valore di idBuonoPrelievo "+idBuonoPrelievo);
   request.setAttribute("idDomAss", idDomAss);
   SolmrLogger.debug(this, "Valore di idDomAss "+idDomAss);
   request.setAttribute("azione", "cancella restituzione");*/
 }

 if(request.getParameter("confermaOperazione")!=null){
   SolmrLogger.debug(this, "Entro in ConfermaOperazione");
   idBuonoPrelievo = new Long(request.getParameter("idBuono"));
   Long idDomAss = new Long(request.getParameter("idDomAss"));
   request.setAttribute("idDomAss", idDomAss);
   
   if(request.getParameter("azione").equals("cancella restituzione")){
     SolmrLogger.debug(this, "Entro in operazione cancella restituzione");
     try {          
       client.annullaRestituzioneBuono(idBuonoPrelievo, ruoloUtenza);  //OK c'era profiloUtenza
 
       SolmrLogger.debug(this, "Ho annullato la restituzione del buono......");
       v_buoni = client.findBuonoPrelievo(idDomAss);
       request.setAttribute("v_buoni",v_buoni);
       msg = ""+UmaErrors.get("BUONO_PRELIEVO_CANCELLA_REST_OK");
       request.setAttribute("msg", msg);
     }
     catch (SolmrException ex) {
       SolmrLogger.debug(this, "ERRRRRORE "+ex);
       v_buoni = client.findBuonoPrelievo(idDomAss);
       request.setAttribute("v_buoni",v_buoni);
       error = new ValidationError(ex.getMessage());
       errors = new ValidationErrors();
       errors.add("error", error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher("../../domass/view/buoniPrelievoView.jsp").forward(request, response);
       return;
     }
   }
   else if(request.getParameter("azione").equals("annulla")){
     SolmrLogger.debug(this, "Entro in operazione annulla");
     try {         
       client.annullaBuono(idBuonoPrelievo,ruoloUtenza);  //ok c'era profiloUtenza
              
       SolmrLogger.debug(this, "Ho annullato il buono......");
       
       v_buoni = client.findBuonoPrelievo(idDomAss);
       request.setAttribute("v_buoni",v_buoni);
       
       msg = UmaErrors.BUONO_PRELIEVO_ANNULLATO_OK;
       request.setAttribute("msg", msg);

     }
     catch (Exception ex) {
       SolmrLogger.debug(this, "ERRRRRORE "+ex);
       error = new ValidationError(ex.getMessage());
       errors = new ValidationErrors();
       errors.add("error", error);
       v_buoni = client.findBuonoPrelievo(idDomAss);
       request.setAttribute("v_buoni",v_buoni);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher("../../domass/view/buoniPrelievoView.jsp").forward(request, response);
       return;
     }
   }
 }


 // Se ho cliccato sul link "Buoni di prelievo" faccio
 // vedere gli eventuali buoni legati alla ditta per
 // quella domanda assegnazione...
 else if (request.getParameter("buoniPrelievo")!=null){
   SolmrLogger.debug(this, "Entro in buoni prelievo");
   Long idDomAss = new Long(request.getParameter("select"));
   SolmrLogger.debug(this, " ::::: ID DOM ASSSSSSSS "+idDomAss);
   request.setAttribute("idDomAss", idDomAss);
     try {
       v_buoni = client.findBuonoPrelievo(idDomAss);

       request.setAttribute("v_buoni",v_buoni);
     }
     catch (SolmrException ex) {
       SolmrLogger.debug(this, "Eccc..." +ex+" - "+ex.getMessage());
       if (errors == null) {
         errors = new ValidationErrors();
         error = new ValidationError(ex.getMessage());
         errors.add("error", error);
       }
       request.setAttribute("errors", errors);
       request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
       return;
     }
 }
 else if(request.getAttribute("comeBack")!=null){
   SolmrLogger.debug(this, "comeBack ok");
   buonoVO = (BuonoPrelievoVO)session.getAttribute("buonoVO");
   Long idDomAss = null;
   if(request.getParameter("idDomAss")!=null){
     SolmrLogger.debug(this, "idDomass in request");
     idDomAss = new Long(request.getParameter("idDomAss"));
   }
   else{
     SolmrLogger.debug(this, "idDomAss da VO");
     idDomAss = buonoVO.getIdDomandaAssegnazione();
   }
   session.removeAttribute("buonoVO");
   SolmrLogger.debug(this, " ::::: ID DOM ASSSSSSSS "+idDomAss);
   request.setAttribute("idDomAss", idDomAss);
     try {
       v_buoni = client.findBuonoPrelievo(idDomAss);
       SolmrLogger.debug(this, "In comeBack valore di v_buoni..."+v_buoni);
       request.setAttribute("v_buoni",v_buoni);
     }
     catch (SolmrException ex) {
       SolmrLogger.debug(this, "Eccc..." +ex+" - "+ex.getMessage());
       error = new ValidationError(ex.getMessage());
       errors = new ValidationErrors();
       errors.add("error", error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher("/domass/view/buoniPrelievoView.jsp").forward(request, response);
       return;
     }
 }
 // Non ho pigiato alcun pulsante, ergo entro per la prima volta....
 // NON E' VERO: POSSO ANCHE AVER PIGIATO IL BOTTONE ANNULLA DALLA PAGINA DI
 // DETTAGLIO DI UN BUONO
 else{
   if(request.getParameter("operazione")== null) {
     // Carico la combo con le domande
     // assegnazione legate alle ditte
     SolmrLogger.debug(this, "Entro per la 1a volta");
     session.removeAttribute("v_domass");
     try {
       v_domass = client.findDomAssByIdDittaUma(dittaUMAAziendaVO.getIdDittaUMA());
       if(v_domass!=null&&v_domass.size()!=0)
         session.setAttribute("v_domass", v_domass);
       else{
         error = new ValidationError(""+UmaErrors.get("DOMANDA_ASSEGNAZIONE_NON_ESISTE_PER_PRELIEVO"));
         SolmrLogger.debug(this, "Valore della ValidationErrors "+errors);
         if (errors == null)
           errors = new ValidationErrors();
         else {
           Iterator iter = errors.get("error");
           while (iter.hasNext()) {
             error = (ValidationError)iter.next();
           }
         }
         errors.add("error", error);
         request.setAttribute("errors", errors);
         request.getRequestDispatcher("../../anag/view/dettaglioAziendaView.jsp").forward(request, response);
         return;
       }
     }
     catch (SolmrException ex) {
       SolmrLogger.debug(this, "ERRRRRORE "+ex);
       error = new ValidationError(ex.getMessage());
       errors = new ValidationErrors();
       errors.add("error", error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher("../../anag/view/dettaglioAziendaView.jsp").forward(request, response);
       return;
     }
     // Carico i buoni prelievi legati alla prima domanda assegnazione
     // (l'ultima in ordine di tempo)
     Long idDomAss = ((DomandaAssegnazione)v_domass.get(0)).getIdDomandaAssegnazione();
     try{
       v_buoni = client.findBuonoPrelievo(idDomAss);
       request.setAttribute("v_buoni",v_buoni);
       request.setAttribute("idDomAss", idDomAss);
     }
     catch (SolmrException ex) {
       SolmrLogger.debug(this, "ERRRRRORE "+ex);
       error = new ValidationError(ex.getMessage());
       errors = new ValidationErrors();
       errors.add("error", error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher("../../domass/view/buoniPrelievoView.jsp").forward(request, response);
       return;
     }
   }
 }
 SolmrLogger.debug(this, "URLLLLLLL???? "+url);

 SolmrLogger.debug(this, "buoniPrelievoCtrl.jsp - End");
%>
<jsp:forward page="<%=url%>"/>