

<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<jsp:useBean id="frmAssegnazioneSupplementareVO" scope="request"
 class="it.csi.solmr.dto.uma.FrmAssegnazioneSupplementareVO">
  <jsp:setProperty name="frmAssegnazioneSupplementareVO" property="*" />
</jsp:useBean>
<%!
  private static final String VIEW_URL="/domass/view/verificaAssegnazioneSupplementareBOView.jsp";
  private static final String NEXT_PAGE="/domass/layout/verificaAssegnazioneSupplementareSalvataBO.htm";
%>
<%

  String iridePageName = "verificaAssegnazioneSupplementareBOCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  SolmrLogger.debug(this, "   BEGIN verificaAssegnazioneSupplementareBOCtrl");
  
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  UmaFacadeClient client = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  frmAssegnazioneSupplementareVO.makeTotals();
  if (request.getParameter("indietro.x")!=null)
  {
    SolmrLogger.debug(this, " -- Caso INDIETRO"); 
    try{
      SolmrLogger.debug(this,"if (request.getParameter(\"indietro.x\")!=null)");
      %>
        <jsp:forward page="<%=VIEW_URL%>" />
      <%
    }
    catch(Exception e){
      throwValidation(e.getMessage(),VIEW_URL);
    }
  }

  if (request.getParameter("conferma.x")!=null)
  {
    SolmrLogger.debug(this, " -- Caso CONFERMA");
    try
    {      
      FrmDettaglioAssegnazioneVO daVO=new FrmDettaglioAssegnazioneVO();     
      daVO.setAltreMacchine(new Long(request.getParameter("altreMacchine")));
      
      Long numeroSupplemento = new Long(request.getParameter("numeroSupplemento"));
      SolmrLogger.debug(this, "-- numeroSupplemento recuperato da hidden in verificaAssegnazioneSupplementare.htm ="+numeroSupplemento);
      frmAssegnazioneSupplementareVO.setNumeroSupplemento(numeroSupplemento);
       
      
      frmAssegnazioneSupplementareVO.setFrmDettaglioAssegnazioneVO(daVO);            
      SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getIdDomandaAssegnazione(): "+frmAssegnazioneSupplementareVO.getIdDomandaAssegnazione());
		
      /***
      	Controllo se si tratta di un'Assegnazione Supplementare di Maggiorazione (se notifica = "supplementareMaggiorazione"), 
      	in questo caso effettuo ulteriori controlli      		
      */
      SolmrLogger.debug(this,"--- Controllo se si tratta di un'Assegnazione Supplementare di Maggiorazione, in questo caso effettuo ulteriori controlli");
      String notifica = null;
      Hashtable common = (Hashtable) session.getAttribute("common");
      if(common != null){
     	  notifica = (String) common.get("notifica");
     	  SolmrLogger.debug(this, "--- notifica: " + notifica);     	 
      }	  
      ValidationErrors errors=client.controllaAssegnazioneSupplementare(frmAssegnazioneSupplementareVO,ruoloUtenza,notifica);
      
      Long tipiSupplemento = frmAssegnazioneSupplementareVO.getTipiSupplementoLong();
      SolmrLogger.debug(this,"tipiSupplemento: "+tipiSupplemento);
      if(tipiSupplemento!=null){
        String descTipiSupplemento = client.getDescTipoSupplemento(tipiSupplemento);
        SolmrLogger.debug(this,"descTipiSupplemento: "+descTipiSupplemento);
        frmAssegnazioneSupplementareVO.setDescTipiSupplemento(descTipiSupplemento);
      }
      SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getDescTipiSupplemento(): "+frmAssegnazioneSupplementareVO.getDescTipiSupplemento());
      request.setAttribute("frmAssegnazioneSupplementareVO",frmAssegnazioneSupplementareVO);

      if (errors!=null && errors.size()>0)
      {
        request.setAttribute("errors",errors);       
        SolmrLogger.debug(this,"errors="+errors);
      }
      else
      {
        SolmrLogger.debug(this, " --- nextPage ="+NEXT_PAGE);
      %><jsp:forward page="<%=NEXT_PAGE%>" /><%
        return;
      }
    }
    catch(Exception e)
    {
      SolmrLogger.error(this, " --- Exception in verificaAssegnazioneSupplementareBOCtrl ="+e.getMessage()); 
      throwValidation(e.getMessage(),VIEW_URL);
    }
  }
  else
  {
    try
    {
      SolmrLogger.debug(this,"-- non è caso conferma");
      SolmrLogger.debug(this," --- idDittaUma="+idDittaUma);
      
      String numSupplemento = request.getParameter("numSupplemento");
      Long numSupplementoL = null;
      if(numSupplemento != null && !numSupplemento.equals(""))
        numSupplementoL = new Long(numSupplemento);      
      SolmrLogger.debug(this," -- numSupplementoL ="+numSupplementoL);
      
      frmAssegnazioneSupplementareVO = client.getAssegnazioneSupplementare(idDittaUma,numSupplementoL);
      SolmrLogger.debug(this, " --- numSupplemento ="+frmAssegnazioneSupplementareVO.getNumeroSupplemento());
      
      if ("0".equals(frmAssegnazioneSupplementareVO.getNumeroDoc()))
      {
        frmAssegnazioneSupplementareVO.setNumeroDoc(null);
      }
      SolmrLogger.debug(this,"\n\n\n\n\n\n++++++++++++++++++++++++++");
      SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getIdDomandaAssegnazione(): "+frmAssegnazioneSupplementareVO.getIdDomandaAssegnazione());

      SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getAssSupplPrecContoProprioGasolio(): "+frmAssegnazioneSupplementareVO.getAssSupplPrecContoProprioGasolio());
      SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getAssSupplPrecContoTerziGasolio(): "+frmAssegnazioneSupplementareVO.getAssSupplPrecContoTerziGasolio());
      SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getAssSupplPrecRiscSerraGasolio(): "+frmAssegnazioneSupplementareVO.getAssSupplPrecRiscSerraGasolio());
      SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getAssSupplPrecContoProprioBenzina(): "+frmAssegnazioneSupplementareVO.getAssSupplPrecContoProprioBenzina());
      SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getAssSupplPrecContoTerziBenzina(): "+frmAssegnazioneSupplementareVO.getAssSupplPrecContoTerziBenzina());
      SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getAssSupplPrecRiscSerraBenzina(): "+frmAssegnazioneSupplementareVO.getAssSupplPrecRiscSerraBenzina());

      request.setAttribute("frmAssegnazioneSupplementareVO",frmAssegnazioneSupplementareVO);
    }
    catch(Exception e)
    {
      SolmrLogger.error(this, "--- Exception in verificaAssegnazioneSupplementareBOCtrl ="+e.getMessage());
      throwValidation(e.getMessage(),VIEW_URL);
    }
  }
  frmAssegnazioneSupplementareVO.makeTotals();
%>
<jsp:forward page="<%=VIEW_URL%>" />
<%!
  private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException(msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }
%>
