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

  private static final String VIEW="../view/reportConsumiEmessiAnnoView.jsp";

%>

<%
  String iridePageName = "reportConsumiEmessiAnnoCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  try  {

    UmaFacadeClient umaClient = new UmaFacadeClient();

    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

    ValidationErrors errors=new ValidationErrors();

    String provUMA = request.getParameter("provUMA");

    String strAnno = request.getParameter("anno");

    String strMese = request.getParameter("mese");



    ValidationError vError = null;

    if (ruoloUtenza.isUtenteIntermediario()) {

        session.setAttribute("erroreUtente", "Utente non abilitato alla funzione richiesta");

        response.sendRedirect("../layout/stampaElenchi.htm");

        return;

    } else {

      if (request.getParameter("conferma") != null) {

        if (!Validator.isNotEmpty(provUMA)) {

          errors.add("provUMA",new ValidationError("La provincia deve essere valorizzata"));

        }

        if (!Validator.isNotEmpty(strAnno)) {

          errors.add("anno",new ValidationError("L''anno deve essere valorizzato"));

        }

        if (!Validator.isNumericInteger(strAnno)) {

          errors.add("anno",new ValidationError("Anno non valido"));

        }

        if ((provUMA != null) && !(provUMA.equals(ruoloUtenza.getIstatProvincia()))) {

          if (!ruoloUtenza.isUtenteRegionale()) {

            errors.add("provUMA",new ValidationError("La provincia selezionata non è quella di competenza"));

          }

        }

        if (errors.size()!=0) {

          request.setAttribute("errors", errors);

        }

      }

    }

  }

  catch(Exception e)  {

    ValidationErrors errors=new ValidationErrors();

    errors.add("error",new ValidationError(e.getMessage()));

    request.setAttribute("errors",errors);

  }

%>

<jsp:forward page="<%=VIEW%>"/>



