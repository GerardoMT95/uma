<%@
  page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.etc.*"%>

<%



  java.io.InputStream layout = application.getResourceAsStream("/macchina/layout/listaMatrici.htm");

  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


  if(!ruoloUtenza.isUtenteIntermediario()) {

    htmpl.newBlock("bloccoDettaglio");

    htmpl.newBlock("bloccoRicerca");

  }



  MatriceVO ricercaMatriceVO = (MatriceVO)session.getAttribute("ricercaMatriceVO");

  HtmplUtil.setValues(htmpl,ricercaMatriceVO);



  Vector elencoMatrici = (Vector)session.getAttribute("elencoMatrici");

  htmpl.set("dimensioniElencoMatrici",String.valueOf(elencoMatrici.size()));



  if(elencoMatrici.size() > 0) {



    String indice = (String)session.getAttribute("indice");

    int i = 0;

    if(indice != null) {

      i = Integer.parseInt(indice);

      if(i <= 0) {

        i=0;

      }

      else if(i >= elencoMatrici.size()) {

        i = (elencoMatrici.size()-1)-(elencoMatrici.size()-1)%10;

      }

    }

    int j = i+9;





    Iterator iteraMatrici = elencoMatrici.iterator();

    if(iteraMatrici.hasNext()) {

      for(; i < elencoMatrici.size()&&i <= j; i++) {

        htmpl.newBlock("elencoMatrici");

        MatriceVO matriceVO = (MatriceVO)elencoMatrici.elementAt(i);

        htmpl.set("elencoMatrici.idMatrice",matriceVO.getIdMatrice());

        htmpl.set("elencoMatrici.numeroMatrice",matriceVO.getNumeroMatrice());

        htmpl.set("elencoMatrici.descrizioneMarca",matriceVO.getDescMarca());

        htmpl.set("elencoMatrici.tipoMacchina",matriceVO.getTipoMacchina());

        htmpl.set("elencoMatrici.categoria",matriceVO.getDescCategoria());

        htmpl.set("elencoMatrici.numeroOmologazione",matriceVO.getNumeroOmologazione());

        htmpl.set("elencoMatrici.potenzaKw",matriceVO.getPotenzaKW());

        htmpl.set("elencoMatrici.alimentazione",matriceVO.getDescAlimentazione());

      }

    }



    // Valorizzazione dei blocchi pulsanti avanti/indietro

    if(i > 10) {

      htmpl.newBlock("frecciaSinistra");

      htmpl.set("frecciaSinistra.valore",""+(i-20+(10-i%10)%10));

    }



    int valoreTotale = 1;

    int numParziale = 1;



    if(elencoMatrici.size() > 10 &&i <elencoMatrici.size()) {

      htmpl.newBlock("frecciaDestra");

      htmpl.set("frecciaDestra.valore",""+i);

    }



    valoreTotale = (int)Math.ceil(elencoMatrici.size()/10.0);

    htmpl.set("numeroTotale", String.valueOf(valoreTotale));



    numParziale = ((i-1)/10)+1;

    htmpl.set("numeroParziale",String.valueOf(numParziale));

  }

  HtmplUtil.setErrors(htmpl,errors,request);



%>

<%= htmpl.text()%>