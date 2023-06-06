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
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>

<%



  java.io.InputStream layout = application.getResourceAsStream("/macchina/layout/inserimentoMatrici.htm");

  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  // Recupero l'elenco con il genere macchine

  Vector elencoMacchine = null;

  try {

    elencoMacchine = umaFacadeClient.getGenereMacchinaForMatrici();

  }

  catch(SolmrException se) {

  }



  String genereMacchina = (String)session.getAttribute("genereMacchina");

  Iterator iteraMacchine = elencoMacchine.iterator();

  while(iteraMacchine.hasNext()) {

    htmpl.newBlock("genereMacchina");

    CodeDescr code = (CodeDescr)iteraMacchine.next();

    if(genereMacchina != null) {

      if(genereMacchina.equalsIgnoreCase(code.getCode().toString())) {

        htmpl.set("genereMacchina.check","selected");

      }

    }

    htmpl.set("genereMacchina.idCodice", code.getCode().toString());

    htmpl.set("genereMacchina.descrizione", code.getDescription());

  }





  String categoria = (String)session.getAttribute("categoria");

  // Recupero l'elenco delle categorie

  Vector elencoCategorie = (Vector)session.getAttribute("elencoCategorie");

  if(elencoCategorie != null) {

    if(elencoCategorie.size() == 0) {

      htmpl.set("larghezza","style= width:230px");

    }

    Iterator iteraCategorie = elencoCategorie.iterator();

    while(iteraCategorie.hasNext()) {

      htmpl.newBlock("categoria");

      CodeDescr code = (CodeDescr)iteraCategorie.next();

      if(categoria != null) {

        if(categoria.equalsIgnoreCase(code.getCode().toString())) {

          htmpl.set("categoria.check","selected");

        }

      }

      htmpl.set("categoria.idCodice", code.getCode().toString());

      htmpl.set("categoria.descrizione", code.getDescription());

    }

  }

  else {

    htmpl.set("larghezza","style= width:230px");

  }



  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");



  MatriceVO inserimentoMatriceVO = (MatriceVO)session.getAttribute("inserimentoMatriceVO");



  if(errors == null) {

    HtmplUtil.setValues(htmpl,inserimentoMatriceVO);

    HtmplUtil.setValues(htmpl,request);

  }

  else {

    HtmplUtil.setErrors(htmpl,errors,request);

    HtmplUtil.setValues(htmpl,inserimentoMatriceVO);

  }

%>

<%= htmpl.text()%>