<%@ page language="java"
      contentType="text/htm"
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
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%

  UmaFacadeClient umaClient = new UmaFacadeClient();

  String storicizzazione=request.getParameter("storico");

  Vector allevamenti=null;

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/elencoAllevamentoBis.htm");
%><%@include file = "/include/menu.inc" %><%

  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);





  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();




  allevamenti=(Vector)request.getAttribute("elencoAllevamenti");

  if (allevamenti==null)

  {

    SolmrLogger.debug(this,"elencoAllevamenti==null");

    allevamenti=new Vector(); // Evito nullpointerexception

  }

/*  try

  {

    allevamenti=umaClient.getAllevamenti(idDittaUma,new Boolean(false));

  }

  catch(SolmrException e)

  {

    htmpl.set("$$exception",e.getMessage());

  }*/

  SolmrLogger.debug(this,"allevamenti.size()="+allevamenti.size());

  String startRowStr=request.getParameter("startRow");

  int startRow=0;

  int rows=allevamenti.size();



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

  if (allevamenti.size()==0)

  {

    maxPage=1;

  }

  int currentPage=startRow/SolmrConstants.NUM_MAX_ROWS_PAG+1+(startRow%SolmrConstants.NUM_MAX_ROWS_PAG>0?1:0);



  int size=allevamenti.size();

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

  htmpl.set("numAllevamenti",""+allevamenti.size());

  htmpl.set("maxPage",""+maxPage);

  htmpl.set("currentPage",""+currentPage);

  Long radio=null;

  try

  {

    radio=new Long(request.getParameter("radiobutton"));

  }

  catch(Exception e)

  {

  }

  if (allevamenti.size()!=0)

  {

    htmpl.newBlock("blkIntestazione");

  }



  java.text.DecimalFormat numericFormat2 = new java.text.DecimalFormat(SolmrConstants.FORMATO_NUMERIC_1INT_2DEC);

  boolean flagIntermediario = false;

  double totUba=0;

  double uba=0;

  HashMap lavorazioni=null;
  try
  {
    int numAllevamenti=size-startRow;
    if (numAllevamenti>SolmrConstants.NUM_MAX_ROWS_PAG)
    {
      numAllevamenti=SolmrConstants.NUM_MAX_ROWS_PAG;
    }
    if (numAllevamenti>0)
    {
      Long idAllevamenti[]=new Long[numAllevamenti];
      for(int k=0;k<numAllevamenti;k++)
      {
        idAllevamenti[k]=((AllevamentoVO)allevamenti.get(k+startRow)).getIdAllevamento();
      }
      lavorazioni=umaClient.getDescrizioniLavorazioniPraticateByIdRange(idAllevamenti);
    }
    else
    {
      lavorazioni=new HashMap();
    }
  }
  catch(Exception e)
  {
    SolmrLogger.debug(this,"Eccezione durante il recupero delle lavorazioni: "+e.toString());
    // Nel caso ci siano errori non visualizzo le lavorazioni ma evito il null
    // pointer
    lavorazioni=new HashMap();
  }



  for(int i=startRow;i<size && i< startRow+SolmrConstants.NUM_MAX_ROWS_PAG;i++)

  {

    htmpl.newBlock("blkAllevamento");

    AllevamentoVO allevamentoVO=(AllevamentoVO)allevamenti.get(i);

    Long idAllevamento=allevamentoVO.getIdAllevamento();



    if(!"".equals(allevamentoVO.getModificaIntermediario()) && allevamentoVO.getModificaIntermediario() != null)

    {

      htmpl.set("blkAllevamento.modIntermediario", "color:red");

      flagIntermediario = true;

    }





    if (radio!=null && radio.equals(idAllevamento))

    {

      htmpl.set("blkAllevamento.checked","checked");

    }

    htmpl.set("blkAllevamento.idAllevamento",""+idAllevamento);

    htmpl.set("blkAllevamento.specie",allevamentoVO.getSpecie());

    htmpl.set("blkAllevamento.categoria",allevamentoVO.getCategoria());

    htmpl.set("blkAllevamento.quantita",""+allevamentoVO.getQuantita());
    
    if(allevamentoVO.getFlagSoccida() != null && allevamentoVO.getFlagSoccida().equals(SolmrConstants.FLAG_SI))
      htmpl.set("blkAllevamento.soccida", "Si");

    htmpl.set("blkAllevamento.dataCarico",formatDate(allevamentoVO.getDataCarico()));

    htmpl.set("blkAllevamento.unitaDiMisura",allevamentoVO.getTipoCategoriaAnimaleVO().getUnitaMisura());

    htmpl.set("blkAllevamento.dataScarico",""+formatDate(allevamentoVO.getDataScarico()));

    htmpl.set("blkAllevamento.inizioValidita",""+formatDate(allevamentoVO.getDataInizioVal()));

    htmpl.set("blkAllevamento.fineValidita",""+formatDate(allevamentoVO.getDataFineVal()));

    uba=NumberUtils.arrotonda(allevamentoVO.getQuantita().longValue()*allevamentoVO.getTipoCategoriaAnimaleVO().getCoefficienteUBA().doubleValue(),4);

    if(allevamentoVO.getDataFineVal() == null)

    {

      totUba+=uba;

    }

    htmpl.set("blkAllevamento.uba",numericFormat2.format(new Double(uba)));

    StringBuffer lavorazioneSB=(StringBuffer)lavorazioni.get(allevamentoVO.getIdAllevamento().toString());
    String lavorazione=lavorazioneSB==null?"":lavorazioneSB.toString();
    htmpl.set("blkAllevamento.lavorazioni",lavorazione);

  }

  if (startRow<size)

  {

    htmpl.newBlock("blkTotaleUba");

    htmpl.set("blkTotaleUba.totaleUba",numericFormat2.format(new Double(totUba)));

  }

  if(flagIntermediario)

    htmpl.newBlock("blkIntermediario");

  out.print(htmpl.text());

%>

<%!

  private String formatDate(Date date)

  {

    if (date!=null)

    {

      return DateUtils.formatDate(date);

    }

    return "";

  }

%>

