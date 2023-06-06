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
  private static final String VIEW_URL="/domass/view/verificaAssegnazioneSupplementareTrasmessaView.jsp";
%>
<%

  String iridePageName = "verificaAssegnazioneSupplementareTrasmessaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient client = new UmaFacadeClient();
  try
  {
    SolmrLogger.debug(this,"\n\n\n\n\n\n\n\n\n\n\n\nfindDomAssByPrimaryKey()...\n\n\n\n");
    SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getIdDomandaassegnazione()="+request.getParameter("idDomandaAssegnazione"));
//    DomandaAssegnazione domandaAssegnazione=client.findDomAssByPrimaryKey(new Long(request.getParameter("idDomandaAssegnazione")));
    AssegnazioneCarburanteVO assegnazioneCarburanteVO=client.getAssegnazioneCarburante((Long)request.getAttribute("idAssCarb"));
    SolmrLogger.debug(this,"\n\n\n\n\n\n\n\n\n\n\n\ndone!\n\n\n\n");
    request.setAttribute("assegnazioneCarburanteVO",assegnazioneCarburanteVO);
//    request.setAttribute("domandaAssegnazione",domandaAssegnazione);
  }
  catch(Exception e)
  {
    throwValidation(e.getMessage(),VIEW_URL);
  }
%>

  <jsp:forward page ="<%=VIEW_URL%>" />

<%
  SolmrLogger.debug(this,"verificaAssegnazioneTrasmessaView.jsp -  FINE PAGINA");
%>
<%!
  private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException("Errore: eccezione="+msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }
%>
