<%@ page import="it.csi.solmr.util.*,it.csi.solmr.dto.uma.*" %>



<%@ page language="java"
  contentType="text/html"
%>

<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%


  String iridePageName = "cessaDittaUmaSalvataSenzaVerificaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();



  String url = "/ditta/view/cessaDittaUmaSalvataSenzaVerificaView.jsp";

  SolmrLogger.debug(this,"____________sono in cessaDittaUmaSalvataSenzaVerificaCtrl______________");

  /*Long idDittaUma = null;

  if(request.getParameter("idDittaUMA") != null && !request.getParameter("idDittaUMA").equals(""))

    idDittaUma = new Long(request.getParameter("idDittaUMA"));

  SolmrLogger.debug(this,"____________sono in cessaDittaUmaSalvataSenzaVerificaCtrl idDittaUma______________"+idDittaUma);

  DittaUMAVO duVO = umaFacadeClient.findByPrimaryKey(idDittaUma);

  if(duVO.getDataCessazione()!=null){

    ValidationErrors errors = new ValidationErrors();

    ValidationError error = new ValidationError(""+UmaErrors.get("DITTA_CESSATA"));

    errors.add("error", error);

    request.setAttribute("errors", errors);

    request.getRequestDispatcher(url).forward(request, response);

  }*/

  ValidationException valEx = null;

  Validator validator = new Validator(url);

  session.setAttribute("refreshDettaglio", "true");

%>

<jsp:forward page="<%=url%>"/>

