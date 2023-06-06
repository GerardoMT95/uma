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

  String iridePageName = "scaricoMacchinaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  ValidationErrors errors = new ValidationErrors();

  UmaFacadeClient umaClient = new UmaFacadeClient();
  AnagFacadeClient anagClient = new AnagFacadeClient();
  String viewUrl="/macchina/view/scaricoMacchinaView.jsp";
  String annullaUrl="/macchina/layout/dettaglioMacchinaDittaUtilizzo.htm";
  String salvaUrl="/macchina/layout/dettaglioMacchinaDittaUtilizzo.htm";
  String errorCtrl = "/ctrl/dettaglioMacchinaDittaUtilizzoCtrl.jsp";
  String errorPage = "/macchina/view/scaricoMacchinaView.jsp";
  String url = "";

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  if(request.getParameter("salva")!=null)
  {
    MacchinaVO mVO = (MacchinaVO)session.getAttribute("scaricoMacchinaVO");
    if (mVO!=null && umaClient.isBloccoMacchinaImportataAnagrafe(mVO)) 
    {  
      it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::errorMessage!=null] utente non abilitato: "+it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
      request.setAttribute("errorMessage",it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
      %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
      return;
    }
  
  
    url = salvaUrl;
    UtilizzoVO uVO = null;
    if(mVO.getUtilizzoVO()!=null)
      uVO = mVO.getUtilizzoVO();
    if(uVO!=null){
      uVO.setIdScarico(request.getParameter("idMotivoScarico"));
      uVO.setDataScarico(request.getParameter("dataScarico"));

      errors = uVO.validateScaricoMacchina();
      if (!(errors == null || errors.size() == 0)) {
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(errorPage).forward(request, response);
        return;
      }

      if(uVO.getIdScarico()!=null && !uVO.getIdScarico().equals(""))
        uVO.setIdScaricoLong(new Long(uVO.getIdScarico()));
      else
        uVO.setIdScaricoLong(null);
      if(uVO.getDataScarico()!=null && !uVO.getDataScarico().equals(""))
        uVO.setDataScaricoDate(DateUtils.parseDate(uVO.getDataScarico()));
      else
        uVO.setDataScaricoDate(null);

      try{
        umaClient.scaricoMacchina(ruoloUtenza, uVO);
        session.removeAttribute("scaricoMacchinaVO");
      }
      catch(SolmrException sex){
        ValidationError error = new ValidationError(sex.getMessage());
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(errorCtrl).forward(request, response);
        return;
      }
    }
  }
  else if(request.getParameter("annulla")!=null){
    url = annullaUrl;
  }
  else{
    session.removeAttribute("scaricoMacchinaVO");
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
      MacchinaVO mVO = umaClient.checkScaricoMacchina(ruoloUtenza,idDittaUma, idUtilizzo);
      
      if (mVO!=null && umaClient.isBloccoMacchinaImportataAnagrafe(mVO)) 
      {  
        it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::errorMessage!=null] utente non abilitato: "+it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
        request.setAttribute("errorMessage",it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
        %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
        return;
      }
      
      session.setAttribute("scaricoMacchinaVO", mVO);
    }
    catch(SolmrException sex){
      SolmrLogger.debug(this,sex.getMessage());
      ValidationError error = new ValidationError(sex.getMessage());
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(errorCtrl).forward(request, response);
      return;
    }
  }

 %><jsp:forward page="<%=url%>" /><%
%>