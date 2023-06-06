  <%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>

<%@ page import="it.csi.solmr.business.uma.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/ditta/layout/cessaDittaUmaSenzaVerifica.htm");


%><%@include file = "/include/menu.inc" %><%


  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  it.csi.solmr.client.uma.UmaFacadeClient umaFacadeClient = new it.csi.solmr.client.uma.UmaFacadeClient();



  HtmplUtil.setValues(htmpl, request);

  HtmplUtil.setErrors(htmpl, errors, request);


  ValidationException valEx = null;

  String denominazione = "";

  String dittaUMA = "";

  String cuaa = "";



  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  try {

    denominazione = dittaVO.getDenominazione();

  }

  catch (Exception exc) {

    SolmrLogger.debug(this,"Qui dentro 5");

  }

  try {

    cuaa = dittaVO.getCuaa();

  }

  catch (Exception exc) {

    SolmrLogger.debug(this,"Qui dentro 7");

  }

  try {

    dittaUMA = dittaVO.getDittaUMAstr();

  }

  catch (Exception exc) {

    SolmrLogger.debug(this,"Qui dentro 8");

  }



  Long idDittaUma = null;

  try {

    idDittaUma = new Long(""+request.getAttribute("idDittaUMA"));

  }

  catch (Exception exc) {

    SolmrLogger.debug(this,"Qui dentro");

  }



  String provCompetenza ="";

  /*if(dittaVO.getProvCompetenza()!= null && !dittaVO.getProvCompetenza().equals(""))

    provCompetenza = umaFacadeClient.getProvinciaByIstat(dittaVO.getProvCompetenza());*/

  if(dittaVO.getProvUMA()!= null && !dittaVO.getProvUMA().equals(""))

    provCompetenza = umaFacadeClient.getProvinciaByIstat(dittaVO.getProvUMA());



  String dataCessazioneAttivita = DateUtils.getCurrentDateString();



  String annoRif = DateUtils.getCurrentYear().toString();

  htmpl.set("denominazione",denominazione);

  htmpl.set("CUAA",cuaa);

  htmpl.set("dittaUMA",dittaUMA);

  htmpl.set("umaTipoDitta",dittaVO.getTipiDitta());

  htmpl.set("provinciaCompetenza", provCompetenza);



  htmpl.set("anno",""+annoRif);

  htmpl.set("idDittaUMA", ""+idDittaUma);

  htmpl.set("dataCessazioneAttivita", dataCessazioneAttivita);

  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

%>

<%= htmpl.text()%>