<%@ page language="java"

         contentType="text/html"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.SolmrConstants" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%
  // Se c'è un errore torno indietro di 2 pagine
  request.setAttribute("historyNum","-2");
  String iridePageName = "assegnazioneBaseCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  ValidationErrors errors = new ValidationErrors();

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");



  String url = "/domass/view/assegnazioneBaseView.jsp";

  String calcoloAutomaticoFOUrl = "/domass/ctrl/calcoloAutomaticoFOCtrl.jsp";

  String calcoloAutomaticoBOUrl = "/domass/ctrl/calcoloAutomaticoBOCtrl.jsp";

  String dettaglioDomandaUrl = "/domass/ctrl/dettaglioDomandaCtrl.jsp";

  String verificaAssegnazioneUrl = "/domass/ctrl/verificaAssegnazioneSalvataBOCtrl.jsp";

  String verificaAssegnazioneValidataUrl = "/domass/ctrl/verificaAssegnazioneValidataCtrl.jsp";





  //da rimuovere - solo per test

  Long idDomAss=null;

  Long idDomAssAnnoInCorso, idDomAssUltima;

  SolmrLogger.debug(this,"prima getParameter");



  DittaUMAAziendaVO dumaa = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

  Long idDittaUma = dumaa.getIdDittaUMA();



//  session.setAttribute("idDittaUma", idDittaUma);

  SolmrLogger.debug(this,"idDittaUma: " + idDittaUma);

//  profile.setIdProfile(SolmrConstants.PROF_USP2);

  //da rimuovere - solo per test  ValidationException valEx = null;



  if(request.getParameter("dettaglio.x") != null)

  {

    SolmrLogger.debug(this,"\\\\\\\\\\Dettaglio");

    %>

    <jsp:forward page ="<%=dettaglioDomandaUrl%>" />

    <%

  }



  if(request.getParameter("conferma.x") != null)

  {

    SolmrLogger.debug(this,"\\\\\\\\\\Conferma");

    try{

      //DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

      //if(dittaUMAAziendaVO!=null){

        //Vector result = umaFacadeClient.verificaAssegnazione(dittaUMAAziendaVO.getDittaUMA(),profile);

      //url = "/domass/view/assegnazioneBaseView.jsp";

      SolmrLogger.debug(this,"\n\n\n\n***********************************");

      

      

     
      if (ruoloUtenza.isUtenteIntermediario()){

        SolmrLogger.debug(this,"calcoloAutomaticoFOUrl: "+calcoloAutomaticoFOUrl);%>

        <jsp:forward page ="<%=calcoloAutomaticoFOUrl%>" />

      <%}else{

        SolmrLogger.debug(this,"calcoloAutomaticoBOUrl: "+calcoloAutomaticoBOUrl);%>

        <jsp:forward page ="<%=calcoloAutomaticoBOUrl%>" />

      <%}

      //umaFacadeClient.calcoloAutomaticoPL(idDittaUma);

        // devo creare un segnaposto al posto del testo e devo inserire

        // il testo che mi ritorna il metodo di business,

        // in base al valore restituito devo aggiungere

      //}

      //else

        //throw new SolmrException("Nessuna ditta uma caricata");

    }

    catch(Exception se)

    {

      ValidationError error = new ValidationError(se.getMessage());

      errors.add("error", error);

      request.setAttribute("errors", errors);

      request.getRequestDispatcher(url).forward(request, response);

      return;

    }

  }

  if(request.getParameter("avanti.x") != null)

  {

    SolmrLogger.debug(this,"\\\\\\\\\\Avanti");

    SolmrLogger.debug(this,"request.getParameter(\"stato_dom_ass\")!=null");



    if(request.getParameter("stato_dom_ass")!=null)

    {

      SolmrLogger.debug(this,"request.getParameter(\"stato_dom_ass\"): "+request.getParameter("stato_dom_ass"));

      SolmrLogger.debug(this,"request.getParameter(\"stato_dom_ass\") = "+request.getParameter("stato_dom_ass"));



      if(request.getParameter("stato_dom_ass").equals("VALIDATA"))

      {

        SolmrLogger.debug(this,"Sto andando su: "+verificaAssegnazioneValidataUrl);

        %><jsp:forward page ="<%=verificaAssegnazioneValidataUrl%>" /><%

        return;

      }

      else if(request.getParameter("stato_dom_ass").equals("ATTESA_VALIDAZIONE"))

      {

        SolmrLogger.debug(this,"Sto andando su: "+verificaAssegnazioneUrl);

        %><jsp:forward page ="<%=verificaAssegnazioneUrl%>" /><%

        return;

      }

    }



    //response.sendRedirect(request.getContextPath()+"/uma/domass/view/elencoAssegnazioniView.jsp?idDomAss=" + idDomAss);

    //request.getRequestDispatcher(visualViewUrl).forward(request, response);

  }

  else{

    SolmrLogger.debug(this,"\\\\\\\\\\Visualizza pulsanti");

    try{

      request.setAttribute("idDittaUma", idDittaUma);

      Vector result = umaFacadeClient.verificaAssegnazione(dumaa.getIdDittaUMA(),ruoloUtenza);

      // devo creare un segnaposto al posto del testo e devo inserire

      // il testo che mi ritorna il metodo di business,

      // in base al valore restituito devo aggiungere un pulsante

      idDomAssAnnoInCorso = (Long) result.get(2);

      SolmrLogger.debug(this,"result.get(2) "+result.get(2));

      idDomAssUltima = (Long) result.get(3);

      SolmrLogger.debug(this,"result.get(3) "+result.get(3));



      //Carica ultima idDomAss presentata per la ditta Uma

      if (idDomAssAnnoInCorso!=null)

      {

        idDomAss=idDomAssAnnoInCorso;

      }

      else

      {

        if (idDomAssUltima!=null)

        {

          idDomAss=idDomAssUltima;

        }

      }



      request.setAttribute("resultVerificaAssegnazione",result);

      request.setAttribute("idDomAss", idDomAss);



      SolmrLogger.debug(this,"idDomAss: " + idDomAss);

      SolmrLogger.debug(this,"Fine Throw Visualizza pulsanti");

    }

    catch(SolmrException se)

    {

      SolmrLogger.debug(this,"Catch Visualizza pulsanti");



      /*ValidationError error = new ValidationError();

      SolmrLogger.debug(this,"error.getMessage(): " + error.getMessage());

      errors.add("exception", error);*/

/*      if (profile.isUtenteProvinciale())

      {*/

        writeModificaIntermediario(umaFacadeClient,idDittaUma,request,session);

//      }

      throwValidation(se.getMessage(), url);

      request.setAttribute("errors", errors);

      %>

        <jsp:forward page ="<%=url%>" />

      <%

      return;

    }

  }

/*  if (profile.isUtenteProvinciale())

  {*/

    writeModificaIntermediario(umaFacadeClient,idDittaUma,request,session);

//  }

  %>

   <jsp:forward page ="<%=url%>" />

  <%

  SolmrLogger.debug(this,"- assegnazioneBaseCtrl.jsp -  FINE PAGINA");

%>

<%!

  private void throwValidation(String msg,String validateUrl) throws ValidationException

  {

    ValidationException valEx = new ValidationException("Errore: eccezione="+msg,validateUrl);

    valEx.addMessage(msg,"exception");

    throw valEx;

  }

%>

<%!

  private void writeModificaIntermediario(UmaFacadeClient umaFacadeClient,

                                          Long idDittaUma,

                                          HttpServletRequest request,

                                          HttpSession session) throws SolmrException

  {

    try

    {

      SolmrLogger.debug(this,"writeModificaIntermediario()");

      //UMA2 - Begin
      DatiModificatiIntermediarioVO dmiVO=null;
      dmiVO=umaFacadeClient.getDatiModificatiInteremediario(idDittaUma);
      /*Date dataInizioGestioneFascicolo = (Date)session.getAttribute("dataInizioGestioneFascicolo");
      Date toDay = new Date();
      if (toDay.after(dataInizioGestioneFascicolo)){
        //Elimina la visualizzazione delle superfici non conformi con contratti affitto scaduti
        SolmrLogger.debug(this, "if (toDay.after(dataInizioGestioneFascicolo))");
      }else{
        SolmrLogger.debug(this, "else (toDay.after(dataInizioGestioneFascicolo))");
        dmiVO=umaFacadeClient.getDatiModificatiInteremediario(idDittaUma);
      }*/
      //UMA2 - End

      SolmrLogger.debug(this,"dmiVO="+dmiVO);

      request.setAttribute("datiModificatiIntermediarioVO",dmiVO);

    }

    catch(Exception e)

    {

      SolmrLogger.debug(this,"errore="+e.getMessage());

      ValidationErrors errors=new ValidationErrors();

      errors.add("error",new ValidationError(e.getMessage()));

      request.setAttribute("errors",errors);

    }

  }

%>



