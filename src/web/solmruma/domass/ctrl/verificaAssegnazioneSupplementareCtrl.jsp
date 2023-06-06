

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
  private static final String VIEW_URL="/domass/view/verificaAssegnazioneSupplementareView.jsp";
  private static final String NEXT_PAGE="/domass/layout/verificaAssegnazioneSupplementareSalvata.htm";
%>
<%

  String iridePageName = "verificaAssegnazioneSupplementareCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  UmaFacadeClient client = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  frmAssegnazioneSupplementareVO.makeTotals();
  if (request.getParameter("indietro.x")!=null)
  {
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
    try
    {
      SolmrLogger.debug(this,"\n\n\n\n\n\n\n\n\n1");
      FrmDettaglioAssegnazioneVO daVO=new FrmDettaglioAssegnazioneVO();
      daVO.setAltreMacchine(new Long(request.getParameter("altreMacchine")));
      frmAssegnazioneSupplementareVO.setFrmDettaglioAssegnazioneVO(daVO);
//      frmAssegnazioneSupplementareVO.formatFields();

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

      ValidationErrors errors = client.controllaAssegnazioneSupplementare(frmAssegnazioneSupplementareVO,ruoloUtenza,notifica);
      SolmrLogger.debug(this,"\n\n\n\n\n/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*");

      Long tipiSupplemento = frmAssegnazioneSupplementareVO.getTipiSupplementoLong();
      SolmrLogger.debug(this,"tipiSupplemento: "+tipiSupplemento);
      if(tipiSupplemento!=null){
        String descTipiSupplemento = client.getDescTipoSupplemento(tipiSupplemento);
        SolmrLogger.debug(this,"descTipiSupplemento: "+descTipiSupplemento);
        frmAssegnazioneSupplementareVO.setDescTipiSupplemento(descTipiSupplemento);
      }
      SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getDescTipiSupplemento(): "+frmAssegnazioneSupplementareVO.getDescTipiSupplemento());
      request.setAttribute("frmAssegnazioneSupplementareVO",frmAssegnazioneSupplementareVO);

      SolmrLogger.debug(this,"6");

      //SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getIdAssCarb()="+frmAssegnazioneSupplementareVO.getIdAssCarb());
//      frmAssegnazioneSupplementareVO.formatFields();
      SolmrLogger.debug(this,"7");
      if (errors!=null && errors.size()>0)
      {
        SolmrLogger.debug(this,"8");
        request.setAttribute("errors",errors);
        SolmrLogger.debug(this,"9");
        SolmrLogger.debug(this,"errors="+errors);
      }
      else
      {
        SolmrLogger.debug(this,"10");
      %><jsp:forward page="<%=NEXT_PAGE%>" /><%
        return;
      }
    }
    catch(Exception e)
    {
      throwValidation(e.getMessage(),VIEW_URL);
    }
  }
  else
  {
    try
    {
      SolmrLogger.debug(this,"-- non è caso conferma");
      SolmrLogger.debug(this,"idDittaUma="+idDittaUma);
      
      String numSupplemento = request.getParameter("numSupplemento");
      Long numSupplementoL = null;
      if(numSupplemento != null && !numSupplemento.equals(""))
        numSupplementoL = new Long(numSupplemento);      
      SolmrLogger.debug(this," -- numSupplementoL ="+numSupplementoL);
      
      frmAssegnazioneSupplementareVO=client.getAssegnazioneSupplementare(idDittaUma, numSupplementoL);
      
      if ("0".equals(frmAssegnazioneSupplementareVO.getNumeroDoc()))
      {
        frmAssegnazioneSupplementareVO.setNumeroDoc(null);
      }
      SolmrLogger.debug(this,"\n\n\n\n\n\n++++++++++++++++++++++++++");
      SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getIdDomandaAssegnazione(): "+frmAssegnazioneSupplementareVO.getIdDomandaAssegnazione());
      SolmrLogger.debug(this, " --- numSupplemento ="+frmAssegnazioneSupplementareVO.getNumeroSupplemento()); 

      request.setAttribute("frmAssegnazioneSupplementareVO",frmAssegnazioneSupplementareVO);
    }
    catch(Exception e)
    {
      SolmrLogger.error(this, "--- Exception in verificaAssegnazioneSupplementareCtrl ="+e.getMessage());
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
