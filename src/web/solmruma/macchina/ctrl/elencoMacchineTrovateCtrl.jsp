<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>

<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.etc.anag.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%

  String iridePageName = "elencoMacchineTrovateCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();



  int sizeResult = 0;

  String errorPage = "/macchina/view/elencoMacchineTrovateView.jsp";

  String ricercaPage = "/macchina/view/ricercaMacchinaView.jsp";

  String dettaglioURL = "/macchina/view/dettaglioDatiMacchinaView.jsp";

  String avantiIndietroURL = "/macchina/view/elencoMacchineTrovateView.jsp";

  String elencoURL = "/macchina/view/elencoMacchineTrovateView.jsp";

  String url = null;



  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");



  int paginaCorrente = 0;

  Integer paginaCorrenteInteger;



  Vector elencoIdMacchina = (Vector)session.getAttribute("elencoIdMacchina");

  Vector elencoMacchina = (Vector)session.getAttribute("elencoMacchina");



  Validator validator = null;

  ValidationErrors errors = new ValidationErrors();



  if(request.getParameter("valorePulsante") != null && request.getParameter("valorePulsante").equals("avanti")){

    try {

      if(elencoIdMacchina!=null){

        sizeResult = elencoIdMacchina.size();

        paginaCorrenteInteger = ((Integer)session.getAttribute("currPage"));

        if(paginaCorrenteInteger.toString().equals(request.getParameter("totalePagine")))

          paginaCorrente = paginaCorrenteInteger.intValue();

        else

          paginaCorrente = paginaCorrenteInteger.intValue()+1;



        Vector rangeIdMacchina =new Vector();

        int limiteA;

        if(sizeResult<SolmrConstants.NUM_MAX_ROWS_PAG*paginaCorrente)

          limiteA=sizeResult;

        else

          limiteA=SolmrConstants.NUM_MAX_ROWS_PAG*paginaCorrente;



        for(int i=(paginaCorrente-1)*SolmrConstants.NUM_MAX_ROWS_PAG;

            i<limiteA;i++){

          SolmrLogger.debug(this,"");

          rangeIdMacchina.addElement(elencoIdMacchina.elementAt(i));

        }

        session.removeAttribute("elencoMacchina");

        Boolean matriceCarattSiNo = (Boolean)session.getAttribute("matriceCarattSiNo");

        if(matriceCarattSiNo!=null){

          if(matriceCarattSiNo.booleanValue())

            elencoMacchina = umaFacadeClient.getElencoMacchineWithMatriceByCaratt(rangeIdMacchina);

          else

            elencoMacchina = umaFacadeClient.getElencoMacchineWithoutMatriceByCaratt(rangeIdMacchina);

        }

        else{

          elencoMacchina = umaFacadeClient.getElencoMacchineByAttestaz(rangeIdMacchina);

        }

        session.setAttribute("elencoMacchina",elencoMacchina);

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

  else if(request.getParameter("valorePulsante") != null && request.getParameter("valorePulsante").equals("indietro")){

    try {

      if(elencoIdMacchina!=null){

        sizeResult = elencoIdMacchina.size();



        paginaCorrenteInteger = ((Integer)session.getAttribute("currPage"));

        if(paginaCorrenteInteger.toString().equals("1"))

          paginaCorrente = paginaCorrenteInteger.intValue();

        else

          paginaCorrente = paginaCorrenteInteger.intValue()-1;



        Vector rangeIdMacchina = new Vector();

        int limiteA;

        if(sizeResult<SolmrConstants.NUM_MAX_ROWS_PAG*paginaCorrente)

          limiteA=sizeResult;

        else

          limiteA=SolmrConstants.NUM_MAX_ROWS_PAG*paginaCorrente;

        for(int i=(paginaCorrente-1)*SolmrConstants.NUM_MAX_ROWS_PAG;

            i<limiteA;i++){

          rangeIdMacchina.addElement(elencoIdMacchina.elementAt(i));

        }

        session.removeAttribute("elencoMacchina");

        Boolean matriceCarattSiNo = (Boolean)session.getAttribute("matriceCarattSiNo");

        if(matriceCarattSiNo!=null){

          if(matriceCarattSiNo.booleanValue())

            elencoMacchina = umaFacadeClient.getElencoMacchineWithMatriceByCaratt(rangeIdMacchina);

          else

            elencoMacchina = umaFacadeClient.getElencoMacchineWithoutMatriceByCaratt(rangeIdMacchina);

        }

        else{

          elencoMacchina = umaFacadeClient.getElencoMacchineByAttestaz(rangeIdMacchina);

        }

        session.setAttribute("elencoMacchina",elencoMacchina);



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

  else if(request.getParameter("dettaglio") != null){



    session.removeAttribute("macchinaVO");

    session.removeAttribute("v_utilizzi");

    session.removeAttribute("v_attestazioni");

    session.removeAttribute("v_immatricolazioni");

    if(elencoMacchina!=null){



      String idMacchina = request.getParameter("idMacchina");

      if(idMacchina!=null){

        MacchinaVO mVO = null;

        for(int i=0; i<elencoMacchina.size(); i++){

          mVO = (MacchinaVO)elencoMacchina.elementAt(i);

          if(idMacchina.equals(mVO.getIdMacchina())){

            session.setAttribute("macchinaVO",mVO);

            url = request.getParameter("page");

            break;

          }

        }

      }

      else{

        ValidationError error = new ValidationError("Selezionare una macchina");

        errors.add("error", error);

        request.setAttribute("errors", errors);

        request.getRequestDispatcher(elencoURL).forward(request, response);

        return;

      }

    }

  }

  else if(request.getParameter("indietro") != null){



    MacchinaVO ricMacchinaVO = (MacchinaVO)session.getAttribute("ricercaCaratt");

    AttestatoProprietaVO attPropVO = (AttestatoProprietaVO)session.getAttribute("ricercaAttest");

    Boolean matriceCarattSiNo = (Boolean)session.getAttribute("matriceCarattSiNo");



    session.removeAttribute("currPage");

    session.removeAttribute("macchinaVO");

    session.removeAttribute("elencoIdMacchina");

    session.removeAttribute("elencoMacchina");

    session.removeAttribute("messaggioTarga");

    session.removeAttribute("v_utilizzi");

    session.removeAttribute("v_attestazioni");

    session.removeAttribute("v_immatricolazioni");

    //session.removeAttribute("indietro");



    int numBlock = 1;

    Vector rangeIdMacchina = new Vector();

    if(ricMacchinaVO!=null && matriceCarattSiNo!=null){

      try{

        boolean matriceSiNo = matriceCarattSiNo.booleanValue();

        if(matriceSiNo){

          elencoIdMacchina = umaFacadeClient.getIdMacchineWithMatriceByCaratt(ricMacchinaVO);

        }

        else{

          elencoIdMacchina = umaFacadeClient.getIdMacchineWithoutMatriceByCaratt(ricMacchinaVO);

        }

        if(elencoIdMacchina!=null)

          sizeResult = elencoIdMacchina.size();
        SolmrLogger.debug(this,"\n\n\n\nsizeResult="+sizeResult+"\n\n\n\n");
        SolmrLogger.debug(this,"\n\n\n\nrangeIdMacchina.size()="+rangeIdMacchina.size()+"\n\n\n\n");

        int limiteA;

        if(sizeResult<SolmrConstants.NUM_MAX_ROWS_PAG)

          limiteA=sizeResult;

        else

          limiteA=SolmrConstants.NUM_MAX_ROWS_PAG;

        for(int i=(numBlock-1)*SolmrConstants.NUM_MAX_ROWS_PAG; i<limiteA; i++){
          SolmrLogger.debug(this,"\ni="+i);

          rangeIdMacchina.addElement(elencoIdMacchina.elementAt(i));

        }

        if(matriceSiNo){

          elencoMacchina = umaFacadeClient.getElencoMacchineWithMatriceByCaratt(rangeIdMacchina);

        }

        else{

          elencoMacchina = umaFacadeClient.getElencoMacchineWithoutMatriceByCaratt(rangeIdMacchina);

        }

      }

      catch(SolmrException sex){

        ValidationError error = new ValidationError(sex.getMessage());

        errors.add("error", error);

        request.setAttribute("errors", errors);

        request.getRequestDispatcher(errorPage).forward(request, response);

        return;

      }

    }

    else if(attPropVO!=null){

      try{

        elencoIdMacchina = umaFacadeClient.getIdMacchineByAttestaz(attPropVO);



        if(elencoIdMacchina!=null)

          sizeResult = elencoIdMacchina.size();

        int limiteA;

        if(sizeResult<SolmrConstants.NUM_MAX_ROWS_PAG)

          limiteA=sizeResult;

        else

          limiteA=SolmrConstants.NUM_MAX_ROWS_PAG;

        for(int i=(numBlock-1)*SolmrConstants.NUM_MAX_ROWS_PAG; i<limiteA; i++){

          rangeIdMacchina.addElement(elencoIdMacchina.elementAt(i));

        }



        elencoMacchina = umaFacadeClient.getElencoMacchineByAttestaz(rangeIdMacchina);

      }

      catch(SolmrException sex){

        ValidationError error = new ValidationError(sex.getMessage());

        errors.add("error", error);

        request.setAttribute("errors", errors);

        request.getRequestDispatcher(errorPage).forward(request, response);

        return;

      }

    }

    session.setAttribute("elencoIdMacchina",elencoIdMacchina);

    session.setAttribute("elencoMacchina",elencoMacchina);

    url = elencoURL;

  }

  %>

      <jsp:forward page ="<%=url%>" />

  <%



%>