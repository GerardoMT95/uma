<%@ page language="java"
     contentType="text/html"
     isErrorPage="true"
 %>



<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%

 SolmrLogger.debug(this,"- noteBloccoView.jsp -  INIZIO PAGINA");

 java.io.InputStream layout = application.getResourceAsStream("ditta/layout/noteBloccoPOP.htm");

 Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
 //Correzione Blocco Ditta 19/11/2004 - Begin
 //Vector v_blocchi = (Vector)session.getAttribute("v_blocchi");

 DittaUMAAziendaVO dittaUma = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

 UmaFacadeClient client = new UmaFacadeClient();

 Vector v_blocchi = client.getBlocchiDitta(dittaUma.getIdDittaUMA());
 //Correzione Blocco Ditta 19/11/2004 - End

 Integer indice = null;

 BloccoDittaVO vo = null;

 if(request.getParameter("notaSelezionata")!=null){

   indice = new Integer(request.getParameter("notaSelezionata"));

   int index = indice.intValue();

   vo = (BloccoDittaVO)v_blocchi.elementAt(index-1);

   htmpl.set("note", vo.getNote());

 }

 it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
 
   it.csi.solmr.presentation.security.Autorizzazione aut=
  (it.csi.solmr.presentation.security.Autorizzazione)
  it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ACCESSO_SISTEMA");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  aut.writeBanner(htmpl,ruoloUtenza,request);
%>

<%= htmpl.text()%>