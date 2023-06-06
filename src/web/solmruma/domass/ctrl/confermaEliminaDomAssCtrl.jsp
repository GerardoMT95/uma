<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
  String iridePageName = "confermaEliminaDomAssCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%
  UmaFacadeClient umaClient = new UmaFacadeClient();
  String viewUrl = "/domass/view/confermaEliminaDomAssView.jsp";
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  String elencoDomandeHtmlUrl = "../layout/assegnazioni.htm";
  String elencoDomandeUrl = "/domass/ctrl/assegnazioniCtrl.jsp";
  String dettaglioDomandaUrl = "/domass/ctrl/dettaglioDomandaCtrl.jsp";
  String dettaglioVerificaAssegnazioneUrl = "/domass/ctrl/dettaglioVerificaAssegnazioneCtrl.jsp";
  String dettaglioAssegnazioniSupplementareUrl = "/domass/ctrl/dettaglioAssegnazioniSupplementareCtrl.jsp";
  String dettaglioCarburanteAssegnabileUrl = "/domass/ctrl/carburanteAssegnabileCtrl.jsp";
  Long idDomAss = null;
  if (request.getParameter("idDomAss") != null)
  {
    idDomAss = new Long(request.getParameter("idDomAss"));
  }
  if (request.getParameter("conferma.x") != null)
  {
    SolmrLogger.debug(this,
        "[confermaEliminaDomAssCtrl::service] conferma.x");
    // Conferma Eliminazione Domanda
    try
    {
      SolmrLogger.debug(this,
          "[confermaEliminaDomAssCtrl::service] request.getParameter(\"idDomAss\"): "
              + request.getParameter("idDomAss"));
      GregorianCalendar calendar = new GregorianCalendar();
      calendar.setTime(new Date());
      SolmrLogger
          .debug(
              this,
              "[confermaEliminaDomAssCtrl::service] \n\n\n\n\n***********************************+");
      SolmrLogger.debug(this,
          "[confermaEliminaDomAssCtrl::service] umaClient.deleteDomAss("
              + idDomAss + ", ruoloUtenza);");
      umaClient.deleteDomAss(idDomAss, ruoloUtenza);
    }
    catch (Exception e)
    {
      SolmrLogger.debug(this,"--- Exception in confermaEliminaDomAssCtrl ="+e.getMessage());
      ValidationErrors vErr = new ValidationErrors();
      vErr.add("error", new ValidationError(e.getMessage()));
      request.setAttribute("errors", vErr);
      SolmrLogger.debug(this,
          "[confermaEliminaDomAssCtrl::service] \n\n\nelencoDomandeUrl: "
              + elencoDomandeUrl);
%><jsp:forward page="<%=elencoDomandeUrl%>" />
<%
  return;
    }
    SolmrLogger.debug(this,
        "[confermaEliminaDomAssCtrl::service] \n\n\nelencoDomandeUrl: "
            + elencoDomandeUrl);
    session.setAttribute("notifica", "Eliminazione eseguita con successo");
    response.sendRedirect(elencoDomandeHtmlUrl);
    return;
  }
  else
  {
    if (request.getParameter("indietro.x") != null)
    {
      // Annulla Eliminazione Domanda
      SolmrLogger.debug(this,
          "[confermaEliminaDomAssCtrl::service] indietro.x");
      SolmrLogger.debug(this,
          "[confermaEliminaDomAssCtrl::service] \n\n\nelencoDomandeHtmlUrl: "
              + elencoDomandeHtmlUrl);
      if (request.getParameter("annullaBuoni").equalsIgnoreCase(
          "elencoDomande"))
      {
        //Elenco assegnazioni
        SolmrLogger
            .debug(
                this,
                "[confermaEliminaDomAssCtrl::service] request.getParameter(\"annullaBuoni\").equalsIgnoreCase(\"elencoDomande\")");
%>
<jsp:forward page="<%=elencoDomandeUrl%>" />
<%
  return;
      }
      else
      {
        if (request.getParameter("annullaBuoni").equalsIgnoreCase(
            "dettaglioDomanda"))
        {
          //Dettaglio domanda
          SolmrLogger
              .debug(
                  this,
                  "[confermaEliminaDomAssCtrl::service] request.getParameter(\"annullaBuoni\").equalsIgnoreCase(\"dettaglioDomanda\")");
%>
<jsp:forward page="<%=dettaglioDomandaUrl%>" />
<%
  return;
        }
        else
        {
          if (request.getParameter("annullaBuoni").equalsIgnoreCase(
              "dettaglioVerificaAssegnazione"))
          {
            //Dettaglio Verifica Assegnazioni
            SolmrLogger
                .debug(
                    this,
                    "[confermaEliminaDomAssCtrl::service] request.getParameter(\"annullaBuoni\").equalsIgnoreCase(\"dettaglioVerificaAssegnazione\")");
%>
<jsp:forward page="<%=dettaglioVerificaAssegnazioneUrl%>" />
<%
  return;
          }
          else

          {
            if (request.getParameter("annullaBuoni").equalsIgnoreCase(
                "dettaglioAssegnazioniSupplementari"))
            {
              //Dettaglio Assegnazioni Supplementare
              SolmrLogger
                  .debug(
                      this,
                      "[confermaEliminaDomAssCtrl::service] request.getParameter(\"annullaBuoni\").equalsIgnoreCase(\"dettaglioAssegnazioniSupplementare\")");
%>
<jsp:forward page="<%=dettaglioAssegnazioniSupplementareUrl%>" />
<%
  return;
            }
            else
            {
              if (request.getParameter("annullaBuoni").equalsIgnoreCase(
                  "carburanteAssegnabile"))
              {
                //Dettaglio Assegnazioni Supplementare
                //System.err.println("dettaglioCarburanteAssegnabileUrl="
                    //+ dettaglioCarburanteAssegnabileUrl);
%>
<jsp:forward page="<%=dettaglioCarburanteAssegnabileUrl%>">
	<jsp:param name="pageFrom" value="../layout/assegnazioni.htm" />
</jsp:forward>
<%
  return;

              }
            }
          }
        }
      }
      //response.sendRedirect(elencoDomandeHtmlUrl);
      return;
    }
    else
    {
      SolmrLogger.debug(this,
          "[confermaEliminaDomAssCtrl::service] visualizza");
%>
<jsp:forward page="<%=viewUrl%>" />
<%
  }
  }
%>