<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>



<%@ page import="java.util.*" %><%@ page import="it.csi.jsf.htmpl.*" %>
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

  SolmrLogger.debug(this,"macchinaNuovaDatiCasoMatrice.jsp - Begin");



  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("macchina/layout/MacchinaNuovaDatiCasoMatrice.htm");
%>
  <%@include file = "/include/menu.inc" %>
<%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  Vector genere=new Vector();
  HashMap common = (HashMap) session.getAttribute("common");
  MatriceVO matriceVO=(MatriceVO)common.get("matriceVO");
  MacchinaVO macchinaVO=(MacchinaVO)common.get("macchinaVO");

  String genereStr = composeString(matriceVO.getCodBreveGenereMacchina(), matriceVO.getDescGenereMacchina());
  String categoriaStr = composeString(matriceVO.getCodBreveCategoriaMacchina(), matriceVO.getDescCategoria());
  htmpl.set("genereMacchina", genereStr);
  htmpl.set("categoria", categoriaStr);

  SolmrLogger.debug(this,"showMatricolaTelaio: "+matricolaTelaioIsNotValorizable(matriceVO));
  SolmrLogger.debug(this,"showMatricolaMotore: "+matricolaMotoreIsNotValorizable(matriceVO));
  htmpl.set("showMatricolaTelaio", ""+(!matricolaTelaioIsNotValorizable(matriceVO)));
  htmpl.set("showMatricolaMotore", ""+(!matricolaMotoreIsNotValorizable(matriceVO)));

  HtmplUtil.setValues(htmpl, matriceVO, request.getParameter("pathToFollow"));
  HtmplUtil.setValues(htmpl, macchinaVO, request.getParameter("pathToFollow"));
  HtmplUtil.setValues(htmpl, request, request.getParameter("pathToFollow"));
  HtmplUtil.setErrors(htmpl, (ValidationErrors) request.getAttribute("errors"),request);
  SolmrLogger.debug(this,"errors="+(ValidationErrors) request.getAttribute("errors"));
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

<%!

  private boolean matricolaTelaioIsNotValorizable(MatriceVO matriceVO)
  {
    String codBreveGenereMacchina=matriceVO.getCodBreveGenereMacchina().trim();
    return SolmrConstants.COD_BREVE_GENERE_MACCHINA_V.equals(codBreveGenereMacchina);
  }

  private boolean matricolaMotoreIsNotValorizable(MatriceVO matriceVO)
  {
    String codBreveGenereMacchina=matriceVO.getCodBreveGenereMacchina().trim();
    return (SolmrConstants.COD_BREVE_GENERE_MACCHINA_T.equals(codBreveGenereMacchina) ||
            SolmrConstants.COD_BREVE_GENERE_MACCHINA_MTS.equals(codBreveGenereMacchina) ||
            SolmrConstants.COD_BREVE_GENERE_MACCHINA_MTA.equals(codBreveGenereMacchina));
  }

%>

