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

  String iridePageName = "nuovoBloccoCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


 SolmrLogger.debug(this,"- nuovoBloccoCtrl.jsp -  INIZIO PAGINA");

 DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

 RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
 UmaFacadeClient client = new UmaFacadeClient();

 ValidationError error = null;

 ValidationErrors errors = null;

 BloccoDittaVO bloccoVO = null;

 String url = "/ditta/layout/elencoBlocchi.htm";

 //Correzione Blocco Ditta 22/11/2004 - Begin

 //if(request.getParameter("conferma") != null&&session.getAttribute("check")==null){

 //Correzione Blocco Ditta 22/11/2004 - End
 if("conferma".equals(request.getParameter("conferma")))
 {

   SolmrLogger.debug(this,"URL in conferma nuovoBloccoCtrl??? "+url);

   bloccoVO = new BloccoDittaVO();

   bloccoVO.setDataBlocco(DateUtils.parseDate(request.getParameter("dataBlocco")));

   //bloccoVO.setIdDittaUma(dittaUma.getIdDitta());

   bloccoVO.setIdDittaUma(dittaUMAAziendaVO.getIdDittaUMA());

   bloccoVO.setIdUtenteBlocco(ruoloUtenza.getIdUtente());

   bloccoVO.setNote(request.getParameter("note"));

   try {

     client.insertBlocco(bloccoVO);

     //051215 Imposta la visualizzazione del blocco importa dati in LayoutWriter - Begin
     session.setAttribute("gestioneImportaDati", new Boolean(true));
     //051215 Imposta la visualizzazione del blocco importa dati in LayoutWriter - End


     //Correzione Blocco Ditta 22/11/2004 - Begin

     //session.removeAttribute("v_blocchi");

     //Correzione Blocco Ditta 19/11/2004 - End

     //051215 Imposta la visualizzazione del blocco importa dati in LayoutWriter - Begin
     session.setAttribute("gestioneImportaDati", new Boolean(true));
     //051215 Imposta la visualizzazione del blocco importa dati in LayoutWriter - End

   }

   catch (SolmrException ex) {

     /*valEx = new ValidationException(ex.getMessage(), "/ditta/view/nuovoBloccoView.jsp");

     valEx.addMessage(ex.getMessage(),"exc");

     throw valEx;*/

     error=new ValidationError(ex.getMessage());

     errors = new ValidationErrors();

     errors.add("error", error);

     request.setAttribute("errors", errors);

     request.getRequestDispatcher("/ditta/view/nuovoBloccoView.jsp").forward(request, response);

     return;

   }

   //Correzione Blocco Ditta 19/11/2004 - Begin

   //session.setAttribute("check","ok");

   //Correzione Blocco Ditta 19/11/2004 - End

 }



 else if(request.getParameter("annulla") != null){

   url = "/ditta/view/bloccoDittaView.jsp";

 }

 //Correzione Blocco Ditta 19/11/2004 - Begin

 /*else if(session.getAttribute("check") != null){

   SolmrLogger.debug(this,"else check");

   url = "/ditta/layout/elencoBlocchi.htm";

 }*/

 //Correzione Blocco Ditta 19/11/2004 - End

 else{

  SolmrLogger.debug(this,"nOT ELSE");

  url = "/ditta/view/nuovoBloccoView.jsp";

 }



  SolmrLogger.debug(this,"URLLLLLL da nuovoBloccoCtrl "+url);

  SolmrLogger.debug(this,"- nuovoBloccoCtrl.jsp -  FINE PAGINA");

%>

<jsp:forward page="<%=url%>"/>