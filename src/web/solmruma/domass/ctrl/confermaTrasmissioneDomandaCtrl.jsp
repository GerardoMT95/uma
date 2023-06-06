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
  private static final String PREV_CTRL="/domass/ctrl/verificaAssegnazioneSalvataView.jsp";
  private static final String PREV_CTRL_PROV_REG="/domass/ctrl/verificaAssegnazioneSalvataBOView.jsp";
  private static final String VIEW="/domass/view/confermaTrasmissioneDomandaView.jsp";
  private static final String NEXT_PAGE="../layout/verificaAssegnazioneTrasmessa.htm";
  private static final String PREV_PAGE="../layout/verificaAssegnazioneSalvata.htm";
  private static final String PREV_PAGE_PROV_REG = "../layout/verificaAssegnazioneSalvataBO.htm";
  private static final Long IN_ATTESA_VALIDAZIONE_PA = new Long(20);
%>
<%

  String iridePageName = "confermaTrasmissioneDomandaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "   BEGIN confermaTrasmissioneDomandaCtrl");
  
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  if (request.getParameter("conferma.x")!=null)
  {
	Long idDomandaassegnazione = new Long(request.getParameter("idDomandaassegnazione"));
    try
    {
      SolmrLogger.debug(this," ---------- TRASMISSIONE ------------");
      DomandaAssegnazione da=new DomandaAssegnazione();
      
      UmaFacadeClient client = new UmaFacadeClient();
      da.setIdDomandaAssegnazione(idDomandaassegnazione);
      da.setIdStatoDomanda(IN_ATTESA_VALIDAZIONE_PA);
      
      SolmrLogger.debug(this," -- idDomandaAssegnazione ="+da.getIdDomandaAssegnazione());
      Long idAssCarb=client.getIdAssegnazCarbByDomAss(da.getIdDomandaAssegnazione());
      SolmrLogger.debug(this," -- idAssegnazioneCarburante ="+idAssCarb);
      
      SolmrLogger.debug(this," -- chiamata a trasmettiAssegnazioneBase");
      client.trasmettiAssegnazioneBase(da.getIdDomandaAssegnazione(), idAssCarb, idDittaUma, ruoloUtenza);
    }
    catch(Exception e)
    {
     SolmrLogger.error(this, "--- Exception in confermaTrasmissioneDomandaCtrl ="+e.getMessage());
     // Controllare se il ruolo dell'utente è Persona fisica o intermediario
  	 if(ruoloUtenza.isUtenteIntermediario()){
      throwValidation(e.getMessage(),PREV_CTRL);
     }
  	 else{
  	  throwValidation(e.getMessage(),PREV_CTRL_PROV_REG);	 
  	 }    
    }
    response.sendRedirect(NEXT_PAGE+"?idDomandaassegnazione="+idDomandaassegnazione);
    return;
  } 
  if (request.getParameter("annulla.x")!=null)
  {
	// Controllare se il ruolo dell'utente è Persona fisica o intermediario (se persona fisica deve tornare nel ramo usato per il regionale e provinciale (xxxBO))
	if(ruoloUtenza.isUtenteIntermediario()){
		SolmrLogger.debug(this, "-- CASO Ruolo Intermediario");
    	response.sendRedirect(PREV_PAGE);
	}
	else{
		SolmrLogger.debug(this, "-- CASO Ruolo Persona fisica");
		response.sendRedirect(PREV_PAGE_PROV_REG);
	}
    return;
  }
%>
<jsp:forward page="<%=VIEW%>" />
<%!
  private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException(msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }
%>
