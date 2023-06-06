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
<%@ page import="it.csi.solmr.dto.comune.IntermediarioVO" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%!

  public static final String LAYOUT="layout/modelloDistinta.htm";

%>

<%

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  AnagFacadeClient anagFacadeClient = new AnagFacadeClient();

  Collection collProvUMA = (Collection)anagFacadeClient.getProvinceByRegione(SolmrConstants.ID_REGIONE);

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

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



  if (request.getParameter("conferma") == null) {

    htmpl.set("dataFineValidita", DateUtils.formatDate(new Date()));

  }



  String idProvUma = (String)request.getParameter("provUMA");

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



  if (request.getAttribute("errors") != null) {

    HtmplUtil.setErrors(htmpl,(ValidationErrors) request.getAttribute("errors") , request);

  } else {

    if (request.getParameter("conferma") != null) {

      //htmpl.set("dittaUma", idDittaUma.toString());

      htmpl.set("idUtente", idUtente.toString());

      htmpl.set("scriptModelloDistinta", "stampaModelloDistinta()");

      if ((request.getParameter("oraInizio") != null) && !("".equals(request.getParameter("oraInizio")))) {

        htmpl.set("oraInizioI", request.getParameter("oraInizio"));

      } else {

        htmpl.set("oraInizioI", "00:00:01");

      }

      if ((request.getParameter("oraFine") != null) && !("".equals(request.getParameter("oraFine")))) {

        htmpl.set("oraFineI", request.getParameter("oraFine"));

      } else {

        htmpl.set("oraFineI", "23:59:59");

      }

    }

  }


  TreeMap intermediariTM=(TreeMap)request.getAttribute("intermediari");
  java.util.Iterator iterator=intermediariTM.keySet().iterator();
  String idIntermediarioSelected=request.getParameter("idIntermediario");
  while(iterator.hasNext())
  {
    String key=(String)iterator.next();
    htmpl.newBlock("blkOptionCAA");
    IntermediarioVO iVO=(IntermediarioVO) intermediariTM.get(key);
    String idIntermediario=iVO.getIdIntermediario().toString();
    if (idIntermediario.equals(idIntermediarioSelected))
    {
      htmpl.set("blkOptionCAA.selected",SolmrConstants.HTML_SELECTED);
    }
    htmpl.set("blkOptionCAA.value",idIntermediario);
    htmpl.set("blkOptionCAA.descrizione",key);
  }


  HtmplUtil.setValues(htmpl, request, (String) session.getAttribute("pathToFollow"));

  response.setContentType("text/html");

  out.println(htmpl.text());

%>