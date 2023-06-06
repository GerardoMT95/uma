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
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<jsp:useBean id="allevamentoVO" scope="page" class="it.csi.solmr.dto.uma.AllevamentoVO">
  <jsp:setProperty name="allevamentoVO" property="*" />
</jsp:useBean>
<%

  String iridePageName = "nuovoAllevamentoCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  UmaFacadeClient umaClient = new UmaFacadeClient();
  String url="/ditta/ctrl/elencoAllevamentoCtrl.jsp";
  String viewUrl="/ditta/view/nuovoAllevamentoView.jsp";
  String elenco="/ditta/ctrl/elencoAllevamentoCtrl.jsp";
  String elencoBis="/ditta/ctrl/elencoAllevamentoBisCtrl.jsp";
  String elencoHtm="../../ditta/layout/elencoAllevamento.htm";
  String elencoBisHtm="../../ditta/layout/elencoAllevamentoBis.htm";
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  request.setAttribute("allevamentoVO",allevamentoVO);
  SolmrLogger.debug(this,"\nEntering nuovoAllevamentoCtrl...\n");
  if (request.getParameter("salva.x")!=null)
  {
    SolmrLogger.debug(this,"\nEntering insert...\n");
    Vector lavorazioniPraticate=new Vector();
    String lp[]=request.getParameterValues("lavorazioniEffettuate");
    SolmrLogger.debug(this,"lp="+lp);
    if (lp!=null)
    {
      SolmrLogger.debug(this,"LAVORAZIONI PRATICATE:");
      for(int idx=0;idx<lp.length;idx++)
      {
        LavorazioniPraticateVO lavorazioniVO=new LavorazioniPraticateVO();
        try
        {
          SolmrLogger.debug(this,lp[idx]);
        lavorazioniPraticate.add(idx,new Long(lp[idx]));
        }
        catch(Exception e)
        {

        }
      }
    }
    request.setAttribute("lavorazioniPraticate",lavorazioniPraticate);
    SolmrLogger.debug(this,"*******************************VALIDATION*******************************");
    ValidationErrors errors=allevamentoVO.validate();
    if (lavorazioniPraticate!=null && lavorazioniPraticate.size()==0)
    {
      errors.add("lavorazioniEffettuate",new ValidationError("Inserire almeno una lavorazione"));
    }
    if (errors.size()!=0)
    {
      request.setAttribute("errors",errors);
    }
    else
    {
      try
      {
        umaClient.insertAllevamento(idDittaUma,allevamentoVO,lavorazioniPraticate,ruoloUtenza);
      }
      catch(SolmrException e)
      {
        errors= e.getValidationErrors();
        SolmrLogger.debug(this,"((((((((((((((((((((((((((((((((errors="+errors+")))))))))))))))))))))))))))))))))))))");
        if (errors!=null)
        {
          request.setAttribute("errors",errors);
          %><jsp:forward page="<%=viewUrl%>"/><%
          return;
        }
        ValidationException valEx=new ValidationException("",viewUrl);
        SolmrLogger.debug(this,"\n\nException="+e.getMessage()+"\n\n");
        valEx.addMessage(e.getMessage(),"exception");
        throw valEx;
      }
      String forwardUrl=elencoHtm;
      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
      {
        forwardUrl=elencoBisHtm;
      }
      session.setAttribute("notifica","Inserimento eseguito con successo");
      response.sendRedirect(forwardUrl);
//      response.sendRedirect(forwardUrl+"?notifica=inserimento");
      return;
/*      ValidationException valEx=new ValidationException("",forwardUrl);
      valEx.addMessage("Inserimento eseguito con successo","exception");
      throw valEx;*/
    }
  }
  else
  {
    if (request.getParameter("annulla.x")!=null)
    {
      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
      {
        response.sendRedirect(elencoBisHtm);
      }
      else
      {
        response.sendRedirect(elencoHtm);
      }
      return;
    }
    else
    {
      if (allevamentoVO.getDataCaricoStr()==null)
      {
        allevamentoVO.setDataCaricoStr(DateUtils.formatDate(new Date()));
      }
      request.setAttribute("allevamentoVO",allevamentoVO);
    }
  }
%>
<jsp:forward page="<%=viewUrl%>"/>
