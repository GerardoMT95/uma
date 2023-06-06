<%@ page language="java" contentType="text/html"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%!private static final String LAYOUT_PAGE = "/domass/layout/verificaAssegnazioneAccontoTrasmessa.htm";%>
<%
  SolmrLogger.debug(this,"verificaAssegnazioneTrasmessaView.jsp -  INIZIO PAGINA");
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT_PAGE);
%><%@include file="/include/menu.inc"%>
<%
  DomandaAssegnazione accontoVO = (DomandaAssegnazione) request
      .getAttribute("accontoVO");
  htmpl.set("annoCorrente", ""
      + DateUtils.extractYearFromDate(accontoVO.getDataRiferimento()));
  htmpl.set("dataRiferimento", DateUtils.formatDate(accontoVO
      .getDataRiferimento()));
  htmpl.set("idDomAss", accontoVO.getIdDomandaAssegnazione().toString());
%>
<%=htmpl.text()%>