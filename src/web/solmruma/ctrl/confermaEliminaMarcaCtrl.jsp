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
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  private static final String VIEW="../view/confermaEliminaMarcaView.jsp";
  private static final String DETTAGLIO="../macchina/layout/lista_marche.htm";
  private static final String SUCCESS_PAGE="../macchina/layout/eliminaMarcheOk.htm";
%>
<%
  SolmrLogger.debug(this,"confermaEliminaMarcaCtrl started");
  String iridePageName = "confermaEliminaMarcaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%
  UmaFacadeClient umaClient = new UmaFacadeClient();

  //session.setAttribute("refresh", "");

  String genereMacchina = (String)session.getAttribute("ListaMarcheGenereMacchina");
  String descrizioneMarca = (String)session.getAttribute("ListaMarcheDescrizioneMarca");
  String matriceMarca = (String)session.getAttribute("ListaMarcheMatriceMarca");
  SolmrLogger.debug(this,"###### genereMacchina : "+genereMacchina);
  SolmrLogger.debug(this,"###### descrizioneMarca : "+descrizioneMarca);
  SolmrLogger.debug(this,"###### matriceMarca : "+matriceMarca);

  if (request.getParameter("submit")!=null)
  {
    SolmrLogger.debug(this,"submit!!!!!!!");
    session.removeAttribute("elencoIdMarca");
    session.removeAttribute("elencoMarca");
    session.removeAttribute("currPage");
    String idMarca = (String)session.getAttribute("idMarca");
  SolmrLogger.debug(this,"###### session.getAttribute(idMarca) : "+session.getAttribute("idMarca"));
  SolmrLogger.debug(this,"###### new Long(idMarca.trim()) : "+new Long((String)session.getAttribute("idMarca")));
    umaClient.deleteMarca(new Long(idMarca.trim()));
    session.removeAttribute("idMarca");

    response.sendRedirect(DETTAGLIO);
    return;
  }
  if (request.getParameter("submit2")!=null)
  {
    response.sendRedirect(DETTAGLIO);
    return;
  }
%>
<jsp:forward page="<%=VIEW%>" />
