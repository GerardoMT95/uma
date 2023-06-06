<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@page import="it.csi.solmr.dto.uma.AttestatoProprietaVO"%>
<%!
  public static String ELENCO_URL = "../layout/dettaglioMacchinaDittaComproprietari.htm";
  public static String VALIDATE_URL = "/macchina/view/attestazioniDittaCtrl.jsp";
  public static String VIEW = "/macchina/view/confermaEliminaAttestatoProprietaView.jsp";
%>
<%

  String iridePageName = "confermaEliminaAttestatoProprietaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%
  
  UmaFacadeClient umaClient = new UmaFacadeClient();
  
  if(session.getAttribute("common") instanceof MacchinaVO){
    SolmrLogger.debug(this,"Instance of MacchinaVO");
    MacchinaVO macchinaVO = (MacchinaVO)session.getAttribute("common");
    if (macchinaVO!=null && umaClient.isBloccoMacchinaImportataAnagrafe(macchinaVO)) 
    {  
      it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::errorMessage!=null] utente non abilitato: "+it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
      request.setAttribute("errorMessage",it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
      %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
      return;
    }
  }

  if (request.getParameter("conferma")!=null)
  {
    String sRadioAttestazione = request.getParameter("radioAttestazione");
    Long idAttestazioneProprieta=getIdAttestatoProprieta(sRadioAttestazione);
    umaClient.deleteAttestatoProprieta(idAttestazioneProprieta);
    response.sendRedirect(ELENCO_URL);
    return;
  }
  else
  {
    if (request.getParameter("annulla")!=null)
    {
      response.sendRedirect(ELENCO_URL);
      return;
    }
    else
    {
      String sRadioAttestazione = request.getParameter("radioAttestazione");
      Long idAttestazioneProprieta=getIdAttestatoProprieta(sRadioAttestazione);
      AttestatoProprietaVO apVO=umaClient.getAttestatoProprietaById(idAttestazioneProprieta);
      request.setAttribute("attestatoProprietaVO",apVO); 
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
  
  private Long getIdAttestatoProprieta(String value)
  {
    if (value==null)
    {
      SolmrLogger.error(this,"[confermaEliminaAttestatoProprietaCtrl::service] idAttestatoProprieta is NULL ==> seguirà eccezione di NullPointer");
      return null;
    }
    try
    {
      return new Long(value.trim());
    }
    catch(Exception e)
    {
      SolmrLogger.error(this,"[confermaEliminaAttestatoProprietaCtrl::service] idAttestatoProprieta NON NUMERICO ==> seguirà eccezione di NullPointer");
      return null;
    }
  }
%>