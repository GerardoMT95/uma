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
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%!

  public static final String LAYOUT="layout/modelloMovimentiMacchine.htm";

  private static String[][] strMesi = {{"Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno",

                                        "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"},

                                       {"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"}};

%>

<%

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  AnagFacadeClient anagFacadeClient = new AnagFacadeClient();

  UmaFacadeClient umaClient = new UmaFacadeClient();

  Collection collProvUMA = (Collection)anagFacadeClient.getProvinceByRegione(SolmrConstants.ID_REGIONE);

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  Long idUtente = ruoloUtenza.getIdUtente();


  Vector genere=new Vector();

  try  {

    genere=umaClient.getGenereMacchina();

  }  catch(SolmrException e) {

  }



  //==============================================================

  // Gestione annullamento stampa

  //==============================================================

  String strPagina = "";

  StringTokenizer st = new StringTokenizer(request.getHeader("Referer"),"/",false);

  while (st.hasMoreTokens()) { strPagina = st.nextToken(); }

  if ((session.getAttribute("paginaAnnulla") == null) || ("".equals((String) session.getAttribute("paginaAnnulla")))) {

    session.setAttribute("paginaAnnulla", strPagina);

  } else {

    strPagina = (String) session.getAttribute("paginaAnnulla");

  }

  htmpl.set("paginaAnnulla", strPagina);

  //==============================================================



  String strAnno = "" + DateUtils.getCurrentYear().intValue();

  String strMese = (DateUtils.getCurrentMonth().intValue()<9?"0":"")+DateUtils.getCurrentMonth().intValue();

  String selMese = request.getParameter("mese");

  String strGenere = request.getParameter("idGenereMacchina");



  if (request.getParameter("conferma") == null) {

    htmpl.set("anno", strAnno);

  }



  for (int i=0; i<strMesi[0].length; i++) {

    htmpl.newBlock("blkMese");

    htmpl.set("blkMese.valueMese",strMesi[1][i]);

    htmpl.set("blkMese.nomeMese",strMesi[0][i]);

    if (request.getParameter("conferma") == null) {

      if (strMese.equals(strMesi[1][i]))

        htmpl.set("blkMese.selected","selected");

    } else {

      if (selMese.equals(strMesi[1][i]))

        htmpl.set("blkMese.selected","selected");

    }

  }

/*

  ProvinciaVO provinciaVO = new ProvinciaVO();

  provinciaVO.setDescrizione("Tutte le provincie");

  provinciaVO.setIstatProvincia("999");

  provinciaVO.setSiglaProvincia("Regione TOBECONFIG");

  collProvUMA.add(provinciaVO);

*/

  ProvinciaVO provinciaVO = null;

  String idProvUma = (String)request.getParameter("provUMA");

  if (request.getParameter("conferma") == null) {

    if(collProvUMA!=null&&collProvUMA.size()>0){

      Iterator iterProvincia = collProvUMA.iterator();

      while(iterProvincia.hasNext()){

        provinciaVO = (ProvinciaVO)iterProvincia.next();

        htmpl.newBlock("comboProvUMA");

        htmpl.set("comboProvUMA.idProvUMA",""+provinciaVO.getIstatProvincia());

        htmpl.set("comboProvUMA.provUMA",provinciaVO.getSiglaProvincia());

        if(ruoloUtenza.isUtenteRegionale()) {

          if ("999".equals(provinciaVO.getIstatProvincia())) {

            htmpl.set("comboProvUMA.idProvUMASelPunt","selected");

          }

        } else {

          if (provinciaVO.getIstatProvincia().equals(ruoloUtenza.getIstatProvincia())) {

            htmpl.set("comboProvUMA.idProvUMASelPunt","selected");

          }

        }

      }

    }

    for(int i=0;i<genere.size();i++) {

      GenereMacchinaVO genereMacchinaVO=(GenereMacchinaVO) genere.get(i);

      htmpl.newBlock("blkComboGenere1");

      htmpl.set("blkComboGenere1.idGenereMacchina",""+genereMacchinaVO.getIdGenereMacchina());

      htmpl.set("blkComboGenere1.genereMacchinaDesc",""+genereMacchinaVO.getDescrizione() );

    }

  } else {

    if(collProvUMA!=null&&collProvUMA.size()>0){

      Iterator iterProvincia = collProvUMA.iterator();

      while(iterProvincia.hasNext()){

        provinciaVO = (ProvinciaVO)iterProvincia.next();

        htmpl.newBlock("comboProvUMA");

        htmpl.set("comboProvUMA.idProvUMA",""+provinciaVO.getIstatProvincia());

        htmpl.set("comboProvUMA.provUMA",provinciaVO.getSiglaProvincia());

        if(idProvUma!=null && provinciaVO.getIstatProvincia().equals(idProvUma)){

          htmpl.set("comboProvUMA.idProvUMASelPunt","selected");

        }

      }

    }

    for(int i=0;i<genere.size();i++) {

      GenereMacchinaVO genereMacchinaVO=(GenereMacchinaVO) genere.get(i);

      htmpl.newBlock("blkComboGenere1");

      htmpl.set("blkComboGenere1.idGenereMacchina",""+genereMacchinaVO.getIdGenereMacchina());

      htmpl.set("blkComboGenere1.genereMacchinaDesc",""+genereMacchinaVO.getDescrizione() );

      if (strGenere!=null && strGenere.equals(genereMacchinaVO.getIdGenereMacchina().toString())) {

        htmpl.set("blkComboGenere1.selectedGenereMacchina","selected");

      }

    }

  }



  if (request.getAttribute("errors") != null) {

    HtmplUtil.setErrors(htmpl,(ValidationErrors) request.getAttribute("errors") , request);

  } else {

    if (request.getParameter("conferma") != null) {

      htmpl.set("scriptMovimentiMacchine", "stampaMovimentiMacchine()");

    }

  }

  HtmplUtil.setValues(htmpl, request, (String) session.getAttribute("pathToFollow"));

  response.setContentType("text/html");

  out.println(htmpl.text());

%>