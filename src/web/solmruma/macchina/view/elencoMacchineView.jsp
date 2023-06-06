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
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  public static final String LAYOUT="macchina/layout/elencoMacchine.htm";
  private static final String elencoPagine[]={"/dettaglioMacchinaDittaDati.htm",
                                              "/modificaMacchinaDittaDati.htm",
                                              "/dettaglioMacchinaDati.htm",
                                              "/dettaglioMacchinaDittaUtilizzo.htm",
                                              "/dettaglioUtilizzo.htm",
                                              "/modificaUtilizzo.htm",
                                              "/scaricoMacchina.htm",
                                              "dettaglioMacchinaDettaglioUtilizzo.htm",
                                              "/caricoMacchina.htm",
                                              "/dettaglioMacchinaComporprietari.htm",
                                              "/dettaglioMacchinaDettaglioComproprietari.htm",
                                              "/dettaglioMacchinaDittaComproprietari.htm",
                                              "/dettaglioMacchinaDittaDettaglioComproprietari.htm",
                                              "/dettaglioMacchinaDittaNuovaAttestazione.htm",
                                              "/dettaglioMacchinaImmatricolazioni.htm",
                                              "/dettaglioMacchinaDittaImmatricolazioni.htm",
                                              "/dettaglioTarga.htm",
                                              "/nuovaImmatricolazione.htm",
                                              "/nuovaImmatricolazioneConferma.htm",
                                              "/venditaFuoriRegione.htm",
                                              "/venditaFuoriRegioneConferma.htm",
                                              "/conferma.htm"};
%>
<%
  UmaFacadeClient umaClient = new UmaFacadeClient();
  String storicizzazione=request.getParameter("storico");
  Vector macchine=null;
  Htmpl htmpl = HtmplFactory.getInstance(application)
                .getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  setComboGenereMacchina(htmpl,(Vector)request.getAttribute("tipiGenereMacchina"),request);
  HtmplUtil.setErrors(htmpl, (ValidationErrors) request.getAttribute("errors"), request);

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

  Long idDittaUma=(Long) session.getAttribute("idDittaUma");
  macchine=(Vector)request.getAttribute("elencoMacchine");
  if (macchine==null)
  {
    SolmrLogger.debug(this,"elencoMacchine==null");
    macchine=new Vector(); // Evito nullpointerexception
  }
  String startRowStr=request.getParameter("startRow");
  int startRow=0;
  int rows=macchine.size();

  if (startRowStr!=null)
  {
    try
    {
      startRow=new Integer(startRowStr).intValue();
    }
    catch(Exception e) // Errore, suppongo startrow==0 e quindi non faccio nulla!!!
    {
    }
  }
  else
  {
    startRow=checkPageFrom(request,session);
  }
  session.setAttribute("currentPage",new Long(startRow));
  session.removeAttribute("elencoMacchineBis");
  int prevPage=startRow-SolmrConstants.NUM_MAX_ROWS_PAG;
  int nextPage=startRow+SolmrConstants.NUM_MAX_ROWS_PAG;
  if (nextPage>=rows)
  {
    nextPage=startRow;
  }
  if (prevPage<=0)
  {
    prevPage=0;
  }
  int maxPage=rows/SolmrConstants.NUM_MAX_ROWS_PAG+(rows%SolmrConstants.NUM_MAX_ROWS_PAG>0?1:0);
  if (macchine.size()==0)
  {
    maxPage=1;
  }
  int currentPage=startRow/SolmrConstants.NUM_MAX_ROWS_PAG+1+(startRow%SolmrConstants.NUM_MAX_ROWS_PAG>0?1:0);

  int size=macchine.size();
  SolmrLogger.debug(this,"currentPage="+currentPage);
  SolmrLogger.debug(this,"maxPage="+maxPage);
  if (currentPage!=1)
  {
    htmpl.set("prev.prevPage",""+prevPage);
  }
  if (currentPage!=maxPage)
  {
    htmpl.set("next.nextPage",""+nextPage);
  }
  htmpl.set("numMacchine",""+macchine.size());
  htmpl.set("maxPage",""+maxPage);
  htmpl.set("currentPage",""+currentPage);
  if (macchine.size()!=0)
  {
    htmpl.newBlock("blkIntestazione");
  }
  for(int i=startRow;i<size && i< startRow+SolmrConstants.NUM_MAX_ROWS_PAG;i++)
  {
    htmpl.newBlock("blkMacchina");
    MacchinaVO macchinaVO=(MacchinaVO)macchine.get(i);
    
    SolmrLogger.debug(this, "-- idMacchina ="+macchinaVO.getIdMacchina());
    htmpl.set("blkMacchina.idMacchina",macchinaVO.getIdMacchina());
    
    SolmrLogger.debug(this, "-- idUtilizzo ="+macchinaVO.getUtilizzoVO().getIdUtilizzo());
    htmpl.set("blkMacchina.idUtilizzo", macchinaVO.getUtilizzoVO().getIdUtilizzo());
        
    MatriceVO matriceVO=macchinaVO.getMatriceVO();
    if (macchinaVO.getMatriceVO()!=null)
    {
      SolmrLogger.debug(this,"macchinaVO.getMatriceVO().getIdMatrice()="+macchinaVO.getMatriceVO().getIdMatrice());
    }
    if (macchinaVO.getDatiMacchinaVO()!=null)
    {
      SolmrLogger.debug(this,"macchinaVO.getDatiMacchinaVO().getIdDatiMacchina()="+macchinaVO.getDatiMacchinaVO().getIdDatiMacchina());
    }
//    htmpl.set("blkMacchina.dataCarico",formatDate(macchinaVO.getDataCaricoDate()));
    htmpl.set("blkMacchina.dataCarico",macchinaVO.getUtilizzoVO().getDataCarico());
    htmpl.set("blkMacchina.targa",macchinaVO.getTargaCorrente()==null?"":macchinaVO.getTargaCorrente().getNumeroTarga());
    if (matriceVO==null)
    {
      DatiMacchinaVO datiVO=macchinaVO.getDatiMacchinaVO();
      htmpl.set("blkMacchina.descGenereMacchina",datiVO.getCodBreveGenereMacchina());
      htmpl.set("blkMacchina.descCategoria",datiVO.getDescCategoria());
      htmpl.set("blkMacchina.descMarca",datiVO.getMarca());
      htmpl.set("blkMacchina.tipoMacchina",datiVO.getTipoMacchina());
    }
    else
    {
      htmpl.set("blkMacchina.descGenereMacchina",matriceVO.getCodBreveGenereMacchina());
      htmpl.set("blkMacchina.descCategoria",matriceVO.getDescCategoria());
      htmpl.set("blkMacchina.descMarca",matriceVO.getDescMarca());
      htmpl.set("blkMacchina.tipoMacchina",matriceVO.getTipoMacchina());
    }
    htmpl.set("blkMacchina.descBreveAlimentazione",macchinaVO.getDescBreveAlimentazione());
    htmpl.set("blkMacchina.matricolaTelaio",macchinaVO.getMatricolaTelaio());
    UtilizzoVO utilizzoVO = macchinaVO.getUtilizzoVO();
    htmpl.set("blkMacchina.formaPossesso",utilizzoVO.getDescLastPossessoVO());

  }
  request.getSession().removeAttribute("eliminaVar");
  Long idGenereMacchinaLong=(Long) request.getAttribute("idGenereMacchinaLong");
  String selectedGenereMacchina=idGenereMacchinaLong==null?null:idGenereMacchinaLong.toString();
  htmpl.set("idGenereMacchina",selectedGenereMacchina);
  out.print(htmpl.text());
%>
<%!
  private void setComboGenereMacchina(Htmpl htmpl,Vector tipiGenereMacchina,HttpServletRequest request)
  {
    SolmrLogger.debug(this,"tipiGenereMacchina="+tipiGenereMacchina);
    if (tipiGenereMacchina==null)
    {
      return;
    }
    int size=tipiGenereMacchina.size();
    Long idGenereMacchinaLong=(Long) request.getAttribute("idGenereMacchinaLong");
    String selectedGenereMacchina=idGenereMacchinaLong==null?null:idGenereMacchinaLong.toString();
    if ("".equals(selectedGenereMacchina))
    {
      selectedGenereMacchina=null;
    }
    for(int i=0;i<size;i++)
    {
      CodeDescription  cd=(CodeDescription )tipiGenereMacchina.get(i);
      SolmrLogger.debug(this,"tipiGenereMacchina.idGenereMacchina="+cd.getCode());
      SolmrLogger.debug(this,"tipiGenereMacchina.descGenereMacchina="+cd.getDescription());
      htmpl.newBlock("blkTipoGenereMacchina");
      String code=""+cd.getCode();
      htmpl.set("blkTipoGenereMacchina.idGenereMacchina",""+cd.getCode());
      htmpl.set("blkTipoGenereMacchina.descGenereMacchina",cd.getDescription());
      if (code.equals(selectedGenereMacchina))
      {
        htmpl.set("blkTipoGenereMacchina.selected","selected");
      }
    }
  }
  private String formatDate(Date date)
  {
    if (date!=null)
    {
      return DateUtils.formatDate(date);
    }
    return "";
  }

  private int checkPageFrom(HttpServletRequest request,HttpSession session)
  {
    SolmrLogger.debug(this,"checkPageFrom");
    String referer=request.getHeader("Referer");
    SolmrLogger.debug(this,"referer="+referer);
    if (referer==null)
    {
      return 0;
    }
    for(int i=0;i<elencoPagine.length;i++)
    {
      if (referer.endsWith(elencoPagine[i]))
      {
        Long currentPage=(Long)session.getAttribute("currentPage");
        SolmrLogger.debug(this,"TROVATO "+currentPage);
        return currentPage==null?0:currentPage.intValue();
      }
    }
    if (request.getSession().getAttribute("eliminaVar")!=null)
    {
      Long currentPage=(Long)session.getAttribute("currentPage");
      SolmrLogger.debug(this,"TROVATO ELIMINAVAR "+currentPage);
      return currentPage==null?0:currentPage.intValue();
    }
    SolmrLogger.debug(this,"NON TROVATO");
    return 0;
  }
%>