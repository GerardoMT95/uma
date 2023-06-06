<%@ page language="java"
         contentType="text/html"
         import="it.csi.jsf.htmpl.Htmpl, it.csi.solmr.exception.ValidationException, it.csi.solmr.util.*"
         isErrorPage="true"
%><%
  ValidationException valEx = (ValidationException)exception;
  String errorPage = valEx.getErrorPage();
  if (null != errorPage) {
    String daMess = valEx.getMessage("exception");
    if (daMess != null && request.getAttribute("errors") == null) {
      ValidationErrors errors = new ValidationErrors();
      ValidationError error = new ValidationError(daMess);
      errors.add("error", error);
      request.setAttribute("errors", errors);
    }
    pageContext.forward(errorPage);
  } else
    throw new ServletException("ErrorPage not set", valEx);
%>