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
  SolmrLogger.debug(this, "   BEGIN visualizzaFileAllegatoCtrl");

  ValidationErrors errors = new ValidationErrors();

  try{
	UmaFacadeClient umaClient = new UmaFacadeClient();
    
    Long idFile = new Long(request.getParameter("idFile"));
    
    //Lettura dati
    SolmrLogger.debug(this, "-- ricerca del file con idAllegato ="+idFile);
   
    
    FileVO fileVO = umaClient.getFileAllegato(idFile);
    if(fileVO !=null){
      SolmrLogger.debug(this," --- è stato trovato il file da visualizzare");

	  response.resetBuffer();
	  response.setContentType("application/x-download");
	  /*
	   * Il filename viene encodato per evitare vulnerabilità di response splitting
	   */
	  response.setHeader("Content-disposition", "attachment;filename=" + URLEncoder.encode(fileVO.getNomeFisico(), "UTF-8"));   	  
	            
	  byte[] b = fileVO.getFileAllegato();
	            
	  if (b != null && b.length > 0)
	  {
	    SolmrLogger.debug(this," -- ci sono dei byte");
	    response.getOutputStream().write(b);
	  }
	  response.getOutputStream().flush();
	  response.getOutputStream().close();
	
	  SolmrLogger.debug(this, "   END visualizzaFileAllegatoCtrl");
    }
             
    return;
  }
  catch (Exception e){
	  SolmrLogger.error(this," -- Eccezione in visualizzaFileAllegatoCtrl :"+e.getMessage());    
    setError(request, e.getMessage());    
  }
  finally{
	  SolmrLogger.debug(this,"   END visualizzaFileAllegatoCtrl");
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