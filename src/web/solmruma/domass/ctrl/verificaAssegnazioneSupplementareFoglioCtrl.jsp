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

<%

  String iridePageName = "verificaAssegnazioneSupplementareFoglioCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  SolmrLogger.debug(this, "   BEGIN verificaAssegnazioneSupplementareFoglioCtrl");
  
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  String visualValidazioneDomandaUrl = "/domass/ctrl/verificaAssegnazioneSupplementareValidataCtrl.jsp";
  String layoutViewUrl = "/domass/view/verificaAssegnazioneSupplementareFoglioView.jsp";
  String confermaUrl = "/domass/ctrl/confermaCreazioneFoglioRigaAssSupplCtrl.jsp";
  String elencoDomAssUrl = "../ctrl/dettaglioAssegnazioniSupplementareCtrl.jsp";

  if( session.getAttribute("frmAssegnazioneSupplementareVO")!=null ){
    FrmAssegnazioneSupplementareVO frmAssegnazioneSupplementareVO =
        (FrmAssegnazioneSupplementareVO) session.getAttribute("frmAssegnazioneSupplementareVO");
    session.setAttribute("frmAssegnazioneSupplementareVO", frmAssegnazioneSupplementareVO);
  }

  try{
    Long idDomAss=null;
    if ( request.getParameter("idDomAss") != null){
      SolmrLogger.debug(this,"request.getParameter(\"idDomAss\") != null");
      idDomAss = new Long( request.getParameter("idDomAss") );
    }
    else{
      if ( request.getAttribute("idDomAss") != null){
        SolmrLogger.debug(this,"request.getAttribute(\"idDomAss\") != null");
        idDomAss = ( (Long) request.getAttribute("idDomAss") );
      }
    }
    SolmrLogger.debug(this,"idDomAss: " + idDomAss);

    if(request.getParameter("avanti.x") != null){
      SolmrLogger.debug(this,"\\\\\\\\\\Conferma");

      //Restituito dalla pagina VerificaAssegnazioneSalvataBO.jsp
      //Associazione/modifica del foglio riga per l'utente

      SolmrLogger.debug(this,"Prima Forward conferma: "+confermaUrl);
      %>
        <jsp:forward page ="<%=confermaUrl%>" />
      <%
      }

      SolmrLogger.debug(this,"\n\n\n\n**********************************");
      SolmrLogger.debug(this,"\\\\\\\\\\Elenco Fogli Riga");
      SolmrLogger.debug(this,"ruoloUtenza.getIdUtente(): "+ruoloUtenza.getIdUtente());

      DittaUMAVO dittaUmaVO = umaFacadeClient.findByPrimaryKey(idDittaUma);
      NumerazioneFoglioVO numFoglioVOUtente = umaFacadeClient.findNumerazioneFoglioByUtente(ruoloUtenza, dittaUmaVO.getExtProvinciaUMA());
      SolmrLogger.debug(this,"Dopo umaFacadeClient.findNumerazioneFoglioByUtente(ruoloUtenza.getIdUtente())");

      if ( numFoglioVOUtente!=null ){
        SolmrLogger.debug(this,"numFoglioVOUtente!=null");
        //Se l'utente ha associato un proprio foglio riga
        SolmrLogger.debug(this,"numFoglioVOUtente.getNumeroFoglio(): "+numFoglioVOUtente.getNumeroFoglio());
        SolmrLogger.debug(this,"numFoglioVOUtente.getNumeroRiga(): "+numFoglioVOUtente.getNumeroRiga());

        //Associazione/modifica del foglio riga per l'utente
        //Long idAssegnazioneCarburante = new Long(request.getParameter("idAssCarb"));
        Long idNumerazioneFoglio = numFoglioVOUtente.getIdNumerazioneFoglio();
        SolmrLogger.debug(this,"idNumerazioneFoglio: "+numFoglioVOUtente.getIdNumerazioneFoglio());
        Boolean createNew = new Boolean("False");

        Boolean valida = new Boolean(true);
        FrmAssegnazioneSupplementareVO frmAssegnazioneSupplementareVO=null;
        if ( request.getParameter("pageFrom") != null){
          SolmrLogger.debug(this,"request.getParameter(\"pageFrom\") != null");
          if ( request.getParameter("pageFrom").equalsIgnoreCase("cessaDittaUma")){
            //Arrivo dalla Cessazione Ditta Uma
            valida=new Boolean(false);
          }
          else{
            //Arrivo dalla Verifica Assegnazione
            valida=new Boolean(true);
            Object commonObj=session.getAttribute("common");
            if (commonObj==null || !(commonObj instanceof FrmAssegnazioneSupplementareVO) )
            {
              SolmrLogger.debug(this, "--- Problemi sugli oggetti in sessione");
              response.sendRedirect(elencoDomAssUrl);
              return;
            }
            SolmrLogger.debug(this,"Recupero il FrmVerificaAssegnazioneVO dalla session, passato dalla confermaValidazioneDomandaCrl.jsp");
            //Recupero il FrmVerificaAssegnazioneVO dalla session, passato dalla confermaValidazioneDomandaCrl.jsp
            frmAssegnazioneSupplementareVO = (FrmAssegnazioneSupplementareVO) session.getAttribute("common");
          }
        }
        SolmrLogger.debug(this,"valida: "+valida);

        FrmVerificaAssegnazioneVO frmVerificaAssegnazioneVO = new FrmVerificaAssegnazioneVO();

        Long idAssegnazioneCarburante = umaFacadeClient.getIdAssCarbAnnoCorrenteByIdDittaUma(idDittaUma);
        frmAssegnazioneSupplementareVO.setIdAssCarbLong(idAssegnazioneCarburante);

        SolmrLogger.debug(this,"\n\n\n---------------------------");
        SolmrLogger.debug(this,"idDomAss: "+idDomAss);
        SolmrLogger.debug(this,"idNumerazioneFoglio: "+idNumerazioneFoglio);
        SolmrLogger.debug(this,"ruoloUtenza.getIdUtente(): "+ruoloUtenza.getIdUtente());
        SolmrLogger.debug(this,"ruoloUtenza.getIstatProvincia()(): "+ruoloUtenza.getIstatProvincia());
        SolmrLogger.debug(this,"idAssegnazioneCarburante: "+idAssegnazioneCarburante);
        SolmrLogger.debug(this,"createNew: "+createNew);

        SolmrLogger.debug(this,"\n\n\n***************frmAssegnazioneSupplementareVO");
        SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getAssSupplContoProprioGasolio(): "+frmAssegnazioneSupplementareVO.getAssSupplContoProprioGasolio());
        SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getAssSupplContoProprioBenzina(): "+frmAssegnazioneSupplementareVO.getAssSupplContoProprioBenzina());
        SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getAssSupplContoTerziGasolio(): "+frmAssegnazioneSupplementareVO.getAssSupplContoTerziGasolio());
        SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getAssSupplContoTerziBenzina(): "+frmAssegnazioneSupplementareVO.getAssSupplContoTerziBenzina());
        SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getAssSupplRiscSerraGasolio(): "+frmAssegnazioneSupplementareVO.getAssSupplRiscSerraGasolio());
        SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getAssSupplRiscSerraBenzina(): "+frmAssegnazioneSupplementareVO.getAssSupplRiscSerraBenzina());

        SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getIdDomandaAssegnazione(): "+frmAssegnazioneSupplementareVO.getIdDomandaAssegnazione());
        SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getIdAssCarb(): "+frmAssegnazioneSupplementareVO.getIdAssCarb());

        SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getTipiSupplemento(): "+frmAssegnazioneSupplementareVO.getTipiSupplemento());
        SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getMotivazioneSupplemento(): "+frmAssegnazioneSupplementareVO.getMotivazioneSupplemento());
        SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getExtIdIntermediario(): "+frmAssegnazioneSupplementareVO.getExtIdIntermediario());

        SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getNumeroDoc(): "+frmAssegnazioneSupplementareVO.getNumeroDoc());
        SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getDataConsegnaDoc(): "+frmAssegnazioneSupplementareVO.getDataConsegnaDoc());


        frmVerificaAssegnazioneVO.setAssNettaContoProprioGasolio(frmAssegnazioneSupplementareVO.getAssSupplContoProprioGasolio());
        frmVerificaAssegnazioneVO.setAssNettaContoProprioBenzina(frmAssegnazioneSupplementareVO.getAssSupplContoProprioBenzina());
        frmVerificaAssegnazioneVO.setAssNettaContoTerziGasolio(frmAssegnazioneSupplementareVO.getAssSupplContoTerziGasolio());
        frmVerificaAssegnazioneVO.setAssNettaContoTerziBenzina(frmAssegnazioneSupplementareVO.getAssSupplContoTerziBenzina());
        frmVerificaAssegnazioneVO.setAssNettaRiscSerraGasolio(frmAssegnazioneSupplementareVO.getAssSupplRiscSerraGasolio());
        frmVerificaAssegnazioneVO.setAssNettaRiscSerraBenzina(frmAssegnazioneSupplementareVO.getAssSupplRiscSerraBenzina());
        frmVerificaAssegnazioneVO.setIdDomandaassegnazione(frmAssegnazioneSupplementareVO.getIdDomandaAssegnazioneLong());
        frmVerificaAssegnazioneVO.setIdAssCarb(frmAssegnazioneSupplementareVO.getIdAssCarb());
        frmVerificaAssegnazioneVO.setTipiSupplemento(frmAssegnazioneSupplementareVO.getTipiSupplemento());
        frmVerificaAssegnazioneVO.setMotivazioneSupplemento(frmAssegnazioneSupplementareVO.getMotivazioneSupplemento());
        frmVerificaAssegnazioneVO.setExtIdIntermediario(frmAssegnazioneSupplementareVO.getExtIdIntermediarioLong());
        frmVerificaAssegnazioneVO.setIdAssCarb(frmAssegnazioneSupplementareVO.getIdAssCarb());

        frmVerificaAssegnazioneVO.setNumeroDoc(frmAssegnazioneSupplementareVO.getNumeroDoc());
        frmVerificaAssegnazioneVO.setDataConsegnaDoc(frmAssegnazioneSupplementareVO.getDataConsegnaDoc());
        
        frmVerificaAssegnazioneVO.setNumeroSupplemento(frmAssegnazioneSupplementareVO.getNumeroSupplemento());


        SolmrLogger.debug(this,"\n\n\n***************frmVerificaAssegnazioneVO");
        SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getAssNettaContoProprioGasolio(): "+frmVerificaAssegnazioneVO.getAssNettaContoProprioGasolio());
        SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getAssNettaContoProprioBenzina(): "+frmVerificaAssegnazioneVO.getAssNettaContoProprioBenzina());
        SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getAssNettaContoTerziGasolio(): "+frmVerificaAssegnazioneVO.getAssNettaContoTerziGasolio());
        SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getAssNettaContoTerziBenzina(): "+frmVerificaAssegnazioneVO.getAssNettaContoTerziBenzina());
        SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getAssNettaRiscSerraGasolio(): "+frmVerificaAssegnazioneVO.getAssNettaRiscSerraGasolio());
        SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getAssNettaRiscSerraBenzina(): "+frmVerificaAssegnazioneVO.getAssNettaRiscSerraBenzina());

        SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getIdDomandaassegnazione(): "+frmVerificaAssegnazioneVO.getIdDomandaassegnazione());
        SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getIdAssCarb(): "+frmVerificaAssegnazioneVO.getIdAssCarb());

        SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getTipiSupplemento(): "+frmVerificaAssegnazioneVO.getTipiSupplemento());
        SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getMotivazioneSupplemento(): "+frmVerificaAssegnazioneVO.getMotivazioneSupplemento());
        SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getExtIdIntermediario(): "+frmVerificaAssegnazioneVO.getExtIdIntermediario());

        SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getNumeroDoc(): "+frmVerificaAssegnazioneVO.getNumeroDoc());
        SolmrLogger.debug(this,"frmVerificaAssegnazioneVO.getDataConsegnaDoc(): "+frmVerificaAssegnazioneVO.getDataConsegnaDoc());
        
        SolmrLogger.debug(this," -- numeroSupplemento da inserire ="+frmVerificaAssegnazioneVO.getNumeroSupplemento());

        idAssegnazioneCarburante = new Long(-1);        
        SolmrLogger.debug(this, "---------------- updateNumerazioneFoglio ---------");
        FogliRigaVO foglioRiga = umaFacadeClient.updateNumerazioneFoglio(idDittaUma, idDomAss, idNumerazioneFoglio, ruoloUtenza,
            idAssegnazioneCarburante, createNew, new Boolean(false), frmVerificaAssegnazioneVO);
        session.removeAttribute("common");

        SolmrLogger.debug(this,"confermaUrl: "+confermaUrl);
        SolmrLogger.debug(this," -- visualValidazioneDomandaUrl: "+visualValidazioneDomandaUrl);
    %>
      <jsp:forward page ="<%=visualValidazioneDomandaUrl%>" />
    <%
      }else{
      SolmrLogger.debug(this,"numFoglioVOUtente==null");
      //Se l'utente non ha associato un proprio foglio riga

      //Visualizzazione elenco Fogli per la provincia selezionata
      SolmrLogger.debug(this,"Visualizzazione elenco Fogli per la provincia selezionata");
      SolmrLogger.debug(this,"ruoloUtenza.getIstatProvincia(): "+ruoloUtenza.getIstatProvincia());
      Vector numFogliResult = umaFacadeClient.findNumerazioneFoglioByProvincia(dittaUmaVO.getExtProvinciaUMA());
      request.setAttribute("numFogliResult", numFogliResult);

      %>
        <jsp:forward page ="<%=layoutViewUrl%>" />
      <%
    }
  }
  catch(Exception e){
    SolmrLogger.error(this, "-- Exception in verificaAssegnazioneSupplementareFoglioCtrl ="+e.getMessage());
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
  finally{
    SolmrLogger.debug(this, "   END verificaAssegnazioneSupplementareFoglioCtrl");
  }  
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
    SolmrLogger.debug(this,"\n\n\n\n\n\n\n\n\n\n\nmsg="+msg+"\n\n\n\n\n\n\n\n");
    ValidationErrors errors=new ValidationErrors();
    errors.add("error", new ValidationError(msg));
    request.setAttribute("errors",errors);
  }
%>
