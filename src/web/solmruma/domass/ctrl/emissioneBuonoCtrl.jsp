<%@ page import="it.csi.solmr.util.*,it.csi.solmr.dto.uma.*" %>
<%@ page language="java" contentType="text/html"isErrorPage="true"%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.util.SolmrLogger" %>
<%@ page import="it.csi.solmr.dto.anag.services.DelegaAnagrafeVO" %>

<%String iridePageName = "emissioneBuonoCtrl.jsp";%>
<%@include file = "/include/autorizzazione.inc" %>

<%
  SolmrLogger.debug(this, "BEGIN emissioneBuonoCtrl");
  
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  //061212 Buono prelievo emesso da intermediario - Begin
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idAzienda=dittaUMAAziendaVO.getIdAzienda();
  SolmrLogger.debug(this, "\n\n\n\n\n@@--//@@--//@@--//@@--//@@--//@@--//@@--//");
  SolmrLogger.debug(this, "idAzienda: "+idAzienda);
  DelegaAnagrafeVO delegaAnagrafeVO = umaFacadeClient.serviceGetDelega(idAzienda, null, null, null);

  SolmrLogger.debug(this, "delegaAnagrafeVO: "+delegaAnagrafeVO);
  String idIntermediarioValida = null;
  if(delegaAnagrafeVO!=null){
    SolmrLogger.debug(this, "if(delegaAnagrafeVO!=null)");
    idIntermediarioValida = delegaAnagrafeVO.getIdIntermediario();
  }
  SolmrLogger.debug(this, "idIntermediarioValida: "+idIntermediarioValida);
  SolmrLogger.debug(this, "@@--//@@--//@@--//@@--//@@--//@@--//@@--//\n\n\n\n\n");
  //061212 Buono prelievo emesso da intermediario - End

  String validateUrl = "/domass/view/emissioneBuonoView.jsp";
  String verificaAssUrl = "/domass/layout/verificaAssegnazioneValidata.htm";
  String precUrl = "/domass/layout/elencoBuoniEmessi.htm";
  //String precUrlView = "/domass/view/buoniPrelievoView.jsp";
  String url ="";

  SolmrLogger.debug(this,"profilo utenzaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa: "+ruoloUtenza.getIdUtente());

  Long idDittaUMA=null;
  Long idDomAss=null;
  Long annoRiferimento = null;

  Validator validator = new Validator(validateUrl);
  ValidationErrors errors = new ValidationErrors();

  DomandaAssegnazione domAssVO = new DomandaAssegnazione();

  int annoCorrente = 0;
  int annoRif = 0;

  if(request.getParameter("salva") != null){
  
    SolmrLogger.debug(this,"ho clickato salva!!!!!!!!!!!!!");

    if(request.getParameter("idDomAss")!=null)
      idDomAss = new Long(""+request.getParameter("idDomAss"));
    SolmrLogger.debug(this,"----idDomAss: "+idDomAss);

    if(request.getParameter("dittaUma")!=null)
      idDittaUMA = new Long(""+request.getParameter("dittaUma"));
    SolmrLogger.debug(this,"----idDittaUMA: "+idDittaUMA);

    if(request.getParameter("anno")!=null)
      annoRiferimento = new Long(""+request.getParameter("anno"));
    SolmrLogger.debug(this,"----annoRiferimento: "+annoRiferimento);

    try{
      String qtaConcAgriCPGas = "";
      String qtaConcAgriCPBenz = "";
      String qtaConcAgriCTGas = "";
      String qtaConcAgriCTBenz = "";
      String qtaConcRiscSerraGas = "";
      String qtaConcRiscSerraBenz = "";
      DittaUMAVO du = new DittaUMAVO();
      String codiceIstatDitta = "";

      if(!request.getParameter("numero").equals("")){
        String numeroDitta = request.getParameter("numero");
        if(numeroDitta.length()>6){
          ValidationError error = new ValidationError(""+UmaErrors.get("NUMERO_DITTA_NOT_VALID"));
          errors.add("error", error);
          request.setAttribute("errors", errors);
          request.getRequestDispatcher(validateUrl).forward(request, response);
          return;
        }
      }
      if(!request.getParameter("provincia").equals("")){
        String provDitta = request.getParameter("provincia");
        if(provDitta.length()>2){
          ValidationError error = new ValidationError(""+UmaErrors.get("PROVINCIA_NOT_VALID"));
          errors.add("error", error);
          request.setAttribute("errors", errors);
          request.getRequestDispatcher(validateUrl).forward(request, response);
          return;
        }
      }

      if(request.getParameter("qtaConcAgriCPGas")!=null && !request.getParameter("qtaConcAgriCPGas").equals(""))
        qtaConcAgriCPGas = request.getParameter("qtaConcAgriCPGas");
      if(request.getParameter("qtaConcAgriCPBenz")!=null && !request.getParameter("qtaConcAgriCPBenz").equals(""))
        qtaConcAgriCPBenz = request.getParameter("qtaConcAgriCPBenz");
      if(request.getParameter("qtaConcAgriCTGas")!=null && !request.getParameter("qtaConcAgriCTGas").equals(""))
        qtaConcAgriCTGas = request.getParameter("qtaConcAgriCTGas");
      if(request.getParameter("qtaConcAgriCTBenz")!=null && !request.getParameter("qtaConcAgriCTBenz").equals(""))
        qtaConcAgriCTBenz = request.getParameter("qtaConcAgriCTBenz");

      if(request.getParameter("qtaConcRiscSerraGas")!=null && !request.getParameter("qtaConcRiscSerraGas").equals(""))
        qtaConcRiscSerraGas = request.getParameter("qtaConcRiscSerraGas");
      if(request.getParameter("qtaConcRiscSerraBenz")!=null && !request.getParameter("qtaConcRiscSerraBenz").equals(""))
        qtaConcRiscSerraBenz = request.getParameter("qtaConcRiscSerraBenz");

//nessuna quantità concessa inserita deve superare la quantità disponibile
      //agricoltura
      int intQtaConcAgriCPGas = 0;
      int intDisponibileCPGas = 0;
      int intQtaConcAgriCPBenz = 0;
      int intDisponibileCPBenz = 0;

      int intQtaConcAgriCTGas = 0;
      int intDisponibileCTGas = 0;
      int intQtaConcAgriCTBenz = 0;
      int intDisponibileCTBenz = 0;

      //riscaldamento serra
      int intQtaConcRiscSerraGas = 0;
      int intDisponibileRiscSerraGas = 0;
      int intQtaConcRiscSerraBenz = 0;
      int intDisponibileRiscSerraBenz = 0;

      if(request.getParameter("qtaConcAgriCPGas")!=null && !request.getParameter("qtaConcAgriCPGas").equals(""))
        intQtaConcAgriCPGas = new Integer(request.getParameter("qtaConcAgriCPGas")).intValue();

      if(request.getParameter("disponibileCPGas")!=null && !request.getParameter("disponibileCPGas").equals(""))
        intDisponibileCPGas = new Integer(request.getParameter("disponibileCPGas")).intValue();

      if(request.getParameter("qtaConcAgriCTBenz")!=null && !request.getParameter("qtaConcAgriCTBenz").equals(""))
        intQtaConcAgriCTBenz = new Integer(request.getParameter("qtaConcAgriCTBenz")).intValue();

      if(request.getParameter("disponibileCTBenz")!=null && !request.getParameter("disponibileCTBenz").equals(""))
        intDisponibileCTBenz = new Integer(request.getParameter("disponibileCTBenz")).intValue();

      if(request.getParameter("qtaConcRiscSerraGas")!=null && !request.getParameter("qtaConcRiscSerraGas").equals(""))
        intQtaConcRiscSerraGas = new Integer(request.getParameter("qtaConcRiscSerraGas")).intValue();

      if(request.getParameter("disponibileGasDue")!=null && !request.getParameter("disponibileGasDue").equals(""))
        intDisponibileRiscSerraGas = new Integer(request.getParameter("disponibileGasDue")).intValue();

      if(request.getParameter("qtaConcRiscSerraBenz")!=null && !request.getParameter("qtaConcRiscSerraBenz").equals(""))
        intQtaConcRiscSerraBenz = new Integer(request.getParameter("qtaConcRiscSerraBenz")).intValue();

      if(request.getParameter("disponibileBenzDue")!=null && !request.getParameter("disponibileBenzDue").equals(""))
        intDisponibileRiscSerraBenz = new Integer(request.getParameter("disponibileBenzDue")).intValue();      

//controllo che almeno uno dei 4 dati di qta concessa sia stato valorizzato
      if(intQtaConcAgriCPGas==0 && intQtaConcAgriCPBenz==0 && intQtaConcAgriCTGas==0 && intQtaConcAgriCTBenz==0 && intQtaConcRiscSerraGas==0 && intQtaConcRiscSerraBenz==0){
        SolmrLogger.debug(this,"DOVREBBE DARE UN MSG DI ERRORE!!!!!!!!!!!!!!!!");
        ValidationError error = new ValidationError(""+UmaErrors.get("QTA_AGRI_RISC_SERRA_EMPTY"));
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(validateUrl).forward(request, response);
        return;
      }
      
      if(intQtaConcAgriCPGas>0 && (intQtaConcAgriCPGas-intDisponibileCPGas)>0)
        errors.add("qtaConcAgriCPGas", new ValidationError(""+UmaErrors.get("DIFFERENZA_QTA_CONC_DISP_NEGATIVA_NEW")));
      
      if(intQtaConcAgriCPBenz>0 && (intQtaConcAgriCPBenz-intDisponibileCPBenz)>0)
        errors.add("qtaConcAgriCPBenz", new ValidationError(""+UmaErrors.get("DIFFERENZA_QTA_CONC_DISP_NEGATIVA_NEW")));
     
      if(intQtaConcAgriCTGas>0 && (intQtaConcAgriCTGas-intDisponibileCTGas)>0)
        errors.add("qtaConcAgriCTGas", new ValidationError(""+UmaErrors.get("DIFFERENZA_QTA_CONC_DISP_NEGATIVA_NEW")));
      
      if(intQtaConcAgriCTBenz>0 && (intQtaConcAgriCTBenz-intDisponibileCTBenz)>0)
        errors.add("qtaConcAgriCTBenz", new ValidationError(""+UmaErrors.get("DIFFERENZA_QTA_CONC_DISP_NEGATIVA_NEW")));
      
      if((intQtaConcRiscSerraGas>0 && (intQtaConcRiscSerraGas-intDisponibileRiscSerraGas)>0))
        errors.add("qtaConcRiscSerraGas", new ValidationError(""+UmaErrors.get("DIFFERENZA_QTA_CONC_DISP_NEGATIVA_NEW")));
      
      if((intQtaConcRiscSerraBenz>0 && (intQtaConcRiscSerraBenz-intDisponibileRiscSerraBenz)>0))
        errors.add("qtaConcRiscSerraBenz", new ValidationError(""+UmaErrors.get("DIFFERENZA_QTA_CONC_DISP_NEGATIVA_NEW")));
        
      if(intQtaConcAgriCPGas<0)
        errors.add("qtaConcAgriCPGas", new ValidationError(""+UmaErrors.get("QTA_CONC_DISP_NEGATIVA")));
      
      if(intQtaConcAgriCPBenz<0)
        errors.add("qtaConcAgriCPBenz", new ValidationError(""+UmaErrors.get("QTA_CONC_DISP_NEGATIVA")));

      if(intQtaConcAgriCTGas<0)
        errors.add("qtaConcAgriCTGas", new ValidationError(""+UmaErrors.get("QTA_CONC_DISP_NEGATIVA")));
      
      if(intQtaConcAgriCTBenz<0)
        errors.add("qtaConcAgriCTBenz", new ValidationError(""+UmaErrors.get("QTA_CONC_DISP_NEGATIVA")));
      
      if(intQtaConcRiscSerraGas<0)
        errors.add("qtaConcRiscSerraGas", new ValidationError(""+UmaErrors.get("QTA_CONC_DISP_NEGATIVA")));
      
      if(intQtaConcRiscSerraBenz<0)
        errors.add("qtaConcRiscSerraBenz", new ValidationError(""+UmaErrors.get("QTA_CONC_DISP_NEGATIVA")));  
      
      if (!errors.empty())
      {
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(validateUrl).forward(request, response);
        return;
      }
      
      
			//FINE CONTROLLO nessuna quantità concessa inserita deve superare la quantità disponibile
      //provincia o ditta valorizzati -> entrambi obbligatori, oppure entrambi vuoti
      SolmrLogger.debug(this,"numero dalla VIEWWWWWWWWWWWWWWWWWWW "+request.getParameter("numero"));
      SolmrLogger.debug(this,"provincia dalla VIEWWWWWWWWWWWWWWWWWWW "+request.getParameter("provincia"));

      if((!request.getParameter("numero").equals("") && request.getParameter("provincia").equals("")) ||
         (request.getParameter("numero").equals("") && !request.getParameter("provincia").equals(""))){
        SolmrLogger.debug(this,"request.getParameter(numero): "+request.getParameter("numero"));
        SolmrLogger.debug(this,"request.getParameter(provincia): "+request.getParameter("numero"));

        //ex =  UmaErrors.PROV_O_NUMERODITTA_VUOTI;
        //throw new SolmrException(ex);
        ValidationError error = new ValidationError(""+UmaErrors.get("PROV_O_NUMERODITTA_VUOTI"));
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(validateUrl).forward(request, response);
        return;
      }
      else{
      
//se sono stati valorizzati numero ditta Uma e provincia devo controllare:
        Long idDomAssMaxData = null;

        if((!request.getParameter("numero").equals("") && !request.getParameter("provincia").equals(""))){
          DomandaAssegnazione da = new DomandaAssegnazione();

          SolmrLogger.debug(this,"prima di findByCriterio");
//1- la ditta deve esistere sulla tab ditta UMA con ext_prov_uma e ditta_uma inseriti dall'utente

          du.setDittaUMA(request.getParameter("numero"));
          du.setExtProvinciaUMA(request.getParameter("provincia"));
          try{
//3- la ditta NON deve essere la stessa su cui si sta operando
            if(request.getParameter("numero").equals(idDittaUMA.toString())){
              //throw new SolmrException(UmaErrors.DITTAUMASTESSA);
              ValidationError error = new ValidationError(""+UmaErrors.get("DITTAUMASTESSA"));
              errors.add("error", error);
              request.setAttribute("errors", errors);
              request.getRequestDispatcher(validateUrl).forward(request, response);
              return;
            }
            else{
              Vector vectUma = new Vector();
              SolmrLogger.debug(this,"prima di findDittaByVO, dittaUMA = "+du.getDittaUMA());
              SolmrLogger.debug(this,"prima di findDittaByVO, provincia = "+du.getExtProvinciaUMA());
              vectUma = umaFacadeClient.findDittaByVO(du);

//2- data cessazione della ditta deve essere != null
              SolmrLogger.debug(this,"dimensione vettore ditta uma: "+vectUma.size());
              //Long idDittaUmaRest = null;
              if(vectUma.size()>0){
                du = (DittaUMAVO)vectUma.firstElement();
                SolmrLogger.debug(this, "#############################");
                SolmrLogger.debug(this, "prima di findDittaByVO, idDitta = "+du.getIdDitta());
                SolmrLogger.debug(this, "#############################");
                if(du.getDataCessazione()== null){
                  //throw new SolmrException(UmaErrors.DITTAUMANONCESSATA);
                  ValidationError error = new ValidationError(""+UmaErrors.get("DITTAUMANONCESSATA"));
                  errors.add("error", error);
                  request.setAttribute("errors", errors);
                  request.getRequestDispatcher(validateUrl).forward(request, response);
                  return;
                }
                //else idDittaUmaRest = du.getIdDitta();

                //da = umaFacadeClient.findByCriterio(new Long(request.getParameter("numero")).longValue());
                da = umaFacadeClient.findByCriterio(du.getIdDitta().longValue());
                idDomAssMaxData = da.getIdDomandaAssegnazione();
                SolmrLogger.debug(this, "DOMANDA ULTIMAAAAAAAAAAAAAAAAAAAAAAAAA: "+idDomAssMaxData);
                codiceIstatDitta = du.getExtProvinciaUMA();
//4- deve essere stata fatta la restituzione -> lettura della domanda assegnazione con data riferimento
//   + recente e controllo che rimanenza conto proprio e rimanenza conto terzi suddivisi per benzina e
//   gasolio coincidano con quantità concessa sia per serra che base

                int rimanenzaBenz = umaFacadeClient.selectConsumoRimanenza(idDomAssMaxData, SolmrConstants.ID_BENZINA)+
                umaFacadeClient.selectConsumoRimanenzaSerra(idDomAssMaxData, SolmrConstants.ID_BENZINA);
                int rimanenzaGas = umaFacadeClient.selectConsumoRimanenza(idDomAssMaxData, SolmrConstants.ID_GASOLIO)+
                umaFacadeClient.selectConsumoRimanenzaSerra(idDomAssMaxData, SolmrConstants.ID_GASOLIO);                
                int qtaConcBenz = 0;
                int qtaConcGas = 0;
                if(request.getParameter("qtaConcAgriCPBenz")!=null && !request.getParameter("qtaConcAgriCPBenz").equals(""))
                  qtaConcBenz = new Integer(request.getParameter("qtaConcAgriCPBenz")).intValue();
                if(request.getParameter("qtaConcAgriCTBenz")!=null && !request.getParameter("qtaConcAgriCTBenz").equals(""))
                  qtaConcBenz += new Integer(request.getParameter("qtaConcAgriCTBenz")).intValue();
                if(request.getParameter("qtaConcRiscSerraBenz")!=null && !request.getParameter("qtaConcRiscSerraBenz").equals(""))
                  qtaConcBenz += new Integer(request.getParameter("qtaConcRiscSerraBenz")).intValue();

                if(request.getParameter("qtaConcAgriCPGas")!=null && !request.getParameter("qtaConcAgriCPGas").equals(""))
                  qtaConcGas = new Integer(request.getParameter("qtaConcAgriCPGas")).intValue();
                if(request.getParameter("qtaConcAgriCTGas")!=null && !request.getParameter("qtaConcAgriCTGas").equals(""))
                  qtaConcGas += new Integer(request.getParameter("qtaConcAgriCTGas")).intValue();
                if(request.getParameter("qtaConcRiscSerraGas")!=null && !request.getParameter("qtaConcRiscSerraGas").equals(""))
                  qtaConcGas += new Integer(request.getParameter("qtaConcRiscSerraGas")).intValue();

                if(qtaConcBenz>0 && rimanenzaBenz>qtaConcBenz ||
                   qtaConcGas>0 && rimanenzaGas>qtaConcGas){
                  //throw new SolmrException(UmaErrors.CHECK_RESTITUZIONE);
                  ValidationError error = new ValidationError(UmaErrors.ERR_VAL_RIMANENZE_DITTA_CESSATA_SUPERIORE_DISPONIBILITA);
                  errors.add("error", error);
                  request.setAttribute("errors", errors);
                  request.getRequestDispatcher(validateUrl).forward(request, response);
                  return;
                }
                // 2009-02-26 Modifica by Einaudi 
                qtaConcAgriCPBenz=String.valueOf(rimanenzaBenz);
                qtaConcAgriCPGas=String.valueOf(rimanenzaGas);
                qtaConcAgriCTBenz="0";
                qtaConcAgriCTGas="0";
                qtaConcRiscSerraBenz="0";
                qtaConcRiscSerraGas="0";
                // Fine Modifica
                SolmrLogger.debug(this, "rimanenzaBenz: "+rimanenzaBenz);
                SolmrLogger.debug(this, "qtaConcBenz: "+qtaConcBenz);
                SolmrLogger.debug(this, "rimanenzaGas: "+rimanenzaGas);
                SolmrLogger.debug(this, "qtaConcGas: "+qtaConcGas);
              }

            }//fine else ditta uma diversa da quella su cui si sta operando
          }catch(SolmrException except){
            /*valEx = new ValidationException("emissioneBuonoCtrl ", validateUrl);
            valEx.addMessage(except.getMessage(), "exception");
            throw valEx;*/
            ValidationError error = new ValidationError(except.getMessage());
            errors.add("error", error);
            request.setAttribute("errors", errors);
            request.getRequestDispatcher(validateUrl).forward(request, response);
            return;
          }
        }//fine if(request.getParameter("numero")!=null && request.getParameter("provincia")!=null)

        try{
//se è andato tutto a buon fine, inserisco in db_Buono_prelievo
          Vector insBuonoPrelievoVect = new Vector();
          NumerazioneBloccoVO nbVO = new NumerazioneBloccoVO();
          BuonoPrelievoVO bpVOAgriCP = new BuonoPrelievoVO();
          BuonoPrelievoVO bpVOAgriCT = new BuonoPrelievoVO();
          BuonoPrelievoVO bpVOSerra = new BuonoPrelievoVO();
          Long idDittaForInsertBP=idDittaUMA;

//Vector insBuonoPrelievoVect, contiene buoni, la posizione determina l'uso
// 0: agricoltura
// 1: serra
//se è stato valorizzato il dato quantità concessa per agricoltura
            if(intQtaConcAgriCPGas>0 || intQtaConcAgriCPBenz>0){

              SolmrLogger.debug(this, "bpVOAgri.setAnnoRiferimento(annoRiferimento): "+annoRiferimento);
              bpVOAgriCP.setAnnoRiferimento(annoRiferimento);
              nbVO.setAnno(annoRiferimento);
              bpVOAgriCP.setAnnullato("");
              bpVOAgriCP.setCarburantePerSerra("");
              bpVOAgriCP.setIdDomandaAssegnazione(idDomAss);
              bpVOAgriCP.setIdConduzione(1L);
              SolmrLogger.debug(this, "prima di ruoloUtenza.getIdUtente():");
              SolmrLogger.debug(this, "ruoloUtenza.getIdUtente(): "+ruoloUtenza.getIdUtente());
              bpVOAgriCP.setExtIdUtenteAggiornamento(ruoloUtenza.getIdUtente());

              //061212 Buono prelievo emesso da intermediario - Begin
              Long idUtente = ruoloUtenza.getIdUtente();
              bpVOAgriCP.setExtIdUtenteEmissione(idUtente.toString());
              if(ruoloUtenza.isUtenteIntermediario()){
                bpVOAgriCP.setExtIdIntermediarioEmissione(idIntermediarioValida);
                SolmrLogger.debug(this, "\n\n\n\n\n\n\n\n1############################");
                SolmrLogger.debug(this, "ruoloUtenza.isUtenteIntermediario(): "+ruoloUtenza.isUtenteIntermediario());
                SolmrLogger.debug(this, "idIntermediarioValida: "+idIntermediarioValida);
                SolmrLogger.debug(this, "############################\n\n\n\n\n\n\n\n");
              }
              //061212 Buono prelievo emesso da intermediario - End

              if(!request.getParameter("provincia").equals("")){
                bpVOAgriCP.setExtProvinciaProvenienza(codiceIstatDitta);
                bpVOAgriCP.setIdDittaUma(new Long(request.getParameter("numero")));
                bpVOAgriCP.setNumeroBlocco(new Long(SolmrConstants.NUMERO_BLOCCO));
                bpVOAgriCP.setNumeroBuono(new Long(SolmrConstants.NUMERO_BUONO));
              }
              else{
                du = umaFacadeClient.findByPrimaryKey(idDittaUMA);
                //idDittaForInsertBP = idDittaUMA;
                nbVO.setExtIdProvincia(du.getExtProvinciaUMA());
              }
              insBuonoPrelievoVect.add(0,bpVOAgriCP);
            }
            else insBuonoPrelievoVect.add(0, "");

			if(intQtaConcAgriCTGas>0 || intQtaConcAgriCTBenz>0){

              SolmrLogger.debug(this, "bpVOAgriCT.setAnnoRiferimento(annoRiferimento): "+annoRiferimento);
              bpVOAgriCT.setAnnoRiferimento(annoRiferimento);
              nbVO.setAnno(annoRiferimento);
              bpVOAgriCT.setAnnullato("");
              bpVOAgriCT.setCarburantePerSerra("");
              bpVOAgriCT.setIdDomandaAssegnazione(idDomAss);
              bpVOAgriCT.setIdConduzione(2L);
              SolmrLogger.debug(this, "prima di ruoloUtenza.getIdUtente():");
              SolmrLogger.debug(this, "ruoloUtenza.getIdUtente(): "+ruoloUtenza.getIdUtente());
              bpVOAgriCT.setExtIdUtenteAggiornamento(ruoloUtenza.getIdUtente());

              //061212 Buono prelievo emesso da intermediario - Begin
              Long idUtente = ruoloUtenza.getIdUtente();
              bpVOAgriCT.setExtIdUtenteEmissione(idUtente.toString());
              if(ruoloUtenza.isUtenteIntermediario()){
                bpVOAgriCT.setExtIdIntermediarioEmissione(idIntermediarioValida);
                SolmrLogger.debug(this, "\n\n\n\n\n\n\n\n1############################");
                SolmrLogger.debug(this, "ruoloUtenza.isUtenteIntermediario(): "+ruoloUtenza.isUtenteIntermediario());
                SolmrLogger.debug(this, "idIntermediarioValida: "+idIntermediarioValida);
                SolmrLogger.debug(this, "############################\n\n\n\n\n\n\n\n");
              }
              //061212 Buono prelievo emesso da intermediario - End

              if(!request.getParameter("provincia").equals("")){
                bpVOAgriCT.setExtProvinciaProvenienza(codiceIstatDitta);
                bpVOAgriCT.setIdDittaUma(new Long(request.getParameter("numero")));
                bpVOAgriCT.setNumeroBlocco(new Long(SolmrConstants.NUMERO_BLOCCO));
                bpVOAgriCT.setNumeroBuono(new Long(SolmrConstants.NUMERO_BUONO));
              }
              else{
                du = umaFacadeClient.findByPrimaryKey(idDittaUMA);
                //idDittaForInsertBP = idDittaUMA;
                nbVO.setExtIdProvincia(du.getExtProvinciaUMA());
              }
              insBuonoPrelievoVect.add(1,bpVOAgriCT);
            }
            else insBuonoPrelievoVect.add(1, "");

//se è stato valorizzato il dato quantità concessa per serra
            if(intQtaConcRiscSerraGas>0 || intQtaConcRiscSerraBenz>0){
              SolmrLogger.debug(this, "bpVOSerra annoRiferimento: "+annoRiferimento);
              bpVOSerra.setAnnoRiferimento(annoRiferimento);
              nbVO.setAnno(annoRiferimento);
              bpVOSerra.setAnnullato("");
              bpVOSerra.setExtIdUtenteAggiornamento(ruoloUtenza.getIdUtente());
              bpVOSerra.setIdConduzione(null);
              if(!request.getParameter("qtaConcRiscSerraBenz").equals("") || !request.getParameter("qtaConcRiscSerraGas").equals(""))
                bpVOSerra.setCarburantePerSerra(SolmrConstants.CARBURANTE_PER_SERRA);
              else bpVOSerra.setCarburantePerSerra("");

              bpVOSerra.setIdDomandaAssegnazione(idDomAss);

              //061212 Buono prelievo emesso da intermediario - Begin
              Long idUtente = ruoloUtenza.getIdUtente();
              bpVOSerra.setExtIdUtenteEmissione(idUtente.toString());
              if(ruoloUtenza.isUtenteIntermediario()){
                bpVOSerra.setExtIdIntermediarioEmissione(idIntermediarioValida);
                SolmrLogger.debug(this, "\n\n\n\n\n\n\n\n2############################");
                SolmrLogger.debug(this, "ruoloUtenza.isUtenteIntermediario(): "+ruoloUtenza.isUtenteIntermediario());
                SolmrLogger.debug(this, "idIntermediarioValida: "+idIntermediarioValida);
                SolmrLogger.debug(this, "############################\n\n\n\n\n\n\n\n");
              }
              //061212 Buono prelievo emesso da intermediario - End

              if(!request.getParameter("provincia").equals("")){
                bpVOSerra.setExtProvinciaProvenienza(codiceIstatDitta);
                bpVOSerra.setIdDittaUma(new Long(request.getParameter("numero")));
                bpVOSerra.setNumeroBlocco(new Long(SolmrConstants.NUMERO_BLOCCO));
                bpVOSerra.setNumeroBuono(new Long(SolmrConstants.NUMERO_BUONO));
              }
              else{
                du = umaFacadeClient.findByPrimaryKey(idDittaUMA);
                //idDittaForInsertBP = idDittaUMA;
                nbVO.setExtIdProvincia(du.getExtProvinciaUMA());
              }

              insBuonoPrelievoVect.add(2,bpVOSerra);
            }
            else{
               insBuonoPrelievoVect.add(2, "");
            }

            Vector forBuoniCarburante = new Vector();
            Vector forBuoniCarburanteAgriCP = new Vector();
            Vector forBuoniCarburanteAgriCT = new Vector();
            Vector forBuoniCarburanteSerra = new Vector();

            if(!qtaConcAgriCPBenz.equals("") && !qtaConcAgriCPBenz.equals("0")){
              BuonoCarburanteVO bcVOAgriBenz = new BuonoCarburanteVO();
              bcVOAgriBenz.setQuantitaConcessa(new Long(qtaConcAgriCPBenz));
              bcVOAgriBenz.setIdCarburante(new Long(SolmrConstants.ID_BENZINA));
              forBuoniCarburanteAgriCP.add(bcVOAgriBenz);
            }
            if(!qtaConcAgriCPGas.equals("") && !qtaConcAgriCPGas.equals("0")){
              BuonoCarburanteVO bcVOAgriGas= new BuonoCarburanteVO();              
              bcVOAgriGas.setQuantitaConcessa(new Long(qtaConcAgriCPGas));
              SolmrLogger.debug(this, "-- bcVOAgriGas.setQuantitaConcessa ="+bcVOAgriGas.getQuantitaConcessa() );
              bcVOAgriGas.setIdCarburante(new Long(SolmrConstants.ID_GASOLIO));
              forBuoniCarburanteAgriCP.add(bcVOAgriGas);
            }
            forBuoniCarburante.add(0,forBuoniCarburanteAgriCP);

            if(!qtaConcAgriCTBenz.equals("") && !qtaConcAgriCTBenz.equals("0")){
              BuonoCarburanteVO bcVOAgriBenz = new BuonoCarburanteVO();
              bcVOAgriBenz.setQuantitaConcessa(new Long(qtaConcAgriCTBenz));
              bcVOAgriBenz.setIdCarburante(new Long(SolmrConstants.ID_BENZINA));
              forBuoniCarburanteAgriCT.add(bcVOAgriBenz);
            }
            if(!qtaConcAgriCTGas.equals("") && !qtaConcAgriCTGas.equals("0")){
              BuonoCarburanteVO bcVOAgriGas= new BuonoCarburanteVO();
              bcVOAgriGas.setQuantitaConcessa(new Long(qtaConcAgriCTGas));
              bcVOAgriGas.setIdCarburante(new Long(SolmrConstants.ID_GASOLIO));
              forBuoniCarburanteAgriCT.add(bcVOAgriGas);
            }
            forBuoniCarburante.add(1,forBuoniCarburanteAgriCT);

            if(!qtaConcRiscSerraBenz.equals("") && !qtaConcRiscSerraBenz.equals("0")){
              BuonoCarburanteVO bcVOSerraBenz= new BuonoCarburanteVO();
              bcVOSerraBenz.setQuantitaConcessa(new Long(qtaConcRiscSerraBenz));
              bcVOSerraBenz.setIdCarburante(new Long(SolmrConstants.ID_BENZINA));
              forBuoniCarburanteSerra.add(bcVOSerraBenz);
            }

            if(!qtaConcRiscSerraGas.equals("") && !qtaConcRiscSerraGas.equals("0")){
              BuonoCarburanteVO bcVOSerraGas= new BuonoCarburanteVO();
              bcVOSerraGas.setQuantitaConcessa(new Long(qtaConcRiscSerraGas));
              bcVOSerraGas.setIdCarburante(new Long(SolmrConstants.ID_GASOLIO));
              forBuoniCarburanteSerra.add(bcVOSerraGas);
            }
            forBuoniCarburante.add(2,forBuoniCarburanteSerra);
            
            try{

              SolmrLogger.debug(this, "\n\n\n\n\n\n\n\n2//##//##//##//##//##//##");
              SolmrLogger.debug(this, "request.getParameter(\"provincia\"): "+request.getParameter("provincia"));
              if(request.getParameter("provincia").equals("")){
                SolmrLogger.debug(this, "if(request.getParameter(\"provincia\").equals(\"\")");
                NumerazioneBloccoVO nbPerBlocco = new NumerazioneBloccoVO();
                nbPerBlocco = umaFacadeClient.selectNumerazioneBlocco(idDittaForInsertBP, nbVO, insBuonoPrelievoVect, forBuoniCarburante);
              }
              else{
                SolmrLogger.debug(this, "else(request.getParameter(\"provincia\").equals(\"\")");
                umaFacadeClient.insertVectBuonoPrelievoBase(idDittaForInsertBP, null, insBuonoPrelievoVect, forBuoniCarburante);
              }
              SolmrLogger.debug(this, "//##//##//##//##//##//##\n\n\n\n\n\n\n\n");
            }catch(SolmrException se){
              SolmrLogger.debug(this, "\n\n\n\n\n\n");
              SolmrLogger.debug(this, "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee "+se.getMessage());
              ValidationError error = new ValidationError(se.getMessage());
              errors.add("error", error);
              request.setAttribute("errors", errors);
              if(se.getMessage().equals(""+UmaErrors.get("NO_EMISSIONE_BUONO_PRELIEVO_BASE")))
                url = precUrl;
              else url = validateUrl;
              SolmrLogger.debug(this, "");
              request.getRequestDispatcher(url).forward(request, response);
              return;
            }
            //}
            SolmrLogger.debug(this, "***********prima della forward!!!!!!!!!!!!! ");
            ////////////////////////////////////////////////////////////
            Vector v_domass = umaFacadeClient.findDomAssByIdDittaUma(idDittaUMA);
            if(v_domass!=null&&v_domass.size()!=0)
              session.setAttribute("v_domass", v_domass);
			//////////////////////////////////////////////////////////////////////

            request.getRequestDispatcher(precUrl).forward(request, response);
        }
        catch(SolmrException except){
          ValidationError error = new ValidationError(except.getMessage());
          errors.add("error", error);
          request.setAttribute("errors", errors);
          request.getRequestDispatcher(validateUrl).forward(request, response);
          return;
        }
      }//fine else
    }
    catch(SolmrException exc){      
      SolmrLogger.debug(this, "VA QUIIIIIIIIIIIIIIIIIIIIIII "+exc.getMessage());
      SolmrLogger.debug(this, "request.getAttribute(\"pageFrom\"): "+request.getAttribute("pageFrom"));
      SolmrLogger.debug(this, "session.getAttribute(\"pageFrom\"): "+session.getAttribute("pageFrom"));
      SolmrLogger.debug(this, "VA QUIIIIIIIIIIIIIIIIIIIIIII "+url);
      if(request.getParameter("pageFrom")!=null){
        request.setAttribute("fromEmissione", "emissione");
        SolmrLogger.debug(this, "idDomAss: "+request.getParameter("idDomAss"));
        request.setAttribute("idDomAss", idDomAss);
        url = verificaAssUrl;
      }
      else url = precUrl;
      ValidationError error = new ValidationError(exc.getMessage());
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(url).forward(request, response);
      return;
    }
  }//fine se ho clickato "salva"
  else if(request.getParameter("annullaEmissione")!= null){
    SolmrLogger.debug(this, "annullaEmissione, pageFrom: "+request.getParameter("pageFrom"));
    if(request.getParameter("pageFrom")!=null && request.getParameter("pageFrom").equalsIgnoreCase("validazione")){
      request.setAttribute("fromEmissione", "emissione");
      SolmrLogger.debug(this, "idDomAss: "+request.getParameter("idDomAss"));
      request.setAttribute("idDomAss", idDomAss);
      url = verificaAssUrl;
    }
    else{
      SolmrLogger.debug(this, "precUrl: "+precUrl);
      url = precUrl;
    }
    request.getRequestDispatcher(url).forward(request, response);
  }//fine else if(request.getParameter("annullaEmissione")!= null)
  else{
    try{

      if(request.getParameter("select")!=null)
        idDomAss = new Long(request.getParameter("select"));

      domAssVO = umaFacadeClient.findDomAssByPrimaryKey(idDomAss);
      idDittaUMA = new Long(domAssVO.getIdDitta());
      annoRiferimento = new Long(DateUtils.extractYearFromDate(domAssVO.getDataRiferimento()));

      request.setAttribute("idDomAss",idDomAss);
      request.setAttribute("dittaUma",idDittaUMA);
      request.setAttribute("anno",annoRiferimento);
    }
    catch(SolmrException se){
      if(request.getParameter("pageFrom")!=null){
        request.setAttribute("fromEmissione", "emissione");
        SolmrLogger.debug(this, "idDomAss: "+request.getParameter("idDomAss"));
        request.setAttribute("idDomAss", idDomAss);
        url = verificaAssUrl;
      }
      else url = precUrl;
      ValidationError error = new ValidationError(se.getMessage());
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(url).forward(request, response);
      return;
    }
    annoCorrente = DateUtils.getCurrentYear().intValue();
    annoRif = annoRiferimento.intValue();

    SolmrLogger.debug(this, "idDomAss: "+idDomAss);
    SolmrLogger.debug(this, "idDittaUMA: "+idDittaUMA);
    SolmrLogger.debug(this, "annoRif: "+annoRif);

    if(annoRif == annoCorrente){
      try
      {
        SolmrLogger.debug(this, "if(annoRif == annoCorrente)");
        request.setAttribute("dittaUma",idDittaUMA);
        request.setAttribute("idDomAss",idDomAss);
        request.setAttribute("anno",annoRiferimento);

        if(idDittaUMA!=null && idDomAss!=null){
          SolmrLogger.debug(this, "if (idDittaUMA!=null && idDomAss!=null)");
          umaFacadeClient.checkForEmissione(idDittaUMA, idDomAss);
        }
        else
          SolmrLogger.debug(this, "else (idDittaUMA!=null && idDomAss!=null)");

        request.getRequestDispatcher(validateUrl).forward(request, response);
      }
      catch(SolmrException ex){
        SolmrLogger.debug(this, "eccezione: "+ex.getMessage());

        if(request.getParameter("pageFrom")!=null){
          request.setAttribute("fromEmissione", "emissione");
          SolmrLogger.debug(this, "idDomAss: "+request.getParameter("idDomAss"));
          request.setAttribute("idDomAss", idDomAss);
          url = verificaAssUrl;
        }
        else url = precUrl;
        ValidationError error = new ValidationError(ex.getMessage());
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(url).forward(request, response);
        return;
      }
    }
    else{
      if(request.getParameter("pageFrom")!=null){
        request.setAttribute("fromEmissione", "emissione");
        SolmrLogger.debug(this, "idDomAss: "+request.getParameter("idDomAss"));
        request.setAttribute("idDomAss", idDomAss);
        url = verificaAssUrl;
      }
      else url = precUrl;
      ValidationError error = new ValidationError(""+UmaErrors.get("ANNO_DOMASS_NON_CORRENTE"));
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(url).forward(request, response);
      return;
    }
  }
%>