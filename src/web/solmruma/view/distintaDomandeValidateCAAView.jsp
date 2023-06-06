<%@ page language="java"

    contentType="text/html"

    isErrorPage="true"

%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.TreeMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.SolmrConstants" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.dto.comune.IntermediarioVO" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!

  public static final String LAYOUT="layout/distintaDomandeValidateCAA.htm";

%><%

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
  %><%@include file = "/include/menu.inc" %><%

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  TreeMap provinceTM=(TreeMap)request.getAttribute("province");
  Object province[]=provinceTM.values().toArray();
  int length=province==null?0:province.length;
  String istatProvinciaSelected=request.getParameter("istatProvincia");
  for(int i=0;i<length;i++)
  {
    htmpl.newBlock("blkProvincia");
    ProvinciaVO pVO=(ProvinciaVO) province[i];
    String istatProvincia=pVO.getIstatProvincia();
    if (istatProvincia.equals(istatProvinciaSelected))
    {
      htmpl.set("blkProvincia.selected",SolmrConstants.HTML_SELECTED,null);
    }
    htmpl.set("blkProvincia.istatProvincia",istatProvincia);
    htmpl.set("blkProvincia.descrizione",pVO.getSiglaProvincia());
  }

  String anno=request.getParameter("anno");
  if (anno==null)
  {
    anno=DateUtils.getCurrentYear().toString();
  }
  htmpl.set("anno",anno);

  String dalFoglio=request.getParameter("dalFoglio");
  if (dalFoglio==null)
  {
    dalFoglio="1";
  }
  htmpl.set("dalFoglio",dalFoglio);

  htmpl.set("alFoglio",request.getParameter("alFoglio"));

  TreeMap intermediariTM=(TreeMap)request.getAttribute("intermediari");
  java.util.Iterator iterator=intermediariTM.keySet().iterator();
  String idIntermediarioSelected=request.getParameter("idIntermediario");
  while(iterator.hasNext())
  {
    String key=(String)iterator.next();
    htmpl.newBlock("blkOptionCAA");
    IntermediarioVO iVO=(IntermediarioVO) intermediariTM.get(key);
    String idIntermediario=iVO.getIdIntermediario().toString();
    if (idIntermediario.equals(idIntermediarioSelected))
    {
      htmpl.set("blkOptionCAA.selected",SolmrConstants.HTML_SELECTED);
    }
    htmpl.set("blkOptionCAA.value",idIntermediario);
    htmpl.set("blkOptionCAA.descrizione",key);
  }

  ValidationErrors errorsList=(ValidationErrors) request.getAttribute("errors");
  HtmplUtil.setErrors(htmpl,errorsList ,request);

  String conferma=request.getParameter("conferma");
  if ("conferma".equals(conferma) || "report".equals(conferma))
  {
    Vector risultatiRicerca=(Vector) request.getAttribute("risultatiRicerca");
    if (risultatiRicerca==null)
    {
      if (errorsList==null)
      {
	    htmpl.newBlock("blkNoRisultati");
        htmpl.set("blkNoRisultati.msgErrore", UmaErrors.ERRORE_NESSUNA_DOMANDA_VALIDATA_TROVATA);
      }
    }
    else
    {
      doBlkResults(htmpl,risultatiRicerca,request);
      if ("report".equals(conferma) && request.getAttribute("errors")==null)
      {
        htmpl.newBlock("blkPopupReport");
      }
    }
  }
%><%=htmpl.text() %><%!
private void  doBlkResults(Htmpl htmpl,Vector risultatiRicerca,HttpServletRequest request)
{
  int size=risultatiRicerca.size();
  ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");
  htmpl.newBlock("blkRisultati");
  htmpl.set("blkRisultati.hdnIstatProvincia",request.getParameter("istatProvincia"));
  htmpl.set("blkRisultati.hdnAnno",request.getParameter("anno"));
  htmpl.set("blkRisultati.hdnIdIntermediario",request.getParameter("idIntermediario"));
  htmpl.set("blkRisultati.hdnDalFoglio",request.getParameter("dalFoglio"));
  htmpl.set("blkRisultati.hdnAlFoglio",request.getParameter("alFoglio"));
  htmpl.set("blkRisultati.hdnNumElementi",String.valueOf(size));
  String selezionati[]=request.getParameterValues("indexIntermediario");
  String rigaIniziale[]=request.getParameterValues("rigaIniziale");
  String rigaFinale[]=request.getParameterValues("rigaFinale");
  for(int i=0;i<size;i++)
  {
    String risultato[]=(String[])risultatiRicerca.get(i);
    htmpl.newBlock("blkRisultati.blkFoglio");

    if (i==0)
    {
      if (errors!=null && errors.get("indexIntermediario")!=null)
      {
        htmpl.set("blkRisultati.blkFoglio.err_indexIntermediario",getError(errors,"indexIntermediario",-1,request),null);
      }
    }

    String indexIntermediario=String.valueOf(i);
    htmpl.set("blkRisultati.blkFoglio.indexIntermediario",indexIntermediario);
    if (StringUtils.in(indexIntermediario,selezionati))
    {
      htmpl.set("blkRisultati.blkFoglio.checked",SolmrConstants.HTML_CHECKED,null);
    }

    htmpl.set("blkRisultati.blkFoglio.numeroFoglio",risultato[0]);
    String rigaInizialeStr=null;
    if (rigaIniziale==null)
    {
      rigaInizialeStr="1";
    }
    else
    {
      rigaInizialeStr=rigaIniziale[i];
    }
    htmpl.set("blkRisultati.blkFoglio.rigaIniziale",rigaInizialeStr);

    String rigaFinaleStr=null;
    if (rigaFinale==null)
    {
      rigaFinaleStr=risultato[1];
    }
    else
    {
      rigaFinaleStr=rigaFinale[i];
    }
    htmpl.set("blkRisultati.blkFoglio.rigaFinale",rigaFinaleStr);

    StringBuffer nomeIntemediario=new StringBuffer(risultato[2]);
    String nome=risultato[3];
    if (nome!=null)
    {
      nomeIntemediario.append(" - ").append(nome);
    }
    htmpl.set("blkRisultati.blkFoglio.desc",nomeIntemediario.toString());

    if (errors!=null) // Errori
    {
      htmpl.set("blkRisultati.blkFoglio.err_rigaIniziale",getError(errors,
      "rigaIniziale",i,request),null);
      htmpl.set("blkRisultati.blkFoglio.err_rigaFinale",getError(errors,
      "rigaFinale",i,request),null);
    }

  }
}

  private String getError(ValidationErrors errors, String name, int index,
                          HttpServletRequest request)
  {
    if (errors!=null)
    {
      String keyRiga=null;
      if (index>=0)
      {
        keyRiga=name+index;
      }
      else
      {
        keyRiga=name;
      }
      ValidationError errorRiga=getError(errors,keyRiga);
      if (errorRiga!=null)
      {
        return HtmplUtil.getHtmlErrorCode(keyRiga,errorRiga.getMessage(), request);
      }
    }
    return "";
  }

  private ValidationError getError(ValidationErrors errors, String key)
  {
    Iterator iterator=(Iterator)errors.get(key);
    if (iterator!=null)
    {
      return (ValidationError)iterator.next();
    }
    else
    {
      return null;
    }
  }
%>