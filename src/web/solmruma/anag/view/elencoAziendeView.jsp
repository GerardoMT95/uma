  <%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>

<%@ page import="it.csi.solmr.business.uma.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  //java.io.InputStream layout = application.getResourceAsStream("/uma/anag/layout/elencoAziende.htm");

  //SolmrLogger.info(this, "Found layout: "+layout);

  //Htmpl htmpl = new Htmpl(layout);

  Htmpl htmpl = HtmplFactory.getInstance(application)

                .getHtmpl("/anag/layout/elencoAziende.htm");
%><%@include file = "/include/menu.inc" %><%

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  int totalePagine;

  int pagCorrente;

  Integer currPage;

  Vector vectIdAziendaDitta = (Vector)session.getAttribute("vectIdAziendaDitta");

  Vector rangeAziendaDitta = (Vector)session.getAttribute("rangeAziendaDitta");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  if(session.getAttribute("currPage")==null)

    pagCorrente=1;

  else

    pagCorrente = ((Integer)session.getAttribute("currPage")).intValue();

  if(vectIdAziendaDitta!=null){

    totalePagine=vectIdAziendaDitta.size()/SolmrConstants.NUM_MAX_ROWS_PAG;

    int resto = vectIdAziendaDitta.size()%SolmrConstants.NUM_MAX_ROWS_PAG;

    if(resto!=0)

      totalePagine+=1;

    htmpl.set("currPage",""+pagCorrente);

    htmpl.set("totPage",""+totalePagine);

    htmpl.set("numeroRecord",""+vectIdAziendaDitta.size());

    currPage = new Integer(pagCorrente);

    session.setAttribute("currPage",currPage);

    if(pagCorrente>1)

      htmpl.newBlock("bottoneIndietro");

    if(pagCorrente<totalePagine)

      htmpl.newBlock("bottoneAvanti");

  }

  if(rangeAziendaDitta!=null && rangeAziendaDitta.size()>0){



    for(int i=0; i<rangeAziendaDitta.size();i++){

      DittaUMAAziendaVO dittaAziendaVO = (DittaUMAAziendaVO)rangeAziendaDitta.elementAt(i);

      htmpl.newBlock("rigaAziendaDitta");

      htmpl.set("rigaAziendaDitta.posizione",""+i);

      htmpl.set("rigaAziendaDitta.cuaa",dittaAziendaVO.getCuaa());

      htmpl.set("rigaAziendaDitta.partitaIVA",dittaAziendaVO.getPartitaIVA());

      htmpl.set("rigaAziendaDitta.denominazione",dittaAziendaVO.getDenominazione());

      htmpl.set("rigaAziendaDitta.formaGiuridica",dittaAziendaVO.getDescFormaGiuridica());
      // Modificato 27/10/2004 Einaudi
      // Aggiunto visualizzazione dello stato estero
      if (Validator.isNotEmpty(dittaAziendaVO.getSedelegComune()))
      {
        htmpl.set("rigaAziendaDitta.sedelegComune",dittaAziendaVO.getSedelegComune());
      }
      else
      {
        htmpl.set("rigaAziendaDitta.sedelegComune",dittaAziendaVO.getSedelegEstero());
      }
      // Fine modifica
      htmpl.set("rigaAziendaDitta.sedelegProv",dittaAziendaVO.getSedelegProvincia());

      htmpl.set("rigaAziendaDitta.dittaUMA",dittaAziendaVO.getSiglaProvUMA()+" "+

                dittaAziendaVO.getDittaUMAstr()+" / "+dittaAziendaVO.getTipiDitta());

      if(dittaAziendaVO.getDataCessazioneUMA()!=null)

        htmpl.set("rigaAziendaDitta.dataCessUMA",dittaAziendaVO.getDataCessazioneUMA());

    }

  }

  HtmplUtil.setErrors(htmpl, errors, request);

  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl, exception);

%>

<%= htmpl.text()%>