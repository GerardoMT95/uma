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
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%

  String iridePageName = "elencoSerreBisCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "BEGIN elencoSerreBisCtrl");	
		  
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  UmaFacadeClient umaClient = new UmaFacadeClient();
  String url="/ditta/view/elencoSerraBisView.jsp";
  String modificaUrl="/ditta/ctrl/modificaSerraCtrl.jsp?pageFrom=bis";
  String validateUrl="/ditta/view/elencoSerraBisView.jsp";
  String insertUrl="/ditta/ctrl/nuovaSerraCtrl.jsp?pageFrom=bis";
  String deleteUrl="/ditta/ctrl/confermaEliminaSerraCtrl.jsp?pageFrom=bis";
  String giorniRiscaldamentoUrl="/ditta/ctrl/giorniRiscaldSerraCtrl.jsp?pageFrom=bis";
  
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  String info=(String)session.getAttribute("notifica");
  if (info!=null)
  {
    findData(request,umaClient,idDittaUma,url);
    session.removeAttribute("notifica");
    throwValidation(info,validateUrl);
  }

  SolmrLogger.debug(this,"[elencoSerreBisCtrl::service] *************************** idDittaUma "+idDittaUma);
  if (request.getParameter("inserisci.x")!=null)
  {
    %><jsp:forward page="<%=insertUrl%>" /><%
    return;
  }
  else
  {
    if (request.getParameter("modifica.x")!=null)
    {
      try
      {
        SerraVO serraVO=(SerraVO) umaClient.findSerraByPrimaryKey(new Long(request.getParameter("radiobutton")));
        if (serraVO.getDataFineValidita()!=null)
        {
          throw new Exception("La serra non è modificabile perchè si riferisce ad un dato storicizzato");
        }
        request.setAttribute("serraVO",serraVO);
      }
      catch(Exception e)
      {
        request.setAttribute("errorMessage",e.getMessage());
        %><jsp:forward page = "<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
        return;
      }
      %><jsp:forward page="<%=modificaUrl%>" /><%
    }
    else
    {
      if (request.getParameter("elimina.x")!=null)
      {
        try
        {
          // Eliminazione serra
          SerraVO serraVO=(SerraVO) umaClient.findSerraByPrimaryKey(new Long(request.getParameter("radiobutton")));
          if (serraVO.getDataFineValidita()!=null)
          {
            throw new Exception("La serra non è modificabile perchè si riferisce ad un dato storicizzato");
          }
          %><jsp:forward page="<%=deleteUrl%>" /><%
        }
        catch(Exception e)
        {
          request.setAttribute("errorMessage",e.getMessage());
          %><jsp:forward page = "<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
          return;
        }
      }
      else if(request.getParameter("giorniRiscaldamento.x")!=null){
  	    SolmrLogger.debug(this, "--- giorniRiscaldamento ---");
  	    try
  	      {
  	        SerraVO serraVO=(SerraVO) umaClient.findSerraByPrimaryKey(new Long(request.getParameter("radiobutton")));
  	        /*if (serraVO.getDataFineValidita()!=null)
  	        {
  	          throw new Exception("La serra non è modificabile perchè si riferisce ad un dato storicizzato");
  	        }*/
  	        request.setAttribute("serraVO",serraVO);
  	      }
  	      catch(Exception e)
  	      {
  	        request.setAttribute("errorMessage",e.getMessage());
  	        %><jsp:forward page = "<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
  	        return;
  	      }
  	      %><jsp:forward page="<%=giorniRiscaldamentoUrl%>" /><%
  		  
  	  }
      else
      {
         // Visualizzazione Serre
        findData(request,umaClient,idDittaUma,url);
        %><jsp:forward page="<%=url%>" /><%
      }
    }
  }
%>

<%!
  private String dateStr(Date date)
  {
    if (date!=null)
    {
      return DateUtils.formatDate(date);
    }
    else
    {
      return "";
    }
  }
  private void findData(HttpServletRequest request,UmaFacadeClient umaClient,Long idDittaUma,String validateUrl)
      throws ValidationException
  {
    try
    {
      Vector serre=umaClient.getAllSerre(idDittaUma);
      request.setAttribute("elencoSerre",serre);
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
