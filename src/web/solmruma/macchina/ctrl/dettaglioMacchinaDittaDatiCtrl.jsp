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
  private static final String VIEW="../../macchina/view/dettaglioMacchinaDittaDatiView.jsp";
  private static final String ELENCO="../layout/elencoMacchine.htm";
  private static final String MODIFICA="../../macchina/ctrl/modificaMacchinaDittaDatiCtrl.jsp";
%>
<%

  String iridePageName = "dettaglioMacchinaDittaDatiCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  Long idMacchina = null;
  if(request.getParameter("idMacchina")!=null)
  {
    SolmrLogger.debug(this,"############### request.getParameter(\"idMacchina\") : "+request.getParameter("idMacchina"));
    idMacchina=new Long((String)request.getParameter("idMacchina"));
  }
  if(request.getAttribute("idMacchina")!=null)
  {
    idMacchina=new Long((String)request.getAttribute("idMacchina"));
  }
  UmaFacadeClient umaClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  MacchinaVO mavo = new MacchinaVO();
  if(session.getAttribute("common") instanceof MacchinaVO)
  {
    mavo = (MacchinaVO)session.getAttribute("common");
  }
  else
  {
    mavo= umaClient.getMacchinaById(idMacchina);
    session.setAttribute("common", mavo);
  }

  if (request.getParameter("elenco")!=null)
  {
    session.removeAttribute("common");
    response.sendRedirect(ELENCO);
    return;
  }

  if (request.getParameter("modifica")!=null)
  {
    try
    {
      if (mavo!=null && umaClient.isBloccoMacchinaImportataAnagrafe(mavo)) 
      {  
        it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::errorMessage!=null] utente non abilitato: "+it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
        request.setAttribute("errorMessage",it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
        %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
        return;
      }
    
      SolmrLogger.debug(this,"Entro nel try...");
      DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
      Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

      umaClient.isDittaUmaBloccata(idDittaUma);
      umaClient.isDittaUmaCessata(idDittaUma);
      umaClient.isMacchinaInCarico(idMacchina, idDittaUma);
      umaClient.isFunzionarioPAAutorizzato(ruoloUtenza, idDittaUma);
      SolmrLogger.debug(this,"Sto andando nella ctrl di modificaMacchinaDittaDati\n\n");

    }
    catch(Exception e)
    {
      SolmrLogger.debug(this,"Eccezione: "+e.getMessage());
      ValidationErrors errors = new ValidationErrors();
      ValidationError error = new ValidationError(e.getMessage());
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(VIEW).forward(request, response);
      return;
      //throwValidation(e.getMessage(),VIEW);
    }
  %><jsp:forward page="/macchina/ctrl/modificaMacchinaDittaDatiCtrl.jsp" /><%
  }

  %><jsp:forward page="<%=VIEW%>" /><%
%>

<%!
private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException(msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}
%>