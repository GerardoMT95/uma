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

  String iridePageName = "dettaglioMatriciCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


   UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

   String dettaglioMatriciUrl = "/macchina/view/dettaglioMatriciView.jsp";
   String listaMatriciUrl = "/macchina/view/listaMatriciView.jsp";

   ValidationErrors errors = new ValidationErrors();
   // Arrivo dalla pagina di dettaglio e l'utente ha selezionato la funzione "elenco"
   if(request.getParameter("operazione") != null && !request.getParameter("operazione").equals("")) {
     MatriceVO ricercaMatriceVO = (MatriceVO)session.getAttribute("ricercaMatriceVO");
     Vector elencoMatrici = (Vector)session.getAttribute("elencoMatrici");
     if(ricercaMatriceVO != null) {
       try {
         Long idGenereMacchina = null;
         Long idCategoria = null;
         if(ricercaMatriceVO.getIdGenereMacchina() != null && !ricercaMatriceVO.getIdGenereMacchina().equals("")) {
           idGenereMacchina = Long.decode(ricercaMatriceVO.getIdGenereMacchina());
         }
         if(ricercaMatriceVO.getIdCategoria() != null && !ricercaMatriceVO.getIdCategoria().equals("")) {
           idCategoria = Long.decode(ricercaMatriceVO.getIdCategoria());
         }
         elencoMatrici = umaFacadeClient.getListaMatrici(idGenereMacchina, idCategoria,
                                                         ricercaMatriceVO.getDescMarca(),
                                                         ricercaMatriceVO.getTipoMacchina(),
                                                         ricercaMatriceVO.getNumeroMatrice(),
                                                         ricercaMatriceVO.getNumeroOmologazione());
       }
       catch(SolmrException se) {
         ValidationError error = new ValidationError(se.getMessage());
         errors.add("error",error);
         request.setAttribute("errors", errors);
         request.getRequestDispatcher(dettaglioMatriciUrl).forward(request, response);
         return;
       }
     }
     %>
        <jsp:forward page="<%= listaMatriciUrl %>"/>
     <%
   }
   else {
     // Recupero l'id matrice selezionato dall'utente
     String matrice = request.getParameter("idMatrice");

     if(matrice == null || matrice.equals("")) {
       ValidationError error = new ValidationError("Selezionare una matrice");
       errors.add("error",error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(listaMatriciUrl).forward(request, response);
       return;
     }

     Long idMatrice = Long.decode(matrice);

     // Recupero l'oggetto matriceVO
     MatriceVO matriceVO = null;
     try {
       matriceVO = umaFacadeClient.getMatrice(idMatrice);
     }
     catch(SolmrException se) {
       ValidationError error = new ValidationError(se.getMessage());
       errors.add("error",error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(listaMatriciUrl).forward(request, response);
       return;
     }

     session.setAttribute("matriceVO",matriceVO);
     %>
        <jsp:forward page="<%= dettaglioMatriciUrl %>"/>
     <%
   }

%>
