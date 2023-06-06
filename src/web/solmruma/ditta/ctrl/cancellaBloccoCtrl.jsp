<%@ page language="java"
         contentType="text/html"
%>

<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%

  String iridePageName = "cancellaBloccoCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


 DittaUMAVO dittaUma = (DittaUMAVO)session.getAttribute("dittaUma");

 RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

 UmaFacadeClient client = new UmaFacadeClient();

 ValidationError error = null;

 ValidationErrors errors = null;

 //session.removeAttribute("bloccoVO");

 BloccoDittaVO bloccoVO = null;

 String url = "/ditta/layout/elencoBlocchi.htm";



 if(request.getParameter("conferma") != null){

   bloccoVO = new BloccoDittaVO();

   SolmrLogger.debug(this,"ID BLOCCO "+request.getParameter("idBloccoDitta"));

   SolmrLogger.debug(this,"DATA SBLOCCO "+request.getParameter("dataSblocco"));

   SolmrLogger.debug(this,"DATA SBLOCCO PARS "+DateUtils.parseDate(request.getParameter("dataSblocco")));

   bloccoVO.setDataSblocco(DateUtils.parseDate(request.getParameter("dataSblocco")));

   bloccoVO.setIdBloccoDitta(new Long(request.getParameter("idBloccoDitta")));

   bloccoVO.setIdUtenteSblocco(ruoloUtenza.getIdUtente());

   try {

     client.updateBlocco(bloccoVO);

     //051212 - Modifica gestione Importa dati in base allo stato ditta e domanda - Begin
     DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
     boolean gestioneImportaDati = false;
     try{
       SolmrLogger.debug(this, "Before - isDittaUmaCessata");
       SolmrLogger.debug(this, "dittaVO.getDataCessazioneUMA(): "+dittaVO.getDataCessazioneUMA());
       if(dittaVO.getDataCessazioneUMA()==null){
         //ditta cessata
         gestioneImportaDati=true;
       }
       else{
         gestioneImportaDati=false;
       }
       SolmrLogger.debug(this, "After dittaVO.getDataCessazioneUMA() - gestioneImportaDati: "+gestioneImportaDati);

       if(gestioneImportaDati){
         BloccoDittaVO bloccoDittaVO = client.getDettaglioBlocco(dittaVO.getIdDittaUMA());
         SolmrLogger.debug(this, "bloccoDittaVO: "+bloccoDittaVO);
         if(bloccoDittaVO==null){
           //ditta non bloccata
           gestioneImportaDati = true;
         }
         else{
           gestioneImportaDati = false;
         }
       }
       SolmrLogger.debug(this, "After checkBlocco - gestioneImportaDati: "+gestioneImportaDati);

       SolmrLogger.debug(this, "Before - statoDomAssFunzPAorInt");
       if(gestioneImportaDati){
         client.statoDomAssFunzPAorInt(dittaVO.getIdDittaUMA(), new Long(DateUtils.getCurrentYear().intValue()), ruoloUtenza);
       }
       SolmrLogger.debug(this, "After - statoDomAssFunzPAorInt");
     }catch(it.csi.solmr.exception.SolmrException sExc){
       //stato della domanda non valido in base al profilo
       gestioneImportaDati=false;
       SolmrLogger.debug(this, "catch - statoDomAssFunzPAorInt");
     }
     SolmrLogger.debug(this, "After controlli - gestioneImportaDati: "+gestioneImportaDati);
     session.setAttribute("gestioneImportaDati", new Boolean(gestioneImportaDati));
     //051212 - Modifica gestione Importa dati in base allo stato ditta e domanda - End


     //session.removeAttribute("v_blocchi");

     //session.removeAttribute("check");

     //Correzione Blocco Ditta 19/11/2004 - End

   }

   catch (SolmrException ex) {

     error=new ValidationError(ex.getMessage());

     errors = new ValidationErrors();

     errors.add("error", error);

     request.setAttribute("errors", errors);

     request.getRequestDispatcher("/ditta/view/cancellaBloccoView.jsp").forward(request, response);

     return;

   }

 }



 else if(request.getParameter("annulla") != null){

   url = "/ditta/ctrl/bloccoDittaCtrl.jsp";

 }

 else

   url = "/ditta/view/cancellaBloccoView.jsp";

  SolmrLogger.debug(this,"URRRRRL "+url);

  SolmrLogger.debug(this,"- cancellaBloccoCtrl.jsp -  FINE PAGINA");

%>

<jsp:forward page="<%=url%>"/>