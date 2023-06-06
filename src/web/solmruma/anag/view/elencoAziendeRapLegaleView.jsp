  <%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>
<%@ page import="it.csi.solmr.business.uma.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.anag.ParametroRitornoVO" %>
<%@ page import="it.csi.solmr.util.HtmplUtil" %>
<%@ page import="it.csi.solmr.util.ValidationErrors" %>
<%
  response.resetBuffer(); // Cancello il buffer per eliminare gli A CAPO
  Htmpl htmpl = HtmplFactory.getInstance(application)
                .getHtmpl("/anag/layout/elencoAziendeRapLegale.htm");
%><%@include file = "/include/menu.inc" %><%
  DittaUMAAziendaVO[] aziende=(DittaUMAAziendaVO[])request.getAttribute("aziende");
  int size=aziende==null?0:aziende.length;
  ParametroRitornoVO parametroRitornoVO=(ParametroRitornoVO)request.getAttribute("parametroRitornoVO");
  Long idAziende[]=(Long [])request.getAttribute("idAziende");
  if (parametroRitornoVO!=null)
  {
    String messaggi[]=parametroRitornoVO.getMessaggio();
    int length=messaggi==null?0:messaggi.length;
    for(int i=0;i<length;i++)
    {
      htmpl.newBlock("blkMessaggio");
      htmpl.set("blkMessaggio.messaggio",messaggi[i]);
    }
  }
  if (idAziende!=null && idAziende.length>0)
  {
      htmpl.newBlock("blkJsDettaglio"); // Javascript
      htmpl.newBlock("blkMenuDittaUMA.blkDettaglio"); // Menu
  }
  else
  {
      htmpl.newBlock("blkNoDitte"); // Se non trovo ditte ==> Messaggio di errore
  }
  if (size>0)
  {
    htmpl.newBlock("blkHeader");
  }
  for(int i=0;i<size;i++)
  {
    DittaUMAAziendaVO duaVO=aziende[i];
    htmpl.newBlock("blkAziendaDitta");
    htmpl.set("blkAziendaDitta.idDittaUMA",duaVO.getIdDittaUMA().toString());
    htmpl.set("blkAziendaDitta.cuaa",duaVO.getCuaa());
    htmpl.set("blkAziendaDitta.partitaIVA",duaVO.getPartitaIVA());
    htmpl.set("blkAziendaDitta.denominazione",duaVO.getDenominazione());
    String sedeLeg=duaVO.getSedelegComune();
    if (it.csi.solmr.util.Validator.isEmpty(sedeLeg))
    {
      sedeLeg=duaVO.getSedelegEstero();
    }
    htmpl.set("blkAziendaDitta.sedeLeg",sedeLeg);
  }
  HtmplUtil.setErrors(htmpl,(ValidationErrors)request.getAttribute("errors"),request);
%><%= htmpl.text()%>