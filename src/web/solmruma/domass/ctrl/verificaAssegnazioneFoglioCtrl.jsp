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
<%@ page import="it.csi.solmr.dto.uma.FrmVerificaAssegnazioneVO" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%!
  private static String visualValidazioneDomandaUrl = "/domass/ctrl/verificaAssegnazioneValidataCtrl.jsp";
  private static String layoutViewUrl = "/domass/view/verificaAssegnazioneFoglioView.jsp";
  private static String confermaUrl = "/domass/ctrl/confermaCreazioneFoglioRigaCtrl.jsp";
  private static String elencoDomAssUrl = "../ctrl/assegnazioniCtrl.jsp";
%>
<%
  String iridePageName = "verificaAssegnazioneFoglioCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "BEGIN verificaAssegnazioneFoglioCtrl"); 
		   
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  try{
    /*DomandaAssegnazione da = umaFacadeClient.findDomandaAssegnazioneCorrente(idDittaUma);
    Long idDomAss = da.getIdDomandaAssegnazione();
    SolmrLogger.debug(this, "idDomAss: " + idDomAss);*/

    HashMap provincieValidazioneIntermediario = (HashMap) session.getAttribute("provincieValidazioneIntermediario");
    HashMap formeGiuridicheValidazionePA = (HashMap) session.getAttribute("formeGiuridicheValidazionePA");
    Long idFormaGiuridica = dittaUMAAziendaVO.getIdFormaGiuridica();

    FrmVerificaAssegnazioneVO frmVerificaAssegnazioneVO=
        umaFacadeClient.getVerificaAssegnazione(idDittaUma, provincieValidazioneIntermediario, idFormaGiuridica, formeGiuridicheValidazionePA);
    request.setAttribute("frmVerificaAssegnazioneVO",frmVerificaAssegnazioneVO);

    Long idDomAss = frmVerificaAssegnazioneVO.getIdDomandaassegnazione();
    SolmrLogger.debug(this, "idDomAss: " + idDomAss);

    SolmrLogger.debug(this, "frmVerificaAssegnazioneVO.getIdAssCarb(): " + frmVerificaAssegnazioneVO.getIdAssCarb());
    Long idAssegnazioneCarburante=new Long(frmVerificaAssegnazioneVO.getIdAssCarb());
    SolmrLogger.debug(this, "idAssegnazioneCarburante: " + idAssegnazioneCarburante);

    if(request.getParameter("avanti.x") != null){
      SolmrLogger.debug(this, "\\\\\\\\\\Conferma");

      //Restituito dalla pagina VerificaAssegnazioneSalvataBO.jsp
      //Associazione/modifica del foglio riga per l'utente

      SolmrLogger.debug(this, "Prima Forward conferma: "+confermaUrl);
      %>
        <jsp:forward page ="<%=confermaUrl%>" />
      <%
    }

    SolmrLogger.debug(this, "\n\n\n\n**********************************");
    SolmrLogger.debug(this, "\\\\\\\\\\Elenco Fogli Riga");
    SolmrLogger.debug(this, "ruoloUtenza.getIdUtente(): "+ruoloUtenza.getIdUtente());

    if(!ruoloUtenza.isUtenteIntermediario()){
      SolmrLogger.debug(this, "--- Utente NON intermediario");
      //Utente non intermediario
      DittaUMAVO dittaUmaVO = umaFacadeClient.findByPrimaryKey(idDittaUma);
      NumerazioneFoglioVO numFoglioVOUtente = umaFacadeClient.findNumerazioneFoglioByUtente(ruoloUtenza, dittaUmaVO.getExtProvinciaUMA());
      SolmrLogger.debug(this, "Dopo umaFacadeClient.findNumerazioneFoglioByUtente(profile.getIdUtente())");

      if ( numFoglioVOUtente!=null ){
        SolmrLogger.debug(this, "if( numFoglioVOUtente!=null )");
        SolmrLogger.debug(this, "numFoglioVOUtente!=null");
        //Se l'utente ha associato un proprio foglio riga
        SolmrLogger.debug(this, "numFoglioVOUtente.getNumeroFoglio(): "+numFoglioVOUtente.getNumeroFoglio());
        SolmrLogger.debug(this, "numFoglioVOUtente.getNumeroRiga(): "+numFoglioVOUtente.getNumeroRiga());

        //Associazione/modifica del foglio riga per l'utente
        //Long idAssegnazioneCarburante = new Long(request.getParameter("idAssCarb"));
        Long idNumerazioneFoglio = numFoglioVOUtente.getIdNumerazioneFoglio();
        SolmrLogger.debug(this, "idNumerazioneFoglio: "+numFoglioVOUtente.getIdNumerazioneFoglio());
        Boolean createNew = new Boolean("False");

        Boolean valida = new Boolean(true);
        //FrmVerificaAssegnazioneVO frmVerificaAssegnazioneVO=null;
        if ( request.getParameter("pageFrom") != null){
          SolmrLogger.debug(this, "request.getParameter(\"pageFrom\") != null");
          if ( request.getParameter("pageFrom").equalsIgnoreCase("cessaDittaUma")){
            //Arrivo dalla Cessazione Ditta Uma
            valida=new Boolean(false);
          }
          else{
            //Arrivo dalla Verifica Assegnazione
            valida=new Boolean(true);
            Object commonObj=session.getAttribute("common");
            if (commonObj==null || !(commonObj instanceof FrmVerificaAssegnazioneVO) )
            {
              response.sendRedirect(elencoDomAssUrl);
              return;
            }
            //Recupero il FrmVerificaAssegnazioneVO dalla session, passato dalla confermaValidazioneDomandaCrl.jsp
            frmVerificaAssegnazioneVO = (FrmVerificaAssegnazioneVO) session.getAttribute("common");
          }
        }
        SolmrLogger.debug(this, "valida: "+valida);

        FogliRigaVO foglioRiga = umaFacadeClient.updateNumerazioneFoglio(idDittaUma,idDomAss, idNumerazioneFoglio, ruoloUtenza, idAssegnazioneCarburante, createNew, new Boolean(true), frmVerificaAssegnazioneVO);
        session.removeAttribute("common");
        SolmrLogger.debug(this, " -- visualValidazioneDomandaUrl ="+visualValidazioneDomandaUrl);

        %>
          <jsp:forward page ="<%=visualValidazioneDomandaUrl%>" />
        <%
      }else{
        SolmrLogger.debug(this, "else( numFoglioVOUtente!=null )");
        //Se l'utente non ha associato un proprio foglio riga

        //Visualizzazione elenco Fogli per la provincia selezionata
        SolmrLogger.debug(this, "Visualizzazione elenco Fogli per la provincia selezionata");
        SolmrLogger.debug(this, " --- dittaUmaVO.getExtProvinciaUMA(): "+dittaUmaVO.getExtProvinciaUMA());
        Vector numFogliResult = umaFacadeClient.findNumerazioneFoglioByProvincia(dittaUmaVO.getExtProvinciaUMA());
        request.setAttribute("numFogliResult", numFogliResult);

		 SolmrLogger.debug(this, " -- layoutViewUrl ="+layoutViewUrl);
        %>
          <jsp:forward page ="<%=layoutViewUrl%>" />
        <%
      }
    }
    else{
      //Utente intermediario
      SolmrLogger.debug(this, "--- Utente intermediario ----- updateNumerazioneFoglioByIntermediario() ------");
      FogliRigaVO foglioRiga = umaFacadeClient.updateNumerazioneFoglioByIntermediario(idDittaUma, idAssegnazioneCarburante, ruoloUtenza);
      
      SolmrLogger.debug(this, " -- visualValidazioneDomandaUrl ="+visualValidazioneDomandaUrl);

      %>
        <jsp:forward page ="<%=visualValidazioneDomandaUrl%>" />
      <%
    }

  }
  catch(Exception e){
    if ( e instanceof SolmrException )
    {
      setError(request,e.getMessage());
    }
    else
    {
      e.printStackTrace();
      setError(request,"Si è verificato un errore di sistema");
    }
    %><jsp:forward page="<%=layoutViewUrl%>" /><%
  }
  SolmrLogger.debug(this, "- verificaAssegnazioneFoglioCtrl.jsp -  FINE PAGINA");
%>
<%!
  private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException("Errore: eccezione="+msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }

  private void setError(HttpServletRequest request, String msg)
  {
    SolmrLogger.debug(this, "\n\n\n\n\n\n\n\n\n\n\nmsg="+msg+"\n\n\n\n\n\n\n\n");
    ValidationErrors errors=new ValidationErrors();
    errors.add("error", new ValidationError(msg));
    request.setAttribute("errors",errors);
  }
  //Verifica che la stringa contenga un Long - Restituisce null
  protected Long checkLongNull(String val) {
    if (val==null) {
      return null;
    }
    return new Long(val);
  }
%>
