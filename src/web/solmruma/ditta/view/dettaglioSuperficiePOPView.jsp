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
<%@ page import="java.text.DecimalFormat"%>

<%

  SolmrLogger.debug(this,"dettaglioSuperficiePOPView.jsp");
  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/dettaglioSuperficiePOP.htm");
%>
  <%@include file = "/include/menu.inc" %>
<%

  SolmrLogger.debug(this, "   BEGIN dettaglioSuperficiePOPView");
  
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
  DecimalFormat numericFormat4 = new DecimalFormat(SolmrConstants.FORMATO_NUMERIC_1INT_4DEC);
  //SuperficieAziendaVO superficieVO=new SuperficieAziendaVO();
  Vector<SuperficieAziendaVO> vSuperficieAzienda = null;
  UtenteIrideVO utenteIrideVO=new UtenteIrideVO();
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  try
  {
    StringTokenizer st = new StringTokenizer(request.getParameter("idSuperficie"), "|");
    String istatComune = st.nextToken();  
    SolmrLogger.debug(this, "-- istatComune ="+istatComune);  
    String idTitoloPossesso = st.nextToken();
    SolmrLogger.debug(this, "-- idTitoloPossesso ="+idTitoloPossesso);
    String dataInizioValidita = st.nextToken();
    SolmrLogger.debug(this, "-- dataInizioValidita ="+dataInizioValidita);
    String flagColturaSecondaria = st.nextToken();
    SolmrLogger.debug(this, "-- flagColturaSecondaria ="+flagColturaSecondaria);
    String dataFineValidita = "";
    if(st.hasMoreElements()){
      dataFineValidita = st.nextToken();      
    }    
    SolmrLogger.debug(this, "-- dataFineValidita ="+dataFineValidita);
  
    SolmrLogger.debug(this, "-- ricerca dettaglio superfici e colture");
    vSuperficieAzienda = umaClient.findSuperficiAziendaByComunePossesso(
      dittaUMAAziendaVO.getIdDittaUMA(), istatComune, new Long(idTitoloPossesso), dataInizioValidita, dataFineValidita, flagColturaSecondaria);
  }
  catch(Exception e)
  {}

  //Prendo il primo per tutti gli altri dovrebbe essere uguale
  SuperficieAziendaVO superficieVO = vSuperficieAzienda.get(0);
  try
  {
    utenteIrideVO=umaClient.getUtenteIride(superficieVO.getExtIdUtenteAggiornamento());
  }
  catch(Exception e)
  {
    utenteIrideVO=new UtenteIrideVO();
  }

  htmpl.set("comune", superficieVO.getComuniTerreniStr());
  htmpl.set("dataCarico",formatDate(superficieVO.getDataCarico()));
  htmpl.set("dataScarico",formatDate(superficieVO.getDataScarico()));
  htmpl.set("dataInizioValidita",formatDate(superficieVO.getDataInizioValidita()));
  htmpl.set("dataFineValidita",formatDate(superficieVO.getDataFineValidita()));
  
  String flagColturaSecondaria = superficieVO.getFlagColturaSecondaria();
  SolmrLogger.debug(this, "-- flagColturaSecondaria ="+flagColturaSecondaria);
  if(flagColturaSecondaria != null && flagColturaSecondaria.equalsIgnoreCase("S"))
    flagColturaSecondaria = "SI";
  else
    flagColturaSecondaria = ""; 
  htmpl.set("colturaSecondaria", flagColturaSecondaria);
  
  htmpl.set("dataScadenzaAffitto",formatDate(superficieVO.getDataScadenzaAffitto()));
  htmpl.set("dataAggiornamento",formatDate(superficieVO.getDataAggiornamento()));
  htmpl.set("dataRegistrazioneContratto",formatDate(superficieVO.getDataRegistrazione()));
  htmpl.set("utenteAggiornamento",utenteIrideVO.getDenominazione());
  htmpl.set("enteAggiornamento",utenteIrideVO.getDescrizioneEnteAppartenenza());
  HtmplUtil.setValues(htmpl,superficieVO,(String) session.getAttribute("pathToFollow"));

  htmpl.set("nomeEnte",utenteIrideVO.getDescrizioneEnteAppartenenza());
  Boolean hasGestioniAttribute=(Boolean)request.getAttribute("hasGestioniSU");
  boolean hasGestioni=hasGestioniAttribute!=null && hasGestioniAttribute.booleanValue();
  if (!hasGestioni && Validator.isNotEmpty(superficieVO.getExtIdConsistenza()))
  {
    htmpl.newBlock("blkConsistenza");
    htmpl.set("blkConsistenza.dataConsistenza",DateUtils.formatDateTimeNotNull(superficieVO.getDataConsistenza()));
  }
  
  boolean trovataAzienda = false;
  boolean flagPrimoRecord = true;
  for(int i=0;i<vSuperficieAzienda.size();i++)
  {
    flagPrimoRecord = true;
    String azienda = "";
    if(Validator.isNotEmpty(vSuperficieAzienda.get(i).getIdAziendaSocio()))
	  {
	    if(!trovataAzienda)
	    {
	      htmpl.newBlock("blkAzienda");
	      trovataAzienda = true;
	    }
	    
	    htmpl.newBlock("blkAzienda.blkElencoAzienda");
	    htmpl.newBlock("blkAzienda.blkElencoAzienda.blkPrimo");
	    htmpl.set("blkAzienda.blkElencoAzienda.blkPrimo.numrighe", ""+vSuperficieAzienda.get(i).getColturePraticate().size());
	    htmpl.set("blkAzienda.blkElencoAzienda.blkPrimo.cuaa", vSuperficieAzienda.get(i).getCuaaAziendaSocio());
	    htmpl.set("blkAzienda.blkElencoAzienda.blkPrimo.partitaIva", vSuperficieAzienda.get(i).getCuaaAziendaSocio());
	    htmpl.set("blkAzienda.blkElencoAzienda.blkPrimo.denominazone", vSuperficieAzienda.get(i).getDenomAziendaSocio());
	    String sedeLegale = vSuperficieAzienda.get(i).getSedeLegIndirizzoAziendaSocio()
	     +" - " +vSuperficieAzienda.get(i).getSedeLegComuneAziendaSocio()+" ("
	     +vSuperficieAzienda.get(i).getSedeLegProvinciaAziendaSocio()+")";
	    htmpl.set("blkAzienda.blkElencoAzienda.blkPrimo.sedeLegale", sedeLegale);
	    for(int j=0;j<vSuperficieAzienda.get(i).getColturePraticate().size();j++)
	    {
	      if(flagPrimoRecord)
	      {
	        htmpl.newBlock("blkAzienda.blkElencoAzienda.blkSecondo");
	        flagPrimoRecord = false;	        
	        htmpl.set("blkAzienda.blkElencoAzienda.blkSecondo.descColtura", 
	          ((ColturaPraticataVO)vSuperficieAzienda.get(i).getColturePraticate().get(j)).getDescColtura());
	        String supUtilizzata = numericFormat4.format(((ColturaPraticataVO)vSuperficieAzienda.get(i).getColturePraticate().get(j))
	         .getSuperficieUtilizzataDouble());
	        htmpl.set("blkAzienda.blkElencoAzienda.blkSecondo.supUtilizzata", supUtilizzata.replace('.',','));
	      }
	      else
	      {
	        htmpl.newBlock("blkAzienda.blkElencoAzienda");
	        htmpl.newBlock("blkAzienda.blkElencoAzienda.blkSecondo");
		      htmpl.set("blkAzienda.blkElencoAzienda.blkSecondo.descColtura", 
		        ((ColturaPraticataVO)vSuperficieAzienda.get(i).getColturePraticate().get(j)).getDescColtura());
		      String supUtilizzata = numericFormat4.format(((ColturaPraticataVO)vSuperficieAzienda.get(i).getColturePraticate().get(j))
		       .getSuperficieUtilizzataDouble());
		      htmpl.set("blkAzienda.blkElencoAzienda.blkSecondo.supUtilizzata", supUtilizzata.replace('.',','));
		    }
	    }
	    
	  }
  }

  SolmrLogger.debug(this, "   END dettaglioSuperficiePOPView");

  out.print(htmpl.text());

%>

<%!

  private String formatDate(Date aDate)
  {
    if (aDate==null)
    {
      return null;
    }
    return DateUtils.formatDate(aDate);
  }
  
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

