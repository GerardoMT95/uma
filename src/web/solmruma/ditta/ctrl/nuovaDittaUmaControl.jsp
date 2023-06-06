 <%@ page language="java"
     contentType="text/html"
     isErrorPage="true"
 %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
  String iridePageName = "nuovaDittaUmaControl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%



  String validateUrl = "/uma/ditta/view/nuovaDittaUmaView.jsp";
  String annullaUrl = "/uma/anag/view/dettaglioAziendaView.jsp";

  UmaFacadeClient umaClient = new UmaFacadeClient();

  AnagFacadeClient anagFacadeClient = new AnagFacadeClient();

  Validator validator = new Validator(validateUrl);

  ValidationException valEx = null;

  if(request.getParameter("conferma.x") != null) {
    // Recupero i parametri
    String dataIscrizione = request.getParameter("dataIscrizione");
    String istatProvinciaCompetenza = request.getParameter("provinciaCompetenza");
    Long idConduzioneAzienda = null;
    if(request.getParameter("tipiConduzione") != null && !request.getParameter("tipiConduzione").equals("")) {
      idConduzioneAzienda = Long.decode(request.getParameter("tipiConduzione"));
    }
    String istatComunePrincipaleAttivita = request.getParameter("istatComune");
    String identificativoAzienda = request.getParameter("idAzienda");
    Long idAzienda = Long.decode(identificativoAzienda);
    String comunePrincipaleAttivita = request.getParameter("comune");
    String provincia = request.getParameter("provincia");
    // Creo il Value Object
    DittaUMAVO dittaUma = new DittaUMAVO();
    // Setto i parametri
    dittaUma.setExtIdAzienda(idAzienda);
    dittaUma.setStringaDataIscrizione(dataIscrizione);
    dittaUma.setExtProvinciaUMA(istatProvinciaCompetenza);
    dittaUma.setIdConduzione(idConduzioneAzienda);
    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
    dittaUma.setRuoloUtenza(ruoloUtenza);
    dittaUma.setProvinciaComuneAttivita(provincia);
    dittaUma.setDescComunePrincipaleAttivita(comunePrincipaleAttivita);
    session.setAttribute("dittaUma",dittaUma);
    // Effettuo il controllo relativo alla correttezza dei dati inseriti dall'utente
    ValidationErrors errors = dittaUma.validate();
    try {
      istatComunePrincipaleAttivita = anagFacadeClient.ricercaCodiceComune(comunePrincipaleAttivita, provincia);
      dittaUma.setExtComunePrincipaleAttivita(istatComunePrincipaleAttivita);
    }
    catch(SolmrException se) {
      ValidationError error = new ValidationError(se.getMessage());
      errors.add("extComunePrincipaleAttivita", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(validateUrl).forward(request, response);
    }

    if(errors != null && errors.size() != 0) {
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(validateUrl).forward(request, response);
      return;
    }




    // Non deve esistere già una ditta UMA attiva associata all'azienda agriocola trovata
    try {
      umaClient.isDittaUmaInseribile(dittaUma.getExtIdAzienda());
    }
    catch(SolmrException se) {
      ValidationError error = new ValidationError(se.getMessage());
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(validateUrl).forward(request, response);
    }







    // Inserisco la nuova Ditta UMA
    long primaryKey = 0;
    String dataIscrizioneDitta = DateUtils.formatDate(dittaUma.getDataIscrizione());
    dittaUma.setDataIscrizione(DateUtils.parseDate(dataIscrizioneDitta));
    try {
      primaryKey = umaClient.insertDittaUMA(dittaUma);
    }
    catch(SolmrException se) {
      ValidationError error = new ValidationError(se.getMessage());
      if(se.getMessage().equalsIgnoreCase(""+UmaErrors.get("DATAISCRIZIONEERRATA"))) {
        errors.add("dataIscrizione",error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(validateUrl).forward(request, response);
        return;
      }
      else {
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(validateUrl).forward(request, response);
        return;
      }
    }

    AnagAziendaVO anagAziendaVO = null;
    // Riprelevo i dati della ditta anagrafica a cui è associata la nuova ditta Uma inserita
    try {
      anagAziendaVO = umaClient.selezionaAzienda(idAzienda);
    }
    catch(SolmrException se) {
      ValidationError error = new ValidationError("Si è verificato un errore durante la ricerca dei dati della ditta anagrafica"+
                                                  "a cui è associata la nuova ditta UMA inserita!");
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(validateUrl).forward(request, response);
    }
    // Recupero i dati della nuova ditta UMA inserita
    try {
      dittaUma = umaClient.findByPrimaryKey(new Long(primaryKey));
    }
    catch(SolmrException se) {
      ValidationError error = new ValidationError(""+UmaErrors.get("ERRORE_RECUPERO_DATI"));
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(validateUrl).forward(request, response);
    }
    // Setto i nuovi dati in sessione e forwardo alla pagina di visualizzazione
    session.removeAttribute("anagAziendaVO");
    session.removeAttribute("dittaUma");
    session.setAttribute("anagAziendaVO",anagAziendaVO);
    session.setAttribute("dittaUma",dittaUma);
    session.setAttribute("ins","ok");
    %>
       <jsp:forward page = "/uma/ditta/view/numeroDittaUmaView.jsp" />
    <%
    return;
  }
  if(request.getParameter("chiudi.x") != null) {
    session.removeAttribute("anagAziendaVO");
    %>
       <jsp:forward page = "/uma/anag/view/dettaglioAziendaView.jsp" />
    <%
    return;
  }

%><jsp:forward page = "/ditta/view/nuovaDittaUmaView.jsp" />

