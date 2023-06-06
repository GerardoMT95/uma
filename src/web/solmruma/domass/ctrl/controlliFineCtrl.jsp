<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.client.uma.UmaFacadeClient" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO" %>
<%@ page import="it.csi.solmr.dto.uma.DomandaAssegnazione" %>
<%@ page import="it.csi.solmr.util.DateUtils" %>
<%@ page import="java.util.*" %>

<%!
  public final static String VIEW = "../view/controlliFineView.jsp";
  public final static String ASSEGNAZIONE_BASE = "../layout/assegnazioneBase.htm";
  public final static String ASSEGNAZIONE_SUPPLEMENTARE = "../layout/assegnazioneSupplementare.htm";
%>

<%

  String iridePageName = "controlliFineCtrl.jsp";
  request.setAttribute("noCheckIntermediario","TRUE");
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.info(this, " - controlliCtrl.jsp - INIZIO PAGINA");

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

  Long idDittaUma = dittaVO.getIdDittaUMA();
  Hashtable common = (Hashtable) session.getAttribute("common");
  SolmrLogger.debug(this, "common: "+common);
  String notifica = (String) common.get("notifica");
  SolmrLogger.debug(this, "notifica: "+notifica);

  //Long annoAssegnazione = new Long(DateUtils.extractYearFromDate(domandaAssegnazione.getDataRiferimento()));
  Long annoAssegnazione=null;
  if(notifica==null){
    //notifica=null (controlli.x)
    Long idDomandaAssegnazione = (Long) common.get("idDomandaAssegnazione");
    SolmrLogger.debug(this, "idDomandaAssegnazione: "+idDomandaAssegnazione);
    DomandaAssegnazione domandaAssegnazione = umaFacadeClient.findDomAssByPrimaryKey(idDomandaAssegnazione);
    SolmrLogger.debug(this, "domandaAssegnazione: "+domandaAssegnazione);
    Date dataAssegnazione = domandaAssegnazione.getDataRiferimento();
    SolmrLogger.debug(this, "dataAssegnazione: "+dataAssegnazione);

    annoAssegnazione = new Long(DateUtils.extractYearFromDate(dataAssegnazione));
  }
  else{
    //notifica=base - notifica=supplementare
    annoAssegnazione = new Long(DateUtils.extractYearFromDate(new Date()));
  }
  SolmrLogger.debug(this, "annoAssegnazione: "+annoAssegnazione);

  ValidationErrors errors = new ValidationErrors();

  try
  {
    //L'utente ha selezionato la funzionalità "controlli" sul procedimento scelto

    //Elenco dei controlli effettuati sulla pratica con gli errori riscontrati
    SolmrLogger.debug(this, "Before findData()");
    findData(request, umaFacadeClient, idDittaUma, annoAssegnazione, notifica);
    SolmrLogger.debug(this, "After findData()");

  }
  catch(Exception exc)
  {
    common = (Hashtable)session.getAttribute("common");
    if(common==null){
      common = new Hashtable();
    }
    common.put("msgCreazione", exc.getMessage());
    session.setAttribute("common", common);
    %><jsp:forward page="<%=VIEW%>"/><%
  }

  Vector vErroriControlli = (Vector) request.getAttribute("vErroriControlli");

  //@@todo da Rimuovere - Begin
  //vErroriControlli = null;
  //@@todo da Rimuovere - End
  if(vErroriControlli!=null && vErroriControlli.size()>0){
    SolmrLogger.debug(this, "if(vErroriControlli!=null && vErroriControlli.size()>0)");
    %><jsp:forward page="<%=VIEW%>"/><%
  }
  else{
    SolmrLogger.debug(this, "else(vErroriControlli!=null && vErroriControlli.size()>0)");
    if(notifica!=null){
      SolmrLogger.debug(this, "if(notifica!=null)");
      if(notifica.equalsIgnoreCase("base")){
        SolmrLogger.debug(this, "if(notifica.equalsIgnoreCase(\"base\"))");
        response.sendRedirect(ASSEGNAZIONE_BASE);
        return;
      }
      else{
        SolmrLogger.debug(this, "else(notifica.equalsIgnoreCase(\"base\"))");
        if ( (notifica.equalsIgnoreCase("supplementare")) || (notifica.equalsIgnoreCase("supplementareMaggiorazione"))){        	
          SolmrLogger.debug(this, "if(notifica.equalsIgnoreCase(\"supplementare\"))");
          response.sendRedirect(ASSEGNAZIONE_SUPPLEMENTARE);
          return;
        }
      }
    }
  }

  SolmrLogger.info(this, " - controlliCtrl.jsp - FINE PAGINA");
%>

<%!
  private void findData(HttpServletRequest request, UmaFacadeClient umaFacadeClient, Long idDittaUma, Long annoAssegnazione, String notifica) throws Exception
  {
    Vector vErroriControlli = null;

    //Elenco controlli
    SolmrLogger.debug(this, "notifica: "+notifica);
    if(notifica==null){
      SolmrLogger.debug(this, "if(notifica==null)");
      vErroriControlli = umaFacadeClient.getErroriControlliAttivati(idDittaUma, annoAssegnazione);
    }
    else{
      SolmrLogger.debug(this, "else(notifica==null)");
      vErroriControlli = umaFacadeClient.getErroriControlliNegativi(idDittaUma, annoAssegnazione);
    }
    SolmrLogger.debug(this, "\n\n\n\n\n**********************\n\n\n\n\n");
    SolmrLogger.debug(this, "vErroriControlli: "+vErroriControlli);
    SolmrLogger.debug(this, "vErroriControlli.size(): "+vErroriControlli.size());
    request.setAttribute("vErroriControlli", vErroriControlli);
  }
%>