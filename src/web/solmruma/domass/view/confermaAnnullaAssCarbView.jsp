
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
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%!
  private static final String NEXT_PAGE="../layout/dettaglioAssegnazioniSupplementare.htm";
  private String PREV_PAGE="../layout/dettaglioAssegnazioniSupplementare.htm";
%>
<%
  SolmrLogger.debug(this,"Entering confermaAnnullaAssCarbView.jsp");
  Htmpl htmpl = HtmplFactory.getInstance(application)
                .getHtmpl("/domass/layout/confermaAnnullaAssCarb.htm");
%><%@include file = "/include/menu.inc" %>
<%  

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  UmaFacadeClient client = new UmaFacadeClient();

  if(request.getParameter("pageFrom")!=null)
  {
    SolmrLogger.debug(this,"View - if(request.getParameter(\"pageFrom\")!=null)");
    PREV_PAGE=request.getParameter("pageFrom");
  }
  else{
    SolmrLogger.debug(this,"View - else(request.getParameter(\"pageFrom\")!=null)");
    PREV_PAGE=(String) session.getAttribute("pageFrom");
  }
  SolmrLogger.debug(this,"\n\n\n\n\n*+*+*+*+*+*+*+**+*+*+*");
  SolmrLogger.debug(this,"PREV_PAGE: "+PREV_PAGE);

  SolmrLogger.debug(this,"#################################################################");
  SolmrLogger.debug(this,"confermaAnnullaAssCarbView - request.getAttribute(\"idAssCarb\") "+request.getAttribute("idAssCarb"));
  SolmrLogger.debug(this,"#################################################################");

  htmpl.set("idAssCarb", ((Long)request.getAttribute("idAssCarb")).toString());
  htmpl.set("pageFrom", PREV_PAGE);

  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
  out.print(htmpl.text());
%>

