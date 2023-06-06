<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>



<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>

<%

  java.io.InputStream layout = application.getResourceAsStream("/anag/layout/dettaglioBuonoPOP.htm");

  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%

  Vector v_carb = (Vector)request.getAttribute("v_carb");

  BuonoPrelievoVO buonoVO = (BuonoPrelievoVO)request.getAttribute("buonoVO");

  BuonoCarburanteVO carbVO = null;



  htmpl.set("anno", buonoVO.getAnnoRiferimento().toString());

  htmpl.set("blocco", buonoVO.getNumeroBlocco().toString());

  htmpl.set("buono", buonoVO.getNumeroBuono().toString());

  htmpl.set("dataEmissione", DateUtils.formatDate(buonoVO.getDataEmissione()));

  htmpl.set("prov", buonoVO.getExtProvinciaProvenienza());

  htmpl.set("dittaUMA", buonoVO.getIdDittaUma().toString());

  htmpl.set("dataModifica", DateUtils.formatDate(buonoVO.getDataAggiornamento()));

  htmpl.set("modifica", buonoVO.getUtente());



  int gasolio = 0;

  int benzina = 0;

  int totale = 0;



  Iterator i = v_carb.iterator();

  while(i.hasNext()){

    carbVO = (BuonoCarburanteVO)i.next();

    if(carbVO.getCarburante().equals(SolmrConstants.ID_BENZINA)){

      benzina += carbVO.getQuantitaConcessa().intValue();

    }

    else if(carbVO.getCarburante().equals(SolmrConstants.ID_GASOLIO)){

      gasolio += carbVO.getQuantitaConcessa().intValue();

    }

  }



  totale = gasolio+benzina;



  htmpl.set("gasolio", gasolio+"");

  htmpl.set("benzina", benzina+"");

  htmpl.set("totale", totale+"");



%>

<%= htmpl.text()%>