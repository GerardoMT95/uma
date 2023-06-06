<%@page import="it.csi.solmr.util.SolmrLogger"%>
<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%!
  public static String DELETE_URL="/ditta/ctrl/confermaEliminaAllevamentoCtrl.jsp?pageFrom=bis";
  public static String URL="/ditta/view/elencoAllevamentoBisView.jsp";
  public static String MODIFICA_URL="/ditta/ctrl/modificaAllevamentoCtrl.jsp?pageFrom=bis";
  public static String VALIDATE_URL="/ditta/view/elencoAllevamentoBisView.jsp";
  public static String INSERT_URL="/ditta/ctrl/nuovoAllevamentoCtrl.jsp?pageFrom=bis";
%>
<%
  String iridePageName = "elencoAllevamentoBisCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "  BEGIN elencoAllevamentoBisCtrl");
  
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  UmaFacadeClient umaClient = new UmaFacadeClient();
  String info=(String)session.getAttribute("notifica");
  if (info!=null)
  {
    findData(request,umaClient,idDittaUma,URL);
    session.removeAttribute("notifica");
    throwValidation(info,VALIDATE_URL);
  }
  if (request.getParameter("inserisci.x")!=null)
  {
    %><jsp:forward page="<%=INSERT_URL%>" /><%
    return;
  }
  else
  {
    if (request.getParameter("modifica.x")!=null)
    {
      try
      {
        AllevamentoVO allevamentoVO=(AllevamentoVO) umaClient.findAllevamentoByID(new Long(request.getParameter("radiobutton")));
        if (allevamentoVO.getDataFineVal()!=null)
        {
          throw new Exception("Allevamento non modificabile perchè riferito ad un dato storicizzato");
        }
      }
      catch(Exception e)
      {
        request.setAttribute("errorMessage",e.getMessage());
        %><jsp:forward page = "<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
        return;
      }
      %><jsp:forward page="<%=MODIFICA_URL%>" /><%
    }
    else
    {
      if (request.getParameter("elimina.x")!=null)
      {
        // Eliminazione allevamento
        Long idAllevamento=null;
        try
        {
          AllevamentoVO allevamentoVO=(AllevamentoVO) umaClient.findAllevamentoByID(new Long(request.getParameter("radiobutton")));
          if (allevamentoVO.getDataFineVal()!=null)
          {
            throw new Exception("Allevamento non eliminabile perchè riferito ad un dato storicizzato");
          }
        }
        catch(Exception e)
        {
          request.setAttribute("errorMessage",e.getMessage());
          %><jsp:forward page = "<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
          return;
        }
        // Controlli superati positivamente
        %><jsp:forward page="<%=DELETE_URL%>" /><%
      }
      else
      {
         // Visualizzazione allevamenti
        findData(request,umaClient,idDittaUma,URL);
        %><jsp:forward page="<%=URL%>" /><%
      }
    }
  }
%>

<%!
  private void findData(HttpServletRequest request,UmaFacadeClient umaClient,Long idDittaUma,String validateUrl)
      throws ValidationException
  {
    try
    {
      Vector allevamenti=umaClient.getAllevamenti(idDittaUma,new Boolean(false));
      request.setAttribute("elencoAllevamenti",allevamenti);
    }
    catch(Exception e)
    {
      throwValidation(e.getMessage(),validateUrl);
    }
}

private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException(msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}
%>