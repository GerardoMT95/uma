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

  String iridePageName = "caricoMacchinaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "   BEGIN caricoMacchinaCtrl");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  ValidationErrors errors = new ValidationErrors();

  UmaFacadeClient umaClient = new UmaFacadeClient();
  AnagFacadeClient anagClient = new AnagFacadeClient();
  String viewUrl="/macchina/view/caricoMacchinaView.jsp";
  String annullaUrl="/macchina/layout/dettaglioMacchinaDittaUtilizzo.htm";
  String salvaUrl="/macchina/layout/dettaglioMacchinaDittaUtilizzo.htm";
  String errorCtrl = "../ctrl/dettaglioMacchinaDittaUtilizzoCtrl.jsp";
  String errorPage = "/macchina/view/caricoMacchinaView.jsp";
  String url = "";

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  MacchinaVO macchinaVO = (MacchinaVO) session.getAttribute("dittaMacchinaVO");
  
  if (macchinaVO!=null && umaClient.isBloccoMacchinaImportataAnagrafe(macchinaVO)) 
  {  
    it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::errorMessage!=null] utente non abilitato: "+it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
    request.setAttribute("errorMessage",it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
    %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
    return;
  }

  if(request.getParameter("salva")!=null){
    SolmrLogger.debug(this, "----- CASO salva carico macchina");
    url = salvaUrl;
    UtilizzoVO uVO = new UtilizzoVO();
    PossessoVO pVO = new PossessoVO();

    uVO.setDittaUma(request.getParameter("dittaUma"));
    uVO.setIdProvUma(request.getParameter("provUma"));
    uVO.setDataCarico(request.getParameter("dataCarico"));

    if(macchinaVO!=null)
      uVO.setIdMacchinaLong(macchinaVO.getIdMacchinaLong());

    pVO.setIdFormaPossesso(request.getParameter("idFormaPossesso"));
    pVO.setDataScadenzaLeasing(request.getParameter("dataScadenzaLeasing"));
    SolmrLogger.debug(this, "---- data scadenza ="+pVO.getDataScadenzaLeasing());
    pVO.setExtIdAzienda(request.getParameter("idSocietaLeasing"));

    if(!request.getParameter("idSocietaLeasing").equals("")){
      Long idAziendaLong = new Long(pVO.getExtIdAzienda());
      AnagAziendaVO aaVO = anagClient.findAziendaAttiva(idAziendaLong);
      String rappLegale = anagClient.getRappLegaleTitolareByIdAzienda(idAziendaLong);
      aaVO.setRappresentanteLegale(rappLegale);
      request.setAttribute("dittaLeasing", aaVO);
    }

    if(pVO.getIdFormaPossesso()!=null && !pVO.getIdFormaPossesso().equals(""))
      pVO.setIdFormaPossessoLong(new Long(pVO.getIdFormaPossesso()));
    else
      pVO.setIdFormaPossessoLong(null);
    if(pVO.getDataScadenzaLeasing()!=null && !pVO.getDataScadenzaLeasing().equals(""))
      pVO.setDataScadenzaLeasingDate(DateUtils.parseDate(pVO.getDataScadenzaLeasing()));
    else
      pVO.setDataScadenzaLeasingDate(null);
    if(pVO.getExtIdAzienda()!=null && !pVO.getExtIdAzienda().equals(""))
      pVO.setExtIdAziendaLong(new Long(pVO.getExtIdAzienda()));
    else
      pVO.setExtIdAziendaLong(null);
    pVO.setDataFineValiditaDate(null);

    uVO.setLastPossessoVO(pVO);
	
	SolmrLogger.debug(this, "--- VALIDAZIONE CAMPI");
    errors = uVO.validateCaricoMacchina();

    if (!(errors == null || errors.size() == 0)) {
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(errorPage).forward(request, response);
      return;
    }

    try{
      umaClient.caricoAltraDitta(ruoloUtenza, uVO);
    }
    catch(SolmrException sex){
      ValidationError error = new ValidationError(sex.getMessage());
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(errorCtrl).forward(request, response);
      return;
    }
  }
  else if(request.getParameter("annulla")!=null){
    url = annullaUrl;
  }
  else{

    url = viewUrl;
    try
    {
      umaClient.isDittaUmaCessata(idDittaUma);
      umaClient.isDittaUmaBloccata(idDittaUma);

      if(request.getParameter("idSocietaLeasing")!=null && !request.getParameter("idSocietaLeasing").equals("")){
        Long idAziendaLong = new Long(request.getParameter("idSocietaLeasing"));
        AnagAziendaVO aaVO = anagClient.findAziendaAttiva(idAziendaLong);
        String rappLegale = anagClient.getRappLegaleTitolareByIdAzienda(idAziendaLong);
        aaVO.setRappresentanteLegale(rappLegale);
        request.setAttribute("dittaLeasing", aaVO);
      }
    }
    catch(Exception ex)
    {
      ValidationError error = new ValidationError(ex.getMessage());
      errors.add("error", error);
      request.setAttribute("errors", errors);
      url=annullaUrl;
    }
  }

  SolmrLogger.debug(this, "   END caricoMacchinaCtrl");
 %><jsp:forward page="<%=url%>" /><%
%>