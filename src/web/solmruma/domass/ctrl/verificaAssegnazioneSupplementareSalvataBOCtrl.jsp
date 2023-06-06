<%@ page language="java"
         contentType="text/html"
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
<%@ page import="java.io.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<jsp:useBean id="frmAssegnazioneSupplementareVO" scope="request"
 class="it.csi.solmr.dto.uma.FrmAssegnazioneSupplementareVO">
  <jsp:setProperty name="frmAssegnazioneSupplementareVO" property="*" />
</jsp:useBean>

<%!
  private static final String VIEW_URL="/domass/view/verificaAssegnazioneSupplementareSalvataBOView.jsp";
  private static final String PAGINA_ANNULLAMENTO="";
  private static final String PAGINA_RIFIUTO="../ctrl/rifiutoAssegnazioneSupplementareCtrl.jsp";
  private static final String CONFERMA_VALIDA="/domass/view/verificaAssegnazioneSupplementareSalvataBOView.jsp";
  private static final String PAGINA_VALIDAZIONE="/domass/ctrl/confermaValidazioneAssegnazioneSupplCtrl.jsp";
  private static final String PAGE_PREV="../layout/verificaAssegnazioneSupplementareBO.htm";
%>

<%
  String iridePageName = "verificaAssegnazioneSupplementareSalvataBOCtrl.jsp";
  %>
    <%@include file = "/include/autorizzazione.inc" %>
  <%
  
  SolmrLogger.debug(this, "   BEGIN verificaAssegnazioneSupplementareSalvataBOCtrl");
  
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");  
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();  

  it.csi.solmr.client.uma.UmaFacadeClient client = new it.csi.solmr.client.uma.UmaFacadeClient();
  
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  //SolmrLogger.debug(this,"valida="+request.getParameter("valida"));
  SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getDescTipiSupplemento="+frmAssegnazioneSupplementareVO.getDescTipiSupplemento());

  if (request.getParameter("valida.x")!=null)
  {
    SolmrLogger.debug(this," -- Caso VALIDA");
    try
    {
      SolmrLogger.debug(this," --- numSupplemento per la validazione ="+frmAssegnazioneSupplementareVO.getNumeroSupplemento());
      
      ValidationErrors errors = new ValidationErrors();
      SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getExtIdIntermediarioLong(): "+frmAssegnazioneSupplementareVO.getExtIdIntermediarioLong());
      if( frmAssegnazioneSupplementareVO.getExtIdIntermediarioLong().longValue()!=0 ) 
      {
        errors = frmAssegnazioneSupplementareVO.validateValida(errors);
      }
      SolmrLogger.debug(this,"errors: "+errors);
      /**
       * 27-10-2004
       * Aggiunto controllo sulla data.
       * La data ricevuta documenti non può essere inferiore alla data di assegnazione
       */
      if(errors == null)
      {
        errors = new ValidationErrors();
      }

      Date dateRicevutaDocumenti = null;
      try
      {
        dateRicevutaDocumenti = frmAssegnazioneSupplementareVO.getDataConsegnaDocDate();
      }
      catch (Exception ex)
      {
      }

      if(errors.get("dataConsegnaDoc")==null && Validator.isNotEmpty(frmAssegnazioneSupplementareVO.getExtIdIntermediario())
         && dateRicevutaDocumenti != null)
      {
        Long idAssCarb = client.getIdAssCarbAnnoCorrenteByIdDittaUma(idDittaUma);
        AssegnazioneCarburanteVO assCarbVO = client.getAssegnazioneCarburante(idAssCarb);
        //System.err.println("assCarbVO.getDataAssegnazione() "+assCarbVO.getDataAssegnazione());
        //System.err.println("dateRicevutaDocumenti "+dateRicevutaDocumenti);
        Date dataTmp = DateUtils.parseDate(DateUtils.formatDate(assCarbVO.getDataAssegnazione()));

        if(dateRicevutaDocumenti.compareTo(dataTmp) < 0)
        {
          errors.add("dataConsegnaDoc",new ValidationError("La data ricezione documenti non può essere precedente alla data di trasmissione"));
        }
      }
      /**
       * FINE 27-10-2004
       */


      if ( errors!=null && errors.size()!=0 )
      {
        request.setAttribute("errors", errors);
        %><jsp:forward page="<%=VIEW_URL%>" /><%
      }

      SolmrLogger.debug(this,"VALIDAZIONE");
      %><jsp:forward page="<%=PAGINA_VALIDAZIONE%>" /><%
      SolmrLogger.debug(this,"FINE VALIDAZIONE");
      return;
    }
    catch(Exception e)
    {
      SolmrLogger.error(this," -- Exception in verificaAssegnazioneSupplementareSalvataBOCtrl ="+e.getMessage());
      throwValidation(e.getMessage(),VIEW_URL);
    }
  }// fine caso VALIDA
  
  // Caso RIFIUTA
  if (request.getParameter("rifiuta.x")!=null){
	  SolmrLogger.debug(this, "-- CASO RIFUITA");
	  
	  Long idAssegnazioneCarburante = client.getIdAssCarbAnnoCorrenteByIdDittaUma(idDittaUma);
	  frmAssegnazioneSupplementareVO.setIdAssCarbLong(idAssegnazioneCarburante);
	  
	  try{
	      %><jsp:forward page ="<%=PAGINA_RIFIUTO%>" /><%
	      SolmrLogger.debug(this,"FINE RIFIUTA");
	      return;
	    }
	    catch(Exception e){
	      throwValidation(e.getMessage(),VIEW_URL);
	    }
  }
  // fine caso RIFIUTA

  if (request.getParameter("indietro.x")!=null)
  {
    SolmrLogger.debug(this, "--- Caso INDIETRO");
    try
    {
      SolmrLogger.debug(this,"INDIETRO = "+PAGE_PREV);
      response.sendRedirect(PAGE_PREV);
     
     // SolmrLogger.debug(this,"FINE INDIETRO");
      return;
    }
    catch(Exception e)
    {
      SolmrLogger.error(this," -- Exception in verificaAssegnazioneSupplementareSalvataBOCtrl ="+e.getMessage());
      throwValidation(e.getMessage(),VIEW_URL);
    }
  }// fine caso INDIETRO



  frmAssegnazioneSupplementareVO.makeTotals();
  if (request.getParameter("validaDomAss")!=null)
  {
    SolmrLogger.debug(this, "-- Caso validaDomAss");
    ValidationErrors errors=null;
    SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getExtIdIntermediario()="+frmAssegnazioneSupplementareVO.getExtIdIntermediario());

    Long tipiSupplemento = frmAssegnazioneSupplementareVO.getTipiSupplementoLong();
    String descTipiSupplemento = frmAssegnazioneSupplementareVO.getDescTipiSupplemento();
    SolmrLogger.debug(this,"descTipiSupplemento: "+descTipiSupplemento);
    SolmrLogger.debug(this,"tipiSupplemento: "+tipiSupplemento);
    if (errors==null || errors.size()==0)
    {
      try
      {
        SolmrLogger.debug(this,"VALIDAZIONE");
        %><jsp:forward page="<%=VIEW_URL%>" /><%
        return;
      }
      catch(Exception e)
      {
        throwValidation(e.getMessage(),VIEW_URL);
      }
    }
    else
    {
      request.setAttribute("errors",errors);
    }
  }// fine CASO validaDomAss
  
  
  // ARRIVA QUI SE STO VISUALIZZANDO LA PAGINA PER LA PRIMA VOLTA
  try
  {
    // PROVA ALE    
    Long numSupplemento = null;
    numSupplemento = frmAssegnazioneSupplementareVO.getNumeroSupplemento();
    SolmrLogger.debug(this, " -- numSupplemento nel VO ="+numSupplemento);
    // Attenzione : posso arrivare su questa pagina anche da assegnazioneSupplementareCtrl -> in questo caso recupero il dato da request
    if(numSupplemento == null){
       numSupplemento = (Long)request.getAttribute("numeroSupplemento");
       SolmrLogger.debug(this, " -- numSupplemento da request ="+numSupplemento);
    }
    // PROVA ALE

    frmAssegnazioneSupplementareVO = client.getAssegnazioneSupplementare(idDittaUma, numSupplemento);
    
    
    SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getExtIdIntermediarioLong(): "+frmAssegnazioneSupplementareVO.getExtIdIntermediarioLong());

    Long tipiSupplemento = frmAssegnazioneSupplementareVO.getTipiSupplementoLong();
    SolmrLogger.debug(this,"tipiSupplemento: "+tipiSupplemento);
    if(tipiSupplemento!=null)
    {
      String descTipiSupplemento = client.getDescTipoSupplemento(tipiSupplemento);
      SolmrLogger.debug(this,"descTipiSupplemento: "+descTipiSupplemento);
      frmAssegnazioneSupplementareVO.setDescTipiSupplemento(descTipiSupplemento);
    }
    SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getDescTipiSupplemento(): "+frmAssegnazioneSupplementareVO.getDescTipiSupplemento());
    request.setAttribute("frmAssegnazioneSupplementareVO",frmAssegnazioneSupplementareVO);

    frmAssegnazioneSupplementareVO.formatFields();
    request.setAttribute("frmAssegnazioneSupplementareVO",frmAssegnazioneSupplementareVO);
    SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getIdAssCarb()="+frmAssegnazioneSupplementareVO.getIdAssCarb());
    SolmrLogger.debug(this,"-- numeroSupplemento ="+frmAssegnazioneSupplementareVO.getNumeroSupplemento());
  }
  catch(SolmrException e)
  {
    SolmrLogger.error(this, " -- SolmrException in verificaAssegnazioneSupplementareSalvataBOCtrl ="+e.getMessage());
    throwValidation(e.getMessage(),VIEW_URL);
  }
  catch(Exception e)
  {
    SolmrLogger.error(this, " -- Exception in verificaAssegnazioneSupplementareSalvataBOCtrl ="+e.getMessage());
    throwValidation((String)it.csi.solmr.etc.SolmrErrors.get("GENERIC_SYSTEM_EXCEPTION"),VIEW_URL);
  }
  finally{
    SolmrLogger.debug(this, "   END verificaAssegnazioneSupplementareSalvataBOCtrl");
  }

%><jsp:setProperty name="frmAssegnazioneSupplementareVO" property="*" /><%

  SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getDescTipiSupplemento="+frmAssegnazioneSupplementareVO.getDescTipiSupplemento());
  frmAssegnazioneSupplementareVO.makeTotals();
  SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getExtIdIntermediarioLong(): "+frmAssegnazioneSupplementareVO.getExtIdIntermediarioLong());

%><jsp:forward page ="<%=VIEW_URL%>" /><%
  SolmrLogger.debug(this,"verificaAssegnazioneSalvataBOCtrl.jsp -  FINE PAGINA");
%>

<%!

  private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException("Errore: eccezione="+msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }

%>

