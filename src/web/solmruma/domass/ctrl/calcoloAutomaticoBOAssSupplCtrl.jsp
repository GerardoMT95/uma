
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
<%@ page import="it.csi.solmr.etc.*" %>
<%!
  private static final String VIEW_URL="/domass/view/calcoloAutomaticoBOAssSupplView.jsp";
%>
<%  String iridePageName = "calcoloAutomaticoBOAssSupplCtrl.jsp";
%><%@include file = "/include/autorizzazione.inc" %>
<jsp:forward page="<%=VIEW_URL%>" />
