<%@page language="java" contentType="text/html" isErrorPage="true"%><%@page
	import="it.csi.solmr.util.*"%>
<%@page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO"%>
<%@page import="it.csi.solmr.client.uma.UmaFacadeClient"%>
<%@page import="it.csi.solmr.etc.SolmrConstants"%>
<%@page import="java.util.Vector"%>
<%@page import="it.csi.solmr.dto.uma.DomandaAssegnazione"%><%!public final static String VIEW                         = "../view/controlliAccontoFineView.jsp";
  public final static String ASSEGNAZIONE_ACCONTO         = "../layout/assegnazioneAcconto.htm";
  public final static String ASSEGNAZIONE_ACCONTO_CONSUMI = "../layout/verificaAssegnazioneAccontoConsumi.htm";
  public final static String CLOSE_URL                    = "../layout/assegnazioni.htm";%>
<%
  SolmrLogger.debug(this, " - controlliAccontoCtrl.jsp - INIZIO PAGINA");
  session.removeAttribute("ASSEGNAZIONE_VALIDA");
  request.setAttribute("closeUrl", CLOSE_URL);
  String iridePageName = "controlliAccontoFineCtrl.jsp";
  request.setAttribute("noCheckIntermediario", "TRUE");
%><%@include file="/include/autorizzazione.inc"%>
<%
  request.setAttribute("historyNum", "-2");
  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  Long idDittaUMA = dittaVO.getIdDittaUMA();
  Long annoAssegnazione = new Long(DateUtils.getCurrentYear().longValue());
  umaFacadeClient.preControlliPraticaPL(idDittaUMA, annoAssegnazione,
      SolmrConstants.TIPO_CONTROLLO_PL_B,
      SolmrConstants.TIPO_FASE_PL_ACCONTO);
  Vector vErroriControlli = umaFacadeClient.getErroriControlliNegativi(
      idDittaUMA, annoAssegnazione);
  if (vErroriControlli == null || vErroriControlli.size() == 0)
  {
    DomandaAssegnazione accontoVO = (DomandaAssegnazione) request
        .getAttribute("accontoVO");
    boolean inAttesaValidazione = accontoVO != null
        && accontoVO.getIdStatoDomanda().intValue() == new Integer(
            SolmrConstants.ID_STATO_DOMANDA_ATTESA_VAL_PA).intValue();
    if (inAttesaValidazione)
    {
      response.sendRedirect(ASSEGNAZIONE_ACCONTO);
    }
    else
    {
      response.sendRedirect(ASSEGNAZIONE_ACCONTO_CONSUMI);
    }
    return;
  }
  request.setAttribute("vErroriControlli", vErroriControlli);
%><jsp:forward page="<%=VIEW%>" />
<%
  SolmrLogger.debug(this, " - controlliAccontoFineCtrl.jsp - FINE PAGINA");
%>