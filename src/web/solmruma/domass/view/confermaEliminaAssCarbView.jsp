<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%
  SolmrLogger.debug(this,"Entering confermaEliminaAssCarbView.jsp");
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(
      "/domass/layout/confermaEliminaAssCarb.htm");
%><%@include file="/include/menu.inc"%>
<%
  Long idAssCarb = ((Long) request.getAttribute("idAssCarb"));
  SolmrLogger.debug(this,
      "[confermaEliminaAssCarbView::service] request.getAttribute(\"idAssCarb\") ="
          + idAssCarb);

  htmpl.set("idAssCarb", idAssCarb.toString());
  HtmplUtil.setErrors(htmpl, (ValidationErrors) request
      .getAttribute("errors"), request);
  out.print(htmpl.text());
%>

