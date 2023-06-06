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
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<jsp:useBean id="dittaLeasing" scope="request" class="it.csi.solmr.dto.anag.AnagAziendaVO">
  <jsp:setProperty name="dittaLeasing" property="*" />
</jsp:useBean>

<%!
  public static final String LAYOUT="macchina/layout/MacchinaUsataNonTrovataUtilizzoCasoR-ASM.htm";
  public static final String ASM = "ASM";
  public static final String RIMORCHIO = "R";
  public static final String MAO_TRAINATA = "010";
  public static final String CARRO_UNIFEED = "012";
%>

<%

  SolmrLogger.debug(this,"macchinaUsataNonTrovataCasoR-ASMView started");



//---------------- Ricerca in sessione delle variabili necessarie --------------
  HashMap common=(HashMap) session.getAttribute("common");
  MacchinaVO macchinaVO=(MacchinaVO)get(common,"macchinaVO");
  DatiMacchinaVO datiMacchinaVO=macchinaVO.getDatiMacchinaVO();
  DittaUMAVO dittaProvenienzaVO=(DittaUMAVO)get(common,"dittaProvenienzaVO");
//------------------------------------------------------------------------------

  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  String pathToFollow=(String)request.getAttribute("pathToFollow");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  printCombo(htmpl,umaClient.getTipiFormaPossesso(),"idFormaPossesso","descrizione",request.getParameter("idFormaPossesso"),"blkTipoFormaPossesso");
  setRadios(request, common, htmpl,datiMacchinaVO);
  htmpl.set("dataCarico",request.getParameter("dataCarico"));
  SolmrLogger.debug(this,"common.get(\"conTarga\")="+common.get("conTarga"));
  if (request.getParameter("salva")==null && request.getParameter("indietro")==null)
  {
    htmpl.set("dataCarico",DateUtils.formatDate(new Date()));
  }

  HtmplUtil.setErrors(htmpl,(ValidationErrors)request.getAttribute("errors"),request);
  HtmplUtil.setValues(htmpl,datiMacchinaVO,pathToFollow);
  HtmplUtil.setValues(htmpl,macchinaVO,pathToFollow);
  HtmplUtil.setValues(htmpl,macchinaVO.getTargaCorrente(),pathToFollow);
  HtmplUtil.setValues(htmpl,dittaProvenienzaVO,pathToFollow);
  HtmplUtil.setValues(htmpl,dittaLeasing,pathToFollow);
  HtmplUtil.setValues(htmpl,request);

%>



<%=htmpl.text()%>



<%!



  private void setRadios(HttpServletRequest request, HashMap common, Htmpl htmpl,DatiMacchinaVO datiMacchinaVO)
  {
    if (isMacchinaConTarga(datiMacchinaVO))
    {
      htmpl.newBlock("blkNuovaTarga");
      if ("yes".equalsIgnoreCase(request.getParameter("nuovaTarga")))
      {
        htmpl.set("blkNuovaTarga.checkedNuovaTargaYes","checked");
      }
      else
      {
        htmpl.set("blkNuovaTarga.checkedNuovaTargaNo","checked");
      }
      htmpl.set("blkNuovaTarga.nuovoNumeroTarga",request.getParameter("nuovoNumeroTarga"));
    }

  }

  private Object get(HashMap common,String name)
  {
    if (common==null)
    {
      return null;
    }
    return common.get(name);
  }

  private void printCombo(Htmpl htmpl,Vector comboData,String nameCode,String nameDesc,String selectedCode,String blockName)
  {
    int size=comboData==null?0:comboData.size();
    SolmrLogger.debug(this,"size="+size);
    String blkNameCode=blockName+"."+nameCode;
    String blkNameDesc=blockName+"."+nameDesc;
    SolmrLogger.debug(this,"blkNameCode="+blkNameCode);
    SolmrLogger.debug(this,"blkNameDesc="+blkNameDesc);
    htmpl.newBlock(blockName);
    htmpl.set(blkNameCode,null);
    htmpl.set(blkNameDesc,"-seleziona-");
    SolmrLogger.debug(this,"selectedCode="+selectedCode);
    for(int i=0;i<size;i++)
    {
      CodeDescr cd=(CodeDescr)comboData.get(i);
      String code=cd.getCode().toString();
      htmpl.newBlock(blockName);
      if (code!=null && code.equals(selectedCode))
      {
        htmpl.set(blockName+".selected","selected");
      }
      htmpl.set(blkNameCode,code);
      htmpl.set(blkNameDesc,cd.getDescription());
    }
  }

  private boolean isMacchinaConTarga(DatiMacchinaVO datiMacchinaVO)
  {
    final double LIMITE_LORDO=15;
    String tipoTarga=null;
    final String STRADALERA = "Stradale RA";
    SolmrLogger.debug(this,"1tipoTarga: "+tipoTarga);
    //Tipo Genere = RIMORCHIO
    if (RIMORCHIO.equals(datiMacchinaVO.getCodBreveGenereMacchina().trim()))
    {
      if (MAO_TRAINATA.equals(datiMacchinaVO.getCodBreveCategoriaMacchina().trim()))
      {
        tipoTarga=null;
      }
      else
      {
        if (CARRO_UNIFEED.equals(datiMacchinaVO.getCodBreveCategoriaMacchina().trim()))
        {
          tipoTarga=null;
        }
        else
        {
          if(tipoTarga==null)
          {
            if (datiMacchinaVO.getLordoDouble().doubleValue() <= LIMITE_LORDO)
            {
              tipoTarga=null;
            }
            else
            {
              tipoTarga=STRADALERA;
            }
          }
        }
      }
    }
    if (ASM.equals(datiMacchinaVO.getCodBreveGenereMacchina()))
    {
      SolmrLogger.debug(this,ASM.equals(datiMacchinaVO.getCodBreveGenereMacchina()));
      tipoTarga=null;
    }
    SolmrLogger.debug(this,"tipoTarga="+(tipoTarga!=null));
    return tipoTarga!=null;
  }



%>

