<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.util.*" %>
<%
    SolmrLogger.debug(this,"rifiutoAssegnazioneView - Begin");

    Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/domass/layout/rifiutoAssegnazione.htm");
%><%@include file = "/include/menu.inc" %><%

    DomandaAssegnazione da=null;
    if ( request.getAttribute("DomandaAssegnazione")!=null ){
      da = (DomandaAssegnazione) request.getAttribute("DomandaAssegnazione");
    }

    htmpl.set("idDomAss", ""+da.getIdDomandaAssegnazione() );
    SolmrLogger.debug(this,"idDomAss: "+da.getIdDomandaAssegnazione());
    htmpl.set("note", da.getNote() );
    SolmrLogger.debug(this,"da.getNote(): "+da.getNote());

    Integer annoDiRiferimento = DateUtils.getCurrentYear();
    SolmrLogger.debug(this,"annoDiRiferimento: "+annoDiRiferimento);
    htmpl.set("annoDiRiferimento", ""+annoDiRiferimento);

    ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");
    SolmrLogger.debug(this,"errors="+errors);
    HtmplUtil.setErrors(htmpl,errors,request);

    it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
    out.print(htmpl.text());

    SolmrLogger.debug(this,"rifiutoAssegnazioneView - End");
%>