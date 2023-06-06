<%@page import="it.csi.solmr.util.SolmrLogger"%>
<%@ page language="java" contentType="text/html"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!private static final String VIEW                     = "/domass/view/confermaTrasmissioneAccontoView.jsp";
  private static final String NEXT_PAGE                = "../layout/verificaAssegnazioneAccontoTrasmessa.htm";
  private static final String PREV_PAGE                = "../layout/verificaAssegnazioneAccontoSalvata.htm";
  private static final Long   IN_ATTESA_VALIDAZIONE_PA = new Long(20);%>
<%
  String iridePageName = "confermaTrasmissioneAccontoCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%
 SolmrLogger.debug(this, "   BEGIN confermaTrasmissioneAccontoCtrl");
  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");
  Long idDittaUma = dittaUMAAziendaVO.getIdDittaUMA();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  if (request.getParameter("conferma.x") != null)
  {
    DomandaAssegnazione da = new DomandaAssegnazione();
    UmaFacadeClient client = new UmaFacadeClient();
    DomandaAssegnazione accontoVO = (DomandaAssegnazione) request
        .getAttribute("accontoVO");
    da.setIdDomandaAssegnazione(accontoVO.getIdDomandaAssegnazione());
    da.setIdStatoDomanda(IN_ATTESA_VALIDAZIONE_PA);
    client.trasmettiAssegnazioneAcconto(da.getIdDomandaAssegnazione(),
        ruoloUtenza);
    response.sendRedirect(NEXT_PAGE);
    return;
  }
  if (request.getParameter("annulla.x") != null)
  {
    response.sendRedirect(PREV_PAGE);
    return;
  }
%>
<jsp:forward page="<%=VIEW%>" />