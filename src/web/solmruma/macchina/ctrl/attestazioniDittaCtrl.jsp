<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.etc.uma.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%

  String iridePageName = "attestazioniDittaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient client = new UmaFacadeClient();
  String url = "/macchina/view/attestazioniDittaView.jsp";
  ValidationError error = null;
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
  Long idAttestazione = null;
  Vector v_attestazioni = null;
  Vector v_proprietari = null;
  HashMap vecSession = null;
  // Recupero i dati della maghena
  Long idMacchina = null;

  SolmrLogger.debug(this,"\n\n\n++++++++++++++++++");
  SolmrLogger.debug(this,"attestazioniDittaCtrl.jsp");
  if(request.getParameter("idMacchina")!=null){
    SolmrLogger.debug(this,"idMacchina: "+idMacchina);
    idMacchina=new Long(request.getParameter("idMacchina"));
  }
  SolmrLogger.debug(this,"idMacchina: "+idMacchina);
  /*if(request.getAttribute("idMacchina")!=null){
    idMacchina=new Long(request.getAttribute("idMacchina").toString());
  }*/
  MacchinaVO macchinaVO = new MacchinaVO();
  /*if (session.getAttribute("common")!=null){
    SolmrLogger.debug(this,"session.getAttribute(\"common\")!=null");
    vecSession = (HashMap) session.getAttribute("common");
    macchinaVO = (MacchinaVO) vecSession.get("macchinaVO");
    v_attestazioni = (Vector) vecSession.get("v_attestazioni");
  }*/
  if(session.getAttribute("common") instanceof MacchinaVO){
    SolmrLogger.debug(this,"Instance of MacchinaVO");
    macchinaVO = (MacchinaVO)session.getAttribute("common");
  }
  else{
    macchinaVO= client.getMacchinaById(idMacchina);
    session.setAttribute("common", macchinaVO);
  }

  // Entro in dettaglio
  if(request.getParameter("operazione")!=null&&request.getParameter("operazione").equals("dettaglio")){
    SolmrLogger.debug(this,"Entro in Dettaglio");
    url = "/macchina/layout/dettaglioMacchinaDittaDettaglioComproprietari.htm";
  }
  // Inserimento nuova
  else if(request.getParameter("operazione")!=null&&request.getParameter("operazione").equals("inserisci")){
    SolmrLogger.debug(this,"Entro in Inserisci");
    url = "/macchina/layout/dettaglioMacchinaDittaNuovaAttestazione.htm";
  }
  else if(request.getParameter("operazione")!=null&&request.getParameter("operazione").equals("indietro")){

  }
  else if(request.getParameter("operazione")!=null&&request.getParameter("operazione").equals("elimina")){
    url = "/macchina/layout/confermaEliminaAttestatoProprieta.htm";
  }
  // Entro per la prima volta
  else{
    SolmrLogger.debug(this,"Entro in Nessuna Parte");

      SolmrLogger.debug(this,"v_attestazioni NON in sessione");
      try {
        if(idMacchina==null)
          idMacchina = macchinaVO.getIdMacchinaLong();
        v_attestazioni = client.getAttestazioniProprieta(idMacchina);
        session.setAttribute("v_attestazioni",v_attestazioni);
        /*vecSession = new HashMap();
        vecSession.put("macchinaVO", macchinaVO);
        vecSession.put("v_attestazioni",v_attestazioni);
        session.setAttribute("common",vecSession);*/
      }
      catch (SolmrException ex) {
        SolmrLogger.debug(this,"ERRRRRORE "+ex);
        error = new ValidationError(ex.getMessage());
        errors = new ValidationErrors();
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher("../../macchina/view/attestazioniDittaView.jsp").forward(request, response);
        return;
      }

    // La ditta UMA non deve essere cessata
    /*try {
      client.isDittaUmaCessata(dittaVO.getIdDittaUMA());
    }
    catch (SolmrException ex) {
      SolmrLogger.debug(this,"ERRRRRORE DITTA CESSATA");
      error = new ValidationError(UmaErrors.DITTA_CESSATA);
      errors = new ValidationErrors();
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher("../../macchina/view/attestazioniDittaView.jsp").forward(request, response);
      return;
    }
    // La ditta UMA non deve essere bloccata
    try {
      client.isDittaUmaBloccata(dittaVO.getIdDittaUMA());
    }
    catch (SolmrException ex) {
      SolmrLogger.debug(this,"ERRRRRORE DITTA BLOCCATA");
      error = new ValidationError(UmaErrors.DITTA_BLOCCATA);
      errors = new ValidationErrors();
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher("../../macchina/view/attestazioniDittaView.jsp").forward(request, response);
      return;
    }*/

    /*if(v_attestazioni!=null){
      SolmrLogger.debug(this,"v_attestazioni in sessione");
      v_attestazioni = (Vector)session.getAttribute("v_attestazioni");
    }
    else{
      SolmrLogger.debug(this,"v_attestazioni NON in sessione");
      try {
        if(idMacchina==null)
          idMacchina = macchinaVO.getIdMacchinaLong();
        v_attestazioni = client.getAttestazioniProprieta(idMacchina);
        session.setAttribute("v_attestazioni",v_attestazioni);
        /*vecSession = new HashMap();
        vecSession.put("macchinaVO", macchinaVO);
        vecSession.put("v_attestazioni",v_attestazioni);
        session.setAttribute("common",vecSession);*/
      /*}
      catch (SolmrException ex) {
        SolmrLogger.debug(this,"ERRRRRORE "+ex);
        error = new ValidationError(ex.getMessage());
        errors = new ValidationErrors();
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher("../../macchina/view/attestazioniDittaView.jsp").forward(request, response);
        return;
      }
    }*/
  }
  SolmrLogger.debug(this,"- attestazioniDittaCtrl.jsp - Fine Pagina");
%>
<jsp:forward page="<%=url%>"/>