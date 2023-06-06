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

  SolmrLogger.debug(this, "   BEGIN confermaEliminaLavCtrl");

  UmaFacadeClient umaClient = new UmaFacadeClient();
  String url="/ditta/ctrl/elencoLavContoTerziCtrl.jsp";
  String viewUrl="/ditta/view/confermaEliminaLavContoTerziView.jsp";
  String elenco="/ditta/ctrl/elencoLavContoTerziCtrl.jsp";
  String elencoBis="/ditta/ctrl/elencoLavContoTerziBisCtrl.jsp";
  String elencoHtm="../../ditta/layout/elencoLavContoTerzi.htm";
  String elencoBisHtm="../../ditta/layout/elencoLavContoTerziBis.htm";
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  Long[] idLavContoTerzi = (Long[])session.getAttribute("vLavContoTerzi");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  
  SolmrLogger.debug(this,"Sono in confermaEliminaLavContoTerziCtrl...");
  if (request.getParameter("conferma.x")!=null)
  {
    SolmrLogger.debug(this,"idDittaUma="+idDittaUma);    
    SolmrLogger.debug(this,"conferma.x");
    // Eliminazione lavorazioni conto terzi
    try
    {
     	SolmrLogger.debug(this,"idLavContoTerzi="+idLavContoTerzi);      
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
   
    // viene utilizzato per mantenere i filtri settati in fase di ricerca nella pagina di Elenco lavorazioni
	session.setAttribute("paginaChiamante", "elimina");
   
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
      
      // viene utilizzato per mantenere i filtri settati in fase di ricerca nella pagina di Elenco lavorazioni
	  session.setAttribute("paginaChiamante", "elimina");
      return;
    }
    else
    {
      SolmrLogger.debug(this,"visualizza");
      %>
      <jsp:forward page="<%=viewUrl%>"/>
      <%
    }
  }
%>
SolmrLogger.debug(this,"confermaEliminaLavContoTerziCtrl - End");

<%!
private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException(msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}

%>
