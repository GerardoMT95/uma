<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%!
  public static final String VIEW="../view/confermaEliminaUltimaMovimentazioneView.jsp";
  private static final String DETTAGLIO="../macchina/layout/dettaglioMacchinaDittaImmatricolazioni.htm";
%>
<%
  String iridePageName = "confermaEliminaUltimaMovimentazioneCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%
  UmaFacadeClient umaClient = new UmaFacadeClient();
  
  MacchinaVO mavo = new MacchinaVO();
  if(session.getAttribute("common") instanceof MacchinaVO)
    mavo = (MacchinaVO)session.getAttribute("common");
    
  if (mavo!=null && umaClient.isBloccoMacchinaImportataAnagrafe(mavo)) 
  {  
    it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::errorMessage!=null] utente non abilitato: "+it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
    request.setAttribute("errorMessage",it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
    %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
    return;
  }
  
  if (request.getParameter("submit")!=null)
  {
    Long idMacchina = mavo.getIdMacchinaLong();
    umaClient.eliminaUltimaImmatricolazioneByIdMacchina(idMacchina);
    session.setAttribute("common", umaClient.getMacchinaById(idMacchina));
    response.sendRedirect(DETTAGLIO);
    return;
  }
  if (request.getParameter("submit2")!=null)
  {
    response.sendRedirect(DETTAGLIO);
    return;
  }
%>
<jsp:forward page="<%=VIEW%>" />
