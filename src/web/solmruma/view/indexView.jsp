  <%@ page language="java"

      contentType="text/html"

      isErrorPage="true"

  %>

<%@ page import="java.util.*" %>

<%@ page import="it.csi.jsf.htmpl.*" %>

<%@ page import="it.csi.solmr.util.*" %>

<%@ page import="java.rmi.RemoteException" %>

<%@ page import="java.sql.Timestamp" %>

<%@ page import="it.csi.solmr.client.uma.UmaFacadeClient" %>
<%@ page import="it.csi.solmr.etc.SolmrConstants" %>



<jsp:useBean id="ruoloUtenza" scope="session" class="it.csi.solmr.dto.profile.RuoloUtenza"/>



<%

  java.io.InputStream layout = application.getResourceAsStream("/layout/index.htm");

  Htmpl htmpl = new Htmpl(layout);
%><%@ include file = "/include/menu.inc" %><%
  it.csi.solmr.presentation.security.Autorizzazione aut=
  (it.csi.solmr.presentation.security.Autorizzazione)
  it.csi.solmr.util.IrideFileParser.elencoSecurity.get("NUOVA_DITTA");
  htmpl.newBlock("blkNO_NUOVA_DITTA");
  //UMA2 - Begin
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();


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
%>

<%= htmpl.text() %><%!
private void readAndSetParameter(String paramName, UmaFacadeClient client, HttpSession sessione)
throws it.csi.solmr.exception.SolmrException
{
  String value=client.getParametro(paramName);
  if (value==null)
  {
    SolmrLogger.error(this,"ERRORE: PARAMETRO ["+paramName+"] NON VALORIZZATO!");
  }
  else
  {
    sessione.setAttribute(paramName,value);
  }
} %>