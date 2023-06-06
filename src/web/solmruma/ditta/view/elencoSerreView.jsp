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
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
  UmaFacadeClient umaClient = new UmaFacadeClient();
  String storicizzazione=request.getParameter("storico");
  Vector elencoSerre=null;
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/elencoSerre.htm");
%><%@include file = "/include/menu.inc" %><%
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


  DecimalFormat numericFormat4 = new DecimalFormat(SolmrConstants.FORMATO_NUMERIC_1INT_4DEC);

  //this.errErrorValExc(htmpl, request, exception);
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

  elencoSerre=(Vector)request.getAttribute("elencoSerre");
  if (elencoSerre==null)
  {
    elencoSerre=new Vector(); // Evito nullpointerexception
  }

  String startRowStr=request.getParameter("startRow");
  int startRow=0;
  int rows=elencoSerre.size();

  if (startRowStr!=null)
  {
    try
    {
      startRow=new Integer(startRowStr).intValue();
    }
    catch(Exception e) // Errore, suppongo startrow==0 e quindi non faccio nulla!!!
    {
    }
  }
  int prevPage=startRow-SolmrConstants.NUM_MAX_ROWS_PAG;
  int nextPage=startRow+SolmrConstants.NUM_MAX_ROWS_PAG;
  if (nextPage>=rows)
  {
    nextPage=startRow;
  }
  if (prevPage<=0)
  {
    prevPage=0;
  }
  int maxPage=rows/SolmrConstants.NUM_MAX_ROWS_PAG+(rows%SolmrConstants.NUM_MAX_ROWS_PAG>0?1:0);
  if (elencoSerre.size()==0)
  {
    maxPage=1;
  }
  int currentPage=startRow/SolmrConstants.NUM_MAX_ROWS_PAG+1+(startRow%SolmrConstants.NUM_MAX_ROWS_PAG>0?1:0);

  int size=elencoSerre.size();
  SolmrLogger.debug(this,"currentPage="+currentPage);
  SolmrLogger.debug(this,"maxPage="+maxPage);
  if (currentPage!=1)
  {
    htmpl.set("prev.prevPage",""+prevPage);
  }
  if (currentPage!=maxPage)
  {
    htmpl.set("next.nextPage",""+nextPage);
  }
  htmpl.set("numSerre",""+elencoSerre.size());
  htmpl.set("maxPage",""+maxPage);
  htmpl.set("currentPage",""+currentPage);
  Long radio=null;
  if (elencoSerre.size()!=0)
  {
    htmpl.newBlock("blkIntestazione");
  }
  boolean flagIntermediario = false;
  for(int i=startRow;i<size && i< startRow+SolmrConstants.NUM_MAX_ROWS_PAG;i++)
  {
    SerraVO serraVO = (SerraVO)elencoSerre.elementAt(i);

    if(serraVO.getDataFineValidita() == null)
    {
      htmpl.newBlock("blkElencoSerre");

      if(!"".equals(serraVO.getModificaIntermediario()) && serraVO.getModificaIntermediario() != null)
      {
        htmpl.set("blkElencoSerre.modIntermediario", "color:red");
        flagIntermediario = true;
      }
      htmpl.set("blkElencoSerre.idSerra",serraVO.getIdSerra().toString());
      htmpl.set("blkElencoSerre.descrizioneTipoColtura",serraVO.getDescrizioneTipoColtura());
      htmpl.set("blkElencoSerre.descrizioneTipoFormaSerra",serraVO.getDescrizioneTipoFormaSerra());
      htmpl.set("blkElencoSerre.volumeMetriCubi",serraVO.getVolumeMetriCubi().toString());
      if(serraVO.getMesiDiRiscaldamento() != null){
        htmpl.set("blkElencoSerre.mesiDiRiscaldamento",serraVO.getMesiDiRiscaldamento().toString());
      }
      if(serraVO.getGiorniRiscaldamentoAnnulali() != null){
      	htmpl.set("blkElencoSerre.ggRiscaldAnn",serraVO.getGiorniRiscaldamentoAnnulali().toString());
      }
      htmpl.set("blkElencoSerre.dataCarico",DateUtils.formatDate(serraVO.getDataCarico()));
      htmpl.set("blkElencoSerre.linkIdSerra",serraVO.getIdSerra().toString());
    }
  }
  if(flagIntermediario)
    htmpl.newBlock("blkIntermediario");

  Double volumeTotale = new Double(0);
  for(int i=0;i<elencoSerre.size();i++){
    SerraVO serraVO=(SerraVO)elencoSerre.get(i);
    volumeTotale = new Double( serraVO.getVolumeMetriCubi().doubleValue() + volumeTotale.doubleValue() );
  }

  //if( supUtilizzataTotale.doubleValue()!=0 ){
  if (elencoSerre.size()!=0){
    SolmrLogger.debug(this,"volumeTotale!=0");
    htmpl.newBlock("blkSommaVolume");
//    String volumeTotaleStr = numericFormat4.format(volumeTotale);
    htmpl.set("blkSommaVolume.volumeTotale",volumeTotale==null?null:""+volumeTotale.longValue());
  }

  if (elencoSerre.size()==0)
  {
    SolmrLogger.debug(this,"notifica");
    htmpl.set("notifica","Nessuna serra per la ditta uma selezionata");
  }

  out.print(htmpl.text());
%>
<%!
  private String formatDate(Date aDate)
  {
    if (aDate==null)
    {
      return "";
    }
    return DateUtils.formatDate(aDate);
  }
%>
