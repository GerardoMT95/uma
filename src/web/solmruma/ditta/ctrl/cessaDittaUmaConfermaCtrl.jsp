<%@ page import="it.csi.solmr.util.*,it.csi.solmr.dto.uma.*" %>

<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
  String iridePageName = "cessaDittaUmaConfermaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%
  SolmrLogger.debug(this, "cessaDittaUmaConfermaCtrl.jsp - Begin");

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  String url = "/ditta/layout/cessaDittaUmaSalvata.htm";
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  SolmrLogger.debug(this, "Before session.removeAttribute(\"numFoglio\");");
  SolmrLogger.debug(this, "Before session.removeAttribute(\"numRiga\");");
  String numeroFoglio = "";
  String numeroRiga = "";
  session.removeAttribute("numFoglio");
  session.removeAttribute("numRiga");

  SolmrLogger.debug(this, "Before if(request.getParameter(\"conferma\") != null)");
    if(request.getParameter("conferma") != null){
	  SolmrLogger.debug(this, "conferma........................");
	  DomandaAssegnazione daVO = new DomandaAssegnazione();
	  Vector vectCrVO = new Vector();
	 // Vector vectBP = new Vector();
	  Date dataCessazione = null;
	  SolmrLogger.debug(this, "prima di anno");
	  String anno = request.getParameter("anno");
	  SolmrLogger.debug(this, "dopo anno: "+anno);
	
	  Date dataDoc = null;
	
	  SolmrLogger.debug(this, "prima di dataConsegnaDoc!!!!!!!!!!!!!!!");
	  if(request.getParameter("dataConsegnaDoc") != null && !request.getParameter("dataConsegnaDoc").equals(""))
	    dataDoc = DateUtils.parseDate(request.getParameter("dataConsegnaDoc"));
	  SolmrLogger.debug(this, "dopo dataConsegnaDoc!!!!!!!!!!!!!!!");
	
	  if(request.getParameter("dataCessazioneAtt") != null && !request.getParameter("dataCessazioneAtt").equals("")){
	    dataCessazione = DateUtils.parseDate(request.getParameter("dataCessazioneAtt"));
	  }
	
	  Long idDittaUma = null;
	  SolmrLogger.debug(this, "prima di idDittaUMA!!!!!!!!!!!!!!! "+request.getParameter("idDittaUMA"));
	  if(request.getParameter("idDittaUMA") != null && !request.getParameter("idDittaUMA").equals(""))
	    idDittaUma = new Long(request.getParameter("idDittaUMA"));
	  SolmrLogger.debug(this, "idDittaUma: "+idDittaUma);
	  daVO.setIdDitta(idDittaUma.longValue());
	
	  if(request.getParameter("numDocumenti") != null && !request.getParameter("numDocumenti").equals(""))
	    daVO.setNumeroDocumenti(new Integer(request.getParameter("numDocumenti")).intValue());
	  daVO.setDataDocumentazione(dataDoc);
	  String extIdIntermediarioDocCarta=request.getParameter("extIdIntermediarioDocCarta");
	  String dataRicevutaDocumenti=request.getParameter("dataRicevutaDocumenti");
	  String numeroRicevutaDocumenti=request.getParameter("numeroRicevutaDocumenti");
	  if (Validator.isNotEmpty(extIdIntermediarioDocCarta))
	  {
	    daVO.setExtIdIntermediarioDocCarta(new Long(extIdIntermediarioDocCarta));
	  }
	
	  if (Validator.isNotEmpty(dataRicevutaDocumenti))
	  {
	    daVO.setDataRicevutaDocumenti(DateUtils.parseDate(dataRicevutaDocumenti));
	  }
	
	  if (Validator.isNotEmpty(numeroRicevutaDocumenti))
	  {
	    daVO.setNumeroRicevutaDocumenti(new Long(numeroRicevutaDocumenti));
	  }

//GASOLIO
  ConsumoRimanenzaVO crVOGas = null;

  Integer idGas = new Integer(SolmrConstants.ID_GASOLIO);
  Integer idBenz = new Integer(SolmrConstants.ID_BENZINA);

  if(request.getParameter("rimAttualeCPGas") != null && !request.getParameter("rimAttualeCPGas").equals("0") ||
     request.getParameter("rimAttualeCTGas") != null && !request.getParameter("rimAttualeCTGas").equals("0") ||
     request.getParameter("consumoCPGas") != null && !request.getParameter("consumoCPGas").equals("0") ||
     request.getParameter("consumoCTGas") != null && !request.getParameter("consumoCTGas").equals("0") ||
     request.getParameter("consumoSerraGas") != null && !request.getParameter("consumoSerraGas").equals("0") ||
     request.getParameter("rimanenzaSerraGas") != null && !request.getParameter("rimanenzaSerraGas").equals("0")
     ){

    crVOGas = new ConsumoRimanenzaVO();

    if(request.getParameter("rimAttualeCPGas") != null){
      crVOGas.setRimContoProp(new Long(""+request.getParameter("rimAttualeCPGas")));
    }
    if(request.getParameter("rimAttualeCTGas") != null){
      crVOGas.setRimContoTer(new Long(request.getParameter("rimAttualeCTGas")));
    }
    if(request.getParameter("consumoCPGas") != null){
      crVOGas.setConsContoProp(new Long(request.getParameter("consumoCPGas")));
    }
    if(request.getParameter("consumoCTGas") != null){
      crVOGas.setConsContoTer(new Long(request.getParameter("consumoCTGas")));
    }

    //061031 - Carburante x Serra - Begin
    if(request.getParameter("consumoSerraGas") != null){
      crVOGas.setConsSerra(new Long(request.getParameter("consumoSerraGas")));
    }
    if(request.getParameter("rimanenzaSerraGas") != null){
      crVOGas.setRimSerra(new Long(request.getParameter("rimanenzaSerraGas")));
    }
    //061031 - Carburante x Serra - End
  }

  if(crVOGas != null){
    SolmrLogger.debug(this, "consumo rimanenza gasolio != null ");
    crVOGas.setIdCarburante(idGas);
    vectCrVO.add(crVOGas);
  }


//BENZINA
  ConsumoRimanenzaVO crVOBenz = null;
  if(request.getParameter("rimAttualeCPBenz") != null && !request.getParameter("rimAttualeCPBenz").equals("0") ||
     request.getParameter("rimAttualeCTBenz") != null && !request.getParameter("rimAttualeCTBenz").equals("0") ||
     request.getParameter("consumoCPBenz") != null && !request.getParameter("consumoCPBenz").equals("0") ||
     request.getParameter("consumoCTBenz") != null && !request.getParameter("consumoCTBenz").equals("0") ||
     request.getParameter("consumoSerraBenz") != null && !request.getParameter("consumoSerraBenz").equals("0") ||
     request.getParameter("rimanenzaSerraBenz") != null && !request.getParameter("rimanenzaSerraBenz").equals("0")
     ){

    crVOBenz = new ConsumoRimanenzaVO();

    if(request.getParameter("rimAttualeCPBenz") != null){
      crVOBenz.setRimContoProp(new Long(request.getParameter("rimAttualeCPBenz")));
    }
    if(request.getParameter("rimAttualeCTBenz") != null){
      crVOBenz.setRimContoTer(new Long(request.getParameter("rimAttualeCTBenz")));
    }
    if(request.getParameter("consumoCPBenz") != null){
      crVOBenz.setConsContoProp(new Long(request.getParameter("consumoCPBenz")));
    }
    if(request.getParameter("consumoCTBenz") != null){
      crVOBenz.setConsContoTer(new Long(request.getParameter("consumoCTBenz")));
    }

    //061031 - Carburante x Serra - Begin
    if(request.getParameter("consumoSerraBenz") != null){
      crVOBenz.setConsSerra(new Long(request.getParameter("consumoSerraBenz")));
    }
    if(request.getParameter("rimanenzaSerraBenz") != null){
      crVOBenz.setRimSerra(new Long(request.getParameter("rimanenzaSerraBenz")));
    }

    SolmrLogger.debug(this, "\n\n\n############################1");
    SolmrLogger.debug(this, "request.getParameter(\"rimanenzaSerraBenz\"): "+request.getParameter("rimanenzaSerraBenz"));
    SolmrLogger.debug(this, "crVOBenz.getRimSerra(): "+crVOBenz.getRimSerra());
    SolmrLogger.debug(this, "############################\n\n\n");
    //061031 - Carburante x Serra - End
  }

  if(crVOBenz != null){
    SolmrLogger.debug(this, "consumo rimanenza benzina != null");
    crVOBenz.setIdCarburante(idBenz);
    vectCrVO.add(crVOBenz);
  }


 /* --- Se ci sono delle rimanenze attuali :
  -  se ci sono rimanenze per serra : dovrà essere inserito un record su DB_BUONO_PRELIEVO con CARBURANTE_PER_SERRA = 'S'
       - controllare se è rimanenza di gasolio : inserire un record su DB_BUONO_CARBURANTE con ID_CARBURANTE = 2
       - controllare se è rimanenza di benzina : inserire un record su DB_BUONO_CARBURANTE con ID_CARBURANTE = 1
  -  se ci sono rimanenze conto proprio o conto terzi : dovrà essere effettuata la somma ed inserito un record su  DB_BUONO_PRELIEVO con CARBURANTE_PER_SERRA = 'N'
       - controllare se è rimanenza di gasolio : inserire un record su DB_BUONO_CARBURANTE con ID_CARBURANTE = 2
       - controllare se è rimanenza di benzina : inserire un record su DB_BUONO_CARBURANTE con ID_CARBURANTE = 1  
 */
  Vector<BuonoPrelievoVO> elencoBuoniPrelievo = null;
  if( (request.getParameter("rimAttualeCPGas") != null && new Integer(request.getParameter("rimAttualeCPGas")).intValue() != 0)
     || (request.getParameter("rimAttualeCPBenz") != null && new Integer(request.getParameter("rimAttualeCPBenz")).intValue() != 0)
     || (request.getParameter("rimAttualeCTGas") != null && new Integer(request.getParameter("rimAttualeCTGas")).intValue() != 0)
     || (request.getParameter("rimAttualeCTBenz") != null && new Integer(request.getParameter("rimAttualeCTBenz")).intValue() != 0)
     || (request.getParameter("rimanenzaSerraGas") != null && new Integer(request.getParameter("rimanenzaSerraGas")).intValue() != 0)
     || (request.getParameter("rimanenzaSerraBenz") != null && new Integer(request.getParameter("rimanenzaSerraBenz")).intValue() != 0)
     ){
       SolmrLogger.debug(this, " --- ci sono RIMANENZA ATTUALI");
       elencoBuoniPrelievo = new Vector<BuonoPrelievoVO>(); 
             
       // Controllo se ci sono rimanenze PER SERRA
       if( ( (request.getParameter("rimanenzaSerraGas") != null && new Integer(request.getParameter("rimanenzaSerraGas")).intValue() != 0)) ||
           ( (request.getParameter("rimanenzaSerraBenz") != null && new Integer(request.getParameter("rimanenzaSerraBenz")).intValue() != 0))
          ){
          SolmrLogger.debug(this, " --- *** ci sono RIMANENZE PER SERRA ***");
          
          // Costruisco l'oggetto da inserirei in DB_BUONO_PRELIEVO
          BuonoPrelievoVO buonoPrel = new BuonoPrelievoVO();
    	  buonoPrel.setAnnoRiferimento(new Long(request.getParameter("anno")));
          buonoPrel.setNumeroBlocco(new Long(SolmrConstants.NUMERO_BLOCCO));
          buonoPrel.setNumeroBuono(new Long(SolmrConstants.NUMERO_BUONO));
          buonoPrel.setCarburantePerSerra("S");
          
          if(request.getParameter("provincia") != null)
            buonoPrel.setExtProvinciaProvenienza(request.getParameter("provincia"));
            
          // Ditta alla quale vengono cedute le rimanenze  
          if(request.getParameter("numDittaUmaConsRim") != null){            
            buonoPrel.setIdDittaUma(NumberUtils.parseLong(request.getParameter("numDittaUmaConsRim")));
            SolmrLogger.debug(this, "--- Ditta alla quale vengono cedute le rimanenze ="+buonoPrel.getIdDittaUma());
          }  
            
          String siglaProvincia = buonoPrel.getExtProvinciaProvenienza();
          buonoPrel.setSiglaProvinciaProvenienza(siglaProvincia);
          String istatProvincia = umaFacadeClient.getIstatProvinciaBySiglaProvincia(siglaProvincia);
          SolmrLogger.debug(this, " --- extProvinciaProvenienza ="+istatProvincia);
          buonoPrel.setExtProvinciaProvenienza(istatProvincia);  
                    
          //  **** Controllo se le rimanenze PER SERRA sono di benzina e/o gasolio ****
          Vector<BuonoCarburanteVO> elencoBuoniCarburante = new Vector<BuonoCarburanteVO>();              
                
          // - Caso GASOLIO PER SERRA
          if((request.getParameter("rimanenzaSerraGas") != null && new Integer(request.getParameter("rimanenzaSerraGas")).intValue() != 0)){
            SolmrLogger.debug(this, " --- ci sono RIMANENZE PER SERRA DI GASOLIO");            
            // Costruisco l'oggetto da inserire in DB_BUONO_CARBURANTE
            String rimanenzaSerraGas = request.getParameter("rimanenzaSerraGas");
            SolmrLogger.debug(this, " --- rimanenzaSerraGas ="+rimanenzaSerraGas);
            BuonoCarburanteVO buonoCarb = new BuonoCarburanteVO();
            // Attenzione : numero negativo nel caso di inserimento per la ditta cessata    
            Long qtaConcessaGas = new Long(rimanenzaSerraGas);
            buonoCarb.setIdCarburante(new Long(SolmrConstants.ID_GASOLIO));
            buonoCarb.setQuantitaConcessa(qtaConcessaGas);
            elencoBuoniCarburante.add(buonoCarb);			           
          }
          // - Caso BENZINA PER SERRA
          if((request.getParameter("rimanenzaSerraBenz") != null && new Integer(request.getParameter("rimanenzaSerraBenz")).intValue() != 0)){
            SolmrLogger.debug(this, " --- ci sono RIMANENZE PER SERRA DI BENZINA");
            // Costruisco l'oggetto da inserire in DB_BUONO_CARBURANTE
            String rimanenzaSerraBenz = request.getParameter("rimanenzaSerraBenz");
            SolmrLogger.debug(this, " --- rimanenzaSerraBenz ="+rimanenzaSerraBenz);
            BuonoCarburanteVO buonoCarb = new BuonoCarburanteVO();      
            // Attenzione : numero negativo nel caso di inserimento ditta cessata      
            Long qtaConcessaGas = new Long(rimanenzaSerraBenz);
            buonoCarb.setIdCarburante(new Long(SolmrConstants.ID_BENZINA));
            buonoCarb.setQuantitaConcessa(qtaConcessaGas);
            elencoBuoniCarburante.add(buonoCarb);	            
          } 
          buonoPrel.setElencoBuoniCarburante(elencoBuoniCarburante);
          
          elencoBuoniPrelievo.add(buonoPrel);          
       }// fine caso RIMANENZA PER SERRA   
       //  **** Controllo se ci sono rimanenze CONTO TERZI o CONTO PROPRIO ****
      if( (request.getParameter("rimAttualeCPGas") != null && new Integer(request.getParameter("rimAttualeCPGas")).intValue() != 0) ||
          (request.getParameter("rimAttualeCPBenz") != null && new Integer(request.getParameter("rimAttualeCPBenz")).intValue() != 0) ||
          (request.getParameter("rimAttualeCTGas") != null && new Integer(request.getParameter("rimAttualeCTGas")).intValue() != 0) ||
          (request.getParameter("rimAttualeCTBenz") != null && new Integer(request.getParameter("rimAttualeCTBenz")).intValue() != 0)
      ){
          SolmrLogger.debug(this, " --- *** ci sono RIMANENZE CT o CP ***");
          // Costruisco l'oggetto da inserirei in DB_BUONO_PRELIEVO
          BuonoPrelievoVO buonoPrel = new BuonoPrelievoVO();
    	  buonoPrel.setAnnoRiferimento(new Long(request.getParameter("anno")));
          buonoPrel.setNumeroBlocco(new Long(SolmrConstants.NUMERO_BLOCCO));
          buonoPrel.setNumeroBuono(new Long(SolmrConstants.NUMERO_BUONO));
          
          if(request.getParameter("provincia") != null)
            buonoPrel.setExtProvinciaProvenienza(request.getParameter("provincia"));
            
          // Ditta alla quale vengono cedute le rimanenze
          if(request.getParameter("numDittaUmaConsRim") != null){
            buonoPrel.setIdDittaUma(NumberUtils.parseLong(request.getParameter("numDittaUmaConsRim")));
            SolmrLogger.debug(this, "--- Ditta alla quale vengono cedute le rimanenze ="+buonoPrel.getIdDittaUma()); 
          }  
          
          String siglaProvincia = buonoPrel.getExtProvinciaProvenienza();
          buonoPrel.setSiglaProvinciaProvenienza(siglaProvincia);
          String istatProvincia = umaFacadeClient.getIstatProvinciaBySiglaProvincia(siglaProvincia);
          SolmrLogger.debug(this, " --- extProvinciaProvenienza ="+istatProvincia);
          buonoPrel.setExtProvinciaProvenienza(istatProvincia);  
          
          /* 
             Se è CP : ID_CONDUZIONE = 1
             Se è CT : ID_CONDUZIONE = 2
          */
          if((request.getParameter("rimAttualeCPGas") != null && new Integer(request.getParameter("rimAttualeCPGas")).intValue() != 0) ||
             (request.getParameter("rimAttualeCPBenz") != null && new Integer(request.getParameter("rimAttualeCPBenz")).intValue() != 0)){
        	  SolmrLogger.debug(this, " -- Caso CP - setto idConduzione = 1");
        	  buonoPrel.setIdConduzione(1L);
          }
          else if((request.getParameter("rimAttualeCTGas") != null && new Integer(request.getParameter("rimAttualeCTGas")).intValue() != 0) ||
                  (request.getParameter("rimAttualeCTBenz") != null && new Integer(request.getParameter("rimAttualeCTBenz")).intValue() != 0)){
        	  SolmrLogger.debug(this, " -- Caso CT - setto idConduzione = 2");
        	  buonoPrel.setIdConduzione(2L);
          }
            
        	  
            
          Vector<BuonoCarburanteVO> elencoBuoniCarburante = new Vector<BuonoCarburanteVO>();  
          // Calcolo il totale GASOLIO (CT + CP)
          if( ((request.getParameter("rimAttualeCPGas") != null && new Integer(request.getParameter("rimAttualeCPGas")).intValue() != 0)) ||
              ((request.getParameter("rimAttualeCTGas") != null && new Integer(request.getParameter("rimAttualeCTGas")).intValue() != 0))
            ){
            SolmrLogger.debug(this, " --- ci sono RIMANENZE CT o CP DI GASOLIO");
            String rimanenzeCPGas = request.getParameter("rimAttualeCPGas");
            SolmrLogger.debug(this, "-- rimanenzeCPGas ="+rimanenzeCPGas);
            String rimanenzaCTGas = request.getParameter("rimAttualeCTGas");
            SolmrLogger.debug(this, "-- rimanenzaCTGas ="+rimanenzaCTGas);
            Long totRimanenzaCPCTGas = new Long(0);
            if(rimanenzeCPGas != null && !rimanenzeCPGas.equals(""))
              totRimanenzaCPCTGas = totRimanenzaCPCTGas.longValue() + new Long(rimanenzeCPGas).longValue();
            if(rimanenzaCTGas != null && !rimanenzaCTGas.equals(""))
              totRimanenzaCPCTGas = totRimanenzaCPCTGas.longValue() + new Long(rimanenzaCTGas).longValue();
            
                      
            // Costruisco l'oggetto da inserire in DB_BUONO_CARBURANTE          
            SolmrLogger.debug(this, " --- totRimanenzaCPCTGas ="+totRimanenzaCPCTGas);
            BuonoCarburanteVO buonoCarb = new BuonoCarburanteVO();     
            // Attenzione : numero negativo nel caso di inserimento per la ditta cessata        
            Long qtaConcessaGas = new Long(totRimanenzaCPCTGas);
            buonoCarb.setIdCarburante(new Long(SolmrConstants.ID_GASOLIO));
            buonoCarb.setQuantitaConcessa(qtaConcessaGas);            
            
            elencoBuoniCarburante.add(buonoCarb);
          }                    
          // Calcolo il totale BENZINA (CT + CP)
          if( ((request.getParameter("rimAttualeCPBenz") != null && new Integer(request.getParameter("rimAttualeCPBenz")).intValue() != 0) ) ||
              ((request.getParameter("rimAttualeCTBenz") != null && new Integer(request.getParameter("rimAttualeCTBenz")).intValue() != 0)) ){
              SolmrLogger.debug(this, " --- ci sono RIMANENZE CT o CP DI BENZINA");
              
            String rimanenzeCPBenz = request.getParameter("rimAttualeCPBenz");
            SolmrLogger.debug(this, "-- rimAttualeCPBenz ="+rimanenzeCPBenz);
            String rimanenzaCTBenz = request.getParameter("rimAttualeCTBenz");
            SolmrLogger.debug(this, "-- rimanenzaCTBenz ="+rimanenzaCTBenz);
            Long totRimanenzaCPCTBenz = new Long(0);
            if(rimanenzeCPBenz != null && !rimanenzeCPBenz.equals(""))
              totRimanenzaCPCTBenz = totRimanenzaCPCTBenz.longValue() + new Long(rimanenzeCPBenz).longValue();
            if(rimanenzaCTBenz != null && !rimanenzaCTBenz.equals(""))
              totRimanenzaCPCTBenz = totRimanenzaCPCTBenz.longValue() + new Long(rimanenzaCTBenz).longValue();
            
                      
            // Costruisco l'oggetto da inserire in DB_BUONO_CARBURANTE          
            SolmrLogger.debug(this, " --- totRimanenzaCPCTBenz ="+totRimanenzaCPCTBenz);
            BuonoCarburanteVO buonoCarb = new BuonoCarburanteVO();
            // Attenzione : numero negativo nel caso di inserimento ditta cessata             
            Long qtaConcessaGas = new Long(totRimanenzaCPCTBenz);
            buonoCarb.setIdCarburante(new Long(SolmrConstants.ID_GASOLIO));
            buonoCarb.setQuantitaConcessa(qtaConcessaGas);
            
            elencoBuoniCarburante.add(buonoCarb);
          }
          buonoPrel.setElencoBuoniCarburante(elencoBuoniCarburante);
          
          elencoBuoniPrelievo.add(buonoPrel);                   
      }// fine caso RIMANENZA CP o CT
       
  /*  BuonoPrelievoVO bpVO = new BuonoPrelievoVO();
    bpVO.setAnnoRiferimento(new Long(request.getParameter("anno")));
    bpVO.setNumeroBlocco(new Long(SolmrConstants.NUMERO_BLOCCO));
    bpVO.setNumeroBuono(new Long(SolmrConstants.NUMERO_BUONO));
    if(request.getParameter("provincia") != null)
      bpVO.setExtProvinciaProvenienza(request.getParameter("provincia"));

    if(request.getParameter("numDittaUmaConsRim") != null)
      bpVO.setIdDittaUma(NumberUtils.parseLong(request.getParameter("numDittaUmaConsRim")));*/

 /*   SolmrLogger.debug(this, "******************************");
    SolmrLogger.debug(this, "******************************");
    SolmrLogger.debug(this, "ditta uma ricevente: "+request.getParameter("numDittaUmaConsRim"));
    SolmrLogger.debug(this, "******************************");
    SolmrLogger.debug(this, "******************************");

    int totRimAttGas = 0;
    int totRimAttBenz = 0;

    if(request.getParameter("totaleRimAttualeGas") != null)
      totRimAttGas = new Integer(request.getParameter("totaleRimAttualeGas")).intValue();
    if(request.getParameter("totaleRimAttualeBenz") != null)
      totRimAttBenz = new Integer(request.getParameter("totaleRimAttualeBenz")).intValue();

    vectBP.add(bpVO);
    vectBP.add(""+totRimAttGas);
    vectBP.add(""+totRimAttBenz);*/
  }

  SolmrLogger.debug(this, "*** Prima della chiamata ");
  SolmrLogger.debug(this, "*** IdDittaUma "+daVO.getIdDitta());
  SolmrLogger.debug(this, "*** DataCessazione "+dataCessazione);  

  try{   
  //cerco sulla tabella db_numerazione_foglio. Se il record esiste => cessaDittaUma
  //altrimenti rimando alla pagina cessazioneAssegnazioneFoglio
    SolmrLogger.debug(this, "UTENTE: "+ruoloUtenza.getIdUtente());
    SolmrLogger.debug(this, "anno: "+anno);
    
    NumerazioneFoglioVO nfVO = umaFacadeClient.selectNumFoglioByProfiloAndAnno(ruoloUtenza, new Long(anno));
    if(nfVO!=null){
      SolmrLogger.debug(this, " ---------- HO TROVATO IL RECORD IN DB_NUMERAZIONE_FOGLIO");
      daVO.setDataRiferimento(new Date());
     
      for(int i=0; i<vectCrVO.size(); i++){
        ConsumoRimanenzaVO crVO = (ConsumoRimanenzaVO) vectCrVO.get(i);
        SolmrLogger.debug(this, "crVO.getIdCarburante(): "+crVO.getIdCarburante());
        SolmrLogger.debug(this, "crVO.getRimSerra(): "+crVO.getRimSerra());
      }

      
      String extCuaaAziendaDest=request.getParameter("extCuaaAziendaDest");
      
      /*
       L'HashMap tornata in output sarà composta da:
        - key = BUONI_PREL_PASSIVI, BUONI_PREL_ATTIVI, FOGLIO, RIGA
        - valore = Vector<Long>
      */
      HashMap<String, Vector<Long>> outputCessaDittaUma = umaFacadeClient.cessaDittaUma(daVO, vectCrVO, elencoBuoniPrelievo, dataCessazione, ruoloUtenza, StringUtils.trim(extCuaaAziendaDest));
      
      //051215 Imposta la visualizzazione del blocco importa dati in LayoutWriter - Begin
      session.setAttribute("gestioneImportaDati", new Boolean(true));
      session.setAttribute("extCuaaAziendaDest", extCuaaAziendaDest);
      //051215 Imposta la visualizzazione del blocco importa dati in LayoutWriter - End
      
      SolmrLogger.debug(this,"-- Recupero i dati restituiti da  cessaDittaConNumeroFoglio()");
      // Recupero gli ID_BUONO_PRELIEVO inseriti per la ditta cedente (quella che viene cessata)
      Vector<Long> idBuoniPrelPassiviVect = outputCessaDittaUma.get(SolmrConstants.BUONI_PREL_PASSIVI);  
    
      // Recupero gli ID_BUONO_PRELIEVO inseriti per l'eventuale ditta ricevente
      Vector<Long> idBuoniPrelAttiviVect = outputCessaDittaUma.get(SolmrConstants.BUONI_PREL_ATTIVI);           
    
      // Recupero il foglio
      Long foglio = null;
      Vector<Long> foglioVect = outputCessaDittaUma.get(SolmrConstants.FOGLIO);
      if(foglioVect != null && foglioVect.size() >0)
       foglio = foglioVect.get(0);
    
      // Recupero la riga
      Vector<Long> rigaVect = outputCessaDittaUma.get(SolmrConstants.RIGA);
      Long riga = null;
      if(rigaVect != null && rigaVect.size() >0)
        riga = rigaVect.get(0);
      
      
      // Se c'erano delle rimanenze, sono stati inseriti dei record in DB_BUONO_PRELIEVO
      if(!outputCessaDittaUma.isEmpty() && idBuoniPrelPassiviVect != null && idBuoniPrelPassiviVect.size()>0){
       
        SolmrLogger.debug(this, " ---------- ci sono delle RIMANENZE CARBURANTE");
		//PER LA DITTA DA CESSARE
        DittaUMAVO dittaUmaVO = umaFacadeClient.findDittaVOByIdDitta(idDittaUma);
        String siglaDittaDaCessare = dittaUmaVO.getExtProvinciaUMA();        
        String provinciaDaCessare = umaFacadeClient.getSiglaProvinciaByIstatProvincia(siglaDittaDaCessare);
        session.setAttribute("siglaProvinciaPassivo", provinciaDaCessare);
        session.setAttribute("anno", anno);
        
        // ditta cedente (ditta cesssata)
        session.setAttribute("idBuoniPrelPassiviVect", idBuoniPrelPassiviVect);
		
        // eventuale ditta ricevente        
        session.setAttribute("idBuoniPrelAttiviVect", idBuoniPrelAttiviVect);


      /*  if(idBuonoPrelievoVect.size()!=0){
          numeroFoglio = (String)idBuonoPrelievoVect.elementAt(0);
          numeroRiga = (String)idBuonoPrelievoVect.elementAt(1);
          session.setAttribute("numFoglio", numeroFoglio);
          session.setAttribute("numRiga", numeroRiga);

          SolmrLogger.debug(this, "dopo le set da cessaDittaUmaConfermaCTRL numeroFoglio ="+numeroFoglio);
          SolmrLogger.debug(this, "dopo le set da cessaDittaUmaConfermaCTRL numeroRiga ="+numeroRiga);
        }*/
        
        SolmrLogger.debug(this," -- numFoglio: "+foglio);
        SolmrLogger.debug(this," -- numRiga: "+foglio);
        session.setAttribute("numFoglio", ""+foglio);
        session.setAttribute("numRiga", ""+foglio);

        SolmrLogger.debug(this," -- idDomAss ="+daVO.getIdDomandaAssegnazione());
        session.setAttribute("idDomAss", ""+daVO.getIdDomandaAssegnazione());

        session.setAttribute("anno", anno);
        url = "/ditta/layout/cessaDittaUmaSalvata.htm";
      }
      else{
        SolmrLogger.debug(this, " ---------- NON ci sono delle RIMANENZE CARBURANTE");
        
        SolmrLogger.debug(this," -- numFoglio: "+foglio);
        SolmrLogger.debug(this," -- numRiga: "+foglio);
        session.setAttribute("numFoglio", ""+foglio);
        session.setAttribute("numRiga", ""+foglio);

        SolmrLogger.debug(this, "forward in cessaDittaUmaSalvataSenzaVerifica");
        url = "/ditta/layout/cessaDittaUmaSalvataSenzaVerifica.htm";
      }
    }
    else{
      SolmrLogger.debug(this, " ------ NON HO TROVATO IL RECORD IN DB_NUMERAZIONE_FOGLIO");
      
      
      SolmrLogger.debug(this, "*************daVO.getIdDitta()**************** "+daVO.getIdDitta());
      session.setAttribute("domandaAssegnazione", daVO);
      session.setAttribute("vectConsumoRimanenzaVO", vectCrVO);
      session.setAttribute("vectBuonoPrelievoVO", elencoBuoniPrelievo);
      session.setAttribute("dataCessazione", dataCessazione);
      //profile
      session.setAttribute("anno", anno);
      url = "/ditta/layout/cessazioneAssegnazioneFoglio.htm";
    }
  }catch(SolmrException except){
    url = "/ditta/view/cessaDittaUmaConfermaView.jsp";
    SolmrLogger.debug(this, "URL DALL'ECCEZIONE: "+url);
    ValidationErrors errors = new ValidationErrors();
    ValidationError error = new ValidationError(except.getMessage());
    errors.add("error", error);
    request.setAttribute("errors", errors);
    /*request.getRequestDispatcher(url).forward(request, response);
    return;*/
  }
}

SolmrLogger.debug(this, "\n\n\n\n\n[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[");
SolmrLogger.debug(this, "url: "+url);
SolmrLogger.debug(this, "]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]\n\n\n\n\n");

%>
<jsp:forward page="<%=url%>"/>