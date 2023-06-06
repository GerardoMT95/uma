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

  String iridePageName = "dettaglioMacchinaDittaUtilizzoCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  String url = "/macchina/view/dettaglioMacchinaDittaUtilizzoView.jsp";

  Validator validator = null;
  ValidationErrors errors = null;

  if(request.getAttribute("errors")!=null){
    errors = (ValidationErrors)request.getAttribute("errors");
    //request.setAttribute("errors", (ValidationErrors)request.getAttribute("errors"));
  }


  String idMacchinaStr = null;

  if(request.getParameter("idMacchina")!=null &&
     !request.getParameter("idMacchina").equals(""))
    idMacchinaStr = request.getParameter("idMacchina");
  else if(session.getAttribute("dittaMacchinaVO")!=null)
    idMacchinaStr = ((MacchinaVO)session.getAttribute("dittaMacchinaVO")).getIdMacchina();

  session.removeAttribute("dittaMacchinaVO");
  session.removeAttribute("v_dittaMacchinaUtilizzi");
  session.removeAttribute("dittaUtilizzoVO");

  UmaFacadeClient umaClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  Long idDittaUma = null;
  if(dittaUMAAziendaVO!=null){
    MacchinaVO mVO = null;
    Vector v_utilizzi = null;
    idDittaUma = dittaUMAAziendaVO.getIdDittaUMA();

    Long idMacchina = null;
    if(idMacchinaStr!=null && !idMacchinaStr.equals("")){
      idMacchina=new Long(idMacchinaStr);
      try{
        mVO = umaClient.getMacchinaById(idMacchina);
        v_utilizzi = umaClient.getElencoUtilizzo(idMacchina);
        if(mVO!=null)
          session.setAttribute("dittaMacchinaVO", mVO);
        if(v_utilizzi!=null)
          session.setAttribute("v_dittaMacchinaUtilizzi", v_utilizzi);

        if(errors!=null)
          request.setAttribute("errors", errors);
      }
      catch(SolmrException sex){
        if(errors==null)
          errors = new ValidationErrors();
        ValidationError error = new ValidationError(sex.getMessage());
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(url).forward(request, response);
        return;
      }
    }
  }

  %><jsp:forward page="<%=url%>" /><%
%>

