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

  String iridePageName = "confermaModificaMatriciOmologazioneCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


   UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

   String modificaMatriciUrl = "/macchina/view/modificaMatriciView.jsp";
   String modificaMatriciOkUrl = "/macchina/view/modificaMatriciOkView.jsp";
   String confermaModificaMatriciOmologazioneUrl = "/macchina/view/confermaModificaMatriciOmologazioneView.jsp";

   ValidationErrors errors = new ValidationErrors();

   if(request.getParameter("conferma") != null) {
     MatriceVO modificaMatriceVO = (MatriceVO)session.getAttribute("matriceVO");
     try {
       umaFacadeClient.updateMatrice(modificaMatriceVO);
     }
     catch(SolmrException se) {
       ValidationError error = new ValidationError(se.getMessage());
       errors.add("error",error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(confermaModificaMatriciOmologazioneUrl).forward(request, response);
       return;
     }
     %>
        <jsp:forward page="<%= modificaMatriciOkUrl %>"/>
     <%
   }
   if(request.getParameter("annulla") != null) {
     %>
        <jsp:forward page="<%= modificaMatriciUrl %>"/>
     <%
   }
%>
