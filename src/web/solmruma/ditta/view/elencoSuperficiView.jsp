<%@ page language="java" contentType="text/html" isErrorPage="true" %>



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
  Vector<SuperficieAziendaVO> superfici=null;
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/elencoSuperfici.htm");
%>
  <%@include file = "/include/menu.inc" %>
<%
  SolmrLogger.debug(this, "   BEGIN elencoSuperficiView");

  DecimalFormat numericFormat4 = new DecimalFormat(SolmrConstants.FORMATO_NUMERIC_1INT_4DEC);
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
  Long idDittaUma=(Long) session.getAttribute("idDittaUma");
  //superfici=formatData((Vector)request.getAttribute("elencoSuperfici"));
  superfici=(Vector<SuperficieAziendaVO>)request.getAttribute("elencoSuperfici");
  if (superfici==null)
  {
    superfici=new Vector(); // Evito nullpointerexception
  }

  String startRowStr=request.getParameter("startRow");
  int startRow=0;
  int rows=superfici.size();
  SolmrLogger.debug(this, "-- numero di righe trovate ="+rows);
  if (startRowStr!=null)
  {
    try
    {
      startRow=new Integer(startRowStr).intValue();
    }
    catch(Exception e) // Errore, suppongo startrow==0 e quindi non faccio nulla!!!
    {}
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
  if (superfici.size()==0)
  {
    maxPage=1;
  }
  int currentPage=startRow/SolmrConstants.NUM_MAX_ROWS_PAG+1+(startRow%SolmrConstants.NUM_MAX_ROWS_PAG>0?1:0);
  int size=superfici.size();
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
  htmpl.set("numSuperfici",""+superfici.size());
  htmpl.set("maxPage",""+maxPage);
  htmpl.set("currentPage",""+currentPage);
  Long radio=null;
  if (superfici.size()!=0)
  {
    htmpl.newBlock("blkIntestazione");
  }

  Double supUtilizzataDouble;
  String supUtilizzata;
  boolean flagIntermediario = false;
  boolean hasConsistenza=false;
  Boolean hasGestioniAttribute=(Boolean)request.getAttribute("hasGestioniSU");
  boolean hasGestioni=hasGestioniAttribute!=null && hasGestioniAttribute.booleanValue();
  for(int i=startRow;i<size && i< startRow+SolmrConstants.NUM_MAX_ROWS_PAG;i++)
  {
    htmpl.newBlock("blkSuperficie");
    SuperficieAziendaVO superficieVO= superfici.get(i);

    supUtilizzataDouble = superficieVO.getSuperficieUtilizzataDouble();
    
    // ---- valore settato sotto il radioButton
    String idSuperficie = superficieVO.getExtComuneIstat()+"|"+superficieVO.getIdTitoloPossesso();
    idSuperficie += "|"+DateUtils.formatDate(superficieVO.getDataInizioValidita());
    idSuperficie += "|"+superficieVO.getFlagColturaSecondaria();
    if(Validator.isNotEmpty(superficieVO.getDataFineValidita()))
    {
      idSuperficie += "|"+DateUtils.formatDate(superficieVO.getDataFineValidita());
    }    
    SolmrLogger.debug(this, "--- idSuperficie settato ="+idSuperficie);
    htmpl.set("blkSuperficie.idSuperficie", idSuperficie);
    //
    
    htmpl.set("blkSuperficie.comuniTerreniStr",""+superficieVO.getComuniTerreniStr());
    htmpl.set("blkSuperficie.titoloPossesso",superficieVO.getTitoloPossesso());
    
    String flagColturaSecondaria = superficieVO.getFlagColturaSecondaria();
    SolmrLogger.debug(this, "-- flagColturaSecondaria ="+flagColturaSecondaria);
    String colturaSecondaria = "";
    if(flagColturaSecondaria != null && flagColturaSecondaria.equalsIgnoreCase("S"))
      colturaSecondaria = "SI";
       htmpl.set("blkSuperficie.colturaSecondaria", colturaSecondaria);
    
    htmpl.set("blkSuperficie.dataCarico",formatDate(superficieVO.getDataCarico()));

    supUtilizzata = numericFormat4.format(supUtilizzataDouble);
    htmpl.set("blkSuperficie.supUtilizzata",supUtilizzata);
  }

  Double supUtilizzataTotale = new Double(0);
  for(int i=0;i<superfici.size();i++)
  {
    SuperficieAziendaVO superficieVO=(SuperficieAziendaVO)superfici.get(i);
    supUtilizzataDouble = superficieVO.getSuperficieUtilizzataDouble();
    supUtilizzataTotale = new Double( supUtilizzataTotale.doubleValue() + supUtilizzataDouble.doubleValue() );
  }

  //if( supUtilizzataTotale.doubleValue()!=0 ){
  if (superfici.size()!=0)
  {
    SolmrLogger.debug(this,"supUtilizzataTotale!=0");
    htmpl.newBlock("blkSommaSuperficie");
    supUtilizzata = numericFormat4.format(supUtilizzataTotale);
    htmpl.set("blkSommaSuperficie.supUtilizzataTotale",supUtilizzata);
  }

  if(flagIntermediario)
    htmpl.newBlock("blkIntermediario");
  if (superfici.size()==0)
  {
    SolmrLogger.debug(this,"notifica");
    htmpl.set("notifica","Nessuna superficie per la ditta uma selezionata");
  }
  
  SolmrLogger.debug(this, "   END elencoSuperficiView");
  
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

