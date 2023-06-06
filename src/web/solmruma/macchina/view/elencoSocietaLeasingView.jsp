<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.jsf.htmpl.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>

<%
  SolmrLogger.debug(this,"Inizio elencoSocietaLeasingView.jsp");
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application)
                .getHtmpl("macchina/layout/elencoSocietaLeasing.htm");
%><%@include file = "/include/menu.inc" %><%
  Vector comuni=null;

  String partitaIVA=request.getParameter("partitaIVA");
  String ragioneSociale=request.getParameter("ragioneSociale");
  if (partitaIVA==null)
  {
    partitaIVA="";
  }
  if (ragioneSociale==null)
  {
    ragioneSociale="";
  }
  Vector ditteLeasing=null;
  try
  {
    SolmrLogger.debug(this,"calling getDittaLeasing(\""+partitaIVA+"\",\""+ragioneSociale+"\")");
    ditteLeasing=umaClient.getElencoDitteLeasing(partitaIVA, ragioneSociale);
    SolmrLogger.debug(this,"ditteLesing.size()="+ditteLeasing.size());
  }
  catch(Exception e)
  {
    ditteLeasing=new Vector();
    SolmrLogger.debug(this,"e.getMessage()="+e.getMessage());
  }
  int vectSize=ditteLeasing.size();
  htmpl.setStringProcessor(new CustomHTMLStringProcessor());
  for(int i=0;i<vectSize;i++)
  {
    htmpl.newBlock("blkSocietaLeasing");
    AnagAziendaVO aavo=(AnagAziendaVO) ditteLeasing.get(i);
    htmpl.set("blkSocietaLeasing.idSocietaLeasing",""+aavo.getIdAzienda());
    htmpl.set("blkSocietaLeasing.denominazione",aavo.getDenominazione());
    htmpl.set("blkSocietaLeasing.partitaIVA",aavo.getPartitaIVA());
    htmpl.set("blkSocietaLeasing.indirizzo",aavo.getSedelegIndirizzo());
    htmpl.set("blkSocietaLeasing.comune",aavo.getDescComune());
    htmpl.set("blkSocietaLeasing.rappresentante",aavo.getRappresentanteLegale());
  }
  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

  out.print(htmpl.text());
%>
