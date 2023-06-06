<%@
  page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>

<%

  SolmrLogger.debug(this,"- attestazioniNewConfermaView.jsp -  INIZIO PAGINA");

  java.io.InputStream layout = application.getResourceAsStream("/macchina/layout/NuovaAttestazioneConferma.htm");

  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");



  MacchinaVO macchinaVO = null;

  if(session.getAttribute("common") instanceof MacchinaVO){

    SolmrLogger.debug(this,"Instance of MacchinaVO");

    macchinaVO = (MacchinaVO)session.getAttribute("common");

  }

  // Dati Ditta UMA

  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

  if(dittaVO.getCuaa()!=null&&!dittaVO.getCuaa().equals(""))

    htmpl.set("CUAA",dittaVO.getCuaa()+" - ");

  htmpl.set("denominazione",dittaVO.getDenominazione());

  htmpl.set("dittaUMA",dittaVO.getDittaUMAstr());

  htmpl.set("umaTipoDitta",dittaVO.getTipiDitta());

  htmpl.set("prov", dittaVO.getDescProvinciaUma());

  // Dati identificativi del veicolo

  it.csi.solmr.presentation.security.AutorizzazioneMacchine.writeDatiMacchina(htmpl, macchinaVO);

  // Dati attestazione appena inserita

  AttestatoProprietaVO attestatoVO = (AttestatoProprietaVO)request.getAttribute("attestatoNewVO");

  SolmrLogger.debug(this,"Valori di provincia: "+attestatoVO.getDescProv()+" - "+attestatoVO.getSiglaProv()+

                     " - "+ruoloUtenza.getIstatProvincia() + " - "+ruoloUtenza.getProvincia());

  htmpl.set("prov", attestatoVO.getDescProv());

  htmpl.set("anno", attestatoVO.getAnno());

  htmpl.set("numero", attestatoVO.getNumeroModello72());

  htmpl.set("data", attestatoVO.getDataAttestazione());

  SolmrLogger.debug(this,"- attestazioniNewConfermaView.jsp -  FINE PAGINA");

%>

<%= htmpl.text()%>