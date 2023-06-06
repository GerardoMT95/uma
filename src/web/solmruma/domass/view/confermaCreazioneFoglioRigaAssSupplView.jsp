
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
                .getHtmpl("domass/layout/confermaCreazioneFoglioRigaAssSuppl.htm");
%><%@include file = "/include/menu.inc" %><%
  Long idAssCarb=null;
  if ( request.getAttribute("idAssCarb") != null){
    idAssCarb = (Long) request.getAttribute("idAssCarb");
    SolmrLogger.debug(this,"idAssCarb: "+idAssCarb);
    htmpl.set("idAssCarb",""+idAssCarb);
  }
  Long idNumerazioneFoglio =null;
  if (request.getParameter("radiobutton")!=null){
    idNumerazioneFoglio=new Long(request.getParameter("radiobutton"));
    SolmrLogger.debug(this,"idNumerazioneFoglio: "+idNumerazioneFoglio);
    htmpl.set("idNumerazioneFoglio",""+idNumerazioneFoglio);
  }
  Long idDomAss=null;
  if (request.getParameter("idDomAss")!=null){
    idDomAss=new Long(request.getParameter("idDomAss"));
    SolmrLogger.debug(this,"idDomAss: "+idDomAss);
    htmpl.set("idDomAss",""+idDomAss);
  }
  String msgFoglioRiga=null;
  if (request.getParameter("msgFoglioRiga")!=null){
    msgFoglioRiga=request.getParameter("msgFoglioRiga");
    SolmrLogger.debug(this,"\n\n\n******msgFoglioRiga: "+msgFoglioRiga);
    htmpl.set("msgFoglioRiga",""+msgFoglioRiga);
  }
  else{
    SolmrLogger.debug(this,"\n\n\n******msgFoglioRiga: "+msgFoglioRiga);
  }

  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
  out.print(htmpl.text());
%>

