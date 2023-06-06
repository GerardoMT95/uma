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

  private static final String VIEW="../view/modello74View.jsp";

  private static final String msgErrorIntervallo = "E' possibile specificare un solo intervallo, date oppure numero attestazioni";

  private static final String msgErrorObbliga = "Specificare almeno un intervallo";

%>

<%

  String iridePageName = "modello74Ctrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%
  try

  {

    UmaFacadeClient umaClient = new UmaFacadeClient();

    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

    ValidationErrors errors=new ValidationErrors();

    String strDataInizio = (request.getParameter("dataInizioI")!=null?request.getParameter("dataInizioI"):"");

    String strDataFine = (request.getParameter("dataFineI")!=null?request.getParameter("dataFineI"):"");

    String strAnno = (request.getParameter("anno")!=null?request.getParameter("anno"):"");

    String strNumeroInizio = (request.getParameter("numeroInizio")!=null?request.getParameter("numeroInizio"):"");

    String strNumeroFine = (request.getParameter("numeroFine")!=null?request.getParameter("numeroFine"):"");

    ValidationError vError = null;



    if (ruoloUtenza.isUtenteIntermediario() || ruoloUtenza.isUtenteRegionale()) {

        session.setAttribute("erroreUtente", "Utente non abilitato alla funzione richiesta");

        response.sendRedirect("../layout/stampaElenchi.htm");

        return;

    } else {

      if (request.getParameter("conferma") != null) {

        if (Validator.isNotEmpty(strDataInizio) || Validator.isNotEmpty(strDataFine) ||

            Validator.isNotEmpty(strNumeroInizio) || Validator.isNotEmpty(strNumeroFine)) {

            if ((Validator.isNotEmpty(strDataInizio) || Validator.isNotEmpty(strDataFine)) &&

               (Validator.isNotEmpty(strNumeroInizio) || Validator.isNotEmpty(strNumeroFine))) {

               errors.add("dataInizioI",new ValidationError(msgErrorIntervallo));

               errors.add("dataFineI",new ValidationError(msgErrorIntervallo));

               errors.add("anno",new ValidationError(msgErrorIntervallo));

               errors.add("numeroFine",new ValidationError(msgErrorIntervallo));

               errors.add("numeroInizio",new ValidationError(msgErrorIntervallo));

            } else {

              if (Validator.isNotEmpty(strDataInizio) || Validator.isNotEmpty(strDataFine)) {

                Validator.validateDateAll(strDataInizio, "dataInizioI", "data inizio", errors, true, false);

                Validator.validateDateAll(strDataFine, "dataFineI", "data fine", errors, true, false);

                if (errors.size()==0) {

                  if (DateUtils.extractYearFromDate(DateUtils.parseDate(strDataInizio)) != DateUtils.extractYearFromDate(DateUtils.parseDate(strDataFine))) {

                    errors.add("dataInizioI",new ValidationError("Le date devono appartenere allo stesso anno"));

                  } else {

                    if (DateUtils.getAgeInDays(DateUtils.parseDate(strDataInizio), DateUtils.parseDate(strDataFine)) > 30) {

                      errors.add("dataInizioI",new ValidationError("Il numero di giorni tra la data inizio e data fine non deve essere superiore a 30"));

                    }

                  }

                }

              } else {

                if (!Validator.isNotEmpty(strAnno)) {

                  errors.add("anno",new ValidationError("Il campo è obbligatorio"));

                }

                if (!Validator.isNotEmpty(strNumeroInizio)) {

                  errors.add("numeroInizio",new ValidationError("Il campo è obbligatorio"));

                }

                if (!Validator.isNotEmpty(strNumeroFine)) {

                  errors.add("numeroFine",new ValidationError("Il campo è obbligatorio"));

                }

              }

           }

        } else {

           errors.add("dataInizioI",new ValidationError(msgErrorObbliga));

           errors.add("dataFineI",new ValidationError(msgErrorObbliga));

           errors.add("anno",new ValidationError(msgErrorObbliga));

           errors.add("numeroFine",new ValidationError(msgErrorObbliga));

           errors.add("numeroInizio",new ValidationError(msgErrorObbliga));

        }

        if (errors.size()!=0) {

          request.setAttribute("errors", errors);

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

<jsp:forward page="<%=VIEW%>"/>



