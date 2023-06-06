  <%@ page language="java"

      contentType="text/html"

      isErrorPage="true"

  %>

<%@ page import="it.csi.solmr.exception.*" %>

<%@ page import="it.csi.jsf.htmpl.*" %>

<%@ page import="it.csi.solmr.util.*" %>

<%@ page import="java.util.*" %>

<%

String msg = ((Exception)session.getAttribute("exception")).getMessage();

session.removeAttribute("exception");

java.io.InputStream layout = application.getResourceAsStream("/layout/errore.htm");

Htmpl h = new Htmpl(layout);

String daLayout = (String)request.getAttribute("layout");

if (daLayout!=null) {

  StringTokenizer st = new StringTokenizer(daLayout, "/");

  int counter = 0;

  while (st.hasMoreTokens()) {

    counter++;

    st.nextToken();

  }

  String daPath = "";

  for (int i=0; i<(counter-2); i++) {

    daPath = "../"+daPath;

  }

  if (daPath.length()!=0) {

    String path = (String)session.getAttribute("pathToFollow");

    if (path == null) path = "sispie";

    daPath += path;

    h.bset("pathToFollow", daPath);

    h.set("pathToFollow", daPath);

  }

}

h.set("exception", msg);

//session.setAttribute("backPage", session.getAttribute("backPageDefault"));

  it.csi.solmr.presentation.security.Autorizzazione aut=
  (it.csi.solmr.presentation.security.Autorizzazione)
  it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ACCESSO_SISTEMA");
  it.csi.solmr.dto.ProfiloUtenza profiloUtenza =   (it.csi.solmr.dto.ProfiloUtenza)
  session.getAttribute("profile");
  aut.writeBanner(h,profiloUtenza.getRuoloUtenza(),request);

%>

<%= h.text() %>

