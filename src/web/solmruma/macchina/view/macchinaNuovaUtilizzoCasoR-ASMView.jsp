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
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  SolmrLogger.debug(this,"macchinaNuovaUtilizzoCasoR-ASMView.jsp - Begin");
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("macchina/layout/MacchinaNuovaUtilizzoCasoR-ASM.htm");
%>
  <%@include file = "/include/menu.inc" %>
<%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  HashMap vecSession = (HashMap) session.getAttribute("common");
  MacchinaVO macchinaVO = (MacchinaVO) vecSession.get("macchinaVO");
  DatiMacchinaVO datiMacchinaVO = (DatiMacchinaVO) vecSession.get("datiMacchinaVO");
  UtilizzoVO utilizzoVO = (UtilizzoVO) vecSession.get("utilizzoVO");
  PossessoVO possessoVO = (PossessoVO) vecSession.get("possessoVO");
  AnagAziendaVO dittaLeasing = (AnagAziendaVO) vecSession.get("anagAziendaVO");

  printCombo(htmpl,umaClient.getTipiFormaPossesso(),"idFormaPossesso","descrizione",request.getParameter("idFormaPossesso"),"blkTipoFormaPossesso");
  htmpl.set("dataCarico", request.getParameter("dataCarico"));
  htmpl.set("showTarga",""+datiMacchinaVO.isHasTarga());
  SolmrLogger.debug(this,"\n\n\n**********datiMacchinaVO.isHasTarga(): "+datiMacchinaVO.isHasTarga());

  //Acquisto nuovo con targa - Borgogno 21/10/2004 - Begin
  final String TARGA_ASSEGNATA = "auto";
  final String TARGA_SPECIFICATA = "spec";
  SolmrLogger.debug(this, "request.getParameter(\"radioTarga\"): "+
                    request.getParameter("radioTarga"));
  if (Validator.isNotEmpty(request.getParameter("radioTarga")))
  {
    SolmrLogger.debug(this, "if (Validator.isNotEmpty(request.getParameter(\"radioTarga\")))");
    String radioTarga = request.getParameter("radioTarga");
    if(radioTarga.equalsIgnoreCase(TARGA_SPECIFICATA))
    {
      SolmrLogger.debug(this, "if(radioTarga.equalsIgnoreCase(TARGA_SPECIFICATA))");
      htmpl.set("tipoAssTarga",TARGA_SPECIFICATA);
      htmpl.set("chkTarga2","checked", null);
    }
    else if(radioTarga.equalsIgnoreCase(TARGA_ASSEGNATA))
    {
      SolmrLogger.debug(this, "if(radioTarga.equalsIgnoreCase(TARGA_ASSEGNATA))");
      htmpl.set("tipoAssTarga",TARGA_ASSEGNATA);
      htmpl.set("chkTarga1","checked", null);
    }
  }
  else
  {
    SolmrLogger.debug(this, "else (Validator.isNotEmpty(request.getParameter(\"radioTarga\")))");
    htmpl.set("tipoAssTarga",TARGA_ASSEGNATA);
    htmpl.set("chkTarga1","checked", null);
  }
  //Acquisto nuovo con targa - Borgogno 21/10/2004 - End
  SolmrLogger.debug(this,"pathToFollow="+(String)session.getAttribute("pathToFollow"));

  HtmplUtil.setValues(htmpl,macchinaVO,(String)session.getAttribute("pathToFollow"));
  HtmplUtil.setValues(htmpl,datiMacchinaVO,(String)session.getAttribute("pathToFollow"));
  HtmplUtil.setValues(htmpl,utilizzoVO,(String)session.getAttribute("pathToFollow"));
  HtmplUtil.setValues(htmpl,possessoVO,(String)session.getAttribute("pathToFollow"));
  HtmplUtil.setValues(htmpl,dittaLeasing,(String)session.getAttribute("pathToFollow"));
  if (dittaLeasing!=null)
  {
    SolmrLogger.debug(this, "CONTROLLO ID AZIENDA: "+String.valueOf(dittaLeasing.getIdAzienda()));
	htmpl.set("idAziendaLeasing", String.valueOf(dittaLeasing.getIdAzienda()));
    htmpl.set("ragioneSociale", dittaLeasing.getDenominazione());
  }
  
  String dataPrima = request.getParameter("dataPrimaImmatricolazione");
  htmpl.set("numeroTarga", request.getParameter("numeroTarga"));
  htmpl.set("dataPrimaImmatricolazione", request.getParameter("dataPrimaImmatricolazione"));

  ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");
  SolmrLogger.debug(this,"errors="+errors);
  HtmplUtil.setErrors(htmpl,errors,request);
  this.errErrorValExc(htmpl, request, exception);
  out.print(htmpl.text());

%>

<%! 
  private boolean findCode(Integer code,Vector codes)
  {
    if (codes==null || code==null)
    {
      return false;
    }
    int size=codes.size();
    for(int i=0;i<size;i++)
    {
      Long lavCode=(Long)codes.get(i);
      if (code.intValue()==lavCode.longValue())
      {
        return true;
      }
    }
    return false;
  }
%>

<%!
  private void errErrorValExc(Htmpl htmpl, HttpServletRequest request, Throwable exc)
  {
    SolmrLogger.debug(this,"errErrorValExc()");
    if (exc instanceof it.csi.solmr.exception.ValidationException)
    {
      ValidationErrors valErrs = new ValidationErrors();
      valErrs.add("error", new ValidationError(exc.getMessage()) );
      HtmplUtil.setErrors(htmpl, valErrs, request);
    }
  }

  private void printCombo(Htmpl htmpl,Vector comboData,String nameCode,String nameDesc,String selectedCode,String blockName)
  {
    int size=comboData==null?0:comboData.size();
    SolmrLogger.debug(this,"size="+size);
    String blkNameCode=blockName+"."+nameCode;
    String blkNameDesc=blockName+"."+nameDesc;
    SolmrLogger.debug(this,"blkNameCode="+blkNameCode);
    SolmrLogger.debug(this,"blkNameDesc="+blkNameDesc);
    htmpl.newBlock(blockName);
    htmpl.set(blkNameCode,null);
    htmpl.set(blkNameDesc,"-seleziona-");
    SolmrLogger.debug(this,"selectedCode="+selectedCode);
    for(int i=0;i<size;i++)
    {
      CodeDescr cd=(CodeDescr)comboData.get(i);
      String code=cd.getCode().toString();
      htmpl.newBlock(blockName);
      if (code!=null && code.equals(selectedCode))
      {
        htmpl.set(blockName+".selected","selected");
      }
      htmpl.set(blkNameCode,code);
      htmpl.set(blkNameDesc,cd.getDescription());
    }
  }

%>