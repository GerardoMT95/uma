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
<%@ page import="java.math.BigDecimal"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%
  UmaFacadeClient umaClient = new UmaFacadeClient();
  String storicizzazione=request.getParameter("storico");
  Vector elencoLavConsorzi=null;
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/elencoLavConsorziBis.htm");
%><%@include file = "/include/menu.inc" %><%
	DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

  elencoLavConsorzi=(Vector)session.getAttribute("vettLavConsorzi");
  SolmrLogger.debug(this,"NELLA VIEW elencoLavConsorziBis vale: "+elencoLavConsorzi);
  if (elencoLavConsorzi==null)
  {
    elencoLavConsorzi=new Vector(); // Evito nullpointerexception
  }
  SolmrLogger.debug(this,"NELLA VIEW di elencoLavConsorziBis elencoLavConsorzi.size() vale: "+elencoLavConsorzi.size());
  String startRowStr=request.getParameter("startRow");
  int startRow=0;
  int rows=elencoLavConsorzi.size();

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
  if (elencoLavConsorzi.size()==0)
  {
    maxPage=1;
  }
  int currentPage=startRow/SolmrConstants.NUM_MAX_ROWS_PAG+1+(startRow%SolmrConstants.NUM_MAX_ROWS_PAG>0?1:0);

  int size=elencoLavConsorzi.size();
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
  htmpl.set("maxPage",""+maxPage);
  htmpl.set("currentPage",""+currentPage);
  
  LavConsorziVO elem= new LavConsorziVO();
  if(elencoLavConsorzi!=null && elencoLavConsorzi.size()>0){
   	  htmpl.newBlock("blkSiLavorazioni");	
  	  htmpl.newBlock("blkIntestazione");
  	  htmpl.newBlock("blkDati");
  	  //BigDecimal totaleGasolio = new BigDecimal(0);
  	  //BigDecimal totaleBenzina = new BigDecimal(0);
  	  
  	  /*for(int somma=0;somma<elencoLavConsorzi.size();somma++){
  	  	elem = (LavConsorziVO)elencoLavConsorzi.elementAt(somma);
  	  	if(elem.getGasolio()!=null)
	    	totaleGasolio = totaleGasolio.add(elem.getGasolio());
	   	if(elem.getBenzina()!=null)
	    	totaleBenzina = totaleBenzina.add(elem.getBenzina());
  	  }*/

	  for(int i=startRow;i<size && i< startRow+SolmrConstants.NUM_MAX_ROWS_PAG;i++)
	  {
	  	SolmrLogger.debug(this,"NELLA VIEW startRow VALE: "+startRow);
	    elem = (LavConsorziVO)elencoLavConsorzi.elementAt(i);
		htmpl.newBlock("blkDati.blkLavorazione");
	    	      
	    htmpl.set("blkDati.blkLavorazione.cuaa",StringUtils.checkNull(elem.getCuaaAziendaSocio()));    	      
		htmpl.set("blkDati.blkLavorazione.usoDelSuolo",StringUtils.checkNull(elem.getDescCategoriaUtilizzo()));
	    htmpl.set("blkDati.blkLavorazione.supOre",StringUtils.checkNull(elem.getSupOre()));
	    htmpl.set("blkDati.blkLavorazione.lavorazione",StringUtils.checkNull(elem.getDescTipoLavorazione()));
		htmpl.set("blkDati.blkLavorazione.idLavConsorzio",StringUtils.checkNull(elem.getIdLavorazioneConsorzi()));
		htmpl.set("blkDati.blkLavorazione.gasolio",StringUtils.checkNull(elem.getGasolio()));
	    htmpl.set("blkDati.blkLavorazione.benzina",StringUtils.checkNull(elem.getBenzina()));
		htmpl.set("blkDati.blkLavorazione.inizioValidita",UmaDateUtils.formatDateNext(elem.getDataInizioValidita()));
		htmpl.set("blkDati.blkLavorazione.fineValidita",UmaDateUtils.formatDateNext(elem.getDataFineValidita()));
		htmpl.set("blkDati.blkLavorazione.dataCessazione",UmaDateUtils.formatDateNext(elem.getDataCessazione()));	    

	  }// end for
	  
	  htmpl.set("blkDati.totaleGasolio",StringUtils.checkNull(elem.getTotaleGasolio()));
  	  htmpl.set("blkDati.totaleBenzina",StringUtils.checkNull(elem.getTotaleBenzina()));
  }else{
   htmpl.newBlock("blkNoLavorazioni");
   }
  
 // carico combo anniCampagna
  AnnoCampagnaVO annoCampagnaSel= (AnnoCampagnaVO)session.getAttribute("annoCampagna");
  
  SolmrLogger.debug(this,"NELLA VIEW annoCampagnaSel VALE: "+annoCampagnaSel);
  if(null!=annoCampagnaSel && !StringUtils.isStringEmpty(annoCampagnaSel.getAnnoCampagna()) && elencoLavConsorzi!=null && elencoLavConsorzi.size()>0){
		
		SolmrLogger.debug(this,"NELLA VIEW annoCampagnaSel.getAnnoCampagna() VALE: "+annoCampagnaSel.getAnnoCampagna());
		htmpl.set("blkSiLavorazioni.campagna",annoCampagnaSel.getAnnoCampagna());
  }
  Vector vettAnniCampagna =(Vector)session.getAttribute("lavVettAnniCampagna");
  SolmrLogger.debug(this,"NELLA VIEW vettAnniCampagna vale: "+vettAnniCampagna);
  Vector vett= new Vector();
  if(vettAnniCampagna!=null && vettAnniCampagna.size()>0){
  	vett=vettAnniCampagna;
  }
  	
  for(int i=0;i<vett.size();i++){
	AnnoCampagnaVO elemAnno = (AnnoCampagnaVO)vett.get(i);
	htmpl.newBlock("blkComboAnno");
	
	htmpl.set("blkComboAnno.idAnnoRiferimento",""+elemAnno.getAnnoCampagna());
	htmpl.set("blkComboAnno.annoRiferimentoDesc",""+elemAnno.getAnnoCampagna());
	SolmrLogger.debug(this,"NELLA VIEW CARICA COMBO annoCampagnaSel vale: "+annoCampagnaSel);
	SolmrLogger.debug(this,"NELLA VIEW CARICA COMBO elemAnno.getAnnoCampagna() vale: "+elemAnno.getAnnoCampagna());
	if (i==0 ||(annoCampagnaSel!=null && (annoCampagnaSel.getAnnoCampagna()).equalsIgnoreCase(elemAnno.getAnnoCampagna()))){
    		htmpl.set("blkComboAnno.annoRiferimentoSel","selected");
 	}
	
  }

	if(session.getAttribute("annoCampagna")!=null){
  		AnnoCampagnaVO annoCampagna =(AnnoCampagnaVO)session.getAttribute("annoCampagna");
   		htmpl.set("cuaaSel",annoCampagna.getCuaaContoProprio());
   		htmpl.set("partitaIvaSel",annoCampagna.getPartitaIvaContoProprio());
   		htmpl.set("denominazioneSel",annoCampagna.getDenominazioneContoProprio());
  	}
	
  out.print(htmpl.text());
%>