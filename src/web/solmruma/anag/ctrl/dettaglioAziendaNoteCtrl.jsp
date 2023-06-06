 <%@ page language="java"
     contentType="text/html"
     isErrorPage="true"
 %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>

<%

  String iridePageName = "dettaglioAziendaNoteCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  String errorPage = "/anag/view/dettaglioAziendaView.jsp";
  //String validateUrl = "/anag/view/dettaglioAziendaNoteView.jsp";

  UmaFacadeClient umaClient = new UmaFacadeClient();
  //Validator validator = new Validator(validateUrl);

  ValidationException valEx = null;
  if(request.getParameter("indietro") != null){

    String dettaglioURL = (String)session.getAttribute("dettaglioURL");
    if(dettaglioURL==null)
      dettaglioURL = "/anag/view/dettaglioAziendaView.jsp";
    session.removeAttribute("dettaglioURL");

    %>
       <jsp:forward page="<%= dettaglioURL %>"/>
    <%
  }

  else{

    if(session.getAttribute("dittaUMAAziendaVO")!=null){
      %>
        <jsp:forward page = "/anag/view/dettaglioAziendaNoteView.jsp" />
      <%
    }
    else{
      ValidationErrors errors = new ValidationErrors();
      ValidationError error = new ValidationError("");
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(errorPage).forward(request, response);
      return;
    }
  }

%>

