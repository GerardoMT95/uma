<%@page import="it.csi.solmr.business.uma.UmaFacadeBean"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="it.csi.solmr.dto.profile.RuoloUtenza"%>
<%@page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@ page language="java"
    contentType="text/html"
    isErrorPage="false"
%>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="java.util.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="org.apache.commons.io.FilenameUtils"%>
<%@ page  import="java.io.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%!
  public final static String VIEW = "/ditta/view/popupAllegaFileView.jsp";
  public final static String REFRESH = "../../ditta/layout/popup_allega_file_refresh.htm";

%>

<%
  SolmrLogger.debug(this,"   BEGIN popupAllegaFileCtrl");
  
  UmaFacadeClient umaClient = new UmaFacadeClient();
  
  ValidationErrors errors = new ValidationErrors();
  Long idPadre = null;
  String chiamante = null;
  List<FileVO> vElencoFileAllegati = null;
  FileVO fileVO = null;
  Long fileSize = null;
  String funzione = null;  
  try{
	  	  
    String maxFileSize = umaClient.getParametro(SolmrConstants.PARAMETRO_FILE_SIZE);
    SolmrLogger.debug(this, "--- maxFileSize ="+maxFileSize);
    fileSize =new Long(maxFileSize);    
    
    HashMap common = null;
    HashMap hmRequest = null;
    try{
      hmRequest = multipartRequestToHashMap(request,fileSize.longValue()); 
    }
    catch(FileUploadException ex){
      errors.add("fileAllegato", new ValidationError("File con dimensioni troppo grandi : " + fileSize.toString()));
      //in caso di FileUploadException la HmRequest viene popolata solo parzialmente.
      funzione = SolmrConstants.OPERATION_CONFIRM;
    }
    
    if (Validator.isEmpty(funzione)){
      funzione = (String) getFromRequest(hmRequest, request,"funzione");
    }
    SolmrLogger.debug(this," --- funzione ="+funzione);
    if (Validator.isEmpty(funzione)){
    	SolmrLogger.debug(this," --- CASO funzione isEmpty"); 
        //svuoto common
        session.removeAttribute("common");
        common = new HashMap();
      
      	String idPadreStr = (String)getFromRequest(hmRequest, request,"idPadre");
      	SolmrLogger.debug(this," ---idPadreStr ="+idPadreStr);
      	if(!idPadreStr.isEmpty())
          idPadre = new Long ((String) getFromRequest(hmRequest, request,"idPadre"));
      
      	SolmrLogger.debug(this," -- idPadre ="+idPadre);
      	common.put("idPadre",idPadre);      
      
      	// se sono già stati salvati degli allegati e poi si torna sulla popup, recupero gli allegati
      	vElencoFileAllegati = (List<FileVO>)session.getAttribute("vElencoFileAllegati");
      	common.put("vElencoFileAllegati",vElencoFileAllegati);
      
      
      	chiamante = (String) getFromRequest(hmRequest, request,"chiamante");
      	common.put("chiamante",chiamante);            	
      	common.put("vElencoFileAllegati",vElencoFileAllegati);
      	SolmrLogger.debug(this," -- creo new FileVO");      
      	fileVO = new FileVO();
      	common.put("fileVO",fileVO);     
    }
    else{
      common = (HashMap) session.getAttribute("common");
      
      if(common != null){
        idPadre = (Long) common.get("idPadre");
        chiamante = (String) common.get("chiamante");
        fileVO = (FileVO) common.get("fileVO");
        vElencoFileAllegati = (List<FileVO>) common.get("vElencoFileAllegati");
      }
            
      SolmrLogger.debug(this," -- prendo dalla sessione FileVO");
    }    
    if (funzione != null){
    	// ------ DELETE -----------
	    if("D".equals(funzione)){	      
	      String idFile = (String) getFromRequest(hmRequest,request,"idFile");	 
	      
	      Long idFileL = new Long(idFile);
	      	      
	      // 1) Rimuovo il record sul db con id_allegato = idFile
	      SolmrLogger.debug(this," -- 1) Rimuovo il record sul db con id_allegato ="+idFileL);	      
	      umaClient.deleteAllegato(idFileL);
	      
	      // 2)Rimuovo dalla sessione il file con id_allegato = idFile
	      SolmrLogger.debug(this," -- 1) Rimuovo dalla sessione il file con id_allegato = ="+idFile);
	      SolmrLogger.debug(this," -- vElencoFileAllegati.size() prima ="+vElencoFileAllegati.size());
	      vElencoFileAllegati = (List<FileVO>)common.get("vElencoFileAllegati");
	      for(int i=0;i<vElencoFileAllegati.size();i++){
	    	if(vElencoFileAllegati.get(i).getIdAllegato().longValue() == idFileL){
	    		vElencoFileAllegati.remove(i);
	    		break;
	    	}	    	
	      }
	      SolmrLogger.debug(this," -- vElencoFileAllegati.size() dopo ="+vElencoFileAllegati.size());
	      common.put("vElencoFileAllegati", vElencoFileAllegati);
	      
	      SolmrLogger.debug(this," -- operazioni di delete effettuate");	           
	      //eseguo refresh 
	      funzione =  "R";
	      SolmrLogger.debug(this," -- funzione ="+funzione);
	    }	    
    	// ---------- REFRESH ------------------
	    if ("R".equals(funzione)){ 
	    	SolmrLogger.debug(this," -- operazione di refresh");
	    	SolmrLogger.debug(this," --  chiamante ="+chiamante);
	        //ricarico elenco e svuoto fileVO		                
            SolmrLogger.debug(this," --- Refresh, ricarico l'elenco dei file allegati");	      
	        vElencoFileAllegati = (List<FileVO>)common.get("vElencoFileAllegati");
	      
	        fileVO = new FileVO();
	        common.put("fileVO",fileVO);     
	      
	        //imposto per fare in modo che sulla chiusura ricarichi la form padre
	        request.setAttribute("reloadParent",SolmrConstants.FLAG_SI);	      
	    }
	    // ---------- CONFIRM ------------------
	    else if ("C".equals(funzione)){
	    	SolmrLogger.debug(this," --- Bisogna inserire il file su db");
	        if(fileVO == null){
	          fileVO = new FileVO();
	        }  
	        	        
	        fileVO.setDescrizione((String)getFromRequest(hmRequest, request,"descrizione"));	        	        	      
	        fileVO.setNomeFisico((String)getFromRequest(hmRequest, request,"nomeFisico"));
	        fileVO.setFileAllegato((byte[])getFromRequest(hmRequest, request,"fileAllegato"));
	
	        if (errors.size() == 0){
	          SolmrLogger.debug(this," -- validate file");          
	          errors = validateUploadFile(errors, fileVO);
	        }
	        
	        if (errors == null || errors.size() == 0){
	        	SolmrLogger.debug(this," -- non ci sono errori, si puo' proseguire con l'inserimento del file");	
	        	SolmrLogger.debug(this," -- chiamante ="+chiamante);
	           
	        	SolmrLogger.debug(this," -- Inserisco l'allegato in MONI_T_ALLEGATI");
	            
	        	DittaUMAAziendaVO dumaa = (DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
	        	Long idDittaUma = dumaa.getIdDittaUMA();
	        	SolmrLogger.debug(this, "-- idDittaUma ="+idDittaUma);
	        	fileVO.setIdDittaUma(idDittaUma);
	        	RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
	        	fileVO.setIdUtenteInserimento(ruoloUtenza.getIdUtente());
	            Long idAllegato = umaClient.inserisciAllegati(fileVO);
	        	
	            SolmrLogger.debug(this," -- idAllegato inserito ="+idAllegato);
	            fileVO.setIdAllegato(idAllegato);
	            // salvo in sessione l'elenco dei file salvati su DB_ALLEGATO_UMA	            
	             List<FileVO> fileList = (List<FileVO>)common.get("vElencoFileAllegati");
	             if(fileList != null)
	               fileList.add(fileVO);
	             else{
	               fileList = new ArrayList<FileVO>();
	               fileList.add(fileVO);
	             }
	             common.put("vElencoFileAllegati",fileList);	          
	             SolmrLogger.debug(this," -- file Inserito");
	             //ricarico la pagina in refresh
	             response.sendRedirect(REFRESH);
	             return;
	        }
	
	    }
    }

    session.setAttribute("common", common);
    session.setAttribute("vElencoFileAllegati", common.get("vElencoFileAllegati"));
    
    
    //in request per view
    request.setAttribute("errors",errors);
    request.setAttribute("vElencoFileAllegati",vElencoFileAllegati);
    if(Validator.isEmpty(chiamante)){
    	if(common != null)            
            chiamante = (String) common.get("chiamante");
    }
    SolmrLogger.debug(this, "-- chiamante in request = "+chiamante);
    request.setAttribute("chiamante",chiamante);    
    request.setAttribute("fileVO",fileVO);
   
  
  }
  catch(Exception e){
	SolmrLogger.error(this," -- Problemi in allegaFileCtrl :"+e.getMessage());
    //if (e instanceof AgriException){
      setError(request, e.getMessage());
    /*}
    else{
      setError(request, (String)SolmrConstants.get("GENERIC_SYSTEM_EXCEPTION"));
    }*/
  }
  finally{
    SolmrLogger.debug(this,"   END popupAllegaFileCtrl");
  }
  

  %><jsp:forward page="<%= VIEW %>"/>
<%!

private ValidationErrors validateUploadFile(ValidationErrors errors, FileVO fileVO) throws Exception{
	SolmrLogger.debug(this, "BEGIN validateUploadFile");
	
	String note = fileVO.getDescrizione();
	SolmrLogger.debug(this, "-- note ="+note);
	
	if(fileVO.getFileAllegato() == null || fileVO.getFileAllegato().length == 0) {
		errors.add("fileAllegato",new ValidationError("Campo obbligatorio"));
	}
	if (Validator.isNotEmpty(fileVO.getFileAllegato()) && fileVO.getFileAllegato().length > 5 * 1024 * 1024) {
		errors.add("fileAllegato", new ValidationError("La dimensione massima del file è : " + 5));
	}
	
	SolmrLogger.debug(this, "END validateUploadFile");
	return errors;	
}

 private void setError(HttpServletRequest request, String msg){
	SolmrLogger.debug(this, "\n\n\n\n\n\n\n\n\n\n\nmsg="+msg+"\n\n\n\n\n\n\n\n");
    ValidationErrors errors = new ValidationErrors();
    errors.add("error", new ValidationError(msg));
    request.setAttribute("errors", errors);
  }

  private Object getFromRequest(HashMap hmRequest, HttpServletRequest request,String param){
    if (hmRequest != null) 
    {
      return hmRequest.get(param);
    }
    else
    {
      return request.getParameter(param);
    }   
  }
  
  
  private HashMap multipartRequestToHashMap(HttpServletRequest request, long maxFileSize) throws FileUploadException{
	SolmrLogger.debug(this,"   BEGIN multipartRequestToHashMap");
    boolean isMultipart = ServletFileUpload.isMultipartContent(request);
    HashMap hmRequest = null;    
    if(isMultipart)
    { 
      hmRequest = new HashMap();
      
      // Create a factory for disk-based file items
      DiskFileItemFactory factory = new DiskFileItemFactory();

      // Create a new file upload handler
      ServletFileUpload upload = new ServletFileUpload(factory);
      upload.setFileSizeMax(maxFileSize * 1024 * 1024);      

      // Parse the request
      List items = upload.parseRequest(request);
      
      // Process the uploaded items
      Iterator iter = items.iterator();
      while (iter.hasNext()) 
      {
        FileItem item = (FileItem) iter.next();
        
        if (item.isFormField())
        {
          hmRequest.put(item.getFieldName(), item.getString());
        }
        else
        {
          String fieldName = item.getFieldName();
          String fileName = item.getName();
        
          String contentType = item.getContentType();
          boolean isInMemory = item.isInMemory();
          long sizeInBytes = item.getSize();
          byte[] data = item.get();

          hmRequest.put("nomeFisico", FilenameUtils.getName(fileName));
          hmRequest.put("fileAllegato", data);
        
          SolmrLogger.debug(this, " -- fieldName " + fieldName);
          SolmrLogger.debug(this, " -- FilenameUtils.getName(fileName) " + FilenameUtils.getName(fileName));
          SolmrLogger.debug(this, " -- contentType " + contentType);
          SolmrLogger.debug(this, " -- isInMemory " + isInMemory);
          SolmrLogger.debug(this, " -- sizeInBytes " + sizeInBytes);
        }
      }
    }
    SolmrLogger.debug(this,"   END multipartRequestToHashMap");
    return hmRequest;
  }%>