<%@ page language="java"
         contentType="text/html"
 %>
 
 <%@ page import="it.csi.solmr.util.*" %>
 <%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
 
<%

  String iridePageName = "dettaglioBuonoCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%
 SolmrLogger.debug(this,"- dettaglioBuonoCtrl.jsp -  INIZIO PAGINA");
 String url = "/domass/view/dettaglioBuonoView.jsp";

 if(request.getParameter("indietro")!= null&&!request.getParameter("indietro").equals("")){
   url = "/domass/layout/elencoBuoniEmessi.htm";
   session.removeAttribute("v_carb");
   request.setAttribute("comeBack", "true");
 }

 SolmrLogger.debug(this,"- dettaglioBuonoCtrl.jsp -  FINE PAGINA");
%>
<jsp:forward page="<%=url%>"/>