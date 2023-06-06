<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%!
  public static final String LIGHT_GREY = " style='background-color:LightGrey' ";
 %>
<%
  SolmrLogger.debug(this,"[restituzioneBuonoView::service] BEGIN.");
  java.io.InputStream layout = application.getResourceAsStream("/domass/layout/restituzioneBuono.htm");
  UmaFacadeClient client = new UmaFacadeClient();
  Htmpl htmpl = new Htmpl(layout);
%>

<%@include file = "/include/menu.inc" %>

<%
  Vector v_carb = (Vector)session.getAttribute("v_carb");
  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

  if(request.getAttribute("esisteBruciatore")!=null)
    htmpl.set("flag", (String)request.getAttribute("esisteBruciatore"));

  // Settaggio dei dati comuni
  String provCompetenza ="";

  if(dittaVO.getProvUMA()!=null&&!dittaVO.getProvUMA().equals(""))
    provCompetenza = client.getProvinciaByIstat(dittaVO.getProvUMA());

  htmpl.set("provinciaUMA", provCompetenza);

  if(dittaVO.getCuaa()!=null &&!dittaVO.getCuaa().equals("")){
   htmpl.set("CUAA", dittaVO.getCuaa()+" - ");
  }

  HtmplUtil.setValues(htmpl, dittaVO);

  BuonoPrelievoVO buonoVO = (BuonoPrelievoVO)session.getAttribute("buonoVO");
  SolmrLogger.debug(this, "--buonoVO.getNumeroBlocco() ="+buonoVO.getNumeroBlocco());
  boolean isBuono99999=SolmrConstants.NUMERO_BLOCCO.equals(StringUtils.checkNull(buonoVO.getNumeroBlocco()));
  SolmrLogger.debug(this, "-- isBuono99999 ="+isBuono99999);		  
  BuonoCarburanteVO carbVO = null;

  htmpl.set("annoRife", buonoVO.getAnnoRiferimento().toString());

  SolmrLogger.debug(this,"[restituzioneBuonoView::service] Valore di Anno Riferimento "+buonoVO.getAnnoRiferimento().toString());

  htmpl.set("blocco", buonoVO.getNumeroBlocco().toString());
  htmpl.set("buono", buonoVO.getNumeroBuono().toString());
  htmpl.set("dataEmissione", DateUtils.formatDate(buonoVO.getDataEmissione()));

  if(buonoVO.getCarburantePerSerra()!=null&&buonoVO.getCarburantePerSerra().equals(SolmrConstants.CARBURANTE_PER_SERRA))
    htmpl.set("serra", "checked");
  else{
	  if(buonoVO.getIdConduzione().longValue() == 1L)
    	htmpl.set("noSerraCp", "checked");
	  else
    	htmpl.set("noSerraCt", "checked");
  }

  // Se l'anno riferimento è superiore a 2003 non deve essere possibile modificare
  // il valore del radiobutton "Tipo Utilizzo"
  if(buonoVO.getAnnoRiferimento().compareTo(new Long("2003"))>0){
    htmpl.set("disabled", "disabled");
  }

  // Se l'anno è inferiore a 2004 recupero eventualmente la presenza di un
  // bruciatore per serra legato alla ditta UMA e lo segnalo
  else if(request.getAttribute("esisteBruciatore")!=null)
    htmpl.set("bruciatore", ""+UmaErrors.get("ESISTE_BRUCIATORE"));

  int gConc = 0;
  int bConc = 0;
  
  // 18-11-2008 - Nick - CU-GUMA-15 gestione buoni emessi.  
  String strQuantitaPrelevataB = "0";
  String strQuantitaPrelevataG = "0";
  String strDataUltimoPrelievoB = "";
  String strDataUltimoPrelievoG = "";
  String strQuantitaUltimoPrelievoB = "0";
  String strQuantitaUltimoPrelievoG = "0";

  Iterator i = v_carb.iterator();

  SolmrLogger.debug(this,"[restituzioneBuonoView::service] Valore di v_carb "+v_carb.size());
  while(i.hasNext()){
    carbVO = (BuonoCarburanteVO)i.next();

    SolmrLogger.debug(this,"[restituzioneBuonoView::service] Id Carburante.... "+carbVO.getIdCarburante());

    if(carbVO.getDataAggiornamentoPrelievo()!=null)
      htmpl.set("dataModPrel", DateUtils.formatDate(carbVO.getDataAggiornamentoPrelievo()));

    htmpl.set("modificaPrel", carbVO.getUtenteAggiornamentoPrelievo());        
    if(carbVO.getCarburante().equals(SolmrConstants.ID_BENZINA)){
        bConc = carbVO.getQuantitaConcessa().intValue();
      SolmrLogger.debug(this,"[restituzioneBuonoView::service] idCarburanteBenzina "+carbVO.getIdCarburante());

      htmpl.set("idCarburanteBenzina", carbVO.getIdCarburante().toString());
      
      // 18-11-2008 - Nick - CU-GUMA-15 gestione buoni emessi.             
      if (carbVO.getTotQuantitaPrelievo() == null) 
	  	  strQuantitaPrelevataB = "0";
	  else
	  	  strQuantitaPrelevataB = String.valueOf( NumberUtils.sumIntegerStringValueNoError(carbVO.getTotQuantitaPrelievo().toString(),
	  	  strQuantitaPrelevataB));
	  	  
	  if (carbVO.getDataUltimoPrelievo() == null) 
	  	  strDataUltimoPrelievoB = "";
	  else
	  	  strDataUltimoPrelievoB = DateUtils.formatDate(carbVO.getDataUltimoPrelievo());
	  	  
	  if (carbVO.getQtaUltimoPrelievo() == null) 
	  	  strQuantitaUltimoPrelievoB = "0";
	  else
	  	  strQuantitaUltimoPrelievoB = carbVO.getQtaUltimoPrelievo().toString();	  	  	  	  
    }

    else if(carbVO.getCarburante().equals(SolmrConstants.ID_GASOLIO)){
        gConc = carbVO.getQuantitaConcessa().intValue();

      SolmrLogger.debug(this,"[restituzioneBuonoView::service] idCarburanteGasolio "+carbVO.getIdCarburante());

      htmpl.set("idCarburanteGasolio", carbVO.getIdCarburante().toString());
      
      // 18-11-2008 - Nick - CU-GUMA-15 gestione buoni emessi.              
	  if (carbVO.getTotQuantitaPrelievo() == null) 
	  	  strQuantitaPrelevataG = "0";
	  else
	  	  strQuantitaPrelevataG =  String.valueOf( NumberUtils.sumIntegerStringValueNoError(carbVO.getTotQuantitaPrelievo().toString(),
	  	  strQuantitaPrelevataG));
	  	  
	  if (carbVO.getDataUltimoPrelievo() == null) 
	  	  strDataUltimoPrelievoG = "";
	  else
	  	  strDataUltimoPrelievoG = DateUtils.formatDate(carbVO.getDataUltimoPrelievo());
	  	  
	  if (carbVO.getQtaUltimoPrelievo() == null) 
	  	  strQuantitaUltimoPrelievoG = "0";
	  else
	  	  strQuantitaUltimoPrelievoG = carbVO.getQtaUltimoPrelievo().toString();
    }
  }
  htmpl.set("gasolioConc", gConc+"");
  htmpl.set("benzinaConc", bConc+"");
  
  // 18-11-2008 - Nick - CU-GUMA-15 gestione buoni emessi.	  
  Date dataRiferimento = (Date)request.getAttribute("data_riferimento");  	  
  
  if (request.getParameter("salva")!=null)
  {
	SolmrLogger.debug(this, "-- isBuono99999 ="+isBuono99999);
	SolmrLogger.debug(this, "-- buonoVO.getDataEmissione() ="+buonoVO.getDataEmissione());
	SolmrLogger.debug(this, "-- dataRiferimento ="+dataRiferimento);
	if (isBuono99999 || buonoVO.getDataEmissione().after(dataRiferimento)) {
	  htmpl.set("readonly",SolmrConstants.HTML_READONLY+LIGHT_GREY,null);
	}  
  	
    htmpl.set("gasolioPrel", request.getParameter("gasolioPrel"));
    htmpl.set("benzinaPrel", request.getParameter("benzinaPrel"));
    htmpl.set("dataRestituzione", request.getParameter("dataRestituzione"));    
  }
  else
  {
	 SolmrLogger.debug(this, "-- isBuono99999 ="+isBuono99999);
	 SolmrLogger.debug(this, "-- buonoVO.getDataEmissione() ="+buonoVO.getDataEmissione());
	 SolmrLogger.debug(this, "-- dataRiferimento ="+dataRiferimento);
  	// 18-11-2008 - Nick - CU-GUMA-15 gestione buoni emessi.
  	if (isBuono99999) {
  		htmpl.set("readonly",SolmrConstants.HTML_READONLY+LIGHT_GREY,null);
  		htmpl.set("gasolioPrel", gConc+"");
    	htmpl.set("benzinaPrel", bConc+"");
  	}	    	  	
  	else if (buonoVO.getDataEmissione().after(dataRiferimento)) {  		
  		htmpl.set("readonly",SolmrConstants.HTML_READONLY+LIGHT_GREY,null);  		  
  		htmpl.set("gasolioPrel", strQuantitaPrelevataG);
    	htmpl.set("benzinaPrel", strQuantitaPrelevataB);        	
    }
    else { // Per le date del 2008 resta tutto come prima.  	     	  
    	htmpl.set("gasolioPrel", gConc+"");
    	htmpl.set("benzinaPrel", bConc+"");        	          
    }   
    
    htmpl.set("dataRestituzione", DateUtils.getCurrentDateString()); 
  }
  
  if (isBuono99999)
  {                  
    htmpl.newBlock("blkHiddens");        
    
    htmpl.set("blkHiddens.gasolioPrel", gConc+"");
    htmpl.set("blkHiddens.benzinaPrel", bConc+"");
  }
  else
  {
    htmpl.newBlock("blkUltimoPrelievo");          	  
    
    // 18-11-2008 - Nick - CU-GUMA-15 gestione buoni emessi.    
    SolmrLogger.debug(this, "-- buonoVO.getDataEmissione() ="+buonoVO.getDataEmissione());
    SolmrLogger.debug(this, "-- dataRiferimento ="+dataRiferimento);
    if (buonoVO.getDataEmissione().after(dataRiferimento))
  	    htmpl.set("blkUltimoPrelievo.readonly",SolmrConstants.HTML_READONLY+LIGHT_GREY,null);  	      	
  	  	  
    htmpl.set("blkUltimoPrelievo.dataUltimoPrelievoG", strDataUltimoPrelievoG);
    htmpl.set("blkUltimoPrelievo.dataUltimoPrelievoB", strDataUltimoPrelievoB);       
    htmpl.set("blkUltimoPrelievo.qtaUltimoPrelievoG", strQuantitaUltimoPrelievoG);
    htmpl.set("blkUltimoPrelievo.qtaUltimoPrelievoB", strQuantitaUltimoPrelievoB);
  }

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  HtmplUtil.setErrors(htmpl, errors, request);

  SolmrLogger.debug(this,"[restituzioneBuonoView::service] END.");
%>

<%= htmpl.text()%>
