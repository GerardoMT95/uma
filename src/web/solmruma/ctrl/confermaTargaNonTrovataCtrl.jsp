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
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>

<%!
  public static final String VIEW="../view/confermaTargaNonTrovataView.jsp";
  public static final String NEXT="../macchina/layout/macchinaUsataNonTrovataGenere.htm";
  public static final String PREV="../macchina/layout/macchinaUsataTarga.htm";
%>
<%
  String iridePageName = "confermaTargaNonTrovataCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%
  if (request.getParameter("submit2")!=null)
  {
    HashMap common;
    if (session.getAttribute("common") instanceof java.util.HashMap)
    {
      common=(HashMap)session.getAttribute("common");
      common.put("indietro","indietro");
    }

    response.sendRedirect(PREV);
    return;
  }
  if (request.getParameter("submit")!=null)
  {
    response.sendRedirect(NEXT);
    return;
  }
%>
<jsp:forward page="<%=VIEW%>" />
