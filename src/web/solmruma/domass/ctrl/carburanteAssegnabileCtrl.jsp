<%@page import="it.csi.solmr.etc.profile.AgriConstants"%>
<%@ page language="java" contentType="text/html"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.etc.*" %>

<jsp:useBean id="fdaVO" scope="page"
	class="it.csi.solmr.dto.uma.FrmDettaglioAssegnazioneVO">
	<jsp:setProperty name="fdaVO" property="*" />
</jsp:useBean>



<%!public static final String VIEW_URL = "/domass/view/carburanteAssegnabileView.jsp";
  public static final String ANNULLA_URL = "/domass/ctrl/annulloAssegnazioneCtrl.jsp";
  public static final String confermaEliminaUrl = "/domass/ctrl/confermaEliminaDomAssCtrl.jsp";
  public static final String dettaglioUrl = "/domass/ctrl/dettaglioDomandaCtrl.jsp";%>

<%
  String iridePageName = "carburanteAssegnabileCtrl.jsp";
%>
  <%@include file="/include/autorizzazione.inc"%>
<%
  
  SolmrLogger.debug(this,"   BEGIN carburanteAssegnabileCtrl");
  
  UmaFacadeClient umaClient = new UmaFacadeClient();
  String pageFrom = (String) request.getParameter("pageFrom");
  SolmrLogger.debug(this,"-- pageFrom "+pageFrom);
  if (request.getParameter("indietro") != null)
  {
	  if(pageFrom.equals("../layout/verificaAssegnazioneSalvataBO.htm")){
		  pageFrom = "/domass/layout/verificaAssegnazioneSalvataBO.htm";
	  }
	  response.sendRedirect(pageFrom);
	  return;
  }
  
  request.setAttribute("pageFrom", pageFrom);
  Long idDomAss = null;

  if (request.getParameter("idDomAss") != null)
  {
    idDomAss = new Long(request.getParameter("idDomAss"));
    SolmrLogger.debug(this," -- idDomAss ="+idDomAss);
  }

  DomandaAssegnazione da = null;
  String fromVerificaAssegnazione  = request.getParameter("fromVerificaAssegnazione");
  if (request.getParameter("fromVerificaAssegnazione") == null)
  {

    SolmrLogger.debug(this," ----- Richiesta dati dettaglio carburante");
    //Long idDomAss=new Long(request.getParameter("idDomAss"));
    da = umaClient.findDomAssByPrimaryKey(idDomAss);
    
    //recupero i dati dell'eccedenza
    int annoDomanda = DateUtils.extractYearFromDate(da.getDataRiferimento());
    java.util.Vector risEcc=umaClient.getTotaliConsumo(new Long(da.getIdDitta()), ""+(annoDomanda-1));
    if (risEcc!=null && risEcc.size()>0)
    {
      LavContoTerziVO elem = (LavContoTerziVO) risEcc.get(0);
      if (elem!=null)
        request.setAttribute("eccedenza", elem.getEccedenzaStr());
    }
    
    
    SolmrLogger.debug(this,"da.getDataRiferimento()=" + da.getDataRiferimento());
    if (DateUtils.extractYearFromDate(da.getDataRiferimento()) < 2004)
    {
      String forwardPage = null;
      if ("../layout/assegnazioni.htm".equalsIgnoreCase(pageFrom))
      {
        forwardPage = "/domass/ctrl/assegnazioniCtrl.jsp";
      }
      else
      {
        if ("../layout/dettaglioDomanda.htm".equalsIgnoreCase(pageFrom))
        {
          forwardPage = "/domass/ctrl/dettaglioDomandaCtrl.jsp";
        }
      }
      throwValidation(
          "Il dettaglio del calcolo è applicabile solamente alle domande di assegnazione posteriori al 2003",
          forwardPage);
    }
    
    request.setAttribute("domandaAssegnazione", da);
    
    if ((da.getIdStatoDomanda().intValue() == SolmrConstants.ID_STATO_DOMANDA_ACCONTO_IN_BOZZA)
      || (da.getIdStatoDomanda().intValue() == SolmrConstants.ID_STATO_DOMANDA_ACCONTO_VALIDATO))
    {
      String forwardPage = null;
      if ("../layout/assegnazioni.htm".equalsIgnoreCase(pageFrom))
      {
        forwardPage = "/domass/ctrl/assegnazioniCtrl.jsp";
      }
      else
      {
        if ("../layout/dettaglioDomanda.htm".equalsIgnoreCase(pageFrom))
        {
          forwardPage = "/domass/ctrl/dettaglioDomandaCtrl.jsp";
        }
      }
      throwValidation(
          "Operazione non permessa: per la tipologia di assegnazione selezionata non è presente il dettaglio del calcolo",
          forwardPage);
    }
        
    
    /* -- Voce di Menu 'Dettaglio calcolo' o 'Dettaglio' richiamata dopo aver selezionato :
       - Assegnazione base 
       - Supplemento       
       Il pl PCK_SMRUMA_ASSEGNAZ_CARB.DETTAGLIO_ASSEGNAZIONE_CARB() avrà parametri di input diversi
     */ 
    String tipoAssegnazione = "";
    Long numeroSupplemento = null;
    // Se questo valore è nullo è perchè non stiamo arrivando dal 'Supplemento'
    String idAssegnazioneCarburanteSel =  (String)request.getParameter("idAssCarb"); // radio button selezionato dall'elenco dei Supplementi    
    SolmrLogger.debug(this, "--- idAssegnazioneCarburanteSel ="+idAssegnazioneCarburanteSel);
    if(idAssegnazioneCarburanteSel != null && !idAssegnazioneCarburanteSel.equals("")){
      // Certo il numero_supplemento su db_assegnazione_carburante, dato l'id_assegnazione_carburante selezionato
      numeroSupplemento = umaClient.getNumSupplementoByIdAssCarburante(new Long(idAssegnazioneCarburanteSel));
      request.setAttribute("numeroSupplemento",numeroSupplemento);
      // memorizzo il valore per le popup relative ai pulsanti "dettaglio" delle voci presenti sulla pagina (A), B), ecc ..)
      request.setAttribute("numSupplemento", numeroSupplemento);
      SolmrLogger.debug(this, "--- numeroSupplemento selezionato dall'elenco ="+numeroSupplemento);
      tipoAssegnazione = SolmrConstants.ID_TIPO_ASSEGNAZIONE_SUPPLEMENTARE;      
    }
    else{
      tipoAssegnazione  = SolmrConstants.TIPO_ASSEGNAZIONE_BASE_SALDO;
    }         
            
    SolmrLogger.debug(this, " --- chiamata a PCK_SMRUMA_ASSEGNAZ_CARB.DETTAGLIO_ASSEGNAZIONE_CARB()");
    fdaVO = umaClient.dettaglioCalcoloPL(idDomAss,tipoAssegnazione,numeroSupplemento);
    
  }
  
  if(da == null)
  {
    da = umaClient.findDomAssByPrimaryKey(idDomAss);
    request.setAttribute("domandaAssegnazione", da);
  }

  // Recupero l'anno dal quale inizia il caricamento delle lavorazioni conto proprio
  // -> utilizzato per capire quale pop up di dettaglio visualizzare per le voci A), F), G)
  String valoreUMLC = umaClient.getParametro(SolmrConstants.PARAMETRO_ANNO_INIZIO_CARICAM_LAVORAZ_CP);
  SolmrLogger.debug(this, " ---- valoreUMLC ="+valoreUMLC);
  if(valoreUMLC != null)
    request.setAttribute("annoInizioCaricamentoLavCP", new Integer(valoreUMLC));
  
  request.setAttribute("fdaVO", fdaVO);
  SolmrLogger.debug(this,"\n\n\n\n-------------------------------");
  SolmrLogger.debug(this,"Blocco If");
  try
  {
    SolmrLogger.debug(this,"request.getParameter(\"elimina.x\"): "
        + request.getParameter("elimina.x"));
    if (request.getParameter("elimina.x") != null)
    {
      SolmrLogger.debug(this,"///////Elimina");
      %>
        <jsp:forward page="<%=confermaEliminaUrl%>">
	        <jsp:param name="annullaBuoni" value="carburanteAssegnabile" />
        </jsp:forward>
      <%
    }
    else
    {
      if (request.getParameter("dettaglio.x") != null)
      {
        SolmrLogger.debug(this,"///////Dettaglio : caso dettaglioDomandaCtrl");
        %>
          <jsp:forward page="<%=dettaglioUrl%>" />
        <%
      }
      
      if (request.getParameter("annulla.x") != null)
      {
        //Controllo esistenza buoni non restituiti - Begin
        try
        {
          %>
            <jsp:forward page="<%=ANNULLA_URL%>" />
          <%
          return;
        }
        catch (Exception e)
        {
          SolmrLogger.debug(this,"Condizioni non valide per annullare la domanda");
          this.throwValidation(e.getMessage(), VIEW_URL);
        }
       //Controllo esistenza buoni non restituiti - End
      }
    }
%>
<jsp:forward page="<%=VIEW_URL%>" />

<%
  }
  catch (ValidationException e)
  {
    throw e;
  }
  catch (Exception e)
  {
    setError(request, "Si è verificato un errore di sistema");
    %>
      <jsp:forward page="<%=VIEW_URL%>" />
    <%
  }
%>

<%!private void setError(HttpServletRequest request, String msg)
  {
    SolmrLogger.debug(this, "\n\n\n\n\n\n\n\n\n\n\nmsg=" + msg
        + "\n\n\n\n\n\n\n\n");
    ValidationErrors errors = new ValidationErrors();
    errors.add("error", new ValidationError(msg));
    request.setAttribute("errors", errors);
  }

  private void throwValidation(String msg, String validateUrl)
      throws ValidationException
  {
    ValidationException valEx = new ValidationException("Errore: eccezione="
        + msg, validateUrl);
    valEx.addMessage(msg, "exception");
    throw valEx;
  }%>