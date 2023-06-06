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

  //public static final String LAYOUT="layout/modelloVerifiche.htm"; -- modificato il 26/5/2004

  public String LAYOUT=null;

  private static String[] nomiMesi = {"Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno",

                                      "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"};

%>

<%

  UmaFacadeClient umaClient = new UmaFacadeClient();

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");



  if(ruoloUtenza.isUtenteIntermediario())

    LAYOUT="layout/modelloVerificheIntermediario.htm";

  else

    LAYOUT="layout/modelloVerifiche.htm";



  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  Long idUtente = ruoloUtenza.getIdUtente();

  String idProvincia = request.getParameter("idProvincia");

  if (idProvincia == null)

    idProvincia = ruoloUtenza.getIstatProvincia();

  String anno = request.getParameter("anno");

  String mese = request.getParameter("mese");

  if (idProvincia!=null)

    htmpl.set("idProvincia", idProvincia);

  if (anno!=null)

    htmpl.set("anno", anno);

  else

    htmpl.set("anno", String.valueOf(DateUtils.getCurrentYear()));

  if (mese!=null)

    htmpl.set("mese", mese);



  if(!ruoloUtenza.isUtenteIntermediario())

  {

    Vector province=umaClient.getProvincieByRegione((String)SolmrConstants.get("ID_REGIONE"));

    int vectSize = province.size();

    htmpl.newBlock("blkProvincia");

    htmpl.set("blkProvincia.idProvincia","999");

    htmpl.set("blkProvincia.descProvincia","Regione TOBECONFIG");

    for(int i=0;i<vectSize;i++)

    {

      ProvinciaVO provinciaVO=(ProvinciaVO) province.get(i);

      htmpl.newBlock("blkProvincia");

      htmpl.set("blkProvincia.idProvincia",provinciaVO.getIstatProvincia());

      htmpl.set("blkProvincia.descProvincia",provinciaVO.getSiglaProvincia());

      if (!(ruoloUtenza.isUtenteRegionale()) &&

          provinciaVO.getIstatProvincia().equals(idProvincia))

      {

        htmpl.set("blkProvincia.selected","selected");

      }

    }

  }



  String valueMese=null;

  for (int i=0; i<nomiMesi.length; i++)

  {

    htmpl.newBlock("blkMese");

    valueMese=(i<9?"0":"")+(i+1);

    htmpl.set("blkMese.valueMese",valueMese);

    htmpl.set("blkMese.nomeMese",nomiMesi[i]);

    if (valueMese.equals(mese))

      htmpl.set("blkMese.selected","selected");

  }



  //==============================================================

  // Gestione annullamento stampa - copiato da modello39View.jsp

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



  if (request.getAttribute("errors") != null) {

    HtmplUtil.setErrors(htmpl,(ValidationErrors) request.getAttribute("errors") , request);

  } else {

    if (request.getParameter("conferma") != null) {

      htmpl.set("scriptModelloVerifiche", "stampaModelloVerifiche()");

    }

  }



  HtmplUtil.setValues(htmpl, request, (String) session.getAttribute("pathToFollow"));

  response.setContentType("text/html");

  out.println(htmpl.text());

%>