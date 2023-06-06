<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.uma.FrmControlliPraticaVO" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.Htmpl" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  public static final String LAYOUT = "/domass/layout/controlli.htm";
%>
<%
  SolmrLogger.info(this, " - controlliErroreView.jsp - INIZIO PAGINA");

  it.csi.solmr.dto.uma.DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);

      // A causa del fatto che questa pagina ha il menu della assegnazione base
    // ma è inserita nel CU del dettaglio azienda (che è di pertinenza di un
    // altro menu) viene cambiata al volo la classe Autorizzazione per
    // permettere l'utilizzo del gestore di menu corretto.
    it.csi.solmr.presentation.security.Autorizzazione autAssegnazioneBase=
    (it.csi.solmr.presentation.security.Autorizzazione)
    it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ASSEGNAZIONE_BASE");
    request.setAttribute("__autorizzazione",autAssegnazioneBase);

%><%@include file = "/include/menu.inc" %><%
  Hashtable common = (Hashtable) session.getAttribute("common");
  String risCreazione = (String) common.get("risCreazione");
  String msgCreazione = (String) common.get("msgCreazione");

  SolmrLogger.debug(this, "msgCreazione: "+msgCreazione);  
  if(Validator.isNotEmpty(msgCreazione)){
    htmpl.newBlock("blkMsgCreazione");
    htmpl.set("blkMsgCreazione.msgCreazione", msgCreazione,null);
  } 
  
  SolmrLogger.info(this, " - controlliErroreView.jsp - FINE PAGINA");
%>
<%= htmpl.text()%>
