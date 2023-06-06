<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.SolmrLogger" %>

<%!
  public static final String LAYOUT = "/domass/layout/controlliEsegui.htm";
  public static final String NEXT_PAGE="../layout/controlliAccontoFine.htm";
%>

<%
  SolmrLogger.info(this, " - controlliEseguiView.jsp - INIZIO PAGINA");

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
	htmpl.set("nextPage",NEXT_PAGE);
	htmpl.set("goNext","goNext()");
  SolmrLogger.info(this, " - controlliEseguiView.jsp - FINE PAGINA");
%><%=htmpl.text()%>