<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@page import="it.csi.solmr.dto.filter.LavConsorziFilter"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%
	String iridePageName = "elencoLavConsorziBisCtrl.jsp";
%>
  <%@include file = "/include/autorizzazione.inc" %>
<%
	DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  SolmrLogger.debug(this,"[elencoLavConsorziBisCtrl::service] ################## idDittaUma "+idDittaUma);

  UmaFacadeClient umaClient = new UmaFacadeClient();
  AnagFacadeClient anagClient = new AnagFacadeClient();
  String url="/ditta/view/elencoLavConsorziBisView.jsp";
  String urlTornaElenco="/ditta/ctrl/elencoLavConsorziCtrl.jsp";
 
   String modificaUrl="/ditta/ctrl/modificaLavConsorziCtrl.jsp";
  String validateUrl="/ditta/view/elencoLavConsorziView.jsp";
  String insertUrl="/ditta/ctrl/nuovaLavConsorziCtrl.jsp";
  String deleteUrl="/ditta/ctrl/confermaEliminaLavConsorziCtrl.jsp";
  //String urlDeleteOk="../../ditta/layout/elencoSerre.htm?notifica=delete";
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  String info=(String)session.getAttribute("notifica");
  if (info!=null)
  {
    findData(request,umaClient,idDittaUma,url,dittaUMAAziendaVO.getIdAzienda());
    session.removeAttribute("notifica");
    throwValidation(info,validateUrl);
  }

  if (request.getParameter("tornaElenco.x")!=null)
  {
		SolmrLogger.debug(this,"[elencoLavConsorziBisCtrl] TORNO AD ELENCO..."); 
		String annoRiferimento = request.getParameter("annoRiferimento");
		
  	SolmrLogger.debug(this,"annoRiferimento VALE: "+annoRiferimento);
  	if(!StringUtils.isStringEmpty(annoRiferimento)){
  		AnnoCampagnaVO annoCampagna = new AnnoCampagnaVO();
  		annoCampagna.setAnnoCampagna(annoRiferimento);
  		
  		String cuaa = request.getParameter("cuaa");
		String partitaIva = request.getParameter("iva");
		String denominazione = request.getParameter("Denominazione");
		  
  		annoCampagna.setCuaaContoProprio(cuaa);
  		annoCampagna.setPartitaIvaContoProprio(partitaIva);
  		annoCampagna.setDenominazioneContoProprio(denominazione);
  		
  		session.setAttribute("annoCampagna",annoCampagna);
    }
	  %>
	    <jsp:forward page="<%=urlTornaElenco%>" />
	  <%
	  return;
  }
  
  SolmrLogger.debug(this,"[elencoLavConsorziBisCtrl::service] *************************** idDittaUma "+idDittaUma);
  if (request.getParameter("inserisci.x")!=null)
  {
  	request.setAttribute("flagPulisciSessione","true");
	  %>
	    <jsp:forward page="<%=insertUrl%>" />
	  <%
	  return;
  }
  else if(request.getParameter("ricarica.x")!=null)
  {
	  try
	  {
		 SolmrLogger.debug(this,"Sono in RICARICAAAAA ");
	  	String annoRiferimento = request.getParameter("annoRiferimento");
	  	String cuaa = request.getParameter("cuaa");
		String partitaIva = request.getParameter("iva");
		String denominazione = request.getParameter("Denominazione");
			
	  	SolmrLogger.debug(this,"annoRiferimento VALE: "+annoRiferimento);
	  	SolmrLogger.debug(this,"cuaa VALE: "+cuaa);
	  	SolmrLogger.debug(this,"partitaIva VALE: "+partitaIva);
	  	SolmrLogger.debug(this,"Denominazione VALE: "+denominazione);
	  	
	  	if(!StringUtils.isStringEmpty(annoRiferimento))
	  	{
	  		AnnoCampagnaVO annoCampagna = new AnnoCampagnaVO();
	  		annoCampagna.setAnnoCampagna(annoRiferimento);
	  		
			  
	  		annoCampagna.setCuaaContoProprio(cuaa);
	  		annoCampagna.setPartitaIvaContoProprio(partitaIva);
	  		annoCampagna.setDenominazioneContoProprio(denominazione);
	  		
	  		session.setAttribute("annoCampagna",annoCampagna);
	  	}
	  	DittaUMAAziendaVO dittaUma = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");	
      SolmrLogger.debug(this,"[elencoLavConsorziBisCtrl::ricarica] dittaUma.getIdDittaUMA() VALE: "+dittaUma);	
		  getVettLavorazioni(request, umaClient,idDittaUma, annoRiferimento, dittaUMAAziendaVO.getIdAzienda(), cuaa, partitaIva, denominazione);
		  SolmrLogger.debug(this,"Sono in RICARICAAAAA DOPO di getVettLavorazioni");
		  // Visualizzazione Lav consorzi
		  //findData(request,umaClient,idDittaUma,url,dittaUMAAziendaVO.getIdAzienda());
		  request.removeAttribute("ricarica.x");
		  %>
		    <jsp:forward page="<%=url%>" />
		  <%
		  return;
	  }
	  catch(Exception e)
    {
      request.setAttribute("errorMessage",e.getMessage());
      SolmrLogger.debug(this,"ERRORE... "+e.getMessage());
      %>
        <jsp:forward page = "<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
      <%
	    return;
	  }
	}
	else
  {
    if (request.getParameter("modifica.x")!=null)
    {
      try
      {
        String[] checkBoxSel = request.getParameterValues("checkbox");
       	HashMap hmLavorazioni = (HashMap)request.getSession().getAttribute("hmLavorazioni");
       	Vector vLavConsorzi = new Vector();
       	for(int i = 0;i < checkBoxSel.length;i++)
       	{
       		Long idLavorazioneConsorzi = new Long(checkBoxSel[i]);
       		LavConsorziVO lavConsorziVO = (LavConsorziVO)hmLavorazioni.get(idLavorazioneConsorzi);
       		vLavConsorzi.add(lavConsorziVO);
       		if (lavConsorziVO.getDataFineValidita()!=null || lavConsorziVO.getDataCessazione() != null)
  	      {
  	        throw new Exception("Una delle lavorazioni non è modificabile perchè si riferisce ad un dato storicizzato");
  	      }
       	}       	
        session.setAttribute("vLavConsorzi",vLavConsorzi);
      }
      catch(Exception e)
      {
      	e.printStackTrace();
        request.setAttribute("errorMessage",e.getMessage());
	      %>
	        <jsp:forward page = "<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
	      <%
	      return;
      }
	    %>
	      <jsp:forward page="<%=modificaUrl%>" />
	    <%
	    return;
	  }
    else
    {
      if (request.getParameter("elimina.x")!=null)
      {
        try
        {
	      	String[] checkBoxSel = request.getParameterValues("checkbox");
	      	Long[] vIdLav = new Long[checkBoxSel.length];
	      	for(int i = 0;i < checkBoxSel.length;i++){
	      		vIdLav[i] = new Long(checkBoxSel[i]);
	      	}
	      	if(umaClient.isLavConsorziStoricizzate(vIdLav))
	        {
	          throw new Exception("Una delle lavorazioni non è modificabile perchè si riferisce ad un dato storicizzato");
	        }
	        SolmrLogger.debug(this,"STORICIZZATE???? "+umaClient.isLavConsorziStoricizzate(vIdLav));
	        session.setAttribute("vLavConsorzi",vIdLav);

	      }
        catch(Exception e)
        {
          request.setAttribute("errorMessage",e.getMessage());
          %>
            <jsp:forward page = "<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
          <%
	        return;
        }
        %>
          <jsp:forward page="<%=deleteUrl%>" />
	      <%
      }
      else 
      {
        // inizio cris
	      try
	      {
	       	SolmrLogger.debug(this,"Sono in CARICA DATII di elencoLavConsorziBisCtrl");
	     	  SolmrLogger.debug(this,"[elencoLavConsorziBisCtrl::service] CONTROLLO IDCONDIZIONE");	
	
	        DittaUMAVO dittaUmaVO =umaClient.findDittaVOByIdDitta(idDittaUma);
			  	boolean isConsorzio = umaClient.isDittaUmaConsorzio(dittaUmaVO.getExtIdAzienda());
			  	String versoLavorazione = (isConsorzio)?SolmrConstants.VERSO_LAVORAZIONI_E:SolmrConstants.VERSO_LAVORAZIONI_S;
			  	session.setAttribute("versoLavorazione",versoLavorazione);
	
		  		// CARICO DATI
		  		findData(request,umaClient,idDittaUma,url,dittaUMAAziendaVO.getIdAzienda());
	      }
	      catch(Exception e)
	      {
	        request.setAttribute("errorMessage",e.getMessage());
          %>
            <jsp:forward page = "<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
          <%
	        return;
	      }
      		
	      // Visualizzazione Lav consorzi
	      //findData(request,umaClient,idDittaUma,url,dittaUMAAziendaVO.getIdAzienda());
	      %>
	        <jsp:forward page="<%=url%>" />
	      <%      		
      }// end cris
      
    }
  }// end
%>


<%!
  private void getVettLavorazioni(HttpServletRequest request, UmaFacadeClient umaClient,Long idDittaUma,String annoCampagna,Long idAzienda, String cuaa, String partitaIva, String denominazione)
    throws SolmrException,Exception
  {
		SolmrLogger.debug(this,"Nel metodo getVettLavorazioni di elencoLavConsorziBisCtrl BEGIN....");
		HashMap hm = new HashMap();
	
		LavConsorziFilter filter = new LavConsorziFilter();
		
		filter.setStorico(true);		
		filter.setIdAzienda(idAzienda);
		filter.setIdDittaUma(idDittaUma);
		filter.setAnno(annoCampagna);
		filter.setVersoLavorazioni((String)(request.getSession().getAttribute("versoLavorazione")));

		filter.setCuaa(cuaa);
		filter.setPartitaIva(partitaIva);
		filter.setDenominazione(denominazione);
		
		Vector vettLavorazioni= umaClient.findListaLavorazioniConsorzi(filter);
    
    if(vettLavorazioni!=null && vettLavorazioni.size()>0){
	    for(int i=0;i<vettLavorazioni.size();i++){
	    	LavConsorziVO elem=(LavConsorziVO)vettLavorazioni.get(i);
	    	hm.put(elem.getIdLavorazioneConsorzi(),elem);						    
	    }
    }
    
    request.getSession().setAttribute("vettLavConsorzi",vettLavorazioni);
    request.getSession().setAttribute("hmLavorazioni",hm);
	  SolmrLogger.debug(this,"Nel metodo getVettLavorazioni di elencoLavConsorziBisCtrl END....");
  }

  private void findData(HttpServletRequest request,UmaFacadeClient umaClient,Long idDittaUma,String validateUrl,Long idAzienda)
    throws ValidationException
	{
		try
		{
			SolmrLogger.debug(this,"[elencoLavConsorziCtrl::service::::begin] \n\n\n\n\n\n\n\n\nidDittaUma="+idDittaUma+" \n\n\n\n\n\n\n\n\n....");
			HttpSession session = request.getSession();
			
			Vector vettAnniCampagna= umaClient.findAnniCampagnaConsorziByIdDittaUma(idDittaUma, null, (String)session.getAttribute("versoLavorazione"));
			SolmrLogger.debug(this,"vettAnniCampagna vale: "+vettAnniCampagna);
			if(null!=vettAnniCampagna && vettAnniCampagna.size()>0)
			{
				String annoAtt=String.valueOf(UmaDateUtils.getCurrentYear());
				boolean trov1=false;
				for(int i=0;i<vettAnniCampagna.size();i++)
				{
					AnnoCampagnaVO elem = (AnnoCampagnaVO)vettAnniCampagna.get(i);
					if(elem.getAnnoCampagna().equalsIgnoreCase(annoAtt)) 
					{
						trov1=true;
					}
				}
				if(!trov1)
				{
					// Aggiungo nell'elenco degli anni l'anno corrente
					AnnoCampagnaVO elem= new AnnoCampagnaVO();
		  		elem.setAnnoCampagna(String.valueOf(UmaDateUtils.getCurrentYear()));
				 	SolmrLogger.debug(this," String.valueOf(DateUtils.getCurrentYear()) VALE: "+String.valueOf(UmaDateUtils.getCurrentYear()));
				 	vettAnniCampagna.add(elem);
				}
			}
			else
			{
				SolmrLogger.debug(this," CASO VETTANNOCAMPAGNE VUOTO...");
			 	AnnoCampagnaVO elem= new AnnoCampagnaVO();
			 	elem.setAnnoCampagna(String.valueOf(UmaDateUtils.getCurrentYear()));
			 	SolmrLogger.debug(this," String.valueOf(DateUtils.getCurrentYear()) VALE: "+String.valueOf(UmaDateUtils.getCurrentYear()));
			 	vettAnniCampagna.add(elem);
		 	
			}
			Collections.sort(vettAnniCampagna);
			SolmrLogger.debug(this,"vettAnniCampagna.size vale: "+vettAnniCampagna.size());
			session.setAttribute("lavVettAnniCampagna",vettAnniCampagna);
		  	
		  // Carico la griglia delle lavorazioni
		   
		  AnnoCampagnaVO annoCampagna =(AnnoCampagnaVO)session.getAttribute("annoCampagna");
		  if(annoCampagna!=null)
		  {
		  	SolmrLogger.debug(this,"ANNOCAMPAGNA IN SESSION VALE: "+annoCampagna.getAnnoCampagna());
			SolmrLogger.debug(this,"CUAA IN SESSION VALE: "+annoCampagna.getCuaaContoProprio());
	   		SolmrLogger.debug(this,"PARTITAIVA IN SESSION VALE: "+annoCampagna.getPartitaIvaContoProprio());
	   		SolmrLogger.debug(this,"DENOMINAZIONE IN SESSION VALE: "+annoCampagna.getDenominazioneContoProprio());
		  }
		  else
		  {
		    SolmrLogger.debug(this,"ANNOCAMPAGNA IN SESSION E' NULL");
		    annoCampagna = new AnnoCampagnaVO();
		    annoCampagna.setAnnoCampagna(String.valueOf(UmaDateUtils.getCurrentYear()));
		  }	 
		  session.setAttribute("annoCampagna",annoCampagna);
		    
		   	
		  getVettLavorazioni(request,umaClient,idDittaUma, annoCampagna.getAnnoCampagna(),idAzienda,annoCampagna.getCuaaContoProprio(), annoCampagna.getPartitaIvaContoProprio(), annoCampagna.getDenominazioneContoProprio());
		 	SolmrLogger.debug(this,"[elencoLavConsorziCtrl::findData:::::end]");
		}
		catch(Exception e)
		{
		  throwValidation(e.getMessage(),validateUrl);
		}
	}
  private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException(msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }%>
