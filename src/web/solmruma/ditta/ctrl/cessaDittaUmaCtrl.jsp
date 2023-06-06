<%@ page import="it.csi.solmr.util.*,it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.util.SolmrLogger"%>

<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  private final String CESSA_DITTA_UMA_VIEW = "/ditta/view/cessaDittaUmaView.jsp";
  private final String CESSA_DITTA_UMA_CONFERMA_VIEW = "/ditta/view/cessaDittaUmaConfermaView.jsp";
  private final String CESSA_DITTA_UMA_SENZA_VERIFICA = "/ditta/layout/cessaDittaUmaSenzaVerifica.htm";
  private final String DETTAGLIO_AZIENDA = "/anag/layout/dettaglioAzienda.htm";
%>
<%
  String iridePageName = "cessaDittaUmaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  AnagFacadeClient anagFacadeClient = new AnagFacadeClient();

  String url = CESSA_DITTA_UMA_VIEW;
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] ---------------------profile------------------ "+ruoloUtenza.isUtenteProvinciale());
  //SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] ---------------------profile intermediario?------------------ "+profile.isIntermediario());

  session.setAttribute("refreshDettaglio", "true");
  if(ruoloUtenza.isUtenteProvinciale() || ruoloUtenza.isUtenteRegionale()){
    Long idDittaUMA=null;
    Long dittaUMA=null;

    Validator validator = new Validator(url);
    ValidationError error = null;
    DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
    idDittaUMA = dittaVO.getIdDittaUMA();
    dittaUMA = new Long(dittaVO.getDittaUMAstr());
    String provinciaDitta=dittaVO.getProvUMA();

    SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] idDittaUMA: "+idDittaUMA);
    SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] provinciaDitta: "+provinciaDitta);

    Long idDomAss = null;
    request.setAttribute("idDittaUMA",idDittaUMA);

    SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] ***********************idDittaUMA: "+idDittaUMA);
    if(request.getParameter("idDomAss") != null)
      idDomAss = new Long(""+request.getParameter("idDomAss"));
    SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] ***********************idDomAss: "+idDomAss);

    if(request.getParameter("avanti") != null){
      SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] if(request.getParameter(\"avanti\") != null)");      long rimanenzaPrecContoProprioGas  = 0;
      long rimanenzaPrecContoTerziGas = 0;
      long rimanenzaPrecSerraGas = 0;

      long rimanenzaPrecContoProprioBenz  = 0;
      long rimanenzaPrecContoTerziBenz = 0;
      long rimanenzaPrecSerraBenz = 0;


      /*long prelevatoNonSerraGas = 0;
      long prelevatoNonSerraBenz = 0;
      */
      
      long prelevatoCPGas = 0;
      long prelevatoCPBenz = 0;
      long prelevatoCTGas = 0;
      long prelevatoCTBenz = 0;
      
      
      long prelevatoSerraGas = 0;
      long prelevatoSerraBenz = 0;


      long rimanenzaContoGas = 0;
      long rimanenzaContoTerziGas = 0;
      long rimanenzaSerraGas = 0;

      long rimanenzaContoBenz = 0;
      long rimanenzaContoTerziBenz = 0;
      long rimanenzaSerraBenz = 0;


      long consumoContoProprioGas = 0;
      long consumoContoTerziGas = 0;
      long consumoSerraGas = 0;

      long consumoContoProprioBenz = 0;
      long consumoContoTerziBenz = 0;
      long consumoSerraBenz = 0;


      long sommaRimanenzaConsumoNonSerraGas = 0;
      long sommaDisponibilitaNonSerraGas = 0;
      long sommaRimanenzaConsumoSerraGas = 0;
      long sommaDisponibilitaSerraGas = 0;

      long sommaRimanenzaConsumoNonSerraBenz = 0;
      long sommaDisponibilitaNonSerraBenz = 0;
      long sommaRimanenzaConsumoSerraBenz = 0;
      long sommaDisponibilitaSerraBenz = 0;


      long rimanenzaAttualeBenz = 0;
      long rimanenzaAttualeGas = 0;

      String dataDocumentazione="";

      long numeroDocumenti=0;
      long numeroDittaUma=0;
      String provincia = "";
      String dataCessazioneAttivita="";
      String except="";

      ValidationErrors errors = new ValidationErrors();
      errors = controllaConsumiRimanenze(errors, request);

      errors = controllaIntermediarioDocCarta(errors,request);

      //la data di cessazione attività è obbligatoria e non può essere superiore alla data del giorno
      Date dataCorrente = new Date();
      dataCorrente = DateUtils.parseDate(DateUtils.getCurrent());
      SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] dataCorrente: "+dataCorrente);

      Date dataCessAtt = new Date();
      if(request.getParameter("dataCessazioneAttivita") != null && !request.getParameter("dataCessazioneAttivita").equals("")){
        dataCessazioneAttivita = request.getParameter("dataCessazioneAttivita");
      }
      if(dataCessazioneAttivita.equals("")){
        SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] DATA CESSAZIONE \"\"");
        error=new ValidationError(""+UmaErrors.get("DATA_CESSAZIONE_EMPTY"));
        errors.add("dataCessazioneAttivita", error);
      }
      else{
        if(validator.validateDateF(dataCessazioneAttivita)){
          SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] DATA CESSAZIONE VALIDA");
          dataCessAtt = DateUtils.parseDate(dataCessazioneAttivita);
          if(((String)(""+DateUtils.extractYearFromDate(dataCessAtt))).length()==4){
            SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] dataCessAtt: "+dataCessAtt);
            if(dataCessAtt.after(dataCorrente)){
              error=new ValidationError(""+UmaErrors.get("DATA_MAGGIORE_CORRENTE"));
              errors.add("dataCessazioneAttivita", error);
            }
          }
          else{
            error=new ValidationError(""+UmaErrors.get("DATA_ERRATA"));
            errors.add("dataCessazioneAttivita", error);
          }
        }
        else{
          error=new ValidationError(""+UmaErrors.get("DATA_ERRATA"));
          errors.add("dataCessazioneAttivita", error);
        }
      }

      String sNumeroDittaUma=request.getParameter("numeroDittaUma");
      if (sNumeroDittaUma!=null)
      {
        sNumeroDittaUma=sNumeroDittaUma.trim();
      }
      if( Validator.isNotEmpty(sNumeroDittaUma))
      {
        SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] numeroDittaUma ="+sNumeroDittaUma);
        if (Validator.isNumericInteger(sNumeroDittaUma))
        {
          numeroDittaUma = new Long(request.getParameter("numeroDittaUma")).longValue();
        }
        else
        {
          error=new ValidationError(UmaErrors.ERR_NUMERO_DITTA_UMA_NON_VALIDO);
          errors.add("numeroDittaUma", error);
        }
      }
      boolean isExtCuaaAziendaDest=validateExtCuaaAziendaDest(request.getParameter("extCuaaAziendaDest"),sNumeroDittaUma,request.getParameter("provincia"), errors, umaFacadeClient);

      SolmrLogger.debug(this, "[cessaDittaUmaCtrl::service] errors: "+errors);
      if(errors!=null && errors.size()!=0){
        SolmrLogger.debug(this, "[cessaDittaUmaCtrl::service] if(errors!=null && errors.size()!=0)");
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(url).forward(request, response);
        return;
      }


      //Numero ditta UMA - Provincia
      if(request.getParameter("provincia") != null && !request.getParameter("provincia").equals("")){
        provincia = request.getParameter("provincia");
      }



      //Documentazione
      if(request.getParameter("dataDocumentazione") != null && !request.getParameter("dataDocumentazione").equals("")){
        dataDocumentazione = request.getParameter("dataDocumentazione");
      }

      if(request.getParameter("numeroDocumenti") != null && !request.getParameter("numeroDocumenti").equals("")){
        numeroDocumenti = new Long(request.getParameter("numeroDocumenti")).longValue();
      }


      //Rimanenze - Consumi (Gas)
      if(request.getParameter("rimanenzaContoGas") != null && !request.getParameter("rimanenzaContoGas").equals("")){
        rimanenzaContoGas = new Long(request.getParameter("rimanenzaContoGas")).longValue();
      }

      if(request.getParameter("rimanenzaContoTerziGas") != null && !request.getParameter("rimanenzaContoTerziGas").equals("")){
        rimanenzaContoTerziGas = new Long(request.getParameter("rimanenzaContoTerziGas")).longValue();
      }

      if(request.getParameter("rimanenzaSerraGas") != null && !request.getParameter("rimanenzaSerraGas").equals("")){
        rimanenzaSerraGas = new Long(request.getParameter("rimanenzaSerraGas")).longValue();
      }

      if(request.getParameter("consumoContoProprioGas") != null && !request.getParameter("consumoContoProprioGas").equals("")){
        consumoContoProprioGas = new Long(request.getParameter("consumoContoProprioGas")).longValue();
      }

      if(request.getParameter("consumoContoTerziGas") != null && !request.getParameter("consumoContoTerziGas").equals("")){
        consumoContoTerziGas = new Long(request.getParameter("consumoContoTerziGas")).longValue();
      }

      if(request.getParameter("consumoSerraGas") != null && !request.getParameter("consumoSerraGas").equals("")){
        consumoSerraGas = new Long(request.getParameter("consumoSerraGas")).longValue();
      }

      SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] Somma Gas");
      rimanenzaPrecContoProprioGas = new Long(request.getParameter("rimanenzaPrecContoProprioGas")).longValue();
      rimanenzaPrecContoTerziGas = new Long(request.getParameter("rimanenzaPrecContoTerziGas")).longValue();
      rimanenzaPrecSerraGas = new Long(request.getParameter("rimanenzaPrecSerraGas")).longValue();
      
      //prelevatoNonSerraGas = new Long(request.getParameter("prelevatoNonSerraGas")).longValue();
      prelevatoSerraGas = new Long(request.getParameter("prelevatoSerraGas")).longValue();
      
      prelevatoCPGas = new Long(request.getParameter("prelevatoCPGas")).longValue();
      prelevatoCPBenz = new Long(request.getParameter("prelevatoCPBenz")).longValue();
      prelevatoCTGas = new Long(request.getParameter("prelevatoCTGas")).longValue();
      prelevatoCTBenz = new Long(request.getParameter("prelevatoCTBenz")).longValue();
      
      //prelevatoGas = new Long(request.getParameter("prelevatoGas")).longValue();

      sommaRimanenzaConsumoNonSerraGas = rimanenzaContoGas+rimanenzaContoTerziGas+consumoContoProprioGas+consumoContoTerziGas;
      
      sommaDisponibilitaNonSerraGas = rimanenzaPrecContoProprioGas+rimanenzaPrecContoTerziGas+prelevatoCPGas+prelevatoCTGas;
      
      sommaRimanenzaConsumoSerraGas = rimanenzaSerraGas+consumoSerraGas;
      
      sommaDisponibilitaSerraGas = rimanenzaPrecSerraGas+prelevatoSerraGas;
      
      //sommaRimanenzaConsumoGas = rimanenzaContoGas+rimanenzaContoTerziGas+consumoContoProprioGas+consumoContoTerziGas;
      //sommaDisponibilitaGas = rimanenzaPrecContoProprioGas+rimanenzaPrecContoTerziGas+prelevatoGas;


      //Rimanenze - Consumi (Benzina)
      if(request.getParameter("rimanenzaContoBenz") != null && !request.getParameter("rimanenzaContoBenz").equals("")){
        rimanenzaContoBenz = new Long(request.getParameter("rimanenzaContoBenz")).longValue();
      }

      if(request.getParameter("rimanenzaContoTerziBenz") != null && !request.getParameter("rimanenzaContoTerziBenz").equals("")){
        rimanenzaContoTerziBenz = new Long(request.getParameter("rimanenzaContoTerziBenz")).longValue();
      }

      if(request.getParameter("rimanenzaSerraBenz") != null && !request.getParameter("rimanenzaSerraBenz").equals("")){
        rimanenzaSerraBenz = new Long(request.getParameter("rimanenzaSerraBenz")).longValue();
      }

      if(request.getParameter("consumoContoProprioBenz") != null && !request.getParameter("consumoContoProprioBenz").equals("")){
        consumoContoProprioBenz = new Long(request.getParameter("consumoContoProprioBenz")).longValue();
      }

      if(request.getParameter("consumoContoTerziBenz") != null && !request.getParameter("consumoContoTerziBenz").equals("")){
        consumoContoTerziBenz = new Long(request.getParameter("consumoContoTerziBenz")).longValue();
      }

      if(request.getParameter("consumoSerraBenz") != null && !request.getParameter("consumoSerraBenz").equals("")){
        consumoSerraBenz = new Long(request.getParameter("consumoSerraBenz")).longValue();
      }


      SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] Somma Benz");
      rimanenzaPrecContoProprioBenz = new Long(request.getParameter("rimanenzaPrecContoProprioBenz")).longValue();
      //SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] request.getParameter(\"rimanenzaPrecContoProprioBenz\")");
      rimanenzaPrecContoTerziBenz = new Long(request.getParameter("rimanenzaPrecContoTerziBenz")).longValue();
      //SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] request.getParameter(\"rimanenzaPrecContoTerziBenz\")");
      rimanenzaPrecSerraBenz = new Long(request.getParameter("rimanenzaPrecSerraBenz")).longValue();
      //SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] request.getParameter(\"rimanenzaPrecSerraBenz\")");
      
      //prelevatoNonSerraBenz = new Long(request.getParameter("prelevatoNonSerraBenz")).longValue();
      prelevatoCPGas = new Long(request.getParameter("prelevatoCPGas")).longValue();
      prelevatoCPBenz = new Long(request.getParameter("prelevatoCPBenz")).longValue();
      prelevatoCTGas = new Long(request.getParameter("prelevatoCTGas")).longValue();
      prelevatoCTBenz = new Long(request.getParameter("prelevatoCTBenz")).longValue();
      
      prelevatoSerraBenz = new Long(request.getParameter("prelevatoSerraBenz")).longValue();
      //SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] request.getParameter(\"prelevatoSerraBenz\")");
      //prelevatoBenz = new Long(request.getParameter("prelevatoBenz")).longValue();

      //SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] request.getParameter Somma Benz");
      sommaRimanenzaConsumoNonSerraBenz = rimanenzaContoBenz+rimanenzaContoTerziBenz+consumoContoProprioBenz+consumoContoTerziBenz;
      sommaDisponibilitaNonSerraBenz = rimanenzaPrecContoProprioBenz+rimanenzaPrecContoTerziBenz+prelevatoCPBenz+prelevatoCTBenz;
      sommaRimanenzaConsumoSerraBenz = rimanenzaSerraBenz+consumoSerraBenz;
      sommaDisponibilitaSerraBenz = rimanenzaPrecSerraBenz+prelevatoSerraBenz;
      //sommaRimanenzaConsumoBenz = rimanenzaContoBenz+rimanenzaContoTerziBenz+consumoContoProprioBenz+consumoContoTerziBenz;
      //sommaDisponibilitaBenz = rimanenzaPrecContoProprioBenz+rimanenzaPrecContoTerziBenz+prelevatoBenz;


      SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] Dopo Somma Benz");
      try{

//se le somma di disponibilità  e di consumo/rimanenza, suddivisivi per serra
// e tipologia carburante si corrispondono
        //if(sommaRimanenzaConsumoGas == sommaDisponibilitaGas && sommaRimanenzaConsumoBenz == sommaDisponibilitaBenz){
        if((sommaRimanenzaConsumoNonSerraBenz == sommaDisponibilitaNonSerraBenz)
           && (sommaRimanenzaConsumoSerraBenz == sommaDisponibilitaSerraBenz)
           && (sommaRimanenzaConsumoNonSerraGas == sommaDisponibilitaNonSerraGas)
           && (sommaRimanenzaConsumoSerraGas == sommaDisponibilitaSerraGas)){

            //se è stato inserito un valore di consumo CT (gasolio o benz) devono essere stati
            // inseriti anche i dati Data Documentazione e Numero Documenti
            SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] dataDocumentazione: "+dataDocumentazione);
            SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] numeroDocumenti: "+numeroDocumenti);
            if(new Long(consumoContoTerziBenz) != null && new Integer(""+consumoContoTerziBenz).intValue()!=0 ||
               new Long(consumoContoTerziGas) != null && new Integer(""+consumoContoTerziGas).intValue()!=0){

              if(dataDocumentazione == null || dataDocumentazione.equals("") ||
                 new Long(numeroDocumenti) == null || numeroDocumenti==0){

                error=new ValidationError(""+UmaErrors.get("DATA_CONSEGNA_DOC_NUMERO_DOC_VUOTI"));
                errors.add("dataDocumentazione", error);
                errors.add("numeroDocumenti", error);
                //controllaIntermediarioDocCarta(errors,request);
              }
            }

            SolmrLogger.debug(this, "@@###@@###@@###@@###@@###@@###@@###@@###\n\n\n\n\n");

            //se sono stati inseriti i dati di rimanenza attuale e non provincia e num ditta uma di destinazione delle rimanenze
            //il sistema risponde con un msg di errore
            if(new Long(rimanenzaContoGas)!=null && new Integer(""+rimanenzaContoGas).intValue()!=0 ||
               new Long(rimanenzaContoTerziGas)!=null && new Integer(""+rimanenzaContoTerziGas).intValue()!=0 ||
               new Long(rimanenzaContoBenz)!=null && new Integer(""+rimanenzaContoBenz).intValue()!=0 ||
               new Long(rimanenzaContoTerziBenz)!=null && new Integer(""+rimanenzaContoTerziBenz).intValue()!=0 ||
               new Long(rimanenzaSerraGas)!=null && new Integer(""+rimanenzaSerraGas).intValue()!=0 ||
               new Long(rimanenzaSerraBenz)!=null && new Integer(""+rimanenzaSerraBenz).intValue()!=0
               ){
                    if (isExtCuaaAziendaDest)
                    {
                      // Inserito cuaa azienda destinazione
                      // Nessun controllo!!!!
                    }
                    else
                    {
                      // Vecchia gestione
	                    //@@Controlli ditta ricevente
	                    SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
	                    if(new Long(numeroDittaUma)==null || provincia.equals("") || new Integer(""+numeroDittaUma).intValue()==0)
	                    {
	                        error=new ValidationError(""+UmaErrors.get("RIMANENZE_NON_CONSEGNATE"));
	                        errors.add("provincia", error);
	                        errors.add("numeroDittaUma", error);
	                        //controllaIntermediarioDocCarta(errors,request);
	                    }
	
	                    //la + di rimanenza attuale (CP,CT) e consumo (CP,CT) suddivisi tra tipo carburante devono
	                    // coincidere con Totale della disponibilità(CP+CT+prelevato)
	                    if(numeroDittaUma == dittaUMA.longValue()){
	                        error=new ValidationError(""+UmaErrors.get("DITTAUMASTESSA"));
	                        errors.add("numeroDittaUma", error);
	                    }
	
	                    //@@Controlli Provincia REA valida
	                    /* AGGIUNTO DA MONICA IL 30/10/2003 - INIZIO */
	                    // effettua il controllo che la sigla dell provincia inserita sia effettivamente una provincia
	                    // uso un metodo di anagrafe e anche se il nome non è appropriato
	                    if(provincia!=null && !provincia.equals("")){
	                        try {
	                          boolean isValida = anagFacadeClient.isProvinciaReaValida(provincia.toUpperCase());
	                          if(!isValida) {
	                            error=new ValidationError(SolmrErrors.ERR_PROVINCIA_INESISTENTE);
	                            errors.add("provincia", error);
	                          }
	                        }
	                        catch(SolmrException se) {
	                          error = new ValidationError(se.getMessage());
	                          errors.add("error", error);
	                        }
	                    }
	
	                    //@@Controlli checkDittaUmaRimanenze
	                    //*************************
	                    //se sono stati inseriti i dati di ditta uma di destinazione rimanenze e la provincia (l'utente ha inserito la
	                    //sigla) appartiene al TOBECONFIG, il sistema legge la "Ditta UMA" impostando alcuni campi
	                    String istatRegione = umaFacadeClient.getRegioneByProvincia(provincia);
	                    if(istatRegione.equals(SolmrConstants.ID_REGIONE)){
	                        DittaUMAVO duVO = new DittaUMAVO();
	                        duVO.setExtProvinciaUMA(provincia);
	                        duVO.setTipoDitta(SolmrConstants.TIPODITTAUMA);
	                        duVO.setDittaUMA(""+numeroDittaUma);
	                        Vector vectDittaUma = umaFacadeClient.findDittaByVO(duVO);
	                        if(vectDittaUma.size()==0){
	                          error=new ValidationError(""+UmaErrors.get("DITTA_PER_RIMANENZE_INESISTENTE"));
	                          errors.add("numeroDittaUma", error);
	                          //controllaIntermediarioDocCarta(errors,request);
	                        }
	                        DittaUMAVO duVORimanenze = (DittaUMAVO)vectDittaUma.firstElement();
	
	                        rimanenzaAttualeBenz = rimanenzaContoBenz + rimanenzaContoTerziBenz + rimanenzaSerraBenz;
	                        rimanenzaAttualeGas = rimanenzaContoGas + rimanenzaContoTerziGas + rimanenzaSerraGas;
	                        try{
	                          umaFacadeClient.checkDittaUmaRimanenze(duVORimanenze.getIdDitta(), new Long(rimanenzaAttualeBenz), new Long(rimanenzaAttualeGas));
	                        }catch(SolmrException se){
	                          error = new ValidationError(se.getMessage());
	                          errors.add("numeroDittaUma", error);
	                          //controllaIntermediarioDocCarta(errors,request);
	                        }
	
	                        SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] dopo checkDittaUmaRimanenze del ctrl");
	                    }
                    }

                    //@@ Modifico Url pagina successiva
                    //Controlli OK

      //*************************
                }
      //se non sono stati inseriti dei dati di rimanenza attuale ma sono stati inseriti i dati di provincia o num ditta uma
      //di destinazione delle rimanenze il sistema risponde con un msg di errore
                else{
                    SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] sono nell'else dell'iffone");
                    if(!provincia.equals("") || (new Long(numeroDittaUma) != null && new Integer(""+numeroDittaUma).intValue()!=0))
                    {
                      error=new ValidationError(""+UmaErrors.get("NO_DICHIARATE_RIMANENZE"));
                      errors.add("rimanenzaContoGas", error);
                      errors.add("rimanenzaContoBenz", error);
                      errors.add("rimanenzaContoTerziGas", error);
                      errors.add("rimanenzaContoTerziBenz", error);
                      errors.add("rimanenzaSerraGas", error);
                      errors.add("rimanenzaSerraBenz", error);
                    }
                }
        }
        else{
                SolmrLogger.debug(this, "\n\n\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
                SolmrLogger.debug(this, "sommaRimanenzaConsumoNonSerraBenz: "+sommaRimanenzaConsumoNonSerraBenz);
                SolmrLogger.debug(this, "sommaDisponibilitaNonSerraBenz: "+sommaDisponibilitaNonSerraBenz);
                SolmrLogger.debug(this, "sommaRimanenzaConsumoSerraBenz: "+sommaRimanenzaConsumoSerraBenz);
                SolmrLogger.debug(this, "sommaDisponibilitaSerraBenz: "+sommaDisponibilitaSerraBenz);
                SolmrLogger.debug(this, "sommaRimanenzaConsumoNonSerraGas: "+sommaRimanenzaConsumoNonSerraGas);
                SolmrLogger.debug(this, "sommaDisponibilitaNonSerraGas: "+sommaDisponibilitaNonSerraGas);
                SolmrLogger.debug(this, "sommaRimanenzaConsumoSerraGas: "+sommaRimanenzaConsumoSerraGas);
                SolmrLogger.debug(this, "sommaDisponibilitaSerraGas: "+sommaDisponibilitaSerraGas);
                SolmrLogger.debug(this, "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n\n\n");


                if(sommaRimanenzaConsumoNonSerraBenz != sommaDisponibilitaNonSerraBenz){
                  error=new ValidationError(""+UmaErrors.get("RIMANENZA_CONSUMO_DIVERSO_DISPONIBILITA_CONTO_PROPRIO_TERZI_BENZ"));
                  errors.add("rimanenzaContoBenz", error);
                  errors.add("rimanenzaContoTerziBenz", error);
                  errors.add("consumoContoProprioBenz", error);
                  errors.add("consumoContoTerziBenz", error);
                }

                if(sommaRimanenzaConsumoSerraBenz != sommaDisponibilitaSerraBenz){
                  error=new ValidationError(""+UmaErrors.get("RIMANENZA_CONSUMO_DIVERSO_DISPONIBILITA_SERRA_BENZ"));
                  errors.add("rimanenzaSerraBenz", error);
                  errors.add("consumoSerraBenz", error);
                }

                if(sommaRimanenzaConsumoNonSerraGas != sommaDisponibilitaNonSerraGas){
                  error=new ValidationError(""+UmaErrors.get("RIMANENZA_CONSUMO_DIVERSO_DISPONIBILITA_CONTO_PROPRIO_TERZI_GAS"));
                  errors.add("rimanenzaContoGas", error);
                  errors.add("rimanenzaContoTerziGas", error);
                  errors.add("consumoContoProprioGas", error);
                  errors.add("consumoContoTerziGas", error);
                }

                if(sommaRimanenzaConsumoSerraGas != sommaDisponibilitaSerraGas){
                  error=new ValidationError(""+UmaErrors.get("RIMANENZA_CONSUMO_DIVERSO_DISPONIBILITA_SERRA_GAS"));
                  errors.add("rimanenzaSerraGas", error);
                  errors.add("consumoSerraGas", error);
                }

        }

        SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] PRIMA DELL'IFFONEEEEEEEEEEEEEEEEEEEEEE");
        SolmrLogger.debug(this, "\n\n\n\n\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@22");
        SolmrLogger.debug(this, "errors: "+errors);
        SolmrLogger.debug(this, "22@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n\n\n\n\n");
        if(errors!=null && errors.size()!=0){
          SolmrLogger.debug(this, "if(errors!=null && errors.size()!=0)");
          request.setAttribute("errors", errors);
          request.getRequestDispatcher(url).forward(request, response);
          return;
        }

        url = CESSA_DITTA_UMA_CONFERMA_VIEW;

      }catch(Exception ex){
        SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] catch(Exception ex) URL: "+url);
        SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] catch(Exception ex) "+ex);

        request.setAttribute("idDomAss",idDomAss);
        session.setAttribute("provincia",provincia);
        if(ex.getMessage().equals(""+UmaErrors.get("DITTA_UMA_INESISTENTE"))){
          except = ""+UmaErrors.get("DITTA_PER_RIMANENZE_INESISTENTE");
          error = new ValidationError(except);
          errors.add("numeroDittaUma", error);
          request.setAttribute("errors", errors);
          request.getRequestDispatcher(url).forward(request, response);
          return;
        }

        if(ex.getMessage().equals(""+UmaErrors.get("DITTA_CESSATA"))){
          except = ""+UmaErrors.get("DITTA_PER_RIMANENZE_CESSATA");
          error = new ValidationError(except);
          errors.add("numeroDittaUma", error);
          request.setAttribute("errors", errors);
          request.getRequestDispatcher(url).forward(request, response);
          return;
        }

        if(ex.getMessage().equals(""+UmaErrors.get("DITTA_BLOCCATA"))){
          except = ""+UmaErrors.get("DITTA_PER_RIMANENZE_BLOCCATA");
          error = new ValidationError(except);
          errors.add("numeroDittaUma", error);
          request.setAttribute("errors", errors);
          request.getRequestDispatcher(url).forward(request, response);
          return;
        }
        else{
          error = new ValidationError(except);
          errors.add("error", error);
          request.setAttribute("errors", errors);
          request.getRequestDispatcher(url).forward(request, response);
          return;
        }
      }
    }//fine se ho clickato "avanti"
    else{
      try
      {
        SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] NON HO CLICKATO AVANTI!!!!");
        SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] idDittaUMA="+idDittaUMA);
        if(idDittaUMA!=null){
         /* 2006/08/22 Modifica per passaggio ad iride2 ==> ora i controlli
            di validazioni sono fatti dalle classi nel package
            it.csi.solmr.presentation.security.cu, quindi l'idDomAss viene
            ricavato direttamente nella fase di validazione dell'accesso alla
            funzionalità e viene messo in request dalla classe
            CessazioneDittaUmaCU, non è più necessario richiamare il metodo
            checkForCessazioneDitta() */

//          idDomAss = umaFacadeClient.checkForCessazioneDitta(idDittaUMA);
            idDomAss = (Long) request.getAttribute("__idDomAss");
          SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] idDomAss: "+idDomAss);

          if(idDomAss==null){
            throw new SolmrException(SolmrConstants.SCENARIO_UNO);
          }

          request.setAttribute("idDomAss",idDomAss);
        }

        SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] DOPO checkForCessazioneDitta");
      }
      catch(SolmrException ex){
        SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] SONO NEL CATCH!!!!!!!!!!!!!!!!!!!!!!ex: "+ex.getMessage());
        if(ex.getMessage().indexOf(SolmrConstants.SCENARIO_UNO)!=-1){
          session.removeAttribute("numFoglio");
          session.removeAttribute("numRiga");
          SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] "+CESSA_DITTA_UMA_SENZA_VERIFICA);
          url = CESSA_DITTA_UMA_SENZA_VERIFICA;
        }
        else{
          SolmrLogger.debug(this,"[cessaDittaUmaCtrl::service] "+DETTAGLIO_AZIENDA);
          ValidationErrors errors = new ValidationErrors();
          error = new ValidationError(ex.getMessage());
          errors.add("error", error);
          request.setAttribute("errors", errors);
          url = DETTAGLIO_AZIENDA;
        }
      }
    }
  }//fine if(profile.isUtenteProvinciale()){
  else{
    ValidationError error = new ValidationError(""+UmaErrors.get("ERROREPROFILO"));
    ValidationErrors errors = new ValidationErrors();
    errors.add("error",error);
    request.setAttribute("errors", errors);
    url = DETTAGLIO_AZIENDA;
  }

  SolmrLogger.debug(this, "\n\n\n\n\n????????????????????????????????????????");
  SolmrLogger.debug(this, "url: "+url);
  SolmrLogger.debug(this, "????????????????????????????????????????\n\n\n\n\n");
%>
<jsp:forward page="<%=url%>"/>
<%!

  private ValidationErrors controllaIntermediarioDocCarta(ValidationErrors errors, HttpServletRequest request)
  {
      String dataRicevutaDocumentiStr=request.getParameter("dataRicevutaDocumenti");
      String extIdIntermediarioDocCartaStr=request.getParameter("tipiIntermediario");
      String numeroRicevutaDocumentiStr=request.getParameter("numeroRicevutaDocumenti");

      boolean bDataRicevutaDocumenti=Validator.isNotEmpty(dataRicevutaDocumentiStr);
      boolean bExtIdIntermediarioDocCarta=Validator.isNotEmpty(extIdIntermediarioDocCartaStr);
      boolean bNumeroDoc=Validator.isNotEmpty(numeroRicevutaDocumentiStr);

      if (bDataRicevutaDocumenti!=bExtIdIntermediarioDocCarta ||
          bExtIdIntermediarioDocCarta!=bNumeroDoc)
      {
        ValidationError valErr=new ValidationError("La data di ricezione documenti, il N. protocollo e la denominazione dell''intermediario devono essere tutti valorizzati o tutti non valorizzati");
        errors.add("dataRicevutaDocumenti",valErr);
        errors.add("tipiIntermediario",valErr);
        errors.add("numeroRicevutaDocumenti",valErr);
      }
      else
      {
        if (bDataRicevutaDocumenti) // Ne testo uno a caso tanto devono essere tutti uguali
        {
          Validator.validateDateAll(dataRicevutaDocumentiStr,
                                           "dataRicevutaDocumenti",
                                           "data di ricevuta documenti",
                                           errors,
                                           true,
                                           true);
          long NUMERO_MAX_RICEVUTA = 99999999;
          if (!Validator.isNumericInteger(numeroRicevutaDocumentiStr) ||
              getLong(numeroRicevutaDocumentiStr)<=0 ||
              getLong(numeroRicevutaDocumentiStr)>NUMERO_MAX_RICEVUTA)
          {
            errors.add("numeroRicevutaDocumenti",new ValidationError("Inserire un valore numerico maggiore di 0"));
          }
        }
      }
      return errors;
  }


  private ValidationErrors controllaConsumiRimanenze(ValidationErrors errors, HttpServletRequest request)
  {
      String MSG_NUMERICO_MAGGIORE_UGUALE_ZERO = "Inserire un valore numerico maggiore o uguale a 0";
      long NUMERO_MAX_RICEVUTA = 99999999;

      //Gas
      String rimanenzaContoGasStr = request.getParameter("rimanenzaContoGas");
      String rimanenzaContoTerziGasStr = request.getParameter("rimanenzaContoTerziGas");
      String rimanenzaSerraGasStr = request.getParameter("rimanenzaSerraGas");
      String consumoContoProprioGasStr = request.getParameter("consumoContoProprioGas");
      String consumoContoTerziGasStr = request.getParameter("consumoContoTerziGas");
      String consumoSerraGasStr = request.getParameter("consumoSerraGas");

      if (!Validator.isNumericInteger(rimanenzaContoGasStr) ||
          getLong(rimanenzaContoGasStr)<0 ||
          getLong(rimanenzaContoGasStr)>NUMERO_MAX_RICEVUTA)
      {
        errors.add("rimanenzaContoGas",new ValidationError(MSG_NUMERICO_MAGGIORE_UGUALE_ZERO));
      }

      if (!Validator.isNumericInteger(rimanenzaContoTerziGasStr) ||
          getLong(rimanenzaContoTerziGasStr)<0 ||
          getLong(rimanenzaContoTerziGasStr)>NUMERO_MAX_RICEVUTA)
      {
        errors.add("rimanenzaContoTerziGas",new ValidationError(MSG_NUMERICO_MAGGIORE_UGUALE_ZERO));
      }

      if (!Validator.isNumericInteger(rimanenzaSerraGasStr) ||
          getLong(rimanenzaSerraGasStr)<0 ||
          getLong(rimanenzaSerraGasStr)>NUMERO_MAX_RICEVUTA)
      {
        errors.add("rimanenzaSerraGas",new ValidationError(MSG_NUMERICO_MAGGIORE_UGUALE_ZERO));
      }

      if (!Validator.isNumericInteger(consumoContoProprioGasStr) ||
          getLong(consumoContoProprioGasStr)<0 ||
          getLong(consumoContoProprioGasStr)>NUMERO_MAX_RICEVUTA)
      {
        errors.add("consumoContoProprioGas",new ValidationError(MSG_NUMERICO_MAGGIORE_UGUALE_ZERO));
      }

      if (!Validator.isNumericInteger(consumoContoTerziGasStr) ||
          getLong(consumoContoTerziGasStr)<0 ||
          getLong(consumoContoTerziGasStr)>NUMERO_MAX_RICEVUTA)
      {
        errors.add("consumoContoTerziGas",new ValidationError(MSG_NUMERICO_MAGGIORE_UGUALE_ZERO));
      }

      if (!Validator.isNumericInteger(consumoSerraGasStr) ||
          getLong(consumoSerraGasStr)<0 ||
          getLong(consumoSerraGasStr)>NUMERO_MAX_RICEVUTA)
      {
        errors.add("consumoSerraGas",new ValidationError(MSG_NUMERICO_MAGGIORE_UGUALE_ZERO));
      }


      //Benzina
      String rimanenzaContoBenzStr = request.getParameter("rimanenzaContoBenz");
      String rimanenzaContoTerziBenzStr = request.getParameter("rimanenzaContoTerziBenz");
      String rimanenzaSerraBenzStr = request.getParameter("rimanenzaSerraBenz");
      String consumoContoProprioBenzStr = request.getParameter("consumoContoProprioBenz");
      String consumoContoTerziBenzStr = request.getParameter("consumoContoTerziBenz");
      String consumoSerraBenzStr = request.getParameter("consumoSerraBenz");

      if (!Validator.isNumericInteger(rimanenzaContoBenzStr) ||
          getLong(rimanenzaContoGasStr)<0 ||
          getLong(rimanenzaContoGasStr)>NUMERO_MAX_RICEVUTA)
      {
        errors.add("rimanenzaContoBenz",new ValidationError(MSG_NUMERICO_MAGGIORE_UGUALE_ZERO));
      }

      if (!Validator.isNumericInteger(rimanenzaContoTerziBenzStr) ||
          getLong(rimanenzaContoTerziBenzStr)<0 ||
          getLong(rimanenzaContoTerziBenzStr)>NUMERO_MAX_RICEVUTA)
      {
        errors.add("rimanenzaContoTerziBenz",new ValidationError(MSG_NUMERICO_MAGGIORE_UGUALE_ZERO));
      }

      if (!Validator.isNumericInteger(rimanenzaSerraBenzStr) ||
          getLong(rimanenzaSerraBenzStr)<0 ||
          getLong(rimanenzaSerraBenzStr)>NUMERO_MAX_RICEVUTA)
      {
        errors.add("rimanenzaSerraBenz",new ValidationError(MSG_NUMERICO_MAGGIORE_UGUALE_ZERO));
      }

      if (!Validator.isNumericInteger(consumoContoProprioBenzStr) ||
          getLong(consumoContoProprioBenzStr)<0 ||
          getLong(consumoContoProprioBenzStr)>NUMERO_MAX_RICEVUTA)
      {
        errors.add("consumoContoProprioBenz",new ValidationError(MSG_NUMERICO_MAGGIORE_UGUALE_ZERO));
      }

      if (!Validator.isNumericInteger(consumoContoTerziBenzStr) ||
          getLong(consumoContoTerziBenzStr)<0 ||
          getLong(consumoContoTerziBenzStr)>NUMERO_MAX_RICEVUTA)
      {
        errors.add("consumoContoTerziBenz",new ValidationError(MSG_NUMERICO_MAGGIORE_UGUALE_ZERO));
      }

      if (!Validator.isNumericInteger(consumoSerraBenzStr) ||
          getLong(consumoSerraBenzStr)<0 ||
          getLong(consumoSerraBenzStr)>NUMERO_MAX_RICEVUTA)
      {
        errors.add("consumoSerraBenz",new ValidationError(MSG_NUMERICO_MAGGIORE_UGUALE_ZERO));
      }


      //Documenti non intermediario
      String dataCessazioneAttivitaStr=request.getParameter("dataCessazioneAttivita");
      String dataDocumentazioneStr=request.getParameter("dataDocumentazione");
      String numeroDocumentiStr=request.getParameter("numeroDocumenti");

      boolean bDataCessazioneAttivita=Validator.isNotEmpty(dataCessazioneAttivitaStr);
      if(bDataCessazioneAttivita){
        Validator.validateDateAll(dataCessazioneAttivitaStr,
                                       "dataCessazioneAttivita",
                                       "data cessazione attività",
                                       errors,
                                       true,
                                       true);
      }

      boolean bDataDocumentazione=Validator.isNotEmpty(dataDocumentazioneStr);
      if(bDataDocumentazione){
        Validator.validateDateAll(dataDocumentazioneStr,
                                       "dataDocumentazione",
                                       "data documentazione",
                                       errors,
                                       true,
                                       true);
      }

      boolean bNumeroDocumenti=Validator.isNotEmpty(numeroDocumentiStr);
      if(bNumeroDocumenti){
        if (!Validator.isNumericInteger(numeroDocumentiStr) ||
            getLong(numeroDocumentiStr)<=0 ||
            getLong(numeroDocumentiStr)>NUMERO_MAX_RICEVUTA)
        {
          errors.add("numeroDocumenti",new ValidationError(MSG_NUMERICO_MAGGIORE_UGUALE_ZERO));
        }
      }

      return errors;
  }



  private long getLong(String num)
  {
    try
    {
      return new Long(num).longValue();
    }
    catch(Exception e)
    {
      return 0;
    }
 }
 
 public boolean validateExtCuaaAziendaDest(String extCuaaAziendaDest, String sNumeroDittaUma, String provincia, ValidationErrors errors, UmaFacadeClient umaFacadeClient)
 throws Exception
 {
    extCuaaAziendaDest=StringUtils.trim(extCuaaAziendaDest);
    sNumeroDittaUma=StringUtils.trim(sNumeroDittaUma);
    provincia=StringUtils.trim(provincia);
    if (Validator.isNotEmpty(extCuaaAziendaDest))
    {
      if (!Validator.controlloPIVA(extCuaaAziendaDest) && !Validator.controlloCf(extCuaaAziendaDest))
      {
        errors.add("extCuaaAziendaDest",new ValidationError(UmaErrors.ERR_CUAA_ERRATO));
      }
      else
      {
        if (Validator.isNotEmpty(sNumeroDittaUma) || Validator.isNotEmpty(provincia))
        {
          errors.add("extCuaaAziendaDest",new ValidationError(UmaErrors.ERR_VAL_CUAA_E_DITTA_NON_INSERIBILI_CONTEMPORANEAMENTE_IN_CESSAZIONE));
          errors.add("numeroDittaUma",new ValidationError(UmaErrors.ERR_VAL_CUAA_E_DITTA_NON_INSERIBILI_CONTEMPORANEAMENTE_IN_CESSAZIONE));
          errors.add("provincia",new ValidationError(UmaErrors.ERR_VAL_CUAA_E_DITTA_NON_INSERIBILI_CONTEMPORANEAMENTE_IN_CESSAZIONE));
        }
        else
        {
          DittaUMAAziendaVO duaVO=new DittaUMAAziendaVO();
          duaVO.setCuaa(extCuaaAziendaDest);
          //System.err.println("Ricerca CUAA");
          Vector idList=umaFacadeClient.getListIdAziendeDitte(duaVO, true);
          //System.err.println("idList.size()"+(idList==null?0:idList.size()));
          if (idList==null || idList.size()==0)
          {
            return true;
          }
          else
          {
            errors.add("extCuaaAziendaDest",new ValidationError(UmaErrors.ERR_CUAA_CESSAZIONE_ESISTENTE));
          }
        }
      }
    }
    return false;
 }
%>