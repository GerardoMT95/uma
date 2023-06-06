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



<%

  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application)

                .getHtmpl("ditta/layout/dettaglioAllevamentoPOP.htm");
%><%@include file = "/include/menu.inc" %><%
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

  AllevamentoVO allevamentoVO=umaClient.findAllevamentoByID(new Long(request.getParameter("idAllevamento")));

  UtenteIrideVO utenteIrideVO=null;

  try

  {

    utenteIrideVO=umaClient.getUtenteIride(allevamentoVO.getExtIdUtenteAggiornamento());

  }

  catch(Exception e)

  {

    utenteIrideVO=new UtenteIrideVO();

  }

  Vector lavorazioniVO=umaClient.getLavorazioniPraticate(allevamentoVO.getIdAllevamento());

  int lavSize=lavorazioniVO==null?0:lavorazioniVO.size();

  StringBuffer lavorazioniDesc=new StringBuffer();

  for(int i=0;i<lavSize;i++)

  {

    LavorazioniPraticateVO lav=(LavorazioniPraticateVO) lavorazioniVO.get(i);

    SolmrLogger.debug(this,lav);

    lavorazioniDesc.append(lav.getTipoLitriAllevamentoVO().getTipoLavorazioni().getDescription());

    if (lavSize>0 && i <lavSize-1)

    {

      lavorazioniDesc.append(", ");

    }

  }

  htmpl.set("specie",allevamentoVO.getSpecie());

  htmpl.set("categoria",allevamentoVO.getCategoria());

  htmpl.set("quantita",""+allevamentoVO.getQuantita());
  
  if(allevamentoVO.getFlagSoccida() != null && allevamentoVO.getFlagSoccida().equals(SolmrConstants.FLAG_SI))
      htmpl.set("soccida", "Si");

  htmpl.set("dataCarico",dateStr(allevamentoVO.getDataCarico()));

  htmpl.set("dataScarico",dateStr(allevamentoVO.getDataScarico()));

  htmpl.set("dataInizioValidita",dateStr(allevamentoVO.getDataInizioVal()));

  htmpl.set("dataFineValidita",dateStr(allevamentoVO.getDataFineVal()));

  htmpl.set("unitaDiMisura",allevamentoVO.getTipoCategoriaAnimaleVO().getUnitaMisura());

  htmpl.set("lavorazioniPraticate",lavorazioniDesc.toString());

  htmpl.set("note",allevamentoVO.getNote());

  htmpl.set("dataAggiornamento",dateStr(allevamentoVO.getDataAggiornamento()));

  htmpl.set("nomeUtente",utenteIrideVO.getDenominazione());

  htmpl.set("nomeEnte",utenteIrideVO.getDescrizioneEnteAppartenenza());
  boolean bIsAfterUMAL = isAfterUMAL(session);
  if (bIsAfterUMAL && allevamentoVO.getExtIdConsistenza()!=null &&
  allevamentoVO.getDataConsistenza()!=null)
  {
    htmpl.newBlock("blkConsistenza");
    htmpl.set("blkConsistenza.dataConsistenza",DateUtils.formatDate(allevamentoVO.getDataConsistenza()));
  }

  out.print(htmpl.text());

%>

<%!

  private String dateStr(Date date)

  {

    if (date!=null)

    {

      return DateUtils.formatDate(date);

    }

    else

    {

      return "";

    }

  }

  private boolean isAfterUMAL(HttpSession session)
  {
    HashMap parametriUM=(HashMap)session.getAttribute("parametriUM");

    Date umal=(Date)parametriUM.get(SolmrConstants.PARAMETRO_GESTIONE_ALLEVAMENTI);
    Date toDay = new Date();
    return toDay.after(umal);
  }

%>

