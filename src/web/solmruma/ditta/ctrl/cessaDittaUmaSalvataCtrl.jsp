<%@ page import="it.csi.solmr.util.*,it.csi.solmr.dto.uma.*" %>

<%@ page language="java"
  contentType="text/html"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>

<%

  String iridePageName = "cessaDittaUmaSalvataCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "cessaDittaUmaSalvataCtrl.jsp - Begin");

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  //String url = "/ditta/layout/cessaDittaUmaSalvata.htm";
  String url = "/ditta/view/cessaDittaUmaSalvataView.jsp";

  ValidationException valEx = null;
  Validator validator = new Validator(url);

%>
<jsp:forward page="<%=url%>"/>
