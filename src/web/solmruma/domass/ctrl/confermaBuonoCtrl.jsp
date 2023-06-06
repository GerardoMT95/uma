<%@ page language="java"
         contentType="text/html"
 %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.SolmrConstants" %>
<%@ page import="it.csi.solmr.dto.CodeDescr" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="java.util.*"%>

<%

  String iridePageName = "confermaBuonoCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

 String url = "/domass/view/confermaBuonoView.jsp";

 if(request.getParameter("confermaOperazione")!=null){
   url = "/domass/layout/elencoBuoniEmessi.htm";
 }
 else if(request.getParameter("chiudi")!=null){
   url = "/domass/layout/elencoBuoniEmessi.htm";
   request.setAttribute("comeBack", "true");
 }

 SolmrLogger.debug(this,"- confermaBuonoCtrl.jsp -  FINE PAGINA");
%>
<jsp:forward page="<%=url%>"/>