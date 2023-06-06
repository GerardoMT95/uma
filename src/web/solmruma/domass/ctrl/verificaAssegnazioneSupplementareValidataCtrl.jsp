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


<jsp:useBean id="frmAssegnazioneSupplementareVO" scope="request"
 class="it.csi.solmr.dto.uma.FrmAssegnazioneSupplementareVO">
  <jsp:setProperty name="frmAssegnazioneSupplementareVO" property="*" />
</jsp:useBean>
<%

  String iridePageName = "verificaAssegnazioneSupplementareValidataCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  SolmrLogger.debug(this, "   BEGIN verificaAssegnazioneSupplementareValidataCtrl");
  
  if( session.getAttribute("frmAssegnazioneSupplementareVO")!=null ){
    session.removeAttribute("frmAssegnazioneSupplementareVO");
  }

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  ValidationErrors errors = new ValidationErrors();
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  String layoutViewUrl = "/domass/view/verificaAssegnazioneSupplementareValidataView.jsp";
  String annullaDomUrl = "/domass/ctrl/confermaAnnullaAssCarbCtrl.jsp";
  String emissioneUrl = "/domass/ctrl/emissioneBuonoCtrl.jsp";

  Long idDomAss=null;
  if ( request.getParameter("idDomAss") != null){
    SolmrLogger.debug(this,"request.getParameter(\"idDomAss\") != null");
    idDomAss = new Long( request.getParameter("idDomAss") );
  }
  else{
    SolmrLogger.debug(this,"request.getParameter(\"idDomAss\") == null");
    if ( request.getAttribute("idDomAss") != null){
      SolmrLogger.debug(this,"request.getAttribute(\"idDomAss\") != null");
      idDomAss = (Long) request.getAttribute("idDomAss");
    }
    else{
      SolmrLogger.debug(this,"request.getAttribute(\"idDomAss\") == null");
    }
  }
  SolmrLogger.debug(this,"idDomAss: " + idDomAss);
  
   // Nick 30-01-2009 - Nuova gestione emissione buoni - New 
   Long idAssCarb = null;
   AssegnazioneCarburanteVO assCarb = null;
   
   try {
	   idAssCarb = umaFacadeClient.getIdAssCarbAnnoCorrenteByIdDittaUma(idDittaUma);
	   assCarb = umaFacadeClient.getAssegnazioneCarburante(idAssCarb);
   }
   catch(Exception e) {
       findData(request,umaFacadeClient,idDittaUma,layoutViewUrl);
       this.throwValidation(e.getMessage(),layoutViewUrl);
   }
   //

  if(request.getParameter("annullaDom.x") != null)
  {
    SolmrLogger.debug(this,"\\\\\\\\\\annullaDom");

    try
    {
      // Nick 30-01-2009 - Nuova gestione emissione buoni - Old
      //Long idAssCarb = umaFacadeClient.getIdAssCarbAnnoCorrenteByIdDittaUma(idDittaUma);
      //AssegnazioneCarburanteVO assCarb = umaFacadeClient.getAssegnazioneCarburante(idAssCarb);
      //
      Date dataAssegnazioneCarb = assCarb.getDataAssegnazione();            

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
      umaFacadeClient.isDittaUmaBloccata(idDittaUma);
      umaFacadeClient.isDittaUmaCessata(idDittaUma);
      umaFacadeClient.esisteBuonoPrelievoEmessiENonAnnullatoDopoDataRiferimento(idDomAss, dataAssegnazioneCarb);
    }
    catch(Exception e)
    {
      SolmrLogger.error(this, "--- Exception in verificaAssegnazioneSupplementareValidataCtrl ="+e.getMessage());
      findData(request,umaFacadeClient,idDittaUma,layoutViewUrl);
      this.throwValidation(e.getMessage(),layoutViewUrl);
    }

     SolmrLogger.debug(this,"annullaDomUrl: "+annullaDomUrl);
    %>
      <jsp:forward page ="<%=annullaDomUrl%>" />
    <%
  }

  if(request.getParameter("emissione.x") != null)
  {
    SolmrLogger.debug(this,"\\\\\\\\\\Emissione");
    SolmrLogger.debug(this,"emissioneUrl: "+emissioneUrl);            
    
    if (request.getAttribute("fromEmissione")==null)
    {
      %>
        <jsp:forward page ="<%=emissioneUrl%>" />
      <%
    }
  }
  
  
  // Nick 30-01-2009 - Nuova gestione emissione buoni. 
  int iQContoProprioGasolio = umaFacadeClient.selectContoProprioGasolio(assCarb.getIdDomandaAssegnazione());
  int iQContoProprioBenzina = umaFacadeClient.selectContoProprioBenzina(assCarb.getIdDomandaAssegnazione());
  int iQContoTerziGasolio = umaFacadeClient.selectContoTerziGasolio(assCarb.getIdDomandaAssegnazione());
  int iQContoTerziBenzina = umaFacadeClient.selectContoTerziBenzina(assCarb.getIdDomandaAssegnazione());
  int iQSerraGasolio = umaFacadeClient.selectRiscSerraGasolio(assCarb.getIdDomandaAssegnazione());
  int iQSerraBenzina = umaFacadeClient.selectRiscSerraBenz(assCarb.getIdDomandaAssegnazione());

  String strCtrlBuonoInserito = "FALSE";
  if (iQContoProprioGasolio+iQContoProprioBenzina+iQContoTerziGasolio+iQContoTerziBenzina+iQSerraGasolio+iQSerraBenzina > 0)
	  strCtrlBuonoInserito = "TRUE";
	  
  request.setAttribute("ctrl_buono_inserito", strCtrlBuonoInserito);
  //
  

  SolmrLogger.debug(this,"\\\\\\\\\\Visualizzazione Foglio riga assegnato");
  SolmrLogger.debug(this,"layoutViewUrl: "+layoutViewUrl);

  findData(request,umaFacadeClient,idDittaUma,layoutViewUrl);
  request.setAttribute("errors", errors);

  SolmrLogger.debug(this,"***layoutViewUrl: "+layoutViewUrl);
  %>
    <jsp:forward page ="<%=layoutViewUrl%>" />
  <%

  SolmrLogger.debug(this,"verificaAssegnazioneSupplementareValidataCtrl.jsp -  FINE PAGINA");
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

      FogliRigaVO fogliRigaVO = umaClient.getLastFoglioRigaByIdDittaUma(idDittaUma, year);

      request.setAttribute("fogliRigaVO",fogliRigaVO);
    }
    catch(Exception e)
    {
      throwValidation(e.getMessage(),validateUrl);
    }
  }
%>
