<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>

<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.Vector" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%!
  public static final String LAYOUT="ditta/layout/stampa_26.htm";
%>

<%

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  DittaUMAAziendaVO dumaa = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

  Long idUtente = ruoloUtenza.getIdUtente();

  String idProvinciaUma = ruoloUtenza.getIstatProvincia();
  boolean isConferma=request.getParameter("conferma")!=null;

  if (!isConferma)
  {
    if (ruoloUtenza.isUtenteIntermediario())
    {
      htmpl.newBlock("blkLabelData");
      htmpl.set("blkLabelData.dataUtente",DateUtils.formatDate(new Date()));
    }
    else
    {
      htmpl.newBlock("blkInputData");
      htmpl.set("blkInputData.dataUtente",DateUtils.formatDate(new Date()));
    }
  }
  else
  {
    if (ruoloUtenza.isUtenteIntermediario())
    {
      htmpl.newBlock("blkLabelData");
      htmpl.set("blkLabelData.dataUtente",DateUtils.formatDate(new Date()));
    }
    else
    {
      htmpl.newBlock("blkInputData");
      htmpl.set("blkInputData.dataUtente",request.getParameter("dataUtente"));
    }
  }
    Boolean isRistampa=(Boolean)request.getAttribute("isRistampa");
    if (isConferma && isRistampa!=null && isRistampa.booleanValue())
    {
      writeMotivazioniRistampa(htmpl,request);
    }

  if (request.getAttribute("errors") != null) {

    HtmplUtil.setErrors(htmpl,(ValidationErrors) request.getAttribute("errors") , request);

  } else {

    if (isConferma) {

      htmpl.set("idUtente", idUtente.toString());

      htmpl.set("idProvinciaUma", idProvinciaUma);

      htmpl.set("dataRiferimento", (String) request.getParameter("dataUtente"));
      if (request.getAttribute("noPdf")==null) // testo solo la sua NON
      // esistenza non il valore. (questo flag indica se ci sono motivi per  non
      // visualizzare il pdf. Viene inserito in request quando l'utente passa
      // dalla pagina iniziale in cui c'è da inserire solo la data alla stessa
      // in cui bisogna però inserire anche il motivo dato che il sistema ha
      // rilevato che non è una ristampa).
      {
        htmpl.set("scriptModello26", "stampaModello26()");
      }

    }

  }

  HtmplUtil.setValues(htmpl, request, (String) session.getAttribute("pathToFollow"));

  htmpl.set("CUAA", dumaa.getCuaa());

  htmpl.set("denominazione", dumaa.getDenominazione());

  htmpl.set("dittaUMA", dumaa.getDittaUMA().toString());

  htmpl.set("umaTipoDitta", dumaa.getTipiDitta());

  htmpl.set("siglaProvUMA", dumaa.getSiglaProvUMA());

  response.setContentType("text/html");

  out.println(htmpl.text());

%><%!
  private void writeMotivazioniRistampa(Htmpl htmpl, HttpServletRequest request)
  throws SolmrException
  {
    htmpl.newBlock("blkComboMotivazione");
    Vector motivazioni=new UmaFacadeClient().getMotivazioniRistampaValide();
    int size=motivazioni==null?0:motivazioni.size();
    String selected=request.getParameter("idMotivazioneRistampa");
    for(int i=0;i<size;i++)
    {
      CodeDescr motivazione=(CodeDescr)motivazioni.get(i);
      String code=motivazione.getCode().toString(); // Non può essere null
      htmpl.newBlock("blkComboMotivazione.blkOption");
      htmpl.set("blkComboMotivazione.blkOption.code",code);
      htmpl.set("blkComboMotivazione.blkOption.desc",motivazione.getDescription());
      if (code.equals(selected))
      {
        htmpl.set("blkComboMotivazione.blkOption.selected",SolmrConstants.HTML_SELECTED,null);
      }
    }
    htmpl.set("idMotivazioneRistampa",selected);
  }
%>