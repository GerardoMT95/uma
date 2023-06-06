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
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  private static final String VIEW="/macchina/view/elencoMacchineBisView.jsp";
  private static final String STD_CTRL="/macchina/ctrl/elencoMacchineCtrl.jsp";
  private static final String ELIMINA="/layout/conferma.htm";
  private static final String elencoPagine[]={"/dettaglioMacchinaDittaDati.htm",
                                              "/modificaMacchinaDittaDati.htm",
                                              "/dettaglioMacchinaDati.htm",
                                              "/dettaglioMacchinaDittaUtilizzo.htm",
                                              "/dettaglioUtilizzo.htm",
                                              "/modificaUtilizzo.htm",
                                              "/scaricoMacchina.htm",
                                              "dettaglioMacchinaDettaglioUtilizzo.htm",
                                              "/caricoMacchina.htm",
                                              "/dettaglioMacchinaComporprietari.htm",
                                              "/dettaglioMacchinaDettaglioComproprietari.htm",
                                              "/dettaglioMacchinaDittaComproprietari.htm",
                                              "/dettaglioMacchinaDittaDettaglioComproprietari.htm",
                                              "/dettaglioMacchinaDittaNuovaAttestazione.htm",
                                              "/dettaglioMacchinaImmatricolazioni.htm",
                                              "/dettaglioMacchinaDittaImmatricolazioni.htm",
                                              "/dettaglioTarga.htm",
                                              "/nuovaImmatricolazione.htm",
                                              "/nuovaImmatricolazioneConferma.htm",
                                              "/venditaFuoriRegione.htm",
                                              "/venditaFuoriRegioneConferma.htm",
                                              "/conferma.htm"};
%>
<%

  String iridePageName = "elencoMacchineBisCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  if (request.getParameter("elimina.x")!=null)
  {
    %><jsp:forward page="<%=ELIMINA%>" /><%
    return;
  }
  session.removeAttribute("common");
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  UmaFacadeClient umaClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  findData(request,umaClient,idDittaUma,VIEW);
  if (request.getAttribute("errors")==null && session.getAttribute("notifica")!=null)
  {
    ValidationErrors errors=new ValidationErrors();
    errors.add("error",new ValidationError((String)session.getAttribute("notifica")));
    request.setAttribute("errors",errors);
    session.removeAttribute("notifica");
    SolmrLogger.debug(this,"NOTIFICA!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
  }
  %><jsp:forward page="<%=VIEW%>" /><%
%>

<%!
  private void findData(HttpServletRequest request,UmaFacadeClient umaClient,Long idDittaUma,String validateUrl)
      throws ValidationException
  {
    try
    {
      HttpSession session=request.getSession();
      SolmrLogger.debug(this,"umaClient="+umaClient);
      String idStr= (String) request.getParameter("idGenereMacchina");
      Long idGenereMacchina=null;
      try
      {
        idGenereMacchina=new Long(idStr);
        session.setAttribute("idGenereMacchina",idGenereMacchina);
      }
      catch(Exception e)
      {
        if (checkPageFrom(request))
        {
          idGenereMacchina=(Long)session.getAttribute("idGenereMacchina");
        }
        else
        {
          session.removeAttribute("idGenereMacchina");
        }
      }
      SolmrLogger.debug(this,"idGenereMacchina="+idGenereMacchina);
      SolmrLogger.debug(this,"idStr="+idStr);
      Vector macchine=umaClient.getElencoMacchineByIdDittaUma(idDittaUma,new Boolean(true),idGenereMacchina);
      request.setAttribute("idGenereMacchinaLong",idGenereMacchina);
      request.setAttribute("elencoMacchine",macchine);
      Vector tipiGenereMacchina=umaClient.getTipiGenereMacchina();
      request.setAttribute("tipiGenereMacchina",tipiGenereMacchina);
    }
    catch(Exception e)
    {
      throwValidation(e.getMessage(),validateUrl);
    }
  }
private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException("Eccezione : "+msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}
private boolean checkPageFrom(HttpServletRequest request)
{
  String referer=request.getHeader("Referer");
  SolmrLogger.debug(this,"Referer="+referer);
  if (referer==null)
  {
    return false;
  }
  for(int i=0;i<elencoPagine.length;i++)
  {
    if (referer.endsWith(elencoPagine[i]))
    {
      return true;
    }
  }
  return request.getSession().getAttribute("eliminaVar")!=null;
}
%>