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

  String iridePageName = "confermaInserimentoMatriciOmologazioneCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


   UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

   String inserimentoMatriciUrl = "/macchina/view/inserimentoMatriciView.jsp";
   String inserimentoMatriciOkUrl = "/macchina/view/inserimentoMatriciOkView.jsp";
   String confermaInserimentoMatriciOmologazioneUrl = "/macchina/view/confermaInserimentoMatriciOmologazioneView.jsp";

   ValidationErrors errors = new ValidationErrors();

   if(request.getParameter("conferma") != null) {
     MatriceVO inserisciMatriceVO = (MatriceVO)session.getAttribute("inserimentoMatriceVO");
     Long primaryKey = null;
     try {
       primaryKey = umaFacadeClient.insertMatrice(inserisciMatriceVO);
     }
     catch(SolmrException se) {
       ValidationError error = new ValidationError(se.getMessage());
       errors.add("error",error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(confermaInserimentoMatriciOmologazioneUrl).forward(request, response);
       return;
     }
     // Recupero la matrice e la mando alla pagina di inserimento effettuato
     MatriceVO matriceVO = null;
     try {
       matriceVO = umaFacadeClient.getMatrice(primaryKey);
     }
     catch(SolmrException se) {
       ValidationError error = new ValidationError(se.getMessage());
       errors.add("error",error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(confermaInserimentoMatriciOmologazioneUrl).forward(request, response);
       return;
     }
     session.removeAttribute("inserisciMatriceVO");
     session.setAttribute("matriceVO",matriceVO);
     %>
        <jsp:forward page="<%= inserimentoMatriciOkUrl %>"/>
     <%
   }
   if(request.getParameter("annulla") != null) {
     %>
        <jsp:forward page="<%= inserimentoMatriciUrl %>"/>
     <%
   }
%>
