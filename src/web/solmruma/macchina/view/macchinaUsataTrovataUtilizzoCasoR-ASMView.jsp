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
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<jsp:useBean id="possessoVO" scope="request" class="it.csi.solmr.dto.uma.PossessoVO">

  <jsp:setProperty name="possessoVO" property="*" />

</jsp:useBean>





<%!

  public static final String LAYOUT="macchina/layout/MacchinaUsataTrovataUtilizzoCasoR-ASM.htm";

%>

<%



//---------------- Ricerca in sessione delle variabili necessarie --------------

  AnagAziendaVO dittaLeasing=(AnagAziendaVO) request.getAttribute("dittaLeasing");

  HashMap common=(HashMap) session.getAttribute("common");

  MacchinaVO macchinaVO=(MacchinaVO)get(common,"macchinaVO");

  DittaUMAVO dittaProvenienzaVO=(DittaUMAVO)get(common,"dittaProvenienzaVO");

//------------------------------------------------------------------------------

  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  String pathToFollow=(String)request.getAttribute("pathToFollow");



  setRadios(request,htmpl);



  if (request.getParameter("salva")==null && request.getParameter("indietro")==null)

  {

    htmpl.set("dataCarico",DateUtils.formatDate(new Date()));

  }



  HtmplUtil.setErrors(htmpl,(ValidationErrors)request.getAttribute("errors"),request);

  HtmplUtil.setValues(htmpl,macchinaVO.getDatiMacchinaVO(),pathToFollow);

  HtmplUtil.setValues(htmpl,macchinaVO,pathToFollow);

  HtmplUtil.setValues(htmpl,macchinaVO.getTargaCorrente(),pathToFollow);

  HtmplUtil.setValues(htmpl,dittaProvenienzaVO,pathToFollow);

  HtmplUtil.setValues(htmpl,dittaLeasing,pathToFollow);

  HtmplUtil.setValues(htmpl,request);

  printCombo(htmpl,umaClient.getTipiFormaPossesso(),"idFormaPossesso","descrizione",possessoVO.getIdFormaPossesso(),"blkTipoFormaPossesso");

%>



<%=htmpl.text()%>



<%!

  private void setRadios(HttpServletRequest request, Htmpl htmpl)

  {

    if ("yes".equalsIgnoreCase(request.getParameter("nuovaTarga")))

    {

      htmpl.set("checkedNuovaTargaYes","checked");

    }

    else

    {

      htmpl.set("checkedNuovaTargaNo","checked");

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

%>

