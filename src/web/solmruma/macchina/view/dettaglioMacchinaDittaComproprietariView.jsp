<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%

  java.io.InputStream layout = application.getResourceAsStream("macchina/layout/dettaglioMacchinaDittaComproprietari.htm");

  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
  DittaUMAAziendaVO dittaUmaAziendaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
  // Dati relativi alla ditta Uma su cui sto lavorando.
  if(dittaUmaAziendaVO.getCuaa() != null) 
  {
    htmpl.set("CUAA",dittaUmaAziendaVO.getCuaa());
  }
  htmpl.set("denominazione",dittaUmaAziendaVO.getDenominazione());
  htmpl.set("dittaUMA",dittaUmaAziendaVO.getDittaUMA().toString());
  htmpl.set("umaTipoDitta",dittaUmaAziendaVO.getTipiDitta());
  htmpl.set("provincia",dittaUmaAziendaVO.getDescProvinciaUma());

  // Dati relativi alla macchina selezionata
  MacchinaVO macchinaVO = (MacchinaVO)session.getAttribute("macchinaVO");
  if(macchinaVO != null) 
  {
    DatiMacchinaVO datiMacchinaVO = macchinaVO.getDatiMacchinaVO();
    MatriceVO matriceVO = macchinaVO.getMatriceVO();
    if(datiMacchinaVO != null) 
    {
      htmpl.set("descGenereMacchina",datiMacchinaVO.getDescGenereMacchina());
      htmpl.set("descCategoria",datiMacchinaVO.getDescCategoria());
      if(datiMacchinaVO.getMarca() != null) 
      {
        htmpl.set("descMarca",datiMacchinaVO.getDescGenereMacchina());
      }
      if(datiMacchinaVO.getTipoMacchina() != null) 
      {
        htmpl.set("tipoMacchina",datiMacchinaVO.getTipoMacchina());
      }
    }
    else 
    {
      if(matriceVO != null) 
      {
        htmpl.set("descGenereMacchina",matriceVO.getDescGenereMacchina());
        htmpl.set("descCategoria",matriceVO.getDescCategoria());
        if(matriceVO.getDescMarca() != null) 
        {
          htmpl.set("descMarca",matriceVO.getDescMarca());
        }
        if(matriceVO.getTipoMacchina() != null) 
        {
          htmpl.set("tipoMacchina",matriceVO.getTipoMacchina());
        }
      }
    }
    if(macchinaVO.getMatricolaTelaio() != null) 
    {
      htmpl.set("matricolaTelaio",macchinaVO.getMatricolaTelaio());
    }

    if(macchinaVO.getMatricolaMotore() != null) 
    {
      htmpl.set("matricolaMotore",macchinaVO.getMatricolaMotore());
    }

    TargaVO targaVO = macchinaVO.getTargaCorrente();

    if(targaVO != null) 
    {
      htmpl.set("tipoTarga",targaVO.getDescrizioneTipoTarga());
      htmpl.set("numeroTarga",targaVO.getNumeroTarga());
    }
  }
  // Dati relativi alle attestazioni di proprietà
%>

<%= htmpl.text()%>

