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

  SolmrLogger.debug(this,"macchinaUsataNonTrovataDatiCasoMatrice.jsp - Begin");



  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("macchina/layout/MacchinaUsataNonTrovataDatiCasoMatrice.htm");
%><%@include file = "/include/menu.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  Vector genere=new Vector();

  HashMap common = (HashMap) session.getAttribute("common");

  MacchinaVO macchinaVO=(MacchinaVO) common.get("macchinaVO");

  MatriceVO matriceVO=(MatriceVO)common.get("matriceVO");

//  htmpl.set("matricolaTelaioDisable","disabled");

  HtmplUtil.setValues(htmpl, matriceVO, request.getParameter("pathToFollow"));

  if (request.getParameter("matricolaMotore")==null && request.getParameter("matricolaTelaio")==null)

  {

    HtmplUtil.setValues(htmpl, macchinaVO, request.getParameter("pathToFollow"));

  }

  else

  {

    HtmplUtil.setValues(htmpl, request, request.getParameter("pathToFollow"));

  }

  htmpl.set("showMatricolaTelaio", ""+(!matricolaTelaioIsNotValorizable(matriceVO)));

  htmpl.set("showMatricolaMotore", ""+(!matricolaMotoreIsNotValorizable(matriceVO)));

  HtmplUtil.setErrors(htmpl, (ValidationErrors) request.getAttribute("errors"),request);

  SolmrLogger.debug(this,"errors="+(ValidationErrors) request.getAttribute("errors"));

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

<%=htmpl.text()%>

