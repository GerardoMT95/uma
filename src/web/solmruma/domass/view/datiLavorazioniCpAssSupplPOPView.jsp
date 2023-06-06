<%@page import="java.math.BigDecimal"%>
<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
    SolmrLogger.debug(this,"   BEGIN datiLavorazioniCpAssSupplPOPView");

    String layoutUrl = "/domass/layout/datiLavorazioniCpAssSupplPOP.htm";
    ValidationException valEx;
    Validator validator = new Validator(layoutUrl);
    Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layoutUrl);

    SolmrLogger.debug(this, "--- recupero l'elenco delle Lavorazioni Conto Proprio per l'Assegnazione supplementare");
    Vector<LavContoProprioVO> elencoLavContoProprio = ( Vector<LavContoProprioVO>)request.getAttribute("elencoLavorazioniAssSupplPop");
   
    String annoDomanda = (String)request.getAttribute("annoRiferimento"); 
    SolmrLogger.debug(this, "--   annoDomanda ="+annoDomanda);
    htmpl.set("annoDiRiferimento", annoDomanda);
   
    if(elencoLavContoProprio == null || elencoLavContoProprio.size() == 0){
      SolmrLogger.debug(this, "-- NON ci sono lavorazioni da visualizzare");
      htmpl.newBlock("blkNoLavorazioni");
    }
    else{
      SolmrLogger.debug(this, "-- Ci sono lavorazioni da visualizzare");
      
      SolmrLogger.debug(this, "--- sono state trovate delle Lavorazioni Conto Proprio, quante ="+elencoLavContoProprio.size());  	  
      htmpl.newBlock("blkLavorazioni");
                       
      for(int i =0;i<elencoLavContoProprio.size();i++){
        htmpl.newBlock("blkLavorazioni.blkLavContoProprio");
        LavContoProprioVO lavCP = elencoLavContoProprio.get(i);
        
        htmpl.set("blkLavorazioni.blkLavContoProprio.idLavContoProprio", lavCP.getIdLavorazioneContoProprio());
        htmpl.set("blkLavorazioni.blkLavContoProprio.usoDelSuolo", lavCP.getUsoDelSuolo());
        htmpl.set("blkLavorazioni.blkLavContoProprio.lavorazione", lavCP.getLavorazione());
        htmpl.set("blkLavorazioni.blkLavContoProprio.motivoLavoraz", lavCP.getDescrMotivoLavoraz());
        htmpl.set("blkLavorazioni.blkLavContoProprio.superficie", StringUtils.formatDouble4(lavCP.getSuperficie()));
        htmpl.set("blkLavorazioni.blkLavContoProprio.unitaMisura", lavCP.getUnitaMisura());
        htmpl.set("blkLavorazioni.blkLavContoProprio.numEsecuzioni", lavCP.getNumEsecuzioni());      
        htmpl.set("blkLavorazioni.blkLavContoProprio.litriCarburante", StringUtils.formatDouble2(lavCP.getLitriLavorazione()));
        
        
        
        htmpl.set("blkLavorazioni.blkLavContoProprio.litriBase", StringUtils.formatDouble2(lavCP.getLitriBase()));
        htmpl.set("blkLavorazioni.blkLavContoProprio.litriMedioImpasto", StringUtils.formatDouble2(lavCP.getLitriMedioImpasto()));
        htmpl.set("blkLavorazioni.blkLavContoProprio.litriAcclivita", StringUtils.formatDouble2(lavCP.getLitriAcclivita()));      
	 	    
	          
      }// chiusura ciclo sugli elementi trovati
      
      // Valore del totale carburante : TOTALE RELATIVO AL RISULTATO COMPLETO DELLA RICERCA ed esclusivamente dei record con DATA_FINE_VALIDITA e DATA_CESSAZIONE non valorizzate        
      htmpl.set("blkLavorazioni.totaleLitriCarburante", StringUtils.formatDouble2(elencoLavContoProprio.get(0).getTotaleLitriLavorazione()));
      
      
      // --------- Visualizzare il Carburante per frammentazione
      Vector<CarburanteFrammentazioneVO> elencoCarburantiPerFrammentaz = (Vector<CarburanteFrammentazioneVO>)request.getAttribute("elencoCarburantiPerFrammentazAssSuppl");
      if(elencoCarburantiPerFrammentaz != null && elencoCarburantiPerFrammentaz.size()>0){
        SolmrLogger.debug(this, "-- Ci sono carburanti per frammentazione");
        htmpl.newBlock("blkFrammentazioni");
        
        BigDecimal totSuperficie = new BigDecimal(0);
        BigDecimal totLitriFrammentazione = new BigDecimal(0);
        for(int i=0;i<elencoCarburantiPerFrammentaz.size();i++){
          CarburanteFrammentazioneVO carburFrammVO = elencoCarburantiPerFrammentaz.get(i);
          htmpl.newBlock("blkFrammentazioni.blkUsiDelSuoloFramm");
          htmpl.set("blkFrammentazioni.blkUsiDelSuoloFramm.usoDelSuolo", carburFrammVO.getDescrUsoDelSuolo());
          
          htmpl.set("blkFrammentazioni.blkUsiDelSuoloFramm.superficie", StringUtils.formatDouble4(carburFrammVO.getSuperficie()));
          totSuperficie = totSuperficie.add(carburFrammVO.getSuperficie());
          
          htmpl.set("blkFrammentazioni.blkUsiDelSuoloFramm.litriFrammentazione", StringUtils.formatDouble2(carburFrammVO.getLitriFrammentazione()));
          totLitriFrammentazione = totLitriFrammentazione.add(carburFrammVO.getLitriFrammentazione());
        }  
        
        SolmrLogger.debug(this, "-- totSuperficie ="+totSuperficie);
        htmpl.set("blkFrammentazioni.totSuperficie", StringUtils.formatDouble4(totSuperficie));
        SolmrLogger.debug(this, "-- totLitriFrammentazione ="+totLitriFrammentazione);
        htmpl.set("blkFrammentazioni.totLitriFrammentazione", StringUtils.formatDouble2(totLitriFrammentazione));         
      }
    }


    it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

    it.csi.solmr.presentation.security.Autorizzazione aut= (it.csi.solmr.presentation.security.Autorizzazione)
    it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ACCESSO_SISTEMA");
    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
    aut.writeBanner(htmpl, ruoloUtenza,request);



    SolmrLogger.debug(this,"   END datiLavorazioniCpPOPView");
    out.print(htmpl.text());

%>