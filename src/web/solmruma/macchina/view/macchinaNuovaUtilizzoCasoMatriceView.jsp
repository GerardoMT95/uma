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
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<jsp:useBean id="dittaLeasing" scope="request" class="it.csi.solmr.dto.anag.AnagAziendaVO">
  <jsp:setProperty name="dittaLeasing" property="*" />
</jsp:useBean>

<%!
  public static final String LAYOUT="macchina/layout/MacchinaNuovaUtilizzoCasoMatrice.htm";
%>

<%
  //---------------- Ricerca in sessione delle variabili necessarie --------------
  HashMap common=(HashMap) session.getAttribute("common");
  MacchinaVO macchinaVO=(MacchinaVO)get(common,"macchinaVO");
  MatriceVO matriceVO=(MatriceVO)get(common,"matriceVO");
  DittaUMAVO dittaProvenienzaVO=(DittaUMAVO)get(common,"dittaProvenienzaVO");
//------------------------------------------------------------------------------

  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%>
  <%@include file = "/include/menu.inc" %>
<%

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
  
  String pathToFollow=(String)request.getAttribute("pathToFollow");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  //Visualizza la combo per la scelta della targa
  printCombo(htmpl,umaClient.getTipiFormaPossesso(),"idFormaPossesso","descrizione",request.getParameter("idFormaPossesso"),"blkTipoFormaPossesso");

  if( request.getParameter("dataCarico")!=null )
  {
    SolmrLogger.debug(this,"request.getParameter(\"dataCarico\")!=null");
    htmpl.set("dataCarico", request.getParameter("dataCarico"));
  }
  else
  {
    SolmrLogger.debug(this,"request.getParameter(\"dataCarico\")==null");
    htmpl.set("dataCarico", DateUtils.formatDate(new Date()) );
  }

  //Visualizza il radio button per la scelta del MC824
  setRadios(request,common,htmpl);
  String genereStr = composeString(matriceVO.getCodBreveGenereMacchina(), matriceVO.getDescGenereMacchina());
  String categoriaStr = composeString(matriceVO.getCodBreveCategoriaMacchina(), matriceVO.getDescCategoria());
  htmpl.set("genereMacchina", genereStr);
  htmpl.set("categoria", categoriaStr);

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
      htmpl.set("chkSpec","checked");
    }
    else if(radioTarga.equalsIgnoreCase(TARGA_ASSEGNATA))
    {
      SolmrLogger.debug(this, "if(radioTarga.equalsIgnoreCase(TARGA_ASSEGNATA))");
      htmpl.set("tipoAssTarga",TARGA_ASSEGNATA);
      htmpl.set("chkAuto","checked");
    }
  }
  else
  {
    SolmrLogger.debug(this, "else (Validator.isNotEmpty(request.getParameter(\"radioTarga\")))");
    htmpl.set("tipoAssTarga",TARGA_ASSEGNATA);
    htmpl.set("chkAuto","checked");
  }
  htmpl.set("numeroTarga", request.getParameter("numeroTarga"));
  htmpl.set("dataPrimaImmatricolazione", request.getParameter("dataPrimaImmatricolazione"));
  //Acquisto nuovo con targa - Borgogno 21/10/2004 - End

  HtmplUtil.setValues(htmpl,matriceVO,pathToFollow);
  HtmplUtil.setValues(htmpl,macchinaVO,pathToFollow);
  HtmplUtil.setValues(htmpl,macchinaVO.getTargaCorrente(),pathToFollow);
  HtmplUtil.setValues(htmpl,dittaProvenienzaVO,pathToFollow);
  HtmplUtil.setValues(htmpl,dittaLeasing,pathToFollow);
  HtmplUtil.setValues(htmpl,request);
  

%>



<%=htmpl.text()%>



<%!



  private void setRadios(HttpServletRequest request, HashMap common, Htmpl htmpl)
  {
    SolmrLogger.debug(this,"setRadios()");
    String mc824=request.getParameter("mc824");
    SolmrLogger.debug(this,"mc824: "+mc824);
    MacchinaVO macchinaVO=(MacchinaVO)common.get("macchinaVO");
    TargaVO targaVO=macchinaVO.getTargaCorrente();
    SolmrLogger.debug(this,"targaVO: "+targaVO);
    MatriceVO matriceVO=(MatriceVO)common.get("matriceVO");
    SolmrLogger.debug(this,"matriceVO: "+matriceVO);
    String codBreveGenereMacchina=matriceVO.getCodBreveGenereMacchina().trim();
    SolmrLogger.debug(this,"codBreveGenereMacchina="+codBreveGenereMacchina);

    if (!(SolmrConstants.COD_BREVE_GENERE_MACCHINA_MC.equals(codBreveGenereMacchina) ||
        SolmrConstants.COD_BREVE_GENERE_MACCHINA_MZ.equals(codBreveGenereMacchina) ||
        SolmrConstants.COD_BREVE_GENERE_MACCHINA_MF.equals(codBreveGenereMacchina)))
    {
      SolmrLogger.debug(this,"disableMc824 disabled");
      htmpl.set("disableMc824","disabled");
    }
    else
    {
      SolmrLogger.debug(this,"mc824 non Assegnabile");
      htmpl.set("checkMc824No","checked");
    }

    switch(findTipoTarga(matriceVO))
    {
      case 3:
        htmpl.set("checkedUMA","checked");
        htmpl.set("disabledTipoTarga","disabled");
        htmpl.newBlock("blkTipoTargaUma");
        break;
      default:
        if ("UMA".equalsIgnoreCase(request.getParameter("tipoTarga")))
        {
          htmpl.set("checkedUMA","checked");
        }
        else
        {
          htmpl.set("checkedStradale","checked");
        }
        break;
    }
  }

  private Object get(HashMap common,String name)
  {
    if (common==null)
    {
      return null;
    }
    return common.get(name);
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

  private int findTipoTarga(MatriceVO matriceVO)
  {
    String codBreveGenere=matriceVO.getCodBreveGenereMacchina().trim();
    SolmrLogger.debug(this,"codBreveGenere=\""+codBreveGenere+"\"");
    if (SolmrConstants.COD_BREVE_GENERE_MACCHINA_T.equals(codBreveGenere) ||
        SolmrConstants.COD_BREVE_GENERE_MACCHINA_D.equals(codBreveGenere) ||
        SolmrConstants.COD_BREVE_GENERE_MACCHINA_MTS.equals(codBreveGenere) ||
        SolmrConstants.COD_BREVE_GENERE_MACCHINA_MTA.equals(codBreveGenere))
    {
      return 1;
    }

    if (SolmrConstants.COD_BREVE_GENERE_MACCHINA_MAO.equals(codBreveGenere))
    {
      return 2;
    }
    return 3;
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

%>