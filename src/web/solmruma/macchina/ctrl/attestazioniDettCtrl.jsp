<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String iridePageName = "attestazioniDettCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient client = new UmaFacadeClient();
  String url = "/macchina/view/attestazioniDettView.jsp";
  ValidationError error = null;
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  Long idAttestazione = null;
  Vector v_proprietari = null;
  // Indietro
  if(request.getParameter("operazione")!=null&&request.getParameter("operazione").equals("indietro_")){
    url = "/macchina/layout/dettaglioMacchinaComproprietari.htm";
  }
  // Entro per la prima volta
  else{
    if(request.getParameter("radioAttestazione")!=null&&!request.getParameter("radioAttestazione").equals("")){
      SolmrLogger.debug(this,"Valore di Id Attestazione "+request.getParameter("radioAttestazione"));
      idAttestazione = new Long(request.getParameter("radioAttestazione"));
      try {
        session.removeAttribute("v_proprietari");
        v_proprietari = client.getProprietariByAttestazione(idAttestazione);
        session.setAttribute("v_proprietari", v_proprietari);
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
    else{
      SolmrLogger.debug(this,"Selezionare un attestato!");
      error = new ValidationError("Selezionare un attestato!");
      errors = new ValidationErrors();
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher("../../macchina/view/attestazioniView.jsp").forward(request, response);
      return;
    }
  }
  SolmrLogger.debug(this,"- attestazioniDettCtrl.jsp - Fine Pagina");
%>
<jsp:forward page="<%=url%>"/>