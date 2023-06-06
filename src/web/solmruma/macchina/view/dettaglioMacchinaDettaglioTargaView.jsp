<%@
  page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.client.uma.UmaFacadeClient" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  UmaFacadeClient umaClient = new UmaFacadeClient();

  java.io.InputStream layout = application.getResourceAsStream("/macchina/layout/dettaglioMacchinaTarga.htm");

  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
  Vector v_immatricolazioni = (Vector)session.getAttribute("v_immatricolazioni");

  MacchinaVO macchinaVO = (MacchinaVO)session.getAttribute("macchinaVO");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  // Dati identificativi del veicolo

  it.csi.solmr.presentation.security.AutorizzazioneMacchine.writeDatiMacchina(htmpl, macchinaVO);

  // Dati Movimentazioni Targhe

  String idMovTarga = request.getParameter("radioTarga");

  Iterator i_imm = v_immatricolazioni.iterator();

  int i = 0;

  while(i_imm.hasNext()){

    MovimentiTargaVO mtVO = (MovimentiTargaVO)i_imm.next();

    SolmrLogger.debug(this,"Confronto id: "+idMovTarga+" - "+mtVO.getIdMovimentiTarga());

    if(idMovTarga!=null&&idMovTarga.equals(mtVO.getIdMovimentiTarga())){

      UtenteIrideVO utenteIrideVO;

      // Dati Targa

      if(mtVO.getDatiTarga()!=null){

        htmpl.set("TTipo", StringUtils.checkNull(mtVO.getDatiTarga().getDescrizioneTipoTarga()));

        htmpl.set("TProv", StringUtils.checkNull(mtVO.getDatiTarga().getDescProvincia()));

        htmpl.set("TNum", StringUtils.checkNull(mtVO.getDatiTarga().getNumeroTarga()));

        if(mtVO.getDatiTarga().getMc_824()!=null&&mtVO.getDatiTarga().getMc_824().equals("S"))

          htmpl.set("TMC824", "SI");

        String TUltimaMod = StringUtils.checkNull(mtVO.getDatiTarga().getDataAggiornamento());

        utenteIrideVO = umaClient.getUtenteIride(mtVO.getDatiTarga().getExtIdUtenteAggiornamentoLong());

        TUltimaMod += composeString(utenteIrideVO.getDenominazione(),utenteIrideVO.getDescrizioneEnteAppartenenza());

        htmpl.set("TUltimaMod", TUltimaMod);

      }





      // Dati Movimentazione

      htmpl.set("tipoMov", StringUtils.checkNull(mtVO.getDescMovimentazione()));

      htmpl.set("dataMov", StringUtils.checkNull(mtVO.getDataInizioValidita()));

      htmpl.set("UProv", StringUtils.checkNull(mtVO.getSiglaProvincia()));

      htmpl.set("UNum", StringUtils.checkNull(mtVO.getDittaUma()));

      if(mtVO.getAnnoModello()!=null&&!mtVO.getAnnoModello().equals("")&&

         mtVO.getNumeroModello()!=null&&!mtVO.getNumeroModello().equals(""))

        htmpl.set("49Anno", mtVO.getAnnoModello()+" - ");

      else

        htmpl.set("49Anno",  StringUtils.checkNull(mtVO.getAnnoModello()));

      htmpl.set("49Num", StringUtils.checkNull(mtVO.getNumeroModello()));

      if(mtVO.getDataProtocollo()!=null&&!mtVO.getDataProtocollo().equals("")&&

         mtVO.getProtocolloModello()!=null&&!mtVO.getProtocolloModello().equals(""))

        htmpl.set("49Data", mtVO.getDataProtocollo()+" - ");

      else

        htmpl.set("49Data",  StringUtils.checkNull(mtVO.getDataProtocollo()));

      htmpl.set("49Prot", StringUtils.checkNull(mtVO.getProtocolloModello()));

      String MUltimaMod = StringUtils.checkNull(mtVO.getDataAggiornamento());

      utenteIrideVO = umaClient.getUtenteIride(mtVO.getExtIdUtenteAggiornamentoLong());

      MUltimaMod += composeString(utenteIrideVO.getDenominazione(),utenteIrideVO.getDescrizioneEnteAppartenenza());

      htmpl.set("MUltimaMod", MUltimaMod);

    }

    else

      SolmrLogger.debug(this,"idMovTarga  == null || != mtVO.getId");

  }

  SolmrLogger.debug(this,"- dettaglioMacchinaDettaglioTarga.jsp -  FINE PAGINA");

%>

<%= htmpl.text()%>

<%!

  private String composeString(String first, String second){

    String result = "";

    if(first != null && !first.equals("")){

      result = first;

      if(second != null && !second.equals(""))

        result += " - " + second;

    }

    else if(second != null && !second.equals(""))

      result = second;

    if(!result.equals(""))

      result = " ("+result+")";

    return result;

  }

%>