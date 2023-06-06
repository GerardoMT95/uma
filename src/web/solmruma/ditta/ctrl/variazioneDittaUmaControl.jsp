<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%
  String iridePageName = "variazioneDittaUmaControl.jsp";
%>
  <%@include file="/include/autorizzazione.inc"%>
<%
  String variazioneDittaUMAUrl = "/ditta/view/variazioneDittaUmaView.jsp";
  String validateUrl = "/ditta/view/variazioneDittaUmaView.jsp";
  String annullaUrl = "../../anag/layout/dettaglioAzienda.htm";
  String updateOkUrl = "../../anag/layout/dettaglioAzienda.htm";
  
  SolmrLogger.debug(this,"BEGIN variazioneDittaUmaControl");
  
  UmaFacadeClient umaClient = new UmaFacadeClient();
  DittaUMAAziendaVO dumaa = (DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma = dumaa.getIdDittaUMA();
  SolmrLogger.debug(this, "-- idDittaUma ="+idDittaUma);
  
  // Allegati
  List<FileVO> vElencoFileAllegati = null;
 
  // Se sto entrando sulla pagina per la prima volta : rimuovo i dati in sessione
  String conferma = request.getParameter("conferma.x");
  String annulla =  request.getParameter("annulla.x");
  String azione = request.getParameter("azione");
  //if(Validator.isEmpty(conferma) && Validator.isEmpty(annulla) && Validator.isEmpty(azione)){
  if(Validator.isEmpty(azione)){
	SolmrLogger.debug(this, "-- sto entrando nella pagina per la prima volta");  
    session.removeAttribute("vElencoFileAllegati");
    
    // Allegati presenti sul db	    
 	session.setAttribute("vElencoFileAllegati",umaClient.getAllegatiByIdDittaUma(idDittaUma));
  }
  else{
	// Recupero gli allegati inseriti con la popup, se ce ne sono	
	// Note : se stiamo salvando i dati, senza aver aperto la popup degli allegati non devo prendere questi dati	  
	HashMap common = (HashMap)session.getAttribute("common");
	if(common != null){
	  SolmrLogger.debug(this, "-- setto vElencoFileAllegati in sessione");	  
	  vElencoFileAllegati = (List<FileVO>)common.get("vElencoFileAllegati");
	  session.setAttribute("vElencoFileAllegati",vElencoFileAllegati);
	}	  
  }
  
  
  

  String dtmn=umaClient.getParametro(SolmrConstants.PARAMETRO_DATA_MINIMA_RICEZIONE_DOCUMENTI_ASSEGNAZIONE);
  String dtmx=umaClient.getParametro(SolmrConstants.PARAMETRO_DATA_MASSIMA_RICEZIONE_DOCUMENTI_ASSEGNAZIONE);
  Date dtmnDate=null;
  Date dtmxDate=null;
  try
  {
    dtmnDate=DateUtils.parseDate(dtmn);
  }
  catch(Exception e)
  {
    throw new SolmrException(UmaErrors.ERRORE_PARAMETRO_DTMN_NON_VALIDO);
  }
  try
  {
    dtmxDate=DateUtils.parseDate(dtmx);
  }
  catch(Exception e)
  {
    throw new SolmrException(UmaErrors.ERRORE_PARAMETRO_DTMX_NON_VALIDO);
  }
  // Se sono arrivato qui le variabili dtmnDate e dtmxDate sono != null
  request.setAttribute("DTMN",dtmnDate);
  request.setAttribute("DTMX",dtmxDate);


  
  DittaUMAVO dittaUmaVO = umaClient.findByPrimaryKey(idDittaUma);
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  SolmrLogger.debug(this,"idDittaUma: " + idDittaUma);
  SolmrLogger.debug(this,"\n\n\n\nPrima di isUtenteAutorizzato");
  Date today=DateUtils.parseDate(DateUtils.formatDate(new Date())); // Data senza HH:MI:SS

  if (request.getParameter("conferma.x") != null)
  {
    SolmrLogger.debug(this,"setDataIscrizione : "
        + DateUtils.parseDate(request.getParameter("dataIscrizioneStr")));
    dittaUmaVO.setDataIscrizione(DateUtils.parseDate(request
        .getParameter("dataIscrizioneStr")));
    //Carica ruoloUtenza nel dittaUma
    dittaUmaVO.setRuoloUtenza(ruoloUtenza);
    dittaUmaVO.setComune(request.getParameter("comune"));
    dittaUmaVO.setProvincia(request.getParameter("provincia"));
    dittaUmaVO.setIndirizzoConsegna(request.getParameter("indirizzoConsegna"));
    dittaUmaVO.setNoteDitta(request.getParameter("noteDitta"));
    SolmrLogger.debug(this,"\n\n\n\n #########comune : " + dittaUmaVO.getComune());

    SolmrLogger.debug(this,"\n\n\n\n #########provincia : " + dittaUmaVO.getProvincia());
    

    String tipiConduzione = request.getParameter("tipiConduzione");

    if (tipiConduzione != null && !"".equals(tipiConduzione))
    {
      dittaUmaVO.setIdConduzione(new Long(tipiConduzione));
    }
    else
    {
      dittaUmaVO.setIdConduzione(null);
    }

    dittaUmaVO.setModificaFlagRicezioneDocumAssegnaz(!today.before(dtmnDate) && !today.after(dtmxDate));
    if (request.getParameter("flagRicezDocumAssegnaz")!=null)
    {
      dittaUmaVO.setDataRicezDocumAssegnaz(today);
    }
    else
    {
      dittaUmaVO.setDataRicezDocumAssegnaz(null);
    }
    // validazione

    SolmrLogger.debug(this,"prima dittaUmaVO.validateUpdateDitta()");
    ValidationErrors errors = dittaUmaVO.validateUpdateDitta();
    SolmrLogger.debug(this,"\n\n\n\n\n*********************************");
    SolmrLogger.debug(this,"errori " + errors);
    SolmrLogger.debug(this,"Dati validati");
    // ricerco il codice del comune e della provincia perchè non so se l'utente è passato
    // dal pop-up per la scelta del comune o li ha inseriti a mano.
    String codiceIstatComune = "";
    try
    {
      if (!"".equals(dittaUmaVO.getComune())
          && dittaUmaVO.getComune() != null)
      {
        codiceIstatComune = umaClient.ricercaCodiceComune(dittaUmaVO
            .getComune(), dittaUmaVO.getProvincia());
        dittaUmaVO.setIstatComune(codiceIstatComune);
        
        // NOTE : PER TOBECONFIG TOLGO IL CONTROLLO SUL COMUNE FUORI REGIONE
       /* if (!isInRegione(dittaUmaVO.getExtComunePrincipaleAttivita(), umaClient))
        {
          errors.add("comune", new ValidationError(
              "Comune non della regione"));
          request.setAttribute("errors", errors);
        }*/
      }
    }
    catch (SolmrException se)
    {
      request.setAttribute("dittaUmaVO", dittaUmaVO);
      if (it.csi.solmr.etc.anag.AnagErrors.CODICEISTATCOMUNE.equals(se.getMessage())
          || UmaErrors.COMUNE_DUPLICATO.equals(se.getMessage()))
      {
        errors = new ValidationErrors();
        SolmrLogger.debug(this,"comune");
        errors.add("comune", new ValidationError(se.getMessage()));
        request.setAttribute("errors", errors);
        SolmrLogger.debug(this,"errors.size()=" + errors.size());
				%>
				  <jsp:forward page="<%=validateUrl%>" />
				<%
				return;
      }

      ValidationException valEx = new ValidationException("Errore = "
          + se.getMessage(), validateUrl);
      valEx.addMessage(se.getMessage(), "exception");
      throw valEx;
    }

    dittaUmaVO.setExtComunePrincipaleAttivita(codiceIstatComune);
    SolmrLogger.debug(this,"\n\n\n\n #########istatComune : " + codiceIstatComune);

    if ((errors != null && errors.size() != 0))
    {
      request.setAttribute("errors", errors);
      request.setAttribute("dittaUmaVO", dittaUmaVO);
			%>
			  <jsp:forward page="<%=validateUrl%>" />
			<%
			return;
    }

    try
    {
      // Esegue l'update della ditta
      SolmrLogger.debug(this,"*************************" + dittaUmaVO.getIdDitta());
      SolmrLogger.debug(this,"dittaUmaVO.getRuoloUtenza().getIdUtente().longValue() : "
              + dittaUmaVO.getRuoloUtenza().getIdUtente().longValue());
      SolmrLogger.debug(this,"new java.sql.Date(dittaUmaVO.getDataCessazione()) : "
              + dittaUmaVO.getDataCessazione());
      SolmrLogger.debug(this,"dittaUmaVO.getIdDitta().longValue() : "
          + dittaUmaVO.getIdDitta().longValue());
      SolmrLogger.debug(this,"dittaUmaVO.getIdDatiDitta() : "
          + dittaUmaVO.getIdDatiDitta());
      dittaUmaVO.setRuoloUtenza((RuoloUtenza) session.getAttribute("ruoloUtenza"));
      
      
      
		List<FileVO> elencoFileAllegati = (List<FileVO>)session.getAttribute("vElencoFileAllegati");
		if(elencoFileAllegati != null && elencoFileAllegati.size()>0){
			SolmrLogger.debug(this, "-- ci sono degli allegati");
			dittaUmaVO.setElencoFileAllegati(elencoFileAllegati);
		}	            
        umaClient.updateDittaUMA(dittaUmaVO);
      
      
      session.setAttribute("refreshDettaglio", "true");
      session.setAttribute("notifica", "Modifica effettuata con successo");
      response.sendRedirect(updateOkUrl);
      return;
    }
    catch (SolmrException se)
    {
      request.setAttribute("dittaUmaVO", dittaUmaVO);
      ValidationException valEx = new ValidationException(
          "Errore aggiornamento ditta Uma", validateUrl);
      SolmrLogger.debug(this,"Errore aggiornamento ditta Uma");
      valEx.addMessage(se.getMessage(), "exception");
      throw valEx;
    }
  }

  if (request.getParameter("annulla.x") != null)
  {
    SolmrLogger.debug(this,"###### ANNULLA");
    response.sendRedirect(annullaUrl);
    return;
  }

  SolmrLogger.debug(this,"default");
  SolmrLogger.debug(this,"dumaa.getIdDittaUMA(): " + dumaa.getIdDittaUMA());
  dittaUmaVO = umaClient.findByPrimaryKey(dumaa.getIdDittaUMA());
  request.setAttribute("dittaUmaVO", dittaUmaVO);
	%>
	  <jsp:forward page="<%=variazioneDittaUMAUrl%>" />
<%!
  private boolean isInRegione(String istat, UmaFacadeClient umaClient)
  {
    try
    {
      ComuneVO comuneVO = umaClient.getComuneByISTAT(istat);
      Vector provincieTOBECONFIG = umaClient
          .getProvincieByRegione(SolmrConstants.ID_REGIONE);
      int size = provincieTOBECONFIG == null ? 0 : provincieTOBECONFIG.size();
      for (int i = 0; i < size; i++)
      {
        ProvinciaVO prov = (ProvinciaVO) provincieTOBECONFIG.get(i);
        if (comuneVO.getIstatProvincia() != null
            && comuneVO.getIstatProvincia().equals(prov.getIstatProvincia()))
        {
          return true;
        }
      }
      return false;
    }
    catch (Exception e)
    {
      return false;
    }
  }
%>

