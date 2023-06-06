<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%
  String LAYOUT = "/domass/layout/verificaAssegnazioneAccontoValidata.htm";

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
  // A causa del fatto che questa pagina ha il menu della assegnazione base
  // ma è inserita nel CU del dettaglio azienda (che è di pertinenza di un
  // altro menu) viene cambiata al volo la classe Autorizzazione per
  // permettere l'utilizzo del gestore di menu corretto.
  it.csi.solmr.presentation.security.Autorizzazione autAssegnazioneBase = (it.csi.solmr.presentation.security.Autorizzazione) it.csi.solmr.util.IrideFileParser.elencoSecurity
      .get("ASSEGNAZIONE_ACCONTO");
  request.setAttribute("__autorizzazione", autAssegnazioneBase);
%><%@include file="/include/menu.inc"%>
<%
  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");      
  Long idDittaUma = dittaUMAAziendaVO.getIdDittaUMA();
  DomandaAssegnazione accontoVO = (DomandaAssegnazione) request.getAttribute("accontoVO");                  
  FogliRigaVO fogliRigaVO = (FogliRigaVO) request.getAttribute("fogliRigaVO");

  Calendar cal = new GregorianCalendar();
  long anno = cal.get(Calendar.YEAR);

  //x EmissioneBuono.htm
  htmpl.bset("idDomAss", accontoVO.getIdDomandaAssegnazione().toString());
  //htmpl.set("idDomAss", ""+idDomAss);
  htmpl.set("anno", String.valueOf(anno));
  htmpl.set("idDittaUma", StringUtils.checkNull(idDittaUma));

  Integer annoDiRiferimento = DateUtils.getCurrentYear();
  htmpl.set("annoDiRiferimento", StringUtils.checkNull(annoDiRiferimento));

  Date dataValidazione = fogliRigaVO.getDataValidazione();
  if (dataValidazione != null)
  {
    htmpl.set("dataValidazione", formatDate(dataValidazione));
  }

  Long numeroFoglio;
  if (fogliRigaVO.getNumeroFoglio() != null)
  {
    numeroFoglio = fogliRigaVO.getNumeroFoglio();
  }
  else
  {
    numeroFoglio = new Long("-1");
  }
  htmpl.set("numeroFoglio", "" + numeroFoglio);

  Long numeroRiga;
  if (fogliRigaVO.getNumeroRiga() != null)
  {
    //Mantiene i dati per la pagina verificaAssegnazioneAccontoValidata.htm
    //   quando ritorno con Annulla da annulloAssegnazione.htm
    numeroRiga = fogliRigaVO.getNumeroRiga();
  }
  else
  {
    numeroRiga = new Long("-1");
  }
  htmpl.set("numeroRiga", StringUtils.checkNull(numeroRiga));

  String messFoglioCompletato = null;
  if (fogliRigaVO.getMessNumFoglio() != null)
  {
    messFoglioCompletato = fogliRigaVO.getMessNumFoglio();
  }

  if ((numeroFoglio.longValue() != -1) && (numeroRiga.longValue() != -1))
  {
    htmpl.newBlock("blk_foglioRigaAss");
    htmpl.set("blk_foglioRigaAss.numeroFoglio", StringUtils
        .checkNull(numeroFoglio));
    htmpl.set("blk_foglioRigaAss.numeroRiga", StringUtils
        .checkNull(numeroRiga));

    htmpl.set("blk_foglioRigaAss.messFoglioCompletato",
        messFoglioCompletato);
  }
  
  // Nick 14-01-2009 - Nuova gestione emissione buoni.
  String strCtrlBuonoInserito = (String)request.getAttribute("ctrl_buono_inserito");
  
  if (strCtrlBuonoInserito.equals("TRUE")) {
  	  htmpl.set("messBuonoEmesso","Sono stati emessi correttamente i buoni di carburante associati alla domanda di assegnazione. Si ricorda di effettuare la stampa del modello 26.");
  }
  else {
  	  htmpl.set("messBuonoEmesso","Non sono stati emessi buoni prelievo, il quantitativo di carburante assegnato risulta nullo.");
  }
  
  htmpl.set("dataRiferimento", formatDate(accontoVO.getDataRiferimento()));

  ValidationErrors errors = (ValidationErrors) request.getAttribute("errors");
  HtmplUtil.setErrors(htmpl, errors, request);

  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
  out.print(htmpl.text());
%>
<%!private String formatDate(Date aDate)
  {
    if (aDate == null)
    {
      return null;
    }
    return DateUtils.formatDate(aDate);
  }%>