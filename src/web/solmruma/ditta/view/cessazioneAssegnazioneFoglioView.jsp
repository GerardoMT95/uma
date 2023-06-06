<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
  %>

<%@ page import="it.csi.solmr.business.uma.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%



  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/ditta/layout/cessazioneAssegnazioneFoglio.htm");


%><%@include file = "/include/menu.inc" %><%


  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();



  HtmplUtil.setValues(htmpl, request);

  HtmplUtil.setErrors(htmpl, errors, request);

  ValidationException valEx = null;

  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


  String denominazione = "";

  String dittaUMA = "";

  String cuaa = "";

  String idAssCarb = "";



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

  /*if(!dittaVO.getProvCompetenza().equals(""))

    provCompetenza = umaFacadeClient.getProvinciaByIstat(dittaVO.getProvCompetenza());*/

  if(!dittaVO.getProvUMA().equals(""))

    provCompetenza = umaFacadeClient.getProvinciaByIstat(dittaVO.getProvUMA());


  String uma_num = "";



  SolmrLogger.debug(this,"cessazioneAssegnazioneView anno: "+session.getAttribute("anno"));



  String anno = ""+session.getAttribute("anno");



  Vector elencoNumerazioneFoglio = (Vector)request.getAttribute("elencoNumerazioneFoglio");




  SolmrLogger.debug(this,"elencoNumerazioneFoglio.size(): "+elencoNumerazioneFoglio.size());



  int size = elencoNumerazioneFoglio.size();

  if (size>0){

    htmpl.newBlock("blk_FoglioRigaIntestazione");

  }

  int cnt=0;

  for(int i=0; i<size; i++){

    NumerazioneFoglioVO numFoglioVO = (NumerazioneFoglioVO) elencoNumerazioneFoglio.get(i);

    String nomeCognome = ((UtenteIrideVO)umaFacadeClient.getUtenteIride(numFoglioVO.getExtIdUtente())).getDenominazione();



    htmpl.newBlock("blk_FoglioRiga");

    htmpl.set("blk_FoglioRiga.idNumerazioneFoglio", ""+ numFoglioVO.getIdNumerazioneFoglio());

    htmpl.set("blk_FoglioRiga.Denominazione", ""+ nomeCognome);

    htmpl.set("blk_FoglioRiga.Foglio", ""+ numFoglioVO.getNumeroFoglio());

    htmpl.set("blk_FoglioRiga.Riga", ""+ numFoglioVO.getNumeroRiga());

    cnt=i+1;

    htmpl.set("blk_FoglioRiga.numFoglio", "numFoglio"+cnt);

    htmpl.set("blk_FoglioRiga.denominazione", "denominazione"+cnt);

  }



  htmpl.set("anno", anno);
  htmpl.set("extCuaaAziendaDest",request.getParameter("extCuaaAziendaDest"));
  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
%>

<%= htmpl.text()%>