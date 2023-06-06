  <%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.papua.papuaserv.presentation.ws.profilazione.axis.UtenteAbilitazioni" %>

<%

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  AnagFacadeClient anagFacadeClient = new AnagFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application)

                .getHtmpl("/anag/layout/ricercaAzienda.htm");

%><%@include file = "/include/menu.inc" %><%

  SolmrLogger.debug(this, "BEGIN ricercaAziendaUMAView");

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

//  HtmplUtil.clearCachedEntity("tipiIntermediarioUmaProv", request);

  //Valorizza segnaposto htmpl

  HtmplUtil.setValues(htmpl, request);

  //Valorizza segnaposto errore htmpl

  HtmplUtil.setErrors(htmpl, errors, request);

  Collection collProvUMA = (Collection)anagFacadeClient.getProvinceByRegione(SolmrConstants.ID_REGIONE);

  Collection collIntermediarioUmaProv = (Collection)anagFacadeClient.getTipiIntermediarioUmaProv();
  
  SolmrLogger.debug(this, "-- idUtente ="+ruoloUtenza.getIdUtente());
  SolmrLogger.debug(this, "--  ruoloUtenza.isUtenteRegionale() ="+ruoloUtenza.isUtenteRegionale());
  Vector<CodeDescr> ufficiUma = (Vector<CodeDescr>)umaFacadeClient.getUfficiUma(ruoloUtenza);
  
  Vector<CodeDescr> statiDomandaAss = (Vector<CodeDescr>)umaFacadeClient.getStatiDomanda();

  DittaUMAAziendaVO dittaAziendaVO = (DittaUMAAziendaVO)(request.getAttribute("dittaAziendaVO"));



  if(ruoloUtenza.isUtenteIntermediario()){

    // cerco il codice dell'intermediario in base al codice dell'utente

    // a cui è associato l'intermediario

    try{

      UtenteIrideVO utenteVO = umaFacadeClient.getUtenteIride(ruoloUtenza.getIdUtente());

      if(utenteVO!=null && utenteVO.getIdIntermediario()!=null)

        request.setAttribute("intermediario", utenteVO.getIdIntermediario().toString());

      htmpl.newBlock("blkIntermediario");
      UtenteAbilitazioni utenteAbilitazioni = (UtenteAbilitazioni) session.getAttribute("utenteAbilitazioni");
      // htmpl.set("blkIntermediario.intermediario", utenteVO.getDenominazione());     
      htmpl.set("blkIntermediario.intermediario",utenteAbilitazioni.getEnteAppartenenza().getIntermediario().getDenominazioneEnte()); 
	  SolmrLogger.debug(this, "utenteAbilitazioni.getEnteAppartenenza().getIntermediario().getDenominazioneEnte() ="+utenteAbilitazioni.getEnteAppartenenza().getIntermediario().getDenominazioneEnte());
    }

    catch(SolmrException sex){

      htmpl.newBlock("blkNoIntermediario");

    }

  }

  else{

    htmpl.newBlock("blkNoIntermediario");

    String intermediarioUmaProv = (String)request.getParameter("intermUmaProv");

      Iterator iterImtermUmaProv = collIntermediarioUmaProv.iterator();

      while(iterImtermUmaProv.hasNext()){

        CodeDescription cdIntermUmaProv = (CodeDescription)iterImtermUmaProv.next();

        htmpl.newBlock("blkNoIntermediario.comboIntermUmaProv");

        htmpl.set("blkNoIntermediario.comboIntermUmaProv.idIntermUmaProv",""+cdIntermUmaProv.getCode());

        htmpl.set("blkNoIntermediario.comboIntermUmaProv.intermUmaProv",cdIntermUmaProv.getDescription());





        if(intermediarioUmaProv != null && !intermediarioUmaProv.trim().equals("") &&

           cdIntermUmaProv.getCode().equals(new Integer(intermediarioUmaProv))){



          htmpl.set("blkNoIntermediario.comboIntermUmaProv.idIntermUmaProvSel","selected");

        }

      }

  }


  String sedelegProvincia = (String)request.getParameter("sedelegProvincia");

  if (sedelegProvincia==null && ruoloUtenza!=null && ruoloUtenza.isUtenteProvinciale() && !ruoloUtenza.isUtenteRegionale())
  {

    Iterator iterProvincia = collProvUMA.iterator();

    while(iterProvincia.hasNext()){

      ProvinciaVO provinciaVO = (ProvinciaVO)iterProvincia.next();

      if (provinciaVO.getIstatProvincia().equals(ruoloUtenza.getIstatProvincia())){

        htmpl.set("sedelegProvincia",provinciaVO.getSiglaProvincia());

      }

    }

  }



  String idProvUma = (String)request.getParameter("provUMA");

  if(collProvUMA!=null&&collProvUMA.size()>0){

    Iterator iterProvincia = collProvUMA.iterator();

    while(iterProvincia.hasNext()){

      ProvinciaVO provinciaVO = (ProvinciaVO)iterProvincia.next();

      htmpl.newBlock("comboProvUMA");

      htmpl.set("comboProvUMA.idProvUMA",""+provinciaVO.getIstatProvincia());

      htmpl.set("comboProvUMA.provUMA",provinciaVO.getSiglaProvincia());

      if(dittaAziendaVO!=null && provinciaVO.getIstatProvincia().equals(dittaAziendaVO.getProvUMA())||

   idProvUma!=null && provinciaVO.getIstatProvincia().equals(idProvUma)||

   idProvUma==null && ruoloUtenza!=null && ruoloUtenza.isUtenteProvinciale() && provinciaVO.getIstatProvincia().equals(ruoloUtenza.getIstatProvincia())

    && !ruoloUtenza.isUtenteRegionale()){

        htmpl.set("comboProvUMA.idProvUMASelPunt","selected");

      }

    }

  }



  String provUMADomAss = (String)request.getParameter("provUMADomAss");



  if(collProvUMA!=null&&collProvUMA.size()>0){

    Iterator iterProvincia = collProvUMA.iterator();

    while(iterProvincia.hasNext()){

      ProvinciaVO provinciaVO = (ProvinciaVO)iterProvincia.next();

      htmpl.newBlock("comboProvUMADomAss");

      htmpl.set("comboProvUMADomAss.idProvUMADomAss",""+provinciaVO.getIstatProvincia());

      htmpl.set("comboProvUMADomAss.provUMADomAss",provinciaVO.getSiglaProvincia());

      if(dittaAziendaVO!=null && provinciaVO.getIstatProvincia().equals(dittaAziendaVO.getProvUMADomAss())||

   provUMADomAss!=null && provinciaVO.getIstatProvincia().equals(provUMADomAss)||

   provUMADomAss==null && ruoloUtenza!=null && ruoloUtenza.isUtenteProvinciale() && provinciaVO.getIstatProvincia().equals(ruoloUtenza.getIstatProvincia())

    && !ruoloUtenza.isUtenteRegionale()){

        htmpl.set("comboProvUMADomAss.idProvUMAda","selected");

      }

    }

  }
  
  // Combo Uffici Uma
  String uffUMADomAss = (String)request.getParameter("uffUMADomAss");
  SolmrLogger.debug(this, "uffUMADomAss selezionato ="+uffUMADomAss);
  if(ufficiUma !=null && ufficiUma.size()>0){
	SolmrLogger.debug(this, "-- Carico gli uffici Uma nella combo");
	Iterator<CodeDescr> iterUfficio = ufficiUma.iterator();	
	while(iterUfficio.hasNext()){
	  CodeDescr ufficioDescr = (CodeDescr)iterUfficio.next();	
	  htmpl.newBlock("comboUfficioUma");	
	  htmpl.set("comboUfficioUma.idUfficoUma",""+ufficioDescr.getCode());	
	  htmpl.set("comboUfficioUma.ufficioUma",ufficioDescr.getDescription());
	  
	  if(uffUMADomAss != null && !uffUMADomAss.equals("") && new Integer(uffUMADomAss).intValue()== ufficioDescr.getCode().intValue()){
		  htmpl.set("comboUfficioUma.idUfficoUmaSel", "selected");
	  }
	}
  }
  
  
 //Combo Stato Domanda + stato Domanda Assegnazione Supplementare
 String statoDomandaAssSel = (String)request.getParameter("tipiStatoDomanda");
 SolmrLogger.debug(this, "statoDomandaAss selezionato ="+statoDomandaAssSel);
 if(statiDomandaAss !=null && statiDomandaAss.size()>0){
	SolmrLogger.debug(this, "-- Carico gli stati domanda nella combo");
	// Aggiungo lo stato fittizio 'In attesa di validazione PA - Supplementi' per filtrare sullo stato della Domanda di Assegnazione Supplementare
	CodeDescr statoAssSuppl = new CodeDescr();
	statoAssSuppl.setCode(new Integer(0));
	statoAssSuppl.setDescription("In attesa di validazione PA - Supplementi");
	statiDomandaAss.add(statoAssSuppl);
	CodeDescr statoAssSupplResp = new CodeDescr();
	statoAssSupplResp.setCode(new Integer(1));
	statoAssSupplResp.setDescription("Respinta - Supplementi");
	statiDomandaAss.add(statoAssSupplResp);
	Iterator<CodeDescr> iterStatiDomanda = statiDomandaAss.iterator();	
	while(iterStatiDomanda.hasNext()){
	  CodeDescr statoDomanda = (CodeDescr)iterStatiDomanda.next();	
	  htmpl.newBlock("comboTipiStatoDomanda");	
	  htmpl.set("comboTipiStatoDomanda.idStatoDomanda",""+statoDomanda.getCode());	
	  htmpl.set("comboTipiStatoDomanda.statoDomanda",statoDomanda.getDescription());
	  
	  if(statoDomandaAssSel != null && !statoDomandaAssSel.equals("") && new Integer(statoDomandaAssSel).intValue()== statoDomanda.getCode().intValue()){
		  htmpl.set("comboTipiStatoDomanda.idStatoDomandaSel", "selected");
	  }
	}
 }
  
  
  // Combo Stato libretto
  String statoLibrettoDomAss = (String)request.getParameter("statoLibrettoDomAss");
  SolmrLogger.debug(this, "statoLibrettoDomAss selezionato ="+statoLibrettoDomAss);
  
  // Valori : stampato, da stampare 
  Vector<CodeDescr> statiLibretto = new Vector<CodeDescr>();
  CodeDescr codeDescr = new CodeDescr();
  codeDescr.setCode(new Integer(SolmrConstants.ID_LIBRETTO_DA_STAMPARE));
  codeDescr.setDescription(SolmrConstants.DESCR_LIBRETTO_DA_STAMPARE);
  statiLibretto.add(codeDescr);
  codeDescr = new CodeDescr();
  codeDescr.setCode(new Integer(SolmrConstants.ID_LIBRETTO_STAMPATO));
  codeDescr.setDescription(SolmrConstants.DESCR_LIBRETTO_STAMPATO);
  statiLibretto.add(codeDescr);
  
  if(statiLibretto !=null && statiLibretto.size()>0){
		SolmrLogger.debug(this, "-- Carico gli stati del libretto nella combo");
		Iterator<CodeDescr> iterStatiLibretto = statiLibretto.iterator();	
		while(iterStatiLibretto.hasNext()){
		  CodeDescr statoLibretto = (CodeDescr)iterStatiLibretto.next();	
		  htmpl.newBlock("comboStatoLibrettoDomAss");	
		  htmpl.set("comboStatoLibrettoDomAss.idStatoLibrettoDomAss",""+statoLibretto.getCode());	
		  htmpl.set("comboStatoLibrettoDomAss.statoLibrettoDomAss",statoLibretto.getDescription());
		  
		  if(statoLibrettoDomAss != null && !statoLibrettoDomAss.equals("") && new Integer(statoLibrettoDomAss).intValue()== statoLibretto.getCode().intValue()){
			  htmpl.set("comboStatoLibrettoDomAss.idStatoLibrettoSel", "selected");
		  }
		}
  }


  String attivita = (String)session.getAttribute("attivita");

  SolmrLogger.debug(this,"Valore di attivita: "+attivita);

  if(attivita == null) {

    htmpl.set("checked","checked");

  }

  else {

    if(attivita.equals("true")) {

      htmpl.set("checked","checked");

    }

  }

  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl, exception);



%>

<%= htmpl.text()%>