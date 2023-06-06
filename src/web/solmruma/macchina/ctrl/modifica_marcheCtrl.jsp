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
  private static final String DETTAGLIO="/macchina/ctrl/modifica_marcheCtrl.jsp";
  private static final String VIEW="/macchina/view/modifica_marcheView.jsp";
  private static final String VIEWHTM="../layout/modifica_marche.htm";
  private static final String ELENCO="/macchina/layout/lista_marche.htm";
  private static final String RICERCA="../layout/ricerca_marche.htm";
  private static final String SUCCESS_PAGE="../../macchina/layout/modificaMarcheOk.htm";
%>
<%

  String iridePageName = "modifica_marcheCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  UmaFacadeClient umaClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  ValidationErrors errors = new ValidationErrors();

  MarcaVO marcaVO = new MarcaVO();

  SolmrLogger.debug(this,"idMarca "+request.getParameter("idMarca"));

  Long idMarca = null;
  Long idGenereMacchina = null;
  String descrizioneMarca = null;
  String matriceMarca = null;
  String genereMacchina = null;

  SolmrLogger.debug(this,"----------------------------- currpage "+session.getAttribute("currPage"));

  if(request.getParameter("genereMacchina") != null)
  {
    genereMacchina = (String)request.getParameter("genereMacchina");
    descrizioneMarca = (String)request.getParameter("descrizioneMarca");
    matriceMarca = (String)request.getParameter("matriceMarca");
    request.setAttribute("genereMacchina", genereMacchina);
    request.setAttribute("descrizioneMarca", descrizioneMarca);
    request.setAttribute("matriceMarca", matriceMarca);
  }

  if(request.getParameter("descrizioneMarcaMod")==null)
  {
    request.setAttribute("descrizioneMarcaMod", request.getParameter("descrizioneMarca"));
  }
  else
  {
    request.setAttribute("descrizioneMarcaMod", request.getParameter("descrizioneMarcaMod"));
  }

  if(request.getAttribute("genereMarca") != null)
    request.setAttribute("descrizioneMarcaMod",   umaClient.getDescGenereMacchina(new Long((String)request.getParameter("genereMacchina"))));

  if(request.getParameter("conferma") != null)
  {

    SolmrLogger.debug(this,"request.getParameter(\"descrizioneMarca\") "+request.getParameter("descrizioneMarca"));

    request.setAttribute("idMarca", (String)request.getParameter("idMarca"));
    request.setAttribute("genereMacchina", (String)request.getParameter("genereMacchina"));
    request.setAttribute("descrizioneMarca", (String)request.getParameter("descrizioneMarca"));
    request.setAttribute("matriceMarca", (String)request.getParameter("matriceMarca"));
    request.setAttribute("matriceMarcaMod", (String)request.getParameter("matriceMarcaMod"));
    validate((String)request.getParameter("descrizioneMarcaMod"), errors);

    if (errors!=null && errors.size()>0)
    {
      request.setAttribute("errors",errors);
      %><jsp:forward page="<%=VIEW%>" /><%
      return;
    }

    marcaVO.setIdMarca((String)request.getParameter("idMarca"));
    marcaVO.setDescrizioneMarca((String)request.getParameter("descrizioneMarcaMod"));
    marcaVO.setMatrice((String)request.getParameter("matriceMarcaMod"));

    umaClient.updateMarca(marcaVO);

    //request.setAttribute("refresh", "");

    session.setAttribute("genereMacchina", (String)request.getParameter("genereMacchina"));
    session.setAttribute("descrizioneMarca", (String)request.getParameter("descrizioneMarca"));
    session.setAttribute("matriceMarca", (String)request.getParameter("matriceMarca"));

    %><jsp:forward page="<%=SUCCESS_PAGE%>" /><%
    return;
  }

  if (request.getParameter("annulla")!=null)
  {

    request.setAttribute("idMarca", (String)request.getParameter("idMarca"));
    request.setAttribute("genereMacchina", (String)request.getParameter("genereMacchina"));
    request.setAttribute("descrizioneMarca", (String)request.getParameter("descrizioneMarca"));
    request.setAttribute("matriceMarca", (String)request.getParameter("matriceMarca"));

    %><jsp:forward page="<%=ELENCO%>" /><%
    return;
  }

  SolmrLogger.debug(this,"\n\n\n++++++++++++++request.getParameter(\"idMarca\"): "+request.getParameter("idMarca"));
  if(Validator.isNotEmpty(request.getParameter("idMarca")))
  {
    idMarca = new Long((String)request.getParameter("idMarca").trim());
    SolmrLogger.debug(this,"idMarca = "+idMarca);
    Vector vect = new Vector();
    vect.add(idMarca);
    marcaVO = (MarcaVO)umaClient.findMarcheByIdList(vect).get(0);
    request.setAttribute("genereMacchina", marcaVO.getIdGenereMacchina());
    request.setAttribute("descrizioneMarcaMod", marcaVO.getDescrizioneMarca());
    request.setAttribute("matriceMarcaMod", marcaVO.getMatrice());
    request.setAttribute("idMarca", marcaVO.getIdMarca());
  }

%><jsp:forward page="<%=VIEW%>" /><%
%>

<%!
public void validate(String descrizione, ValidationErrors errors) throws ValidationException
{
    if(!Validator.isNotEmpty(descrizione))
    {
      errors.add("descrizioneMarca", new ValidationError("La &quot;Descrizione Marca&quot; è un campo obbligatorio"));
    }
}
private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException(msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}
%>
