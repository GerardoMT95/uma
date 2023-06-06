<%@ page language="java" contentType="text/html"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  private static final String PREV_CTRL = "/domass/ctrl/dettaglioAssegnazioniSupplementareCtrl.jsp";
  private static final String VIEW      = "/domass/view/confermaEliminaAssCarbView.jsp";
  private static final String NEXT_PAGE = "../layout/dettaglioAssegnazioniSupplementare.htm";
  private static final String PREV_PAGE = "../layout/dettaglioAssegnazioniSupplementare.htm";%>
<%
  String iridePageName = "confermaEliminaAssCarbCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%
  SolmrLogger.debug(this, "   BEGIN confermaEliminaAssCarbCtrl");

  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");
  Long idDittaUma = dittaUMAAziendaVO.getIdDittaUMA();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  UmaFacadeClient umaClient = new UmaFacadeClient();

  SolmrLogger.debug(this,"confermaEliminaAssCarbCtrl - session.getAttribute(\"idAssCarb\") "
          + session.getAttribute("idAssCarb"));

  Long idAssCarb = null;

  if (session.getAttribute("idAssCarb") != null)
  {
    idAssCarb = (Long) session.getAttribute("idAssCarb");
    session.removeAttribute("idAssCarb");
  }
  else
    if (request.getParameter("idAssCarb") != null)
    {
      idAssCarb = new Long(request.getParameter("idAssCarb"));
    }

  request.setAttribute("idAssCarb", idAssCarb);

  SolmrLogger.debug(this,
      "[confermaEliminaAssCarbCtrl::service] request.getAttribute(\"idAssCarb\") ="
          + idAssCarb);

  SolmrLogger.debug(this,
      "[confermaEliminaAssCarbView::service] session.getAttribute(\"idDomAss\"): "
          + session.getAttribute("idDomAss"));

  if (request.getParameter("conferma.x") != null)
  {
    try
    {
      SolmrLogger.debug(this," -------- ELIMINAZIONE Supplemento");
      umaClient.eliminaAssegnazioneSuppl(idAssCarb, ruoloUtenza,
          idDittaUma);
    }
    catch (Exception e)
    {
      throwValidation(e.getMessage(), PREV_CTRL);
    }

    response.sendRedirect(NEXT_PAGE);
    SolmrLogger.debug(this, "   END confermaEliminaAssCarbCtrl");
    return;
  }
  if (request.getParameter("annulla.x") != null)
  {
    response.sendRedirect(PREV_PAGE);
    SolmrLogger.debug(this, "   END confermaEliminaAssCarbCtrl");
    return;
  }
  SolmrLogger.debug(this, "   END confermaEliminaAssCarbCtrl");
%>
<jsp:forward page="<%=VIEW%>" />
<%!private void throwValidation(String msg, String validateUrl)
      throws ValidationException
  {
    ValidationException valEx = new ValidationException(msg, validateUrl);
    valEx.addMessage(msg, "exception");
    throw valEx;
  }%>
