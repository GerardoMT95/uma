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

<jsp:useBean id="frmVerificaAssegnazioneVO" scope="request"
 class="it.csi.solmr.dto.uma.FrmVerificaAssegnazioneVO">
  <jsp:setProperty name="frmVerificaAssegnazioneVO" property="*" />
</jsp:useBean>
<%!
  private static final String VIEW="/domass/view/confermaValidazioneDomandaView.jsp";
  private static final String ANNULLA="../layout/verificaAssegnazioneSalvataBO.htm";
  private static final String ANNULLA_INTERMEDIARIO="../layout/verificaAssegnazioneSalvata.htm";
  private static final String PAGINA_VALIDAZIONE="../ctrl/verificaAssegnazioneValidataCtrl.jsp";
  private static final String PAGINA_FOGLIO="../ctrl/verificaAssegnazioneFoglioCtrl.jsp";
  private static final Long IN_ATTESA_VALIDAZIONE_PA = new Long(20);
%>
<%

  String iridePageName = "confermaValidazioneDomandaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "BREGIN confermaValidazioneDomandaCtrl");		  
		  
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  it.csi.solmr.client.uma.UmaFacadeClient client = new it.csi.solmr.client.uma.UmaFacadeClient();
  if (request.getParameter("confermaValida")!=null)
  {
    SolmrLogger.debug(this,"VALIDAZIONE****************************************");
    SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getExtIdIntermediario()="+frmVerificaAssegnazioneVO.getExtIdIntermediario());

    //Recuperato dalla confermaCreazioneFoglioRigaCtrl.jsp
    session.setAttribute("common", frmVerificaAssegnazioneVO);
    SolmrLogger.debug(this," -- PAGINA_FOGLIO ="+PAGINA_FOGLIO);

    %><jsp:forward page ="<%=PAGINA_FOGLIO%>" /><%
    return;
  }
  else
    if (request.getParameter("annullaValida")!=null)
    {
      if(ruoloUtenza.isUtenteIntermediario()){
        response.sendRedirect(ANNULLA_INTERMEDIARIO);
      }
      else{
        response.sendRedirect(ANNULLA);
      }
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
