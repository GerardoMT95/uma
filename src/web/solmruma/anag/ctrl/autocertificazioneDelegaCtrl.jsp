<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>

<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.etc.anag.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%
  String iridePageName = "autocertificazioneDelegaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  AnagFacadeClient anagClient = new AnagFacadeClient();



  int sizeResult = 0;

  String errorPage = "/anag/view/elencoAziendeView.jsp";

  String annullaPage = "/anag/view/ricercaAziendaUMAView.jsp";

  String url = null;

  url = "/anag/view/autocertificazioneDelegaView.jsp";



  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");



  Validator validator = null;

  ValidationErrors errors = new ValidationErrors();

  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

  if(request.getParameter("salva") != null){

    UtenteIrideVO uiVO = (UtenteIrideVO)session.getAttribute("utenteIntermediario");



    try{

      AnagAziendaVO aaVO = new AnagAziendaVO();

      if(dittaVO!=null)

        aaVO.setIdAzienda(dittaVO.getIdAzienda());

      else

        throw new SolmrException("Impossibile accedere ai dati della ditta UMA");

      if(uiVO!=null && uiVO.getIdIntermediario()!=null)

        aaVO.setIdIntermediarioDelegato(uiVO.getIdIntermediario().toString());

      else

        throw new SolmrException("L''utente non risulta essere un intermediario");

      anagClient.dichiarazioneDelega(aaVO, ruoloUtenza);

      session.setAttribute("refreshDettaglio", "true");

      url = "/anag/view/dettaglioAziendaView.jsp";

    }

    catch(SolmrException sex){

      ValidationError error = new ValidationError(sex.getMessage());

      errors.add("error", error);

      request.setAttribute("errors", errors);

      request.getRequestDispatcher(errorPage).forward(request, response);

      return;

    }



  }

  else if(request.getParameter("annulla") != null){

    url = annullaPage;

  }





  %>

      <jsp:forward page ="<%=url%>" />

  <%



%>