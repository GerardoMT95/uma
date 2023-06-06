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

  String iridePageName = "modificaSerraCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient umaClient = new UmaFacadeClient();
  String url="/ditta/ctrl/elencoSerreCtrl.jsp";
  String viewUrl="/ditta/view/modificaSerraView.jsp";
  String elenco="/ditta/ctrl/elencoSerreCtrl.jsp";
  String elencoBis="/ditta/ctrl/elencoSerreBisCtrl.jsp";
  String elencoHtm="../../ditta/layout/elencoSerre.htm";
  String elencoBisHtm="../../ditta/layout/elencoSerreBis.htm";
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  if (request.getParameter("salva.x")!=null)
  {
    SolmrLogger.debug(this,"idComune="+request.getParameterValues("idComune"));
    SolmrLogger.debug(this,"validateUpdate");
//    convertForValidation(umaClient, serraVO);
    ValidationErrors errors=serraVO.validateUpdate();
    SolmrLogger.debug(this,"errors.size()="+errors.size());
    if (errors.size()!=0)
    {
      request.setAttribute("errors",errors);
      request.setAttribute("serraVO",serraVO);
    }
    else
    {
      try
      {
        serraVO.setIdDittaUma(idDittaUma);
        request.setAttribute("serraVO",serraVO);
        umaClient.updateSerra(serraVO.getIdSerra(),idDittaUma,serraVO,ruoloUtenza);
      }
      catch(SolmrException sexc)
      {
        SolmrLogger.debug(this,"catch SolmrEception sexc");
        if (sexc.getValidationErrors()!=null){
          SolmrLogger.debug(this,"        if (sexc.getValidationErrors()!=null)");
          ValidationErrors vErrors = sexc.getValidationErrors();
          if (vErrors.size()!=0)
          {
            SolmrLogger.debug(this,"          if (vErrors.size()!=0)");
            request.setAttribute("errors", vErrors);
            %><jsp:forward page="<%=viewUrl%>"/><%
            return;
          }
        }else{
          SolmrLogger.debug(this,"          else (vErrors.size()!=0)");
          ValidationException valEx=new ValidationException("Eccezione di validazione"+sexc.getMessage(),viewUrl);
          valEx.addMessage(sexc.toString(),"exception");
          throw valEx;
        }
        SolmrLogger.debug(this,"        dopo if (sexc.getValidationErrors()!=null)");
      }
      catch(Exception e)
      {
        ValidationException valEx=new ValidationException("Eccezione di validazione"+e.getMessage(),viewUrl);
        valEx.addMessage(e.getMessage(),"exception");
        throw valEx;
      }
      String forwardUrl=elencoHtm;
      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
      {
        forwardUrl=elencoBisHtm;
      }

      session.setAttribute("notifica","Modifica eseguita con successo");
      response.sendRedirect(forwardUrl);
      return;
    }
  }
  else
  {
    if (request.getParameter("annulla.x")!=null)
    {
      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
      {
        response.sendRedirect(elencoBisHtm);
      }
      else
      {
        response.sendRedirect(elencoHtm);
      }
      return;
    }
    else
    {
      serraVO=(SerraVO) request.getAttribute("serraVO");
      convertForValidation(umaClient, serraVO);
      request.setAttribute("serraVO",serraVO);
    }
  }
%>
SolmrLogger.debug(this,"modificaSerraCtrl - End");

<jsp:forward page="<%=viewUrl%>"/>
<%!
private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException(msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}
private void convertForValidation(UmaFacadeClient umaFacadeClient, SerraVO serraVO)
  {
    final String SEPARATORE = "_";
    Double fattoreCubatura = null;

    try{
      //SolmrLogger.debug(this,"\n\n\n\n\n\n\n\n111**************************************");
      //SolmrLogger.debug(this,"serraVO.getIdFormaSerra(): "+serraVO.getIdFormaSerra());
      //SolmrLogger.debug(this,"serraVO.getFormaSerra(): "+serraVO.getIdFormaSerra());
      fattoreCubatura = umaFacadeClient.findFattoreCubatura( serraVO.getIdFormaSerra() );
      SolmrLogger.debug(this,"\n\n\n*********fattoreCubatura: " + fattoreCubatura + "<br>");
    }catch(SolmrException ex){
      SolmrLogger.error(this, "Error in umaFacadeClient.findFattoreCubatura - modificaSerraCtrl.jsp");
    }

    serraVO.setTipiFormaSerra(""+serraVO.getIdFormaSerra() + SEPARATORE + fattoreCubatura.doubleValue());
    serraVO.setTipiColturaInSerra(""+serraVO.getIdColtura());
    serraVO.setAltezzaStr(""+serraVO.getAltezza());
    serraVO.setLunghezzaStr(""+serraVO.getLunghezza());
    serraVO.setLarghezzaStr(""+serraVO.getLarghezza());
    serraVO.setVolumeMetriCubiStr(""+serraVO.getVolumeMetriCubi());
    //serraVO.setMesiDiRiscaldamentoStr(""+serraVO.getMesiDiRiscaldamento());
    //serraVO.setOreDiRiscaldamentoStr(""+serraVO.getOreDiRiscaldamento());
    if (serraVO.getDataInizioValidita()!=null){
      serraVO.setDataInizioValiditaStr(""+DateUtils.formatDate(serraVO.getDataInizioValidita()));
    }
    if (serraVO.getDataFineValidita()!=null){
      serraVO.setDataFineValiditaStr(""+DateUtils.formatDate(serraVO.getDataFineValidita()));
    }
    if (serraVO.getDataAggiornamento()!=null){
      serraVO.setDataAggiornamentoStr(""+DateUtils.formatDate(serraVO.getDataAggiornamento()));
    }
    if (serraVO.getDataCarico()!=null){
      serraVO.setDataCaricoStr(""+DateUtils.formatDate(serraVO.getDataCarico()));
    }
    if (serraVO.getDataScarico()!=null){
      serraVO.setDataScaricoStr(""+DateUtils.formatDate(serraVO.getDataScarico()));
    }
/*    else{
      serraVO.setDataScaricoStr(""+ DateUtils.formatDate(new Date()) );*/
}
%>
