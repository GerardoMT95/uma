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
<%

  String iridePageName = "dettaglioMacchinaTargaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient client = new UmaFacadeClient();
  String url = "/macchina/view/dettaglioMacchinaTargaView.jsp";
  ValidationError error = null;
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  MacchinaVO macchinaVO = (MacchinaVO)session.getAttribute("macchinaVO");
  Long idMacchina = macchinaVO.getIdMacchinaLong();
  SolmrLogger.debug(this,"Valore di Id Maghena "+idMacchina);
  Long idTarga = null;
  Vector v_immatricolazioni = null;
  // Entro in dettaglio
  if(request.getParameter("dettaglioTarga")!=null){
    url = "/macchina/layout/dettaglioMacchinaTarga.htm";
    SolmrLogger.debug(this,"Valore di Id Targa "+request.getParameter("radioTarga"));
  }
  // Entro per la prima volta
  else{
    if(session.getAttribute("v_immatricolazioni")!=null){
      SolmrLogger.debug(this,"v_immatricolazioni IN sessione");
      v_immatricolazioni = (Vector)session.getAttribute("v_immatricolazioni");
    }
    else{
      SolmrLogger.debug(this,"v_immatricolazioni NON in sessione");
      try {
        v_immatricolazioni = client.getElencoMovimentiTarga(idMacchina);
        session.setAttribute("v_immatricolazioni",v_immatricolazioni);
      }
      catch (SolmrException ex) {
        SolmrLogger.debug(this,"ERRRRRORE "+ex);
        error = new ValidationError(ex.getMessage());
        errors = new ValidationErrors();
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher("../../macchina/view/dettaglioMacchinaTargaView.jsp").forward(request, response);
        return;
      }
    }
  }
  SolmrLogger.debug(this,"- dettaglioMacchinaTargaCtrl.jsp - Fine Pagina");
%>
<jsp:forward page="<%=url%>"/>