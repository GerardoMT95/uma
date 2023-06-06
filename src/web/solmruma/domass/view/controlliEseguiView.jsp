<%@ page language="java" contentType="text/html" isErrorPage="true"%>

<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.client.uma.UmaFacadeClient"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO"%>
<%@ page import="it.csi.solmr.dto.uma.DomandaAssegnazione"%>
<%@ page import="it.csi.solmr.util.DateUtils"%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.etc.SolmrErrors"%>
<%@ page import="it.csi.solmr.util.SolmrLogger"%>
<%@page import="it.csi.solmr.util.SianUtils"%>

<%!public static final String LAYOUT                 = "/domass/layout/controlliEsegui.htm";
  public static final String CONTROLLI_PROCEDIMENTO = "../layout/controlliFine.htm";
  public static final String CONTROLLI_ERRORE       = "../layout/controlliErrore.htm";%>

<%
  SolmrLogger.info(this, " - controlliEseguiView.jsp - INIZIO PAGINA");

  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file="/include/menu.inc"%>
<%
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  SolmrLogger.info(this, "\n\n\n1");
  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");
  SolmrLogger.info(this, "\n\n\n2");

  Long result = null;

  //visualizzo immediatamente la form per l'attesa
  out.print(htmpl.text());
  out.flush();

  Hashtable common = (Hashtable) session.getAttribute("common");
  SolmrLogger.debug(this, "common: " + common);
  String notifica = (String) common.get("notifica");
  SolmrLogger.debug(this, "notifica: " + notifica);
  //Elimina visualizzazione @@blkAbilitazioni
  //common.remove("notifica");

  String controlliSuccessivoUrl = null;
  //effettuo i controlli
  try
  {
    Long idDittaUma = dittaVO.getIdDittaUMA();

    SolmrLogger.debug(this, "SolmrError.get(\"ERR_DITTA_CESSATA\"): "
        + SolmrErrors.get("ERR_DITTA_CESSATA"));
    SolmrLogger.debug(this, "dittaVO.getDataCessazioneUMA(): "
        + dittaVO.getDataCessazioneUMA());

    //051216 Controlli x importazione dati - Begin
    if (notifica != null)
    {
      SolmrLogger.debug(this, "if(notifica!=null)");
      if (dittaVO.getDataCessazioneUMA() != null)
      {
        SolmrLogger.debug(this, "if(dittaVO.getDataCessazioneUMA()!=null)");
        throw new SolmrException((String) SolmrConstants
            .get("MSG_DITTA_UMA_CESSATA_CONTROLLI"));
      }

      try
      {
        umaFacadeClient.isDittaUmaBloccata(idDittaUma);
      }
      catch (SolmrException sExc)
      {
        throw new SolmrException((String) SolmrConstants
            .get("MSG_DITTA_UMA_BLOCCATA_CONTROLLI"));
      }

      Long annoRiferimento = new Long(DateUtils
          .extractYearFromDate(new Date()));
      if (notifica.equalsIgnoreCase("base"))
      {
        Vector datiDomanda = umaFacadeClient.findIdDomAssValidate(
            idDittaUma, annoRiferimento);
        if (datiDomanda != null)
        {
          Long statoDomanda = (Long) datiDomanda.get(1);
          if (statoDomanda.longValue() == new Long((String) SolmrConstants
              .get("ID_STATO_DOMANDA_VALIDATA")).longValue())
          {
            throw new SolmrException((String) SolmrConstants
                .get("MSG_DITTA_UMA_DOMANDA_VALIDATA_CONTROLLI"));
          }
        }
      }
    }
    //051216 Controlli x importazione dati - End

    Long annoAssegnazione = null;
    if (notifica == null)
    {
      //notifica=null (controlli.x)
      Long idDomandaAssegnazione = (Long) common
          .get("idDomandaAssegnazione");
      SolmrLogger.debug(this, "idDomandaAssegnazione: "
          + idDomandaAssegnazione);
      DomandaAssegnazione domandaAssegnazione = umaFacadeClient
          .findDomAssByPrimaryKey(idDomandaAssegnazione);
      SolmrLogger
          .debug(this, "domandaAssegnazione: " + domandaAssegnazione);
      Date dataAssegnazione = domandaAssegnazione.getDataRiferimento();
      SolmrLogger.debug(this, "dataAssegnazione: " + dataAssegnazione);
      SolmrLogger.debug(this,
          "DateUtils.extractYearFromDate(dataAssegnazione): "
              + DateUtils.extractYearFromDate(dataAssegnazione));

      annoAssegnazione = new Long(DateUtils
          .extractYearFromDate(dataAssegnazione));
    }
    else
    {
      //notifica=base - notifica=supplementare
      annoAssegnazione = new Long(DateUtils.extractYearFromDate(new Date()));
    }

    SolmrLogger.debug(this, "\n\n\n*****1");
    String tipoControllo = SolmrConstants.TIPO_CONTROLLO_PL_T;
    SolmrLogger.debug(this, "-- tipoControllo ="+tipoControllo);
    SolmrLogger.debug(this, "\n\n\n*****2");

    String tipoFase = null;
    if (notifica == null)
    {
      tipoFase = SolmrConstants.TIPO_FASE_PL_CONTROLLI;
    }
    else
    {
	    /*
	      Modifiche marzo 2015
				Vengono separati i controlli plsql effettuati in fase si assgenazione supplementare rispetto a quelli effettuati in assegnazione base/saldo.
				In caso di assegnazione supplementare il package plsql PACK_CONTROLLI deve essere richiamato con un ID_TIPO_FASE specifico 
				per il supplemento, quindi viene richiamato passando in input i seguenti parametri: 
				- P_ID_DITTA_UMA uguale alla ditta uma in esame
				- P_ANNO_ASSEGNAZIONE uguale all'anno corrente (anno della data di sistema)
				- P_TIPO_CONTROLLO uguale a 'T'
				- P_TIPO_FASE uguale a 'P' (tipo fase assegnazione supplementare)
      */
      SolmrLogger.debug(this, "-- notifica ="+notifica);
      if ("supplementare".equals(notifica)){
        tipoFase = SolmrConstants.TIPO_FASE_PL_ASSEGNAZIONE_SUPPLEMENTARE;
      }  
      else if("supplementareMaggiorazione".equals(notifica)){
    	  tipoFase = SolmrConstants. TIPO_FASE_PL_ASSEGNAZIONE_SUPPLEMENTARE_MAGGIORAZIONE;
      }
      else{
    	  tipoFase = SolmrConstants.TIPO_FASE_PL_ASSEGNAZIONE;
      }
      SolmrLogger.debug(this, "-- tipoFase ="+tipoFase);
      // Modidifica by Einaudi 23/10/2006
      // Richiamare il servizio Sian solo se il parametro "TRIB" su db_parametro
      // vale "S"
      String trib = umaFacadeClient.getParametro(SolmrConstants.PARAMETRO_TRIBUTARIA); // TRIB
      SolmrLogger.debug(this, "-- trib ="+trib);
      if (SolmrConstants.FLAG_SI.equalsIgnoreCase(trib))
      {
        try
        {
          if (dittaUMAAziendaVO.getCuaa() != null)
          // Non lo chiamo se il cuaa è null perchè darebbe errore di parametri
          // non validi che farebbe visualizzare la pagina di errore generico del
          // sian.
          {
            umaFacadeClient.serviceSianAggiornaDatiTributaria(dittaVO
                .getCuaa(), SianUtils.getSianVO(ruoloUtenza));
          }
        }
        catch (Exception ex)
        {
          SolmrLogger.debug(this,
              "Rilevata eccezione nel richiamo del servizio "
                  + "serviceSianAggiornaDatiTributaria("
                  + dittaVO.getCuaa() + ") " + "Messaggio di errore = "
                  + ex.getMessage() + "\nStacktrace=" + ex.toString());
          throw new SolmrException(
              "Si è verificato un errore nella registrazione dei dati provenienti "
                  + "dal SIAN. Se il problema persiste contattare l'assistenza tecnica.");
        }
      }
      // Fine Modifica

      try
      {
        SolmrLogger.debug(this, "dittaVO.getCuaa(): " + dittaVO.getCuaa());
        SolmrLogger.debug(this, "Before - serviceAggiornaDatiAAEP");
        umaFacadeClient.serviceAggiornaDatiAAEP(dittaVO.getCuaa());
        SolmrLogger.debug(this, "After - serviceAggiornaDatiAAEP");
      }
      catch (Exception ex)
      {
        SolmrLogger
            .debug(this,
                "Exception - umaFacadeClient.serviceAggiornaDatiAAEP(dittaVO.getCuaa())");
      }
    }
    SolmrLogger.debug(this, "\n\n\n*****ruoloUtenza: " + ruoloUtenza);

    //effettuo i controlli
    SolmrLogger.debug(this, "idDittaUma: " + idDittaUma);
    SolmrLogger.debug(this, "annoAssegnazione: " + annoAssegnazione);
    SolmrLogger.debug(this, "tipoControllo: " + tipoControllo);
    SolmrLogger.debug(this, "tipoFase: " + tipoFase);

    result = umaFacadeClient.preControlliPraticaPL(idDittaUma,
        annoAssegnazione, tipoControllo, tipoFase);

    SolmrLogger
        .debug(this, "preControlliPraticaPL Jsp - result: " + result);

    if (result.longValue() == new Long(
        SolmrConstants.RISULTATO_PL_NESSUN_ERRORE).longValue())
    {
      SolmrLogger.debug(this,
          "Nessun errore nell'esecuzione della procedura PLSQL");
    }

    //inserisco come stringa
    common.put("risCreazione", "" + result);
    common
        .put("msgCreazione", SolmrConstants.MSG_CONTROLLI_TRASMISSIONE_OK);
    session.setAttribute("common", common);
    controlliSuccessivoUrl = CONTROLLI_PROCEDIMENTO;
  }
  catch (SolmrException agriExc)
  {

    //Imposto errori pre-controlli
    SolmrLogger.debug(this, "******* tipo errore: "
        + agriExc.getErrorType());
    common.put("risCreazione", "" + agriExc.getErrorType());
    common.put("msgCreazione", agriExc.getMessage());
    session.setAttribute("common", common);
    controlliSuccessivoUrl = CONTROLLI_ERRORE;
  }
  catch (Exception ex)
  {
    //Imposto errore grave di sistema
    SolmrLogger.fatal(this, "***** ERRORE " + ex.getMessage());
    common.put("risCreazione", ""
        + SolmrConstants.RISULTATO_PL_ERRORE_SISTEMA);
    common.put("msgCreazione", ex.getMessage());
    session.setAttribute("common", common);
    controlliSuccessivoUrl = CONTROLLI_ERRORE;
  }

  //ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  //HtmplUtil.setErrors(htmpl, errors, request);

  if (controlliSuccessivoUrl == null)
  {
    controlliSuccessivoUrl = CONTROLLI_PROCEDIMENTO;
  }

  SolmrLogger.info(this, " - controlliEseguiView.jsp - FINE PAGINA");
%>
<script language="javascript1.2">
  window.document.form1.action='<%=controlliSuccessivoUrl%>';
  window.document.form1.submit();
</script>