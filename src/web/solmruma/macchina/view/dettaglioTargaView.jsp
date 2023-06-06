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
  public static final String LAYOUT="macchina/layout/dettaglioTarga.htm";
%>
<%
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  UtenteIrideVO utenteIrideVO = null;

  HtmplUtil.setErrors(htmpl, (ValidationErrors) request.getAttribute("errors"), request);
  MacchinaVO mavo = (MacchinaVO)session.getAttribute("common");
  MovimentiTargaVO mtvo = (MovimentiTargaVO)request.getAttribute("mtvo");
  DatiMacchinaVO dmvo = null;
  TargaVO tvo = null;
  MatriceVO mvo = null;

  SolmrLogger.debug(this,"############################## mtvo.getAnnoModello() : "+mtvo.getAnnoModello());

if(mavo != null)
{

  dmvo = mavo.getDatiMacchinaVO();
  tvo = mtvo.getDatiTarga();
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
  htmpl.set("idMacchina", mavo.getIdMacchina());

  if(mavo.getIdMatrice()!=null)
  {

    htmpl.set("descGenereMacchina", mvo.getDescGenereMacchina());
    htmpl.set("descCategoria", mvo.getDescCategoria());
    htmpl.set("marca", mvo.getDescMarca());
    htmpl.set("tipoMacchina", mvo.getTipoMacchina());
  }
  else
  {
    htmpl.set("descGenereMacchina", dmvo.getDescGenereMacchina());
    htmpl.set("descCategoria", dmvo.getDescCategoria());
    htmpl.set("marca", dmvo.getMarca());
    htmpl.set("tipoMacchina", dmvo.getTipoMacchina());
  }
  SolmrLogger.debug(this,"##################### idNumeroTarga : "+mtvo.getIdNumeroTarga());


  if(mtvo.getIdNumeroTarga()!=null)
  {
    try
    {
      utenteIrideVO=umaClient.getUtenteIride(tvo.getExtIdUtenteAggiornamentoLong());
    }
    catch(Exception ex)
    {
    }

    htmpl.set("descrizioneTipoTarga", tvo.getDescrizioneTipoTarga());
    htmpl.set("descProvinciaTarga", tvo.getDescProvincia());
    htmpl.set("numeroTarga", tvo.getNumeroTarga());
    if("S".equals(tvo.getMc_824()))
    {
      htmpl.set("mc_824", "SI");
    }
    htmpl.set("dataAggiornamento", tvo.getDataAggiornamento());
    htmpl.set("aggiornamento", composeString(utenteIrideVO.getDenominazione(), utenteIrideVO.getDescrizioneEnteAppartenenza()));
  }

    htmpl.set("idMovimentiTarga", mtvo.getIdMovimentiTarga());
    htmpl.set("descMovimentazione", mtvo.getDescMovimentazione());
    htmpl.set("dataInizioValidita", mtvo.getDataInizioValidita());
    htmpl.set("siglaProvincia_dittaUma", composeString(mtvo.getSiglaProvincia(), mtvo.getDittaUma()));
    htmpl.set("annoModello_numeroModello", composeString(mtvo.getAnnoModello(), mtvo.getNumeroModello()));
    htmpl.set("dataProtocollo_protocolloModello", composeString(mtvo.getDataProtocollo(), mtvo.getProtocolloModello()));

    try
    {
      utenteIrideVO=umaClient.getUtenteIride(mtvo.getExtIdUtenteAggiornamentoLong());
    }
    catch(Exception ex)
    {
    }
    htmpl.set("dataAggiornamentoTarga", mtvo.getDataAggiornamento());
    htmpl.set("aggiornamentoTarga", composeString(utenteIrideVO.getDenominazione(), utenteIrideVO.getDescrizioneEnteAppartenenza()));


}
  out.print(htmpl.text());
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
