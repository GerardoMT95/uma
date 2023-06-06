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
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  public static final String LAYOUT="macchina/layout/venditaFuoriRegione.htm";
%>
<%
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

  htmpl.set("siglaProvincia", (String)request.getAttribute("siglaProvincia"));
  htmpl.set("numeroDittaUMA", (String)request.getAttribute("numeroDittaUMA"));
  htmpl.set("numeroNuovaTarga", (String)request.getAttribute("numeroNuovaTarga"));
  htmpl.set("numeroModello49", (String)request.getAttribute("numeroModello49"));
  htmpl.set("annoModello49", (String)request.getAttribute("annoModello49"));

  String tipoTargaAssegnata = (String)request.getAttribute("tipoTargaAssegnata");

  this.errErrorValExc(htmpl, request, exception);
  MacchinaVO mavo = (MacchinaVO)session.getAttribute("common");
  MovimentiTargaVO movo = (MovimentiTargaVO)request.getAttribute("movo");
  DatiMacchinaVO dmvo = null;
  TargaVO tvo = null;
  MatriceVO mvo = null;

  Vector select = new Vector();
    select.add("T");
    select.add("D");
    select.add("MTS");
    select.add("MTA");
    select.add("MAO");
  Vector UMA = new Vector();
    UMA.add("MC");
    UMA.add("MF");
    UMA.add("MZ");
    UMA.add("MV");

if(mavo != null)
{
  dmvo = mavo.getDatiMacchinaVO();
  tvo = mavo.getTargaCorrente();
  mvo = mavo.getMatriceVO();

  if (mavo==null)
  {
    SolmrLogger.debug(this,"mavo==null");
    mavo=new MacchinaVO(); // Evito nullpointerexception
  }
  if (tvo==null)
  {
    SolmrLogger.debug(this,"tvo==null");
    tvo=new TargaVO(); // Evito nullpointerexception
    tvo.setNumeroTarga("");
    tvo.setDescrizioneTipoTarga("");
  }
  if (mvo==null)
  {
    SolmrLogger.debug(this,"mvo==null");
    mvo=new MatriceVO(); // Evito nullpointerexception
  }

  htmpl.set("matricolaTelaio", mavo.getMatricolaTelaio());
  htmpl.set("matricolaMotore", mavo.getMatricolaMotore());

  htmpl.set("targa", composeString(tvo.getDescrizioneTipoTarga(), tvo.getNumeroTarga()));

  htmpl.set("idMacchina", mavo.getIdMacchina());
//  htmpl.set("idMovimentiTarga", movo.getIdMovimentiTarga());

  SolmrLogger.debug(this,"\n#\n "+umaClient.getTipiMovimentazione());

  Vector tipiMov = umaClient.getTipiMovimentazione();
  SolmrLogger.debug(this,"############# tipiMov "+tipiMov);
  for(int i=0; i<tipiMov.size(); i++)
  {
    int code = ((CodeDescr)tipiMov.get(i)).getCode().intValue();
    if(code != 4 && code != 5 && code != 6 && code != 8)
    {
      SolmrLogger.debug(this,"\n");
      tipiMov.remove(i);
      i--;
    }
  }
//  SolmrLogger.debug(this,"################################### movo.getIdMovimentazione()|"+movo.getIdMovimentazione()+"|");
  printCombo(htmpl, tipiMov, "idMovimentazione", "descMovimentazione", null, "blkMovimentazione");

  String codBreve = "";

  if(mavo.getIdMatrice()!=null)
  {
    codBreve = mvo.getCodBreveGenereMacchina();
    htmpl.set("descGenereMacchina", mvo.getDescGenereMacchina());
    htmpl.set("descCategoria", mvo.getDescCategoria());
    htmpl.set("marca", mvo.getDescMarca());
    htmpl.set("tipoMacchina", mvo.getTipoMacchina());
  }
  else
  {
    codBreve = dmvo.getCodBreveGenereMacchina();
    htmpl.set("descGenereMacchina", dmvo.getDescGenereMacchina());
    htmpl.set("descCategoria", dmvo.getDescCategoria());
    htmpl.set("marca", dmvo.getMarca());
    htmpl.set("tipoMacchina", dmvo.getTipoMacchina());
  }
  SolmrLogger.debug(this,"\n# codBreve |"+codBreve.trim()+"|");
  SolmrLogger.debug(this,"\n# R |"+"R".equals(codBreve.trim())+"|");
  SolmrLogger.debug(this,"\n# UMA |"+UMA.contains(codBreve.trim())+"|");
  SolmrLogger.debug(this,"\n# sel |"+select.contains(codBreve.trim())+"|");

  if(select.contains(codBreve.trim()))
  {
    htmpl.newBlock("blkUMA");
    htmpl.newBlock("blkStradale");
  }
  else if(UMA.contains(codBreve.trim()))
  {
    htmpl.newBlock("blkUMA");
  }
  else if("R".equals(codBreve.trim()))
  {
    htmpl.newBlock("blkStradale");
  }

  if("UMA".equals(tipoTargaAssegnata))
    htmpl.set("blkUMA.tipoTargaAssegnata", "checked");
  else if("Stradale".equals(tipoTargaAssegnata))
    htmpl.set("blkStradale.tipoTargaAssegnata", "checked");
  else
    htmpl.set("tipoTargaAssegnata", "checked");
}

  out.print(htmpl.text());
%>
<%!
  private void errErrorValExc(Htmpl htmpl, HttpServletRequest request, Throwable exc)
  {
    SolmrLogger.debug(this,"\n\n\n\n *********************************** 2");
    SolmrLogger.debug(this,"errErrorValExc()");

    if (exc instanceof it.csi.solmr.exception.ValidationException){

      ValidationErrors valErrs = new ValidationErrors();
      valErrs.add("error", new ValidationError(exc.getMessage()) );

      HtmplUtil.setErrors(htmpl, valErrs, request);
    }
  }
%>
<%!
  private String composeString(String first, String second)
  {
    String result = "";
    if(!"".equals(first) && first != null)
    {
      result = first;
      if(!"".equals(second) && second != null)
        result += " - " + second;
    }
    else if(!"".equals(second) && second != null)
      result = second;
    return result;
  }
  private void printCombo(Htmpl htmpl,Vector comboData,String nameCode,String nameDesc,String selectedCode,String blockName)
    {
      int size=comboData==null?0:comboData.size();
      String blkNameCode=blockName+"."+nameCode;
      String blkNameDesc=blockName+"."+nameDesc;
      htmpl.newBlock(blockName);
      htmpl.set(blkNameCode,null);
      htmpl.set(blkNameDesc,"-seleziona-");
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
