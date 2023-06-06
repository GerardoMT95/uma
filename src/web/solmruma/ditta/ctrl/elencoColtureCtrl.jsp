<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="java.lang.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String iridePageName = "elencoColtureCtrl.jsp";
%>
  <%@include file = "/include/autorizzazione.inc" %>
<%
  SolmrLogger.debug(this, "   BEGIN elencoColtureCtrl");

  String idSuperficie=null;

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  UmaFacadeClient umaClient = new UmaFacadeClient();


  Vector<SuperficieAziendaVO> vSuperficieAzienda = null;
  SolmrLogger.debug(this,"[elencoColtureCtrl::service] request.getParameter(\"idSuperficie\") != null");
  idSuperficie = request.getParameter("idSuperficie");
  StringTokenizer st = new StringTokenizer(idSuperficie, "|");
  String istatComune = st.nextToken();
  String idTitoloPossesso = st.nextToken();
  String dataInizioValidita = st.nextToken();
  String flagColturaSecondaria = st.nextToken();
    SolmrLogger.debug(this, "-- flagColturaSecondaria ="+flagColturaSecondaria);
  String dataFineValidita = "";
  if(st.hasMoreElements())
    dataFineValidita = st.nextToken(); 

  vSuperficieAzienda = umaClient.findSuperficiAziendaByComunePossesso(
    dittaUMAAziendaVO.getIdDittaUMA(), istatComune, new Long(idTitoloPossesso), dataInizioValidita, dataFineValidita, flagColturaSecondaria);
  
  SolmrLogger.debug(this,"[elencoColtureCtrl::service] idSuperficie: "+idSuperficie);
  
  request.setAttribute("vSuperficieAzienda", vSuperficieAzienda);

  //UmaFacadeClient umaClient = new UmaFacadeClient();
  String URL="/ditta/view/elencoColtureView.jsp";

  String elencoSuperficiHtmlUrl="../layout/elencoSuperfici.htm";
  String elencoSuperficiHtmlBisUrl="../layout/elencoSuperficiBis.htm";

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  SolmrLogger.debug(this,"[elencoColtureCtrl::service] ruoloUtenza.getIdUtente(): " + ruoloUtenza.getIdUtente());

  //Gestisce una sola visualizzazione del messaggio di notifica
  String info=(String)session.getAttribute("notifica");
  if (info!=null)
  {
    findData(request, umaClient, dittaUMAAziendaVO.getIdDittaUMA(), new Long(idTitoloPossesso), istatComune, dataInizioValidita, dataFineValidita, flagColturaSecondaria, URL);
    session.removeAttribute("notifica");
    throwValidation(info, URL);
  }

  findData(request, umaClient, dittaUMAAziendaVO.getIdDittaUMA(), new Long(idTitoloPossesso), istatComune, dataInizioValidita, dataFineValidita, flagColturaSecondaria, URL);
  
  SolmrLogger.debug(this, "   END elencoColtureCtrl");
  
  %>
    <jsp:forward page="<%=URL%>" />
  <%
    
  
%>

<%!
  private void findData(HttpServletRequest request, UmaFacadeClient umaClient,Long idDittaUma, 
    Long idTitoloPossesso, String istatComune, String dataInizioValidita, String dataFineValidita, String flagColturaSecondaria, String validateUrl)
      throws ValidationException
  {
    try
    {
      Vector<ColturaPraticataVO> colture=umaClient.getColtureComunePossessoPr(idDittaUma, idTitoloPossesso, istatComune, dataInizioValidita, dataFineValidita, flagColturaSecondaria);
      SolmrLogger.debug(this,"[elencoColtureCtrl::service] colture.size(): " + colture.size());
      request.setAttribute("elencoColture",colture);
      SolmrLogger.debug(this,"[elencoColtureCtrl::service] Dopo colture.size(): " + colture.size());
    }
    catch(Exception e)
    {
      throwValidation(e.getMessage(),validateUrl);
    }
  }
  private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException(msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }

%>