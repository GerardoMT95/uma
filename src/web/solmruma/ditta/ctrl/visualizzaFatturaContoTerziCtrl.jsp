<%@page import="it.csi.solmr.dto.uma.FatturaContoTerziVO"%>
<%@page language="java" contentType="text/html" isErrorPage="false"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.uma.FileVO"%>
<%
  SolmrLogger.debug(this, "   BEGIN visualizzaFatturaContoTerziCtrl");

  ValidationErrors errors = new ValidationErrors();

  try{
	UmaFacadeClient umaClient = new UmaFacadeClient();
    
    Long idFatturaContoTerzi = new Long(request.getParameter("idFatturaContoTerzi"));
    
    //Lettura dati
    SolmrLogger.debug(this, "-- ricerca del file con ID_FATTURA_CONTO_TERZI ="+idFatturaContoTerzi);
   
    
    FatturaContoTerziVO fatturaContoTerziVO = umaClient.getAllegatoFatturaContoTerzi(idFatturaContoTerzi);
    if(fatturaContoTerziVO != null){
      SolmrLogger.debug(this," --- è stato trovato il file da visualizzare");

	  response.resetBuffer();
	  response.setContentType("application/x-download");
	  /*
	   * Il filename viene encodato per evitare vulnerabilità di response splitting
	   */
	  response.setHeader("Content-disposition", "attachment;filename=" + URLEncoder.encode(fatturaContoTerziVO.getNomeFisico(), "UTF-8"));   	  
	            
	  byte[] b = fatturaContoTerziVO.getAllegato();
	            
	  if (b != null && b.length > 0)
	  {
	    SolmrLogger.debug(this," -- ci sono dei byte");
	    response.getOutputStream().write(b);
	  }
	  response.getOutputStream().flush();
	  response.getOutputStream().close();
	
	  SolmrLogger.debug(this, "   END visualizzaFatturaContoTerziCtrl");
    }
             
    return;
  }
  catch (Exception e){
	SolmrLogger.error(this," -- Eccezione in visualizzaFatturaContoTerziCtrl :"+e.getMessage());    
    setError(request, e.getMessage());    
  }
  finally{
	  SolmrLogger.debug(this,"   END visualizzaFatturaContoTerziCtrl");
  }
    
%>
<%!

 private void setError(HttpServletRequest request, String msg){
	SolmrLogger.info(this, "\n\n\n\n\n\n\n\n\n\n\nmsg="+msg+"\n\n\n\n\n\n\n\n");
    ValidationErrors errors = new ValidationErrors();
    errors.add("error", new ValidationError(msg));
    request.setAttribute("errors", errors);
  }
  %>