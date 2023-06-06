<%@page import="it.csi.solmr.etc.SolmrConstants"%>
<%@page import="it.csi.solmr.client.uma.UmaFacadeClient"%>
<%@page import="it.csi.solmr.etc.uma.UmaErrors"%>
<%@page import="it.csi.solmr.exception.SolmrException"%>
<%@page import="it.csi.solmr.util.DateUtils"%>
<%!// Costanti
  private static final String VIEW = "/domass/view/stampaPrelieviView.jsp";%>
<%
  String iridePageName = "stampaPrelieviCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%
  UmaFacadeClient ufc = new UmaFacadeClient();
  String dtbp = ufc.getParametro(SolmrConstants.PARAMETRO_DTBP);
  try
  {
    request.setAttribute("annoIniziale", new Integer(DateUtils
        .extractYearFromDate(DateUtils.parseDate(dtbp))));
  }
  catch (Exception e)
  {
    throw new SolmrException(UmaErrors.ERRORE_PARAMETRO_DTBP_NON_VALIDO);
  }
%><jsp:forward page="<%=VIEW%>" />
