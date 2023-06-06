<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(
      "/domass/layout/annulloAccontoValidazione.htm");
%><%@include file="/include/menu.inc"%>
<%
  DomandaAssegnazione da = null;
  if (request.getAttribute("DomandaAssegnazione") != null)
  {
    SolmrLogger.debug(this,"request.getAttribute(\"DomandaAssegnazione\")!=null");
    da = (DomandaAssegnazione) request.getAttribute("DomandaAssegnazione");
  }
  else
  {
    SolmrLogger.debug(this,"request.getAttribute(\"DomandaAssegnazione\")==null");
  }

  if (request.getParameter("annullaBuoni") != null)
  {
    htmpl.set("annullaBuoni", request.getParameter("annullaBuoni"));

    if (request.getParameter("pageFrom") != null)
    {
      htmpl.set("pageFrom", request.getParameter("pageFrom"));
    }
  }

  htmpl.set("idDomAss", "" + da.getIdDomandaAssegnazione());
  SolmrLogger.debug(this,"idDomAss: " + da.getIdDomandaAssegnazione());
  htmpl.set("note", da.getNote());
  SolmrLogger.debug(this,"da.getNote(): " + da.getNote());

  if (request.getParameter("numeroFoglio") != null)
  {
    SolmrLogger.debug(this,"request.getParameter(\"numeroFoglio\")!=null");
    //Mantiene i dati per la pagina verificaAssegnazioneValidata.htm
    //   quando ritorno con Annulla da annulloAccontoValidazione.htm
    String numeroFoglio = request.getParameter("numeroFoglio");
    htmpl.set("numeroFoglio", numeroFoglio);
    SolmrLogger.debug(this,"numeroFoglio: " + numeroFoglio);
  }

  ValidationErrors errors = (ValidationErrors) request
      .getAttribute("errors");
  SolmrLogger.debug(this,"errors=" + errors);
  HtmplUtil.setErrors(htmpl, errors, request);

  Integer annoDiRiferimento = DateUtils.getCurrentYear();
  htmpl.set("annoDiRiferimento", "" + annoDiRiferimento);

  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,
      exception);
  out.print(htmpl.text());

  SolmrLogger.debug(this,"annulloAccontoValidazioneView - End");
%>