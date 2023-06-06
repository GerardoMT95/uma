<%@ page language="java"
         contentType="text/html"
         isErrorPage="true"
%>

<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
    SolmrLogger.debug(this,"\n\n\n - verificaAssegnazioneSupplementareFoglioView - Begin");
    DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
    Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


    String layoutUrl = "/domass/layout/verificaAssegnazioneSupplementareFoglio.htm";
    Htmpl htmpl = HtmplFactory.getInstance(application)
                .getHtmpl(layoutUrl);
%><%@include file = "/include/menu.inc" %><%

    //Da valutare per test - Begin
    String idDomAss;
    if ( request.getParameter("idDomAss")!=null ){
      SolmrLogger.debug(this,"request.getParameter(\"idDomAss\")!=null");
      idDomAss = request.getParameter("idDomAss");
      htmpl.set("idDomAss", ""+idDomAss );
    }else{
      SolmrLogger.debug(this,"request.getParameter(\"idDomAss\")==null");
      idDomAss = ""+(Long) request.getAttribute("idDomAss");
    }
    SolmrLogger.debug(this,"idDomAss: "+idDomAss);

    String idAssCarb;
    if ( request.getParameter("idAssCarb")!=null ){
      SolmrLogger.debug(this,"request.getParameter(\"idAssCarb\")!=null");
      idAssCarb = request.getParameter("idAssCarb");
      htmpl.set("idAssCarb", ""+idAssCarb );
    }else{
      SolmrLogger.debug(this,"request.getParameter(\"idAssCarb\")==null");
      idAssCarb = ""+(Long) request.getAttribute("idAssCarb");
    }
    SolmrLogger.debug(this,"idAssCarb: "+idAssCarb);
    //Da valutare per test - End

    htmpl.set("idDomAss", idDomAss);
    htmpl.set("idAssCarb", idAssCarb);

    Vector numFogliResult = null;
    if( request.getAttribute("numFogliResult")!=null ){
      numFogliResult = (Vector) request.getAttribute("numFogliResult");
      SolmrLogger.debug(this,"numFogliResult.size(): "+numFogliResult.size());
    }

    if (numFogliResult!=null){
      SolmrLogger.debug(this,"if (numFogliResult!=null)");
      int size = numFogliResult.size();
      if (size>0){
        htmpl.newBlock("blk_FoglioRigaIntestazione");
      }
      int cnt=0;
      for(int i=0; i<size; i++){
        SolmrLogger.debug(this, "numFoglioVO : "+ i);
        NumerazioneFoglioVO numFoglioVO = (NumerazioneFoglioVO) numFogliResult.get(i);

        htmpl.newBlock("blk_FoglioRiga");
        htmpl.set("blk_FoglioRiga.idNumerazioneFoglio", ""+ numFoglioVO.getIdNumerazioneFoglio());
        SolmrLogger.debug(this, "numFoglioVO.getIdNumerazioneFoglio(): "+numFoglioVO.getIdNumerazioneFoglio() );
        htmpl.set("blk_FoglioRiga.Denominazione", ""+ numFoglioVO.getDenominazione());
        SolmrLogger.debug(this, "numFoglioVO.getDenominazione(): "+numFoglioVO.getDenominazione() );
        htmpl.set("blk_FoglioRiga.Foglio", ""+ numFoglioVO.getNumeroFoglio());
        SolmrLogger.debug(this, "numFoglioVO.getNumeroFoglio(): "+numFoglioVO.getNumeroFoglio() );
        htmpl.set("blk_FoglioRiga.Riga", ""+ numFoglioVO.getNumeroRiga());
        SolmrLogger.debug(this, "numFoglioVO.getNumeroRiga(): "+numFoglioVO.getNumeroRiga() );
        cnt=i+1;
        htmpl.set("blk_FoglioRiga.numFoglio", "numFoglio"+cnt);
        SolmrLogger.debug(this, "numFoglio: "+"numFoglio"+cnt );
        htmpl.set("blk_FoglioRiga.denominazione", "denominazione"+cnt);
        SolmrLogger.debug(this, "denominazione: "+"denominazione"+cnt );

      }
    }
    else{
      SolmrLogger.debug(this,"if (numFogliResult==null)");
    }

    Integer annoDiRiferimento = DateUtils.getCurrentYear();
    htmpl.set("annoDiRiferimento", ""+annoDiRiferimento);

    it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

    ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");
    SolmrLogger.debug(this,"errors="+errors);
    HtmplUtil.setErrors(htmpl,errors,request);
    HtmplUtil.setValues(htmpl,request);

    out.print(htmpl.text());

    SolmrLogger.debug(this,"verificaAssegnazioneSupplementareFoglioView - End");
%>