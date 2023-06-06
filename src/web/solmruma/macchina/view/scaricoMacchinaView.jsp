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

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("macchina/layout/scaricoMacchina.htm");
%><%@include file = "/include/menu.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


  MacchinaVO macchinaVO = (MacchinaVO) session.getAttribute("scaricoMacchinaVO");

  it.csi.solmr.presentation.security.AutorizzazioneMacchine.writeDatiMacchina(htmpl, macchinaVO);


  if(macchinaVO.getUtilizzoVO()!=null){

    if(macchinaVO.getUtilizzoVO().getDataCaricoDate()!=null)

      htmpl.set("dataCarico",DateUtils.formatDate(macchinaVO.getUtilizzoVO().getDataCaricoDate()));

    if(macchinaVO.getUtilizzoVO().getIdScarico()!=null){

      printCombo(htmpl,umaClient.getTipiScarico(),"idMotivoScarico","descrizione",macchinaVO.getUtilizzoVO().getIdScarico(),"blkMotivoScarico");

     }

     else

       printCombo(htmpl,umaClient.getTipiScarico(),"idMotivoScarico","descrizione",request.getParameter("idMotivoScarico"),"blkMotivoScarico");

     if(macchinaVO.getUtilizzoVO().getDataScaricoDate()!=null)

       htmpl.set("dataScarico",DateUtils.formatDate(macchinaVO.getUtilizzoVO().getDataScaricoDate()));

     else if(request.getParameter("dataScarico") != null)

       htmpl.set("dataScarico", request.getParameter("dataScarico"));

     else

       htmpl.set("dataScarico", DateUtils.getCurrentDateString());

  }



  if(macchinaVO.getUtilizzoVO()!=null && macchinaVO.getUtilizzoVO().getLastPossessoVO()!=null){

     if(macchinaVO.getUtilizzoVO().getLastPossessoVO().getDescFormaPossesso()!=null){

       htmpl.set("descFormaPossesso", macchinaVO.getUtilizzoVO().getLastPossessoVO().getDescFormaPossesso());

     }

     // 'Data scadenza' è visibile solo se 'FormaPossesso' =  leasing, utilizzo/noleggio, comodato d'uso, prestito d'uso
     if(macchinaVO.getUtilizzoVO().getLastPossessoVO().getIdFormaPossessoLong() != null){
       long idFormaPossesso = macchinaVO.getUtilizzoVO().getLastPossessoVO().getIdFormaPossessoLong().longValue();
       SolmrLogger.debug(this, "-- idFormaPossesso ="+idFormaPossesso); 
       if(idFormaPossesso == new Long(SolmrConstants.LEASING).longValue() ||
          idFormaPossesso == new Long(SolmrConstants.UTILIZZO_NOLEGGIO).longValue() ||
          idFormaPossesso == new Long(SolmrConstants.COMODATO_DUSO).longValue() ||
          idFormaPossesso == new Long(SolmrConstants.PRESTITO_DUSO).longValue() 
          ){
            htmpl.newBlock("blkLeasing");
            if(macchinaVO.getUtilizzoVO().getLastPossessoVO().getDataScadenzaLeasingDate() != null) 
              htmpl.set("blkLeasing.dataScadenzaLeasing",DateUtils.formatDate(macchinaVO.getUtilizzoVO().getLastPossessoVO().getDataScadenzaLeasingDate()));
          }    
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