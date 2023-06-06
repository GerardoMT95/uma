  <%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>

<%@ page import="it.csi.solmr.business.uma.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>





<%

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/ditta/layout/cessaDittaUmaSalvataSenzaVerifica.htm");
 // Per problemi dovuti ai forward delle possibili pagine precedenti
 request.setAttribute("__autorizzazione",it.csi.solmr.util.IrideFileParser.elencoSecurity.get("VISUALIZZA_DATI_DITTA"));

%><%@include file = "/include/menu.inc" %><%


  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  it.csi.solmr.client.uma.UmaFacadeClient umaFacadeClient = new it.csi.solmr.client.uma.UmaFacadeClient();



  HtmplUtil.setValues(htmpl, request);

  HtmplUtil.setErrors(htmpl, errors, request);



  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  ValidationException valEx = null;

  String denominazione = "";

  String dittaUMA = "";

  String cuaa = "";

  //Cessazione ditta Uma - Borgogno 21/10/2004 - Begin
  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
  dittaVO = umaFacadeClient.getDittaUMAAzienda(dittaVO);
  session.setAttribute("dittaUMAAziendaVO", dittaVO);
  //Cessazione ditta Uma - Borgogno 21/10/2004 - End

  Long idDittaUma = null;

  try {

    idDittaUma = new Long(""+request.getAttribute("idDittaUMA"));

  } catch (Exception exc) {

    SolmrLogger.debug(this,"Qui dentro");

  }

  SolmrLogger.debug(this,"----------------idDittaUma dalla View 3!!!!!! "+request.getAttribute("idDittaUMA"));

  try{

  denominazione = dittaVO.getDenominazione();

  } catch (Exception exc) {

    SolmrLogger.debug(this,"Qui dentro 5");

  }

  try{

    cuaa = dittaVO.getCuaa();

  } catch (Exception exc) {

  SolmrLogger.debug(this,"Qui dentro 7");

  }

  try{

    dittaUMA = dittaVO.getDittaUMAstr();

  } catch (Exception exc) {

  SolmrLogger.debug(this,"Qui dentro 8");

  }



  String provCompetenza ="";

  /*if(dittaVO.getProvCompetenza()!=null && !dittaVO.getProvCompetenza().equals(""))

    provCompetenza = umaFacadeClient.getProvinciaByIstat(dittaVO.getProvCompetenza());*/

  if(dittaVO.getProvUMA()!=null && !dittaVO.getProvUMA().equals(""))

      provCompetenza = umaFacadeClient.getProvinciaByIstat(dittaVO.getProvUMA());


  //Cessazione ditta Uma - Borgogno 21/10/2004 - Begin
  //String dataCessazioneAttivita = DateUtils.getCurrentDateString();
  String dataCessazioneAttivita = dittaVO.getDataCessazioneUMA();
  //Cessazione ditta Uma - Borgogno 21/10/2004 - End


  String annoRif = DateUtils.getCurrentYear().toString();

  SolmrLogger.debug(this,"annoRif: "+annoRif);



  htmpl.set("denominazione",""+denominazione);

  htmpl.set("CUAA", ""+cuaa);

  htmpl.set("dittaUMA", dittaUMA);

  htmpl.set("umaTipoDitta",dittaVO.getTipiDitta());

  htmpl.set("provinciaCompetenza",provCompetenza);



  htmpl.set("anno",""+annoRif);

  htmpl.set("idDittaUMA", ""+idDittaUma);

  htmpl.set("dataCessazioneAttivita", dataCessazioneAttivita);

  if(session.getAttribute("numRiga")!=null){

    htmpl.newBlock("blockNumeroFoglioRiga");

    SolmrLogger.debug(this,"cessaDittaUmaSalvataSenzaVerificaView, numero riga: "+session.getAttribute("numRiga"));

    SolmrLogger.debug(this,"cessaDittaUmaSalvataSenzaVerificaView, numero foglio: "+session.getAttribute("numFoglio"));

    int numeroRiga = new Integer(""+session.getAttribute("numRiga")).intValue();

    if(numeroRiga == 50)

      htmpl.set("blockNumeroFoglioRiga.numRiga", ""+UmaErrors.get("MSGFOGLIORIGACOMPLETATO"));

    else

      htmpl.set("blockNumeroFoglioRiga.numRiga", ""+session.getAttribute("numRiga"));

    htmpl.set("blockNumeroFoglioRiga.numFoglio", ""+session.getAttribute("numFoglio"));

  }



 it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
%>

<%= htmpl.text()%>