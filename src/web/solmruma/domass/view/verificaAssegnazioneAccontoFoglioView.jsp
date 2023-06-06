<%@ page language="java" contentType="text/html" isErrorPage="true"%><%@ page
	import="it.csi.solmr.dto.uma.*"%><%@ 
page import="it.csi.jsf.htmpl.*"%><%@ 
page import="java.util.*"%><%@ 
page import="it.csi.solmr.util.*"%><%!
  public static final String LAYOUT="/domass/layout/verificaAssegnazioneAccontoFoglio.htm"; %>
<%
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file="/include/menu.inc"%>
<%
  Vector numFogliResult = null;
  numFogliResult = (Vector) request.getAttribute("numFogliResult");

  if (numFogliResult != null)
  {
    int size = numFogliResult.size();
    if (size > 0)
    {
      htmpl.newBlock("blk_FoglioRigaIntestazione");
    }
    int cnt = 0;
    for (int i = 0; i < size; i++)
    {
      NumerazioneFoglioVO numFoglioVO = (NumerazioneFoglioVO) numFogliResult
          .get(i);

      htmpl.newBlock("blk_FoglioRiga");
      htmpl.set("blk_FoglioRiga.idNumerazioneFoglio", ""
          + numFoglioVO.getIdNumerazioneFoglio());
      htmpl.set("blk_FoglioRiga.Denominazione", ""
          + numFoglioVO.getDenominazione());
      htmpl
          .set("blk_FoglioRiga.Foglio", "" + numFoglioVO.getNumeroFoglio());
      htmpl.set("blk_FoglioRiga.Riga", "" + numFoglioVO.getNumeroRiga());
      cnt = i + 1;
      htmpl.set("blk_FoglioRiga.numFoglio", "numFoglio" + cnt);
      htmpl.set("blk_FoglioRiga.denominazione", "denominazione" + cnt);
    }
  }

  Integer annoDiRiferimento = DateUtils.getCurrentYear();
  htmpl.set("annoDiRiferimento", annoDiRiferimento.toString());
  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,
      exception);
  ValidationErrors errors = (ValidationErrors) request
      .getAttribute("errors");
  HtmplUtil.setErrors(htmpl, errors, request);
  HtmplUtil.setValues(htmpl, request);
%><%=htmpl.text()%>