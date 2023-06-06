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
  private static final String DETTAGLIO="/macchina/ctrl/inserimento_marcheCtrl.jsp";
  private static final String VIEW="/macchina/view/inserimento_marcheView.jsp";
  private static final String VIEWHTM="../layout/inserimento_marche.htm";
  private static final String ELENCO="../layout/lista_marche.htm";
  private static final String RICERCA="../layout/ricerca_marche.htm";
  private static final String SUCCESS_PAGE="../../macchina/layout/inserimentoMarcheOk.htm";
%>
<%

  String iridePageName = "inserimento_marcheCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  UmaFacadeClient umaClient = new UmaFacadeClient();

  ValidationErrors errors = new ValidationErrors();

  SolmrLogger.debug(this,"genereMacchina "+request.getParameter("genereMacchina"));
  SolmrLogger.debug(this,"descrizioneMarca "+request.getParameter("descrizioneMarca"));
  SolmrLogger.debug(this,"matriceMarca "+request.getParameter("matriceMarca"));

  Long idGenereMacchina = null;
  String descrizioneMarca = null;
  String matriceMarca = null;

  if(request.getParameter("conferma") != null)
  {
    validate((String)request.getParameter("genereMacchina"), (String)request.getParameter("descrizioneMarca"), (String)request.getParameter("matriceMarca"), errors, umaClient);

    request.setAttribute("genereMacchina", (String)request.getParameter("genereMacchina"));
    request.setAttribute("descrizioneMarca", (String)request.getParameter("descrizioneMarca"));
    request.setAttribute("matriceMarca", (String)request.getParameter("matriceMarca"));

    MarcaVO marcaVO = new MarcaVO();

    if (errors!=null && errors.size()>0)
    {
      request.setAttribute("errors",errors);
      %><jsp:forward page="<%=VIEW%>" /><%
      return;
    }

    marcaVO.setIdMarca((String)request.getParameter("genereMacchina"));
    marcaVO.setDescrizioneMarca((String)request.getParameter("descrizioneMarca"));
    marcaVO.setMatrice((String)request.getParameter("matriceMarca"));

    umaClient.insertMarca(marcaVO);

    request.setAttribute("genereMacchina", "");
    request.setAttribute("descrizioneMarca", "");
    request.setAttribute("matriceMarca", "");

    %><jsp:forward page="<%=SUCCESS_PAGE%>" /><%
    return;
  }

  if ( request.getParameter("annulla")!=null )
  {
    SolmrLogger.debug(this,"genereMacchinaSrch: "+request.getParameter("genereMacchinaSrch"));
    SolmrLogger.debug(this,"descrizioneMarcaSrch: "+request.getParameter("descrizioneMarcaSrch"));
    SolmrLogger.debug(this,"matriceMarcaSrch: "+request.getParameter("matriceMarcaSrch"));

    session.setAttribute("genereMacchina", request.getParameter("genereMacchinaSrch"));
    session.setAttribute("descrizioneMarca", request.getParameter("descrizioneMarcaSrch"));
    session.setAttribute("matriceMarca", request.getParameter("matriceMarcaSrch"));

    SolmrLogger.debug(this,"\n\n\n-----------------------------------------");
    SolmrLogger.debug(this,"request.getParameter(\"pageFrom\"): "+request.getParameter("pageFrom"));
    if(request.getParameter("pageFrom")!=null && request.getParameter("pageFrom").equalsIgnoreCase("ricerca")){
      SolmrLogger.debug(this,"next page: "+RICERCA);
      response.sendRedirect(RICERCA);
    }else{
      SolmrLogger.debug(this,"next page: "+ELENCO);
      response.sendRedirect(ELENCO);
    }
    return;
  }

  if(request.getParameter("genereMacchina") != null && !"".equals(request.getParameter("genereMacchina")))
    idGenereMacchina = new Long((String)request.getParameter("genereMacchina").trim());
  SolmrLogger.debug(this,"idGenereMacchina = "+idGenereMacchina);
  if(request.getParameter("descrizioneMarca") != null)
    descrizioneMarca = (String)request.getParameter("descrizioneMarca");
  if(request.getParameter("matriceMarca") != null)
    matriceMarca = (String)request.getParameter("matriceMarca");

%><jsp:forward page="<%=VIEW%>" /><%
%>

<%!
public void validate(String idGenereMacchina, String descrizione, String matrice, ValidationErrors errors, UmaFacadeClient umaClient) throws ValidationException
{
  try
  {
    if(!Validator.isNotEmpty(idGenereMacchina))
    {
      errors.add("idGenereMacchina", new ValidationError("Selezionare il &quot;Genere Macchina&quot;"));
    }
    if(!Validator.isNotEmpty(descrizione))
    {
      errors.add("descrizioneMarca", new ValidationError("La &quot;Descrizione Marca&quot; è un campo obbligatorio"));
    }
    if(!Validator.isNotEmpty(matrice))
    {
      errors.add("matriceMarca", new ValidationError("La &quot;Matrice Marca&quot; è un campo obbligatorio"));
    }
    else if((matrice.toCharArray())[0] != (idGenereMacchina.toCharArray())[0])
    {
      errors.add("matriceMarca", new ValidationError("La &quot;Matrice Marca&quot; non è compatibile con il &quot;Genere Macchina&quot; selezionato"));
    }
    else if(matrice.length()!=5)
    {
      errors.add("matriceMarca", new ValidationError("La &quot;Matrice Marca&quot; deve essere di 5 cifre"));
    }
    else if(!Validator.isNumericInteger(matrice))
    {
      errors.add("matriceMarca", new ValidationError("La &quot;Matrice Marca&quot; deve essere un dato numerico"));
    }

    SolmrLogger.debug(this,"-----matrice : |"+matrice+"|");

    umaClient.findMarcheByMatriceMarca(matrice);

    errors.add("matriceMarca", new ValidationError("La matrice indicata esiste già"));
  }
  catch(Exception ex)
  {
    if(((String)SolmrConstants.get("MATRICE_MARCA_NON_TROVATA")).equals(ex.getMessage()))
    {
      //throwValidation(ex.getMessage(), VIEW);
    }
  }
}
private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException(msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}
%>
