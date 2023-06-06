<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@page import="java.math.BigDecimal"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String iridePageName = "modificaLavConsorziCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  String viewUrl="/ditta/view/modificaLavConsorziView.jsp";
  String elencoHtm="../../ditta/layout/elencoLavConsorzi.htm";
  String elencoBisHtm="../../ditta/layout/elencoLavConsorziBis.htm";
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  UmaFacadeClient umaFacadeClient=new UmaFacadeClient();
  AnnoCampagnaVO annoCampagnaVO = (AnnoCampagnaVO)session.getAttribute("annoCampagna");
  HashMap hashCommon = (HashMap)session.getAttribute("hashCommon");
  if(hashCommon == null){
  	hashCommon = new HashMap();
  }
  if (request.getParameter("salva.x")!=null){
    SolmrLogger.debug(this,"modificaLavConsorziCtrl - salvataggio");
    Vector vLavConsorziUpdate = new Vector();
    ValidationErrors errors= validateUpdate(request,hashCommon,vLavConsorziUpdate);
    SolmrLogger.debug(this,"errors.size()="+errors.size());
    if (errors.size()!=0) {
      request.setAttribute("errors",errors);
    }
    else {
      try {
		    //update
		    umaFacadeClient.aggiornaLavorazioneConsorzi(vLavConsorziUpdate,ruoloUtenza);
      }
      catch(SolmrException sexc){
      	SolmrLogger.debug(this,"catch SolmrEception sexc");
        if (sexc.getValidationErrors()!=null){
        	SolmrLogger.debug(this,"        if (sexc.getValidationErrors()!=null)");
          ValidationErrors vErrors = sexc.getValidationErrors();
          if (vErrors.size()!=0) {
          	SolmrLogger.debug(this,"          if (vErrors.size()!=0)");
            request.setAttribute("errors", vErrors);
            %>
              <jsp:forward page="<%=viewUrl%>"/>
            <%
            return;
          }
        }
        else
        {
          SolmrLogger.debug(this,"          else (vErrors.size()!=0)");
          ValidationException valEx=new ValidationException("Eccezione di validazione"+sexc.getMessage(),viewUrl);
          valEx.addMessage(sexc.toString(),"exception");
          throw valEx;
        }
        SolmrLogger.debug(this,"        dopo if (sexc.getValidationErrors()!=null)");
      }
      catch(Exception e)
      {
        ValidationException valEx=new ValidationException("Eccezione di validazione"+e.getMessage(),viewUrl);
        valEx.addMessage(e.getMessage(),"exception");
        throw valEx;
      }
      String forwardUrl=elencoHtm;
      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
      {
        forwardUrl=elencoBisHtm;
      }

      session.setAttribute("notifica","Modifica eseguita con successo");
      response.sendRedirect(forwardUrl);
      return;
    }
  }
  else {
    if (request.getParameter("annulla.x")!=null)
    {
      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
      {
        response.sendRedirect(elencoBisHtm);
      }
      else
      {
        response.sendRedirect(elencoHtm);
      }
      return;
    }
    else
    {
      //carico i dati la prima volta che entro nella pagina
      Vector vLavConsorzi = (Vector)session.getAttribute("vLavConsorzi");
                 
      
      HashMap hashMapMacchine = new HashMap();
      for(int i = 0; i < vLavConsorzi.size();i++){
      	LavConsorziVO lavConsorziVO = (LavConsorziVO)vLavConsorzi.get(i);
      	SolmrLogger.debug(this,"lavConsorziVO.getIdLavorazioneConsorzi(): "+lavConsorziVO.getIdLavorazioneConsorzi());
      	Vector elencoMacchineUtilizzate = umaFacadeClient.findMacchineUtilizzate(lavConsorziVO.getIdLavorazioni(),lavConsorziVO.getIdCategoriaUtilizziUma(),new Long(annoCampagnaVO.getAnnoCampagna()),dittaUMAAziendaVO.getIdDittaUMA(),true);
      	hashMapMacchine.put(lavConsorziVO.getIdLavorazioneConsorzi(),elencoMacchineUtilizzate);
      	
      	// Ricerco la Zona altimeterica per le lavorazioni Consorzi in Modifica
      	Long extIdAzienda = lavConsorziVO.getIdAziendaSocio();
      	SolmrLogger.debug(this," -- extIdAzienda ="+extIdAzienda);
      	// --- Calcolo della zona altimetrica dell'azienda legata alla lavorazione, se viene trovata l'id_ditta_uma corrispondente
        if(extIdAzienda != null){
          SolmrLogger.debug(this, "---  Verifiche per calcolo zona altimetrica ---");
    	  DittaUMAVO dittaTrovata = umaFacadeClient.getDittaUmaByIdAziendaDataCess(new Long(extIdAzienda), new Long(annoCampagnaVO.getAnnoCampagna())); 
    	  if(dittaTrovata != null && dittaTrovata.getIdDitta() != null){
      		SolmrLogger.debug(this, "--- E' stato trovato l'ID_DITTA_UMA corrispondente all'azienda selezionata, effettuo calcolo ZONA ALTIMETRICA");
	  		ZonaAltimetricaVO zonaAltimetrica = umaFacadeClient.getZonaAltByIdDittaUma(dittaTrovata.getIdDitta());
	  		if(zonaAltimetrica != null){
	  			SolmrLogger.debug(this, " -- codiceZonaAlt ="+zonaAltimetrica.getCodiceZonaAltimetrica());
	  			lavConsorziVO.setZonaAltimetricaAziendaLav(zonaAltimetrica);
	  		}	
    	  }    
  	    }
      } // ciclo sulle Lavorazioni Consorzi visualizzate

      String anno = annoCampagnaVO.getAnnoCampagna();
      String data = null;
      String coefficiente = umaFacadeClient.getValoreParametro(SolmrConstants.PARAMETRO_COEFFICIENTE_CAVALLI_CARBURANTE,anno,data);
      
      boolean isConsorzio = umaFacadeClient.isDittaUmaConsorzio(dittaUMAAziendaVO.getIdAzienda());
      
      hashCommon.put("vLavConsorzi",vLavConsorzi);
      hashCommon.put("hashMapMacchine",hashMapMacchine);
    //  hashCommon.put("codiceZonaAlt",codiceZonaAlt);
      hashCommon.put("coefficiente",coefficiente);
      hashCommon.put("isConsorzio",new Boolean(isConsorzio));
      
      session.setAttribute("hashCommon",hashCommon);
      
      request.setAttribute("vLavConsorzi",hashCommon.get("vLavConsorzi"));

      
    }
  }
  request.setAttribute("hashMapMacchine",hashCommon.get("hashMapMacchine"));
//  request.setAttribute("codiceZonaAlt",hashCommon.get("codiceZonaAlt"));
  request.setAttribute("coefficiente",hashCommon.get("coefficiente"));
  request.setAttribute("isConsorzio",hashCommon.get("isConsorzio"));
  
  SolmrLogger.debug(this,"modificaSerraCtrl - End");
%>

<jsp:forward page="<%=viewUrl%>"/>
<%!
	private ValidationErrors validateUpdate(HttpServletRequest request,HashMap hashCommon,Vector vLavConsorziUpdate)
	{
		ValidationErrors errors = new ValidationErrors();
		try
		{
     	Vector vLavConsorzi = (Vector)hashCommon.get("vLavConsorzi");
     	Boolean isConsorzio = (Boolean)hashCommon.get("isConsorzio");
		  BigDecimal zero = new BigDecimal(0);
		  for(int i = 0;i < vLavConsorzi.size();i++)
		  {
				LavConsorziVO lavConsorziVO = (LavConsorziVO)vLavConsorzi.get(i);
				LavConsorziVO lavConsorziUpdate = loadVO(lavConsorziVO);
				String IdLavorazioneConsorzi = lavConsorziVO.getIdLavorazioneConsorzi().toString();
				String esecuzioniStr = request.getParameter("esecuzioniStr"+IdLavorazioneConsorzi);
				String macchinaUtilizzata = request.getParameter("idMacchina"+IdLavorazioneConsorzi);
				String supOreStr = request.getParameter("supOreStr"+IdLavorazioneConsorzi);
				String supOreFatturaStr = request.getParameter("supOreFatturaStr"+IdLavorazioneConsorzi);
				String gasolioStr = request.getParameter("gasolioStr"+IdLavorazioneConsorzi);
				String benzinaStr = request.getParameter("benzinaStr"+IdLavorazioneConsorzi);
				String note = request.getParameter("note"+IdLavorazioneConsorzi);
				String maxCarburante = request.getParameter("maxCarburante"+IdLavorazioneConsorzi);
				
				lavConsorziUpdate.setEsecuzioniStr(esecuzioniStr);
				lavConsorziUpdate.setSupOreStr(supOreStr);
				//lavConsorziUpdate.setSupOreCalcolataStr(supOreStr);
				lavConsorziUpdate.setSupOreFatturaStr(supOreFatturaStr);
				lavConsorziUpdate.setGasolioStr(gasolioStr);
				lavConsorziUpdate.setBenzinaStr(benzinaStr);
				lavConsorziUpdate.setNote(note);
				lavConsorziUpdate.setMaxCarburante(maxCarburante);
				
				if(note.length() > 1000)
				{
					errors.add("noteStr"+i,new ValidationError("Inserire al max 1000 caratteri"));
				}
				
				
				if(lavConsorziVO.getMaxEsecuzioni() != null)
				{
					if(Validator.isEmpty(esecuzioniStr))
					{
						errors.add("esecuzioniStr"+i,new ValidationError("Campo obbligatorio"));
					}
					else
					{
						long numeroEsecuzioni = lavConsorziVO.getMaxEsecuzioni().longValue();
						long esecuzioniInput = 0;
						try
						{
						  esecuzioniInput = Long.parseLong(esecuzioniStr);
						}
						catch(Exception ex)
						{
							errors.add("esecuzioniStr"+i,new ValidationError("Valore numerico"));						
						}
						
						if(esecuzioniInput < 0)
							errors.add("esecuzioniStr"+i,new ValidationError("Non è possibile inserire un valore negativo"));						
						
						if(lavConsorziUpdate.getFlagEscludiEsecuzioni().equalsIgnoreCase("N"))
	        	{
							if(esecuzioniInput > numeroEsecuzioni)
							{
								errors.add("esecuzioniStr"+i,new ValidationError("Non è possibile aumentare il valore del numero esecuzioni"));
							}
						}
					}
				}
				
				if(lavConsorziVO.getTipoUnitaMisura() != null 
				  && lavConsorziVO.getTipoUnitaMisura().equalsIgnoreCase("T") 
						&& isConsorzio.booleanValue())
			  {
					lavConsorziUpdate.setIdMacchinaStr(macchinaUtilizzata);
					
					if(Validator.isEmpty(macchinaUtilizzata))
					{
						errors.add("idMacchina"+i,new ValidationError("Campo obbligatorio"));
					}
					else
					{
						StringTokenizer token = new StringTokenizer(macchinaUtilizzata,"|");
						lavConsorziUpdate.setIdMacchinaStr(token.nextToken());
					}
					
				}
			
				if(Validator.isEmpty(supOreStr))
				{
					errors.add("supOreStr"+i,new ValidationError("Campo obbligatorio"));
				}
				else 
				{
					try
					{
		        BigDecimal supOre = new BigDecimal(supOreStr.replace(',','.'));
						//System.err.println("lavConsorziVO.getTipoUnitaMisura(): "+lavConsorziVO.getTipoUnitaMisura());
		        if(SolmrConstants.TIPO_UNITA_MISURA_S
		          .equalsIgnoreCase(lavConsorziVO.getTipoUnitaMisura()))
		        { 
						  BigDecimal supMax = lavConsorziVO.getSupOreCalcolata();
		          if (supMax != null
		               && supOre.compareTo(supMax) > 0)
		          {
		             errors.add("supOreStr" + i, new ValidationError(
		                 "Non è possibile aumentare il valore della superficie (valore massimo consentito "
		                     + StringUtils.formatDouble4(supMax)
		                     + " ha)"));
		          }
		       	}
		        else if (SolmrConstants.TIPO_UNITA_MISURA_M.equalsIgnoreCase(lavConsorziVO.getTipoUnitaMisura()))
		        {
		        	BigDecimal superficieLineareMax = lavConsorziVO.getSupOreCalcolata().multiply(new BigDecimal(SolmrConstants.MAX_METRO_L));
		        	if(supOre.compareTo(superficieLineareMax) > 0){
		              errors.add("supOreStr" + i, new ValidationError(
		                        "La lunghezza indicata non può essere maggiore di "+StringUtils.formatDouble4(superficieLineareMax)+" metri"));
		        	}
		        }
		       	else if(SolmrConstants.TIPO_UNITA_MISURA_K.equalsIgnoreCase(lavConsorziVO.getTipoUnitaMisura()))
            { 
              BigDecimal supMax = lavConsorziVO.getSupOreCalcolata();
              if (supMax != null
                   && supOre.compareTo(supMax) > 0)
              {
                 errors.add("supOreStr" + i, new ValidationError(
                     "Non è possibile aumentare il valore della potenza (valore massimo consentito "
                         + StringUtils.formatDouble4(supMax)
                         + " kw)"));
              }
            }
		       	else if(supOre.compareTo(zero) == -1)
		       	{
							errors.add("supOreStr"+i,new ValidationError("Non è possibile inserire un valore negativo"));						
						}
						else if(!Validator.validateDoubleDigit(supOreStr,10,4))
						{
							errors.add("supOreStr"+i,new ValidationError("Il valore può avere al massimo 10 cifre intere e 4 decimali"));
						}
	
					}
					catch(Exception ex)
					{
						errors.add("supOreStr"+i,new ValidationError("Campo non numerico"));
					}
				
				}
			
			  if(Validator.isEmpty(gasolioStr) && Validator.isEmpty(benzinaStr) || 
				  !Validator.isEmpty(gasolioStr) && !Validator.isEmpty(benzinaStr))
				{
				  errors.add("gasolioStr"+i,new ValidationError("Valorizzare solo uno dei due campi: G(lt) o B(lt)"));
				  errors.add("benzinaStr"+i,new ValidationError("Valorizzare solo uno dei due campi: G(lt) o B(lt)"));
			  }
			  else
			  {
				  if(!Validator.isEmpty(gasolioStr))
				  {
					  try
					  {
						  SolmrLogger.debug(this,"gasolio: "+gasolioStr);
						  SolmrLogger.debug(this,"maxCarburante: "+maxCarburante);
						  long gasolio = Long.parseLong(gasolioStr);
						  if(!Validator.isEmpty(maxCarburante) && gasolio > Long.parseLong(maxCarburante))
						  {
							  errors.add("gasolioStr"+i,new ValidationError("Non è possibile aumentare la quantità"));
						  }
						  else if(gasolio < 0)
						  {
							  errors.add("gasolioStr"+i,new ValidationError("Non è possibile inserire un valore negativo"));
						  }

					  }
					  catch(Exception ex)
					  {
						  errors.add("gasolioStr"+i,new ValidationError("Campo non numerico"));
					  }
				  }
				  if(!Validator.isEmpty(benzinaStr))
				  {
					  try
					  {
						  long benzina = Long.parseLong(benzinaStr);
						  SolmrLogger.debug(this,"benzina: "+benzina);
						  SolmrLogger.debug(this,"maxCarburante: "+maxCarburante);
						  if(!Validator.isEmpty(maxCarburante) && benzina > Long.parseLong(maxCarburante))
						  {
							  errors.add("benzinaStr"+i,new ValidationError("Non è possibile aumentare la quantità"));
						  }
						  else if(benzina < 0)
								errors.add("benzinaStr"+i,new ValidationError("Non è possibile inserire un valore negativo"));
					  }
					  catch(Exception ex)
					  {
						  errors.add("benzinaStr"+i,new ValidationError("Campo non numerico"));
					  }
				  }
			  }			
			  vLavConsorziUpdate.add(lavConsorziUpdate);	

		  }
		  request.setAttribute("vLavConsorzi",vLavConsorziUpdate);
		}
		catch(Exception ex)
		{
			ex.printStackTrace();
		}
		return errors;
	}
	
	private LavConsorziVO loadVO(LavConsorziVO lavConsorziVO)
	{
		LavConsorziVO lavConsorziUpdateVO = new LavConsorziVO();
		
		lavConsorziUpdateVO.setIdDittaUma(lavConsorziVO.getIdDittaUma());
		lavConsorziUpdateVO.setIdLavorazioneConsorzi(lavConsorziVO.getIdLavorazioneConsorzi());
		lavConsorziUpdateVO.setAnnoCampagna(lavConsorziVO.getAnnoCampagna());
		lavConsorziUpdateVO.setSupOre(lavConsorziVO.getSupOre());
		lavConsorziUpdateVO.setSupOreFattura(lavConsorziVO.getSupOreFattura());
		lavConsorziUpdateVO.setGasolio(lavConsorziVO.getGasolio());
		lavConsorziUpdateVO.setBenzina(lavConsorziVO.getBenzina());
		lavConsorziUpdateVO.setDescCategoriaUtilizzo(lavConsorziVO.getDescCategoriaUtilizzo());
		lavConsorziUpdateVO.setDescTipoLavorazione(lavConsorziVO.getDescTipoLavorazione());

		lavConsorziUpdateVO.setDescUnitaMisura(lavConsorziVO.getDescUnitaMisura());
		lavConsorziUpdateVO.setTipoUnitaMisura(lavConsorziVO.getTipoUnitaMisura());
    	lavConsorziUpdateVO.setFlagEscludiEsecuzioni(lavConsorziVO.getFlagEscludiEsecuzioni());
		lavConsorziUpdateVO.setCodiceUnitaMisura(lavConsorziVO.getCodiceUnitaMisura());
		
		lavConsorziUpdateVO.setTotaleGasolio(lavConsorziVO.getTotaleGasolio());
		lavConsorziUpdateVO.setTotaleBenzina(lavConsorziVO.getTotaleBenzina());
		lavConsorziUpdateVO.setDataInizioValidita(lavConsorziVO.getDataInizioValidita());
		lavConsorziUpdateVO.setDataFineValidita(lavConsorziVO.getDataFineValidita());
		lavConsorziUpdateVO.setDataCessazione(lavConsorziVO.getDataCessazione());
		lavConsorziUpdateVO.setDataUltimoAggiornamento(lavConsorziVO.getDataUltimoAggiornamento());
		
		
		lavConsorziUpdateVO.setIdMacchina(lavConsorziVO.getIdMacchina());
		lavConsorziUpdateVO.setIdLavorazioni(lavConsorziVO.getIdLavorazioni());
		lavConsorziUpdateVO.setIdUnitaMisura(lavConsorziVO.getIdUnitaMisura());
		lavConsorziUpdateVO.setSupOreCalcolata(lavConsorziVO.getSupOreCalcolata());
		lavConsorziUpdateVO.setIdCategoriaUtilizziUma(lavConsorziVO.getIdCategoriaUtilizziUma());
		lavConsorziUpdateVO.setNumeroEsecuzioni(lavConsorziVO.getNumeroEsecuzioni());
		lavConsorziUpdateVO.setNote(lavConsorziVO.getNote());
		lavConsorziUpdateVO.setExtIdUtenteAggiornamento(lavConsorziVO.getExtIdUtenteAggiornamento());
		lavConsorziUpdateVO.setVersoLavorazione(lavConsorziVO.getVersoLavorazione());
		
		lavConsorziUpdateVO.setMaxEsecuzioni(lavConsorziVO.getMaxEsecuzioni());               
		lavConsorziUpdateVO.setLitriBase(lavConsorziVO.getLitriBase());			       
		lavConsorziUpdateVO.setLitriConto3(lavConsorziVO.getLitriConto3());           
		lavConsorziUpdateVO.setLitriMedioImpasto(lavConsorziVO.getLitriMedioImpasto());     
		lavConsorziUpdateVO.setLitriTerDeclivi(lavConsorziVO.getLitriTerDeclivi());
		lavConsorziUpdateVO.setCoefficiente(lavConsorziVO.getCoefficiente());
		lavConsorziUpdateVO.setMaxCarburante(lavConsorziVO.getMaxCarburante());
		
		lavConsorziUpdateVO.setIdAziendaSocio(lavConsorziVO.getIdAziendaSocio());
		lavConsorziUpdateVO.setCuaaAziendaSocio(lavConsorziVO.getCuaaAziendaSocio());
		lavConsorziUpdateVO.setPiAziendaSocio(lavConsorziVO.getPiAziendaSocio());
		lavConsorziUpdateVO.setDescAziendaSocio(lavConsorziVO.getDescAziendaSocio());
		
		return lavConsorziUpdateVO;
	}
%>
