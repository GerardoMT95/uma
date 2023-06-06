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

  private static final String VIEW="../view/modello39View.jsp";

  private static final String msgErrorIntervallo="E' possibile specificare un solo intervallo, numeri foglio o date emissione";

  private static final String msgErrorNonValido="Specificare almeno un intervallo";

%>

<%
  String iridePageName = "modello39Ctrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  try

  {

    UmaFacadeClient umaClient = new UmaFacadeClient();

    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");



    ValidationErrors errors=new ValidationErrors();

    String anno = request.getParameter("anno");

    String numeroInizio = request.getParameter("numeroInizio");

    String numeroFine = request.getParameter("numeroFine");

    String dataInizio = request.getParameter("dataInizio");

    String dataFine = request.getParameter("dataFine");

    ValidationError vError = null;



    if (ruoloUtenza.isUtenteIntermediario() || ruoloUtenza.isUtenteRegionale()) {

        session.setAttribute("erroreUtente", "Utente non abilitato alla funzione richiesta");

        response.sendRedirect("../layout/stampaElenchi.htm");

        return;

    } else {

      if (request.getParameter("conferma") != null) {

        if (!Validator.isNotEmpty(anno) && !Validator.isNotEmpty(numeroInizio) &&

            !Validator.isNotEmpty(numeroFine) && !Validator.isNotEmpty(dataInizio) &&

            !Validator.isNotEmpty(dataFine)) {

              errors.add("anno",new ValidationError(msgErrorNonValido));

              errors.add("numeroFine",new ValidationError(msgErrorNonValido));

              errors.add("numeroInizio",new ValidationError(msgErrorNonValido));

              errors.add("dataFine",new ValidationError(msgErrorNonValido));

              errors.add("dataInizio",new ValidationError(msgErrorNonValido));

        } else {

        if (Validator.isNotEmpty(anno) || Validator.isNotEmpty(numeroInizio) ||

            Validator.isNotEmpty(numeroFine) || Validator.isNotEmpty(dataInizio) ||

            Validator.isNotEmpty(dataFine)) {

              if ((Validator.isNotEmpty(anno) || Validator.isNotEmpty(numeroInizio) ||

                  Validator.isNotEmpty(numeroFine)) &&

                 (Validator.isNotEmpty(dataInizio) || Validator.isNotEmpty(dataFine))) {

                errors.add("anno",new ValidationError(msgErrorIntervallo));

                errors.add("numeroFine",new ValidationError(msgErrorIntervallo));

                errors.add("numeroInizio",new ValidationError(msgErrorIntervallo));

                errors.add("dataFine",new ValidationError(msgErrorIntervallo));

                errors.add("dataInizio",new ValidationError(msgErrorIntervallo));

              } else {

                if (Validator.isNotEmpty(anno) || Validator.isNotEmpty(numeroInizio) || Validator.isNotEmpty(numeroFine)) {

                  if (!Validator.isNotEmpty(anno)) {

                    errors.add("anno",new ValidationError("L''anno deve essere valorizzato"));

                  } else {

                    if (!Validator.isNumericInteger(anno)) {

                      errors.add("anno",new ValidationError("Anno non valido"));

                    }

                  }

                  if (!Validator.isNotEmpty(numeroInizio)) {

                    errors.add("numeroInizio",new ValidationError("Il numero foglio iniziale deve essere valorizzato"));

                  } else {

                    if (!Validator.isNumericInteger(numeroInizio)) {

                      errors.add("numeroInizio",new ValidationError("Numero foglio iniziale non valido"));

                    }

                  }

                  if (!Validator.isNotEmpty(numeroFine)) {

                    errors.add("numeroFine",new ValidationError("Il numero foglio finale deve essere valorizzato"));

                  } else {

                    if (!Validator.isNumericInteger(numeroFine)) {

                      errors.add("numeroFine",new ValidationError("Numero foglio finale non valido"));

                    }

                  }

                  if (Validator.isNotEmpty(numeroInizio) && Validator.isNotEmpty(numeroFine)) {

                    int intNumeroInizio = new Integer(numeroInizio).intValue();

                    int intNumeroFine = new Integer(numeroFine).intValue();

                    int intGiorni = intNumeroFine - intNumeroInizio;

                    if (intGiorni < 0) {

                      errors.add("numeroFine",new ValidationError("Il numero foglio finale deve essere maggiore o uguale al numero foglio iniziale"));

                    } else {

                      /*if (intGiorni > 25) {

                        errors.add("numeroFine",new ValidationError("Selezionare un massimo di 25 numeri foglio"));*/

                      if (intGiorni > 10) {

                        errors.add("numeroFine",new ValidationError("Selezionare un massimo di 10 numeri foglio"));

                      }

                    }

                  }

                } else {

                  Validator.validateDateAll(dataInizio, "dataInizio", "data inizio emissione", errors, true, true);

                  Validator.validateDateAll(dataFine, "dataFine", "data fine emissione", errors, true, true);

                  if ((errors.size()==0) && DateUtils.getAgeInDays(DateUtils.parseDate(dataInizio), DateUtils.parseDate(dataFine)) > 30) {

                    errors.add("dataInizio",new ValidationError("Il numero di giorni tra la data inizio e data fine non deve essere superiore a 30"));

                  }

                }

              }

          }

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



