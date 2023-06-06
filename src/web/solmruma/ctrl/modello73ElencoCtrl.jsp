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

<%!
  private static final String VIEW="../view/modello73ElencoView.jsp";
  private static final String VIEW2="../view/modello73View.jsp";
  private String FWD;
%>
<%
  FWD = VIEW;
  String iridePageName = "modello73ElencoCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  try
  {
    UmaFacadeClient umaClient = new UmaFacadeClient();
    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

//    ValidationErrors errors=new ValidationErrors();
//    ValidationError vError = null;

    if (!(ruoloUtenza.isUtenteProvinciale()||ruoloUtenza.isUtenteRegionale())) {
        session.setAttribute("erroreUtente", "Utente non abilitato alla funzione richiesta");
        response.sendRedirect("../layout/stampaElenchi.htm");
        return;
    } else {
      if (request.getParameter("conferma") != null && request.getParameter("confermaStampa") == null) {
        String istatProvincia = ruoloUtenza.getIstatProvincia();
        Long idTarga = new Long(request.getParameter("idTarga"));
        String targaDa = request.getParameter("targaDa");
        String targaA = request.getParameter("targaA");
        Vector elencoMacchine = umaClient.getElencoDistintaTarghe(istatProvincia, idTarga, targaDa, targaA);

        if (elencoMacchine.size()==0)
          throw new Exception("Non esistono macchine immatricolate corrispondenti ai paramentri di stampa indicati.");

        request.setAttribute("elencoMacchine", elencoMacchine);

//        if (errors.size()!=0) {
//          request.setAttribute("errors", errors);
//        }
      }
      else
        FWD = VIEW2;
    }
  }
  catch(Exception e) {
    ValidationErrors errors=new ValidationErrors();
    errors.add("error",new ValidationError(e.getMessage()));
    request.setAttribute("errors",errors);
    FWD = VIEW2;
  }

%>
<jsp:forward page="<%=FWD%>"/>

