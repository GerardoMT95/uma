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

  String iridePageName = "modificaMatriciOkCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


   UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

   String modificaMatriceOkUrl = "/macchina/view/modificaMatriciOkView.jsp";
   String listaMatriciUrl = "/macchina/view/listaMatriciView.jsp";

   ValidationErrors errors = new ValidationErrors();

   MatriceVO ricercaMatriceVO = (MatriceVO)session.getAttribute("ricercaMatriceVO");
   Vector elencoMatrici = null;
   try {
     elencoMatrici = umaFacadeClient.getListaMatrici(ricercaMatriceVO.getIdGenereMacchinaLong(),
                                                     ricercaMatriceVO.getIdCategoriaLong(),
                                                     ricercaMatriceVO.getDescMarca(),
                                                     ricercaMatriceVO.getTipoMacchina(),
                                                     ricercaMatriceVO.getNumeroMatrice(),
                                                     ricercaMatriceVO.getNumeroOmologazione());
   }
   catch(SolmrException se) {
     ValidationError error = new ValidationError(se.getMessage());
     errors.add("error",error);
     request.setAttribute("errors", errors);
     request.getRequestDispatcher(modificaMatriceOkUrl).forward(request, response);
     return;
   }
   session.setAttribute("elencoMatrici",elencoMatrici);
   %>
      <jsp:forward page="<%= listaMatriciUrl %>"/>
   <%
%>
