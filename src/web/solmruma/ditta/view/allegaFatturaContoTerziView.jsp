<%@page import="it.csi.solmr.dto.uma.AnnoCampagnaVO"%>
<%@ page language="java"
  contentType="text/html"
  isErrorPage="false"
%>

<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="it.csi.solmr.dto.uma.FatturaContoTerziVO"%>

<%!public static final String  LAYOUT  = "/ditta/layout/allegaFatturaContoTerzi.htm";%>

<%
  SolmrLogger.debug(this, "  BEGIN allegaFatturaContoTerziView");
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
  
  %>
  <%@include file="/include/menu.inc"%>
<%
  

  htmpl.set("OPERATION_CONFIRM",SolmrConstants.OPERATION_CONFIRM);
  htmpl.set("OPERATION_DELETE",SolmrConstants.OPERATION_DELETE);
  
 // SolmrLogger.debug(this, " -- chiamante ="+(String) request.getAttribute("chiamante"));
 // htmpl.set("chiamante",(String) request.getAttribute("chiamante"));
    
  //imposto per fare in modo che sulla chiusura ricarichi la form padre
 // String reloadParent=(String)request.getAttribute("reloadParent");
 // SolmrLogger.debug(this, " -- reloadParent ="+reloadParent);
  
 /* if(reloadParent != null && SolmrConstants.FLAG_SI.equals(reloadParent)){
    htmpl.newBlock("blkReloadParent");
  }*/
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  
  // Recuperare i dati indicati nei campi, nel caso di ricaricamneto pagina per errore
  SolmrLogger.debug(this, " - recupero FatturaContoTerziVO");
  FatturaContoTerziVO fatturaContoTerziCampi = (FatturaContoTerziVO) request.getAttribute("fatturaContoTerziVO");
  
  if(fatturaContoTerziCampi != null){
	  htmpl.set("numeroFatturaIns", fatturaContoTerziCampi.getNumeroFattura());
	  htmpl.set("dataFatturaIns", fatturaContoTerziCampi.getDataFatturaStr());
	  htmpl.set("cuaaDestFatturaIns", fatturaContoTerziCampi.getCuaaDestFattura());
	  htmpl.set("denomDestFatturaIns", fatturaContoTerziCampi.getDenomDestFattura());	  
	  htmpl.set("importoIns", fatturaContoTerziCampi.getImportoStr());	  	
	  htmpl.set("noteIns", fatturaContoTerziCampi.getNote());
  }
  
 
  // Combo Anno Campagna
  String annoCampagnaSel = (String)request.getAttribute("annoCampagna");
  SolmrLogger.debug(this, "-- annoCampagnaSel ="+annoCampagnaSel);
  Vector<AnnoCampagnaVO> anniCampagnaVect = (Vector<AnnoCampagnaVO>)request.getAttribute("anniCampagnaVect");
  if(anniCampagnaVect != null && anniCampagnaVect.size() >0){
	  for(int i=0;i<anniCampagnaVect.size();i++){
	  	AnnoCampagnaVO elemAnno = (AnnoCampagnaVO)anniCampagnaVect.get(i);
	  	htmpl.newBlock("blkComboAnno");	  		  		
	 	htmpl.set("blkComboAnno.idAnnoCampagna",""+elemAnno.getAnnoCampagna());
	 	htmpl.set("blkComboAnno.annoCampagnaDesc",""+elemAnno.getAnnoCampagna());
	 		 		 	
	 	if(annoCampagnaSel != null && !annoCampagnaSel.isEmpty()){
	   		if (annoCampagnaSel.equalsIgnoreCase(elemAnno.getAnnoCampagna())){
	   			htmpl.set("blkComboAnno.annoCampagnaSel","selected");
	   		}
	 	}
	 	// Seleziono anno corrente - 1
	 	else{
	 		SolmrLogger.debug(this, "-- Seleziono anno corrente - 1");
	 		Calendar prevYear = Calendar.getInstance();
	 	    prevYear.add(Calendar.YEAR, -1);	 	    
	 		int annoPrec =  prevYear.get(Calendar.YEAR); 
        	SolmrLogger.debug(this, "-- annoPrec ="+annoPrec);
        	String annoPrecStr = new Integer(annoPrec).toString();
        	if (annoPrecStr.equalsIgnoreCase(elemAnno.getAnnoCampagna())){
	   			htmpl.set("blkComboAnno.annoCampagnaSel","selected");
	   		}
	 	}
	  }
  }
  
  // Visualizzo i file salvati sul db
  SolmrLogger.debug(this, " -- recupero l'elenco dei file");
  List<FatturaContoTerziVO> vElencoFatturaContoTerziVO = (List<FatturaContoTerziVO>) request.getAttribute("vElencoFatturaContoTerziVO");
  if (vElencoFatturaContoTerziVO != null &&  vElencoFatturaContoTerziVO.size() >0){
	SolmrLogger.debug(this, " -- ci sono dei file da visualizzare in elenco, quanti ="+vElencoFatturaContoTerziVO.size());
    htmpl.newBlock("fileAllegatiBlk");

    for ( int i=0; i<vElencoFatturaContoTerziVO.size(); i++){
      FatturaContoTerziVO fatturaContoTerziVO = (FatturaContoTerziVO) vElencoFatturaContoTerziVO.get(i);
      htmpl.newBlock("fileAllegatiBlk.fileBlk");
      SolmrLogger.debug(this, " -- idAllegato ="+fatturaContoTerziVO.getIdFatturaContoTerzi());
      
      if(fatturaContoTerziVO.getIdFatturaContoTerzi() != null){
        htmpl.set("fileAllegatiBlk.fileBlk.idFatturaContoTerzi",fatturaContoTerziVO.getIdFatturaContoTerzi().toString());
      }
      
      // TODO
      // Settare nella combo Anno campagna
            
      if(fatturaContoTerziVO.getAnnoCampagna() != null)
      	htmpl.set("fileAllegatiBlk.fileBlk.anno",fatturaContoTerziVO.getAnnoCampagna().toString());
      
      if(fatturaContoTerziVO.getNumeroFattura() != null)
      	htmpl.set("fileAllegatiBlk.fileBlk.numFattura",fatturaContoTerziVO.getNumeroFattura().toString());
     
      if(fatturaContoTerziVO.getDataFattura() != null){    	     	
    	String pattern = "dd/MM/yyyy";
    	DateFormat df = new SimpleDateFormat(pattern);    	
    	String strDataFattura = df.format(fatturaContoTerziVO.getDataFattura());
    	htmpl.set("fileAllegatiBlk.fileBlk.dataFattura", strDataFattura);//DateUtils.formatDateTimeNotNull(fatturaContoTerziVO.getDataFattura()) );
      }	  
      
      htmpl.set("fileAllegatiBlk.fileBlk.cuaaDest",fatturaContoTerziVO.getCuaaDestFattura());
      htmpl.set("fileAllegatiBlk.fileBlk.denomDest",fatturaContoTerziVO.getDenomDestFattura());
      
      if(fatturaContoTerziVO.getImporto() != null)
        htmpl.set("fileAllegatiBlk.fileBlk.importo",fatturaContoTerziVO.getImporto().toString());
            
      htmpl.set("fileAllegatiBlk.fileBlk.nomeFisico", fatturaContoTerziVO.getNomeFisico());
      htmpl.set("fileAllegatiBlk.fileBlk.note",fatturaContoTerziVO.getNote());
      
    }
    htmpl.newBlock("blkPulsanti");
  }
  else{
    SolmrLogger.debug(this, " -- NON ci sono dei file da visualizzare in elenco");
  }
 
  // TODO : se l'utente può modificare : (rimuovi e aggiunti), altrimenti, tutti i campi disabilitati, a parte la combo 'Anno campagna'
  
  HtmplUtil.setErrors(htmpl, errors, request);
  
  SolmrLogger.debug(this, "  END allegaFatturaContoTerziView");
%>
<%=htmpl.text()%>