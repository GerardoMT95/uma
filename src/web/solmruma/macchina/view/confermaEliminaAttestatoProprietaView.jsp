<%@
  page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@page import="it.csi.solmr.dto.uma.AttestatoProprietaVO"%>
<%@page import="it.csi.solmr.util.DateUtils"%>
<%
  java.io.InputStream layout = application
      .getResourceAsStream("/macchina/layout/confermaEliminaAttestatoProprieta.htm");
  Htmpl htmpl = new Htmpl(layout);
%><%@include file="/include/menu.inc"%>
<%
  String radioAttestazione = request.getParameter("radioAttestazione");
  AttestatoProprietaVO apVO = (AttestatoProprietaVO) request
      .getAttribute("attestatoProprietaVO");
  htmpl.newBlock("blkHidden");
  htmpl.set("blkHidden.hdnName", "radioAttestazione");
  htmpl.set("blkHidden.hdnValue", radioAttestazione);
  htmpl.set("page", "confermaEliminaAttestatoProprieta.htm");
  String dataAttestazione ="";
  if(apVO.getDataAttestazioneDate() != null)
    dataAttestazione = " del "+DateUtils.formatDate(apVO.getDataAttestazioneDate());
  
  htmpl
      .set(
          "messaggio",
          new StringBuffer(
              "ATTENZIONE! Procedendo l'attestato di proprietà verrà eliminato e non portrà più essere ripristinato. "
                  + " Sei sicuro di voler procedere con l'eliminazione dell'attestato di proprietà ")
              .append(apVO.getSiglaProv()).append(" - ").append(
                  apVO.getAnno()).append(" n° ").append(
                  apVO.getNumeroModello72()).append(dataAttestazione).append('?')
              .toString());
%>
<%=htmpl.text()%>