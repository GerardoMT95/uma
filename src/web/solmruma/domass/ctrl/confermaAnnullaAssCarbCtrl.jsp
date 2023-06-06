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
  private static final String PREV_CTRL="/domass/ctrl/dettaglioAssegnazioniSupplementareCtrl.jsp";
  private static final String VIEW="/domass/view/confermaAnnullaAssCarbView.jsp";
  private static final String NEXT_PAGE="../layout/dettaglioAssegnazioniSupplementare.htm";
  private static final Long IN_ATTESA_VALIDAZIONE_PA = new Long(20);
  private String PREV_PAGE="../layout/dettaglioAssegnazioniSupplementare.htm";
%>
<%

  String iridePageName = "confermaAnnullaAssCarbCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  UmaFacadeClient umaClient = new UmaFacadeClient();

  if(request.getParameter("pageFrom")!=null)
  {
    SolmrLogger.debug(this,"if(request.getParameter(\"pageFrom\")!=null)");
    PREV_PAGE=request.getParameter("pageFrom");
  }
  else{
    SolmrLogger.debug(this,"else(request.getParameter(\"pageFrom\")!=null)");
    PREV_PAGE=(String) session.getAttribute("pageFrom");
  }
  SolmrLogger.debug(this,"\n\n\n\n\n*+*+*+*+*+*+*+**+*+*+*");
  SolmrLogger.debug(this,"PREV_PAGE: "+PREV_PAGE);

SolmrLogger.debug(this,"confermaAnnullaAssCarbCtrl - session.getAttribute(\"idAssCarb\") "+session.getAttribute("idAssCarb"));

  Long idAssCarb = null;

if(session.getAttribute("idAssCarb")!= null)
{
  idAssCarb = (Long)session.getAttribute("idAssCarb");
  session.removeAttribute("idAssCarb");
}
else if(request.getParameter("idAssCarb")!=null)
{
  idAssCarb = new Long(request.getParameter("idAssCarb"));
}

request.setAttribute("idAssCarb", idAssCarb);

SolmrLogger.debug(this,"#################################################################");
SolmrLogger.debug(this,"confermaAnnullaAssCarbCtrl - request.getAttribute(\"idAssCarb\") "+request.getAttribute("idAssCarb"));
SolmrLogger.debug(this,"confermaAnnullaAssCarbCtrl - idAssCarb "+idAssCarb);
SolmrLogger.debug(this,"#################################################################");

  SolmrLogger.debug(this,"session.getAttribute(\"idDomAss\"): "+session.getAttribute("idDomAss"));

  if (request.getParameter("conferma.x")!=null)
  {
    try
    {
      SolmrLogger.debug(this,"ANNULLAMENTO");
      umaClient.annullaAssegnazioneSuppl(idAssCarb, ruoloUtenza, idDittaUma);
      AssegnazioneCarburanteVO assCarbVO = umaClient.getAssegnazioneCarburante(idAssCarb);
      Long idDomAss = assCarbVO.getIdDomandaAssegnazione();

      SolmrLogger.debug(this,"idDomAss: "+idDomAss);
      session.setAttribute("idDomAss", idDomAss);
    }
    catch(Exception e)
    {
      throwValidation(e.getMessage(),PREV_CTRL);
    }

    response.sendRedirect(NEXT_PAGE);
    return;
  }
  if (request.getParameter("annulla.x")!=null)
  {
    SolmrLogger.debug(this,"#### annulla, ritorno alla pagina : "+PREV_PAGE);
    AssegnazioneCarburanteVO assCarbVO = umaClient.getAssegnazioneCarburante(idAssCarb);
    Long idDomAss = assCarbVO.getIdDomandaAssegnazione();

    SolmrLogger.debug(this,"idDomAss: "+idDomAss);
    session.setAttribute("idDomAss", idDomAss);

    response.sendRedirect(NEXT_PAGE);
    return;
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
