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


<%
  //Flag per disabilitare controllo autorizzazione abilitazioni IRIDE AssegnazioneBaseCU.hasCompetenzaDato()
  final String DISABILITA_INTERMEDIARIO = "";
  request.setAttribute("noCheckIntermediario", DISABILITA_INTERMEDIARIO);

  String iridePageName = "verificaAssegnazioneValidataCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  SolmrLogger.debug(this, "BEGIN verificaAssegnazioneValidataCtrl");
  
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  ValidationErrors errors = new ValidationErrors();
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  String layoutViewUrl = "/domass/view/verificaAssegnazioneValidataView.jsp";
  String annullaDomUrl = "/domass/ctrl/annulloAssegnazioneCtrl.jsp";
  String emissioneUrl = "/domass/ctrl/emissioneBuonoCtrl.jsp";

  DomandaAssegnazione da = umaFacadeClient.findDomandaAssegnazioneCorrente(idDittaUma);
  Long idDomAss = da.getIdDomandaAssegnazione();
    
  // Nick 14-01-2009 - Nuova gestione emissione buoni.  
  int iQContoProprioGasolio = umaFacadeClient.selectContoProprioGasolio(idDomAss);
  int iQContoProprioBenzina = umaFacadeClient.selectContoProprioBenzina(idDomAss);
  int iQContoTerziGasolio = umaFacadeClient.selectContoTerziGasolio(idDomAss);
  int iQContoTerziBenzina = umaFacadeClient.selectContoTerziBenzina(idDomAss);
  int iQSerraGasolio = umaFacadeClient.selectRiscSerraGasolio(idDomAss);
  int iQSerraBenzina = umaFacadeClient.selectRiscSerraBenz(idDomAss);
  
  String strCtrlBuonoInserito = "FALSE";
  if (iQContoProprioGasolio+iQContoProprioBenzina+iQContoTerziGasolio+iQContoTerziBenzina+iQSerraGasolio+iQSerraBenzina > 0)
  	  strCtrlBuonoInserito = "TRUE";
  	  
  request.setAttribute("ctrl_buono_inserito", strCtrlBuonoInserito);  	    
  //

  if(request.getParameter("annullaDom.x") != null){
    SolmrLogger.debug(this,"\\\\\\\\\\annullaDom");

    try
    {
      SolmrLogger.debug(this,"\n\n\n\n\n\n\n\n\nInserimento !!!!!!!\n\n\n\n\n\n\n\n");
      umaFacadeClient.isDittaUmaBloccata(idDittaUma);
      umaFacadeClient.isDittaUmaCessata(idDittaUma);
      umaFacadeClient.existsBuonoPrelievoIdDomAss(idDomAss);
      umaFacadeClient.esisteAssSupplNonAnnullata(idDomAss);
     }
     catch(Exception e)
     {
       SolmrLogger.debug(this,"Condizioni non valide per annullare la domanda");
       findData(request,umaFacadeClient,idDittaUma,layoutViewUrl);
       this.throwValidation(e.getMessage(),layoutViewUrl);
     }

     SolmrLogger.debug(this,"annullaDomUrl: "+annullaDomUrl);
    %>
      <jsp:forward page ="<%=annullaDomUrl%>" />
    <%
  }

  if(request.getParameter("emissione.x") != null){
    SolmrLogger.debug(this,"\\\\\\\\\\Emissione");
    SolmrLogger.debug(this,"emissioneUrl: "+emissioneUrl);
    if (request.getAttribute("fromEmissione")==null){
      %>
        <jsp:forward page ="<%=emissioneUrl%>" />
      <%
    }
  }

  SolmrLogger.debug(this,"\\\\\\\\\\Visualizzazione Foglio riga assegnato");
  SolmrLogger.debug(this,"layoutViewUrl: "+layoutViewUrl);

  findData(request,umaFacadeClient,idDittaUma,layoutViewUrl);

  SolmrLogger.debug(this,"***layoutViewUrl: "+layoutViewUrl);
  %>
    <jsp:forward page ="<%=layoutViewUrl%>" />
  <%

  SolmrLogger.debug(this,"verificaAssegnazioneValidataCtrl.jsp -  FINE PAGINA");
%>
<%!
  private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException("Errore: eccezione="+msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }
  private void findData(HttpServletRequest request,UmaFacadeClient umaClient,Long idDittaUma,String validateUrl)
      throws ValidationException
  {
    try
    {
      SolmrLogger.debug(this,"\n\n\n\n\n\n\n\n\nidDittaUma="+idDittaUma+" \n\n\n\n\n\n\n\n\n....");
      Calendar cal = new GregorianCalendar();
      Long year = new Long( cal.get(Calendar.YEAR) );

      FogliRigaVO fogliRigaVO = umaClient.getFoglioRigaByIdDomAss(idDittaUma, year);

      request.setAttribute("fogliRigaVO",fogliRigaVO);
    }
    catch(Exception e)
    {
      throwValidation(e.getMessage(),validateUrl);
    }
  }
%>
