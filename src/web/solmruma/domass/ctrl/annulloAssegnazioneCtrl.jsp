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
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%!
  String layoutViewUrl = "/domass/view/annulloAssegnazioneView.jsp";
  String confermaUrl = "/domass/ctrl/assegnazioniCtrl.jsp";
  String elencoStoricoUrl = "/domass/view/assegnazioniView.jsp";
  public static final String ASSEGNAZIONE_ACCONTO_VALIDATA="/domass/ctrl/verificaAssegnazioneAccontoValidataCtrl.jsp";
%>

<%
  //Flag per disabilitare controllo autorizzazione abilitazioni IRIDE AssegnazioneBaseCU.hasCompetenzaDato()
  final String DISABILITA_INTERMEDIARIO = "";
  request.setAttribute("noCheckIntermediario", DISABILITA_INTERMEDIARIO);
  // Flag per abilitare controllo anullamento domande validate PA abilitazioni IRIDE AssegnazioneBaseCU.hasCompetenzaDato()
  // final String NO_ANNULLA_DOMANDE_VALIDATE_PA = "NO_ANNULLA_DOMANDE_VALIDATE_PA";
  // request.setAttribute("noAnullaDomandeValidatePA", NO_ANNULLA_DOMANDE_VALIDATE_PA);
  // 11/12/2008 EINAUDI: RIMOSSO noAnullaDomandeValidatePA IL CU ora è specifico per l'annulla e fa i controlli ad hoc
  String iridePageName = "annulloAssegnazioneCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

Long idDomAss=null;
DomandaAssegnazione da=null;
try
{
  SolmrLogger.debug(this,"- annulloAssegnazioneCtrl.jsp -  INIZIO PAGINA");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  String annullaBuoniUrl = "/domass/ctrl/verificaAssegnazioneValidataCtrl.jsp";
  String elencoDomandeUrl = "/domass/ctrl/assegnazioniCtrl.jsp";
  String dettaglioDomandaUrl = "/domass/ctrl/dettagliodomandaCtrl.jsp";
  String dettaglioVerificaAssegnazioneUrl = "/domass/ctrl/dettaglioVerificaAssegnazioneCtrl.jsp";
  String dettaglioAssegnazioniSupplementareUrl = "/domass/ctrl/dettaglioAssegnazioniSupplementareCtrl.jsp";
  String carburanteAssegnabileUrl = "/domass/ctrl/carburanteAssegnabileCtrl.jsp";
  String annullaUrl = "../layout/verificaAssegnazioneSalvataBO.htm";

  if ( request.getParameter("idDomAss") != null){
      SolmrLogger.debug(this,"request.getParameter(\"idDomAss\") == null");
      idDomAss = new Long( request.getParameter("idDomAss") );
  }
  SolmrLogger.debug(this,"idDomAss: " + idDomAss);


  if(request.getParameter("annullaAss.x") != null){
    SolmrLogger.debug(this,"\\\\\\\\\\annulla");
    if ( request.getParameter("annullaBuoni") != null){
     SolmrLogger.debug(this,"annullaBuoniUrl: "+annullaBuoniUrl);
      if ( request.getParameter("annullaBuoni").equalsIgnoreCase("OK")){
        //Verifica AssegnazioneBase Salvata BO
        SolmrLogger.debug(this,"request.getParameter(\"annullaBuoni\").equalsIgnoreCase(\"OK\")");
        %>
          <jsp:forward page ="<%=annullaBuoniUrl%>" />
        <%
        return;
      }
      else{
        if ( request.getParameter("annullaBuoni").equalsIgnoreCase("elencoDomande")){
          //Elenco assegnazioni
          SolmrLogger.debug(this,"request.getParameter(\"annullaBuoni\").equalsIgnoreCase(\"elencoDomande\")");
          %>
            <jsp:forward page ="<%=elencoDomandeUrl%>" />
          <%
          return;
        }
        else{
          if ( request.getParameter("annullaBuoni").equalsIgnoreCase("dettaglioDomanda")){
            //Dettaglio domanda
            SolmrLogger.debug(this,"request.getParameter(\"annullaBuoni\").equalsIgnoreCase(\"dettaglioDomanda\")");
            %>
              <jsp:forward page ="<%=dettaglioDomandaUrl%>" />
            <%
            return;
          }
          else
          {
            if ( request.getParameter("annullaBuoni").equalsIgnoreCase("dettaglioVerificaAssegnazione")){
              //Dettaglio Verifica Assegnazioni
              SolmrLogger.debug(this,"request.getParameter(\"annullaBuoni\").equalsIgnoreCase(\"dettaglioVerificaAssegnazione\")");
              %>
                <jsp:forward page ="<%=dettaglioVerificaAssegnazioneUrl%>" />
              <%
              return;
            }
            else
            {
              if ( request.getParameter("annullaBuoni").equalsIgnoreCase("dettaglioAssegnazioniSupplementari")){
                //Dettaglio Assegnazioni Supplementare
                SolmrLogger.debug(this,"request.getParameter(\"annullaBuoni\").equalsIgnoreCase(\"dettaglioAssegnazioniSupplementare\")");
                %>
                  <jsp:forward page ="<%=dettaglioAssegnazioniSupplementareUrl%>" />
                <%
                return;
              }
              else
              {
                if ( request.getParameter("annullaBuoni").equalsIgnoreCase("carburanteAssegnabile")){
                SolmrLogger.debug(this,"request.getParameter(\"annullaBuoni\").equalsIgnoreCase(\"carburanteAssegnabile\")");
                %>
                  <jsp:forward page ="<%=carburanteAssegnabileUrl%>" />
                <%
                return;
                }
                else
                {
	                if ( request.getParameter("annullaBuoni").equalsIgnoreCase("acconto")){
	                %>
	                  <jsp:forward page ="<%=ASSEGNAZIONE_ACCONTO_VALIDATA%>" />
	                <%
	                return;
	                }
	                else
	                {
		                if ( request.getParameter("annullaBuoni").equalsIgnoreCase("salvataBO"))
						{
						%>
						  <jsp:forward page ="<%=annullaUrl%>" />
						<%
						return;
						}
						else
						{
						  SolmrLogger.debug(this,"!request.getParameter(\"annullaBuoni\").equalsIgnoreCase(\"OK\")");
						  SolmrLogger.debug(this,"annullaUrl: "+annullaUrl);
						  //response.sendRedirect(annullaUrl);
						  %>
							<jsp:forward page ="<%=elencoDomandeUrl%>" />
						  <%
    					}
                    } 
                }
              }
            }
          }
        }
      }
    }
  }


  if(request.getParameter("conferma.x") != null){
    SolmrLogger.debug(this,"\\\\\\\\\\Conferma");

    ValidationErrors errors = new ValidationErrors();
    String motivazione="";
    if ( request.getParameter("note") != null){
      motivazione = request.getParameter("note");
      SolmrLogger.debug(this,"motivazione: "+motivazione);

      if (motivazione!=null && motivazione.length()==0)
      {
        SolmrLogger.debug(this,"motivazione!=null && motivazione.length()==0");
        errors.add("note",new ValidationError(""+UmaErrors.get("INSERT_MOTIVO_ANNULLAMENTO")));
      }
      if (motivazione!=null && motivazione.length()>512)
      {
        SolmrLogger.debug(this,"motivazione!=null && motivazione.length()>512");
        errors.add("note",new ValidationError(""+UmaErrors.get("MAX_512_CHAR")));
      }
      if (errors.size()!=0){
        SolmrLogger.debug(this,"      if (errors!=null)");
        da = (DomandaAssegnazione) umaFacadeClient.findDomAssByPrimaryKey(idDomAss);
        da.setNote(motivazione);
        SolmrLogger.debug(this,"      dopo umaFacadeClient.findDomAssByPrimaryKey");
        request.setAttribute("DomandaAssegnazione",da);
        SolmrLogger.debug(this,"errors: "+errors);
        SolmrLogger.debug(this,"errors.size(): "+errors.size());
        request.setAttribute("errors",errors);
        %>
          <jsp:forward page ="<%=layoutViewUrl%>" />
        <%
      }

    }
    SolmrLogger.debug(this,"Dopo request.getParameter(\"note\") != null");

    da = umaFacadeClient.findDomAssByPrimaryKey(idDomAss);
    da.setNote(motivazione);
    da.setUtenteAggiornamento( ruoloUtenza.getIdUtente().intValue() );

    CodeDescr cdDomAss = new CodeDescr();
    cdDomAss.setCode(new Integer(SolmrConstants.ID_STATO_DOMANDA_ANNULLATA));
    cdDomAss.setDescription(SolmrConstants.DESC_STATO_DOMANDA_ANNULLATA);
    da.setStatoDomanda(cdDomAss);

    SolmrLogger.debug(this, "umaFacadeClient.annullaDomandaAssegnazione ("+da.getIdDomandaAssegnazione()+", "+ idDittaUma+", "+ da.getNote()+", "+ ruoloUtenza+")");

      SolmrLogger.debug(this, "da.getIdDomandaAssegnazione(): "+da.getIdDomandaAssegnazione());
      SolmrLogger.debug(this, "idDittaUma: "+idDittaUma);
      SolmrLogger.debug(this, "da.getNote(): "+da.getNote());
      SolmrLogger.debug(this, "ruoloUtenza.getIdUtente(): "+ruoloUtenza.getIdUtente());
      
	  int annoRiferimento = UmaDateUtils.extractYearFromDate(da.getDataRiferimento());	
	  SolmrLogger.debug(this, " -- annoRiferimento ="+annoRiferimento);
	      
      SolmrLogger.debug(this, "before call - annullaDomandaAssegnazione - annulloAssegnazioneCtrl");
      umaFacadeClient.annullaDomandaAssegnazione(da.getIdDomandaAssegnazione(), annoRiferimento, idDittaUma, da.getNote(), ruoloUtenza);
      SolmrLogger.debug(this, "after call - annullaDomandaAssegnazione - annulloAssegnazioneCtrl");

    %>
      <jsp:forward page ="<%=confermaUrl%>" />
    <%
    SolmrLogger.debug(this, "Prima Forward conferma: "+confermaUrl);
    return;

  }


  //Visualizzazione Note per la domanda Assegnazione
  SolmrLogger.debug(this, "Visualizzazione Note per la domanda Assegnazione");
  da = (DomandaAssegnazione) umaFacadeClient.findDomAssByPrimaryKey(idDomAss);
  request.setAttribute("DomandaAssegnazione",da);
  SolmrLogger.debug(this, "da.getIdDomandaAssegnazione(): "+da.getIdDomandaAssegnazione());

  %>
    <jsp:forward page ="<%=layoutViewUrl%>" />
  <%
  return;
}
catch(Exception e)
{
  SolmrLogger.debug(this, "catch - annullaDomandaAssegnazione - annulloAssegnazioneCtrl");
  SolmrLogger.debug(this, "e.getMessage()"+e.getMessage());
  request.setAttribute("DomandaAssegnazione",da);
  this.throwValidation(e.getMessage(),layoutViewUrl);
}
%>
<%!
  private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException("Errore: eccezione="+msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }
%>
