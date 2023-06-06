<%@ page language="java" contentType="text/html" isErrorPage="true"%>

<%@ page import="java.util.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@page import="it.csi.solmr.etc.SolmrConstants"%>
<%!public static final String LAYOUT = "macchina/layout/nuovaImmatricolazione.htm";%>
<%
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file="/include/menu.inc"%>
<%
  HtmplUtil.setErrors(htmpl, (ValidationErrors) request
      .getAttribute("errors"), request);

  this.errErrorValExc(htmpl, request, exception);
  MacchinaVO mavo = (MacchinaVO) session.getAttribute("common");
  DatiMacchinaVO dmvo = null;
  TargaVO tvo = null;
  MatriceVO mvo = null;

  Vector<String> select = new Vector<String>();
  select.add("T");
  select.add("D");
  select.add("MTS");
  select.add("MTA");
  select.add("MAO");
  Vector<String> UMA = new Vector<String>();
  UMA.add("MC");
  UMA.add("MF");
  UMA.add("MZ");
  UMA.add("V");
  Vector<String> MC824 = new Vector<String>();
  MC824.add("MC");
  MC824.add("MF");
  MC824.add("MZ");

  SolmrLogger.debug(this,"################# dmvo : " + dmvo);
  SolmrLogger.debug(this,"################# mvo : " + mvo);
  SolmrLogger.debug(this,"################# tvo : " + tvo);
  SolmrLogger.debug(this,"################# mavo : " + mavo);

  if (mavo != null)
  {
    dmvo = mavo.getDatiMacchinaVO();
    tvo = mavo.getTargaCorrente();
    mvo = mavo.getMatriceVO();

    if (mavo == null)
    {
      SolmrLogger.debug(this,"mavo==null");
      mavo = new MacchinaVO(); // Evito nullpointerexception
    }
    if (tvo == null)
    {
      SolmrLogger.debug(this,"tvo==null");
      tvo = new TargaVO(); // Evito nullpointerexception
      tvo.setNumeroTarga("");
      tvo.setDescrizioneTipoTarga("");
    }
    if (mvo == null)
    {
      SolmrLogger.debug(this,"mvo==null");
      mvo = new MatriceVO(); // Evito nullpointerexception
    }

    htmpl.set("matricolaTelaio", mavo.getMatricolaTelaio());
    htmpl.set("matricolaMotore", mavo.getMatricolaMotore());

    htmpl.set("targa", composeString(tvo.getDescrizioneTipoTarga(), tvo
        .getNumeroTarga()));

    htmpl.set("idMacchina", mavo.getIdMacchina());
    //  htmpl.set("idMovimentiTarga", movo.getIdMovimentiTarga());

    SolmrLogger.debug(this,"\n#\n " + umaClient.getTipiMovimentazione());

    Vector tipiMov = umaClient.getTipiMovimentazione();
    SolmrLogger.debug(this,"############# tipiMov " + tipiMov);
    for (int i = 0; i < tipiMov.size(); i++)
    {
      int code = ((CodeDescr) tipiMov.get(i)).getCode().intValue();
      if (code != 4 && code != 5 && code != 6 && code != 8)
      {
        SolmrLogger.debug(this,"\n");
        tipiMov.remove(i);
        i--;
      }
    }
    //  SolmrLogger.debug(this,"################################### movo.getIdMovimentazione()|"+movo.getIdMovimentazione()+"|");
    printCombo(htmpl, tipiMov, "idMovimentazione", "descMovimentazione",
        request.getParameter("idMovimentazione"), "blkMovimentazione");

    String codBreve = "";

    if (mavo.getIdMatrice() != null)
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
    SolmrLogger.debug(this,"\n# codBreve |" + codBreve.trim() + "|");
    SolmrLogger.debug(this,"\n# R |" + "R".equals(codBreve.trim()) + "|");
    SolmrLogger.debug(this,"\n# UMA |" + UMA.contains(codBreve.trim()) + "|");
    SolmrLogger.debug(this,"\n# sel |" + select.contains(codBreve.trim()) + "|");
    if (select.contains(codBreve.trim()))
    {
      htmpl.newBlock("blkSelect");
      String tipoTarga=request.getParameter("tipoTarga");
      if ("uma".equals(tipoTarga))
      {
        htmpl.set("blkSelect.umaCheded", SolmrConstants.HTML_CHECKED, null);
      }
    }
    else
      if (UMA.contains(codBreve.trim()))
      {
        htmpl.newBlock("blkUMA");
      }
      else
        if ("R".equals(codBreve.trim()))
        {
          htmpl.newBlock("blkStradale");
        }

    if (MC824.contains(codBreve))
      htmpl.newBlock("blkMC824");
  }
  String numeroTarga = request.getParameter("numeroTarga");
  htmpl.set("numeroTarga", numeroTarga);
  String radioNumeroTarga = request.getParameter("radioNumeroTarga");
  if (radioNumeroTarga == null || "D".equals(radioNumeroTarga))
  {
    htmpl.set("checkedD", SolmrConstants.HTML_CHECKED, null);
  }
  else
  {
    htmpl.set("checkedA", SolmrConstants.HTML_CHECKED, null);
  }

  out.print(htmpl.text());
%>
<%!private void errErrorValExc(Htmpl htmpl, HttpServletRequest request,
      Throwable exc)
  {
    SolmrLogger.debug(this,"\n\n\n\n *********************************** 2");
    SolmrLogger.debug(this,"errErrorValExc()");

    if (exc instanceof it.csi.solmr.exception.ValidationException)
    {

      ValidationErrors valErrs = new ValidationErrors();
      valErrs.add("error", new ValidationError(exc.getMessage()));

      HtmplUtil.setErrors(htmpl, valErrs, request);
    }
  }%>
<%!private String composeString(String first, String second)
  {
    String result = "";
    if (!"".equals(first) && first != null)
    {
      result = first;
      if (!"".equals(second) && second != null)
        result += " - " + second;
    }
    else
      if (!"".equals(second) && second != null)
        result = second;
    return result;
  }

  private void printCombo(Htmpl htmpl, Vector comboData, String nameCode,
      String nameDesc, String selectedCode, String blockName)
  {
    int size = comboData == null ? 0 : comboData.size();
    String blkNameCode = blockName + "." + nameCode;
    String blkNameDesc = blockName + "." + nameDesc;
    htmpl.newBlock(blockName);
    htmpl.set(blkNameCode, null);
    htmpl.set(blkNameDesc, "-seleziona-");
    for (int i = 0; i < size; i++)
    {
      CodeDescr cd = (CodeDescr) comboData.get(i);
      String code = cd.getCode().toString();
      htmpl.newBlock(blockName);
      if (code != null && code.equals(selectedCode))
      {
        htmpl.set(blockName + ".selected", "selected");
      }
      htmpl.set(blkNameCode, code);
      htmpl.set(blkNameDesc, cd.getDescription());
    }
  }%>
