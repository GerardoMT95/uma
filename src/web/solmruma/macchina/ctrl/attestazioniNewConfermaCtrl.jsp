<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  private static final String attestazioniNewConfermaView = "/macchina/view/attestazioniNewConfermaView.jsp";
  private static final String elencoAttestazioniUrl = "/macchina/ctrl/attestazioniDittaCtrl.jsp";
%>
<%

  String iridePageName = "attestazioniNewConfermaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient client = new UmaFacadeClient();

  //session.removeAttribute("v_attestazione");

  //Controllo univocità Attestato proprietà - Begin
  /*Long idMacchina = null;
  if( ((String)request.getAttribute("operazione")).equalsIgnoreCase("inserisci")){
    idMacchina = (Long)request.getAttribute("idMacchina");
  }*/

  ValidationError error = null;
  ValidationErrors errors = new ValidationErrors();
  AttestatoProprietaVO apVO = new AttestatoProprietaVO();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  HashMap common2 = (HashMap) session.getAttribute("common2");
  //common.put("operazione","inserisci");
  Vector v_proprietari=null;
  Long idMacchina=null;
  String operazione=null;
  if( common2.get("v_proprietari")!=null ){
    v_proprietari = (Vector) common2.get("v_proprietari");
  }
  if( common2.get("idMacchina")!=null ){
    idMacchina = (Long) common2.get("idMacchina");
  }
  if( common2.get("operazione")!=null ){
    operazione = (String) common2.get("operazione");
  }
  //Controllo univocità Attestato proprietà - End

  //url = "/macchina/layout/dettaglioMacchinaDittaComproprietari.htm";
  //v_proprietari = (Vector) session.getAttribute("common");

  try {
    SolmrLogger.debug(this,"request.getParameter(\"conferma\"): "+request.getParameter("conferma"));
    if( request.getParameter("conferma")!=null ){
      SolmrLogger.debug(this,"\n\n\n************conferma");
      apVO = client.insertAttestazione(idMacchina, v_proprietari, ruoloUtenza);
      SolmrLogger.debug(this,"\n\n\n************conferma Dopo");
      request.setAttribute("attestatoNewVO", apVO);
     %>
      <jsp:forward page="<%=attestazioniNewConfermaView%>"/>
     <%
    }

    SolmrLogger.debug(this,"request.getParameter(\"chiudi\"): "+request.getParameter("chiudi"));
    if( request.getParameter("chiudi")!=null ){
      SolmrLogger.debug(this,"\n\n\n************chiudi");
     %>
      <jsp:forward page="<%=elencoAttestazioniUrl%>"/>
     <%
    }

    /*apVO = new AttestatoProprietaVO();
    request.setAttribute("attestatoNewVO", apVO);*/
    if( operazione.equalsIgnoreCase("inserisci") ){
      SolmrLogger.debug(this,"operazione: "+operazione);
      apVO = client.insertAttestazione(idMacchina, v_proprietari, ruoloUtenza);
      SolmrLogger.debug(this,"dopo insertAttestazione");
      request.setAttribute("attestatoNewVO", apVO);
    }

    SolmrLogger.debug(this,"attestazioniNewConfermaView: "+attestazioniNewConfermaView);
    %>
      <jsp:forward page="<%=attestazioniNewConfermaView%>"/>
    <%
  }
  catch (Exception ex)
  {
      SolmrLogger.debug(this,"ECCEZZZZIONE... "+ex+" - "+ex.getMessage());
      error = new ValidationError(ex.getMessage());
      errors = new ValidationErrors();
      errors.add("error", error);
      request.setAttribute("errors", errors);
      //request.getRequestDispatcher("../../macchina/view/attestazioniNewView.jsp").forward(request, response);
      %>
        <jsp:forward page="<%=attestazioniNewConfermaView%>"/>
      <%
      return;
  }

  SolmrLogger.debug(this,"attestazioniNewConfermaCtrl.jsp - Fine Pagina");
%>