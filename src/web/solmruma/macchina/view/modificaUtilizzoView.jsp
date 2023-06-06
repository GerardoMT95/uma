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

  it.csi.solmr.client.anag.AnagFacadeClient anagClient = new AnagFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("macchina/layout/modificaUtilizzo.htm");
%><%@include file = "/include/menu.inc" %><%

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  MacchinaVO macchinaVO = (MacchinaVO) session.getAttribute("modificaMacchinaVO");



  if(macchinaVO!=null){

    it.csi.solmr.presentation.security.AutorizzazioneMacchine.writeDatiMacchina(htmpl, macchinaVO);

  }

  SolmrLogger.debug(this,"");

  if(macchinaVO.getUtilizzoVO()!=null && macchinaVO.getUtilizzoVO().getDataCaricoDate()!=null)

      htmpl.set("dataCarico",DateUtils.formatDate(macchinaVO.getUtilizzoVO().getDataCaricoDate()));

  
  // Controllo se ci sono i dati dello scarico
  if(macchinaVO.getUtilizzoVO() != null && macchinaVO.getUtilizzoVO().getDataScaricoDate() != null){
    SolmrLogger.debug(this, "---- la data scarico e' valorizzata");
    htmpl.newBlock("blkDatiScarico");
    
    // Data scarico
    SolmrLogger.debug(this, "-- dataScarico ="+macchinaVO.getUtilizzoVO().getDataScaricoDate());
    htmpl.set("blkDatiScarico.dataScarico", DateUtils.formatDate(macchinaVO.getUtilizzoVO().getDataScaricoDate()));
    
    // Motivo scarico
    String idMotivoScaricoDaSel = request.getParameter("idMotivoScarico");
    if(idMotivoScaricoDaSel == null){
      if(macchinaVO.getUtilizzoVO() != null)
        idMotivoScaricoDaSel = macchinaVO.getUtilizzoVO().getIdScarico(); 
    }
    SolmrLogger.debug(this, "-- idMotivoScaricoDaSel ="+idMotivoScaricoDaSel);
    printCombo(htmpl,umaClient.getTipiScarico(),"idMotivoScarico","descrizione",idMotivoScaricoDaSel,"blkDatiScarico.blkMotivoScarico");  
  }


  if(macchinaVO.getUtilizzoVO()!=null &&

     macchinaVO.getUtilizzoVO().getLastPossessoVO()!=null){

     // 'Forma possesso' 
     if(macchinaVO.getUtilizzoVO().getLastPossessoVO().getIdFormaPossesso()!=null){

       // Se la data scarico NON è valorizzata -> combo abilitata
       if(macchinaVO.getUtilizzoVO().getDataScaricoDate() == null){
         htmpl.newBlock("blkComboFormaPossesso");
         printCombo(htmpl,umaClient.getTipiFormaPossesso(),"idFormaPossesso","descrizione",macchinaVO.getUtilizzoVO().getLastPossessoVO().getIdFormaPossesso(),"blkComboFormaPossesso.blkTipoFormaPossesso");         
       }
       // Se la data scarico è valorizzata -> combo disabilitata
       // Tutti i campi legati al 'Titolo possesso' -> disabilitati
       else{
          htmpl.newBlock("blkComboFormaPossesso");
          printCombo(htmpl,umaClient.getTipiFormaPossesso(),"idFormaPossesso","descrizione",macchinaVO.getUtilizzoVO().getLastPossessoVO().getIdFormaPossesso(),"blkComboFormaPossesso.blkTipoFormaPossesso");
		  htmpl.set("blkComboFormaPossesso.disabled", "disabled"); 
		  
		  htmpl.set("disabled","disabled");        
       }  

     }

     


     if(macchinaVO.getUtilizzoVO().getLastPossessoVO().getDataScadenzaLeasing()!=null){

       htmpl.set("dataScadenzaLeasing",macchinaVO.getUtilizzoVO().getLastPossessoVO().getDataScadenzaLeasing());

     }

     if(macchinaVO.getUtilizzoVO().getLastPossessoVO().getExtIdAzienda()!=null){

       AnagAziendaVO aaVO = (AnagAziendaVO)request.getAttribute("dittaLeasing");

       if(aaVO!=null){

         htmpl.set("idAzienda", aaVO.getIdAzienda().toString());

         htmpl.set("ragioneSociale",StringUtils.checkNull(aaVO.getDenominazione()));

         htmpl.set("partitaIVA",StringUtils.checkNull(aaVO.getPartitaIVA()));

         htmpl.set("denominazione",StringUtils.checkNull(aaVO.getDenominazione()));

         htmpl.set("sedelegIndirizzo",StringUtils.checkNull(aaVO.getSedelegIndirizzo()));

         htmpl.set("descComune",StringUtils.checkNull(aaVO.getDescComune()));

         htmpl.set("rappresentanteLegale",StringUtils.checkNull(aaVO.getRappresentanteLegale()));

       }

     }

  }

  ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");

  SolmrLogger.debug(this,"errors="+errors);

  HtmplUtil.setErrors(htmpl, errors, request);
  // sostituzione di tutti i place older
  HtmplUtil.reparseTemplate(htmpl);		    
  HtmplUtil.setErrors(htmpl, errors, request);	



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