<%@ page language="java" contentType="text/html"%>

<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.etc.uma.*"%>
<%@ page import="it.csi.solmr.etc.SolmrConstants"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.rmi.RemoteException"%>
<%@ page import="java.sql.Timestamp"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%
	// Se c'è un errore torno indietro di 2 pagine
	request.setAttribute("historyNum", "-2");
	String iridePageName = "assegnazioneSupplementareCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%

    SolmrLogger.debug(this, "   BEGIN assegnazioneSupplementareCtrl");
    
	ValidationErrors errors = new ValidationErrors();
	UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
	RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

	String url = "/domass/view/assegnazioneSupplementareView.jsp";
	String calcoloAutomaticoFOUrl = "/domass/ctrl/calcoloAutomaticoFOAssSupplCtrl.jsp";
	String calcoloAutomaticoBOUrl = "/domass/ctrl/calcoloAutomaticoBOAssSupplCtrl.jsp";
	String dettaglioDomandaUrl = "/domass/ctrl/dettaglioAssegnazioniSupplementariCtrl.jsp";
	String verificaAssegnazioneUrl = "/domass/ctrl/verificaAssegnazioneSupplementareSalvataBOCtrl.jsp";
	String verificaAssegnazioneValidataUrl = "/domass/ctrl/verificaAssegnazioneSupplementareValidataSupplCtrl.jsp";

	//da rimuovere - solo per test

	Long idDomAss = null;
	Long idDomAssAnnoInCorso;

	DittaUMAAziendaVO dumaa = (DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
	Long idDittaUma = dumaa.getIdDittaUMA();	
	SolmrLogger.debug(this, "idDittaUma: " + idDittaUma);	

	if (request.getParameter("conferma.x") != null) {
		SolmrLogger.debug(this, "\\\\\\\\\\Conferma");
		try {
			SolmrLogger.debug(this, "-- isUtenteIntermediario ="+ruoloUtenza.isUtenteIntermediario());
			SolmrLogger.debug(this, "-- isUtenteTitolareCf ="+ruoloUtenza.isUtenteTitolareCf());
			if (ruoloUtenza.isUtenteIntermediario() || ruoloUtenza.isUtenteTitolareCf()) {
				SolmrLogger.debug(this, " ********* calcoloAutomaticoFOUrl: "+ calcoloAutomaticoFOUrl);
				%>
				<jsp:forward page="<%=calcoloAutomaticoFOUrl%>" />
				<%
			}
			else {
				SolmrLogger.debug(this, "*********** calcoloAutomaticoBOUrl: "+ calcoloAutomaticoBOUrl);
			%>
			<jsp:forward page="<%=calcoloAutomaticoBOUrl%>" />

			<%
  		   }
    }
	catch (Exception se){
     ValidationError error = new ValidationError(se.getMessage());
     errors.add("error", error);
	 request.setAttribute("errors", errors);
	 request.getRequestDispatcher(url).forward(request, response);
	 return;
	}
  }
  if (request.getParameter("avanti.x") != null){
	SolmrLogger.debug(this, "--- CASO Avanti");
	SolmrLogger.debug(this, " -- Sto andando su: "+ verificaAssegnazioneUrl);
	
	// Se siamo nel caso di Assegnazione supplementare ancora da validare dalla PA : numeroSupplemento è valorizzato
	String numeroSupplemento = request.getParameter("numeroSupplemento");
	SolmrLogger.debug(this, "-- numeroSupplemento ="+numeroSupplemento);
	if(numeroSupplemento != null && !numeroSupplemento.equals(""))
	  request.setAttribute("numeroSupplemento", new Long(numeroSupplemento));
	  
%><jsp:forward page="<%=verificaAssegnazioneUrl%>" />
<%
	return;
	}
	else {
		SolmrLogger.debug(this, "\\\\\\\\\\Visualizza pulsanti");
		try {
			request.setAttribute("idDittaUma", idDittaUma);

			SolmrLogger.debug(this," ------ Controlli assegnazioneSupplementare");
			Vector result = umaFacadeClient.assegnazioneSupplementare(dumaa.getIdDittaUMA(), ruoloUtenza);
			
			/* Elemeti tornati in result :
			   result.addElement(conferma); // 0
               result.addElement(msgFinale); // 1
               result.addElement(idDomAssAnnoInCorso); // 2
        
              if(numeroSupplemento != null)
                result.addElement(numeroSupplemento); // 3
			*/			

			// devo creare un segnaposto al posto del testo e devo inserire
			// il testo che mi ritorna il metodo di business,
			// in base al valore restituito devo aggiungere un pulsante
			idDomAssAnnoInCorso = (Long) result.get(2);
			SolmrLogger.debug(this, "--- idDomAssAnnoInCorso ="+idDomAssAnnoInCorso);

			//Carica ultima idDomAss presentata per la ditta Uma
			if (idDomAssAnnoInCorso != null) {
				idDomAss = idDomAssAnnoInCorso;
			}

			request.setAttribute("resultVerificaAssegnazione", result);
			request.setAttribute("idDomAss", idDomAss);
			SolmrLogger.debug(this, "idDomAss: " + idDomAss);			
		}

		catch (SolmrException se){
			SolmrLogger.error(this, "Catch Visualizza pulsanti ="+se.getMessage());
			writeModificaIntermediario(umaFacadeClient, idDittaUma,request, session);
			throwValidation(se.getMessage(), url);
			request.setAttribute("errors", errors);
%>
<jsp:forward page="<%=url%>" />
<%
	return;
		}
	}	
	writeModificaIntermediario(umaFacadeClient, idDittaUma, request,session);
%>
<jsp:forward page="<%=url%>" />
<%
	SolmrLogger.debug(this, "  END assegnazioneSupplementareCtrl");
%>

<%!private void throwValidation(String msg, String validateUrl)
			throws ValidationException

	{

		ValidationException valEx = new ValidationException(
				"Errore: eccezione=" + msg, validateUrl);

		valEx.addMessage(msg, "exception");

		throw valEx;

	}%>

<%!private void writeModificaIntermediario(UmaFacadeClient umaFacadeClient,

	Long idDittaUma,

	HttpServletRequest request,

	HttpSession session) throws SolmrException

	{

		try

		{

			SolmrLogger.debug(this, "writeModificaIntermediario()");

			//UMA2 - Begin
			DatiModificatiIntermediarioVO dmiVO = null;
			dmiVO = umaFacadeClient.getDatiModificatiInteremediario(idDittaUma);
			/*Date dataInizioGestioneFascicolo = (Date) session.getAttribute("dataInizioGestioneFascicolo");
			Date toDay = new Date();
			if (toDay.after(dataInizioGestioneFascicolo)){
			  //Elimina la visualizzazione delle superfici non conformi con contratti affitto scaduti
			  SolmrLogger.debug(this, "if (toDay.after(dataInizioGestioneFascicolo))");
			}else{
			  SolmrLogger.debug(this, "else (toDay.after(dataInizioGestioneFascicolo))");
			  dmiVO=umaFacadeClient.getDatiModificatiInteremediario(idDittaUma);
			}*/
			//UMA2 - End

			SolmrLogger.debug(this, "dmiVO=" + dmiVO);

			request.setAttribute("datiModificatiIntermediarioVO", dmiVO);

		}

		catch (Exception e)

		{

			SolmrLogger.error(this, "errore=" + e.getMessage());

			ValidationErrors errors = new ValidationErrors();

			errors.add("error", new ValidationError(e.getMessage()));

			request.setAttribute("errors", errors);

		}

	}%>



