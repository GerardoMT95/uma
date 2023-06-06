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

  String iridePageName = "cessaDittaUmaSenzaVerificaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  String url = "/ditta/view/cessaDittaUmaSenzaVerificaView.jsp";
  SolmrLogger.debug(this,"____________sono in cessaDittaUmaSenzaVerificaCtrl_______________");

  ValidationException valEx = null;
  Validator validator = new Validator(url);
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
  ValidationError error = null;

  if(request.getParameter("avanti")!=null){
    SolmrLogger.debug(this,"AVANTI, idDittaUMA "+request.getParameter("idDittaUMA"));
    Date dataCessazioneAttivita = DateUtils.parseDate(request.getParameter("dataCessazioneAttivita"));
    Date dataCorrente = new Date();
    dataCorrente = DateUtils.parseDate(DateUtils.getCurrent());
    if(dataCessazioneAttivita.after(dataCorrente)){
      url = "/ditta/view/cessaDittaUmaSenzaVerificaView.jsp";
      error=new ValidationError(""+UmaErrors.get("DATA_MAGGIORE_CORRENTE"));
      SolmrLogger.debug(this,"ERRORE DATA!!!!!!!!!!!!!!");
      ValidationErrors errors = new ValidationErrors();
      errors.add("dataCessazioneAttivita", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(url).forward(request, response);
      return;
    }
    else{
      DittaUMAVO dittaUma = new DittaUMAVO();
      dittaUma.setIdDitta(new Long(request.getParameter("idDittaUMA")));
      dittaUma.setDataCessazione(dataCessazioneAttivita);
      try{
        SolmrLogger.debug(this,"prima di updateDittaUMACessazione in CTRL");
        umaFacadeClient.updateDittaUMACessazione(dittaUma, ruoloUtenza);
        url = "/ditta/view/cessaDittaUmaSalvataSenzaVerificaView.jsp";
      }catch(SolmrException ex){
        throw ex;
      }
    }
  }
  else{
    SolmrLogger.debug(this,"NON HO CLICKATO AVANTI");
  }

%>
<jsp:forward page="<%=url%>"/>