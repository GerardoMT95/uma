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

  String iridePageName = "confermaEliminaMatriciCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


   UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

   String validateUrl = request.getParameter("messaggio");
   String eliminaMatriciOkUrl = "/macchina/view/eliminaMatriciOkView.jsp";

   ValidationErrors errors = new ValidationErrors();

   if(request.getParameter("conferma") != null) {
     String matrice = request.getParameter("idMatrice");
     Long idMatrice = Long.decode(matrice);
     try {
       umaFacadeClient.deleteMatrice(idMatrice);
     }
     catch(SolmrException se) {
       ValidationError error = new ValidationError(se.getMessage());
       errors.add("error",error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(validateUrl).forward(request, response);
       return;
     }
     %>
        <jsp:forward page="<%= eliminaMatriciOkUrl %>"/>
     <%
   }
   if(request.getParameter("annulla") != null) {
     %>
        <jsp:forward page="<%= validateUrl %>"/>
     <%
   }
%>
