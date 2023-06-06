 <%@ page language="java"
     contentType="text/html"
     isErrorPage="true"
 %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>

<%

    String iridePageName = "dettaglioAziendaRappCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  String validateUrl = "/anag/view/dettaglioAziendaRappView.jsp";
  String errorPage = "/anag/view/dettaglioAziendaRappView.jsp";

  it.csi.solmr.client.anag.AnagFacadeClient anagClient = new AnagFacadeClient();
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Validator validator = new Validator(validateUrl);
  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
  PersonaFisicaVO pfVO = (PersonaFisicaVO)session.getAttribute("personaVO");

  String dettaglioURL = "/anag/view/dettaglioAziendaRappView.jsp";

  if(request.getParameter("note")!= null){
    session.setAttribute("dettaglioURL",dettaglioURL);
    %>
      <jsp:forward page = "/anag/view/dettaglioAziendaNoteView.jsp" />
    <%
  }
  else{
    if(dittaVO!=null){
      if(pfVO==null){
        try{
          pfVO = anagClient.getTitolareORappresentanteLegaleAzienda(dittaVO.getIdAzienda(), new Date(System.currentTimeMillis()));
          session.setAttribute("personaVO",pfVO);
        }
        catch (SolmrException sex) {
          ValidationErrors errors = new ValidationErrors();
          ValidationError error = new ValidationError(sex.getMessage());
          errors.add("error", error);
          request.setAttribute("errors", errors);
          request.getRequestDispatcher(errorPage).forward(request, response);
          return;
        }
      }
      %>
        <jsp:forward page = "/anag/view/dettaglioAziendaRappView.jsp" />
      <%
      }
  }

%>

