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
<%@ page import="it.csi.solmr.dto.uma.*" %>

<%

  String iridePageName = "numeroDittaUmaControl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  if(request.getParameter("chiudi.x") != null) {
    session.removeAttribute("dittaUma");
    session.removeAttribute("anagAziendaVO");
    %>
       <jsp:forward page = "/uma/anag/view/dettaglioAziendaView.jsp" />
    <%
  }

%>

