<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.etc.uma.*"%>
<%

  String iridePageName = "listaMatriciCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


   UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

   String ricercaMatriceUrl = "/macchina/view/ricercaMatriceView.jsp";
   String listaMatriciUrl = "/macchina/view/listaMatriciView.jsp";

   ValidationErrors errors = new ValidationErrors();

   if(request.getParameter("operazione") != null && !request.getParameter("operazione").equals("")) {
     String indice = request.getParameter("valoreIndice");
     session.setAttribute("indice",indice);
     %>
       <jsp:forward page="<%= listaMatriciUrl %>"/>
     <%
   }
%>
