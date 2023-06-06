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
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String iridePageName = "confermaRipristinoCaricoCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "   BEGIN confermaRipristinoCaricoCtrl");
  
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  ValidationErrors errors = new ValidationErrors();

  UmaFacadeClient umaClient = new UmaFacadeClient();
  AnagFacadeClient anagClient = new AnagFacadeClient();
  String viewUrl="/macchina/view/confermaRipristinoCaricoView.jsp";
  String annullaUrl="/macchina/layout/dettaglioMacchinaDittaUtilizzo.htm";
  String confermaUrl="/macchina/layout/dettaglioMacchinaDittaUtilizzo.htm";
  String errorCtrl = "/ctrl/dettaglioMacchinaDittaUtilizzoCtrl.jsp";
  String errorPage = "/macchina/view/confermaRipristinoCaricoView.jsp";
  String url = "";

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  if(request.getParameter("conferma")!=null){
    url = confermaUrl;
    UtilizzoVO uVO = null;
    MacchinaVO mVO = (MacchinaVO)session.getAttribute("ripristinaCaricoMacchinaVO");
    if (mVO!=null && umaClient.isBloccoMacchinaImportataAnagrafe(mVO)) 
    {  
      it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::errorMessage!=null] utente non abilitato: "+it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
      request.setAttribute("errorMessage",it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
      %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
      return;
    }
    if(mVO.getUtilizzoVO()!=null)
      uVO = mVO.getUtilizzoVO();
    if(uVO!=null){
      try{
        umaClient.ripristinaCaricoMacchina(ruoloUtenza, uVO.getIdUtilizzoLong());
      }
      catch(SolmrException sex){
        ValidationError error = new ValidationError(sex.getMessage());
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(errorCtrl).forward(request, response);
        SolmrLogger.debug(this, "   END confermaRipristinoCaricoCtrl");
        return;
      }
    }
  }
  else if(request.getParameter("annulla")!=null){
    url = annullaUrl;
  }
  else{
    session.removeAttribute("ripristinaCaricoMacchinaVO");
    url = viewUrl;
    UtilizzoVO uVO = (UtilizzoVO)session.getAttribute("dittaUtilizzoVO");
    String idUtilizzoStr = null;
    if(uVO!=null)
      idUtilizzoStr = uVO.getIdUtilizzo();
    else
      idUtilizzoStr = request.getParameter("idUtilizzo");

    Long idUtilizzo = null;
    if(idUtilizzoStr!=null && !idUtilizzoStr.equals("")){
      idUtilizzo = new Long(idUtilizzoStr);
    }
    try{
      MacchinaVO mVO = umaClient.checkRipristinaCaricoMacchina(ruoloUtenza,idDittaUma, idUtilizzo);
      if (mVO!=null && umaClient.isBloccoMacchinaImportataAnagrafe(mVO)) 
      {  
        it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::errorMessage!=null] utente non abilitato: "+it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
        request.setAttribute("errorMessage",it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
        %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
        return;
      }
      session.setAttribute("ripristinaCaricoMacchinaVO", mVO);
    }
    catch(SolmrException sex){
      SolmrLogger.error(this,sex.getMessage());
      ValidationError error = new ValidationError(sex.getMessage());
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(errorCtrl).forward(request, response);
      SolmrLogger.debug(this, "   END confermaRipristinoCaricoCtrl");
      return;
    }
  }
  
  SolmrLogger.debug(this, "   END confermaRipristinoCaricoCtrl");
 %><jsp:forward page="<%=url%>" /><%
%>