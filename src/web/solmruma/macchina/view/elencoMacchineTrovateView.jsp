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

  Htmpl htmpl = HtmplFactory.getInstance(application)

                .getHtmpl("/macchina/layout/elencoMacchineTrovate.htm");
%><%@include file = "/include/menu.inc" %><%
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  int totalePagine;

  int pagCorrente;

  Integer currPage;



  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  Vector elencoIdMacchina = (Vector)session.getAttribute("elencoIdMacchina");

  Vector elencoMacchina = (Vector)session.getAttribute("elencoMacchina");



  if(session.getAttribute("currPage")==null)

    pagCorrente=1;

  else

    pagCorrente = ((Integer)session.getAttribute("currPage")).intValue();

  if(elencoIdMacchina!=null){

    totalePagine=elencoIdMacchina.size()/SolmrConstants.NUM_MAX_ROWS_PAG;

    int resto = elencoIdMacchina.size()%SolmrConstants.NUM_MAX_ROWS_PAG;

    if(resto!=0)

      totalePagine+=1;

    htmpl.set("currPage",""+pagCorrente);

    htmpl.set("totPage",""+totalePagine);

    htmpl.set("numeroRecord",""+elencoIdMacchina.size());

    currPage = new Integer(pagCorrente);

    session.setAttribute("currPage",currPage);



    if(pagCorrente>1)

      htmpl.newBlock("bottoneIndietro");

    if(pagCorrente<totalePagine)

      htmpl.newBlock("bottoneAvanti");

  }



  if(elencoMacchina!=null && elencoMacchina.size()>0){



    for(int i=0; i<elencoMacchina.size();i++){

      MacchinaVO macchinaVO = (MacchinaVO)elencoMacchina.elementAt(i);

      htmpl.newBlock("rigaMacchina");

      htmpl.set("rigaMacchina.idMacchina",macchinaVO.getIdMacchina());

      String genere = "";

      String categoria = "";

      String marca = "";

      String tipo = "";

      String targa = "";



      if(macchinaVO.getMatriceVO()!=null){

        MatriceVO matriceVO = macchinaVO.getMatriceVO();

        genere = nvl(matriceVO.getDescGenereMacchina());

        categoria = nvl(matriceVO.getDescCategoria());

        marca = nvl(matriceVO.getDescMarca());

        tipo = nvl(matriceVO.getTipoMacchina());

      }

      else if(macchinaVO.getDatiMacchinaVO()!=null){

        DatiMacchinaVO datiVO = macchinaVO.getDatiMacchinaVO();

        genere = nvl(datiVO.getDescGenereMacchina());

        categoria = nvl(datiVO.getDescCategoria());

        marca = nvl(datiVO.getMarca());

        tipo = nvl(datiVO.getTipoMacchina());

      }

      if(macchinaVO.getTargaCorrente()!=null){

        TargaVO targaVO = macchinaVO.getTargaCorrente();

        targa = targaVO.getDescrizioneTipoTarga()+" - "+targaVO.getNumeroTarga();

      }

      htmpl.set("rigaMacchina.descGenereMacchina",genere);

      htmpl.set("rigaMacchina.descCategoria",categoria);

      htmpl.set("rigaMacchina.marca",marca);

      htmpl.set("rigaMacchina.tipo",tipo);

      htmpl.set("rigaMacchina.matricolaTelaio",nvl(macchinaVO.getMatricolaTelaio()));

      htmpl.set("rigaMacchina.matricolaMotore",nvl(macchinaVO.getMatricolaMotore()));

      htmpl.set("rigaMacchina.targa",targa);

    }

  }

  HtmplUtil.setErrors(htmpl, errors, request);

  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

%>

<%= htmpl.text()%>



<%!

  private String nvl(String valore){

    String result = "";

    if(valore!=null)

      result = valore;

    return result;

  }

%>

