  <%@ page language="java"

      contentType="text/html"

      isErrorPage="true"

  %>



<%@ page import="java.util.*" %>

<%@ page import="it.csi.jsf.htmpl.*" %>

<%@ page import="java.rmi.RemoteException" %>

<%@ page import="java.sql.Timestamp" %>

<%@ page import="it.csi.solmr.client.uma.*" %>

<%@ page import="it.csi.solmr.client.anag.*" %>

<%@ page import="it.csi.solmr.util.*" %>

<%@ page import="it.csi.solmr.dto.anag.*" %>

<%@ page import="it.csi.solmr.dto.uma.*" %>

<%@ page import="it.csi.solmr.etc.*" %>

<%@ page import="it.csi.solmr.dto.*" %>





<%



  SolmrLogger.debug(this,"Sono nella view!!!!!!!");

  UmaFacadeClient umaClient = new UmaFacadeClient();

  AnagFacadeClient anagClient = new AnagFacadeClient();

  SolmrLogger.debug(this,"Istanzio anagClient!!!: "+anagClient);

  java.io.InputStream layout = application.getResourceAsStream("ditta/layout/nuovaDittaUma.htm");

  SolmrLogger.debug(this,"HO creato il layout!!!!");

  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%


  AnagAziendaVO anagAziendaVO = (AnagAziendaVO)session.getAttribute("anagAziendaVO");

  SolmrLogger.debug(this,"Valore di anagAziendaVO: "+anagAziendaVO);

  DittaUMAVO dittaUma = (DittaUMAVO)session.getAttribute("dittaUma");

  session.removeAttribute("dittaUma");

  if(anagAziendaVO != null) {

    htmpl.set("denominazioneAzienda",anagAziendaVO.getDenominazione());

    htmpl.set("cuaaAzienda",anagAziendaVO.getCUAA());

    htmpl.set("idAzienda",String.valueOf(anagAziendaVO.getIdAzienda()));

  }

  Vector province = anagClient.getProvinceByRegione(SolmrConstants.ID_REGIONE);

  Iterator iteraProvince = province.iterator();

  while(iteraProvince.hasNext()) {

    htmpl.newBlock("provinceCompetenza");

    ProvinciaVO provinciaVO = (ProvinciaVO)iteraProvince.next();

    if(dittaUma != null) {

      if(dittaUma.getExtProvinciaUMA().equals(provinciaVO.getIstatProvincia())) {

        htmpl.set("provinceCompetenza.check","selected");

      }

    }

    htmpl.set("provinceCompetenza.idCodice",provinciaVO.getIstatProvincia());

    htmpl.set("provinceCompetenza.descrizione",provinciaVO.getDescrizione());

  }



  Vector elencoTipiConduzione = umaClient.getTipiConduzione();

  Iterator iteraTipiConduzione = elencoTipiConduzione.iterator();

  while(iteraTipiConduzione.hasNext()) {

    htmpl.newBlock("tipiConduzione");

    CodeDescr CodeDescr = (CodeDescr)iteraTipiConduzione.next();

    if(dittaUma != null) {

      if(dittaUma.getIdConduzione().compareTo(new Long(CodeDescr.getCode().longValue())) == 0) {

        htmpl.set("tipiConduzione.check","selected");

      }

    }

    htmpl.set("tipiConduzione.idCodice",String.valueOf(CodeDescr.getCode()));

    htmpl.set("tipiConduzione.descrizione",CodeDescr.getDescription());

  }

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");



  HtmplUtil.setValues(htmpl, request);

  HtmplUtil.setErrors(htmpl, errors, request);





%>

<%= htmpl.text()%>





