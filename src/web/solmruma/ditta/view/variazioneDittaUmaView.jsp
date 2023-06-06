<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@page import="java.util.Date"%>
<%@page import="it.csi.solmr.etc.SolmrConstants"%>
<%@page import="java.util.GregorianCalendar"%>
<%@page import="java.util.List"%>
<%
  String layout = "/ditta/layout/variazioneDittaUma.htm";
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layout);
%><%@include file = "/include/menu.inc" %><%  SolmrLogger.info(this, "Found layout: "+layout);

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  DittaUMAVO dittaUmaVO = (DittaUMAVO)request.getAttribute("dittaUmaVO");
  SolmrLogger.debug(this,"dittaUmaVO="+dittaUmaVO);
  DittaUMAAziendaVO dumaa = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
  SolmrLogger.debug(this,"[variazioneDittaUmaView::service] DittaUmaVO.getIdDitta "+dittaUmaVO.getIdDitta());
  SolmrLogger.debug(this,"[variazioneDittaUmaView::service] DittaUmaVO.getNoteDitta "+dittaUmaVO.getNoteDitta());
  SolmrLogger.debug(this,"[variazioneDittaUmaView::service] DittaUmaVO.getIndirizzoConsegna "+dittaUmaVO.getIndirizzoConsegna());
  SolmrLogger.debug(this,"[variazioneDittaUmaView::service] DittaUmaVO.getComune "+dittaUmaVO.getComune());
  SolmrLogger.debug(this,"[variazioneDittaUmaView::service] DittaUmaVO.getProvincia "+dittaUmaVO.getProvincia());
  SolmrLogger.debug(this,"[variazioneDittaUmaView::service] DittaUmaVO.getIdDatiDitta "+dittaUmaVO.getIdDatiDitta());

  htmpl.set("dataIscrizione", DateUtils.formatDate(dittaUmaVO.getDataIscrizione()));
  htmpl.set("dataIscrizioneStr", DateUtils.formatDate(dittaUmaVO.getDataIscrizione()));
  htmpl.set("istatComune", dittaUmaVO.getExtComunePrincipaleAttivita());
  HtmplUtil.setValues(htmpl, dittaUmaVO, (String)session.getAttribute("pathToFollow"));
  HtmplUtil.setValues(htmpl, dumaa, (String)session.getAttribute("pathToFollow"));

  HtmplUtil.setErrors(htmpl, errors, request);

  //this.errErrorValExc(htmpl, request, exception);
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
  Date dtmnDate=(Date)request.getAttribute("DTMN");
  Date dtmxDate=(Date)request.getAttribute("DTMX");
  Date today=DateUtils.parseDate(DateUtils.formatDate(new Date())); // Data senza HH:MI:SS
  Date dataRicezDocumAssegnaz=dittaUmaVO.getDataRicezDocumAssegnaz();
  if (dataRicezDocumAssegnaz!=null)
  {
    int year=DateUtils.extractYearFromDate(dataRicezDocumAssegnaz);
    int yearToday=DateUtils.extractYearFromDate(today);
    if (year==yearToday)
    {
      htmpl.set("flagChecked",SolmrConstants.HTML_CHECKED,null);
    }
  }
  
  if (today.before(dtmnDate) || today.after(dtmxDate))
  {
    // Se la data corrente è compresa tra dtmn e dtmx ==> il flag Ricezione Documenti Autorizzazione non è 
    // modificabile
    htmpl.set("flagDisabled",SolmrConstants.HTML_DISABLED,null);
  }
  
  
  //-- Allegati
  List<FileVO> vElencoFileAllegati = (List<FileVO>)session.getAttribute("vElencoFileAllegati");
  if(vElencoFileAllegati != null && vElencoFileAllegati.size()>0){
  SolmrLogger.debug(this, "--- ci sono degli allegati da visualizzare");
  for(int i=0;i<vElencoFileAllegati.size();i++){
	  htmpl.newBlock("blkFilePresenti");
	  FileVO fileVO = vElencoFileAllegati.get(i);
	  htmpl.set("blkFilePresenti.nomeFile",fileVO.getNomeFisico());
	  htmpl.set("blkFilePresenti.idAllegato", ""+fileVO.getIdAllegato());
  }	  
}	
  
  
  out.print(htmpl.text());

%>
