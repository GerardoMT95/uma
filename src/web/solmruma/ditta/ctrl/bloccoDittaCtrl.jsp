<%@ page language="java"
         contentType="text/html"
%>

<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%

  String iridePageName = "bloccoDittaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

 DittaUMAAziendaVO dittaUma = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

 UmaFacadeClient client = new UmaFacadeClient();

 RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

 Vector v_blocchi = null;

 ValidationException valEx = null;

 ValidationError error = null;

 ValidationErrors errors = null;

 BloccoDittaVO bloccoVO = null;

 String url = "/ditta/view/bloccoDittaView.jsp";


 //Correzione Blocco Ditta 19/11/2004 - Begin

 String provCompetenza = null;

 try{

   /*if(dittaUma.getProvCompetenza()!=null&&!dittaUma.getProvCompetenza().equals("")){

     provCompetenza = client.getProvinciaByIstat(dittaUma.getProvCompetenza());

   }*/

   if(dittaUma.getProvUMA()!=null&&!dittaUma.getProvUMA().equals("")){

        provCompetenza = client.getProvinciaByIstat(dittaUma.getProvUMA());

   }

 }catch(SolmrException ex){

    error=new ValidationError(ex.getMessage());

    errors = new ValidationErrors();

    errors.add("error", error);

    request.setAttribute("errors", errors);

    //request.getRequestDispatcher("/ditta/view/bloccoDittaView.jsp").forward(request, response);

    //return;

 }

 request.setAttribute("provCompetenza", provCompetenza);

 //Correzione Blocco Ditta 19/11/2004 - End

 if(request.getParameter("nuovo") != null){

   url = "/ditta/layout/nuovoBlocco.htm";

   try {

     bloccoVO = client.getDettaglioBlocco(dittaUma.getIdDittaUMA());

     //bloccoVO = client.getDettaglioBlocco(new Long(1));

   }

   catch (SolmrException ex) {

     /*valEx = new ValidationException(ex.getMessage(), "/ditta/view/bloccoDittaView.jsp");

     valEx.addMessage(ex.getMessage(),"exc");

     throw valEx;*/

     error=new ValidationError(ex.getMessage());

     errors = new ValidationErrors();

     errors.add("error", error);

     request.setAttribute("errors", errors);

     url = "/ditta/view/bloccoDittaView.jsp";

     //request.getRequestDispatcher("/ditta/view/bloccoDittaView.jsp").forward(request, response);

     //return;

   }

   if(bloccoVO!=null){

     /*valEx = new ValidationException("Errore nuovo blocco ditta UMA", "/ditta/view/bloccoDittaView.jsp");

     valEx.addMessage(UmaErrors.BLOCCO_ATTIVO,"exc");

     throw valEx;*/

     error=new ValidationError(""+UmaErrors.get("BLOCCO_ATTIVO"));

     errors = new ValidationErrors();

     errors.add("error", error);

     request.setAttribute("errors", errors);

     url = "/ditta/view/bloccoDittaView.jsp";

     //request.getRequestDispatcher("/ditta/view/bloccoDittaView.jsp").forward(request, response);

     //return;

   }

 }



 else if(request.getParameter("cancella") != null){

   url = "/ditta/layout/cancellaBlocco.htm";

   try {

     bloccoVO = client.getDettaglioBlocco(dittaUma.getIdDittaUMA());

   }

   catch (SolmrException ex) {

     error=new ValidationError(ex.getMessage());

     errors = new ValidationErrors();

     errors.add("error", error);

     request.setAttribute("errors", errors);

     url = "/ditta/view/bloccoDittaView.jsp";

     //request.getRequestDispatcher("/ditta/view/bloccoDittaView.jsp").forward(request, response);

     //return;

   }

   SolmrLogger.debug(this,":::: VALORE DEL BLOCCO ::::: "+bloccoVO);

   if(bloccoVO==null){

     /*valEx = new ValidationException("Errore cancella blocco ditta UMA", "/ditta/view/bloccoDittaView.jsp");

     valEx.addMessage(UmaErrors.BLOCCO_NON_PRESENTE,"exc");

     throw valEx;*/

     error=new ValidationError(""+UmaErrors.get("BLOCCO_NON_PRESENTE"));

     errors = new ValidationErrors();

     errors.add("error", error);

     request.setAttribute("errors", errors);

     url = "/ditta/view/bloccoDittaView.jsp";

     //request.getRequestDispatcher("/ditta/view/bloccoDittaView.jsp").forward(request, response);

     //return;

   }

   else{
     //Correzione Blocco Ditta 19/11/2004 - Begin

     //session.setAttribute("bloccoVO", bloccoVO);

     request.setAttribute("bloccoVO", bloccoVO);

     //Correzione Blocco Ditta 19/11/2004 - End
   }

  }


  try {

    v_blocchi = client.getBlocchiDitta(dittaUma.getIdDittaUMA());

    //Correzione Blocco Ditta 19/11/2004 - Begin

    //v_blocchi = client.getBlocchiDitta(new Long(1));

    //session.setAttribute("v_blocchi", v_blocchi);

    //Correzione Blocco Ditta 19/11/2004 - End

  }

  catch (SolmrException ex) {

    /*valEx = new ValidationException(ex.getMessage(), url);

    valEx.addMessage(ex.getMessage(),"exc");*/

    error=new ValidationError(ex.getMessage());

    errors = new ValidationErrors();

    errors.add("error", error);

    request.setAttribute("errors", errors);

    //request.getRequestDispatcher("/ditta/view/bloccoDittaView.jsp").forward(request, response);

    //return;

  }

  request.setAttribute("v_blocchi", v_blocchi);

/*
  Modifica by Einaudi 26/10/2006 ==> I controlli di abilitazione sono elaborati
  dalle classi del package it.csi.solmr.presentation.security.cu negli include
  in testa ai controller.
  if(!profile.isUtenteProvinciale()){

    error=new ValidationError(""+UmaErrors.get("UTENTE_NON_AUTORIZZATO_BLOCCO_DITTA"));

    errors = new ValidationErrors();

    errors.add("error", error);

    request.setAttribute("errors", errors);

    request.getRequestDispatcher("/anag/layout/dettaglioAzienda.htm").forward(request, response);

    return;

  }


  /*if(valEx!=null)

  throw valEx;*/


  SolmrLogger.debug(this,"- bloccoDittaCtrl.jsp -  FINE PAGINA");

%>

<jsp:forward page="<%=url%>"/>