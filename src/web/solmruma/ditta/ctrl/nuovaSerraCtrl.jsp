<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<jsp:useBean id="serraVO" scope="page" class="it.csi.solmr.dto.uma.SerraVO">
  <jsp:setProperty name="serraVO" property="*" />
</jsp:useBean>

<%
  String iridePageName = "nuovaSerraCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  SolmrLogger.debug(this,"nuovaSerraCtrl.jsp");
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  String viewUrl="/ditta/view/nuovaSerraView.jsp";
  String elenco="/ditta/ctrl/elencoSerreCtrl.jsp";
  String elencoBis="/ditta/ctrl/elencoSerreBisCtrl.jsp";
  String elencoHtm="../../ditta/layout/elencoSerre.htm";
  String elencoBisHtm="../../ditta/layout/elencoSerreBis.htm";

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  request.setAttribute("serraVO",serraVO);
  if (request.getParameter("salva.x")!=null)
  {
    SolmrLogger.debug(this,"");

    ValidationErrors errors=serraVO.validateInsert();
    SolmrLogger.debug(this,"errors.size()="+errors.size());
    if (errors.size()!=0)
    {
      request.setAttribute("errors",errors);
    }
    else
    {
      try
      {
        serraVO.setIdDittaUma(idDittaUma);
        serraVO.setDataInizioValidita(new Date());
        serraVO.setDataAggiornamento(new Date());
        serraVO.setExtIdUtenteAggiornamento(ruoloUtenza.getIdUtente());

        umaFacadeClient.insertSerra(serraVO, ruoloUtenza, idDittaUma);
      }
      catch(SolmrException sexc)
      {
        SolmrLogger.debug(this,"catch SolmrEception sexc");
        if (sexc.getValidationErrors()!=null){
          SolmrLogger.debug(this,"        if (sexc.getValidationErrors()!=null)");
          ValidationErrors vErrors = sexc.getValidationErrors();
          if (vErrors.size()!=0)
          {
            SolmrLogger.debug(this,"          if (vErrors.size()!=0)");
            request.setAttribute("errors", vErrors);
            %><jsp:forward page="<%=viewUrl%>"/><%
            return;
          }
        }else{
          SolmrLogger.debug(this,"          else (vErrors.size()!=0)");
          ValidationException valEx=new ValidationException("Eccezione di validazione"+sexc.getMessage(),viewUrl);
          valEx.addMessage(sexc.toString(),"exception");
          throw valEx;
        }
        SolmrLogger.debug(this,"        dopo if (sexc.getValidationErrors()!=null)");
      }
      catch(Exception e)
      {
        SolmrLogger.debug(this,"catch(Exception e)");
        ValidationException valEx=new ValidationException("Eccezione di validazione"+e.getMessage(),viewUrl);
        valEx.addMessage(e.toString(),"exception");
        throw valEx;
      }

      String forwardUrl=elencoHtm;
      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
      {
        forwardUrl=elencoBisHtm;
      }

      session.setAttribute("notifica","Inserimento eseguito con successo");
      response.sendRedirect(forwardUrl);
      return;
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
      SolmrLogger.debug(this,"\n\n\nsettaggio nuova dataCarico");
      SolmrLogger.debug(this,"dataCarico="+serraVO.getDataCaricoStr()+"\n\n\n");
      if (serraVO.getDataCaricoStr()==null)
      {
        serraVO.setDataCaricoStr(DateUtils.formatDate(new Date()));
      }
      request.setAttribute("serraVO",serraVO);
    }
  }
%>
<jsp:forward page="<%=viewUrl%>"/>
<%!
private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException(msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}
%>