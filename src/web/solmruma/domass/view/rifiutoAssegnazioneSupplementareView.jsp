<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.util.*" %>
<%
    SolmrLogger.debug(this,"BEGIN rifiutoAssegnazioneSupplementareView");

    Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/domass/layout/rifiutoAssegnazioneSupplementare.htm");
%><%@include file = "/include/menu.inc" %><%

    AssegnazioneCarburanteVO assCarbVO = (AssegnazioneCarburanteVO) session.getAttribute("DomandaAssegnazioneSupplementare");
    

    htmpl.set("idAssCarburante", ""+assCarbVO.getIdAssegnazioneCarburante());
    SolmrLogger.debug(this,"--- idAssCarburante = "+assCarbVO.getIdAssegnazioneCarburante());
    htmpl.set("note", assCarbVO.getNoteIstruttoria());
    SolmrLogger.debug(this," -- noteIstruttoria ="+assCarbVO.getNoteIstruttoria());

    Integer annoDiRiferimento = DateUtils.getCurrentYear();
    SolmrLogger.debug(this,"annoDiRiferimento: "+annoDiRiferimento);
    htmpl.set("annoCorrente", ""+annoDiRiferimento);

    ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");
    SolmrLogger.debug(this,"errors="+errors);
    HtmplUtil.setErrors(htmpl,errors,request);

    it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
    out.print(htmpl.text());

    SolmrLogger.debug(this,"rifiutoAssegnazioneSupplementareView - End");
%>