<%@
  page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.util.*" %>

<%

  java.io.InputStream layout = application.getResourceAsStream("/macchina/layout/dettaglioMacchinaImmatricolazioni.htm");

  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
  Vector v_immatricolazioni = (Vector)session.getAttribute("v_immatricolazioni");

  MacchinaVO macchinaVO = (MacchinaVO)session.getAttribute("macchinaVO");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  HtmplUtil.setErrors(htmpl, errors, request);

  // Dati identificativi del veicolo

  it.csi.solmr.presentation.security.AutorizzazioneMacchine.writeDatiMacchina(htmpl, macchinaVO);

  // Dati attestazioni

  MovimentiTargaVO mtVO = null;

  if(v_immatricolazioni!=null&&v_immatricolazioni.size()!=0){

    htmpl.newBlock("blkDettaglio");

    htmpl.newBlock("blkTarga");

    Iterator iter = v_immatricolazioni.iterator();

    while(iter.hasNext()){

      mtVO = (MovimentiTargaVO)iter.next();

      htmpl.newBlock("blkTarga.blkRigaTarga");

      htmpl.set("blkTarga.blkRigaTarga.idTarga", StringUtils.checkNull(mtVO.getIdMovimentiTarga()));

      if(mtVO.getDatiTarga()!=null){

        htmpl.set("blkTarga.blkRigaTarga.TTipo", StringUtils.checkNull(mtVO.getDatiTarga().getDescrizioneTipoTarga()));

        htmpl.set("blkTarga.blkRigaTarga.TProv", StringUtils.checkNull(mtVO.getDatiTarga().getSiglaProvincia()));

        htmpl.set("blkTarga.blkRigaTarga.TNum", StringUtils.checkNull(mtVO.getDatiTarga().getNumeroTarga()));

      }

      htmpl.set("blkTarga.blkRigaTarga.tipoMov", StringUtils.checkNull(mtVO.getDescMovimentazione()));

      htmpl.set("blkTarga.blkRigaTarga.dataMov", StringUtils.checkNull(mtVO.getDataInizioValidita()));

      htmpl.set("blkTarga.blkRigaTarga.UProv", StringUtils.checkNull(mtVO.getSiglaProvincia()));

      htmpl.set("blkTarga.blkRigaTarga.UNum", StringUtils.checkNull(mtVO.getDittaUma()));

      htmpl.set("blkTarga.blkRigaTarga.49Anno", StringUtils.checkNull(mtVO.getAnnoModello()));

      htmpl.set("blkTarga.blkRigaTarga.49Num", StringUtils.checkNull(mtVO.getNumeroModello()));

    }

  }

  // Pulsante "indietro"

  if(session.getAttribute("indietro")!=null)

    htmpl.newBlock("blkIndietro");

  SolmrLogger.debug(this,"- dettaglioMacchinaTargaView.jsp -  FINE PAGINA");

%>

<%= htmpl.text()%>