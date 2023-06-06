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
<%!
  private static final String VIEW="/domass/view/confermaValidazioneAssegnazioneSupplView.jsp";
  private static final String ANNULLA="../layout/verificaAssegnazioneSupplementareSalvataBO.htm";
  private static final String PAGINA_VALIDAZIONE="../ctrl/verificaAssegnazioneSupplementareValidataCtrl.jsp";
  private static final String PAGINA_FOGLIO="../ctrl/verificaAssegnazioneSupplementareFoglioCtrl.jsp";
%>
<%

  String iridePageName = "confermaValidazioneAssegnazioneSupplCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this,"   BEGIN confermaValidazioneAssegnazioneSupplCtrl.jsp");
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
 // it.csi.solmr.client.uma.UmaFacadeClient client = new it.csi.solmr.client.uma.UmaFacadeClient();

  SolmrLogger.debug(this, "--- numeroSupplemento ="+frmAssegnazioneSupplementareVO.getNumeroSupplemento()); 
  session.setAttribute("frmAssegnazioneSupplementareVO", frmAssegnazioneSupplementareVO);

  SolmrLogger.debug(this,"request.getParameter(\"idAssCarb\") : "+request.getParameter("idAssCarb"));

  if (request.getParameter("confermaValida")!=null)
  {
    SolmrLogger.debug(this," --- Caso confermaValida");

    session.setAttribute("common", frmAssegnazioneSupplementareVO);

    SolmrLogger.debug(this,"done Validate");
    SolmrLogger.debug(this,"FINE VALIDAZIONE");

    %><jsp:forward page ="<%=PAGINA_FOGLIO%>" /><%
    return;
  }
  else{
    SolmrLogger.debug(this,"annullaValida");
    if (request.getParameter("annullaValida")!=null)
    {
      SolmrLogger.debug(this, " --- Caso annullaValida");
      response.sendRedirect(ANNULLA);
    }
  }
   SolmrLogger.debug(this,"   END confermaValidazioneAssegnazioneSupplCtrl.jsp");
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
