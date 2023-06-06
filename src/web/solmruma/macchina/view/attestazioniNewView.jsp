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

<%

  SolmrLogger.debug(this,"- attestazioniNewView.jsp -  INIZIO PAGINA");

  java.io.InputStream layout = application.getResourceAsStream("/macchina/layout/dettaglioMacchinaDittaNuovaAttestazione.htm");

  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  HtmplUtil.setErrors(htmpl, errors, request);

  Vector v_attestazioni = (Vector)session.getAttribute("v_attestazioni");

  //Vector v_intestatari = (Vector)session.getAttribute("v_intestatari");

  Vector v_locatari = (Vector)session.getAttribute("v_locatari");

  SolmrLogger.debug(this,"Size v_locatari "+v_locatari.size());

  Vector v_societa = (Vector)session.getAttribute("v_societa");

  SolmrLogger.debug(this,"Size v_societa "+v_societa.size());

  Vector v_soggetti = (Vector)session.getAttribute("v_soggetti");

  SolmrLogger.debug(this,"Size v_soggetti "+v_soggetti.size());

  MacchinaVO macchinaVO = null;

  IntestatariVO intVO = null;

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


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

  htmpl.set("provincia", dittaVO.getDescProvinciaUma());

  // Dati identificativi del veicolo

  it.csi.solmr.presentation.security.AutorizzazioneMacchine.writeDatiMacchina(htmpl, macchinaVO);

  // Intestatari

  //Iterator i_int = v_intestatari.iterator();

  int sogg = 0;

  int loc = 0;

  int soc = 0;

  /*while(i_prop.hasNext()){

    intVO = (IntestatariVO)i_int.next();

    SolmrLogger.debug(this,"Valore di Tipo Intestatario... "+intVO.getTipoIntestatario());

    // Ditta Locataria

    if (intVO.getTipoIntestatario()!=null&&intVO.getTipoIntestatario().equals("L")){

      if(loc==0){

        htmpl.newBlock("blkDittaLocataria");

        loc++;

      }

      htmpl.newBlock("blkDittaLocataria.blkRigaDitta");

      htmpl.set("blkDittaLocataria.blkRigaDitta.partitaIVA", StringUtils.checkNull(intVO.getDittaLocataria().getPartitaIVA()));

      htmpl.set("blkDittaLocataria.blkRigaDitta.denominazione", StringUtils.checkNull(intVO.getDittaLocataria().getDenominazione()));

      htmpl.set("blkDittaLocataria.blkRigaDitta.comune", StringUtils.checkNull(intVO.getDittaLocataria().getSedelegComune()));

      htmpl.set("blkDittaLocataria.blkRigaDitta.cap", StringUtils.checkNull(intVO.getDittaLocataria().getSedelegCAP()));

      if(intVO.getDittaLocataria().getSedelegProv()!=null&&!intVO.getDittaLocataria().getSedelegProv().equals(""))

        htmpl.set("blkDittaLocataria.blkRigaDitta.siglaProv", "("+intVO.getDittaLocataria().getSedelegProv()+")");

      htmpl.set("blkDittaLocataria.blkRigaDitta.indirizzo", StringUtils.checkNull(intVO.getDittaLocataria().getSedelegIndirizzo()));

    }

    // Società Utilizzatrici

    else if(intVO.getTipoIntestatario()!=null&&intVO.getTipoIntestatario().equals("A")){

      if(soc==0){

        htmpl.newBlock("blkSocietaUtilizzatrice");

        soc++;

      }

      htmpl.newBlock("blkSocietaUtilizzatrice.blkRigaSocieta");

      htmpl.set("blkSocietaUtilizzatrice.blkRigaSocieta.provUMA", StringUtils.checkNull(intVO.getSiglaProvinciaUMA()));

      htmpl.set("blkSocietaUtilizzatrice.blkRigaSocieta.dittaUMA", StringUtils.checkNull(intVO.getDittaUMA()));

      htmpl.set("blkSocietaUtilizzatrice.blkRigaSocieta.CUAA", StringUtils.checkNull(intVO.getSocieta().getCUAA()));

      htmpl.set("blkSocietaUtilizzatrice.blkRigaSocieta.denominazione", StringUtils.checkNull(intVO.getSocieta().getDenominazione()));

      htmpl.set("blkSocietaUtilizzatrice.blkRigaSocieta.comune", StringUtils.checkNull(intVO.getSocieta().getSedelegComune()));

      htmpl.set("blkSocietaUtilizzatrice.blkRigaSocieta.cap", StringUtils.checkNull(intVO.getSocieta().getSedelegCAP()));

      if(intVO.getSocieta().getSedelegProv()!=null&&!intVO.getSocieta().getSedelegProv().equals(""))

         htmpl.set("blkSocietaUtilizzatrice.blkRigaSocieta.siglaProv", "("+intVO.getSocieta().getSedelegProv()+")");

      htmpl.set("blkSocietaUtilizzatrice.blkRigaSocieta.indirizzo", StringUtils.checkNull(intVO.getSocieta().getSedelegIndirizzo()));

    }

    // Sogetti Collegati

    else if(intVO.getTipoIntestatario()!=null&&intVO.getTipoIntestatario().equals("P")){

      SolmrLogger.debug(this,"Entro in P");

      if(sogg==0){

        htmpl.newBlock("blkSoggettiCollegati");

        sogg++;

      }

      htmpl.newBlock("blkSoggettiCollegati.blkRigaSoggetti");

      htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.provUMA", StringUtils.checkNull(intVO.getSiglaProvinciaUMA()));

      htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.dittaUMA", StringUtils.checkNull(intVO.getDittaUMA()));

      htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.codFiscale", StringUtils.checkNull(intVO.getSoggetti().getCodiceFiscale()));

      htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.cognome", StringUtils.checkNull(intVO.getSoggetti().getCognome()));

      htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.nome", StringUtils.checkNull(intVO.getSoggetti().getNome()));

      htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.comune", StringUtils.checkNull(intVO.getSoggetti().getDescResComune()));

      htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.cap", StringUtils.checkNull(intVO.getSoggetti().getResCAP()));

      if(intVO.getSoggetti().getResProvincia()!=null&&!intVO.getSoggetti().getResProvincia().equals(""))

        htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.siglaProv", "("+intVO.getSoggetti().getResProvincia()+")");

      htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.indirizzo", StringUtils.checkNull(intVO.getSoggetti().getResIndirizzo()));

    }

  }*/

  if(v_locatari!=null&&v_locatari.size()!=0){

    SolmrLogger.debug(this,"Entro in locataria");

    htmpl.newBlock("blkDittaLocataria");

  }

  Iterator i_loc = v_locatari.iterator();

  while(i_loc.hasNext()){

    intVO = (IntestatariVO)i_loc.next();

    htmpl.newBlock("blkDittaLocataria.blkRigaDitta");

    htmpl.set("blkDittaLocataria.blkRigaDitta.partIVA", StringUtils.checkNull(intVO.getLocatariaOSocieta().getPartitaIVA()));

    htmpl.set("blkDittaLocataria.blkRigaDitta.denominazione", StringUtils.checkNull(intVO.getLocatariaOSocieta().getDenominazione()));

    htmpl.set("blkDittaLocataria.blkRigaDitta.comune", StringUtils.checkNull(intVO.getLocatariaOSocieta().getSedelegComune()));

    htmpl.set("blkDittaLocataria.blkRigaDitta.cap", StringUtils.checkNull(intVO.getLocatariaOSocieta().getSedelegCAP()));

    if(intVO.getLocatariaOSocieta().getSedelegProv()!=null&&!intVO.getLocatariaOSocieta().getSedelegProv().equals(""))

      htmpl.set("blkDittaLocataria.blkRigaDitta.siglaProv", "("+intVO.getLocatariaOSocieta().getSedelegProv()+")");

    htmpl.set("blkDittaLocataria.blkRigaDitta.indirizzo", ", "+StringUtils.checkNull(intVO.getLocatariaOSocieta().getSedelegIndirizzo()));

  }

  Iterator i_soc = v_societa.iterator();

  if(v_societa!=null&&v_societa.size()!=0){

    SolmrLogger.debug(this,"Entro in societa");

    htmpl.newBlock("blkSocieta");

  }

  while(i_soc.hasNext()){

    intVO = (IntestatariVO)i_soc.next();

    htmpl.newBlock("blkSocieta.blkRigaSocieta");

    htmpl.set("blkSocieta.blkRigaSocieta.provUMA", StringUtils.checkNull(intVO.getSiglaProvinciaUMA()));

    htmpl.set("blkSocieta.blkRigaSocieta.dittaUMA", StringUtils.checkNull(intVO.getDittaUMA()));

    htmpl.set("blkSocieta.blkRigaSocieta.CUAA", StringUtils.checkNull(intVO.getLocatariaOSocieta().getCUAA()));

    htmpl.set("blkSocieta.blkRigaSocieta.denominazione", StringUtils.checkNull(intVO.getLocatariaOSocieta().getDenominazione()));

    htmpl.set("blkSocieta.blkRigaSocieta.comune", StringUtils.checkNull(intVO.getLocatariaOSocieta().getSedelegComune()));

    htmpl.set("blkSocieta.blkRigaSocieta.cap", StringUtils.checkNull(intVO.getLocatariaOSocieta().getSedelegCAP()));

    if(intVO.getLocatariaOSocieta().getSedelegProv()!=null&&!intVO.getLocatariaOSocieta().getSedelegProv().equals(""))

      htmpl.set("blkSocieta.blkRigaSocieta.siglaProv", "("+intVO.getLocatariaOSocieta().getSedelegProv()+")");

    htmpl.set("blkSocieta.blkRigaSocieta.indirizzo", ", "+StringUtils.checkNull(intVO.getLocatariaOSocieta().getSedelegIndirizzo()));

  }

  Iterator i_sogg = v_soggetti.iterator();

  if(v_soggetti!=null&&v_soggetti.size()!=0){

    SolmrLogger.debug(this,"Entro in soggetti");

    htmpl.newBlock("blkSoggettiCollegati");

  }

  int counter = 0;

  while(i_sogg.hasNext()){

    intVO = (IntestatariVO)i_sogg.next();

    htmpl.newBlock("blkSoggettiCollegati.blkRigaSoggetti");

    htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.counter", ""+(counter++));

    htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.idSoggetto", StringUtils.checkNull(intVO.getSoggetti().getIdPersonaFisica()));

    htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.provUMA", StringUtils.checkNull(intVO.getSiglaProvinciaUMA()));

    htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.dittaUMA", StringUtils.checkNull(intVO.getDittaUMA()));

    htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.codFiscale", StringUtils.checkNull(intVO.getSoggetti().getCodiceFiscale()));

    htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.cognome", StringUtils.checkNull(intVO.getSoggetti().getCognome()));

    htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.nome", StringUtils.checkNull(intVO.getSoggetti().getNome()));

    htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.comune", StringUtils.checkNull(intVO.getSoggetti().getDescResComune()));

    htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.cap", StringUtils.checkNull(intVO.getSoggetti().getResCAP()));

    if(intVO.getSoggetti().getResProvincia()!=null&&!intVO.getSoggetti().getResProvincia().equals(""))

      htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.siglaProv", "("+intVO.getSoggetti().getResProvincia()+")");

    htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.indirizzo", ", "+StringUtils.checkNull(intVO.getSoggetti().getResIndirizzo()));

  }

  SolmrLogger.debug(this,"- attestazioniNewView.jsp -  FINE PAGINA");

%>

<%= htmpl.text()%>