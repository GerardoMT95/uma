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
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String layout = "/ditta/layout/nuovaSerra.htm";
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layout);
%><%@include file = "/include/menu.inc" %><%  SolmrLogger.info(this, "Found layout: "+layout);


  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  Vector result = null;
  int len;

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  DecimalFormat numericFormat2 = new DecimalFormat(SolmrConstants.FORMATO_NUMERIC_1INT_2DEC);

  SerraVO serraVO=(SerraVO) request.getAttribute("serraVO");

  String lunghezza=null;
  if (serraVO.getLunghezza()!=null){
    lunghezza = numericFormat2.format(serraVO.getLunghezza());
  }
  htmpl.set("lunghezzaStr", lunghezza);

  String larghezza=null;
  if (serraVO.getLarghezza()!=null){
   larghezza = numericFormat2.format(serraVO.getLarghezza());
  }
  htmpl.set("larghezzaStr", larghezza);

  String altezza=null;
  if (serraVO.getAltezza()!=null){
    altezza = numericFormat2.format(serraVO.getAltezza());
  }
  htmpl.set("altezzaStr", altezza);

  HtmplUtil.setValues(htmpl, serraVO);
  HtmplUtil.setValues(htmpl, request);
  htmpl.set("pageFrom",request.getParameter("pageFrom"));

  if ( request.getParameter("misure") != null ){
    if ( request.getParameter("misure").equalsIgnoreCase("dimensioni") ){
      htmpl.set("checkedDimesioni", "checked");
    }else{
      htmpl.set("checkedMisure", "checked");
      htmpl.set("disabledLunghezzaStr", "disabled");
      htmpl.set("disabledLarghezzaStr", "disabled");
      htmpl.set("disabledAltezzaStr", "disabled");
    }
  }
  else{
    //Primo caricamento della pagina
    htmpl.set("checkedDimesioni", "checked");
  }

  HtmplUtil.setErrors(htmpl, errors, request);

  //this.errErrorValExc(htmpl, request, exception);
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

  out.print(htmpl.text());

%>
