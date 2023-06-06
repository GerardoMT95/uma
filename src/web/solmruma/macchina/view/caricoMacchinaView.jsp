<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>



<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%



  UmaFacadeClient umaClient = new UmaFacadeClient();

  AnagFacadeClient anagClient = new AnagFacadeClient();



  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("macchina/layout/caricoMacchina.htm");
%><%@include file = "/include/menu.inc" %><%

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  MacchinaVO macchinaVO = (MacchinaVO) session.getAttribute("dittaMacchinaVO");



  if(macchinaVO!=null){
    it.csi.solmr.presentation.security.AutorizzazioneMacchine.writeDatiMacchina(htmpl, macchinaVO);
  }


  //try{

  Collection collProvUma = (Collection)anagClient.getProvinceByRegione(SolmrConstants.ID_REGIONE);

  //}

  /*catch(SolmrException sex){

    sex.printStackTrace();

  }*/

  if(collProvUma!=null&&collProvUma.size()>0){

    Iterator iterProvincia = collProvUma.iterator();

    while(iterProvincia.hasNext()){

      ProvinciaVO provinciaVO = (ProvinciaVO)iterProvincia.next();

      htmpl.newBlock("comboProvUma");

      htmpl.set("comboProvUma.idProvUma",""+provinciaVO.getIstatProvincia());

      htmpl.set("comboProvUma.siglaProvUma",provinciaVO.getSiglaProvincia());

      if(request.getParameter("provUma")!=null &&

         request.getParameter("provUma").equals(provinciaVO.getIstatProvincia()))

        htmpl.set("comboProvUma.idProvUmaSel","selected");

    }



  }

  htmpl.set("dittaUma",request.getParameter("dittaUma"));

  if(request.getParameter("dataCarico")!=null && !request.getParameter("dataCarico").equals(""))

    htmpl.set("dataCarico",request.getParameter("dataCarico"));

  else

    htmpl.set("dataCarico", DateUtils.getCurrentDateString());

  printCombo(htmpl,umaClient.getTipiFormaPossesso(),"idFormaPossesso","descrizione",request.getParameter("idFormaPossesso"),"blkTipoFormaPossesso");

  htmpl.set("dataScadenzaLeasing",request.getParameter("dataScadenzaLeasing"));

  if(request.getParameter("idSocietaLeasing")!= null && !request.getParameter("idSocietaLeasing").equals("")){

    AnagAziendaVO aaVO = (AnagAziendaVO)request.getAttribute("dittaLeasing");

    if(aaVO!=null){

      htmpl.set("idAzienda", aaVO.getIdAzienda().toString());

      htmpl.set("partitaIVA",StringUtils.checkNull(aaVO.getPartitaIVA()));

      htmpl.set("ragioneSociale",StringUtils.checkNull(aaVO.getDenominazione()));

      htmpl.set("denominazione",StringUtils.checkNull(aaVO.getDenominazione()));

      htmpl.set("sedelegIndirizzo",StringUtils.checkNull(aaVO.getSedelegIndirizzo()));

      htmpl.set("descComune",StringUtils.checkNull(aaVO.getDescComune()));

      htmpl.set("rappresentanteLegale",StringUtils.checkNull(aaVO.getRappresentanteLegale()));

    }

  }



  ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");

  SolmrLogger.debug(this,"errors="+errors);

  HtmplUtil.setErrors(htmpl,errors,request);



  out.print(htmpl.text());

%>

<%!

  private void printCombo(Htmpl htmpl,Vector comboData,String nameCode,String nameDesc,String selectedCode,String blockName)

  {

    int size=comboData==null?0:comboData.size();

    SolmrLogger.debug(this,"size="+size);

    String blkNameCode=blockName+"."+nameCode;

    String blkNameDesc=blockName+"."+nameDesc;

    SolmrLogger.debug(this,"blkNameCode="+blkNameCode);

    SolmrLogger.debug(this,"blkNameDesc="+blkNameDesc);

    htmpl.newBlock(blockName);

    htmpl.set(blkNameCode,null);

    htmpl.set(blkNameDesc,"-seleziona-");

    SolmrLogger.debug(this,"selectedCode="+selectedCode);

    for(int i=0;i<size;i++)

    {

      CodeDescr cd=(CodeDescr)comboData.get(i);

      String code=cd.getCode().toString();

      htmpl.newBlock(blockName);

      if (code!=null && code.equals(selectedCode))

      {

        htmpl.set(blockName+".selected","selected");

      }

      htmpl.set(blkNameCode,code);

      htmpl.set(blkNameDesc,cd.getDescription());

    }

  }

%>