<%@ page language="java" contentType="text/html"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.etc.SolmrConstants"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  public static final String VIEW = "/domass/view/rifiutoAccontoView.jsp";
  public static final String ANNULLA = "../layout/verificaAssegnazioneAccontoValida.htm";
  public static final  String CONFERMA = "../layout/assegnazioni.htm";
%>  
<%
  String iridePageName = "rifiutoAccontoCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%

  SolmrLogger.debug(this, "   BEGIN rifiutoAccontoCtrl");

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


  Long idDomAss = null;
  DomandaAssegnazione da;
  if (request.getParameter("idDomAss") != null)
  {
    SolmrLogger
        .debug(this,
            "[rifiutoAccontoCtrl:service request.getParameter(\"idDomAss\") != null");
    idDomAss = new Long(request.getParameter("idDomAss"));
  }
  else
  {
    SolmrLogger
        .debug(this,
            "[rifiutoAccontoCtrl:service request.getParameter(\"idDomAss\") == null");
  }
  SolmrLogger.debug(this, "[rifiutoAccontoCtrl:service idDomAss: "
      + idDomAss);

  if (request.getParameter("annulla.x") != null)
  {
    SolmrLogger
        .debug(this, "[rifiutoAccontoCtrl:service annulla");
    response.sendRedirect(ANNULLA);
    return;
  }

  if (request.getParameter("conferma.x") != null)
  {
    SolmrLogger.debug(this,
        "[rifiutoAccontoCtrl:service Conferma");

    ValidationErrors errors = new ValidationErrors();
    String motivazione = "";
    if (request.getParameter("note") != null)
    {
      motivazione = request.getParameter("note");
      SolmrLogger.debug(this, "[rifiutoAccontoCtrl:service motivazione: "
          + motivazione);

      if (motivazione != null && motivazione.length() == 0)
      {
        SolmrLogger
            .debug(this,
                "[rifiutoAccontoCtrl:service motivazione!=null && motivazione.length()==0");
        errors.add("note", new ValidationError(
            "Inserire il motivo del rifiuto"));
      }
      if (motivazione != null && motivazione.length() > 512)
      {
        SolmrLogger
            .debug(this,
                "[rifiutoAccontoCtrl:service motivazione!=null && motivazione.length()>512");
        errors.add("note", new ValidationError(
            "Campo troppo lungo. Massimo 512 caratteri"));
      }
      if (errors.size() != 0)
      {
        SolmrLogger.debug(this,
            "[rifiutoAccontoCtrl:service       if (errors!=null)");
        da = (DomandaAssegnazione) umaFacadeClient
            .findDomAssByPrimaryKey(idDomAss);
        da.setNote(motivazione);
        SolmrLogger
            .debug(this,
                "[rifiutoAccontoCtrl:service       dopo umaFacadeClient.findDomAssByPrimaryKey");
        request.setAttribute("DomandaAssegnazione", da);
        SolmrLogger.debug(this,
            "[rifiutoAccontoCtrl:service errors: " + errors);
        SolmrLogger.debug(this,
            "[rifiutoAccontoCtrl:service errors.size(): " + errors.size());
        request.setAttribute("errors", errors);
%><jsp:forward page="<%=VIEW%>" />
<%
     SolmrLogger.debug(this, "   END rifiutoAccontoCtrl");
      return;
  }
    }
    SolmrLogger
        .debug(this,
            "[rifiutoAccontoCtrl:service Dopo request.getParameter(\"note\") != null");

    da = umaFacadeClient.findDomAssByPrimaryKey(idDomAss);
    da.setNote(motivazione);
    da.setUtenteAggiornamento(ruoloUtenza.getIdUtente().intValue());

    CodeDescr cdDomAss = new CodeDescr();
    cdDomAss
        .setCode(new Integer(SolmrConstants.ID_STATO_DOMANDA_ANNULLATA));
    cdDomAss.setDescription(SolmrConstants.DESC_STATO_DOMANDA_ANNULLATA);

    SolmrLogger
        .debug(
            this,
            "[rifiutoAccontoCtrl:service umaFacadeClient.rifiutaDomandaAssegnazione (da.getIdDomandaAssegnazione(), da.getNote(), profile)");
    umaFacadeClient.rifiutaDomandaAssegnazione(da
        .getIdDomandaAssegnazione(), da.getNote(), ruoloUtenza);
    response.sendRedirect(CONFERMA);
    SolmrLogger.debug(this, "   END rifiutoAccontoCtrl");
    return;
  }

  da = umaFacadeClient.findDomAssByPrimaryKey(idDomAss);
  request.setAttribute("DomandaAssegnazione", da);
%>
<jsp:forward page="<%=VIEW%>" />
<%
  SolmrLogger.debug(this, "   END rifiutoAccontoCtrl");
%>