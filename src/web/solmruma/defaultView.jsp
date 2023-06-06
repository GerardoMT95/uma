<%@ page language="java"

    contentType="text/html"

    isErrorPage="true"

%>

<%@ page import="it.csi.solmr.exception.*"%>

<%@ page import="it.csi.solmr.util.*"%>

<%@ page import="it.csi.jsf.htmpl.*"%>

<%@ page import="java.util.Vector" %>

<%

try {

  String sLayout = (String) request.getAttribute("layout");

  java.io.InputStream is = application.getResourceAsStream(sLayout);

  Htmpl html = new Htmpl(is);

  response.setContentType("text/html");

  it.csi.solmr.presentation.security.Autorizzazione aut=
  (it.csi.solmr.presentation.security.Autorizzazione)
  it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ACCESSO_SISTEMA");
  it.csi.solmr.dto.ProfiloUtenza profiloUtenza =   (it.csi.solmr.dto.ProfiloUtenza)
  session.getAttribute("profile");
  aut.writeBanner(html,profiloUtenza.getRuoloUtenza(),request);

  out.println(html.text());

}

catch ( Exception e ) {

  SolmrException exc = new SolmrException("La pagina richiesta non esiste");

  session.setAttribute("exception", exc);

  session.setAttribute("backPage", "javascript:history.back()");

%>

  <jsp:forward page ="errorPage.jsp"/>

<%

}

%>