<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.dto.anag.ParametroRitornoVO" %>
<%@ page import="java.util.Vector" %>
<%@ page import="it.csi.solmr.util.Validator" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.util.ValidationError" %>
<%@ page import="it.csi.solmr.util.ValidationErrors" %>
<%@ page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO" %>
<%@ page import="it.csi.solmr.util.NumberUtils" %>
<%@ page import="it.csi.solmr.exception.SolmrException" %>
<%@ page import="it.csi.solmr.dto.anag.AnagAziendaVO" %>
<%@ page import="it.csi.solmr.util.SolmrLogger" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.StringTokenizer" %>
<%@ page import="java.util.Date" %>
<%@ page import="it.csi.solmr.etc.SolmrConstants" %>
<%@ page import="it.csi.solmr.util.DateUtils" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  private static final String VIEW="/anag/view/elencoAziendeRapLegaleView.jsp";
  private static final String DETTAGLIO="../layout/dettaglioAzienda.htm";
%><%
  session.removeAttribute("idAziendeRL_TCF");
  String iridePageName = "elencoAziendeRapLegaleCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  ParametroRitornoVO parametroRitornoVO=null;
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  Long idAziende[]=null;
  if (ruoloUtenza.isUtenteNonIscrittoCIIA())
  {
    AnagAziendaVO anagAziendaVO=new AnagAziendaVO(); 
    anagAziendaVO.setCUAA(ruoloUtenza.getCUAA());
    Vector ids=umaFacadeClient.serviceGetListIdAziende(anagAziendaVO, Boolean.TRUE, Boolean.FALSE);
    int length=ids==null?0:ids.size();
    if (length>0)
    {
       idAziende=(Long[])ids.toArray(new Long[length]);
    }
  }
  else
  {
    if (ruoloUtenza.isUtenteLegaleRappresentante())
    {
      parametroRitornoVO = umaFacadeClient.serviceGetAziendeAAEPAnagrafe(ruoloUtenza.getCodiceFiscale(),
                                                                         false,
                                                                         null,
                                                                         true,
                                                                         false);
    }
    else
    {
      parametroRitornoVO = umaFacadeClient.serviceGetAziendeAAEPAnagrafe(ruoloUtenza.getCodiceFiscale(),
                                                                         false,
                                                                         new Boolean(false),
                                                                         true,
                                                                         false);
    }
    if (parametroRitornoVO!=null)
    {
      idAziende=parametroRitornoVO.getIdAzienda();
    }
  }
  boolean loadList=false;
  if (request.getParameter("conferma")!=null)
  {
    // E' stato premuto il pulsante conferma ==> valido i dati
    String parIdDittaUMA=request.getParameter("idDittaUMA");
    if (Validator.isEmpty(parIdDittaUMA) || !Validator.isNumericInteger(parIdDittaUMA))
    {
      // Errore ==> Segnalo all'utente
      ValidationErrors errors=new ValidationErrors();
      errors.add("error",new ValidationError(UmaErrors.ERRORE_SELEZIONARE_DITTA_UMA));
      request.setAttribute("errors",errors);
      loadList=true;
    }
    else
    {
      // Nessun errore ==> carico l'azienda
      Long idDittaUMA=new Long(parIdDittaUMA); // No NumberFormatException perchè
      // controllato da Validator.isNumericInteger()
      DittaUMAAziendaVO durVO=new DittaUMAAziendaVO();
      durVO.setIdDittaUMA(idDittaUMA);
      DittaUMAAziendaVO duaVO=null;
      duaVO=umaFacadeClient.findDittaUMAAziendaByIdDittaUMA(idDittaUMA);
      if (duaVO==null)
      {
        throw new SolmrException(UmaErrors.ERRORE_NESSUNA_DITTA_TROVATA);
      }
      if (idAziende!=null)
      {
        boolean isInList=NumberUtils.in(duaVO.getIdAzienda(),idAziende);
        if (isInList)
        {
          doSessionVar(session,umaFacadeClient);
          request.getSession().setAttribute("dittaUMAAziendaVO",duaVO);
          // Metto in request l'elenco degli id a cui può accedere
          session.setAttribute("idAziendeRL_TCF",idAziende);
          response.sendRedirect(DETTAGLIO);
        }
        else
        {
          throw new SolmrException(UmaErrors.ERRORE_NO_DIRITTI_ACCESSO_DITTA);
        }
      }
      return;
    }
  }
  else
  {
    loadList=true;
  }
  if (loadList)
  {
    if (parametroRitornoVO!=null)
    {
      request.setAttribute("parametroRitornoVO",parametroRitornoVO);
    }
    if (idAziende!=null)
    {
      request.setAttribute("idAziende",idAziende);
      it.csi.solmr.dto.uma.DittaUMAAziendaVO aziende[]=umaFacadeClient.getDitteUMAByIdAziendaRange(idAziende,true);
      if (aziende!=null)
      {
        request.setAttribute("aziende",aziende);
      }
    }
  }
%><jsp:forward page="<%=VIEW%>" />
<%!
  public void doSessionVar(HttpSession session, UmaFacadeClient umaFacadeClient)
  throws Exception
  {
  // GESTIONE DELLE VARIABILI DI SESSIONE !!!!!!!!!!!!!!!!!! DEVE ESSERE UGUALE
  // A QUANTO FATTO NELLA PAGINA DI INDEX
//------------------------------------------------------------------------------
  String elencoFormeGiurdiche = umaFacadeClient.getElencoFormeGiuridicheNonSottoposteGestioneFascicolo();
  SolmrLogger.debug(this, "elencoFormeGiurdiche: "+elencoFormeGiurdiche);

  final String SEPARATORE = ",";
  StringTokenizer st = new StringTokenizer(elencoFormeGiurdiche, SEPARATORE);
  String strIdFormaGiuridica = null;
  Long lngIdFormaGiuridica = null;
  HashMap formeGiuridiche = new HashMap();

  SolmrLogger.debug(this, "\n\n\n************************");
  SolmrLogger.debug(this, "Forme Giuridiche:");
  SolmrLogger.debug(this, "************************\n\n\n");
  while (st.hasMoreTokens())
  {
    strIdFormaGiuridica = st.nextToken().trim();
    SolmrLogger.debug(this, "strIdFormaGiuridica: "+strIdFormaGiuridica);

    formeGiuridiche.put(strIdFormaGiuridica, strIdFormaGiuridica);
  }
  session.setAttribute("formeGiuridicheNonSottoposteAFascicolo", formeGiuridiche);

  Date dataInizioGestioneFascicolo = umaFacadeClient.getDataInizioGestioneFascicolo();
  session.setAttribute("dataInizioGestioneFascicolo", dataInizioGestioneFascicolo);
  HashMap parametriUM=new HashMap();
  String umsu= umaFacadeClient.getParametro(SolmrConstants.PARAMETRO_GESTIONE_SUPERFICI);
  String umco= umaFacadeClient.getParametro(SolmrConstants.PARAMETRO_GESTIONE_COLTURE);
  String umal= umaFacadeClient.getParametro(SolmrConstants.PARAMETRO_GESTIONE_ALLEVAMENTI);
  String umse= umaFacadeClient.getParametro(SolmrConstants.PARAMETRO_GESTIONE_SERRE);
  String umim= umaFacadeClient.getParametro(SolmrConstants.PARAMETRO_IMPORTA_DATI);

  parametriUM.put(SolmrConstants.PARAMETRO_GESTIONE_SUPERFICI,DateUtils.parseDate(umsu.trim()));
  parametriUM.put(SolmrConstants.PARAMETRO_GESTIONE_COLTURE, DateUtils.parseDate(umco.trim()) );
  parametriUM.put(SolmrConstants.PARAMETRO_GESTIONE_ALLEVAMENTI, DateUtils.parseDate(umal.trim()));
  parametriUM.put(SolmrConstants.PARAMETRO_GESTIONE_SERRE,DateUtils.parseDate(umse.trim()));
  parametriUM.put(SolmrConstants.PARAMETRO_IMPORTA_DATI, DateUtils.parseDate(umim.trim()) );
  session.setAttribute("parametriUM",parametriUM);
  
  /* RIMANENZA MINIMA  BEGIN. */
  readAndSetParameter(SolmrConstants.PARAMETRO_RIMANENZA_MINIMA_PT,umaFacadeClient, session);

  readAndSetParameter(SolmrConstants.PARAMETRO_RIMANENZA_MINIMA_SERRE,umaFacadeClient, session);

  readAndSetParameter(SolmrConstants.PARAMETRO_DATA_ULTIMO_PRELIEVO_RIMANENZA_MINIMA,umaFacadeClient, session);
/* RIMANENZA MINIMA  END. */


//------------------------------------------------------------------------------
  String formeGiuridicheValidPA = umaFacadeClient.getParametro(SolmrConstants.PARAMETRO_VALIDAZIONE_PA_FORME_GIURIDICHE);
  SolmrLogger.debug(this, "formeGiuridicheValidPA: "+formeGiuridicheValidPA);

  st = new StringTokenizer(formeGiuridicheValidPA, SEPARATORE);
  String strFormaGiuridicaValidDomPA = null;
  HashMap formeGiuridicheValidazionePA = new HashMap();

  SolmrLogger.debug(this, "\n\n\n**********************************");
  SolmrLogger.debug(this, "Elenco forme giuridiche validazione PA: ");
  SolmrLogger.debug(this, "**********************************\n\n\n");
  while (st.hasMoreTokens())
  {
    strFormaGiuridicaValidDomPA = st.nextToken().trim();
    SolmrLogger.debug(this, "strFormaGiuridicaValidDomPA: "+strFormaGiuridicaValidDomPA);
    formeGiuridicheValidazionePA.put(strFormaGiuridicaValidDomPA, strFormaGiuridicaValidDomPA);
  }
  SolmrLogger.debug(this, "formeGiuridicheValidazionePA: "+formeGiuridicheValidazionePA);
  session.setAttribute("formeGiuridicheValidazionePA", formeGiuridicheValidazionePA);


//------------------------------------------------------------------------------
  String provValidDomInt = umaFacadeClient.getParametro(SolmrConstants.PARAMETRO_VALIDAZIONE_INTERMEDIARIO_PROVINCIE);
  SolmrLogger.debug(this, "provValidDomInt: "+provValidDomInt);

  st = new StringTokenizer(provValidDomInt, SEPARATORE);
  String strProvValidDomInt = null;
  HashMap provincieValidazioneIntermediario = new HashMap();

  SolmrLogger.debug(this, "\n\n\n************************");
  SolmrLogger.debug(this, "Elenco provincie: ");
  SolmrLogger.debug(this, "************************\n\n\n");
  while (st.hasMoreTokens())
  {
    strProvValidDomInt = st.nextToken().trim();
    SolmrLogger.debug(this, "strProvValidDomInt: "+strProvValidDomInt);
    provincieValidazioneIntermediario.put(strProvValidDomInt, strProvValidDomInt);
  }
  SolmrLogger.debug(this, "provincieValidazioneIntermediario: "+provincieValidazioneIntermediario);
  session.setAttribute("provincieValidazioneIntermediario", provincieValidazioneIntermediario);
  //UMA2 - End
  }

private void readAndSetParameter(String paramName, UmaFacadeClient client, HttpSession sessione) throws it.csi.solmr.exception.SolmrException{
  String value=client.getParametro(paramName);
  SolmrLogger.debug(this, " - paramName ="+paramName);
  SolmrLogger.debug(this, " - value ="+value);
  if (value==null)
  {
    SolmrLogger.error(this,"ERRORE: PARAMETRO ["+paramName+"] NON VALORIZZATO!");
  }
  else
  {
    sessione.setAttribute(paramName,value);
  }
}

%>