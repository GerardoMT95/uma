<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*"%>

<%
  SolmrLogger.debug(this,"- eliminaMacchinaView.jsp -  INIZIO PAGINA");
  java.io.InputStream layout = application.getResourceAsStream("/layout/conferma.htm");
  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
  htmpl.set("page", "conferma");
  htmpl.set("msg", "Dopo l'eliminazione non sarà più possibile recuperare il dato, l'operazione deve essere utilizzata solo per eliminazione di errori. Procedere con l'eliminazione della macchina?");
  SolmrLogger.debug(this,"- eliminaMacchinaView.jsp -  FINE PAGINA");
%>
<%= htmpl.text()%>