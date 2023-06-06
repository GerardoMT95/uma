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
  private static final String VIEW_URL="/domass/view/verificaAssegnazioneSupplementareSalvataView.jsp";
  private static final String PAGINA_VALIDAZIONE="/domass/ctrl/confermaTrasmissioneAssegnazioneSupplCtrl.jsp";
  private static final String PAGE_PREV="../layout/verificaAssegnazioneSupplementare.htm";
%>
<%

  String iridePageName = "verificaAssegnazioneSupplementareSalvataCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "   BEGIN verificaAssegnazioneSupplementareSalvataCtrl");
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  it.csi.solmr.client.uma.UmaFacadeClient client = new it.csi.solmr.client.uma.UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  SolmrLogger.debug(this,"valida="+request.getParameter("valida"));
  SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getDescTipiSupplemento="+frmAssegnazioneSupplementareVO.getDescTipiSupplemento());

  if(frmAssegnazioneSupplementareVO.getTipiSupplemento()!=null)
  {
      SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getTipiSupplemento()="+frmAssegnazioneSupplementareVO.getTipiSupplemento());
      String descTipiSupplemento = client.getDescTipoSupplemento(frmAssegnazioneSupplementareVO.getTipiSupplementoLong());
      SolmrLogger.debug(this,"descTipiSupplemento: "+descTipiSupplemento);
      frmAssegnazioneSupplementareVO.setDescTipiSupplemento(descTipiSupplemento);
  }

  if (request.getParameter("trasmetti.x")!=null)
  {
    SolmrLogger.debug(this, " --- CASO trasmetti");
    SolmrLogger.debug(this, " -- numeroSupplemento ="+frmAssegnazioneSupplementareVO.getNumeroSupplemento()); 
    try
    {
      SolmrLogger.debug(this," --- TRASMISSIONE ---");
      %><jsp:forward page="<%=PAGINA_VALIDAZIONE%>" /><%
      SolmrLogger.debug(this,"--- FINE TRASMISSIONE ---");
      return;
    }
    catch(Exception e)
    {
      SolmrLogger.error(this, "-- Exception in verificaAssegnazioneSupplementareSalvataCtrl ="+e.getMessage());
      throwValidation(e.getMessage(),VIEW_URL);
    }
  }

  if (request.getParameter("indietro.x")!=null)
  {
    SolmrLogger.debug(this, " --- CASO indietro");
    try
    {
      SolmrLogger.debug(this,"INDIETRO");
      %><jsp:forward page="<%=PAGE_PREV%>" /><%
      SolmrLogger.debug(this,"FINE INDIETRO");
      return;
    }
    catch(Exception e)
    {
      throwValidation(e.getMessage(),VIEW_URL);
    }
  }
  if(frmAssegnazioneSupplementareVO.getTipiSupplemento()!=null)
  {
      SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getTipiSupplemento()="+frmAssegnazioneSupplementareVO.getTipiSupplemento());
      String descTipiSupplemento = client.getDescTipoSupplemento(frmAssegnazioneSupplementareVO.getTipiSupplementoLong());
      SolmrLogger.debug(this,"descTipiSupplemento: "+descTipiSupplemento);
      frmAssegnazioneSupplementareVO.setDescTipiSupplemento(descTipiSupplemento);
  }
  frmAssegnazioneSupplementareVO.makeTotals();
  // ARRIVA QUI SE STO VISUALIZZANDO LA PAGINA PER LA PRIMA VOLTA
  try
  {
      
    String idDomandaAssegnazione = frmAssegnazioneSupplementareVO.getIdDomandaAssegnazione();
    SolmrLogger.debug(this, "--- idDomandaAssegnazione ="+idDomandaAssegnazione);       
    Long numSupplemento = frmAssegnazioneSupplementareVO.getNumeroSupplemento();
    SolmrLogger.debug(this, " -- numSupplemento ="+numSupplemento);  
    
    frmAssegnazioneSupplementareVO = client.getAssegnazioneSupplementare(idDittaUma, numSupplemento);

    SolmrLogger.debug(this,"\n\n\n\n\n/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*");
    frmAssegnazioneSupplementareVO.setTipiSupplemento(request.getParameter("tipiSupplemento"));
    Long tipiSupplemento = frmAssegnazioneSupplementareVO.getTipiSupplementoLong();
    SolmrLogger.debug(this,"tipiSupplemento: "+tipiSupplemento);
    if(frmAssegnazioneSupplementareVO.getTipiSupplemento()!=null)
    {
        SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getTipiSupplemento()="+frmAssegnazioneSupplementareVO.getTipiSupplemento());
        String descTipiSupplemento = client.getDescTipoSupplemento(frmAssegnazioneSupplementareVO.getTipiSupplementoLong());
        SolmrLogger.debug(this,"descTipiSupplemento: "+descTipiSupplemento);
        frmAssegnazioneSupplementareVO.setDescTipiSupplemento(descTipiSupplemento);
    }
    SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getDescTipiSupplemento(): "+frmAssegnazioneSupplementareVO.getDescTipiSupplemento());
    request.setAttribute("frmAssegnazioneSupplementareVO",frmAssegnazioneSupplementareVO);


    frmAssegnazioneSupplementareVO.formatFields();
    request.setAttribute("frmAssegnazioneSupplementareVO",frmAssegnazioneSupplementareVO);

    SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getIdAssCarb()="+frmAssegnazioneSupplementareVO.getIdAssCarb());
  }
  catch(SolmrException e)
  {
    SolmrLogger.error(this, " -- SolmrException in verificaAssegnazioneSupplementareSalvataCtrl ="+e.getMessage());
    throwValidation(e.getMessage(),VIEW_URL);
  }
  catch(Exception e)
  {
    SolmrLogger.error(this, " -- Exception in verificaAssegnazioneSupplementareSalvataCtrl ="+e.getMessage());
    throwValidation((String)it.csi.solmr.etc.SolmrErrors.get("GENERIC_SYSTEM_EXCEPTION"),VIEW_URL);
  }
  finally{
    SolmrLogger.debug(this, "   END verificaAssegnazioneSupplementareSalvataCtrl");
  }
%><jsp:setProperty name="frmAssegnazioneSupplementareVO" property="*" /><%

  SolmrLogger.debug(this,"\n\n\n\n*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*");
  SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getDescTipiSupplemento="+frmAssegnazioneSupplementareVO.getDescTipiSupplemento());
  frmAssegnazioneSupplementareVO.makeTotals();
%><jsp:forward page ="<%=VIEW_URL%>" /><%
  SolmrLogger.debug(this,"verificaAssegnazioneSalvataCtrl.jsp -  FINE PAGINA");
%>
<%!
  private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException("Errore: eccezione="+msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }
%>
