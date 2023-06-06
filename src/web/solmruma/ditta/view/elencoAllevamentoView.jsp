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
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%

  UmaFacadeClient umaClient = new UmaFacadeClient();

  String storicizzazione=request.getParameter("storico");

  Vector allevamenti=null;

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/elencoAllevamento.htm");
%><%@include file = "/include/menu.inc" %><%

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");



  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();


  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);





  allevamenti=(Vector)request.getAttribute("elencoAllevamenti");

  SolmrLogger.debug(this,"\n\n\n\n\n\n\n\nelencoAllevamentoView.jsp\n\n\n\n\n\n\n\n\n\n");

  if (allevamenti==null)

  {

    SolmrLogger.debug(this,"\n\n\n\n\nelencoAllevamenti==null\n\n\n\n\n");

    allevamenti=new Vector(); // Evito nullpointerexception

  }

  else

  {

    SolmrLogger.debug(this,"\n\n\n\n\nelencoAllevamenti!=null\n\n\n\n\n");

  }

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
  boolean hasConsistenza=false;

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


// MODIFICA effettuata da EINAUDI il 14/11/2005
// Aggiungere la frase sulla consistenza se esiste una superficie con
// ext_id_consistenza<>null (solo dopo la data del parametro FUMA e in base
// alle tipologie non presenti nel parametro GUMA
    Boolean hasGestioniAttribute=(Boolean)request.getAttribute("hasGestioniAL");
    boolean hasGestioni=hasGestioniAttribute!=null && hasGestioniAttribute.booleanValue();
    if (!hasGestioni && !hasConsistenza && Validator.isNotEmpty(allevamentoVO.getExtIdConsistenza()))
    {
      htmpl.newBlock("blkConsistenza");
      htmpl.set("blkConsistenza.dataConsistenza",DateUtils.formatDate(allevamentoVO.getDataConsistenza()));
      hasConsistenza=true;
    }
// Fine MODIFICA



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

    htmpl.set("blkAllevamento.dataCarico",DateUtils.formatDate(allevamentoVO.getDataCarico()));

    htmpl.set("blkAllevamento.unitaDiMisura",allevamentoVO.getTipoCategoriaAnimaleVO().getUnitaMisura());

    double uba=NumberUtils.arrotonda(allevamentoVO.getQuantita().longValue()*allevamentoVO.getTipoCategoriaAnimaleVO().getCoefficienteUBA().doubleValue(),4);

    totUba+=uba;

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