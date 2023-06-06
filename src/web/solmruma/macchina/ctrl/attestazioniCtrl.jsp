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

  String iridePageName = "attestazioniCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient client = new UmaFacadeClient();
  String url = "/macchina/view/attestazioniView.jsp";
  ValidationError error = null;
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  MacchinaVO macchinaVO = (MacchinaVO)session.getAttribute("macchinaVO");
  //Elimino le caratteristiche usate in Inserimento Nuovo Attestato Proprietà
  session.removeAttribute("common2");
  Long idMacchina = macchinaVO.getIdMacchinaLong();
  SolmrLogger.debug(this,"Valore di Id Maghena "+idMacchina);
  Long idAttestazione = null;
  Vector v_attestazioni = null;
  Vector v_proprietari = null;
  // Entro in dettaglio
  if(request.getParameter("operazione")!=null&&request.getParameter("operazione").equals("dettaglio")){
    url = "/macchina/layout/dettaglioMacchinaDettaglioComproprietari.htm";
    SolmrLogger.debug(this,"Valore di Id Attestazione "+request.getParameter("radioAttestazione"));
  }
  // Entro per la prima volta
  else{
    if(session.getAttribute("v_attestazioni")!=null){
      SolmrLogger.debug(this,"v_attestazioni IN sessione");
      v_attestazioni = (Vector)session.getAttribute("v_attestazioni");
    }
    else{
      SolmrLogger.debug(this,"v_attestazioni NON in sessione");
      try {
        v_attestazioni = client.getAttestazioniProprieta(idMacchina);
        session.setAttribute("v_attestazioni",v_attestazioni);
      }
      catch (SolmrException ex) {
        SolmrLogger.debug(this,"ERRRRRORE "+ex);
        error = new ValidationError(ex.getMessage());
        errors = new ValidationErrors();
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher("../../macchina/view/attestazioniView.jsp").forward(request, response);
        return;
      }
    }
  }
  SolmrLogger.debug(this,"- attestazioniCtrl.jsp - Fine Pagina");
%>
<jsp:forward page="<%=url%>"/>