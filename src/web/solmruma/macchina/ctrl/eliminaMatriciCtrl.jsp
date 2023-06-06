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

  String iridePageName = "eliminaMatriciCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


   UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

   String validateUrl = request.getParameter("pagina");
   String confermaEliminaMatriciUrl = "/macchina/view/confermaEliminaMatriciView.jsp";

   ValidationErrors errors = new ValidationErrors();

   String matrice = request.getParameter("idMatrice");
   Long idMatrice = Long.decode(matrice);
   boolean result = false;
   // Controllo che la matrice non sia legata ad una macchina
   try {
     result = umaFacadeClient.isMatriceCollegataMacchine(idMatrice);
   }
   catch(SolmrException se) {
     ValidationError error = new ValidationError(se.getMessage());
     errors.add("error",error);
     request.setAttribute("errors", errors);
     request.getRequestDispatcher(validateUrl).forward(request, response);
     return;
   }
   // Se lo è avviso l'utente
   if(result == true) {
     ValidationError error = new ValidationError((String)UmaErrors.get("ERR_MATRICE_LEGATA_MACCHINE"));
     errors.add("error",error);
     request.setAttribute("errors", errors);
     request.getRequestDispatcher(validateUrl).forward(request, response);
     return;
   }
   // Se non lo è procedo chiedo conferma all'utente
   %>
      <jsp:forward page="<%= confermaEliminaMatriciUrl %>">
      <jsp:param name="messaggio" value="<%=validateUrl%>"/>
      <jsp:param name="idMatrice" value="<%=idMatrice%>"/>
      </jsp:forward>
   <%
%>
