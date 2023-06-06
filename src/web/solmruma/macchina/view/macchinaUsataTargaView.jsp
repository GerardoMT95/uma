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
<%!
  public static final String LAYOUT="macchina/layout/macchinaUsataTarga.htm";
%>
<%
  SolmrLogger.debug(this,"macchinaUsataTargaView started");

//---------------- Ricerca in sessione delle variabili necessarie --------------
  HashMap common=(HashMap) session.getAttribute("common");
  MacchinaVO macchinaVO=(MacchinaVO)get(common,"macchinaVO");
  TargaVO targaVO=(TargaVO)macchinaVO.getTargaCorrente()==null?null:macchinaVO.getTargaCorrente();
  String conTarga=(String)get(common,"conTarga");
  DittaUMAVO dittaProvenienzaVO=(DittaUMAVO)get(common,"dittaProvenienzaVO");
  DittaUMAVO dittaUmaVO=(DittaUMAVO)session.getAttribute("dittaUmaVO");
//------------------------------------------------------------------------------
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  String pathToFollow=(String)request.getAttribute("pathToFollow");
  HtmplUtil.setValues(htmpl,targaVO,pathToFollow);
  HtmplUtil.setValues(htmpl,dittaProvenienzaVO,pathToFollow);
  printCombo(htmpl,
             umaClient.getTipiTarga(),
             "idTarga",
             "descTipoTarga",
             targaVO==null?null:targaVO.getIdTarga(),
             "blkTarga");
  if ("no".equalsIgnoreCase(conTarga))
  {
    htmpl.set("checkedNo","checked");
  }
  else
  {
    htmpl.set("checkedSi","checked");
  }
  ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");
  if (errors!=null)
  {
    HtmplUtil.setErrors(htmpl,errors,request);
  }
%>

<%=htmpl.text()%>

<%!
  private void printCombo(Htmpl htmpl,Vector comboData,String nameCode,String nameDesc,String selectedCode,String blockName)
  {
    int size=comboData==null?0:comboData.size();
    String blkNameCode=blockName+"."+nameCode;
    String blkNameDesc=blockName+"."+nameDesc;
    htmpl.newBlock(blockName);
    htmpl.set(blkNameCode,null);
    htmpl.set(blkNameDesc,"-seleziona-");
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
  private Object get(HashMap common,String name)
  {
    if (common==null)
    {
      return null;
    }
    return common.get(name);
  }
%>
