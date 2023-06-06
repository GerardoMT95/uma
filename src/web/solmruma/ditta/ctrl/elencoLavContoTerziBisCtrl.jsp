<%@ page language="java" contentType="text/html" isErrorPage="true"%>

<%@ page import="java.util.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.client.anag.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.etc.uma.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@page import="it.csi.solmr.dto.profile.RuoloUtenza"%>
<%@page import="javax.servlet.http.HttpSession"%>


<%
  String iridePageName = "elencoLavContoTerziBisCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%
  SolmrLogger.debug(this, "   BEGIN elencoLavContoTerziBisCtrl");

  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");
  Long idDittaUma = dittaUMAAziendaVO.getIdDittaUMA();

  SolmrLogger.debug(this,
      "[elencoLavContoTerziBisCtrl::service] ################## idDittaUma "
          + idDittaUma);

  UmaFacadeClient umaClient = new UmaFacadeClient();
  AnagFacadeClient anagClient = new AnagFacadeClient();
  String url = "/ditta/view/elencoLavContoTerziBisView.jsp";
  String urlTornaElenco = "/ditta/ctrl/elencoLavContoTerziCtrl.jsp";

  String modificaUrl = "/ditta/ctrl/modificaLavContoTerziCtrl.jsp";
  String validateUrl = "/ditta/view/elencoLavContoTerziView.jsp";
  //String insertUrl = "/ditta/ctrl/nuovaLavContoTerziCtrl.jsp";
  String insertUrl = "/ditta/layout/nuovaLavContoTerzi.htm";
  String deleteUrl = "/ditta/ctrl/confermaEliminaLavContoTerziCtrl.jsp";
  String allegaFatturaUrl = "/ditta/ctrl/allegaFatturaContoTerziCtrl.jsp";
  //String urlDeleteOk="../../ditta/layout/elencoSerre.htm?notifica=delete";
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  
  String umar = umaClient.getParametro(SolmrConstants.PARAMETRO_UMAR);  
  request.setAttribute("PARAMETRO_UMAR", umar);

  String info = (String) session.getAttribute("notifica");
  if (info != null)
  {
    findData(request, umaClient, idDittaUma, url, ruoloUtenza, response);
    session.removeAttribute("notifica");
    throwValidation(info, validateUrl);
  }

	String annoRiferimento = (String) request.getParameter("annoRiferimento");
  String cuaaFiltroContoProprio = (String) request.getParameter("cuaaFiltroStr");
  String partitaIvaFiltroContoProprio = (String) request.getParameter("partitaIvaFiltroStr");
  String denominazioneFiltroContoProprio = (String) request.getParameter("denominazioneFiltroStr");
  SolmrLogger.debug(this, "annoRiferimento VALE: " + annoRiferimento);
	AnnoCampagnaVO annoCampagna = new AnnoCampagnaVO();
	if(!StringUtils.isStringEmpty(annoRiferimento)){
  		annoCampagna.setAnnoCampagna(annoRiferimento);
	}
	if(!StringUtils.isStringEmpty(cuaaFiltroContoProprio)){
  		annoCampagna.setCuaaContoProprio(cuaaFiltroContoProprio);
	}
	if(!StringUtils.isStringEmpty(partitaIvaFiltroContoProprio)){
  		annoCampagna.setPartitaIvaContoProprio(partitaIvaFiltroContoProprio);
	}
	if(!StringUtils.isStringEmpty(denominazioneFiltroContoProprio)){
  		annoCampagna.setDenominazioneContoProprio(denominazioneFiltroContoProprio);
	}
	session.setAttribute("annoCampagna",annoCampagna);

  if (request.getParameter("tornaElenco.x") != null)
  {
    SolmrLogger.debug(this,
        "[elencoLavContoTerziBisCtrl] TORNO AD ELENCO...");
		/*AnnoCampagnaVO annoCampagna = new AnnoCampagnaVO();
		if(!StringUtils.isStringEmpty(annoRiferimento)){
	  		annoCampagna.setAnnoCampagna(annoRiferimento);
		}
		if(!StringUtils.isStringEmpty(cuaaFiltroContoProprio)){
	  		annoCampagna.setCuaaContoProprio(cuaaFiltroContoProprio);
		}
		if(!StringUtils.isStringEmpty(partitaIvaFiltroContoProprio)){
	  		annoCampagna.setPartitaIvaContoProprio(partitaIvaFiltroContoProprio);
		}
		if(!StringUtils.isStringEmpty(denominazioneFiltroContoProprio)){
	  		annoCampagna.setDenominazioneContoProprio(denominazioneFiltroContoProprio);
		}
		session.setAttribute("annoCampagna",annoCampagna);*/
	%>
	  <jsp:forward page="<%=urlTornaElenco%>" />
	<%
  return;
  }

  SolmrLogger.debug(this,
      "[elencoLavContoTerziBisCtrl::service] *************************** idDittaUma "
          + idDittaUma);
  if (request.getParameter("inserisci.x") != null)
  {
    request.setAttribute("flagPulisciSessione", "true");
    %>
      <jsp:forward page="<%=insertUrl%>" />
    <%
    return;
  }
  else if (request.getParameter("ricarica.x") != null)
  {
    try
    {
      SolmrLogger.debug(this, "Sono in RICARICAAAAA di elencoLavContoTerziBisCtrl");
      /*String annoRiferimento = request.getParameter("annoRiferimento");
      SolmrLogger.debug(this, "annoRiferimento VALE: " + annoRiferimento);
      if (!StringUtils.isStringEmpty(annoRiferimento))
      {
        AnnoCampagnaVO annoCampagna = new AnnoCampagnaVO();
        annoCampagna.setAnnoCampagna(annoRiferimento);
        session.setAttribute("annoCampagna", annoCampagna);
      }*/
      DittaUMAAziendaVO dittaUma = (DittaUMAAziendaVO) session
          .getAttribute("dittaUMAAziendaVO");
      if (null != dittaUma && dittaUma.getIdConduzione() != null)
      {
        SolmrLogger.debug(this,
            "[elencoLavContoTerziBisCtrl::ricarica] dittaUma.getIdDittaUMA() VALE: "
                + dittaUma.getIdDittaUMA());
        SolmrLogger.debug(this,
            "[elencoLavContoTerziBisCtrl::ricarica] IDCONDUZIONE VALE: "
                + dittaUma.getIdConduzione());
        /*if (!(dittaUma.getIdConduzione().equalsIgnoreCase("2") || dittaUma
            .getIdConduzione().equalsIgnoreCase("3")))
        {

          throw new Exception(
              "La ditta effettua solo attivita' per conto proprio, operazione non permessa");

        }
        else
        {*/
          //SolmrLogger.debug(this,"Sono in RICARICAAAAA PRIMA di getVettLavorazioni");
          
      
       // ------ Se sono stati indicati : cuaa o partita iva o denominazione :     
       String cuaa = annoCampagna.getCuaaContoProprio();
       String partitaIva = annoCampagna.getPartitaIvaContoProprio();   
       String denominazione = annoCampagna.getDenominazioneContoProprio();
       Vector<Long> listIdAzienda = null;
       
       SolmrLogger.debug(this,"-- cuaa ="+cuaa);
       SolmrLogger.debug(this,"-- partita iva ="+partitaIva);
       SolmrLogger.debug(this,"-- denominazione ="+denominazione);
       
       if(!StringUtils.isStringEmpty(cuaa) || !StringUtils.isStringEmpty(partitaIva) || !StringUtils.isStringEmpty(denominazione)){
         // Validazione campi
         ValidationErrors errors = annoCampagna.validate();

         if (! (errors == null || errors.size() == 0)) {
           SolmrLogger.debug(this, "----- ci sono errori di validazione sui filtri di ricerca");
           request.setAttribute("errors", errors);
           request.getRequestDispatcher(validateUrl).forward(request, response);
           return;
         }
       
         SolmrLogger.debug(this,"-- effettuare la chiamata ad anagrafe -- serviceGetListIdAziende()");
         AnagAziendaVO anagAziendaVO= new AnagAziendaVO();
         if(!StringUtils.isStringEmpty(cuaa))
           anagAziendaVO.setCUAA(cuaa.trim());
         if(!StringUtils.isStringEmpty(partitaIva))  
           anagAziendaVO.setPartitaIVA(partitaIva.trim());
         if(!StringUtils.isStringEmpty(denominazione))  
           anagAziendaVO.setDenominazione(denominazione.trim()); 
         listIdAzienda = umaClient.serviceGetListIdAziende(anagAziendaVO,false,false);
       }  
          
        Long extIdAziendaCorrente = null;  
        VectorUtils.getVettLavorazioni(request, umaClient,
           dittaUma.getIdDittaUMA(),extIdAziendaCorrente, annoRiferimento, cuaa, partitaIva, denominazione, listIdAzienda,
           ruoloUtenza, true, null);
           
           
          //SolmrLogger.debug(this,"Sono in RICARICAAAAA DOPO di getVettLavorazioni");
          //SolmrLogger.debug(this,"Sono in RICARICAAAAA DOPO di getVettLavorazioni url VALE: "+url);
          // Visualizzazione Lav conto terzi
          //findData(request,umaClient,idDittaUma,url);
        request.removeAttribute("ricarica.x");
        %>
          <jsp:forward page="<%=url%>" />
        <%
        //SolmrLogger.debug(this,"QUIIIIIII");
        return;

          //}
      }
        /*else
          if (dittaUma.getIdConduzione() == null)
            throw new Exception(
                "La ditta effettua solo attivita' per conto proprio, operazione non permessa");*/
    }
    catch (Exception e)
    {
      request.setAttribute("errorMessage", e.getMessage());
      SolmrLogger.debug(this, "ERRORE... " + e.getMessage());
        //e.printStackTrace();
      %>
        <jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
      <%
      return;
    }
    %><!-- jsp:forward page="<%=modificaUrl%>" /-->
    <%
  }
  else
  {
    if (request.getParameter("modifica.x") != null)
    {
      try
      {
        String[] checkBoxSel = request.getParameterValues("checkbox");
        Long[] vIdLav = new Long[checkBoxSel.length];
        for (int i = 0; i < checkBoxSel.length; i++)
        {
          vIdLav[i] = new Long(checkBoxSel[i]);
        }
        Vector vLavContoTerzi = umaClient.findLavorazioneContoTerziByIdRange(vIdLav);
         for (int i = 0; i < vLavContoTerzi.size(); i++)
         {
           LavContoTerziVO lavContoTerziVO = (LavContoTerziVO) vLavContoTerzi
               .get(i);
           if (lavContoTerziVO.getDataFineValidita() != null
               || lavContoTerziVO.getDataCessazione() != null)
           {
             throw new Exception(
                 "Una delle lavorazioni non è modificabile perchè si riferisce ad un dato storicizzato");
           }
         }
         session.setAttribute("vLavContoTerzi", vLavContoTerzi);
       }
       catch (Exception e)
       {
         e.printStackTrace();
         request.setAttribute("errorMessage", e.getMessage());
         %>
           <jsp:forward	page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
         <%
         return;
      }
      %>
        <jsp:forward page="<%=modificaUrl%>" />
      <%
    }
    else
    {
      if (request.getParameter("elimina.x") != null)
      {
        try
        {
          String[] checkBoxSel = request.getParameterValues("checkbox");
          Long[] vIdLav = new Long[checkBoxSel.length];
          for (int i = 0; i < checkBoxSel.length; i++)
          {
            vIdLav[i] = new Long(checkBoxSel[i]);
          }
          Vector vLavContoTerzi = umaClient.findLavorazioneContoTerziByIdRange(vIdLav);
          for (int i = 0; i < vLavContoTerzi.size(); i++)
          {
            LavContoTerziVO lavContoTerziVO = (LavContoTerziVO) vLavContoTerzi
                .get(i);
            if (lavContoTerziVO.getDataFineValidita() != null
                || lavContoTerziVO.getDataCessazione() != null)
            {
              throw new Exception(
                  "Una delle lavorazioni non è modificabile perchè si riferisce ad un dato storicizzato");
            }
          }
          session.setAttribute("vLavContoTerzi", vIdLav);

        }
        catch (Exception e)
        {
          request.setAttribute("errorMessage", e.getMessage());
          %>
            <jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
          <%
          return;
        }
        %>
          <jsp:forward page="<%=deleteUrl%>" />
        <%
      } 
      else if (request.getParameter("allegaFattura.x")!=null){
	  	SolmrLogger.debug(this, "-- CASO allegaFattura");	
	      try{        	        	
	      	SolmrLogger.debug(this, " ----------- Ricerca delle fattura dell'anno precedente");
	      	int prevYear = getPreviousYear();
	      	SolmrLogger.debug(this, "-- prevYear ="+prevYear);
	      	request.setAttribute("annoCampagna", new Integer(prevYear).toString());
	      	
	      	List<FatturaContoTerziVO> fatturaContoTerziList =umaClient.findFattureContoTerziByAnnoIdDittaUma(new Integer(prevYear).longValue(), dittaUMAAziendaVO.getIdDittaUMA());
	      	request.setAttribute("vElencoFatturaContoTerziVO", fatturaContoTerziList); 
	      	session.setAttribute("vElencoFatturaContoTerziVO", fatturaContoTerziList);
	      	
	      }
	      catch(Exception e){
	        SolmrLogger.error(this, "-- Exception ="+e.getMessage());
	        request.setAttribute("errorMessage",e.getMessage());
				%>
					<jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
				<%
			  return;
	      }
		%>
		<jsp:forward page="<%=allegaFatturaUrl%>" />
		<%
	  }
      else
      {
        // inizio cris
        try
        {
          SolmrLogger.debug(this, "Sono in CARICA DATII di elencoLavContoTerziBisCtrl");
          SolmrLogger.debug(this,
                    "[elencoLavContoTerziBisCtrl::service] CONTROLLO IDCONDIZIONE");

            /*if (null != dittaUMAAziendaVO
                && dittaUMAAziendaVO.getIdConduzione() != null)
            {
              SolmrLogger.debug(this,
                  "[elencoLavContoTerziBisCtrl::service] dittaUma.getIdDittaUMA() VALE: "
                      + dittaUMAAziendaVO.getIdDittaUMA());
              SolmrLogger.debug(this,
                  "[elencoLavContoTerziBisCtrl::service] IDCONDUZIONE VALE: "
                      + dittaUMAAziendaVO.getIdConduzione());
              if (!(dittaUMAAziendaVO.getIdConduzione().equalsIgnoreCase(
                  "2") || dittaUMAAziendaVO.getIdConduzione()
                  .equalsIgnoreCase("3")))
              {

                throw new Exception(
                    "La ditta effettua solo attivita' per conto proprio, operazione non permessa");

              }
              else
              {*/
                // CARICO DATI
          findData(request, umaClient, idDittaUma, url, ruoloUtenza, response);

              /*}
            }*/
        }
        catch (Exception e)
        {
          request.setAttribute("errorMessage", e.getMessage());
          %>
            <jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
          <%
          return;
        }
        // Visualizzazione Lav conto terzi
        //findData(request, umaClient, idDittaUma, url, ruoloUtenza);
        %>
          <jsp:forward page="<%=url%>" />
        <%
      }// end cris

    }
  }// end
%>


<%!
	

  private String dateStr(Date date)
  {
    if (date != null)
    {
      return UmaDateUtils.formatDate(date);
    }
    else
    {
      return "";
    }
  }

  private void findData(HttpServletRequest request, UmaFacadeClient umaClient,
      Long idDittaUma, String validateUrl, RuoloUtenza ruoloUtenza, HttpServletResponse response)
      throws ValidationException
  {
    try
    {
      SolmrLogger.debug(this,
          "[elencoLavContoTerziCtrl::service::::begin] \n\n\n\n\n\n\n\n\nidDittaUma="
              + idDittaUma + " \n\n\n\n\n\n\n\n\n....");
      HttpSession session = request.getSession();
      
      
      SolmrLogger.debug(this, " ---- Ricerca degli anni da visualizzare nella COMBO Anno rifirimento");
	  Vector<AnnoCampagnaVO> vettAnniCampagna= umaClient.findAnniCampLavPerCt(idDittaUma);
	  SolmrLogger.debug(this, " -- ordinamento degli anni");
	  Collections.sort(vettAnniCampagna);
	  SolmrLogger.debug(this," ---- numero di anni da visualizzare nella combo ="+vettAnniCampagna.size());
	  session.setAttribute("LavCTvettAnniCampagna",vettAnniCampagna);
            

      // Carico la griglia delle lavorazioni
      AnnoCampagnaVO annoCampagna = (AnnoCampagnaVO) session
          .getAttribute("annoCampagna");
      if(annoCampagna.getAnnoCampagna()!=null)
      {
        SolmrLogger.debug(this, "ANNOCAMPAGNA IN SESSION VALE: "
            + annoCampagna.getAnnoCampagna());

      }
      else
      {
        SolmrLogger.debug(this, "ANNOCAMPAGNA IN SESSION E' NULL");
        annoCampagna = new AnnoCampagnaVO();
        annoCampagna.setAnnoCampagna(String.valueOf(UmaDateUtils
            .getCurrentYear()));

      }
      session.setAttribute("annoCampagna", annoCampagna);


        
      // ------ Se sono stati indicati : cuaa o partita iva o denominazione :     
      String cuaa = annoCampagna.getCuaaContoProprio();
      String partitaIva = annoCampagna.getPartitaIvaContoProprio();   
      String denominazione = annoCampagna.getDenominazioneContoProprio();
      Vector<Long> listIdAzienda = null;
       
      SolmrLogger.debug(this,"-- cuaa ="+cuaa);
      SolmrLogger.debug(this,"-- partita iva ="+partitaIva);
      SolmrLogger.debug(this,"-- denominazione ="+denominazione);
       
      if(!StringUtils.isStringEmpty(cuaa) || !StringUtils.isStringEmpty(partitaIva) || !StringUtils.isStringEmpty(denominazione)){
        // Validazione campi
        ValidationErrors errors = annoCampagna.validate();

        if (! (errors == null || errors.size() == 0)) {
           SolmrLogger.debug(this, "----- ci sono errori di validazione sui filtri di ricerca");
           request.setAttribute("errors", errors);
           request.getRequestDispatcher(validateUrl).forward(request, response);
           return;
        }
         
        SolmrLogger.debug(this,"-- effettuare la chiamata ad anagrafe -- serviceGetListIdAziende()");
        AnagAziendaVO anagAziendaVO= new AnagAziendaVO();
        if(!StringUtils.isStringEmpty(cuaa))
           anagAziendaVO.setCUAA(cuaa.trim());
        if(!StringUtils.isStringEmpty(partitaIva))  
           anagAziendaVO.setPartitaIVA(partitaIva.trim());
        if(!StringUtils.isStringEmpty(denominazione))  
           anagAziendaVO.setDenominazione(denominazione.trim());  
        listIdAzienda = umaClient.serviceGetListIdAziende(anagAziendaVO,false,false); 
      }
       
      Long extIdAziendaCorrente = null; 
      VectorUtils.getVettLavorazioni(request, umaClient, idDittaUma, extIdAziendaCorrente,
      		annoCampagna.getAnnoCampagna(), annoCampagna.getCuaaContoProprio(),
		    annoCampagna.getPartitaIvaContoProprio(), annoCampagna.getDenominazioneContoProprio(), listIdAzienda,
            ruoloUtenza, true, null);
      SolmrLogger.debug(this, "[elencoLavContoTerziCtrl::findData:::::end]");
    }
    catch (Exception e)
    {
      throwValidation(e.getMessage(), validateUrl);
    }
  }
  
  private String getRequestSessionValue(HttpServletRequest request, String key) throws ValidationException
  {
    HttpSession session = request.getSession(true);
    String value = Validator.isNotEmpty(request.getParameter(key))?request.getParameter(key):(String)session.getAttribute(key);
    session.setAttribute(key, value);
    return value;
  }
 
  private void throwValidation(String msg, String validateUrl)
      throws ValidationException
  {
    ValidationException valEx = new ValidationException(msg, validateUrl);
    valEx.addMessage(msg, "exception");
    throw valEx;
  }
  
  private int getPreviousYear() {
      Calendar prevYear = Calendar.getInstance();
      prevYear.add(Calendar.YEAR, -1);
      return prevYear.get(Calendar.YEAR);
  }%>
