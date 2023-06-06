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
<%@ page import="it.csi.solmr.etc.anag.AnagErrors" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<jsp:useBean id="serraVO" scope="page"
             class="it.csi.solmr.dto.uma.SerraVO">
  <jsp:setProperty name="serraVO" property="*" />
</jsp:useBean>
<%

  String iridePageName = "confermaEliminaSerraCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  UmaFacadeClient umaClient = new UmaFacadeClient();
  String url="/ditta/ctrl/elencoSerreCtrl.jsp";
  String viewUrl="/ditta/view/confermaEliminaSerraView.jsp";
  String elencoCtrl="/ditta/ctrl/elencoSerreCtrl.jsp";
  String elencoBisCtrl="/ditta/ctrl/elencoSerreBisCtrl.jsp";
  String elencoHtm="../layout/elencoSerre.htm";
  String elencoBisHtm="../layout/elencoSerreBis.htm";
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  SolmrLogger.debug(this,"\n\n\n\n\n####################");
  SolmrLogger.debug(this,"request.getParameter(\"idSerra\"): "+request.getParameter("idSerra"));


  String validateUrl=elencoCtrl;
  if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
  {
    validateUrl=elencoBisCtrl;
  }

  if (request.getParameter("conferma.x")!=null)
  {
    SolmrLogger.debug(this,"conferma.x");
    // Eliminazione serra
    Long idSerra=null;
    try
    {
      idSerra=new Long(request.getParameter("idSerra"));
      GregorianCalendar calendar=new GregorianCalendar();
      calendar.setTime(new Date());
      umaClient.deleteSerra(idSerra,idDittaUma,ruoloUtenza);
    }
    catch(Exception e)
    {
      throwValidation(e.getMessage(),validateUrl);
    }

    String forwardUrl=elencoHtm;
    if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
    {
      forwardUrl=elencoBisHtm;
    }

    SolmrLogger.debug(this,"\n\n\n#################forwardUrl: "+forwardUrl);
    session.setAttribute("notifica","Eliminazione eseguita con successo");
    response.sendRedirect(forwardUrl);
    return;
  }
  else{
    if (request.getParameter("annulla.x")!=null)
    {
      SolmrLogger.debug(this,"annulla.x");

      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
      {
        SolmrLogger.debug(this,"elencoBisHtm: "+elencoBisHtm);
        response.sendRedirect(elencoBisHtm);
      }
      else
      {
        SolmrLogger.debug(this,"elencoHtm: "+elencoHtm);
        response.sendRedirect(elencoHtm);
      }
      return;
    }
    else{
      SolmrLogger.debug(this,"visualizza");
      %>
      <jsp:forward page="<%=viewUrl%>"/>
      <%
    }
  }
%>
<%!
private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException(msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}
%>
