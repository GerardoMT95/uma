<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.anag.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%!
 private static final String ATTENDERE="../view/nuovaDittaUmaAttendereView.jsp";
%>

<%


  String iridePageName = "nuovaDittaUmaDatiIdentificativiCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%



 String validateUrl = "/ditta/view/nuovaDittaUmaDatiIdentificativiView.jsp";

 String annullaUrl = "/ditta/view/nuovaDittaUmaAnagraficaView.jsp";

 String confermaUrl = "/ditta/view/nuovaDittaUmaConfermaInserimentoView.jsp";



 RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");



 UmaFacadeClient umaClient = new UmaFacadeClient();

 AnagFacadeClient anagFacadeClient = new AnagFacadeClient();

 AnagAziendaVO anagAziendaVO = (AnagAziendaVO)session.getAttribute("anagAziendaVO");



 if(request.getParameter("salva") != null) {

   // Recupero i parametri

   String dataIscrizione = request.getParameter("dataIscrizione");

   String provinciaAppartenenza = null;

   if(ruoloUtenza.isUtenteProvinciale()) {

     provinciaAppartenenza = request.getParameter("ente");

   }

   else {

     provinciaAppartenenza = request.getParameter("provinceRegione");

   }

   String descComunePrincipaleAttivita = request.getParameter("descComune");

   String provincia = request.getParameter("siglaProvinceTOBECONFIGsi");

   String tipoConduzione = request.getParameter("tipiConduzione");

   String indirizzoConsegna = request.getParameter("indirizzoConsegna");

   String noteDitta = request.getParameter("noteDitta");

   // Creo il Value Object

   DittaUMAVO dittaUmaVO = new DittaUMAVO();

   // Setto i parametri

   dittaUmaVO.setStringaDataIscrizione(dataIscrizione);

   dittaUmaVO.setExtProvinciaUMA(provinciaAppartenenza);

   dittaUmaVO.setDescComunePrincipaleAttivita(descComunePrincipaleAttivita);

   dittaUmaVO.setTipiConduzione(tipoConduzione);

   dittaUmaVO.setProvincia(provincia);

   ValidationErrors errors = dittaUmaVO.validate();

   // Check sulla data creazione > data cessazione ditta uma provenienza

   if (errors==null || errors.get("dataIscrizione")==null)
   {
     Object commonObj=session.getAttribute("common");
     DittaUMAVO duVO=null;
     if (commonObj!=null && commonObj instanceof HashMap)
     {
       HashMap common=(HashMap)commonObj;
       duVO=(DittaUMAVO)common.get("dittaUmaVO");
       if (duVO!=null)
       {
         // Elimino ore/minuti/secondi per il confronto con le date
         Date dataCessazione=DateUtils.parseDate(DateUtils.formatDate(duVO.getDataCessazione()));
         if (dataCessazione.after(dittaUmaVO.getDataIscrizione()))
         {
           if (errors==null)
           {
             errors=new ValidationErrors();
           }
           errors.add("dataIscrizione", new ValidationError((String)UmaErrors.get("DATA_ISCRIZIONE_PRECEDENTE_DATA_CESSAZIONE")));
         }
       }
     }
   }


   if (ruoloUtenza.isUtenteIntermediario()&&!Validator.isNotEmpty(provinciaAppartenenza))

 errors.add("provinceTOBECONFIG", new ValidationError((String)UmaErrors.get("ERR_PROVINCIA_COMPETENZA_OBBLIGATORIA")));



   String provinciaComune = null;

   Vector elencoProvince = null;

   try {

     elencoProvince = umaClient.getSiglaProvinceTOBECONFIGsi();

   }

   catch(SolmrException se) {

     ValidationError error = new ValidationError(se.getMessage());

     errors.add("error", error);

     request.setAttribute("errors", errors);

     request.getRequestDispatcher(validateUrl).forward(request, response);

     return;

   }



   Iterator iteraProvince = elencoProvince.iterator();

   while(iteraProvince.hasNext()) {

     StringcodeDescription code = (StringcodeDescription)iteraProvince.next();

     if(code.getCode().equals(provincia)) {

       provinciaComune = code.getDescription();

     }

   }

   String istatComune = null;

   if(descComunePrincipaleAttivita != null && !descComunePrincipaleAttivita.equals("")) {

     try {

       istatComune = anagFacadeClient.ricercaCodiceComuneNonEstinto(descComunePrincipaleAttivita, provinciaComune);

     }

     catch(SolmrException se) {

       ValidationError error = new ValidationError(UmaErrors.ERR_COMUNE_ATTIVITA_ERRATO);

       errors.add("descComunePrincipaleAttivita",error);

     }

   }

   if(tipoConduzione != null && !tipoConduzione.equals("")) {

     dittaUmaVO.setIdConduzione(Long.decode(tipoConduzione));

   }

   dittaUmaVO.setTipiConduzione(tipoConduzione);

   if(ruoloUtenza.isUtenteProvinciale()) {

     dittaUmaVO.setExtProvinciaUMA(ruoloUtenza.getIstatProvincia());

   }

   if(errors != null && errors.size() != 0) {

     request.setAttribute("errors", errors);

     request.getRequestDispatcher(validateUrl).forward(request, response);

     return;

   }

   if(descComunePrincipaleAttivita != null && !descComunePrincipaleAttivita.equals("")

      && provincia != null && !provincia.equals("")) {

     boolean result = false;

     try {

       result = umaClient.isComuneRegioneDiCompetenza(istatComune,provincia);

     }

     catch(SolmrException se) {

       ValidationError error = new ValidationError(se.getMessage());

       errors.add("descComunePrincipaleAttivita",error);

       request.setAttribute("errors", errors);

       request.getRequestDispatcher(validateUrl).forward(request, response);

       return;

     }

     if(!result) {

       ValidationError error = new ValidationError(UmaErrors.ERR_COMUNE_ATTIVITA_NO_TOBECONFIGSE);

       errors.add("descComunePrincipaleAttivita",error);

       request.setAttribute("errors", errors);

       request.getRequestDispatcher(validateUrl).forward(request, response);

       return;

     }

   }

   dittaUmaVO.setExtIdAzienda(anagAziendaVO.getIdAzienda());

   dittaUmaVO.setTipoDitta(SolmrConstants.TIPODITTAUMA);

   dittaUmaVO.setExtComunePrincipaleAttivita(istatComune);

   dittaUmaVO.setIndirizzoConsegna(indirizzoConsegna);

   dittaUmaVO.setNoteDitta(noteDitta);

   dittaUmaVO.setRuoloUtenza(ruoloUtenza);





   // Non deve esistere già una ditta UMA attiva associata all'azienda agriocola trovata

   try {

     umaClient.isDittaUmaInseribile(dittaUmaVO.getExtIdAzienda());

   }

   catch(SolmrException se) {

     SolmrLogger.debug(this,"Entro nel catch!!!!!!!!!!!!!!!!!!!!!!");

     ValidationError error = new ValidationError(se.getMessage());

     errors.add("error", error);

     request.setAttribute("errors", errors);

     request.getRequestDispatcher(validateUrl).forward(request, response);

     return;

   }



   //Forward sulla pagina ATTENDERE PREGO...
   request.setAttribute("dittaUmaVO",dittaUmaVO);
   %>

      <jsp:forward page = "<%= ATTENDERE %>" />

   <%

 }

 if(request.getParameter("annulla") != null) {

   session.removeAttribute("anagAziendaVO");

   %>

      <jsp:forward page = "<%= annullaUrl %>" />

   <%

 }



%>



