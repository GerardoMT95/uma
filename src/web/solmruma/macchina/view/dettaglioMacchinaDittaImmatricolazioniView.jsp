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
  public static final String LAYOUT="macchina/layout/dettaglioMacchinaDittaImmatricolazioni.htm";
%>
<%
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
  MacchinaVO mavo = (MacchinaVO)session.getAttribute("common");

  DatiMacchinaVO dmvo = null;
  TargaVO tvo = null;
  MatriceVO mvo = null;

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
  htmpl.set("idMacchina", mavo.getIdMacchina());
  SolmrLogger.debug(this,"descrizioneTipoTarga "+tvo.getDescrizioneTipoTarga());

  htmpl.set("targa", composeString(tvo.getDescrizioneTipoTarga(), tvo.getNumeroTarga()));
  
  htmpl.set("dataPrimaImmatricolazione", 
    DateUtils.formatDateNotNull(tvo.getDataPrimaImmatricolazione()));

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

  SolmrLogger.debug(this,"#####------------ umaClient.getMovimentazioni("+mavo.getIdMacchinaLong()+")");
  Vector mov = umaClient.getMovimentazioni(mavo.getIdMacchinaLong());
  SolmrLogger.debug(this,"#####------------ mov.size() "+mov.size());

  for(int i=0; i<mov.size(); i++)
  {
    MovimentiTargaVO mtvo = (MovimentiTargaVO)mov.get(i);

    htmpl.newBlock("blkMovimenti");

    tvo = mtvo.getDatiTarga();

    htmpl.set("idMovimentazione", mtvo.getIdMovimentazione());

    htmpl.set("blkMovimenti.idMovimentiTarga", mtvo.getIdMovimentiTarga());
    htmpl.set("blkMovimenti.idAnnoProt", "idAnnoProt"+mtvo.getIdMovimentiTarga());
    htmpl.set("blkMovimenti.idNumeroProt", "idNumeroProt"+mtvo.getIdMovimentiTarga());
    if(tvo!=null)
    {
      htmpl.set("blkMovimenti.descrizioneTipoTarga", tvo.getDescrizioneTipoTarga());
      htmpl.set("blkMovimenti.descProvinciaTarga", tvo.getDescProvincia());
      htmpl.set("blkMovimenti.numeroTarga", tvo.getNumeroTarga());
    }

    htmpl.set("blkMovimenti.descMovimentazione", mtvo.getDescMovimentazione());
    htmpl.set("blkMovimenti.dataInizioValidita", mtvo.getDataInizioValidita());
    htmpl.set("blkMovimenti.descProvinciaMov", mtvo.getDescProvincia());
    htmpl.set("blkMovimenti.dittaUma", mtvo.getDittaUma());
    htmpl.set("blkMovimenti.annoModello", mtvo.getAnnoModello());
    htmpl.set("blkMovimenti.numeroModello", mtvo.getNumeroModello());
  }

}
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