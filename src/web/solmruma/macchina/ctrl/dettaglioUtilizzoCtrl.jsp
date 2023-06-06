<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String iridePageName = "dettaglioUtilizzoCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient umaClient = new UmaFacadeClient();
  AnagFacadeClient anagClient = new AnagFacadeClient();
  Vector v_utilizzi = (Vector)session.getAttribute("v_dittaMacchinaUtilizzi");
  ValidationErrors errors = new ValidationErrors();
  String errorPage = "/macchina/view/dettaglioUtilizzoView.jsp";
  String url = "";

  session.removeAttribute("dittaUtilizzoVO");

  if(v_utilizzi!=null){
    String idUtilizzo = request.getParameter("idUtilizzo");
    if(idUtilizzo!=null){
      UtilizzoVO uVO = null;
      for(int i=0; i<v_utilizzi.size(); i++){
        uVO = (UtilizzoVO)v_utilizzi.elementAt(i);
        if(idUtilizzo.equals(uVO.getIdUtilizzo())){

          try{
            Vector v_possessi = umaClient.getElencoPossessoByUtilizzo(uVO.getIdUtilizzoLong());            
            uVO.setPossesso((PossessoVO[]) (v_possessi==null ? null : (PossessoVO[]) v_possessi.toArray(new PossessoVO[0])));
          }
          catch(SolmrException sex){
            ValidationError error = new ValidationError(sex.getMessage());
            errors.add("error", error);
            request.setAttribute("errors", errors);
            request.getRequestDispatcher(errorPage).forward(request, response);
            return;
          }
          session.setAttribute("dittaUtilizzoVO",uVO);
          try{
            if(uVO.getIdAzienda()!=null){
              AnagraficaAzVO aVO = anagClient.getDatiAziendaPerMacchine(uVO.getIdAzienda());
              request.setAttribute("datiAziendaVO",aVO);
            }
          }
          catch(SolmrException sex){
            ValidationError error = new ValidationError("Impossibile reperire i dati dell''azienda associata alla ditta UMA");
            errors.add("error", error);
            request.setAttribute("errors", errors);
            request.getRequestDispatcher(errorPage).forward(request, response);
            return;
    }
          url = "/macchina/view/dettaglioUtilizzoView.jsp";
          break;
        }
      }
    }
    else{
      ValidationError error = new ValidationError("Selezionare un utilizzo");
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(errorPage).forward(request, response);
      return;
    }
  }


  %>
     <jsp:forward page = "/macchina/view/dettaglioUtilizzoView.jsp" />
  <%
  SolmrLogger.debug(this,"----- dettaglioUtilizzoCtrl.jsp ----- fine");
%>

