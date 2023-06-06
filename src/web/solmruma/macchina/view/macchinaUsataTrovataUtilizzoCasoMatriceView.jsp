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

  public static final String LAYOUT="macchina/layout/MacchinaUsataTrovataUtilizzoCasoMatrice.htm";

%>

<%



//---------------- Ricerca in sessione delle variabili necessarie --------------

  HashMap common=(HashMap) session.getAttribute("common");

  MacchinaVO macchinaVO=(MacchinaVO)get(common,"macchinaVO");

  DittaUMAVO dittaProvenienzaVO=(DittaUMAVO)get(common,"dittaProvenienzaVO");

//------------------------------------------------------------------------------

  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  String pathToFollow=(String)request.getAttribute("pathToFollow");

  SolmrLogger.debug(this,"macchinaVO.getMatriceVO()="+macchinaVO.getMatriceVO());





  printCombo(htmpl,umaClient.getTipiFormaPossesso(),"idFormaPossesso","descrizione",request.getParameter("idFormaPossesso"),"blkTipoFormaPossesso");



  htmpl.set("dataCarico",request.getParameter("dataCarico"));



  setRadios(request,common,htmpl);

  if (request.getParameter("salva")==null && request.getParameter("indietro")==null)

  {

    htmpl.set("dataCarico",DateUtils.formatDate(new Date()));

  }

  HtmplUtil.setErrors(htmpl,(ValidationErrors)request.getAttribute("errors"),request);

  HtmplUtil.setValues(htmpl,macchinaVO.getMatriceVO(),pathToFollow);

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

    String mc824=request.getParameter("mc824");

    MacchinaVO macchinaVO=(MacchinaVO)common.get("macchinaVO");

    TargaVO targaVO=macchinaVO.getTargaCorrente();

    String codBreveGenereMacchina=macchinaVO.getMatriceVO().getCodBreveGenereMacchina().trim();

    htmpl.set("codBreveGenereMacchina",codBreveGenereMacchina);

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

      if (mc824==null)

      {

        if ("S".equalsIgnoreCase(targaVO.getMc_824()))

        {

          htmpl.set("checkMc824Yes","checked");

        }

        else

        {

          htmpl.set("checkMc824No","checked");

        }

      }

      else

      {

        if ("S".equalsIgnoreCase(mc824))

        {

          htmpl.set("checkMc824Yes","checked");

        }

        else

        {

          htmpl.set("checkMc824No","checked");

        }

      }

    }

    if ("yes".equalsIgnoreCase(request.getParameter("nuovaTarga")))

    {

      htmpl.set("checkedNuovaTargaYes","checked");

    }

    else

    {

      htmpl.set("checkedNuovaTargaNo","checked");

    }

    switch(findTipoTarga(macchinaVO))

    {

      case 3:

        htmpl.set("checkedUMA","checked");

        htmpl.set("disabledTipoTarga","disabled");

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

  private int findTipoTarga(MacchinaVO macchinaVO)

  {

    String codBreveGenere=macchinaVO.getMatriceVO().getCodBreveGenereMacchina().trim();

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

