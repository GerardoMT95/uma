<%@ page language="java"
         contentType="text/html"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.etc.SolmrConstants" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%!
  public static final String VIEW_URL="/domass/view/dettaglioAssegnazioniSupplementareView.jsp";
  public static final String CONFERMA_ANNULLA_URL = "../layout/confermaAnnullaAssCarb.htm";
  public static final String CONFERMA_ELIMINA_URL = "../layout/confermaEliminaAssCarb.htm";
%>
<%

  String iridePageName = "dettaglioAssegnazioniSupplementareCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "   BEGIN dettaglioAssegnazioniSupplementareCtrl");
  
Long idDittaUma = null;
Long idDomAss = null;
Long idAssCarb = null;

UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

try
{
  if (request.getParameter("idDomAss")!=null)
  {
    SolmrLogger.debug(this,"request.getParameter(\"idDomAss\"): "+request.getParameter("idDomAss"));
    idDomAss = new Long(request.getParameter("idDomAss"));

    SolmrLogger.debug(this,"\n\n\n\n/+/+/+/+/+/+/+/+/+/+/+/");
    session.removeAttribute("idDomAss");
  }
  else if(session.getAttribute("idDomAss")!=null)
  {
    SolmrLogger.debug(this,"session.getAttribute(\"idDomAss\"): "+session.getAttribute("idDomAss"));
    idDomAss = (Long)session.getAttribute("idDomAss");
    request.setAttribute("idDomAss", idDomAss.toString());
  }
  if(request.getParameter("idAssCarb") != null)
  {
    idAssCarb = new Long(request.getParameter("idAssCarb"));
  }
  /*else if(session.getAttribute("idAssCarb")!=null)
  {
    //idAssCarb = new Long((String)session.getAttribute("idAssCarb"));
    idAssCarb = (Long)session.getAttribute("idAssCarb");
    session.removeAttribute("idAssCarb");
  }*/

  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
  idDittaUma = dittaVO.getIdDittaUMA();

  SolmrLogger.debug(this,"dettaglioAssegnazioniSupplementareCtrl.jsp idDittaUma "+idDittaUma);
  SolmrLogger.debug(this,"dettaglioAssegnazioniSupplementareCtrl.jsp idAssCarb "+idAssCarb);
  SolmrLogger.debug(this,"dettaglioAssegnazioniSupplementareCtrl.jsp idDomAss "+idDomAss);

  if (request.getParameter("annulla")!=null)
  {
    SolmrLogger.debug(this,"dettaglioAssegnazioniSupplementareCtrl - ready for annulla - idAssCarb = "+session.getAttribute("idAssCarb"));
    session.setAttribute("idAssCarb", idAssCarb);
    session.setAttribute("idDomAss", idDomAss);

    //idAssCarb = umaFacadeClient.getIdAssCarbAnnoCorrenteByIdDittaUma(idDittaUma);
    AssegnazioneCarburanteVO assCarb = umaFacadeClient.getAssegnazioneCarburante(idAssCarb);
    Date dataAssegnazioneCarb = assCarb.getDataAssegnazione();
    SolmrLogger.debug(this,"\n\n\n\n/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-");
    SolmrLogger.debug(this,"dataAssegnazioneCarb: "+dataAssegnazioneCarb);

    Long idUltimaAssCarb = umaFacadeClient.getIdAssCarbAnnoCorrenteByIdDittaUma(idDittaUma);

    if(idUltimaAssCarb.longValue() != idAssCarb.longValue())
    {
      throw new SolmrException("L''assegnazione carburante selezionata non può essere annullata in quanto non è l''ultima per la domanda di assegnazione validata per l''anno in corso.");
    }
    if(assCarb.getDataValidazioneSupplDate() == null || assCarb.getAnnullato() != null)
    {
      throw new SolmrException("E'' possibile annullare soltanto un''assegnazione supplementare validata e non annullata.");
    }

    SolmrLogger.debug(this,"\n\n\n\n\n\n\n\n\nannullaDomAssSuppl !!!!!!!\n\n\n\n\n\n\n\n");
    iridePageName = "confermaAnnullaAssCarbCtrl.jsp";
    %><%@include file = "/include/autorizzazione.inc" %><%
/*    umaFacadeClient.isDittaUmaBloccata(idDittaUma);
    SolmrLogger.debug(this,"1Controlli");
    umaFacadeClient.isDittaUmaCessata(idDittaUma);*/
    SolmrLogger.debug(this,"2Controlli");
    umaFacadeClient.esisteBuonoPrelievoEmessiENonAnnullatoDopoDataRiferimento(idDomAss, dataAssegnazioneCarb);
    SolmrLogger.debug(this,"3Controlli");

    String pageFrom=null;
    if(request.getParameter("pageFrom")!=null)
    {
      SolmrLogger.debug(this,"if(request.getParameter(\"pageFrom\")!=null)");
      pageFrom=request.getParameter("pageFrom");
      session.setAttribute("pageFrom", pageFrom);
    }
    else{
      SolmrLogger.debug(this,"else(request.getParameter(\"pageFrom\")!=null)");
    }
    SolmrLogger.debug(this,"pageFrom: "+pageFrom);

    response.sendRedirect(CONFERMA_ANNULLA_URL);
    return;
  }


  if (request.getParameter("elimina")!=null)
  {
    SolmrLogger.debug(this,"dettaglioAssegnazioniSupplementareCtrl - ready for elimina - idAssCarb = "+session.getAttribute("idAssCarb"));

    Long idUltimaAssCarb = umaFacadeClient.getIdAssCarbAnnoCorrenteByIdDittaUma(idDittaUma);
    SolmrLogger.debug(this, "--- idUltimaAssCarb ="+idUltimaAssCarb);
    AssegnazioneCarburanteVO assCarb = umaFacadeClient.getAssegnazioneCarburante(idAssCarb);

    Long idDomandaAssegnazione = assCarb.getIdDomandaAssegnazione();

    iridePageName = "confermaEliminaAssCarbCtrl.jsp";
    %><%@include file = "/include/autorizzazione.inc" %><%

/*    umaFacadeClient.isDittaUmaBloccata(idDittaUma);
    umaFacadeClient.isDittaUmaCessata(idDittaUma);*/

    if(idUltimaAssCarb == null)
    {
      SolmrLogger.debug(this, "--- CASO idUltimaAssCarb == null");
      throw new SolmrException("Non esiste nessuna assegnazione di carburante per la domanda di assegnazione corrente.");
    }
    
    SolmrLogger.debug(this, "-- idAssCarb ="+idAssCarb);
    SolmrLogger.debug(this, "-- idUltimaAssCarb ="+idUltimaAssCarb);
    if(idUltimaAssCarb.longValue() != idAssCarb.longValue())
    {     
      SolmrLogger.debug(this, "--- CASO idUltimaAssCarb != idAssCarb");
      throw new SolmrException("L''assegnazione carburante selezionata non può essere eliminata in quanto non è l''ultima per la domanda di assegnazione corrente.");
    }
    
    SolmrLogger.debug(this, "-- dataValidazioneSupplDate ="+assCarb.getDataValidazioneSupplDate()); 
    if(assCarb.getDataValidazioneSupplDate() != null)
    {
      SolmrLogger.debug(this, "--- CASO dataValidazioneSupplDate valorizzata");
      throw new SolmrException("E'' possibile eliminare soltanto un''assegnazione in attesa di validazione.");
    }
    
    // Controllo che non siano presenti lavorazioni conto proprio inserite successivamente al supplemento in esame
    SolmrLogger.debug(this, "-- Controllo che non siano presenti lavorazioni conto proprio inserite successivamente al supplemento in esame");
    String annoDomandaAssegnazione = request.getParameter("annoDomandaAssegnazione");
    SolmrLogger.debug(this, "--  idDittaUma ="+idDittaUma);
    SolmrLogger.debug(this, "--  annoDomandaAssegnazione ="+annoDomandaAssegnazione);
    Long countLavCpSucc = umaFacadeClient.countLavCPSuccessiveSupplemento(idDittaUma, new Long(annoDomandaAssegnazione));
    SolmrLogger.debug(this, "--  countLavCpSucc ="+countLavCpSucc);
    if(countLavCpSucc != null && countLavCpSucc.longValue() >0){
      SolmrLogger.debug(this, "--- CASO Presenza lavorazioni conto proprio"); 
      throw new SolmrException("Sono presenti lavorazioni conto proprio inserite successivamente al supplemento in esame. Per eliminare il supplemento occorre prima eliminare tali lavorazioni.");
    }
    

    session.setAttribute("idAssCarb", idAssCarb);
    session.setAttribute("idDomAss", idDomAss);
    
    SolmrLogger.debug(this, "-- SONO STATI SUPERATI TUTTI I CONTROLLI per elimina assegnazione supplementare");
    response.sendRedirect(CONFERMA_ELIMINA_URL);
    return;
  }

  findData(idDomAss, idAssCarb, umaFacadeClient, ruoloUtenza, request);

}
catch(SolmrException e)
{
  SolmrLogger.debug(this,"e.toString()="+e.toString());
  //throw new ValidationException("Errore di sistema : "+e.toString());
  findData(idDomAss, idAssCarb, umaFacadeClient, ruoloUtenza, request);
  throwValidation(e.getMessage(), VIEW_URL);
}
catch(Exception e)
{
  throwValidation(e.getMessage(), VIEW_URL);
  SolmrLogger.debug(this,"e.toString()="+e.toString());
}
%>
<%!
  private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException("Errore: eccezione="+msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }
  
  private void findData(Long idDomAss, Long idAssCarb, UmaFacadeClient umaFacadeClient, RuoloUtenza ruoloUtenza, HttpServletRequest request) throws SolmrException{
    SolmrLogger.debug(this, "   BEGIN findData");
    
    //caricamento dettaglioAssegnazioniSupplementareView
    Vector assegnazioniCarburante=umaFacadeClient.getAssegnazioniCarburante(idDomAss,"S");
    Vector utentiIride=new Vector();
    int iSize=assegnazioniCarburante==null?0:assegnazioniCarburante.size();

    for(int i=0;i<iSize;i++)
    {
      AssegnazioneCarburanteVO assegnazioneCarburanteVO= ((AssegnazioneCarburanteAggrVO)assegnazioniCarburante.get(i)).getAssegnazioneCarburante();
      SolmrLogger.debug(this,"\n\n\n\n\n\n\ndettaglioAssegnazioneSupplementareCtrl:nassegnazioneCarburanteVO.getIdUtenteAgg()="+assegnazioneCarburanteVO.getIdUtenteAgg());
      UtenteIrideVO utenteIrideVO=umaFacadeClient.getUtenteIride(assegnazioneCarburanteVO.getIdUtenteAgg());
      utentiIride.add(utenteIrideVO);
      SolmrLogger.debug(this,"\n\n\nutenteIrideVO.getDenominazione()="+utenteIrideVO.getDenominazione());
    }
    request.setAttribute("utentiIride",utentiIride);
    request.setAttribute("assegnazioniCarburante",assegnazioniCarburante);

    request.setAttribute("idAssCarb",idAssCarb);
    request.setAttribute("idDomAss",idDomAss.toString());
    
    // Ricerco il valore su db_parametro, per avere la data da confrontare con la data_assegnazione (serve per il dettaglio calcolo : vecchio o nuovo layout)
    SolmrLogger.debug(this, "-- Ricerco il valore su db_parametro, per avere la data da confrontare con la data_assegnazione (serve per il dettaglio calcolo : vecchio o nuovo layout)");
    String dataInizioNuovoDettCalcAssSuppl = umaFacadeClient.getParametro(SolmrConstants.ID_PARAMETRO_DETTAGLIO_CALC_ASS_SUPPL_NEW);
    SolmrLogger.debug(this, "-- dataInizioNuovoDettCalcAssSuppl ="+dataInizioNuovoDettCalcAssSuppl);
    request.setAttribute("dataInizioNuovoDettCalcAssSuppl",dataInizioNuovoDettCalcAssSuppl);
    
    SolmrLogger.debug(this, "   END findData");
  }
%>
<jsp:forward page ="<%=VIEW_URL%>" />

