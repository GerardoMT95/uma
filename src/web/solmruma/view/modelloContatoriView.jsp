<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>

<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.Vector" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.integration.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%!

  public static final String LAYOUT="layout/modelloContatori.htm";

%>

<%

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  UmaFacadeClient umaClient = new UmaFacadeClient();

  Collection collProvUMA = (Collection) umaClient.getProvincieByRegione((String) SolmrConstants.get("ID_REGIONE"));


  String idProvinciaUma = ruoloUtenza.getIstatProvincia();

  Long idUtente = ruoloUtenza.getIdUtente();

  //==============================================================

  // Gestione annullamento stampa

  //==============================================================

  String strPagina = "";

  StringTokenizer st = new StringTokenizer(request.getHeader("Referer"),"/",false);

  while (st.hasMoreTokens()) { strPagina = st.nextToken(); }

  if ((session.getAttribute("paginaAnnulla") == null) || ("".equals((String) session.getAttribute("paginaAnnulla")))) {

    session.setAttribute("paginaAnnulla", strPagina);

  } else {

    strPagina = (String) session.getAttribute("paginaAnnulla");

  }

  htmpl.set("paginaAnnulla", strPagina);

  //==============================================================



  String idProvUma = (String) request.getParameter("provUMA");

  if (idProvUma == null) {

    idProvUma = ruoloUtenza.getIstatProvincia();

  }

  if(collProvUMA!=null&&collProvUMA.size()>0){

    Iterator iterProvincia = collProvUMA.iterator();

    while(iterProvincia.hasNext()){

      ProvinciaVO provinciaVO = (ProvinciaVO)iterProvincia.next();

      htmpl.newBlock("comboProvUMA");

      htmpl.set("comboProvUMA.idProvUMA",""+provinciaVO.getIstatProvincia());

      htmpl.set("comboProvUMA.provUMA",provinciaVO.getSiglaProvincia());

      if(idProvUma!=null && provinciaVO.getIstatProvincia().equals(idProvUma)){

        htmpl.set("comboProvUMA.idProvUMASelPunt","selected");

      }

    }

  }



  if (request.getParameter("conferma") == null) {

    htmpl.set("dataUtente", DateUtils.formatDate(new Date()));

  }

  if (request.getAttribute("errors") != null) {

    HtmplUtil.setErrors(htmpl,(ValidationErrors) request.getAttribute("errors") , request);

  } else {

    if (request.getParameter("conferma") != null) {

      htmpl.set("idUtente", idUtente.toString());

      htmpl.set("idProvinciaUma", idProvUma);

      htmpl.set("scriptModelloContatori", "stampaModelloContatori()");

    }

  }

  HtmplUtil.setValues(htmpl, request, (String) session.getAttribute("pathToFollow"));

  response.setContentType("text/html");

  out.println(htmpl.text());

%>