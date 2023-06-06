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
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>

<%!
  public static final String LAYOUT="layout/conferma.htm";
  public static final String PAGE_NAME="confermaTargaNonTrovata";
  public static final String MSG_RICHIESTA_CONFERMA="La targa indicata non "+
      "risulta presente in archivio. Controllare i dati imputati relativi a "+
      "numero targa e ditta uma di provenienza. Scegliere Continua per "+
      "proseguire, Chiudi per abbandonare l'operazione.";
%>
<%
  SolmrLogger.debug(this,"confermaTargaNonTrovataView started");

//---------------- Ricerca in sessione delle variabili necessarie --------------
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  htmpl.set("msg",MSG_RICHIESTA_CONFERMA);
  htmpl.set("page",PAGE_NAME);
%>
<%=htmpl.text()%>
