<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"

%>

<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.etc.anag.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.anag.services.DelegaAnagrafeVO" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%
  String iridePageName = "elencoAziendeCtrl.jsp";
session.removeAttribute("dittaUMAAziendaVO");
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();



  int sizeResult = 0;

  String errorPage = "/anag/view/ricercaAziendaUMAView.jsp";

  String dettaglioURL = "/anag/view/dettaglioAziendaView.jsp";

  String avantiIndietroURL = "/anag/view/elencoAziendeView.jsp";

  String url = null;



  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");



  int paginaCorrente = 0;

  Integer paginaCorrenteInteger;



  Vector vectIdAziendaDitta = (Vector)session.getAttribute("vectIdAziendaDitta");

  Vector rangeAziendaDitta = (Vector)session.getAttribute("rangeAziendaDitta");



  ValidationException valEx=null;

  Validator validator = null;

  ValidationErrors errors = new ValidationErrors();

  //if(request.getParameter("avanti") != null) {

  if(request.getParameter("valorePulsante") != null && request.getParameter("valorePulsante").equals("avanti")){

    try {

      if(vectIdAziendaDitta!=null){

        sizeResult = vectIdAziendaDitta.size();

        SolmrLogger.debug(this,"!!!!!!!!!!!!!! elencoAziendaCtrl.jsp - valore di num_max_rows: "+SolmrConstants.NUM_MAX_ROWS_PAG);



        SolmrLogger.debug(this,"??????????? elencoAziendaCtrl.jsp - numero elementi del vetttore totale: "+sizeResult);



        paginaCorrenteInteger = ((Integer)session.getAttribute("currPage"));

        SolmrLogger.debug(this,"??????????? elencoAziendaCtrl.jsp - pagina corrente: "+paginaCorrenteInteger.intValue());

        if(paginaCorrenteInteger.toString().equals(request.getParameter("totalePagine")))

          paginaCorrente = paginaCorrenteInteger.intValue();

        else

          paginaCorrente = paginaCorrenteInteger.intValue()+1;



        Vector rangeId =new Vector();

        int limiteA;

        if(sizeResult<SolmrConstants.NUM_MAX_ROWS_PAG*paginaCorrente)

          limiteA=sizeResult;

        else

          limiteA=SolmrConstants.NUM_MAX_ROWS_PAG*paginaCorrente;

        SolmrLogger.debug(this,"??????????? elencoAziendaCtrl.jsp - limite pagina: "+limiteA);



        for(int i=(paginaCorrente-1)*SolmrConstants.NUM_MAX_ROWS_PAG;

            i<limiteA;i++){

          rangeId.addElement(vectIdAziendaDitta.elementAt(i));

        }

        session.removeAttribute("rangeAziendaDitta");

        rangeAziendaDitta = umaFacadeClient.getListAziendeDitteByRange(rangeId);

        session.setAttribute("rangeAziendaDitta",rangeAziendaDitta);

        SolmrLogger.debug(this,"??????????? elencoAziendaCtrl.jsp - rangeAziendaDitta.size(): "+rangeAziendaDitta.size());



        session.removeAttribute("currPage");

        paginaCorrenteInteger = new Integer(paginaCorrente);

        session.setAttribute("currPage",paginaCorrenteInteger);

      }

    }

    catch (SolmrException sex) {

      /*valEx = new ValidationException(sex.getMessage(),errorPage);

      valEx.addMessage(sex.getMessage(),"exc2");

      url = errorPage;*/

      ValidationError error = new ValidationError(sex.getMessage());

      errors.add("error", error);

      request.setAttribute("errors", errors);

      request.getRequestDispatcher(errorPage).forward(request, response);

      return;

    }

    url = avantiIndietroURL;

  }

  else /*if(request.getParameter("indietro") != null) {*/

      if(request.getParameter("valorePulsante") != null && request.getParameter("valorePulsante").equals("indietro")){

    try {

      if(vectIdAziendaDitta!=null){

        sizeResult = vectIdAziendaDitta.size();



        paginaCorrenteInteger = ((Integer)session.getAttribute("currPage"));

        if(paginaCorrenteInteger.toString().equals("1"))

          paginaCorrente = paginaCorrenteInteger.intValue();

        else

          paginaCorrente = paginaCorrenteInteger.intValue()-1;



        Vector rangeId = new Vector();

        int limiteA;

        if(sizeResult<SolmrConstants.NUM_MAX_ROWS_PAG*paginaCorrente)

          limiteA=sizeResult;

        else

          limiteA=SolmrConstants.NUM_MAX_ROWS_PAG*paginaCorrente;

        for(int i=(paginaCorrente-1)*SolmrConstants.NUM_MAX_ROWS_PAG;

            i<limiteA;i++){

          rangeId.addElement(vectIdAziendaDitta.elementAt(i));

        }

        session.removeAttribute("rangeAziendaDitta");

        rangeAziendaDitta = umaFacadeClient.getListAziendeDitteByRange(rangeId);

        session.setAttribute("rangeAziendaDitta",rangeAziendaDitta);



        session.removeAttribute("currPage");

        paginaCorrenteInteger = new Integer(paginaCorrente);

        session.setAttribute("currPage",paginaCorrenteInteger);



      }

    }

    catch (SolmrException sex) {



      ValidationError error = new ValidationError(sex.getMessage());

      errors.add("error", error);

      request.setAttribute("errors", errors);

      request.getRequestDispatcher(errorPage).forward(request, response);

      return;

    }

    url = avantiIndietroURL;

  }



  else if(request.getParameter("funzionalita") != null) {

    //session.removeAttribute("dittaUMAAziendaVO");

    AnagFacadeClient afc = new AnagFacadeClient();

    if(rangeAziendaDitta!= null){

      for(int i=0;i<rangeAziendaDitta.size();i++){

        String posizione = request.getParameter("posizione");

        if(posizione==null){

          ValidationError error = new ValidationError("Selezionare una ditta");

          errors.add("error", error);

          request.setAttribute("errors", errors);

          request.getRequestDispatcher(avantiIndietroURL).forward(request, response);

          return;

        }

        if(posizione!= null && !posizione.equals("")){

          int intElement = new Integer(posizione).intValue();

          if(intElement == i){

            DittaUMAAziendaVO vo = (DittaUMAAziendaVO)rangeAziendaDitta.elementAt(i);

            session.removeAttribute("dittaUMAAziendaVO");

            session.setAttribute("dittaUMAAziendaVO",vo);

            break;

          }

        }

      }

      url = request.getParameter("funzionalitaSelezionata");

    }

  }

  %>

      <jsp:forward page ="<%=url%>" />

  <%



%>