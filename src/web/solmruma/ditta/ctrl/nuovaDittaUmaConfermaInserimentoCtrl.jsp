 <%@ page language="java"
     contentType="text/html"
     isErrorPage="true"
 %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.anag.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%
//  String iridePageName = "nuovaDittaUmaConfermaInserimentoCtrl.jsp";
// include file = "/include/autorizzazione.inc"



  String url = "/ditta/view/nuovaDittaUmaConfermaInserimentoView.jsp";
  String chiudiUrl = "/anag/view/dettaglioAziendaView.jsp";
  String confermaUrl = "/ditta/view/nuovaDittaUmaConfermaInserimentoView.jsp";

  DittaUMAVO dittaUmaVO = (DittaUMAVO)session.getAttribute("dittaUmaVO");

  UmaFacadeClient umaClient = new UmaFacadeClient();

  ValidationErrors errors = new ValidationErrors();

  if(request.getParameter("indietro") != null) {
    DittaUMAAziendaVO dittaUmaAziendaVO = new DittaUMAAziendaVO();
    dittaUmaAziendaVO.setDittaUMA(new Long(dittaUmaVO.getDittaUMA()));
    dittaUmaAziendaVO.setProvUMA(dittaUmaVO.getExtProvinciaUMA());
    SolmrLogger.debug(this,"PARAMETRO 1:"+dittaUmaVO.getDittaUMA());
    SolmrLogger.debug(this,"PARAMETRO 2:"+dittaUmaVO.getExtProvinciaUMA());
    try {
      dittaUmaAziendaVO = umaClient.getDittaUMAAzienda(dittaUmaAziendaVO);
    }
    catch(SolmrException se) {
      ValidationError error = new ValidationError(""+UmaErrors.get("ERR_RICERCA_DITTA_AZIENDA"));
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(url).forward(request, response);
    }
    SolmrLogger.debug(this,"ID AZIENDA:::::: "+dittaUmaAziendaVO.getIdAzienda());
    session.setAttribute("dittaUMAAziendaVO",dittaUmaAziendaVO);
    %>
       <jsp:forward page = "<%= chiudiUrl %>" />
    <%
  }
  %>
    <jsp:forward page = "<%= url %>" />
  <%

%>

