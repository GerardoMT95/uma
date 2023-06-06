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

  private static final String VIEW="../view/modello73View.jsp";

  private static final String CTRL="../ctrl/modello73ElencoCtrl.jsp";

  private String FWD;

%>

<%

  String iridePageName = "modello73Ctrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  FWD = VIEW;

  try

  {

    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");



    ValidationErrors errors=new ValidationErrors();

    ValidationError vError = null;



    if (ruoloUtenza.isUtenteIntermediario() || ruoloUtenza.isUtenteRegionale()) {

        session.setAttribute("erroreUtente", "Utente non abilitato alla funzione richiesta");

        response.sendRedirect("../layout/stampaElenchi.htm");

        return;

    } else {

      if (request.getParameter("conferma") != null) {

        String dicitura = request.getParameter("dicitura");

        String idTarga = request.getParameter("idTarga");

        String targaDa = request.getParameter("targaDa");

        String targaA = request.getParameter("targaA");

        if (!Validator.isNumericInteger(idTarga.toString())) {

          errors.add("idTarga",new ValidationError("Il tipo targa deve essere scelto"));

        }

        if (!Validator.isNotEmpty(targaDa)) {

          errors.add("targaDa",new ValidationError("La targa iniziale deve essere valorizzata"));

        }

        if (!Validator.isNotEmpty(targaA)) {

          errors.add("targaA",new ValidationError("La targa finale deve essere valorizzata"));

        }

        Targhe t = new Targhe();

        // Controllare il formato delle targhe: devono essere di tipo uguale

        // e la "targa da" deve precedere la "targa a"

        if (!t.isValid(targaDa) && !t.isValidUMA(targaDa))

          errors.add("targaDa",new ValidationError("Targa iniziale non valida"));

        if (!t.isValid(targaA) && !t.isValidUMA(targaA))

          errors.add("targaA",new ValidationError("Targa finale non valida"));

        if ((t.isValid(targaDa) && t.isValidUMA(targaA)) ||

            (t.isValidUMA(targaDa) && t.isValid(targaA)))

        {

          errors.add("targaDa",new ValidationError("Le targhe devono avere lo stesso formato"));

          errors.add("targaA",new ValidationError("Le targhe devono avere lo stesso formato"));

        }

        if ((t.isValid(targaA) && t.isValid(targaDa) && t.difference(targaDa,targaA)>0) ||

            (t.isValidUMA(targaA) && t.isValidUMA(targaDa) && t.differenceUMA(targaDa,targaA)>0))

        {

          errors.add("targaDa",new ValidationError("La targa iniziale deve precedere la targa finale"));

          errors.add("targaA",new ValidationError("La targa finale deve seguire la targa iniziale"));

        }



        if (errors.size()!=0) {

          request.setAttribute("errors", errors);

        } else {

          FWD = CTRL;

        }

      }

    }

  }

  catch(Exception e) {

    ValidationErrors errors=new ValidationErrors();

    errors.add("error",new ValidationError(e.getMessage()));

    request.setAttribute("errors",errors);

  }

%>

<jsp:forward page="<%=FWD%>"/>



