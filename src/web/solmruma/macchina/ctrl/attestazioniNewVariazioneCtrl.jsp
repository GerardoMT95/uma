<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.dto.anag.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors"%>
<%

  String iridePageName = "attestazioniNewVariazioneCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient client = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  String url = "/macchina/view/attestazioniNewVariazioneView.jsp";
  ValidationError error = null;
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  MacchinaVO macchinaVO = null;
  Long idMacchina = null;
  if(session.getAttribute("common") instanceof MacchinaVO){
    SolmrLogger.debug(this,"Instance of MacchinaVO");
    macchinaVO = (MacchinaVO)session.getAttribute("common");
    idMacchina = macchinaVO.getIdMacchinaLong();
  }
  //SolmrLogger.debug(this,"Valore di v_proprietari... "+session.getAttribute("v_proprietari"));
  // Annulla
  if(request.getParameter("nonProcedi")!=null){
    //session.removeAttribute("v_proprietari");
    session.removeAttribute("v_locatari");
    session.removeAttribute("v_societa");
    session.removeAttribute("v_soggetti");
    url = "/macchina/layout/dettaglioMacchinaDittaComproprietari.htm";
  }
  // Salva
  else if (request.getParameter("procedi")!=null){
    /*Vector v_proprietari =(Vector)session.getAttribute("v_proprietari");
    session.removeAttribute("v_proprietari");
    try{
      AttestatoProprietaVO apVO = client.insertAttestazione(idMacchina, v_proprietari, profile);
      request.setAttribute("attestatoNewVO", apVO);
      url = "/macchina/layout/NuovaAttestazioneConferma.htm";
    }
    catch (SolmrException ex) {
      SolmrLogger.debug(this,"ECCEZZZZIONE... "+ex+" - "+ex.getMessage());
      error = new ValidationError(ex.getMessage());
      errors = new ValidationErrors();
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher("../../macchina/view/attestazioniNewView.jsp").forward(request, response);
      return;
    }*/
    url = "/macchina/view/attestazioniNewView.jsp";
  }
  SolmrLogger.debug(this,"- attestazioniNewVariazioneCtrl.jsp - Fine Pagina");
%>
<jsp:forward page="<%=url%>"/>