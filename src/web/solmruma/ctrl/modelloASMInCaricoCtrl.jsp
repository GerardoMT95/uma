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
  private static final String VIEW="../view/modelloASMIInCaricoView.jsp";
%>

<%
  String iridePageName = "modelloASMInCaricoCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%
  try {
    UmaFacadeClient umaClient = new UmaFacadeClient();
    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
    ValidationErrors errors=new ValidationErrors();
    String provUMA = request.getParameter("provUMA");
    String idCategoria = (String) request.getParameter("idCategoria");
    String idProvinciaProf = ruoloUtenza.getIstatProvincia();
    ValidationError vError = null;
    if (ruoloUtenza.isUtenteIntermediario()) {
        session.setAttribute("erroreUtente", "Utente non abilitato alla funzione richiesta");
        response.sendRedirect("../layout/stampaElenchi.htm");
        return;
    } else {
      if (request.getParameter("conferma") != null) {
        if(!(ruoloUtenza.isUtenteRegionale())
           && !idProvinciaProf.equals(provUMA))
          errors.add("provUMA",new ValidationError("Funzionario PA appartenente ad una provincia differente da quella selezionata"));
        if (!Validator.isNotEmpty(provUMA)) {
          errors.add("provUMA",new ValidationError("La provincia deve essere valorizzata"));
        }
        if (!Validator.isNotEmpty(idCategoria)) {
          errors.add("categoria",new ValidationError("La categoria deve essere valorizzata"));
        }
      }
      if (errors.size()!=0) {
        request.setAttribute("errors", errors);
      }
    }
  } catch(Exception e) {
    ValidationErrors errors=new ValidationErrors();
    errors.add("error",new ValidationError(e.getMessage()));
    request.setAttribute("errors",errors);
  }

%>
<jsp:forward page="<%=VIEW%>"/>