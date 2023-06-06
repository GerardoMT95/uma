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
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>





<%

  UmaFacadeClient umaClient = new UmaFacadeClient();

  AnagFacadeClient anagFacadeClient = new AnagFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("macchina/layout/dettaglioMacchinaDettaglioUtilizzo.htm");
%><%@include file = "/include/menu.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  MacchinaVO macchinaVO = (MacchinaVO)session.getAttribute("macchinaVO");

  if(macchinaVO!=null)
    it.csi.solmr.presentation.security.AutorizzazioneMacchine.writeDatiMacchina(htmpl, macchinaVO);

  UtilizzoVO uVO = (UtilizzoVO)request.getAttribute("utilizzoVO");

  AnagraficaAzVO aVO = (AnagraficaAzVO)request.getAttribute("datiAziendaVO");



  if(uVO != null){



    PossessoVO[] possessi = uVO.getPossesso();

    String ditta = uVO.getSiglaProvUma()+" - "+uVO.getDittaUma();



    htmpl.set("ditta",ditta);

    htmpl.set("dataCarico",uVO.getDataCarico());

    htmpl.set("dataScarico",StringUtils.checkNull(uVO.getDataScarico()));

    htmpl.set("motivoScarico",StringUtils.checkNull(uVO.getDescScarico()));



    String ultimaModifica = uVO.getDataAggiornamento();

    UtenteIrideVO utenteIrideVO = umaClient.getUtenteIride(uVO.getIdUtenteAggiornamentoLong());

    ultimaModifica += composeString(utenteIrideVO.getDenominazione(),utenteIrideVO.getDescrizioneEnteAppartenenza());

    htmpl.set("ultimaModifica",ultimaModifica);



    RottamazioneVO rVO = uVO.getRottamazioneVO();



    if(rVO!=null){

      htmpl.set("numCertificato",StringUtils.checkNull(rVO.getNumeroCertificato()));

      htmpl.set("dataCertificato",StringUtils.checkNull(rVO.getDataCertificato()));

      htmpl.set("dataAnzianita",StringUtils.checkNull(rVO.getDataAnzianita()));

      String tda = rVO.getTipoDataAnzianita();

      String tipoDataAnzianita = "";

      if(tda!=null && !tda.equals("")){

        if(tda.equals("F"))

          tipoDataAnzianita = "DATA DI FABBRICAZIONE";

        else if(tda.equals("M"))

          tipoDataAnzianita = "DATA D'IMMATRICOLAZIONE";

        else if(tda.equals("I"))

          tipoDataAnzianita = "DATA D'ISCRIZIONE ALL'UMA";

      }

      htmpl.set("tipoDataAnzianita",tipoDataAnzianita);

      htmpl.set("dataInizioPossesso",StringUtils.checkNull(rVO.getDataInizioPossesso()));



      String dts = rVO.getDestTargaStradale();

      String destinazioneTargaStradale = "";

      if(dts!=null && !dts.equals("")){

        if(dts.equals("1"))

          destinazioneTargaStradale = "RITIRATA";

        else if(dts.equals("2"))

          destinazioneTargaStradale = "SMARRITA";

        else if(dts.equals("3"))

          destinazioneTargaStradale = "NON RILASCIATA";

        else if(dts.equals("4"))

          destinazioneTargaStradale = "NON PREVISTA";

      }

      htmpl.set("destinazioneTargaStradale",destinazioneTargaStradale);



      String dtu = rVO.getDestTargaStradale();

      String destinazioneTargaUma = "";

      if(dtu!=null && !dtu.equals("")){

        if(dtu.equals("1"))

          destinazioneTargaUma = "RITIRATA";

        else if(dtu.equals("2"))

          destinazioneTargaUma = "SMARRITA";

        else if(dtu.equals("3"))

          destinazioneTargaUma = "NON RILASCIATA";

        else if(dtu.equals("4"))

          destinazioneTargaUma = "NON PREVISTA";

      }

      htmpl.set("destinazioneTargaUma",destinazioneTargaUma);



      String dlc = rVO.getDestTargaStradale();

       String destinazioneLibrCircolaz = "";

       if(dlc!=null && !dlc.equals("")){

         if(dlc.equals("1"))

           destinazioneLibrCircolaz = "RITIRATO";

         else if(dlc.equals("2"))

           destinazioneLibrCircolaz = "SMARRITO";

         else if(dlc.equals("3"))

           destinazioneLibrCircolaz = "NON RILASCIATO";

         else if(dlc.equals("4"))

           destinazioneLibrCircolaz = "NON PREVISTO";

      }

      htmpl.set("destinazioneLibrCircolaz",destinazioneLibrCircolaz);

    }



    if(possessi!=null){

      for(int i=0; i<possessi.length;i++){

        PossessoVO pVO = possessi[i];



        htmpl.newBlock("rigaPossesso");

        htmpl.set("rigaPossesso.idPossesso",pVO.getIdPossesso());



        htmpl.set("rigaPossesso.formaPossesso",StringUtils.checkNull(pVO.getDescFormaPossesso()));

        htmpl.set("rigaPossesso.dataScadenzaLeasing",StringUtils.checkNull(pVO.getDataScadenzaLeasing()));



        String societaLeasing = "";

        if(pVO.getExtIdAziendaLong()!=null){

          societaLeasing = anagFacadeClient.getDenominazioneByIdAzienda(pVO.getExtIdAziendaLong());

        }

        htmpl.set("rigaPossesso.societaLeasing",StringUtils.checkNull(societaLeasing));



        htmpl.set("rigaPossesso.dataInizioVal",StringUtils.checkNull(pVO.getDataInizioValidita()));

        htmpl.set("rigaPossesso.dataFineVal",StringUtils.checkNull(pVO.getDataFineValidita()));



        String ultimaModificaPossesso = pVO.getDataAggiornamento();

        UtenteIrideVO utenteIrideVOPossesso = umaClient.getUtenteIride(pVO.getExtIdUtenteAggiornamentoLong());

        ultimaModificaPossesso += composeString(utenteIrideVOPossesso.getDenominazione(),utenteIrideVOPossesso.getDescrizioneEnteAppartenenza());

        htmpl.set("rigaPossesso.ultimaModificaPossesso",ultimaModificaPossesso);

      }

    }

  }

  if(aVO!=null){

    htmpl.set("cuaa",aVO.getCUAA());

    htmpl.set("partitaIVA",aVO.getPartitaIVA());

    htmpl.set("denominazione",aVO.getDenominazione());

    htmpl.set("sedelegIndirizzo",StringUtils.checkNull(aVO.getSedelegIndirizzo()));

    if(aVO.getSedelegEstero()!= null && !aVO.getSedelegEstero().equals("")){

      htmpl.newBlock("blkStatoEstero");

      htmpl.set("blkStatoEstero.sedelegStatoEstero",StringUtils.checkNull(aVO.getSedelegEstero()));

      htmpl.set("blkStatoEstero.sedelegCittaEstero",StringUtils.checkNull(aVO.getSedelegCittaEstero()));

    }

    else{

      htmpl.newBlock("blkItalia");

      htmpl.set("blkItalia.sedelegCap",StringUtils.checkNull(aVO.getSedelegCAP()));

      htmpl.set("blkItalia.sedelegComune",StringUtils.checkNull(aVO.getDescComune()));

      htmpl.set("blkItalia.sedelegProv",StringUtils.checkNull(aVO.getSedelegProv()));

    }

  }

  ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");

  SolmrLogger.debug(this,"errors="+errors);

  HtmplUtil.setErrors(htmpl,errors,request);

  out.print(htmpl.text());

%>

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