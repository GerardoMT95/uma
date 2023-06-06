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

<jsp:useBean id="serraVO" scope="page"
             class="it.csi.solmr.dto.uma.SerraVO">
  <jsp:setProperty name="serraVO" property="*" />
</jsp:useBean>
<%

  String iridePageName = "confermaCreazioneFoglioRigaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "BEGIN confermaCreazioneFoglioRigaCtrl.jsp");
		  
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  UmaFacadeClient umaClient = new UmaFacadeClient();
  String verificaAssegnazioneValidataUrl="/domass/ctrl/verificaAssegnazioneValidataCtrl.jsp";
  String cessaDittaUmaUrl="/domass/ctrl/cessaDitaUmaConfermaCtrl.jsp";
  String confermaCreazioneFoglioRigaUrl="/domass/ctrl/verificaAssegnazioneValidataCtrl.jsp";
  String annullaCreazioneFoglioRigaUrl="/domass/ctrl/verificaAssegnazioneFoglioCtrl.jsp";
  String viewUrl="/domass/view/confermaCreazioneFoglioRigaView.jsp";
  String elencoDomAssUrl = "../ctrl/assegnazioniCtrl.jsp";
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  SolmrLogger.debug(this,"\n\n\n\n\n####################");
  SolmrLogger.debug(this,"request.getParameter(\"idDittaUma\"): "+request.getParameter("idDittaUma"));

  Long idDomAss=null;
  if (request.getParameter("idDomAss")!=null){
    SolmrLogger.debug(this,"request.getParameter(\"idDomAss\") != null");
    idDomAss=new Long(request.getParameter("idDomAss"));
    SolmrLogger.debug(this,"idDomAss: " + idDomAss);
  }


  Boolean valida = new Boolean(true);
  FrmVerificaAssegnazioneVO frmVerificaAssegnazioneVO=null;
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
    if (commonObj==null || !(commonObj instanceof FrmVerificaAssegnazioneVO) )
    {
      response.sendRedirect(elencoDomAssUrl);
      return;
    }
    //Recupero il FrmVerificaAssegnazioneVO dalla session, passato dalla confermaValidazioneDomandaCrl.jsp
    frmVerificaAssegnazioneVO = (FrmVerificaAssegnazioneVO) session.getAttribute("common");
  }

  SolmrLogger.debug(this,"valida: "+valida);

  if (request.getParameter("confermaCreazione.x")!=null)
  {
    SolmrLogger.debug(this,"confermaCreazione.x");
    try
    {
      SolmrLogger.debug(this,"request.getParameter(\"idDomAss\"): " + request.getParameter("idDomAss"));

      /*Long idAssCarb=null;
      if ( request.getParameter("idAssCarb") != null){
        SolmrLogger.debug(this,"request.getParameter(\"idAssCarb\") != null");
        idAssCarb = new Long( request.getParameter("idAssCarb") );
        SolmrLogger.debug(this,"idAssCarb: " + idAssCarb);
      }*/

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

      Long idAssCarb = null;
      SolmrLogger.debug(this,"\n\n\n\n\n***********************************+");
      SolmrLogger.debug(this,"umaClient.updateNumerazioneFoglio("+idDomAss+", "+idNumerazioneFoglio+", ruoloUtenza,"+idAssCarb+", "+createNew+");");

      SolmrLogger.debug(this,"\n\n\n@@@@@@@@@@@@@@@");
      SolmrLogger.debug(this,"idDomAss: "+idDomAss);
      SolmrLogger.debug(this,"idNumerazioneFoglio: "+idNumerazioneFoglio);
      SolmrLogger.debug(this,"idAssCarb: "+idAssCarb);
      SolmrLogger.debug(this,"createNew: "+createNew);

      FogliRigaVO foglioRiga = umaClient.updateNumerazioneFoglio(idDittaUma, idDomAss, idNumerazioneFoglio, ruoloUtenza, idAssCarb, createNew, valida, frmVerificaAssegnazioneVO);
      session.removeAttribute("common");
      SolmrLogger.debug(this,"idNumerazioneFoglio: "+idNumerazioneFoglio);
    }
    catch(Exception e)
    {
      SolmrLogger.debug(this,"catch Eliminazione 1");
      ValidationErrors vErr = new ValidationErrors();
      vErr.add("error", new ValidationError(e.getMessage()) );
      request.setAttribute("errors", vErr);
      SolmrLogger.debug(this,"\n\n\nverificaAssegnazioneValidataUrl: "+verificaAssegnazioneValidataUrl);
      %><jsp:forward page="<%=verificaAssegnazioneValidataUrl%>"/><%
      return;
    }

    SolmrLogger.debug(this,"\n\n\nverificaAssegnazioneValidataUrl: "+verificaAssegnazioneValidataUrl);
    //session.setAttribute("notifica","Foglio Riga ");
    %><jsp:forward page="<%=verificaAssegnazioneValidataUrl%>"/><%
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