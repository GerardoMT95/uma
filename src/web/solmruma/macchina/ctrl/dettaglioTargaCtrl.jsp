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
  private static final String VIEW="/macchina/view/dettaglioTargaView.jsp";
  private static final String ELENCO="../layout/ElencoMacchine.htm";
  private static final String DETTAGLIO="../layout/dettaglioMacchinaDittaImmatricolazioni.htm";
%>
<%

  String iridePageName = "dettaglioTargaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  Long idMovimentiTarga = null;
  if(request.getParameter("idMovimentiTarga")!=null)
  {
    SolmrLogger.debug(this,"############### request.getParameter(\"idMovimentiTarga\") : "+request.getParameter("idMovimentiTarga"));
    idMovimentiTarga=new Long(request.getParameter("idMovimentiTarga"));
  }
  if(request.getAttribute("idMovimentiTarga")!=null)
  {
    idMovimentiTarga=new Long(request.getParameter("idMovimentiTarga"));
  }
  UmaFacadeClient umaClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  MacchinaVO mavo = new MacchinaVO();
  if(session.getAttribute("common") instanceof MacchinaVO)
  {
    mavo = (MacchinaVO)session.getAttribute("common");
  }

  if (request.getParameter("chiudi")!=null)
  {
    //    request.setAttribute();
    response.sendRedirect(DETTAGLIO);
    return;
  }

  MovimentiTargaVO mtvo = null;
  try
  {
    mtvo = (MovimentiTargaVO)umaClient.getMovimentazioneById(idMovimentiTarga);
    request.setAttribute("mtvo", mtvo);
  }
  catch(Exception e)
  {
    throwValidation(e.getMessage(), VIEW);
    return;
  }

  %><jsp:forward page="<%=VIEW%>" /><%
%>

<%!
private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException("Eccezione : "+msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}
%>