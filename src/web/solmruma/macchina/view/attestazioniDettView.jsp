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

  SolmrLogger.debug(this,"- attestazioniDettView.jsp -  INIZIO PAGINA");

  java.io.InputStream layout = application.getResourceAsStream("/macchina/layout/dettaglioMacchinaDettaglioComproprietari.htm");

  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
  Vector v_attestazioni = (Vector)session.getAttribute("v_attestazioni");

  Vector v_proprietari = (Vector)session.getAttribute("v_proprietari");

  MacchinaVO macchinaVO = (MacchinaVO)session.getAttribute("macchinaVO");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  // Dati identificativi del veicolo

  it.csi.solmr.presentation.security.AutorizzazioneMacchine.writeDatiMacchina(htmpl, macchinaVO);

  // Dati attestazioni

  AttestatoProprietaVO attestatoVO = null;

  String idAttestazione = request.getParameter("radioAttestazione");

  Iterator i_att = v_attestazioni.iterator();

  int i = 0;

  while(i_att.hasNext()){

    attestatoVO = (AttestatoProprietaVO)i_att.next();

    SolmrLogger.debug(this,"Confronto id: "+idAttestazione+" - "+attestatoVO.getIdAttestatoProprieta());

    if(idAttestazione!=null&&idAttestazione.equals(attestatoVO.getIdAttestatoProprieta())){

      htmpl.set("prov", attestatoVO.getSiglaProv());

      htmpl.set("anno", attestatoVO.getAnno());

      htmpl.set("numero", attestatoVO.getNumeroModello72());

      // riga commentata da Monica il 02/01/2004

      //htmpl.set("data", attestatoVO.getDataAttestazione()+attestatoVO.getUltimoAggiornamento());

      // riga in sostituzione di quella sopra 02/01/2004

      htmpl.set("data", StringUtils.checkNull(attestatoVO.getDataAttestazione()));

      //riga aggiunta da Monica il 02/01/2004

      htmpl.set("ultimaModifica", StringUtils.checkNull(attestatoVO.getUltimoAggiornamento()));

    }

    else

      SolmrLogger.debug(this,"Id Attestazione proprieta == null || != attestatoVO.getIdAttestatoProprieta()");

  }

  // Dati legati al proprietario

  ProprietarioVO propVO = null;

  Iterator i_prop = v_proprietari.iterator();

  int sogg = 0;

  int loc = 0;

  int soc = 0;

  while(i_prop.hasNext()){

    propVO = (ProprietarioVO)i_prop.next();

    SolmrLogger.debug(this,"VALORE DI GET TIPO PROPRIETARIO... "+propVO.getTipoProprietario());

    // Ditta Locataria

    SolmrLogger.debug(this,"Valore di propVO.getTipoProprietario() "+propVO.getTipoProprietario());

    if (propVO.getTipoProprietario()!=null&&propVO.getTipoProprietario().equals("L")){

      if(loc==0){

        htmpl.newBlock("blkDittaLocataria");

        loc++;

      }

      htmpl.newBlock("blkDittaLocataria.blkRigaDitta");

      htmpl.set("blkDittaLocataria.blkRigaDitta.partitaIVA", StringUtils.checkNull(propVO.getDatiAzienda().getPartitaIVA()));

      SolmrLogger.debug(this,"Valore di propVO.getDatiAzienda().getPartitaIVA() "+propVO.getDatiAzienda().getPartitaIVA());

      htmpl.set("blkDittaLocataria.blkRigaDitta.denominazione", StringUtils.checkNull(propVO.getDatiAzienda().getDenominazione()));

      htmpl.set("blkDittaLocataria.blkRigaDitta.comune", StringUtils.checkNull(propVO.getDatiAzienda().getSedelegComune()));

      htmpl.set("blkDittaLocataria.blkRigaDitta.cap", StringUtils.checkNull(propVO.getDatiAzienda().getSedelegCAP()));

      if(propVO.getDatiAzienda().getSedelegProv()!=null&&!propVO.getDatiAzienda().getSedelegProv().equals(""))

        htmpl.set("blkDittaLocataria.blkRigaDitta.siglaProv", "("+propVO.getDatiAzienda().getSedelegProv()+")");

      htmpl.set("blkDittaLocataria.blkRigaDitta.indirizzo", StringUtils.checkNull(propVO.getDatiAzienda().getSedelegIndirizzo()));

    }

    // Società Utilizzatrici

    else if(propVO.getTipoProprietario()!=null&&propVO.getTipoProprietario().equals("A")){

      if(soc==0){

        htmpl.newBlock("blkSocietaUtilizzatrice");

        soc++;

      }

      htmpl.newBlock("blkSocietaUtilizzatrice.blkRigaSocieta");

      htmpl.set("blkSocietaUtilizzatrice.blkRigaSocieta.provUMA", StringUtils.checkNull(propVO.getSiglaProvincia()));

      htmpl.set("blkSocietaUtilizzatrice.blkRigaSocieta.dittaUMA", StringUtils.checkNull(propVO.getDittaUma()));

      htmpl.set("blkSocietaUtilizzatrice.blkRigaSocieta.CUAA", StringUtils.checkNull(propVO.getDatiAzienda().getCUAA()));

      htmpl.set("blkSocietaUtilizzatrice.blkRigaSocieta.denominazione", StringUtils.checkNull(propVO.getDatiAzienda().getDenominazione()));

      htmpl.set("blkSocietaUtilizzatrice.blkRigaSocieta.comune", StringUtils.checkNull(propVO.getDatiAzienda().getSedelegComune()));

      htmpl.set("blkSocietaUtilizzatrice.blkRigaSocieta.cap", StringUtils.checkNull(propVO.getDatiAzienda().getSedelegCAP()));

      if(propVO.getDatiAzienda().getSedelegProv()!=null&&!propVO.getDatiAzienda().getSedelegProv().equals(""))

         htmpl.set("blkSocietaUtilizzatrice.blkRigaSocieta.siglaProv", "("+propVO.getDatiAzienda().getSedelegProv()+")");

      htmpl.set("blkSocietaUtilizzatrice.blkRigaSocieta.indirizzo", StringUtils.checkNull(propVO.getDatiAzienda().getSedelegIndirizzo()));

    }

    // Sogetti Collegati

    else if(propVO.getTipoProprietario()!=null&&propVO.getTipoProprietario().equals("P")){

      if(sogg==0){

        htmpl.newBlock("blkSoggettiCollegati");

        sogg++;

      }

      htmpl.newBlock("blkSoggettiCollegati.blkRigaSoggetti");

      htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.provUMA", StringUtils.checkNull(propVO.getSiglaProvincia()));

      htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.dittaUMA", StringUtils.checkNull(propVO.getDittaUma()));

      SolmrLogger.debug(this,"Valore di propVO.getDittaUma "+propVO.getDittaUma());

      htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.codFiscale", StringUtils.checkNull(propVO.getDatiSoggetto().getCodiceFiscale()));

      htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.cognome", StringUtils.checkNull(propVO.getDatiSoggetto().getCognome()));

      htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.nome", StringUtils.checkNull(propVO.getDatiSoggetto().getNome()));

      htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.comune", StringUtils.checkNull(propVO.getDatiSoggetto().getResComune()));

      htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.cap", StringUtils.checkNull(propVO.getDatiSoggetto().getResCAP()));

      if(propVO.getDatiSoggetto().getResProvincia()!=null&&!propVO.getDatiSoggetto().getResProvincia().equals(""))

        htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.siglaProv", "("+propVO.getDatiSoggetto().getResProvincia()+")");

      htmpl.set("blkSoggettiCollegati.blkRigaSoggetti.indirizzo", StringUtils.checkNull(propVO.getDatiSoggetto().getResIndirizzo()));

    }

  }

  SolmrLogger.debug(this,"- attestazioniDettView.jsp -  FINE PAGINA");

%>

<%= htmpl.text()%>

