<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="java.lang.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  public static String MSG_SUCCESS = "Eliminazione eseguita con successo";
  public static String ELENCO_URL = "../layout/elencoAllevamento.htm";
  public static String ELENCO_URL_BIS = "../layout/elencoAllevamentoBis.htm";
  public static String VALIDATE_URL = "/ditta/ctrl/elencoAllevamentoCtrl.jsp";
  public static String VALIDATE_URL_BIS = "/ditta/ctrl/elencoAllevamentoBisCtrl.jsp";
  public static String VIEW = "/ditta/view/confermaEliminaAllevamentoView.jsp";
%>
<%

  String iridePageName = "confermaEliminaAllevamentoCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient umaClient = new UmaFacadeClient();
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  if (request.getParameter("conferma.x")!=null)
  {
    SolmrLogger.debug(this,"----------------------------- CONFERMA ELIMINA -----------------------------");
    try
    {
      SolmrLogger.debug(this,"idAllevamento="+request.getParameter("radiobutton"));
      SolmrLogger.debug(this,"idDittaUma="+idDittaUma);
      umaClient.deleteAllevamento(new Long(request.getParameter("radiobutton")),idDittaUma, ruoloUtenza);
      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
      {
        session.setAttribute("notifica",MSG_SUCCESS);
        response.sendRedirect(ELENCO_URL_BIS);
        return;
      }
      else
      {
        session.setAttribute("notifica",MSG_SUCCESS);
        response.sendRedirect(ELENCO_URL);
        return;
      }
    }
    catch(Exception e)
    {
      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
      {
        throwValidation(e.getMessage(),VALIDATE_URL_BIS);
      }
      else
      {
        throwValidation(e.getMessage(),VALIDATE_URL);
      }
    }
    SolmrLogger.debug(this,"------------------------------- FINE ELIMINA -------------------------------");
  }
  else
  {
    if (request.getParameter("annulla.x")!=null)
    {
      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
      {
        response.sendRedirect(ELENCO_URL_BIS);
        return;
      }
      else
      {
        response.sendRedirect(ELENCO_URL);
        return;
      }
    }
    else
    {
        %><jsp:forward page="<%=VIEW%>" /><%
    }
  }

%>
<%!
  private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException(msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }
%>
