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
  String iridePageName = "dettaglioAziendaSedeCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  String validateUrl = "/anag/view/dettaglioAziendaSedeView.jsp";
  String errorPage = "/anag/view/dettaglioAziendaSedeView.jsp";
  String dettaglioURL = "/anag/view/dettaglioAziendaSedeView.jsp";

  it.csi.solmr.client.anag.AnagFacadeClient anagClient = new AnagFacadeClient();
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Validator validator = new Validator(validateUrl);
  if(request.getParameter("note")!= null){
    session.setAttribute("dettaglioURL", dettaglioURL);
  %>
  <jsp:forward page = "/anag/view/dettaglioAziendaNoteView.jsp" />
  <%
  }
  else{
  %>
  <jsp:forward page = "/anag/view/dettaglioAziendaSedeView.jsp" />
  <%
  }

%>

