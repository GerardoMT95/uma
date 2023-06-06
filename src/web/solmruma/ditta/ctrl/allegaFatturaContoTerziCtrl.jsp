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
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormatSymbols" %>
<%@ page import="java.util.Locale" %>
<%@ page import="org.apache.commons.lang3.math.NumberUtils" %>
<%!
  public final static String VIEW = "/ditta/view/allegaFatturaContoTerziView.jsp";
  //public final static String REFRESH = "../../ditta/layout/allegaFatturaContoTerziRefresh.htm";


	String iridePageName = "allegaFatturaContoTerziCtrl.jsp";
%>
<%@include file="/include/autorizzazione.inc"%>
<%

  SolmrLogger.debug(this,"   BEGIN allegaFatturaContoTerziCtrl");
  
  UmaFacadeClient umaClient = new UmaFacadeClient();
  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  
  ValidationErrors errors = new ValidationErrors();
  Long idPadre = null;
  String chiamante = null; 
  Long fileSize = null;
  String funzione = null;  
  try{
	  
	// Valori per combo Anno campagna
    SolmrLogger.debug(this, "-- Ricerco i valori per la combo Anno campagna");
    Vector<AnnoCampagnaVO> anniCampagnaVect = umaClient.findAnniCampLavPerCt(dittaUMAAziendaVO.getIdDittaUMA());
    request.setAttribute("anniCampagnaVect", anniCampagnaVect);
    
        	  
    String maxFileSize = umaClient.getParametro(SolmrConstants.PARAMETRO_FILE_SIZE);
    SolmrLogger.debug(this, "--- maxFileSize ="+maxFileSize);
    fileSize =new Long(maxFileSize);    
    
    HashMap hmRequest = null;
    try{
      hmRequest = multipartRequestToHashMap(request,fileSize.longValue()); 
    }
    catch(FileUploadException ex){
      errors.add("fileAllegato", new ValidationError("File con dimensioni troppo grandi : " + fileSize.toString()));
      //in caso di FileUploadException la HmRequest viene popolata solo parzialmente.
      funzione = SolmrConstants.OPERATION_CONFIRM;
    }
    
    
    String annoCampagnaSel = (String) getFromRequest(hmRequest, request,"annoCampagna");
    if(annoCampagnaSel != null && !annoCampagnaSel.isEmpty()){
    	SolmrLogger.debug(this, "-- Setto in request annoCampagna ="+annoCampagnaSel);  
		request.setAttribute("annoCampagna", annoCampagnaSel);
    }
	  
    
    if (Validator.isEmpty(funzione)){
      funzione = (String) getFromRequest(hmRequest, request,"funzione");
    }
    SolmrLogger.debug(this," --- funzione ="+funzione);
    if (Validator.isEmpty(funzione)){
    	SolmrLogger.debug(this," --- CASO funzione isEmpty"); 
    	
    	String idFatturaContoTerziDaRimuovere = request.getParameter("idFatturaContoTerziDaRimuovere");
    	SolmrLogger.debug(this, "-- idFatturaContoTerziDaRimuovere ="+idFatturaContoTerziDaRimuovere);
    	// ------ DELETE -----------
	    if(idFatturaContoTerziDaRimuovere != null && !idFatturaContoTerziDaRimuovere.isEmpty()){
	      SolmrLogger.debug(this, "-- Caso di DELETE");	       	      	
    		  
    	  umaClient.deleteFatturaContoTerziById(Long.parseLong(idFatturaContoTerziDaRimuovere));	      	      	      
    	  SolmrLogger.debug(this," -- operazioni di delete effettuate");	           
    	      
    	  // Eseguo Refresh dei dati 
    	  annoCampagnaSel = request.getParameter("annoCampagnaDaVisualizzare");
    	  SolmrLogger.debug(this, "-- annoCampagnaSel ="+annoCampagnaSel);
          request.setAttribute("annoCampagna", annoCampagnaSel);
    	    	
          // Ricerco i record su db_fattura_conto_terzi
      	  SolmrLogger.debug(this, "-- Ricerco i record su db_fattura_conto_terzi con annoCampagnaSel ="+annoCampagnaSel);
      	  List<FatturaContoTerziVO> fatturaContoTerziList =umaClient.findFattureContoTerziByAnnoIdDittaUma(Long.parseLong(annoCampagnaSel), dittaUMAAziendaVO.getIdDittaUMA());
          request.setAttribute("vElencoFatturaContoTerziVO", fatturaContoTerziList); 
          session.setAttribute("vElencoFatturaContoTerziVO", fatturaContoTerziList);
    	      	                     	 
	    }
	    // I campi con i dati da inserire devono comparire tutti vuoti
      	request.setAttribute("fatturaContoTerziVO", null);  
    }       
    if (funzione != null){
    	// ---- RICARICA LA PAGINA DOPO LA SELEZIONE DELLA COMBO ANNO CAMPAGNA 
    	if("RICARICA".equals(funzione)){
    		SolmrLogger.debug(this, "-- CASO RICARICA");	
        	try{        	
        		SolmrLogger.debug(this, " ----------- Ricerca delle fattura dell'anno selezionato");
        		
        		SolmrLogger.debug(this, "-- anno campagna sel ="+annoCampagnaSel);        		
        		List<FatturaContoTerziVO> fatturaContoTerziList = umaClient.findFattureContoTerziByAnnoIdDittaUma(Long.parseLong(annoCampagnaSel), dittaUMAAziendaVO.getIdDittaUMA());
        		request.setAttribute("vElencoFatturaContoTerziVO", fatturaContoTerziList); 
            	session.setAttribute("vElencoFatturaContoTerziVO", fatturaContoTerziList);        		
            	
            	// TODO : settare in request.setAttribute("fatturaContoTerziVO", ); i campi valorizzati per non perderli  
        		        		
        		%>
        		<jsp:forward page="<%= VIEW %>"/>
        		<%        		
        		return;
        	
	        }
	        catch(Exception e){
	          SolmrLogger.error(this, "-- Exception ="+e.getMessage());
	          request.setAttribute("errorMessage",e.getMessage());
	  			%>
	  				<jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
	  			<%
	  		  return;
	        }
    	}   
	    // ---------- CONFIRM ------------------
	    else if ("C".equals(funzione)){
	    	SolmrLogger.debug(this," --- Bisogna inserire il record su DB_FATTURA_CONTOTERZI");
	    	
	    	annoCampagnaSel = (String) getFromRequest(hmRequest, request,"annoCampagna");
	    	SolmrLogger.debug(this, "-- annoCampagnaSel ="+annoCampagnaSel);
    		request.setAttribute("annoCampagna", annoCampagnaSel);
	    		    		    		    		        
	        FatturaContoTerziVO fatturaContoTerziVO = new FatturaContoTerziVO();
	          
	        	        
	        fatturaContoTerziVO.setAnnoCampagna(Long.parseLong((String)getFromRequest(hmRequest, request,"annoCampagna")));	
	        
	        fatturaContoTerziVO.setNomeFisico((String)getFromRequest(hmRequest, request,"nomeFisico"));
	        
	        String numFattura = (String)getFromRequest(hmRequest, request,"numeroFattura");
	        fatturaContoTerziVO.setNumeroFattura(numFattura);
	        
	        fatturaContoTerziVO.setDataFatturaStr((String)getFromRequest(hmRequest, request,"dataFattura"));
	        
	        fatturaContoTerziVO.setCuaaDestFattura((String)getFromRequest(hmRequest, request,"cuaaDestFattura"));
	        fatturaContoTerziVO.setDenomDestFattura((String)getFromRequest(hmRequest, request,"denomDestFattura"));
	        
	        fatturaContoTerziVO.setImportoStr((String)getFromRequest(hmRequest, request,"importo"));
	        	        
	        fatturaContoTerziVO.setAllegato((byte[])getFromRequest(hmRequest, request,"fileAllegato"));
	        
	        fatturaContoTerziVO.setNote((String)getFromRequest(hmRequest, request,"note"));
	
	        if (errors.size() == 0){
	          SolmrLogger.debug(this," -- validate ");          
	          errors = validateUploadFile(errors, fatturaContoTerziVO, request);
	        }
	        
	        if (errors == null || errors.size() == 0){
	        	SolmrLogger.debug(this," -- non ci sono errori, si puo' proseguire con l'inserimento del file");		        	
	           
	        	SolmrLogger.debug(this," -- Inserisco l'allegato in DB_FATTURA_CONTOTERZI");
	            
	        	DittaUMAAziendaVO dumaa = (DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
	        	Long idDittaUma = dumaa.getIdDittaUMA();
	        	SolmrLogger.debug(this, "-- idDittaUma ="+idDittaUma);
	        	fatturaContoTerziVO.setIdDittaUma(idDittaUma);
	        	RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
	        	fatturaContoTerziVO.setExtIdUtenteInserimento(ruoloUtenza.getIdUtente());
	        	fatturaContoTerziVO.setDataInserimento(new Date());
	        	
	        	// La data ha il formato corretto, posso settarla nel VO
	        	String dataFattura = (String)getFromRequest(hmRequest, request,"dataFattura");
		        if(dataFattura != null && !dataFattura.isEmpty()){
		        	fatturaContoTerziVO.setDataFattura(UmaBaseVO.parseDate(dataFattura));
		        }		        		        
		        
	            Long idFatturaAllegata = umaClient.inserisciFatturaContoTerzi(fatturaContoTerziVO);	            	            
	            SolmrLogger.debug(this," -- ID_FATTURA_CONTO_TERZI inserito ="+idFatturaAllegata);
	            fatturaContoTerziVO.setIdFatturaContoTerzi(idFatturaAllegata);
	            	
		        // Eseguo Refresh dei dati 
		  	    annoCampagnaSel = (String) getFromRequest(hmRequest, request,"annoCampagna");
		      	request.setAttribute("annoCampagna", annoCampagnaSel);
	  	    	
	      	    // Ricerco i record su db_fattura_conto_terzi
	    	    SolmrLogger.debug(this, "-- Ricerco i record su db_fattura_conto_terzi con annoCampagnaSel ="+annoCampagnaSel);
	    	    List<FatturaContoTerziVO> fatturaContoTerziList = umaClient.findFattureContoTerziByAnnoIdDittaUma(Long.parseLong(annoCampagnaSel), dittaUMAAziendaVO.getIdDittaUMA());
	            request.setAttribute("vElencoFatturaContoTerziVO", fatturaContoTerziList); 
	            session.setAttribute("vElencoFatturaContoTerziVO", fatturaContoTerziList);
	            
	             //ricarico la pagina in refresh
	             //response.sendRedirect(REFRESH);
	             //return;
	        }
	        // Memorizzo i valori indicati in modo da visualizzarli di nuovo dopo la segnalazione dell'errore
	        else{	        	
		        request.setAttribute("fatturaContoTerziVO", fatturaContoTerziVO); 
		        
		        annoCampagnaSel = (String) getFromRequest(hmRequest, request,"annoCampagna");
	    		request.setAttribute("annoCampagna", annoCampagnaSel);
		    	
	    		// Ricerco i record su db_fattura_conto_terzi
	  	      	SolmrLogger.debug(this, "-- Ricerco i record su db_fattura_conto_terzi con annoCampagnaSel ="+annoCampagnaSel);
	  	      	List<FatturaContoTerziVO> fatturaContoTerziList =umaClient.findFattureContoTerziByAnnoIdDittaUma(Long.parseLong(annoCampagnaSel), dittaUMAAziendaVO.getIdDittaUMA());
	            request.setAttribute("vElencoFatturaContoTerziVO", fatturaContoTerziList); 
	            session.setAttribute("vElencoFatturaContoTerziVO", fatturaContoTerziList);
	        }
	
	    }
    }
    //in request per view
    request.setAttribute("errors",errors);        
  }
  catch(Exception e){
	SolmrLogger.error(this," -- Problemi in allegaFatturaContoTerziCtrl :"+e.getMessage());
    //if (e instanceof AgriException){
      setError(request, e.getMessage());
    /*}
    else{
      setError(request, (String)SolmrConstants.get("GENERIC_SYSTEM_EXCEPTION"));
    }*/
  }
  finally{
    SolmrLogger.debug(this,"   END allegaFatturaContoTerziCtrl");
  }
  

  %><jsp:forward page="<%= VIEW %>"/>
<%!private ValidationErrors validateUploadFile(ValidationErrors errors,
			FatturaContoTerziVO fattura, HttpServletRequest request)
			throws Exception {
		SolmrLogger.debug(this, "BEGIN validateUploadFile");

		// Controllo campi obbligatori
		if (fattura.getAllegato() == null || fattura.getAllegato().length == 0) {
			errors.add("fileAllegato", new ValidationError("Campo obbligatorio"));
		}

		// Controllo dimensione massimna dell'allegato
		if (Validator.isNotEmpty(fattura.getAllegato()) && fattura.getAllegato().length > 5 * 1024 * 1024) {
			errors.add("fileAllegato", new ValidationError("La dimensione massima del file è : " + 5));
		}

		// Controllo dimensione massima note (3000)
		if (Validator.isNotEmpty(fattura.getNote()) && fattura.getNote().trim().length() > 3000) {
			errors.add("note",new ValidationError("Nelle note e' possibile inserire al massimo 3000 caratteri"));
		}

		// Formato della Data fattura		
		SolmrLogger.debug(this, " --  dataFatturaStr ="+fattura.getDataFatturaStr());
		if (fattura.getDataFatturaStr() != null && !fattura.getDataFatturaStr().isEmpty()) {			
			if (!Validator.isDate(fattura.getDataFatturaStr())) {
				errors.add("dataFattura",new ValidationError("Data non valida"));
			}
		}

		// Formato importo : numerico e max due decimali dopo la virgola ?		
		if (fattura.getImportoStr() != null && !fattura.getImportoStr().isEmpty()) {						
			SolmrLogger.debug(this, " --  importoStr ="+fattura.getImportoStr());			
			try{
        		BigDecimal importo = new BigDecimal(fattura.getImportoStr().replace(',','.'));				
        		SolmrLogger.debug(this, " -- importo = "+importo);
				if(!Validator.validateDoubleDigit(fattura.getImportoStr(),10,2)){
					errors.add("importo",new ValidationError("Il valore può avere al massimo 10 cifre intere e 2 decimali"));
				}

			}
			catch(Exception ex){
				errors.add("importo",new ValidationError("Campo non numerico"));
			}
									
			/*if(!Validator.isNumericInteger(fattura.getImportoStr())){
				errors.add("importo",new ValidationError("Formato importo non valido"));
			}*/
		}
		
		// Lunghezza numero fattura
		if(fattura.getNumeroFattura() != null){
			if(fattura.getNumeroFattura().trim().length() > 30){
				errors.add("numeroFattura", new ValidationError("Il valore può avere al massimo 30 caratteri"));
			}
		}

		SolmrLogger.debug(this, "END validateUploadFile");
		return errors;
	}

	private void setError(HttpServletRequest request, String msg) {
		SolmrLogger.debug(this, "\n\n\n\n\n\n\n\n\n\n\nmsg=" + msg
				+ "\n\n\n\n\n\n\n\n");
		ValidationErrors errors = new ValidationErrors();
		errors.add("error", new ValidationError(msg));
		request.setAttribute("errors", errors);
	}

	private Object getFromRequest(HashMap hmRequest,
			HttpServletRequest request, String param) {
		if (hmRequest != null) {
			return hmRequest.get(param);
		} else {
			return request.getParameter(param);
		}
	}

	private HashMap multipartRequestToHashMap(HttpServletRequest request,
			long maxFileSize) throws FileUploadException {
		SolmrLogger.debug(this, "   BEGIN multipartRequestToHashMap");
		boolean isMultipart = ServletFileUpload.isMultipartContent(request);
		HashMap hmRequest = null;
		if (isMultipart) {
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
			while (iter.hasNext()) {
				FileItem item = (FileItem) iter.next();

				if (item.isFormField()) {
					hmRequest.put(item.getFieldName(), item.getString());
				} else {
					String fieldName = item.getFieldName();
					String fileName = item.getName();

					String contentType = item.getContentType();
					boolean isInMemory = item.isInMemory();
					long sizeInBytes = item.getSize();
					byte[] data = item.get();

					hmRequest
							.put("nomeFisico", FilenameUtils.getName(fileName));
					hmRequest.put("fileAllegato", data);

					SolmrLogger.debug(this, " -- fieldName " + fieldName);
					// SolmrLogger.debug(this, " -- FilenameUtils.getName(fileName) " + FilenameUtils.getName(fileName));
					SolmrLogger.debug(this, " -- contentType " + contentType);
					SolmrLogger.debug(this, " -- isInMemory " + isInMemory);
					SolmrLogger.debug(this, " -- sizeInBytes " + sizeInBytes);
				}
			}
		}
		SolmrLogger.debug(this, "   END multipartRequestToHashMap");
		return hmRequest;
	}

	public BigDecimal parseBigDecimal(String value) {
		  BigDecimal result = null;

		  if (value != null) {
			  value = value.replace(',', '.');

			  if (org.apache.commons.lang3.math.NumberUtils.isNumber(value)) {
			    result = NumberUtils.createBigDecimal(value);
			  }
		  }

		  return result;
	  }%>