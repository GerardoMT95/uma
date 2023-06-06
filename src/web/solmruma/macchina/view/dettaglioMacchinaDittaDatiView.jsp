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
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  public static final String LAYOUT="macchina/layout/dettaglioMacchinaDittaDati.htm";
%>
<%
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  //this.errErrorValExc(htmpl, request, exception);
  MacchinaVO mavo = (MacchinaVO)session.getAttribute("common");
  DatiMacchinaVO dmvo = null;
  TargaVO tvo = null;
  MatriceVO mvo = null;

  SolmrLogger.debug(this,"################# dmvo : "+dmvo);
  SolmrLogger.debug(this,"################# mvo : "+mvo);
  SolmrLogger.debug(this,"################# tvo : "+tvo);
  SolmrLogger.debug(this,"################# mavo : "+mavo);
  //  SolmrLogger.debug(this,"#################   "+dmvo.getDescGenereMacchina()+"   #################");


//  SolmrLogger.debug(this,"########## "+mavo.getIdMatrice());


if(mavo != null)
{

  dmvo = mavo.getDatiMacchinaVO();
  tvo = mavo.getTargaCorrente();
  mvo = mavo.getMatriceVO();

  if (mavo==null)
  {
    SolmrLogger.debug(this,"mavo==null");
    mavo=new MacchinaVO(); // Evito nullpointerexception
  }
  if (tvo==null)
  {
    SolmrLogger.debug(this,"tvo==null");
    tvo=new TargaVO(); // Evito nullpointerexception
    tvo.setNumeroTarga("");
    tvo.setDescrizioneTipoTarga("");
  }
  if (mvo==null)
  {
    SolmrLogger.debug(this,"mvo==null");
    mvo=new MatriceVO(); // Evito nullpointerexception
  }

  htmpl.set("matricolaTelaio", mavo.getMatricolaTelaio());
  htmpl.set("matricolaMotore", mavo.getMatricolaMotore());

  htmpl.set("targa", composeString(tvo.getDescrizioneTipoTarga(), tvo.getNumeroTarga()));
  
  htmpl.set("dataPrimaImmatricolazione", 
    DateUtils.formatDateNotNull(tvo.getDataPrimaImmatricolazione()));


  htmpl.set("idMacchina", mavo.getIdMacchina());

  if(mavo.getIdMatrice()!=null)
  {

    htmpl.set("descGenereMacchina", mvo.getDescGenereMacchina());
    htmpl.set("descCategoria", mvo.getDescCategoria());
    htmpl.set("marca", mvo.getDescMarca());
    htmpl.set("tipoMacchina", mvo.getTipoMacchina());

    htmpl.newBlock("blkMatrice");
    SolmrLogger.debug(this,"mavo.getExtIdUtenteAggiornamentoLong()="+mavo.getExtIdUtenteAggiornamentoLong());
    UtenteIrideVO utenteIrideVO=umaClient.getUtenteIride(mavo.getExtIdUtenteAggiornamentoLong());
    htmpl.set("blkMatrice.numeroMatrice", mvo.getNumeroMatrice());
    htmpl.set("blkMatrice.numeroOmologazione", mvo.getNumeroOmologazione());
    htmpl.set("blkMatrice.descAlimentazione", mvo.getDescAlimentazione());
    htmpl.set("blkMatrice.potenzaCV", mvo.getPotenzaCV());
    htmpl.set("blkMatrice.potenzaKW", mvo.getPotenzaKW());
    htmpl.set("blkMatrice.consumoOrario", mvo.getConsumoOrario());
    htmpl.set("blkMatrice.descTrazione", mvo.getDescTrazione());
    htmpl.set("blkMatrice.descNazionalita", mvo.getDescNazionalita());
    htmpl.set("blkMatrice.dataAggiornamento", mavo.getDataAggiornamento());

    htmpl.set("blkMatrice.aggiornamento", composeString(utenteIrideVO.getDenominazione(), utenteIrideVO.getDescrizioneEnteAppartenenza()));

  }
  else
  {
    htmpl.set("descGenereMacchina", dmvo.getDescGenereMacchina());
    htmpl.set("descCategoria", dmvo.getDescCategoria());
    htmpl.set("marca", dmvo.getMarca());
    htmpl.set("tipoMacchina", dmvo.getTipoMacchina());

    SolmrLogger.debug(this,"########" + dmvo.getDescGenereMacchina());
    SolmrLogger.debug(this,"########" + dmvo.getCodBreveGenereMacchina());

    if("R".equals(dmvo.getCodBreveGenereMacchina().trim()))
    {
      htmpl.newBlock("blkRimorchi");
      UtenteIrideVO utenteIrideVO=umaClient.getUtenteIride(dmvo.getExtIdUtenteAggiornamentoLong());
      htmpl.set("blkRimorchi.tara", dmvo.getTara());
      htmpl.set("blkRimorchi.lordo", dmvo.getLordo());
      htmpl.set("blkRimorchi.numeroAssi", dmvo.getNumeroAssi());
      htmpl.set("blkRimorchi.descNazionalita", dmvo.getDescNazionalita());
      htmpl.set("blkRimorchi.dataAggiornamento", dmvo.getDataAggiornamento());

    htmpl.set("blkRimorchi.aggiornamento", composeString(utenteIrideVO.getDenominazione(), utenteIrideVO.getDescrizioneEnteAppartenenza()));
    }
    else if("ASM".equals(dmvo.getCodBreveGenereMacchina().trim()))
    {
      htmpl.newBlock("bklASM");
      UtenteIrideVO utenteIrideVO=umaClient.getUtenteIride(dmvo.getExtIdUtenteAggiornamentoLong());
      htmpl.set("blkASM.calorie", dmvo.getCalorie());
      htmpl.set("blkASM.potenza", dmvo.getPotenza());
      htmpl.set("blkASM.descAlimentazione", dmvo.getDescAlimentazione());
      htmpl.set("blkASM.nazionalita", dmvo.getDescNazionalita());
      htmpl.set("blkASM.dataAggiornamento", dmvo.getDataAggiornamento());

      htmpl.set("blkASM.aggiornamento", composeString(utenteIrideVO.getDenominazione(), utenteIrideVO.getDescrizioneEnteAppartenenza()));
    }
  }
}

ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
if (errors!=null) HtmplUtil.setErrors(htmpl, errors, request);

  out.print(htmpl.text());
%>
<%!
  private void errErrorValExc(Htmpl htmpl, HttpServletRequest request, Throwable exc)
  {
    SolmrLogger.debug(this,"\n\n\n\n *********************************** 2");
    SolmrLogger.debug(this,"errErrorValExc()");

    if (exc instanceof it.csi.solmr.exception.ValidationException){

      ValidationErrors valErrs = new ValidationErrors();
      valErrs.add("error", new ValidationError(exc.getMessage()) );

      HtmplUtil.setErrors(htmpl, valErrs, request);
    }
  }
%>
<%!
  private String composeString(String first, String second)
  {
    String result = "";
    if(!"".equals(first) && first != null)
    {
      result = first;
      if(!"".equals(second) && second != null)
        result += " - " + second;
    }
    else if(!"".equals(second) && second != null)
      result = second;
    return result;
  }
%>
