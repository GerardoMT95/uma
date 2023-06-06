<%@
  page language="java"
  contentType="text/html"
  isErrorPage="true"
%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%
  SolmrLogger.debug(this,"- attestazioniNewView.jsp -  INIZIO PAGINA");
  java.io.InputStream layout = application.getResourceAsStream("/macchina/layout/NuovaAttestazioneModificaConferma.htm");
  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  HtmplUtil.setErrors(htmpl, errors, request);
  Vector v_modificati = (Vector)request.getAttribute("v_modificati");
  Iterator i = v_modificati.iterator();
  while(i.hasNext()){
    IntestatariVO intVO = (IntestatariVO)i.next();
    String msg = "SONO STATI MODIFICATI I DATI ANAGRAFICI DEL";
    if(intVO.getFlagAnagAzienda()!=null)
      if(intVO.getTipoIntestatario()!=null&&intVO.getTipoIntestatario().equals("L")){
        msg+="L'AZIENDA "+intVO.getLocatariaOSocieta().getDenominazione();
      }
      else
        msg+="L'AZIENDA DELLA DITTA ";
    else if(intVO.getFlagPersonaFisica()!=null)
      msg+=" RAPPRESENTANTE LEGALE/TITOLARE DELLA DITTA ";
    if(intVO.getDittaUMA()!=null&&!intVO.getDittaUMA().equals("")){
      msg+=intVO.getDittaUMA();
      if(intVO.getSiglaProvinciaUMA()!=null&&!intVO.getSiglaProvinciaUMA().equals(""))
        msg+="/"+intVO.getSiglaProvinciaUMA();
    }
    else
      msg+=StringUtils.checkNull(intVO.getSiglaProvinciaUMA());
    htmpl.newBlock("blkMsg");
    htmpl.set("blkMsg.msg", msg);
    //if(intVO.)
  }
  SolmrLogger.debug(this,"- attestazioniNewView.jsp -  FINE PAGINA");
%>
<%= htmpl.text()%>