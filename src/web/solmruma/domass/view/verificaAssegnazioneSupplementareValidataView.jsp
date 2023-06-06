<%@ page language="java"
         contentType="text/html"
         isErrorPage="true"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%!
  private final static String PREV_PAGE="../layout/verificaAssegnazioneSupplementareValidata.htm";
  private final static String LAYOUT_URL="/domass/layout/verificaAssegnazioneSupplementareValidata.htm";
%>
<%
  SolmrLogger.debug(this,"\n\n\n - verificaAssegnazioneSupplementareValidataView.jsp -  INIZIO PAGINA");

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  SolmrLogger.debug(this,"LAYOUT_URL: "+LAYOUT_URL);

  Htmpl htmpl = HtmplFactory.getInstance(application)
              .getHtmpl(LAYOUT_URL);
// Il menu deve essere quello di assegnazione supplemento anche se la pagina è
// parte di un CU differente
  request.setAttribute("__autorizzazione",it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ASSEGNAZIONE_SUPPLEMENTO"));
%><%@include file = "/include/menu.inc" %><%
  String idAssCarb=null;

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  SolmrLogger.debug(this,"idDittaUma: "+idDittaUma);

  FogliRigaVO fogliRigaVO = (FogliRigaVO) request.getAttribute("fogliRigaVO");

  SolmrLogger.debug(this,"(String)session.getAttribute(\"pathToFollow\"): "+(String)session.getAttribute("pathToFollow"));

  Long idDomAss=null;
  Date dataValidazione;
  if ( fogliRigaVO.getIdDomAss()!=null ){
    idDomAss = fogliRigaVO.getIdDomAss();
    SolmrLogger.debug(this,"idDomAss: "+idDomAss);
  }

  Calendar cal = new GregorianCalendar();
  Long anno = new Long( cal.get(Calendar.YEAR) );

  //x EmissioneBuono.htm
  if (idDomAss != null) {
   htmpl.bset("idDomAss", idDomAss.toString());
  }
  //htmpl.set("idDomAss", ""+idDomAss);
  htmpl.set("anno", ""+anno);
  htmpl.set("idDittaUma",""+idDittaUma);

  Integer annoDiRiferimento = DateUtils.getCurrentYear();
  htmpl.set("annoDiRiferimento", ""+annoDiRiferimento);

  SolmrLogger.debug(this,"\n\n\n/-/-/-/-/-/-/-/-/-/-/idDomAss: "+idDomAss);

  if ( fogliRigaVO.getIdAssegnazioneCarburante() !=null ){
    idAssCarb = fogliRigaVO.getIdAssegnazioneCarburante();
    htmpl.set("idAssCarb", idAssCarb );
  }
  SolmrLogger.debug(this,"fogliRigaVO.getIdAssegnazioneCarburante(): "+fogliRigaVO.getIdAssegnazioneCarburante());

  if ( fogliRigaVO.getDataValidazione() !=null ){
    dataValidazione = fogliRigaVO.getDataValidazione();
    htmpl.set("dataValidazione", formatDate(fogliRigaVO.getDataValidazione()) );
  }
  SolmrLogger.debug(this,"fogliRigaVO.getDataValidazione(): "+fogliRigaVO.getDataValidazione());

  Long numeroFoglio;
  if ( fogliRigaVO.getNumeroFoglio()!=null ){
    SolmrLogger.debug(this,"fogliRigaVO.getNumeroFoglio!=null");
    //Mantiene i dati per la pagina verificaAssegnazioneSupplementareValidata.htm
    //   quando ritorno con Annulla da annulloAssegnazione.htm
    numeroFoglio = fogliRigaVO.getNumeroFoglio();
  }
  else{
    numeroFoglio = new Long("-1");
  }
  htmpl.set("numeroFoglio",""+numeroFoglio);
  SolmrLogger.debug(this,"numeroFoglio: "+numeroFoglio);


  Long numeroRiga;
  if ( fogliRigaVO.getNumeroRiga()!=null ){
    SolmrLogger.debug(this,"fogliRigaVO.getNumeroRiga!=null");
    //Mantiene i dati per la pagina verificaAssegnazioneSupplementareValidata.htm
    //   quando ritorno con Annulla da annulloAssegnazione.htm
    numeroRiga = fogliRigaVO.getNumeroRiga();
  }
  else{
    numeroRiga = new Long("-1");
  }
  htmpl.set("numeroRiga", ""+numeroRiga );
  SolmrLogger.debug(this,"numeroRiga: "+numeroRiga);

  String messFoglioCompletato=null;
  if ( fogliRigaVO.getMessNumFoglio()!=null ){
    SolmrLogger.debug(this,"fogliRigaVO.getMessNumFoglio()!=null");
    messFoglioCompletato = fogliRigaVO.getMessNumFoglio();
  }
  SolmrLogger.debug(this,"messFoglioCompletato: "+messFoglioCompletato);

  if( (numeroFoglio.longValue()!=-1) && (numeroRiga.longValue()!=-1) ){
    SolmrLogger.debug(this,"if(numeroFoglio.longValue()!=-1) && (numeroRiga.longValue()!=-1)");
    htmpl.newBlock("blk_foglioRigaAss");
    htmpl.set("blk_foglioRigaAss.numeroFoglio",""+numeroFoglio);
    htmpl.set("blk_foglioRigaAss.numeroRiga", ""+numeroRiga );

    SolmrLogger.debug(this,"messFoglioCompletato: "+messFoglioCompletato);
    htmpl.set("blk_foglioRigaAss.messFoglioCompletato", messFoglioCompletato );
  }else{
    SolmrLogger.debug(this,"else(numeroFoglio.longValue()!=-1) && (numeroRiga.longValue()!=-1)");
  }

  htmpl.set("pagePrev", LAYOUT_URL );
  
  // Nick 14-01-2009 - Nuova gestione emissione buoni.
  String strCtrlBuonoInserito = (String)request.getAttribute("ctrl_buono_inserito");
  
  if (strCtrlBuonoInserito.equals("TRUE")) {
  	  htmpl.set("blkMenuBuoni.messBuonoEmesso","Sono stati emessi correttamente i buoni di carburante associati alla domanda di assegnazione. Si ricorda di effettuare la stampa del modello 26.");
  }
  else {
  	  htmpl.set("blkMenuBuoni.messBuonoEmesso","Non sono stati emessi buoni prelievo, il quantitativo di carburante assegnato risulta nullo.");
  }

  ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");
  SolmrLogger.debug(this,"errors="+errors);
  HtmplUtil.setErrors(htmpl,errors,request);

  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
  out.print(htmpl.text());

  SolmrLogger.debug(this,"verificaAssegnazioneSupplementareValidataView.jsp -  FINE PAGINA");
%>
<%!
  private String formatDate(Date aDate)
    {
      if (aDate==null)
      {
        return null;
      }
      return DateUtils.formatDate(aDate);
  }
%>