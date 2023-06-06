<%@ page language="java"
         contentType="text/html"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<jsp:useBean id="assegnazioneCarburanteVO" scope="request"
 class="it.csi.solmr.dto.uma.AssegnazioneCarburanteVO">
</jsp:useBean>
<%!
  private static final String LAYOUT_PAGE="/domass/layout/verificaAssegnazioneSupplementareTrasmessa.htm";
%>
<%
  SolmrLogger.debug(this,"verificaAssegnazioneTrasmessaView.jsp -  INIZIO PAGINA");
  Long idDittaUma=(Long)session.getAttribute("idDittaUma");
  ValidationErrors errors = new ValidationErrors();
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  Htmpl htmpl = HtmplFactory.getInstance(application)
              .getHtmpl(LAYOUT_PAGE);
// Il menu deve essere quello di assegnazione supplemento anche se la pagina è
// parte di un CU differente
  request.setAttribute("__autorizzazione",it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ASSEGNAZIONE_SUPPLEMENTO"));
%><%@include file = "/include/menu.inc" %><%

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  htmpl.set("annoCorrente",""+DateUtils.getCurrentYear());
  try
  {
    htmpl.set("dataRiferimento",DateUtils.formatDate(assegnazioneCarburanteVO.getDataAssegnazione()));
  }
  catch(Exception e)
  {
    // Dovrebbe avvenire soltanto nel caso di errore nel controller... Non
    // faccio nulla in quanto viene visualizzato l'alert "si è verificato un
    // errore di sistema"
  }
  htmpl.set("idDomAss",(String)request.getParameter("idDomandaAssegnazione"));
  SolmrLogger.debug(this,"verificaAssegnazioneTrasmessaView.jsp -  FINE PAGINA");
  if (request.getAttribute("idAssCarb")!=null)
  {
    htmpl.set("idAssCarb",request.getAttribute("idAssCarb").toString());
  }
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
%>
<%=htmpl.text()%>