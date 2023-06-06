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
<%@ page import="it.csi.solmr.etc.anag.AnagErrors" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String iridePageName = "confermaCreazioneFoglioRigaAssSupplCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  Long idAssCarb=null;

  UmaFacadeClient umaClient = new UmaFacadeClient();
  String verificaAssegnazioneSupplementareValidataUrl="/domass/ctrl/verificaAssegnazioneSupplementareValidataCtrl.jsp";
  String cessaDittaUmaUrl="/domass/ctrl/cessaDitaUmaConfermaCtrl.jsp";
  String confermaCreazioneFoglioRigaUrl="/domass/ctrl/verificaAssegnazioneSupplementareValidataCtrl.jsp";
  String annullaCreazioneFoglioRigaUrl="/domass/ctrl/verificaAssegnazioneSupplementareFoglioCtrl.jsp";
  String viewUrl="/domass/view/confermaCreazioneFoglioRigaAssSupplView.jsp";
  String elencoDomAssUrl = "../ctrl/assegnazioniCtrl.jsp";
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  if( session.getAttribute("frmAssegnazioneSupplementareVO")!=null ){
    FrmAssegnazioneSupplementareVO frmAssegnazioneSupplementareVO =
        (FrmAssegnazioneSupplementareVO) session.getAttribute("frmAssegnazioneSupplementareVO");
    session.setAttribute("frmAssegnazioneSupplementareVO", frmAssegnazioneSupplementareVO);
    SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getAssSupplContoProprioGasolio(): "+frmAssegnazioneSupplementareVO.getAssSupplContoProprioGasolio());
    SolmrLogger.debug(this,"frmAssegnazioneSupplementareVO.getAssSupplContoProprioBenzina(): "+frmAssegnazioneSupplementareVO.getAssSupplContoProprioBenzina());
  }
  else{
    SolmrLogger.debug(this,"else( session.getAttribute(\"frmAssegnazioneSupplementareVO\")!=null )");
  }

  SolmrLogger.debug(this,"\n\n\n\n\n####################");
  SolmrLogger.debug(this,"request.getParameter(\"idDittaUma\"): "+request.getParameter("idDittaUma"));

  Long idDomAss=null;
  if (request.getParameter("idDomAss")!=null){
    SolmrLogger.debug(this,"request.getParameter(\"idDomAss\") != null");
    idDomAss=new Long(request.getParameter("idDomAss"));
    SolmrLogger.debug(this,"idDomAss: " + idDomAss);
  }

  Boolean valida = new Boolean(true);
  FrmAssegnazioneSupplementareVO frmAssegnazioneSupplementareVO=null;
  if ( request.getParameter("pageFrom") != null){
    SolmrLogger.debug(this,"request.getParameter(\"pageFrom\") != null");
    if ( request.getParameter("pageFrom").equalsIgnoreCase("cessaDittaUma")){
      //Arrivo dalla Cessazione Ditta Uma
      valida=new Boolean(false);
    }
  }
  else{
    //Arrivo dalla Verifica Assegnazione
    valida=new Boolean(true);
    Object commonObj=session.getAttribute("common");
    if (commonObj==null || !(commonObj instanceof FrmAssegnazioneSupplementareVO) )
    {
      response.sendRedirect(elencoDomAssUrl);
      return;
    }
    //Recupero il FrmAssegnazioneSupplementareVO dalla session, passato dalla confermaValidazioneAssegnazioneSupplementareCrl.jsp
    frmAssegnazioneSupplementareVO = (FrmAssegnazioneSupplementareVO) session.getAttribute("common");
  }

  SolmrLogger.debug(this,"valida: "+valida);

  if (request.getParameter("confermaCreazione.x")!=null)
  {
    SolmrLogger.debug(this,"confermaCreazione.x");
    try
    {
      SolmrLogger.debug(this,"request.getParameter(\"idDomAss\"): " + request.getParameter("idDomAss"));

      if ( request.getParameter("idAssCarb") != null){
        idAssCarb = new Long(request.getParameter("idAssCarb"));
        SolmrLogger.debug(this,"idAssCarb: "+idAssCarb);
      }

      Long idNumerazioneFoglio=null;
      if ( request.getParameter("idNumerazioneFoglio")!=null ){
        SolmrLogger.debug(this,"request.getParameter(\"idNumerazioneFoglio\")!=null");
        idNumerazioneFoglio = new Long(request.getParameter("idNumerazioneFoglio"));
      }else{
        SolmrLogger.debug(this,"request.getParameter(\"idNumerazioneFoglio\")==null");
      }

      Boolean createNew;
      if( idNumerazioneFoglio.longValue()==-1 ){
        SolmrLogger.debug(this,"idNumerazioneFoglio.longValue()==-1");
        createNew = new Boolean("true");
      }else{
        SolmrLogger.debug(this,"idNumerazioneFoglio.longValue()!=-1");
        createNew = new Boolean("false");
      }
      SolmrLogger.debug(this,"createNew: "+createNew);

      GregorianCalendar calendar=new GregorianCalendar();
      calendar.setTime(new Date());

      FrmVerificaAssegnazioneVO frmVerificaAssegnazioneVO = new FrmVerificaAssegnazioneVO();

      Long idAssegnazioneCarburante = umaClient.getIdAssCarbAnnoCorrenteByIdDittaUma(idDittaUma);
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

      frmVerificaAssegnazioneVO.setNumeroDoc(frmAssegnazioneSupplementareVO.getNumeroDoc());
      frmVerificaAssegnazioneVO.setDataConsegnaDoc(frmAssegnazioneSupplementareVO.getDataConsegnaDoc());
      frmVerificaAssegnazioneVO.setExtIdIntermediario(frmAssegnazioneSupplementareVO.getExtIdIntermediarioLong());
      frmVerificaAssegnazioneVO.setIdAssCarb(frmAssegnazioneSupplementareVO.getIdAssCarb());
      
      frmVerificaAssegnazioneVO.setNumeroSupplemento(frmAssegnazioneSupplementareVO.getNumeroSupplemento());

      SolmrLogger.debug(this,"\n\n\n***************frmVerificaAssegnazioneVO");
      SolmrLogger.debug(this," -- settato numeroSupplemento ="+frmVerificaAssegnazioneVO.getNumeroSupplemento());
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


      SolmrLogger.debug(this,"\n\n\n@@@@@@@@@@@@@@@");
      SolmrLogger.debug(this,"idDomAss: "+idDomAss);
      SolmrLogger.debug(this,"idNumerazioneFoglio: "+idNumerazioneFoglio);
      SolmrLogger.debug(this,"idAssCarb: "+idAssCarb);
      SolmrLogger.debug(this,"createNew: "+createNew);


      SolmrLogger.debug(this,"\n\n\n\n\n***********************************+");
      SolmrLogger.debug(this," ----------- updateNumerazioneFoglio");

      FogliRigaVO foglioRiga = umaClient.updateNumerazioneFoglio(idDittaUma, idDomAss, idNumerazioneFoglio, ruoloUtenza,
            idAssCarb, createNew, new Boolean(false), frmVerificaAssegnazioneVO);
      
      session.removeAttribute("common");
      SolmrLogger.debug(this,"idNumerazioneFoglio: "+idNumerazioneFoglio);
    }
    catch(Exception e)
    {
      SolmrLogger.error(this,"------- Exception in confermaCreazioneFoglioRigaAssSupplCtrl ="+e.getMessage());
      ValidationErrors vErr = new ValidationErrors();
      vErr.add("error", new ValidationError(e.getMessage()) );
      request.setAttribute("errors", vErr);
      SolmrLogger.debug(this,"\n\n\nverificaAssegnazioneSupplementareValidataUrl: "+verificaAssegnazioneSupplementareValidataUrl);
      %><jsp:forward page="<%=verificaAssegnazioneSupplementareValidataUrl%>"/><%
      return;
    }

    SolmrLogger.debug(this,"\n\n\nverificaAssegnazioneSupplementareValidataUrl: "+verificaAssegnazioneSupplementareValidataUrl);
    //session.setAttribute("notifica","Foglio Riga ");
    %><jsp:forward page="<%=verificaAssegnazioneSupplementareValidataUrl%>"/><%
    return;
  }
  else{
    if (request.getParameter("annulla.x")!=null)
    {
      SolmrLogger.debug(this,"annulla.x");

      SolmrLogger.debug(this,"\n\n\nannullaCreazioneFoglioRigaUrl: "+annullaCreazioneFoglioRigaUrl);
      %><jsp:forward page="<%=annullaCreazioneFoglioRigaUrl%>"/><%
    }
    else{
      SolmrLogger.debug(this,"visualizza");
      //Imposta l'assegnazione di un foglio riga su Assegnazione Supplementare
      idAssCarb = new Long(-1);
      request.setAttribute("idAssCarb", idAssCarb);

      %>
      <jsp:forward page="<%=viewUrl%>"/>
      <%
    }
  }
%>
<%!
private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException(msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}
%>