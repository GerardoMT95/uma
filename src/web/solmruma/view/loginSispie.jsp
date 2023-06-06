<%@ page language="java" %>
<%@ page import="it.csi.solmr.util.SolmrLogger" %>
<%@ page import="it.csi.iride2.policy.entity.Identita" %>
<%@ page import="java.util.StringTokenizer" %>
<%!
  public static String VIEW_URL="../view/sceltaRuoloPEP.jsp";
%>

<%
    SolmrLogger.debug(this,"  BEGIN loginSispie.jsp  lettura identita restituita da SHIBBOLETH");

	  Identita identita = (Identita) session.getAttribute("identita");
	  SolmrLogger.debug(this,"-- setto in sessione URL_ACCESS_POINT ="+request.getRequestURI());
	  session.setAttribute("URL_ACCESS_POINT", request.getRequestURI());
	
    response.sendRedirect(VIEW_URL);
%>
