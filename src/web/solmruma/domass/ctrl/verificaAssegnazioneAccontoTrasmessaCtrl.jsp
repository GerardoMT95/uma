<%@ page language="java" contentType="text/html"%>
<%@page import="it.csi.solmr.client.uma.UmaFacadeClient"%>
<%@page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO"%>
<%@page import="it.csi.solmr.dto.uma.DomandaAssegnazione"%>
<%@page import="it.csi.solmr.util.IrideFileParser"%>
<%!private static final String VIEW_URL = "/domass/view/verificaAssegnazioneAccontoTrasmessaView.jsp";%>
<%
  String iridePageName = "verificaAssegnazioneAccontoTrasmessaCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%
  request.setAttribute("__autorizzazione",IrideFileParser.elencoSecurity.get("ASSEGNAZIONE_ACCONTO"));
  UmaFacadeClient umaClient=new UmaFacadeClient();
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
  DomandaAssegnazione accontoVO=umaClient.findAccontoCorrenteByIdDittaUMA(dittaUMAAziendaVO.getIdDittaUMA());
  request.setAttribute("accontoVO",accontoVO);
 %>
<jsp:forward page="<%=VIEW_URL%>" />
