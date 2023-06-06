<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>



<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%!

  private static final String DETTAGLIO="/macchina/ctrl/ricerca_marcheCtrl.jsp";

  private static final String VIEW="/macchina/view/ricerca_marcheView.jsp";

  private static final String VIEWHTM="../layout/ricerca_marche.htm";

  private static final String ELENCO="/macchina/layout/lista_marche.htm";

%>

<%

  String iridePageName = "ricerca_marcheCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%




  UmaFacadeClient umaClient = new UmaFacadeClient();

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

//  MacchinaVO mavo = (MacchinaVO)session.getAttribute("common");

  ValidationErrors errors = new ValidationErrors();

  Vector rangeIdMarche = new Vector();

  Vector elencoMarca = new Vector();

  Vector elencoIdMarche = new Vector();

  session.removeAttribute("currPage");



  session.removeAttribute("ListaMarcheGenereMacchina");

  session.removeAttribute("ListaMarcheDescrizioneMarca");

  session.removeAttribute("ListaMarcheMatriceMarca");



  session.removeAttribute("genereMacchina");

  session.removeAttribute("descrizioneMarca");

  session.removeAttribute("matriceMarca");



  int sizeResult = 0;

  int numBlock = 1;



  if(request.getParameter("ricerca")!=null)

  {



    SolmrLogger.debug(this,"\n\n\n[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]");

    SolmrLogger.debug(this,"genereMacchina "+request.getParameter("genereMacchina"));

    SolmrLogger.debug(this,"descrizioneMarca "+request.getParameter("descrizioneMarca"));

    SolmrLogger.debug(this,"matriceMarca "+request.getParameter("matriceMarca"));

    SolmrLogger.debug(this,"\n\n\n");



    Long idGenereMacchina = null;

    String descrizioneMarca = null;

    String matriceMarca = null;



    validate((String)request.getParameter("genereMacchina"), (String)request.getParameter("descrizioneMarca"), (String)request.getParameter("matriceMarca"), errors);



    if (errors!=null && errors.size()>0)

    {

      request.setAttribute("errors",errors);

      %><jsp:forward page="<%=VIEW%>" /><%

      return;

    }



    if(request.getParameter("genereMacchina") != null && !"".equals(request.getParameter("genereMacchina")))

      idGenereMacchina = new Long((String)request.getParameter("genereMacchina").trim());

    SolmrLogger.debug(this,"idGenereMacchina = "+idGenereMacchina);

    if(request.getParameter("descrizioneMarca") != null)

      descrizioneMarca = (String)request.getParameter("descrizioneMarca");

    if(request.getParameter("matriceMarca") != null)

      matriceMarca = (String)request.getParameter("matriceMarca");



    try

    {

      SolmrLogger.debug(this,"idGenereMacchina: "+idGenereMacchina);

      SolmrLogger.debug(this,"descrizioneMarca: "+descrizioneMarca);

      SolmrLogger.debug(this,"matriceMarca: "+matriceMarca);

      elencoIdMarche = umaClient.findIdMarche(idGenereMacchina, descrizioneMarca.toUpperCase(), matriceMarca.toUpperCase());

    }

    catch(SolmrException sex)

    {

      throwValidation(sex.getMessage(), VIEW);

    }



    if( idGenereMacchina!=null ){

      String descGenereMacchina = umaClient.getDescGenereMacchina(idGenereMacchina);

      request.setAttribute("genereMacchina", descGenereMacchina);

    }

    request.setAttribute("descrizioneMarca", descrizioneMarca);

    request.setAttribute("matriceMarca", matriceMarca);



      SolmrLogger.debug(this,"elencoIdMarche.size() "+elencoIdMarche.size());



    if(elencoIdMarche!=null)

      sizeResult = elencoIdMarche.size();

    int limiteA;

    if(sizeResult<SolmrConstants.NUM_MAX_ROWS_PAG)

      limiteA=sizeResult;

    else

      limiteA=SolmrConstants.NUM_MAX_ROWS_PAG;

    for(int i=(numBlock-1)*SolmrConstants.NUM_MAX_ROWS_PAG; i<limiteA; i++)

    {

      SolmrLogger.debug(this,"elencoIdMarche.elementAt(i) "+elencoIdMarche.elementAt(i));

      rangeIdMarche.addElement(elencoIdMarche.elementAt(i));

    }



    elencoMarca = umaClient.findMarcheByIdList(rangeIdMarche);



    SolmrLogger.debug(this,"##-------- ricerca_marcheCtrl elencoIdMarche " + elencoIdMarche);

    SolmrLogger.debug(this,"##-------- ricerca_marcheCtrl elencoMarca " + elencoMarca);



    session.setAttribute("elencoIdMarca",elencoIdMarche);

    session.setAttribute("elencoMarca",elencoMarca);



    SolmrLogger.debug(this,"\n\n\n[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]222");

    SolmrLogger.debug(this,"idGenereMacchina: "+idGenereMacchina);

    SolmrLogger.debug(this,"descrizioneMarca: "+descrizioneMarca);

    SolmrLogger.debug(this,"matriceMarca: "+matriceMarca);



    session.setAttribute("genereMacchina", request.getParameter("genereMacchina"));

    session.setAttribute("descrizioneMarca", request.getParameter("descrizioneMarca"));

    session.setAttribute("matriceMarca", request.getParameter("matriceMarca"));



    %><jsp:forward page="<%=ELENCO%>" /><%

    return;

  }



  //Controllo di ritorno dell'inserimento su ricerca o lista

  session.setAttribute("pageFrom", "ricerca");

%><jsp:forward page="<%=VIEW%>" /><%

%>



<%!

public void validate(String idGenereMacchina, String descrizione, String matrice, ValidationErrors errors)

{

  if(!Validator.isNotEmpty(descrizione) && !Validator.isNotEmpty(matrice))

  {

    errors.add("descrizioneMarca", new ValidationError("Valorizzare almeno il campo &quot;Descrizione marca&quot; o quello &quot;Matrice marca&quot;"));

    errors.add("matriceMarca", new ValidationError("Valorizzare almeno il campo &quot;Descrizione marca&quot; o quello &quot;Matrice marca&quot;"));

  }

}

private void throwValidation(String msg,String validateUrl) throws ValidationException

{

  ValidationException valEx = new ValidationException(msg,validateUrl);

  valEx.addMessage(msg,"exception");

  throw valEx;

}

%>

