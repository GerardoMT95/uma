<%@
  page language="java"
  contentType="text/html"
  isErrorPage="true"
%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.etc.*"%>
<%

  java.io.InputStream layout = application.getResourceAsStream("/macchina/layout/inserimentoMatriciOk.htm");
  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
  MatriceVO matriceVO = (MatriceVO)session.getAttribute("matriceVO");
  session.removeAttribute("matriceVO");
  htmpl.set("numeroMatrice", matriceVO.getNumeroMatrice());

%>
<%= htmpl.text()%>