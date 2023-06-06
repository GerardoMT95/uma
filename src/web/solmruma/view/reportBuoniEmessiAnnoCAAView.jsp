<%@ page language="java"

    contentType="text/html"

    isErrorPage="true"

%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.Vector" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.dto.comune.IntermediarioVO" %>
<%@ page import="it.csi.solmr.util.*" %>
<%!

  public static final String LAYOUT="layout/reportBuoniEmessiAnnoCAA.htm";

%><%

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%


  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  Long idUtente = ruoloUtenza.getIdUtente();

  response.resetBuffer(); // Cancello eventuali '\n','\t'
  doBlkComboIntermediario(htmpl,request);
  String selected=null;
  if (request.getParameter("conferma")==null)
  {
    
    if (ruoloUtenza.isUtenteProvinciale())
    {
      selected=ruoloUtenza.getIstatProvincia();
    }
    htmpl.set("anno",DateUtils.getCurrentYear().toString());
  }
  else
  {
    selected=request.getParameter("istatProvincia");
    htmpl.set("anno",request.getParameter("anno"));
  }
  doBlkComboProvince(htmpl,  request, selected);

  if (request.getAttribute("showPdf")!=null)
  {
    htmpl.set("scriptReportBuoniEmessiAnnoCAA","stampaReport();");
  }
  htmpl.set("istatProvincia",request.getParameter("istatProvincia"));
  htmpl.set("idIntermediario",request.getParameter("idIntermediario"));

  HtmplUtil.setErrors(htmpl,(ValidationErrors)request.getAttribute("errors"),request);

%><%=htmpl.text()%><%!

  private void doBlkComboProvince(Htmpl htmpl,
                                  HttpServletRequest request,
                                  String selected)
  {
    Collection province = (Collection)request.getAttribute("provinceUMA");
    Iterator iter=province.iterator();
    while (iter.hasNext())
    {
      ProvinciaVO pVO=(ProvinciaVO)iter.next();
      String istat=pVO.getIstatProvincia();
      htmpl.newBlock("blkOptionProvincia");
      htmpl.set("blkOptionProvincia.value",istat);
      htmpl.set("blkOptionProvincia.descr",pVO.getDescrizione());
      if (istat.equals(selected))
      {
        htmpl.set("blkOptionProvincia.selected",SolmrConstants.HTML_SELECTED,null);
      }
    }
  }

  private void doBlkComboIntermediario(Htmpl htmpl,
                                  HttpServletRequest request)
  {
    IntermediarioVO intermediari[] = (IntermediarioVO[])request.getAttribute("intermediari");
    int length=intermediari==null?0:intermediari.length;
    String selected=request.getParameter("idIntermediario");
    TreeMap treeMap=new TreeMap();
    for(int i=0;i<length;i++)
    {
      IntermediarioVO intVO=intermediari[i];
      treeMap.put(intVO.getDenominazione(),intVO);
    }
    Iterator iterator=treeMap.values().iterator();
    while(iterator.hasNext())
    {
      IntermediarioVO intVO=(IntermediarioVO)iterator.next();
      String idIntermediario=intVO.getIdIntermediario();
      String denominazione=null;
      if (!SolmrConstants.LIVELLO_INTERMEDIARIO_DI_ZONA.equals(intVO.getLivello()))
      {
        denominazione=new StringBuffer(intVO.getDenominazione()).append(" (").append(intVO.getLivello()).append(")").toString();
      }
      else
      {
        denominazione=intVO.getDenominazione();
      }
      htmpl.newBlock("blkOptionIntermediario");
      htmpl.set("blkOptionIntermediario.value",idIntermediario);
      htmpl.set("blkOptionIntermediario.descr",denominazione);
      if (idIntermediario.equals(selected))
      {
        htmpl.set("blkOptionIntermediario.selected",SolmrConstants.HTML_SELECTED,null);
      }
    }
  }
%>