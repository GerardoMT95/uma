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
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  public static final String LAYOUT="/macchina/layout/modifica_marche.htm";
%>
<%
  SolmrLogger.debug(this,"Sono in modifica_marcheView.jsp");
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%

  if(request.getAttribute("idMarca")!=null)
    htmpl.set("idMarca", (String)request.getAttribute("idMarca"));
  if(request.getAttribute("genereMacchina")!=null)
  {
    SolmrLogger.debug(this,"-------------------genereMacchina "+request.getAttribute("genereMacchina"));
    htmpl.set("genereMacchina", (String)request.getAttribute("genereMacchina"));
    SolmrLogger.debug(this,"genereMacchina: "+(String)request.getAttribute("genereMacchina"));
    if( request.getAttribute("genereMacchina")!=null && (!((String)request.getAttribute("genereMacchina")).trim().equalsIgnoreCase("")) ){
      htmpl.set("descrizioneGenereMacchina", umaClient.getDescGenereMacchina(new Long((String)request.getAttribute("genereMacchina"))));
    }
  }
  if(request.getAttribute("descrizioneMarca")!=null)
  {
    htmpl.set("descrizioneMarca", (String)request.getAttribute("descrizioneMarca"));
  }
  if(request.getAttribute("descrizioneMarcaMod")!=null)
  {
    htmpl.set("descrizioneMarcaMod", (String)request.getAttribute("descrizioneMarcaMod"));
  }

  if(request.getAttribute("matriceMarca")!=null)
    htmpl.set("matriceMarca", (String)request.getAttribute("matriceMarca"));
  if(request.getAttribute("matriceMarcaMod")!=null)
    htmpl.set("matriceMarcaMod", (String)request.getAttribute("matriceMarcaMod"));
  if(request.getAttribute("genereMacchina")!=null)
    htmpl.set("genereMacchina", (String)request.getAttribute("genereMacchina"));

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
  out.print(htmpl.text());
%>

