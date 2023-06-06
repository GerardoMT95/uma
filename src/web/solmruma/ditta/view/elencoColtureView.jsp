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
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String layout = "/ditta/layout/elencoColture.htm";
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layout);
%>
  <%@include file = "/include/menu.inc" %>
<%
  SolmrLogger.debug(this, "   BEGIN elencoColtureView");
  
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
//this.errErrorValExc(htmpl, request, exception);

	HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);	
	UmaFacadeClient umaClient = new UmaFacadeClient();		
	
	// Inizio paginazione	
	Vector elencoColture;	
	elencoColture= (Vector) request.getAttribute("elencoColture");	
	
	Vector<SuperficieAziendaVO> vSuperficieAzienda = (Vector<SuperficieAziendaVO>) request.getAttribute("vSuperficieAzienda");	
	//prendo il primo che è uguale per tutti.
	SuperficieAziendaVO superficieVO = vSuperficieAzienda.get(0);
	SolmrLogger.debug(this,"superficieVO.getIdDittaUma(): " + superficieVO.getIdDittaUma());
	
	if (elencoColture!=null)
	{	
	  htmpl.newBlock("blkIntestazione");	
	  htmpl.set("denominazione",superficieVO.getDenominazione());	
	  htmpl.set("comune",superficieVO.getComuniTerreniStr());
	  htmpl.set("titoloPossesso",""+superficieVO.getTitoloPossesso());
	  String flagColturaSecondaria = superficieVO.getFlagColturaSecondaria();	
	  if(flagColturaSecondaria != null && flagColturaSecondaria.equalsIgnoreCase("S"))
	    flagColturaSecondaria = "SI";
	  else
	    flagColturaSecondaria = "";  
	  htmpl.set("colturaSecondaria", flagColturaSecondaria);
	
	  DecimalFormat numericFormat4 = new DecimalFormat(SolmrConstants.FORMATO_NUMERIC_1INT_4DEC);
	  double totaleSuperficie=0;	
	  
	  boolean flagIntermediario = false;	
	  for(int i=0; i<elencoColture.size(); i++)	
	  {	
	    ColturaPraticataVO colturaVO = (ColturaPraticataVO)elencoColture.elementAt(i);	
	    /**	
	    * Sostitusco per ogni campo reale il punto decimale con la virgola	
	    */	
	    SolmrLogger.debug(this,"colturaVO.getSuperficieUtilizzataDouble(): "+colturaVO.getSuperficieUtilizzataDouble());	
	    if ( colturaVO.getSuperficieUtilizzataDouble() !=null )
	    {	
	      String supUtilizzata = numericFormat4.format(colturaVO.getSuperficieUtilizzataDouble());
	      SolmrLogger.debug(this,"\n\nsupUtilizzata: "+supUtilizzata);	
	      colturaVO.setSuperficieUtilizzata( supUtilizzata.replace('.',',') );	
	    }	
	    SolmrLogger.debug(this,"colturaVO.getSuperficieUtilizzata(): "+colturaVO.getSuperficieUtilizzata());
		  htmpl.newBlock("blkElencoColture");
	
	    htmpl.set("blkElencoColture.tipoColturaPraticata",colturaVO.getDescColtura());	
	    htmpl.set("blkElencoColture.superficieUtilizzata",colturaVO.getSuperficieUtilizzata());	
	    htmpl.set("blkElencoColture.dataAggiornamento",""+DateUtils.formatDate(colturaVO.getDataAggiornamentoDate()));	
	    htmpl.set("blkElencoColture.utenteAggiornamento",colturaVO.getUtenteAggiornamento());	
	    htmpl.set("blkElencoColture.enteAggiornamento",colturaVO.getEnteAggiornamento());	
	
	    SolmrLogger.debug(this,"colturaVO.getDataAggiornamentoDate() "+colturaVO.getDataAggiornamentoDate());	
	    totaleSuperficie = totaleSuperficie + colturaVO.getSuperficieUtilizzataDouble().doubleValue();
	  }
	
	  if(flagIntermediario)	
	    htmpl.newBlock("blkIntermediario");
	
	  String totaleSuperficieStr = numericFormat4.format( new Double(totaleSuperficie) );	
	  SolmrLogger.debug(this,"\n\ntotaleSuperficie: "+totaleSuperficieStr);	
	  totaleSuperficieStr = totaleSuperficieStr.replace('.',',');	
	  htmpl.set("totaleSuperficie", totaleSuperficieStr);	
	}	
	// Fine paginazione	
	
	//se l'operazione selezionata è andata a buon fine	
	if(request.getParameter("mess") != null)	
	  htmpl.set("exception", request.getParameter("mess"));
	  
    SolmrLogger.debug(this, "   END elencoColtureView");
%>

<%= htmpl.text()%>

