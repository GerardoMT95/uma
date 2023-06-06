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




<%

  SolmrLogger.debug(this,"macchinaNuovaGenereView.jsp - Begin");



  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("macchina/layout/MacchinaNuovaMatrice.htm");
%><%@include file = "/include/menu.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  Vector gcomenere=new Vector();

  HashMap common = (HashMap) session.getAttribute("common");

  MacchinaVO macchinaVO=(MacchinaVO)common.get("macchinaVO");

  MatriceVO matriceVO=(MatriceVO)macchinaVO.getMatriceVO();

  SolmrLogger.debug(this,"matriceVO: "+matriceVO);

  String genereStr = composeString(matriceVO.getCodBreveGenereMacchina(), matriceVO.getDescGenereMacchina());

  String categoriaStr = composeString(matriceVO.getCodBreveCategoriaMacchina(), matriceVO.getDescCategoria());

  htmpl.set("genereMacchina", genereStr);

  htmpl.set("categoria", categoriaStr);

  HtmplUtil.setValues(htmpl, matriceVO, request.getParameter("pathToFollow"));

  HtmplUtil.setErrors(htmpl, (ValidationErrors) request.getAttribute("errors"),request);

  Vector elencoMatriciPage=(Vector) request.getAttribute("elencoMatriciPage");

  int size=elencoMatriciPage==null?0:elencoMatriciPage.size();



  SolmrLogger.debug(this,"\n\n\n######################");

  SolmrLogger.debug(this,"size elencoMatriciPage: "+size);

  SolmrLogger.debug(this,"######################");



  Long currentPage=(Long)request.getAttribute("currentPage");

  Long maxPage=(Long)request.getAttribute("maxPage");



  htmpl.set("rows",""+request.getAttribute("rows"));

  htmpl.set("nextPage",""+request.getAttribute("nextPage"));

  htmpl.set("prevPage",""+request.getAttribute("prevPage"));

  htmpl.set("currentPage",""+request.getAttribute("currentPage"));

  htmpl.set("maxPage",""+request.getAttribute("maxPage"));

  if (currentPage.longValue()!=1)

  {

    htmpl.newBlock("prev");

    htmpl.set("prev.prevPage",""+request.getAttribute("prevPage"));

  }

  if (currentPage.longValue()!=maxPage.longValue())

  {

    htmpl.newBlock("next");

    htmpl.set("next.nextPage",""+request.getAttribute("nextPage"));

  }

  if (size!=0)

  {

    for(int i=0;i<size;i++)

    {

      matriceVO=(MatriceVO) elencoMatriciPage.get(i);

      htmpl.set("blkMatrice.idMatrice",matriceVO.getIdMatrice());

      htmpl.set("blkMatrice.numeroMatrice",matriceVO.getNumeroMatrice());

      htmpl.set("blkMatrice.descCategoria",matriceVO.getDescCategoria());

      htmpl.set("blkMatrice.tipoMacchina",matriceVO.getTipoMacchina());

      htmpl.set("blkMatrice.numeroOmologazione",matriceVO.getNumeroOmologazione());

      htmpl.set("blkMatrice.potenzaCV",matriceVO.getPotenzaCV());

      htmpl.set("blkMatrice.potenzaKW",matriceVO.getPotenzaKW());

      htmpl.set("blkMatrice.descAlimentazione",matriceVO.getDescAlimentazione());

    }

  }

%>

<%=htmpl.text()%>

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