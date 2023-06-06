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
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String iridePageName = "dettaglioMacchinaUtilizzoCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  MacchinaVO macchinaVO = (MacchinaVO)session.getAttribute("macchinaVO");
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  String errorPage = "/macchina/view/dettaglioMacchinaUtilizzoView.jsp";
  String dettaglioURL = "/macchina/view/dettaglioMacchinaUtilizzoView.jsp";
  String dettaglioUtilizzoURL = "/macchina/layout/dettaglioMacchinaDettaglioUtilizzo.htm";
  ValidationErrors errors = new ValidationErrors();
  Vector v_utilizzi = (Vector)session.getAttribute("v_utilizzi");
  String url = "/macchina/view/dettaglioMacchinaUtilizzoView.jsp";

  if(macchinaVO!=null){
    if(v_utilizzi==null){
      try{
        v_utilizzi = umaFacadeClient.getElencoUtilizzo(macchinaVO.getIdMacchinaLong());
        session.setAttribute("v_utilizzi",v_utilizzi);
        url = dettaglioURL;
      }
      catch(SolmrException sex){
        ValidationError error = new ValidationError(sex.getMessage());
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(dettaglioURL).forward(request, response);
        return;
      }
    }
  }
  if(request.getParameter("dettaglioUtilizzo")!=null){
    if(v_utilizzi!=null){
      String idUtilizzo = request.getParameter("idUtilizzo");
      if(idUtilizzo!=null){
        UtilizzoVO uVO = null;
        for(int i=0; i<v_utilizzi.size(); i++){
          uVO = (UtilizzoVO)v_utilizzi.elementAt(i);
          if(idUtilizzo.equals(uVO.getIdUtilizzo())){
            request.setAttribute("utilizzoVO",uVO);
            url = dettaglioUtilizzoURL;
            break;
          }
        }
      }
      else{
        ValidationError error = new ValidationError("Selezionare un utilizzo");
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(dettaglioURL).forward(request, response);
        return;
      }
    }
  }


%>
      <jsp:forward page ="<%=url%>" />
  <%
  SolmrLogger.debug(this,"----- dettaglioMacchinaUtilizzoCtrl.jsp ----- fine");
%>

