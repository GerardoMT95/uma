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
  public static String RICERCA = "/../../anag/layout/ricercaAzienda.htm";
  public static String DETTAGLIO = "../../anag/layout/dettaglioAzienda.htm";
  public static String DETTAGLIO_CTRL = "/anag/ctrl/dettaglioAziendaControl.jsp";
  public static String VIEW = "/anag/view/confermaEliminaDittaUmaView.jsp";
%>
<%

  String iridePageName = "confermaEliminaDittaUmaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient umaClient = new UmaFacadeClient();
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  SolmrLogger.debug(this,"[confermaEliminaDittaUmaCtrl::service] idUtente="+ruoloUtenza.getIdUtente());

  if (request.getParameter("conferma.x")!=null)
  {
    SolmrLogger.debug(this,"[confermaEliminaDittaUmaCtrl::service] ----------------------------- CONFERMA ELIMINA -----------------------------");
    try
    {
      umaClient.deleteDittaUMA(idDittaUma, ruoloUtenza);
      session.removeAttribute("dittaUMAAziendaVO");
    }
    catch(Exception e)
    {
      throwValidation(e.getMessage(),VIEW);
    }
//    response.sendRedirect(RICERCA);
    SolmrLogger.debug(this,"[confermaEliminaDittaUmaCtrl::service] ------------------------------- FINE ELIMINA -------------------------------");
  }
  else
  {
    if (request.getParameter("annulla.x")!=null)
    {
        response.sendRedirect(DETTAGLIO);
        return;
    }
    else
    {
      umaClient.isDittaUmaBloccata(idDittaUma);
    }
  }
%>
<jsp:forward page="<%=VIEW%>" />
<%!
 private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException(msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }
%>
