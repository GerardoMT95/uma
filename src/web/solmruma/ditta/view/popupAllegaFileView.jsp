<%@ page language="java"
  contentType="text/html"
  isErrorPage="false"
%>

<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.FileVO"%>

<%!public static final String  LAYOUT  = "/ditta/layout/popup_allega_file.htm";%>

<%
  SolmrLogger.debug(this, "  BEGIN popupAllegaFileView");
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
  //LayoutWriter lw = new LayoutWriter(htmpl, request);  

  htmpl.set("OPERATION_CONFIRM",SolmrConstants.OPERATION_CONFIRM);
  htmpl.set("OPERATION_DELETE",SolmrConstants.OPERATION_DELETE);
  
  SolmrLogger.debug(this, " -- chiamante ="+(String) request.getAttribute("chiamante"));
  htmpl.set("chiamante",(String) request.getAttribute("chiamante"));
    
  //imposto per fare in modo che sulla chiusura ricarichi la form padre
  String reloadParent=(String)request.getAttribute("reloadParent");
  SolmrLogger.debug(this, " -- reloadParent ="+reloadParent);
  
  if(reloadParent != null && SolmrConstants.FLAG_SI.equals(reloadParent)){
    htmpl.newBlock("blkReloadParent");
  }
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  
  SolmrLogger.debug(this, " - recupero fileVO");
  FileVO fileVO = (FileVO) request.getAttribute("fileVO");
  
  /*if(fileVO != null){
	SolmrLogger.debug(this, " - nomeLogico ="+fileVO.getNomeLogico());  
    htmpl.set("nomeLogico",fileVO.getNomeLogico());
  }*/
  
  // Visualizzo i file salvati sul db
  SolmrLogger.debug(this, " -- recupero l'elenco dei file");
  List<FileVO> vElencoFileAllegati = (List<FileVO>) request.getAttribute("vElencoFileAllegati");
  if (vElencoFileAllegati != null &&  vElencoFileAllegati.size() >0){
	SolmrLogger.debug(this, " -- ci sono dei file da visualizzare in elenco, quanti ="+vElencoFileAllegati.size());
    htmpl.newBlock("fileAllegatiBlk");

    for ( int i=0; i<vElencoFileAllegati.size(); i++){
      fileVO = (FileVO) vElencoFileAllegati.get(i);
      htmpl.newBlock("fileAllegatiBlk.fileBlk");
      SolmrLogger.debug(this, " -- idAllegato ="+fileVO.getIdAllegato());
      
      if(fileVO.getIdAllegato() != null){
        htmpl.set("fileAllegatiBlk.fileBlk.idFile",fileVO.getIdAllegato().toString());
      }
      //htmpl.set("fileAllegatiBlk.fileBlk.nomeLogico", fileVO.getNomeLogico());
      
      if(fileVO.getNomeFisico() != null){
        htmpl.set("fileAllegatiBlk.fileBlk.nome",fileVO.getNomeFisico());
      }
      if(fileVO.getDescrizione() != null)
    	htmpl.set("fileAllegatiBlk.fileBlk.descrizione", fileVO.getDescrizione());
    }
  }
  else{
    SolmrLogger.debug(this, " -- NON ci sono dei file da visualizzare in elenco");
  }
 
  HtmplUtil.setErrors(htmpl, errors, request);
  
  SolmrLogger.debug(this, "  END popupAllegaFileView");
%>
<%= htmpl.text()%>