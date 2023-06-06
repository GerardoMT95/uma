<%@
  page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.util.*" %>

<%

  SolmrLogger.debug(this,"- attestazioniView.jsp -  INIZIO PAGINA");

  java.io.InputStream layout = application.getResourceAsStream("/macchina/layout/dettaglioMacchinaComproprietari.htm");

  Htmpl htmpl = new Htmpl(layout);

%><%@include file = "/include/menu.inc" %><%
  Vector v_attestazioni = (Vector)session.getAttribute("v_attestazioni");

  MacchinaVO macchinaVO = (MacchinaVO)session.getAttribute("macchinaVO");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  HtmplUtil.setErrors(htmpl, errors, request);

  // Dati identificativi del veicolo

  it.csi.solmr.presentation.security.AutorizzazioneMacchine.writeDatiMacchina(htmpl, macchinaVO);

  // Dati attestazioni

  AttestatoProprietaVO attestatoVO = null;

  if(v_attestazioni!=null&&v_attestazioni.size()!=0){

    htmpl.newBlock("blkDettaglio");

    htmpl.newBlock("blkProprieta");

    Iterator iter = v_attestazioni.iterator();

    int i = 0;

    while(iter.hasNext()){

      attestatoVO = (AttestatoProprietaVO)iter.next();

      htmpl.newBlock("blkProprieta.blkRigaProprieta");

      if(i==0)

        htmpl.set("blkProprieta.blkRigaProprieta.checked", "checked");

      i++;

      htmpl.set("blkProprieta.blkRigaProprieta.idAttestazione", StringUtils.checkNull(attestatoVO.getIdAttestatoProprieta()));

      htmpl.set("blkProprieta.blkRigaProprieta.prov", StringUtils.checkNull(attestatoVO.getSiglaProv()));

      htmpl.set("blkProprieta.blkRigaProprieta.anno", StringUtils.checkNull(attestatoVO.getAnno()));

      htmpl.set("blkProprieta.blkRigaProprieta.numero", StringUtils.checkNull(attestatoVO.getNumeroModello72()));

      htmpl.set("blkProprieta.blkRigaProprieta.data", StringUtils.checkNull(attestatoVO.getDataAttestazione()));

    }

  }

  // Pulsante "indietro"

  if(session.getAttribute("indietro")!=null)

    htmpl.newBlock("blkIndietro");

  SolmrLogger.debug(this,"- attestazioniView.jsp -  FINE PAGINA");

%>

<%= htmpl.text()%>