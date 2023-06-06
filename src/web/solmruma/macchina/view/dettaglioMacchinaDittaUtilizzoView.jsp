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

  SolmrLogger.debug(this,"----- dettaglioMacchinaDittaUtilizzoView.jsp ----- inizio");
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application)
                .getHtmpl("macchina/layout/dettaglioMacchinaDittaUtilizzo.htm");
%>
  <%@include file = "/include/menu.inc" %>
<%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  if (ruoloUtenza!=null && ruoloUtenza.isUtenteProvinciale())
  {
    htmpl.newBlock("blkSoloProvincialeRO");
    if(ruoloUtenza.isReadWrite()&&
       ruoloUtenza.getIstatProvincia().equals(dittaUMAAziendaVO.getProvUMA()))
      htmpl.newBlock("blkSoloProvincialeRW");
  }

  MacchinaVO macchinaVO = (MacchinaVO)session.getAttribute("dittaMacchinaVO");
  Vector v_utilizzi = (Vector)session.getAttribute("v_dittaMacchinaUtilizzi");
  if(macchinaVO != null)
  {
    htmpl.set("idMacchina", macchinaVO.getIdMacchina());
    it.csi.solmr.presentation.security.AutorizzazioneMacchine.writeDatiMacchina(htmpl, macchinaVO);
    if(v_utilizzi!=null)
    {
      for(int i=0; i<v_utilizzi.size();i++)
      {
        UtilizzoVO uVO = (UtilizzoVO)v_utilizzi.elementAt(i);
        htmpl.newBlock("rigaUtilizzo");
        htmpl.set("rigaUtilizzo.idUtilizzo",uVO.getIdUtilizzo());
        String ditta = uVO.getSiglaProvUma()+" - "+uVO.getDittaUma();
        htmpl.set("rigaUtilizzo.ditta",ditta);
        htmpl.set("rigaUtilizzo.dataCarico",uVO.getDataCarico());
        htmpl.set("rigaUtilizzo.dataScarico",StringUtils.checkNull(uVO.getDataScarico()));
        htmpl.set("rigaUtilizzo.motivoScarico",StringUtils.checkNull(uVO.getDescScarico()));

        String ultimaModifica = uVO.getDataAggiornamento();
        UtenteIrideVO utenteIrideVO = umaClient.getUtenteIride(uVO.getIdUtenteAggiornamentoLong());
        ultimaModifica += composeString(utenteIrideVO.getDenominazione(),utenteIrideVO.getDescrizioneEnteAppartenenza());
        htmpl.set("rigaUtilizzo.ultimaModifica",ultimaModifica);
      }
    }
  }

  ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");
  SolmrLogger.debug(this,"errors="+errors);
  HtmplUtil.setErrors(htmpl,errors,request);
  out.print(htmpl.text());

%>

<%!

  private String composeString(String first, String second)
  {
    String result = "";
    if(first != null && !first.equals(""))
    {
      result = first;
      if(second != null && !second.equals(""))
        result += " - " + second;
    }
    else if(second != null && !second.equals(""))
      result = second;

    if(!result.equals(""))
      result = " ("+result+")";

    return result;
  }

%>