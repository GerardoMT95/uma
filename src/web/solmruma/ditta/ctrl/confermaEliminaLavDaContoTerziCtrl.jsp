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

  String iridePageName = "confermaEliminaLavContoTerziCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient umaClient = new UmaFacadeClient();
  String url="/ditta/ctrl/elencoLavDaContoTerziCtrl.jsp";
  String viewUrl="/ditta/view/confermaEliminaLavDaContoTerziView.jsp";
  String elenco="/ditta/ctrl/elencoLavDaContoTerziCtrl.jsp";
  String elencoBis="/ditta/ctrl/elencoLavDaContoTerziBisCtrl.jsp";
  String elencoHtm="../../ditta/layout/elencoLavDaContoTerzi.htm";
  String elencoBisHtm="../../ditta/layout/elencoLavDaContoTerziBis.htm";
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  Long[] idLavContoTerzi = (Long[])session.getAttribute("vLavDaContoTerzi");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  

  if (request.getParameter("conferma.x")!=null)
  {
    SolmrLogger.debug(this,"idDittaUma="+idDittaUma);
    
    
    SolmrLogger.debug(this,"conferma.x");
    // Eliminazione lavorazioni conto terzi
    try
    {
      	umaClient.deleteLavContoTerzi(idLavContoTerzi,ruoloUtenza.getIdUtente());
      	session.setAttribute("notifica","Eliminazione eseguita con successo");
    }
    catch(Exception e)
    {
      throwValidation(e.getMessage(),url);
    }

    String forwardUrl=elencoHtm;
    if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
    {
      forwardUrl=elencoBisHtm;
    }
    SolmrLogger.debug(this,"\n\n\n#################forwardUrl: "+forwardUrl);
   
    response.sendRedirect(forwardUrl);
    return;
    
  }
  else
  {
    if (request.getParameter("annulla.x")!=null)
    {
      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
      {
        response.sendRedirect(elencoBisHtm);
      }
      else
      {
        response.sendRedirect(elencoHtm);
      }
      return;
    }
    else{
      SolmrLogger.debug(this,"visualizza");
      %>
      <jsp:forward page="<%=viewUrl%>"/>
      <%
    }
  }
%>
SolmrLogger.debug(this,"confermaEliminaLavDaContoTerziCtrl - End");

<%!
private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException(msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}

%>
