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
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<jsp:useBean id="targaVO" scope="request" class="it.csi.solmr.dto.uma.TargaVO">
  <jsp:setProperty name="targaVO" property="*" />
</jsp:useBean>
<jsp:useBean id="dittaProvenienzaVO" scope="request" class="it.csi.solmr.dto.uma.DittaUMAVO">
  <jsp:setProperty name="dittaProvenienzaVO" property="*" />
</jsp:useBean>
<%!
  private static final String VIEW="/macchina/view/macchinaUsataTrovataDatiCasoR-ASMView.jsp";
/*
  private static final String PREV="/macchina/ctrl/macchinaUsataTargaCtrl.jsp";
  private static final String NEXT="/macchina/ctrl/macchinaUsataTrovataUtilizzoCasoR-ASMCtrl.jsp";ù
*/
  private static final String PREV="../layout/macchinaUsataTarga.htm";
  private static final String NEXT="../layout/macchinaUsataTrovataUtilizzoCasoR-ASM.htm";
  private static final String ACQUISTA_MACCHINA="../layout/macchinaUsataTarga.htm";%>
<%

  String iridePageName = "macchinaUsataTrovataDatiCasoR-ASMCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  if (session.getAttribute("common")!=null && !(session.getAttribute("common") instanceof java.util.HashMap))
  {
    SolmrLogger.debug(this,"Redirecting to "+ACQUISTA_MACCHINA);
    response.sendRedirect(ACQUISTA_MACCHINA);
    return;
  }
  DittaUMAVO dittaUmaVO=(DittaUMAVO)session.getAttribute("dittaUmaVO");
  UmaFacadeClient umaClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  SolmrLogger.debug(this,"");
  if (request.getParameter("avanti2")!=null)
  {
    SolmrLogger.debug(this,"NEXT");
    response.sendRedirect(NEXT);
    return;
  }
  if (request.getParameter("indietro2")!=null)
  {
    SolmrLogger.debug(this,"PREV");
    HashMap common=(HashMap)session.getAttribute("common");
    common.put("indietro","indietro");
    response.sendRedirect(PREV);
    return;
  }
%>
<jsp:forward page="<%=VIEW%>"/>
<%!
  private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException("Errore: eccezione="+msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
}
%>

