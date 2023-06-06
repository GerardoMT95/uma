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

  String iridePageName = "lista_marcheCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  int sizeResult = 0;
  String errorPage = "/macchina/view/lista_marcheView.jsp";
  String ricercaPage = "/macchina/view/lista_marcheView.jsp";
  String avantiIndietroURL = "/macchina/view/lista_marcheView.jsp";
  String elencoURL = "/macchina/view/lista_marcheView.jsp";
  String eliminaUrl = "/macchina/layout/elimina_marche.";
  String CONFERMAELIMINA="../../layout/confermaEliminaMarca.htm";
  String url = ricercaPage;
  Long idGenereMacchina = null;
  String descrizioneMarca = null;
  String matriceMarca = null;
  String genereMacchina = null;
  int numBlock = 1;
  //Vector rangeIdMarche = new Vector();
  Vector rangeIdMarca = new Vector();
  Validator validator = null;
  ValidationErrors errors = new ValidationErrors();

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  int j=0;
  int paginaCorrente = 0;
  Integer paginaCorrenteInteger;

  //Vector elencoIdMarche = new Vector();
  Vector elencoIdMarca = new Vector();
  Vector elencoMarca = new Vector();

  SolmrLogger.debug(this,"#§§§§§§§§§§§§§§§ : session.getAttribute(ListaMarcheGenereMacchina): "+session.getAttribute("ListaMarcheGenereMacchina"));

  //Controllo di ritorno dell'inserimento su ricerca o lista
  if ( session.getAttribute("pageFrom")!=null ){
    session.removeAttribute("pageFrom");
  }

  if(request.getParameter("genereMacchina")!=null && !(request.getParameter("genereMacchina").toString().equalsIgnoreCase(""))){
    genereMacchina = (String)request.getParameter("genereMacchina");
    SolmrLogger.debug(this,"request.getParameter genereMacchina: "+genereMacchina);
  }
  else{
    if(request.getAttribute("genereMacchina")!=null && !(request.getAttribute("genereMacchina").toString().equalsIgnoreCase("")) ){
      genereMacchina = (String)request.getAttribute("genereMacchina");
      SolmrLogger.debug(this,"request.getAttribute genereMacchina: "+genereMacchina);
    }
    else{
      genereMacchina = (String)session.getAttribute("genereMacchina");
      SolmrLogger.debug(this,"session genereMacchina: "+genereMacchina);
    }
  }

  if(request.getParameter("descrizioneMarca")!=null && !(request.getParameter("descrizioneMarca").toString().equalsIgnoreCase("")) ){
    descrizioneMarca = (String)request.getParameter("descrizioneMarca");
    SolmrLogger.debug(this,"request.getParameter descrizioneMarca: "+descrizioneMarca);
  }
  else{
    if(request.getAttribute("descrizioneMarca")!=null && !(request.getAttribute("descrizioneMarca").toString().equalsIgnoreCase("")) ){
      descrizioneMarca = (String)request.getAttribute("descrizioneMarca");
      SolmrLogger.debug(this,"request.getAttribute descrizioneMarca: "+descrizioneMarca);
    }
    else{
      descrizioneMarca = (String)session.getAttribute("descrizioneMarca");
      SolmrLogger.debug(this,"session descrizioneMarca: "+descrizioneMarca);
    }
  }

  if(request.getParameter("matriceMarca")!=null && !(request.getParameter("matriceMarca").toString().equalsIgnoreCase("")) ){
    matriceMarca = (String)request.getParameter("matriceMarca");
    SolmrLogger.debug(this,"request.getParameter matriceMarca: "+matriceMarca);
  }
  else{
    if(request.getAttribute("matriceMarca")!=null  && !(request.getAttribute("matriceMarca").toString().equalsIgnoreCase("")) ){
      matriceMarca = (String)request.getAttribute("matriceMarca");
      SolmrLogger.debug(this,"request matriceMarca: "+matriceMarca);
    }
    else{
      matriceMarca = (String)session.getAttribute("matriceMarca");
      SolmrLogger.debug(this,"session matriceMarca: "+matriceMarca);
    }
  }

  request.setAttribute("genereMacchina", genereMacchina);
  request.setAttribute("descrizioneMarca", descrizioneMarca);
  request.setAttribute("matriceMarca", matriceMarca);

  SolmrLogger.debug(this,"###### genereMacchina : "+genereMacchina);
  SolmrLogger.debug(this,"###### descrizioneMarca : "+descrizioneMarca);
  SolmrLogger.debug(this,"###### matriceMarca : "+matriceMarca);
  SolmrLogger.debug(this,"###### session.getAttribute(elencoIdMarca) : "+session.getAttribute("elencoIdMarca"));
  SolmrLogger.debug(this,"###### session.getAttribute(elencoMarca) : "+session.getAttribute("elencoMarca"));

  if(session.getAttribute("elencoIdMarca") != null && session.getAttribute("elencoMarca") != null)
  {
    SolmrLogger.debug(this,"if (session.getAttribute(\"elencoIdMarca\") != null && session.getAttribute(\"elencoMarca\") != null)");
    //elencoIdMarche = (Vector)session.getAttribute("elencoIdMarca");
    elencoIdMarca = (Vector)session.getAttribute("elencoIdMarca");
    elencoMarca = (Vector)session.getAttribute("elencoMarca");
    //session.setAttribute("elencoIdMarca",elencoIdMarche);
  }
  else
  {
    try
    {
      SolmrLogger.debug(this,"else (session.getAttribute(\"elencoIdMarca\") != null && session.getAttribute(\"elencoMarca\") != null)");
      String matriceMarcaUpperCase=null;
      if ( matriceMarca!=null && (!(matriceMarca.trim().equalsIgnoreCase(""))) ){
        matriceMarcaUpperCase =matriceMarca.toUpperCase();
      }
      Long genereMacchinaLong=null;
      if (genereMacchina!=null && (!(genereMacchina.trim().equalsIgnoreCase(""))) ){
        genereMacchinaLong = new Long(genereMacchina);
      }
      String descrizioneMarcaUpperCase=null;
      if (descrizioneMarca!=null){
        descrizioneMarcaUpperCase = descrizioneMarca.toUpperCase();
      }
      SolmrLogger.debug(this,"++++++++findIdMarche");
      SolmrLogger.debug(this,"matriceMarcaUpperCase: "+matriceMarcaUpperCase);
      SolmrLogger.debug(this,"genereMacchinaLong: "+genereMacchinaLong);
      SolmrLogger.debug(this,"descrizioneMarcaUpperCase: "+descrizioneMarcaUpperCase);

      //elencoIdMarche = umaFacadeClient.findIdMarche(genereMacchinaLong, descrizioneMarcaUpperCase, matriceMarcaUpperCase);
      elencoIdMarca = umaFacadeClient.findIdMarche(genereMacchinaLong, descrizioneMarcaUpperCase, matriceMarcaUpperCase);
      //session.setAttribute("elencoIdMarche",elencoIdMarche);
      session.setAttribute("elencoIdMarca",elencoIdMarca);
    }
    catch (SolmrException sex) {
      ValidationError error = new ValidationError(sex.getMessage());
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(errorPage).forward(request, response);
      return;
    }
    if(request.getParameter("genereMacchina") != null && !"".equals(request.getParameter("genereMacchina")))
      idGenereMacchina = new Long((String)request.getParameter("genereMacchina").trim());
    SolmrLogger.debug(this,"idGenereMacchina = "+idGenereMacchina);
    if(request.getParameter("descrizioneMarca") != null)
      descrizioneMarca = (String)request.getParameter("descrizioneMarca");
    if(request.getParameter("matriceMarca") != null)
      matriceMarca = (String)request.getParameter("matriceMarca");

    //SolmrLogger.debug(this,"elencoIdMarche.size() "+elencoIdMarche.size());
    SolmrLogger.debug(this,"elencoIdMarca.size() "+elencoIdMarca.size());

    /*if(elencoIdMarche!=null)
      sizeResult = elencoIdMarche.size();*/
    if(elencoIdMarca!=null)
      sizeResult = elencoIdMarca.size();
    int limiteA;
    if(sizeResult<SolmrConstants.NUM_MAX_ROWS_PAG)
      limiteA=sizeResult;
    else
      limiteA=SolmrConstants.NUM_MAX_ROWS_PAG;

    SolmrLogger.debug(this,"numBlock: "+numBlock);
    for(int i=(numBlock-1)*SolmrConstants.NUM_MAX_ROWS_PAG; i<limiteA; i++)
    {
      /*SolmrLogger.debug(this,"elencoIdMarche.elementAt(i) "+elencoIdMarche.elementAt(i));
      rangeIdMarche.addElement(elencoIdMarche.elementAt(i));*/
      SolmrLogger.debug(this,"elencoIdMarca.elementAt(i) "+elencoIdMarca.elementAt(i));
      rangeIdMarca.addElement(elencoIdMarca.elementAt(i));
    }

    SolmrLogger.debug(this,"\n\n\nfindMarcheByIdList");
    //elencoMarca = umaFacadeClient.findMarcheByIdList(rangeIdMarche);
    elencoMarca = umaFacadeClient.findMarcheByIdList(rangeIdMarca);
    //session.setAttribute("elencoIdMarche",elencoIdMarche);
    session.setAttribute("elencoIdMarca",elencoIdMarca);
    session.setAttribute("elencoMarca",elencoMarca);

    SolmrLogger.debug(this,"\n\n\n\n##################################");
    //SolmrLogger.debug(this,"elencoIdMarche.size(): "+elencoIdMarche.size());
    SolmrLogger.debug(this,"elencoIdMarca.size(): "+elencoIdMarca.size());
    SolmrLogger.debug(this,"elencoMarca.size(): "+elencoMarca.size()+"\n\n\n");
  }

  //SolmrLogger.debug(this,"#lista_marcheCtrl elencoIdMarche "+elencoIdMarche);
  SolmrLogger.debug(this,"#lista_marcheCtrl elencoIdMarca "+elencoIdMarca);
  SolmrLogger.debug(this,"#lista_marcheCtrl elencoMarca "+elencoMarca);

  SolmrLogger.debug(this,"elencoMarca :"+session.getAttribute("elencoMarca"));

  if(request.getParameter("valorePulsante") != null && request.getParameter("valorePulsante").equals("elimina"))
  {
    SolmrLogger.debug(this,"************ Eliminazione");

    SolmrLogger.debug(this,"# genereMacchina : "+genereMacchina);
    SolmrLogger.debug(this,"# descrizioneMarca : "+descrizioneMarca);
    SolmrLogger.debug(this,"# matriceMarca : "+matriceMarca);

    session.setAttribute("ListaMarcheGenereMacchina", genereMacchina);
    session.setAttribute("ListaMarcheDescrizioneMarca", descrizioneMarca);
    session.setAttribute("ListaMarcheMatriceMarca", matriceMarca);
    session.setAttribute("idMarca", request.getParameter("idMarca"));

    try
    {
      Long idMarca = new Long((String)request.getParameter("idMarca"));
      umaFacadeClient.isMarcaCollegata(idMarca);
      response.sendRedirect(CONFERMAELIMINA);
      return;
    }
    catch (SolmrException sex)
    {
      ValidationError error = new ValidationError(sex.getMessage());
      errors.add("error", error);
      request.setAttribute("errors", errors);
    }

  }

  if((request.getParameter("valorePulsante") != null && request.getParameter("valorePulsante").equals("avanti")) || request.getParameter("refresh") != null || session.getAttribute("refresh") != null )
  {
    SolmrLogger.debug(this,"************ Refresh");
    SolmrLogger.debug(this,"request.getParameter(\"valorePulsante\"): "+request.getParameter("valorePulsante"));
    SolmrLogger.debug(this,"request.getParameter(\"refresh\"): "+request.getParameter("refresh"));
    SolmrLogger.debug(this,"session.getAttribute(\"refresh\"): "+session.getAttribute("refresh"));
    try
    {
      //if(elencoIdMarche!=null)
      if(elencoIdMarca!=null)
      {
        //SolmrLogger.debug(this,"elencoIdMarche :"+elencoIdMarche);
        SolmrLogger.debug(this,"elencoIdMarca :"+elencoIdMarca);
        //sizeResult = elencoIdMarche.size();
        sizeResult = elencoIdMarca.size();

        if(session.getAttribute("currPage")==null)
          paginaCorrenteInteger=new Integer(1);
        else
          paginaCorrenteInteger = ((Integer)session.getAttribute("currPage"));

        SolmrLogger.debug(this,"paginaCorrenteInteger :"+paginaCorrenteInteger);
        //if(paginaCorrenteInteger.toString().equals(request.getParameter("totalePagine")) || request.getAttribute("refresh") != null || session.getAttribute("refresh") != null)
        if(paginaCorrenteInteger.toString().equals(request.getParameter("totalePagine")) || request.getParameter("refresh") != null || session.getAttribute("refresh") != null)
        {
          paginaCorrente = paginaCorrenteInteger.intValue();
        }
        else
          paginaCorrente = paginaCorrenteInteger.intValue()+1;

        //Vector rangeIdMarca =new Vector();
        rangeIdMarca =new Vector();
        int limiteA;
        if(sizeResult<SolmrConstants.NUM_MAX_ROWS_PAG*paginaCorrente)
          limiteA=sizeResult;
        else
          limiteA=SolmrConstants.NUM_MAX_ROWS_PAG*paginaCorrente;

        SolmrLogger.debug(this,"SolmrConstants.NUM_MAX_ROWS_PAG: "+SolmrConstants.NUM_MAX_ROWS_PAG);
        SolmrLogger.debug(this,"limiteA: "+limiteA);
        for(int i=(paginaCorrente-1)*SolmrConstants.NUM_MAX_ROWS_PAG; i<limiteA;i++)
        {
          SolmrLogger.debug(this,"i: "+i);
          //SolmrLogger.debug(this,"elencoIdMarche.elementAt(i): "+elencoIdMarche.elementAt(i));
          //rangeIdMarca.addElement(elencoIdMarche.elementAt(i));
          SolmrLogger.debug(this,"elencoIdMarca.elementAt(i): "+elencoIdMarca.elementAt(i));
          rangeIdMarca.addElement(elencoIdMarca.elementAt(i));
        }
        //session.removeAttribute("elencoMarca");

        SolmrLogger.debug(this,"paginaCorrente: "+paginaCorrente);
        SolmrLogger.debug(this,"rangeIdMarca: "+rangeIdMarca);

        SolmrLogger.debug(this,"\n\n\nfindMarcheByIdList - refresh");
        elencoMarca = umaFacadeClient.findMarcheByIdList(rangeIdMarca);

        session.setAttribute("elencoMarca",elencoMarca);
        session.removeAttribute("currPage");
        paginaCorrenteInteger = new Integer(paginaCorrente);
        session.setAttribute("currPage",paginaCorrenteInteger);

        /*if(session.getAttribute("refresh") != null)
            session.removeAttribute("refresh");*/
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
  else if(request.getParameter("valorePulsante") != null && request.getParameter("valorePulsante").equals("indietro"))
  {

    try {
      //if(elencoIdMarche!=null){
      if(elencoIdMarca!=null){
        //sizeResult = elencoIdMarche.size();
        sizeResult = elencoIdMarca.size();

        paginaCorrenteInteger = ((Integer)session.getAttribute("currPage"));
        if(paginaCorrenteInteger.toString().equals("1"))
          paginaCorrente = paginaCorrenteInteger.intValue();
        else
          paginaCorrente = paginaCorrenteInteger.intValue()-1;

        //Vector rangeIdMarca = new Vector();
        rangeIdMarca = new Vector();
        int limiteA;
        if(sizeResult<SolmrConstants.NUM_MAX_ROWS_PAG*paginaCorrente)
          limiteA=sizeResult;
        else
          limiteA=SolmrConstants.NUM_MAX_ROWS_PAG*paginaCorrente;
        for(int i=(paginaCorrente-1)*SolmrConstants.NUM_MAX_ROWS_PAG;
            i<limiteA;i++){
          //rangeIdMarca.addElement(elencoIdMarche.elementAt(i));
          rangeIdMarca.addElement(elencoIdMarca.elementAt(i));
        }
        session.removeAttribute("elencoMarca");

        elencoMarca = umaFacadeClient.findMarcheByIdList(rangeIdMarca);

        session.setAttribute("elencoMarca",elencoMarca);
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

  //Gestione dei dati di request in redirect su inserimento
  /*if(request.getAttribute("genereMacchina")!=null){
    session.setAttribute("genereMacchina", (String)request.getAttribute("genereMacchina"));
  }
  if(request.getAttribute("descrizioneMarca")!=null){
    session.setAttribute("descrizioneMarca", (String)request.getAttribute("descrizioneMarca"));
  }
  if(request.getAttribute("matriceMarca")!=null){
    session.setAttribute("matriceMarca", (String)request.getAttribute("matriceMarca"));
  }*/
  %><jsp:forward page ="<%=url%>" /><%

%>