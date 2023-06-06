<%@ page language="java" contentType="text/html" isErrorPage="true" %>



<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.text.DecimalFormat"%>

<%

  UmaFacadeClient umaClient = new UmaFacadeClient();
  String storicizzazione=request.getParameter("storico");
  Vector<SuperficieAziendaVO> superfici=null;
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/elencoSuperficiCp.htm");
%>
  <%@include file = "/include/menu.inc" %>
<%

  SolmrLogger.debug(this, "  BEGIN elencoSuperficiCpView");
  
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
 
  // Carico gli elementi nella combo 'Tipo riepilogo'
  SolmrLogger.debug(this, " --- popolamento combo 'Tipo riepilogo'");
  popolaComboTipoRiepilogo(session, htmpl, request);
  
  // Carico gli elementi nella combo 'Anno riferimento'
  SolmrLogger.debug(this, " --- popolamento combo 'Anno riferimento'");
  popolaComboAnnoRiferimento(session, htmpl, request);
  
  // Setto il campo Cuaa con l'eventuale valore inserito dall'utente
  String cuaa = (String)request.getAttribute("cuaa");
  SolmrLogger.debug(this, "-- cuaa da visualizzare ="+cuaa);
  if(cuaa != null)
    htmpl.set("cuaa", cuaa);
    
  // Carico gli elementi nella combo 'Uso del suolo'
  SolmrLogger.debug(this, " --- popolamento combo 'Uso del suolo'");
  popolaComboUsoDelSuolo(session, htmpl, request);
  
  // Visualizzo le aziende trovate con la ricerca su anagrafe
  popolaTabellaAziendeAnagrafe(session, htmpl, request);
  
  // Visualizzo i dati delle superfici e in base al valore selezionato in 'Tipo riepilogo', visualizzo o no la colonna 'Comune'
  popoloTabellaSuperfici(session, htmpl, request);
  
  SolmrLogger.debug(this, "  END elencoSuperficiCpView");
  
  out.print(htmpl.text());

%>
<%!

  // Popola la tabella con il risultato della ricerca superfici 
  private void popoloTabellaSuperfici(HttpSession session,Htmpl htmpl,HttpServletRequest request) throws Exception{
    SolmrLogger.debug(this, "  BEGIN popoloTabellaSuperfici");
    
    // Prendo dalla sessione i dati trovati dalla ricerca
    Vector<SuperficieAziendaVO> elencoSuperficiCp = (Vector<SuperficieAziendaVO>)session.getAttribute("elencoSuperficiCp");
    String ricercaSuperfici = (String)session.getAttribute("ricercaSuperfici");
    SolmrLogger.debug(this, "-- ricercaSuperfici ="+ricercaSuperfici);
    
    // Solo se è stata effettuata la ricerca delle superfici, visualizzo la tabella o il messaggio di nessun dato trovato
    if(ricercaSuperfici != null){
      SolmrLogger.debug(this, "-- e' stata effettuata la ricerca delle superfici");
     
      // Se sono stati trovati dei dati
      if(elencoSuperficiCp != null && elencoSuperficiCp.size()>0){
        SolmrLogger.debug(this, "--- sono stati trovati dei dati per le superfici, numero di righe da visualizzare ="+elencoSuperficiCp.size());
        
        htmpl.newBlock("blkTableDatiSuperfici");
        // controllare la selezione di 'Tipo riepilogo', per visualizzare o meno la colonna 'Comune'
        String tipoRiepilogoSel = (String)session.getAttribute("tipoRiepilogoSel");
        SolmrLogger.debug(this, "-- tipoRiepilogoSel ="+tipoRiepilogoSel);
        
        if(new Integer(tipoRiepilogoSel).intValue() == SolmrConstants.ID_TIPO_RIEP_COMUNE){
          SolmrLogger.debug(this, "-- visualizzare anche la colonna 'Comune'");
          htmpl.newBlock("blkTableDatiSuperfici.blkColComune");
        }
        else{
          SolmrLogger.debug(this, "-- NON visualizzare anche la colonna 'Comune'");
        }
        
        DecimalFormat numericFormat4 = new DecimalFormat(SolmrConstants.FORMATO_NUMERIC_1INT_4DEC);
        
        for(int i=0;i<elencoSuperficiCp.size();i++){
          SuperficieAziendaVO sup = elencoSuperficiCp.get(i);
          htmpl.newBlock("blkTableDatiSuperfici.blkDatiSuperfici");
          
          // Comune (prov)
          if(new Integer(tipoRiepilogoSel).intValue() == SolmrConstants.ID_TIPO_RIEP_COMUNE){
            htmpl.newBlock("blkTableDatiSuperfici.blkDatiSuperfici.blkComune");
            String comune = sup.getComuniTerreniStr();
            String prov = sup.getProvinciaStr();
            String comuneProv = comune+" ("+prov+")";
            htmpl.set("blkTableDatiSuperfici.blkDatiSuperfici.blkComune.comuneProv", comuneProv);
          }
          
          // Uso del suolo
          htmpl.set("blkTableDatiSuperfici.blkDatiSuperfici.usoDelSuolo", sup.getUsoDelSuolo());
          
          // Superficie
          String superficie = numericFormat4.format(sup.getSuperficieUtilizzataDouble());
          htmpl.set("blkTableDatiSuperfici.blkDatiSuperfici.superficie",superficie);
          
        }// chiusura ciclo dati

      }
      // Se NON sono stati trovati dei dati
      else{
        SolmrLogger.debug(this, "--- NON sono stati trovati dei dati per le superfici");
        htmpl.newBlock("blkNoSuperfici");
      }
      
      
      
       


    }  
    
    SolmrLogger.debug(this, "  END popoloTabellaSuperfici");
  }

  // Popola la tabella con il risultato della ricerca di anagrafe
  private void popolaTabellaAziendeAnagrafe(HttpSession session,Htmpl htmpl,HttpServletRequest request)throws Exception{
    SolmrLogger.debug(this, "  BEGIN popolaTabellaAziendeAnagrafe");
    
    // Prendo dalla sessione le aziende trovate
    AnagAziendaVO[] elencoAziendeAnagrafe = (AnagAziendaVO[])session.getAttribute("elencoAziendeAnagrafe");
    String ricercaAnagrafe = (String)session.getAttribute("ricercaAnagrafe");
    SolmrLogger.debug(this, "-- ricercaAnagrafe ="+ricercaAnagrafe);
    
    /* Se sono state trovate aziende ed è stata effettuata la ricerca :
        - visualizzo i risultati nella tabella
        - seleziono il radio button della prima azienda
        - visualizzo il pulsante 'ricerca superfici'
      Se NON sono state trovate aziende ed è stata effettuata la ricerca :
        - visualizzo il messaggio relativo all'utente  
    */
    if(ricercaAnagrafe != null){
      SolmrLogger.debug(this, "-- e' stata effettuata la ricerca su anagrafe con il cuaa");
      // -- CASO in cui anagrafe ha restituito dei risultati
      if(elencoAziendeAnagrafe != null && elencoAziendeAnagrafe.length>0){
        SolmrLogger.debug(this, "-- ci sono risultati dalla ricerca di anagrafe");
        
        // Popolo la tabella con le aziende trovate
        htmpl.newBlock("blkTableAziende");
        for(int i=0;i<elencoAziendeAnagrafe.length;i++){
          AnagAziendaVO anagAz = elencoAziendeAnagrafe[i];
          if(anagAz != null){
            htmpl.newBlock("blkTableAziende.blkDatiAzienda");
            SolmrLogger.debug(this, "-- idAzienda ="+anagAz.getIdAzienda());
            htmpl.set("blkTableAziende.blkDatiAzienda.idAzienda", anagAz.getIdAzienda().toString());
            
            // Selezionare il radioButton della prima azienda, se non ne è stato selezionato uno dall'utente
            String idAziendaSel = (String)request.getAttribute("idAziendaSel");
            SolmrLogger.debug(this, "-- idAziendaSel ="+idAziendaSel);
            if(idAziendaSel == null || idAziendaSel.equals("")){
	            if(i == 0){
	              SolmrLogger.debug(this, "-- Selezionare il radio della PRIMA azienda");
	              htmpl.set("blkTableAziende.blkDatiAzienda.checked","checked");
	            }
            }
            else{
              if(anagAz.getIdAzienda().longValue() == new Long(idAziendaSel).longValue()){
                SolmrLogger.debug(this, "-- selezionare il radio con idAzienda ="+idAziendaSel);
                htmpl.set("blkTableAziende.blkDatiAzienda.checked","checked");
              }
            }
            
            htmpl.set("blkTableAziende.blkDatiAzienda.cuaa", anagAz.getCUAA());
            String partitaIva = "";
            if(anagAz.getPartitaIVA() != null)
              partitaIva = anagAz.getPartitaIVA();
            htmpl.set("blkTableAziende.blkDatiAzienda.partitaIva", partitaIva);
            htmpl.set("blkTableAziende.blkDatiAzienda.denominazione", anagAz.getDenominazione());
          }
        }
                
        // Visualizzo il pulsante di 'ricerca superfici'
        SolmrLogger.debug(this, "-- Visualizzo il pulsante di 'ricerca superfici'");
        htmpl.newBlock("buttonRicercaSup");
      }
      // -- CASO in cui anagrafe NON ha restituito dei risultati
      else{
        SolmrLogger.debug(this, "-- NON ci sono risultati dalla ricerca di anagrafe");
        htmpl.newBlock("blkNoAziende");
      }
    }
    
    SolmrLogger.debug(this, "  BEGIN popolaTabellaAziendeAnagrafe");
  }

  private void popolaComboAnnoRiferimento(HttpSession session,Htmpl htmpl,HttpServletRequest request) throws Exception{
    SolmrLogger.debug(this, "  BEGIN popolaComboAnnoRiferimento");
    
    Vector<CodeDescr> annoRif = (Vector<CodeDescr>)session.getAttribute("anniRiferimento");
    
    // Controllo se è stato selezionato un tipo di riepilogo, altrimenti seleziono anno in corso
    String annoRifSel = request.getParameter("annoRiferimento");
    SolmrLogger.debug(this, " - annoRifSel ="+annoRifSel);
    
    if(annoRifSel == null || annoRifSel.equals("")){
      annoRifSel = String.valueOf(UmaDateUtils.getCurrentYear().intValue());      
    }
    
    // Popolo la combo con gli elementi
    for(int i=0;i<annoRif.size();i++){
  	  CodeDescr annoRifCd = (CodeDescr)annoRif.get(i);
  	  htmpl.newBlock("blkComboAnno");  		
  		
  	  htmpl.set("blkComboAnno.idAnnoRiferimento",""+annoRifCd.getCode().toString());
      htmpl.set("blkComboAnno.annoRiferimentoDesc",""+annoRifCd.getDescription());        		
  	  if(annoRifCd.getCode().intValue() == new Integer(annoRifSel).intValue())	
       		htmpl.set("blkComboAnno.annoRiferimentoSel","selected");  		
    }
        
    SolmrLogger.debug(this, "  END popolaComboAnnoRiferimento");
  }

  private void popolaComboTipoRiepilogo(HttpSession session,Htmpl htmpl,HttpServletRequest request) throws Exception{
    SolmrLogger.debug(this, "  BEGIN popolaComboTipoRiepilogo");
    
    Vector<CodeDescr> tipiRiepilogo = (Vector<CodeDescr>)session.getAttribute("tipiRiepilogo");
    
    // Controllo se è stato selezionato un tipo di riepilogo, altrimenti seleziono quello con id=2 di default
    String tipoRiepSel = request.getParameter("tipoRiepilogo");
    SolmrLogger.debug(this, " - tipoRiepSel ="+tipoRiepSel);
    
    if(tipoRiepSel == null || tipoRiepSel.equals("")){
      int tipoRiepSelInt = SolmrConstants.ID_TIPO_RIEP_LAV_SUOLO;
      tipoRiepSel = new Integer(tipoRiepSelInt).toString();
    }
    
    // Popolo la combo con gli elementi
    for(int i=0;i<tipiRiepilogo.size();i++){
  	  CodeDescr tipoRiep = (CodeDescr)tipiRiepilogo.get(i);
  	  htmpl.newBlock("blkTipoRiepilogo");  		
  		
  	  htmpl.set("blkTipoRiepilogo.idTipoRiepilogo",""+tipoRiep.getCode().toString());
      htmpl.set("blkTipoRiepilogo.tipoRiepilogoDesc",""+tipoRiep.getDescription());        		
  	  if(tipoRiep.getCode().intValue() == new Integer(tipoRiepSel).intValue()){
  	    SolmrLogger.debug(this, " - selezionare tipo riepilogo ="+tipoRiep.getCode());	
        htmpl.set("blkTipoRiepilogo.idTipoRiepilogoSel","selected");  		
      } 		
    }
        
    SolmrLogger.debug(this, "  END popolaComboTipoRiepilogo");
  }
  
  
  private void popolaComboUsoDelSuolo(HttpSession session,Htmpl htmpl,HttpServletRequest request)throws Exception{
    SolmrLogger.debug(this, "   BEGIN popolaComboUsoDelSuolo");
    
    Vector<CodeDescr> usiDelSuolo = (Vector<CodeDescr>)session.getAttribute("usiDelSuolo");
    
    // Controllo quale uso del suolo è stato selezionato
    String usoDelSuoloSel = request.getParameter("usoDelSuolo");
    SolmrLogger.debug(this, " - usoDelSuoloSel ="+usoDelSuoloSel);
    
    // Popolo la combo con gli elementi
    for(int i=0;i<usiDelSuolo.size();i++){
  	  CodeDescr usoDelSuolo = (CodeDescr)usiDelSuolo.get(i);
  	  htmpl.newBlock("blkUsoDelSuolo");  		
  		
  	  htmpl.set("blkUsoDelSuolo.idUsoDelSuolo",""+usoDelSuolo.getCode().toString());
      htmpl.set("blkUsoDelSuolo.usoDelSuoloDesc",""+usoDelSuolo.getDescription());        		
  	  
  	  if(usoDelSuoloSel != null && !usoDelSuoloSel.equals("")){
	  	  if(usoDelSuolo.getCode().intValue() == new Integer(usoDelSuoloSel).intValue()){
	  	    SolmrLogger.debug(this, " - selezionare uso del suolo ="+usoDelSuolo.getCode());	
	        htmpl.set("blkUsoDelSuolo.idUsoDelSuoloSel","selected");  		
	      } 		
      }
    }    
    SolmrLogger.debug(this, "   END popolaComboUsoDelSuolo");
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

%>

