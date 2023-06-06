<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(
      "domass/layout/confermaEliminaDomAss.htm");
%><%@include file="/include/menu.inc"%>
<%
  Long idDomAss = null;
  if (request.getParameter("idDomAss") != null)
  {
    idDomAss = new Long(request.getParameter("idDomAss"));
    htmpl.set("idDomAss", "" + idDomAss);
  }

  if (request.getParameter("annullaBuoni") != null)
  {
    htmpl.set("annullaBuoni", request.getParameter("annullaBuoni"));
  }

  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,
      exception);
  out.print(htmpl.text());
%>
