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
  private static final String PREV_CTRL="/domass/ctrl/verificaAssegnazioneSupplementareSalvataCtrl.jsp";
  private static final String VIEW="/domass/view/confermaTrasmissioneAssegnazioneSupplView.jsp";
//  private static final String NEXT_PAGE="../layout/verificaAssegnazioneSupplementareTrasmessa.htm";
  private static final String NEXT_PAGE="/domass/ctrl/verificaAssegnazioneSupplementareTrasmessaCtrl.jsp";
  private static final String PREV_PAGE="/domass/ctrl/verificaAssegnazioneSupplementareSalvataCtrl.jsp";
%>
<jsp:useBean id="frmAssegnazioneSupplementareVO" scope="request"
 class="it.csi.solmr.dto.uma.FrmAssegnazioneSupplementareVO">
  <jsp:setProperty name="frmAssegnazioneSupplementareVO" property="*" />
</jsp:useBean>
<%

  String iridePageName = "confermaTrasmissioneAssegnazioneSupplCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "   BEGIN confermaTrasmissioneAssegnazioneSupplCtrl");
  
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  if (request.getParameter("conferma.x")!=null)
  {
    SolmrLogger.debug(this, "-- Caso di CONFERMA");
    try
    {
      DomandaAssegnazione da=new DomandaAssegnazione();
      UmaFacadeClient client = new UmaFacadeClient();
      SolmrLogger.debug(this, "----- trasmettiAssegnazioneSuppl --");
      Long idAssCarb=  client.trasmettiAssegnazioneSuppl(idDittaUma,frmAssegnazioneSupplementareVO,ruoloUtenza);
      if (idAssCarb!=null)
      {
        request.setAttribute("idAssCarb",idAssCarb);
      }
    }
    catch(Exception e)
    {
      SolmrLogger.error(this, "--- Exception in confermaTrasmissioneAssegnazioneSupplCtrl ="+e.getMessage());
      throwValidation(e.getMessage(),PREV_CTRL);
    }
    finally{
      SolmrLogger.debug(this, "   END confermaTrasmissioneAssegnazioneSupplCtrl");
    }
    %><jsp:forward page="<%=NEXT_PAGE%>" /><%
    return;
  }
  if (request.getParameter("annulla.x")!=null)
  {
    SolmrLogger.debug(this, "-- Caso di ANNULLA");
%>
<jsp:forward page="<%=PREV_PAGE%>" />
<%    return;
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
