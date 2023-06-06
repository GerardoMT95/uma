<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@page import="it.csi.solmr.util.DateUtils"%>
<%@page import="it.csi.solmr.dto.CodeDescr"%>
<%@page import="it.csi.solmr.etc.*"%>
<%@page import="java.util.Vector"%>
<%@page import="it.csi.solmr.util.StringUtils"%>
<%@page import="it.csi.solmr.util.ValidationErrors"%>
<%@page import="it.csi.solmr.util.HtmplUtil"%>
<%@page import="java.util.HashMap"%>
<%
  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(
      "ditta/layout/modificaAllevamentoMultipla.htm");
%><%@include file="/include/menu.inc"%>
<%
  AllevamentoVO allevamenti[] = (AllevamentoVO[]) request
      .getAttribute("allevamenti");
  Vector<CodeDescr> lavorazioniPossibili = (Vector<CodeDescr>) request
      .getAttribute("lavorazioniPossibili");
  int len = allevamenti.length;
  ValidationErrors errors = (ValidationErrors) request
      .getAttribute("errors");
  boolean hasErrors = errors != null
      && errors.size() > 0
      && !(errors.size() == 1 && errors.get("lavorazioniEffettuate") != null);
  if (hasErrors)
  {
    htmpl.newBlock("blkErrore");
    htmpl.set("spanLavorazioni", "1");
    //    htmpl.set("spanLineaVuot", "5");
  }
  else
  {
    htmpl.set("spanLavorazioni", "2");
  }
  HashMap<?, ?> mapDescrizioniLavorazioni = (HashMap<?, ?>) request
      .getAttribute("mapDescrizioniLavorazioni");
  if (mapDescrizioniLavorazioni == null)
  {
    mapDescrizioniLavorazioni = new HashMap<String, String>();
  }
  for (int i = 0; i < len; ++i)
  {
    AllevamentoVO allevamentoVO = allevamenti[i];
    htmpl.newBlock("blkHidden");
    htmpl.set("blkHidden.name", "radiobutton");
    htmpl.set("blkHidden.value", allevamentoVO.getIdAllevamento()
        .toString());
    htmpl.newBlock("blkAllevamento");
    htmpl.set("blkAllevamento.specie", allevamentoVO.getSpecie());
    TipoCategoriaAnimaleVO tcaVO = allevamentoVO
        .getTipoCategoriaAnimaleVO();
    if (tcaVO != null)
    {
      htmpl.set("blkAllevamento.categoria", tcaVO.getDescrizione());
      htmpl.set("blkAllevamento.unitaDiMisura", tcaVO.getUnitaMisura());
    }
    htmpl.set("blkAllevamento.quantita", String.valueOf(allevamentoVO.getQuantita()));
    
    if(allevamentoVO.getFlagSoccida() != null && allevamentoVO.getFlagSoccida().equals(SolmrConstants.FLAG_SI))
      htmpl.set("blkAllevamento.soccida", "Si");
    
    htmpl.set("blkAllevamento.dataCarico", DateUtils
        .formatDate(allevamentoVO.getDataCarico()));
    htmpl.set("blkAllevamento.descLavorazioni",
        StringUtils.checkNull(mapDescrizioniLavorazioni.get(allevamentoVO
            .getIdAllevamento().toString())));
    if (hasErrors)
    {
      htmpl.newBlock("blkAllevamento.blkErrore");
      HtmplUtil.writeIndexedValidationError(htmpl, request, errors,
          "blkAllevamento.blkErrore", "idAllevamento", allevamentoVO
              .getIdAllevamento().longValue());
    }
    else
    {
      htmpl.set("blkAllevamento.spanLavorazioni", "2");
    }
  }
  int size = lavorazioniPossibili == null ? 0 : lavorazioniPossibili.size();
  String lavorazioniEffettuate[] = request
      .getParameterValues("lavorazioniEffettuate");
  for (int i = 0; i < size; ++i)
  {
    CodeDescr lavorazioneCD = lavorazioniPossibili.get(i);
    htmpl.newBlock("blkLavorazioni");
    String code = lavorazioneCD.getCode().toString();
    htmpl.set("blkLavorazioni.code", code);
    htmpl.set("blkLavorazioni.desc", lavorazioneCD.getDescription());
    if (StringUtils.in(code, lavorazioniEffettuate))
    {
      htmpl.newBlock("blkLavorazioniPraticate");
      htmpl.set("blkLavorazioniPraticate.code", code);
      htmpl.set("blkLavorazioniPraticate.desc", lavorazioneCD
          .getDescription());
    }
  }
  String pageFrom = request.getParameter("pageFrom");
  if (pageFrom == null)
  {
    pageFrom = request.getHeader("referer");
  }
  htmpl.set("pageFrom", pageFrom);
  HtmplUtil.setErrors(htmpl, (ValidationErrors) request
      .getAttribute("errors"), request);
%><%=htmpl.text()%>