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
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>




<%

  SolmrLogger.debug(this,"macchinaUsataNonTrovataDatiCasoR-ASMView.jsp - Begin");



  String elencoMacchineUrlHtml="../layout/elencoMacchine.htm";



  String ALTROGENERE = "avantiAltroGenere";

  String RIMORCHIOASM = "avantiRimorchioAsm";



  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("macchina/layout/MacchinaUsataNonTrovataDatiCasoR-ASM.htm");
%><%@include file = "/include/menu.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  SolmrLogger.debug(this,"\n\n\n************************");

  SolmrLogger.debug(this,"SolmrConstants.FORMATO_NUMERIC_1INT_2DEC: "+SolmrConstants.FORMATO_NUMERIC_1INT_2DEC);

  DecimalFormat numericFormat2 = new DecimalFormat(SolmrConstants.FORMATO_NUMERIC_1INT_2DEC);



  MacchinaVO macchinaVO=null;

  MatriceVO matriceVO=null;

  DatiMacchinaVO datiMacchinaVO=null;



  if ( session.getAttribute("common")!=null )

  {

    SolmrLogger.debug(this,"session.getAttribute(\"common\")!=null");

    HashMap common = (HashMap) session.getAttribute("common");

    macchinaVO = (MacchinaVO) common.get("macchinaVO");

    SolmrLogger.debug(this,"macchinaVO: "+macchinaVO);

    matriceVO = (MatriceVO) macchinaVO.getMatriceVO();

    SolmrLogger.debug(this,"matriceVO: "+matriceVO);

    datiMacchinaVO =  macchinaVO.getDatiMacchinaVO();

    SolmrLogger.debug(this,"datiMacchinaVO: "+datiMacchinaVO);

  }





  SolmrLogger.debug(this,"datiMacchinaVO.getDescGenereMacchina(): "+datiMacchinaVO.getDescGenereMacchina());

  //htmpl.set("descGenereMacchinaenere", datiMacchinaVO.getDescGenereMacchina() );

  SolmrLogger.debug(this,"datiMacchinaVO.getDescCategoria(): "+datiMacchinaVO.getDescCategoria());

  //htmpl.set("descCategoria", datiMacchinaVO.getDescCategoria() );





  long RIMORCHIO=10;

  long ASM=11;





  SolmrLogger.debug(this,"\n\n\nààààààààààààààààààààààààààààààà2");

  SolmrLogger.debug(this,"datiMacchinaVO.getIdGenereMacchinaLong(): "+datiMacchinaVO.getIdGenereMacchinaLong());

  SolmrLogger.debug(this,"datiMacchinaVO.getIdCategoriaLong(): "+datiMacchinaVO.getIdCategoriaLong());

  SolmrLogger.debug(this,"datiMacchinaVO.getDescGenereMacchina(): "+datiMacchinaVO.getDescGenereMacchina());

  SolmrLogger.debug(this,"datiMacchinaVO.getDescCategoria(): "+datiMacchinaVO.getDescCategoria());



  ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");

  SolmrLogger.debug(this,"errors="+errors);

  HtmplUtil.setErrors(htmpl,errors,request);



  HtmplUtil.setValues(htmpl,macchinaVO,(String)session.getAttribute("pathToFollow"));

  HtmplUtil.setValues(htmpl,datiMacchinaVO,(String)session.getAttribute("pathToFollow"));



  String tara;

  String lordo;

  SolmrLogger.debug(this,"datiMacchinaVO.getIdGenereMacchinaLong(): "+datiMacchinaVO.getIdGenereMacchinaLong());

  if(datiMacchinaVO.getIdGenereMacchinaLong().longValue() == RIMORCHIO)

  {

    htmpl.newBlock("blkGenereRimorchio");

    if(datiMacchinaVO.getTaraDouble()!=null){

      tara = numericFormat2.format(datiMacchinaVO.getTaraDouble());

      tara = tara.replace('.',',');

      SolmrLogger.debug(this,"tara: "+tara);

      htmpl.bset("tara", tara);

    }

    if(datiMacchinaVO.getLordoDouble()!=null)

    {

      lordo = numericFormat2.format(datiMacchinaVO.getLordoDouble());

      lordo = lordo.replace('.',',');

      SolmrLogger.debug(this,"lordo: "+lordo);

      htmpl.bset("lordo", lordo);

    }

  }

  else{

    htmpl.newBlock("blkGenereAsm");

  }



  out.print(htmpl.text());

%>