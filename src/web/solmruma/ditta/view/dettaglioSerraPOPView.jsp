<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="it.csi.solmr.business.uma.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.DecimalFormat"%>

<%
  SolmrLogger.debug(this, "BEGIN dettaglioSerraPOPView");

  UmaFacadeClient umaClient = new UmaFacadeClient();

  DecimalFormat numericFormat2 = new DecimalFormat(SolmrConstants.FORMATO_NUMERIC_1INT_2DEC);

  Long idSerra = new Long(request.getParameter("idSerra"));
  SerraVO serra = (SerraVO) umaClient.findSerraByPrimaryKey(idSerra);
  UtenteIrideVO utenteIrideVO=null;
  try
  {
    if (serra!=null)
    {
      utenteIrideVO=umaClient.getUtenteIride(serra.getExtIdUtenteAggiornamento());
    }
  }
  catch(Exception ex)
  {
    utenteIrideVO = new UtenteIrideVO();
  }

  String layout = new String("/ditta/layout/dettaglioSerraPOP.htm");
  Htmpl htmpl = HtmplFactory.getInstance(application)
              .getHtmpl(layout);
  
  SolmrLogger.debug(this, "END dettaglioSerraPOPView");
%><%@include file = "/include/menu.inc" %><%  SolmrLogger.info(this, "Found layout: "+layout);
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  if (serra!=null)
  {
    serra.setDataAggiornamentoStr(this.dateStr(serra.getDataAggiornamento()));
    serra.setDataCaricoStr(this.dateStr(serra.getDataCarico()));
    serra.setDataFineValiditaStr(this.dateStr(serra.getDataFineValidita()));
    serra.setDataInizioValiditaStr(this.dateStr(serra.getDataInizioValidita()));
    serra.setDataScaricoStr(this.dateStr(serra.getDataScarico()));
  }

  String lunghezza=null;
  if (serra.getLunghezza()!=null){
    lunghezza = numericFormat2.format(serra.getLunghezza());
  }
  htmpl.set("lunghezza", lunghezza);

  String larghezza=null;
  if (serra.getLarghezza()!=null){
    larghezza = numericFormat2.format(serra.getLarghezza());
  }
  htmpl.set("larghezza", larghezza);

  String altezza=null;
  if (serra.getAltezza()!=null){
    altezza = numericFormat2.format(serra.getAltezza());
  }
  htmpl.set("altezza", altezza);

  HtmplUtil.setValues(htmpl, serra);
  HtmplUtil.setValues(htmpl, utenteIrideVO);
  //Vector elencoSerre = (Vector)request.getAttribute("elencoSerre");

/*
  out.print("dataScarico: "+ serra.getDataScarico());
  out.print("dataFineValidita: "+ serra.getDataFineValidita());
*/

  this.errErrorValExc(htmpl, request, exception);

%>
<%= htmpl.text()%>
<%!
  private String dateStr(Date date)
  {
    if (date!=null)
    {
      return DateUtils.formatDate(date);
    }
    else
    {
      return "";
    }
  }
%>
<%!
  private void errErrorValExc(Htmpl htmpl, HttpServletRequest request, Throwable exc)
  {
    SolmrLogger.debug(this,"\n\n\n\n *********************************** 2");
    SolmrLogger.debug(this,"errErrorValExc()");

    if (exc instanceof it.csi.solmr.exception.ValidationException){

      ValidationErrors valErrs = new ValidationErrors();
      valErrs.add("error", new ValidationError(exc.getMessage()) );

      HtmplUtil.setErrors(htmpl, valErrs, request);
    }
  }
%>