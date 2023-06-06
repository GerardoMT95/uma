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
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>

<%

  SolmrLogger.debug(this,"----- dettaglioMacchinaDatiView.jsp ----- inizio");
  AnagFacadeClient anagClient = new AnagFacadeClient();
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application)
                .getHtmpl("macchina/layout/dettaglioMacchinaDati.htm");
%><%@include file = "/include/menu.inc" %><%
  MacchinaVO macchinaVO = (MacchinaVO)session.getAttribute("macchinaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  if(session.getAttribute("indietro")!=null)
    htmpl.newBlock("blkIndietro");



  if(macchinaVO != null)
  {
    String messaggioTarga = (String)session.getAttribute("messaggioTarga");
    session.removeAttribute("messaggioTarga");
    if(messaggioTarga != null && !messaggioTarga.equals(""))
    {
      htmpl.set("messaggio",messaggioTarga);
    }
    it.csi.solmr.presentation.security.AutorizzazioneMacchine.writeDatiMacchina(htmpl, macchinaVO);

    if(macchinaVO.getMatriceVO()!=null)
    {
      MatriceVO matriceVO = macchinaVO.getMatriceVO();
      htmpl.newBlock("blkMatrice");
      htmpl.set("blkMatrice.numeroMatrice",StringUtils.checkNull(matriceVO.getNumeroMatrice()));
      htmpl.set("blkMatrice.numeroOmologazione",StringUtils.checkNull(matriceVO.getNumeroOmologazione()));
      htmpl.set("blkMatrice.potenzaCV",StringUtils.checkNull(matriceVO.getPotenzaCV()));
      htmpl.set("blkMatrice.potenzaKW",StringUtils.checkNull(matriceVO.getPotenzaKW()));
      htmpl.set("blkMatrice.consumoOrario",StringUtils.checkNull(matriceVO.getConsumoOrario()));
      htmpl.set("blkMatrice.descAlimentazione",StringUtils.checkNull(matriceVO.getDescAlimentazione()));
      htmpl.set("blkMatrice.descNazionalita",StringUtils.checkNull(matriceVO.getDescNazionalita()));
      htmpl.set("blkMatrice.descTrazione",StringUtils.checkNull(matriceVO.getDescTrazione()));

      String ultimaModifica = StringUtils.checkNull(macchinaVO.getDataAggiornamento());
      UtenteIrideVO utenteIrideVO=umaClient.getUtenteIride(macchinaVO.getExtIdUtenteAggiornamentoLong());
      ultimaModifica += composeString(utenteIrideVO.getDenominazione(),utenteIrideVO.getDescrizioneEnteAppartenenza());
      htmpl.set("blkMatrice.ultimaModifica",ultimaModifica);

    }
    else if(macchinaVO.getDatiMacchinaVO()!=null)
    {
      DatiMacchinaVO datiVO = macchinaVO.getDatiMacchinaVO();
      String ultimaModifica = StringUtils.checkNull(datiVO.getDataAggiornamento());
      UtenteIrideVO utenteIrideVO=umaClient.getUtenteIride(datiVO.getExtIdUtenteAggiornamentoLong());
      ultimaModifica += composeString(utenteIrideVO.getDenominazione(),utenteIrideVO.getDescrizioneEnteAppartenenza());

      if(macchinaVO.getDatiMacchinaVO().getIdGenereMacchina()!=null)
      {
        if(macchinaVO.getDatiMacchinaVO().getIdGenereMacchina().equals(SolmrConstants.ID_GENERE_MACCHINA_R.toString()))
        {
          htmpl.newBlock("blkRimorchio");
          htmpl.set("blkRimorchio.tara",StringUtils.checkNull(datiVO.getTara()));
          htmpl.set("blkRimorchio.lordo",StringUtils.checkNull(datiVO.getLordo()));
          htmpl.set("blkRimorchio.numeroAssi",StringUtils.checkNull(datiVO.getNumeroAssi()));
          htmpl.set("blkRimorchio.descNazionalita",StringUtils.checkNull(datiVO.getDescNazionalita()));
          htmpl.set("blkRimorchio.ultimaModifica",ultimaModifica);
        }
        else if(macchinaVO.getDatiMacchinaVO().getIdGenereMacchina().equals(SolmrConstants.ID_GENERE_MACCHINA_ASM.toString()))
        {
          htmpl.newBlock("blkASM");
          htmpl.set("blkASM.calorie",StringUtils.checkNull(datiVO.getCalorie()));
          htmpl.set("blkASM.potenza",StringUtils.checkNull(datiVO.getPotenza()));
          htmpl.set("blkASM.descAlimentazione",StringUtils.checkNull(datiVO.getDescAlimentazione()));
          htmpl.set("blkASM.descNazionalita",StringUtils.checkNull(datiVO.getDescNazionalita()));
          htmpl.set("blkASM.ultimaModifica",ultimaModifica);
        }
      }
    }
  }
  out.print(htmpl.text());

%>

<%!

  private String composeString(String first, String second)
  {
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

