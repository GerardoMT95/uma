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

<%!
  public static String URL="/ditta/view/elencoSuperficiView.jsp";
%>
<%

  String iridePageName = "elencoSuperficiCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  UmaFacadeClient umaClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  SolmrLogger.debug(this,"[elencoSuperficiCtrl::service] *************************** idDittaUma "+idDittaUma);
  String info=(String)session.getAttribute("notifica");
  session.removeAttribute("idSuperficie");
  if (info!=null)
  {
    findData(request,umaClient,idDittaUma,URL);
    session.removeAttribute("notifica");
    throwValidation(info, URL);
  }
   
  // Visualizzazione allevamenti
  findData(request,umaClient,idDittaUma,URL);
  %>
    <jsp:forward page="<%=URL%>" />
  <%
  
%>

<%!
  private void converData(SuperficieAziendaVO superficieVO)
  {
    superficieVO.setTipiContratto(""+superficieVO.getIdContratto());
    superficieVO.setTipiScadenza(""+superficieVO.getIdScadenza());
    superficieVO.setTipiTitoloPossesso(""+superficieVO.getIdTitoloPossesso());
    superficieVO.setDataCaricoStr(dateStr(superficieVO.getDataCarico()));
    superficieVO.setDataScaricoStr(dateStr(superficieVO.getDataScarico()));
    superficieVO.setDataRegistrazioneStr(dateStr(superficieVO.getDataRegistrazione()));
    superficieVO.setDataScadenzaAffittoStr(dateStr(superficieVO.getDataScadenzaAffitto()));
  }
  private String dateStr(Date date)
  {
    if (date!=null)
    {
      return DateUtils.formatDate(date);
    }
    else
    {
      return "";
    }
  }
  private void findData(HttpServletRequest request,UmaFacadeClient umaClient,Long idDittaUma,String validateUrl)
      throws ValidationException
  {
    try
    {
      Vector<SuperficieAziendaVO> superfici = umaClient.getSuperficiAzienda(idDittaUma,new Boolean(false));
      request.setAttribute("elencoSuperfici",superfici);
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
