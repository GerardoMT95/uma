<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>



<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.jsf.htmpl.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.anag.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%

  AnagFacadeClient anagFacadeClient = new AnagFacadeClient();

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  java.io.InputStream layout = application.getResourceAsStream("layout/sceltaComune.htm");

  Htmpl htmpl = new Htmpl(layout);

  String provincia = request.getParameter("provincia");

  String comune = StringUtils.trim(request.getParameter("comune"));
  
  

  String obiettivo = request.getParameter("obiettivo");

  String provenienza = StringUtils.trim(request.getParameter("provenienza"));

  obiettivo = obiettivo==null?"":obiettivo;

  Vector elencoComuni = null;



  try {

    if(provenienza == null || provenienza.equals("")) {

      elencoComuni = anagFacadeClient.getComuniLikeProvAndCom(provincia,comune);

    }

    else {

      elencoComuni = anagFacadeClient.getComuniNonEstintiLikeProvAndCom(provincia,comune,null);

    }

  }

  catch(SolmrException se) {

    se.printStackTrace();
    htmpl.set("exception",AnagErrors.RICERCACOMUNI);

    htmpl.set("chiudi.pathToFollow", (String)session.getAttribute("pathToFollow"));

  }

  //SolmrLogger.debug(this,"Valore di elencoComuni: "+elencoComuni);

  if(elencoComuni != null) {

    htmpl.set("conferma.pathToFollow", (String)session.getAttribute("pathToFollow"));

    Iterator comuniIterator = elencoComuni.iterator();

    while(comuniIterator.hasNext()) {

      ComuneVO comuneVO = (ComuneVO)comuniIterator.next();

      htmpl.newBlock("elencoComuni");

      htmpl.set("elencoComuni.provincia",comuneVO.getDescrProv());

      htmpl.set("elencoComuni.comune",comuneVO.getDescom());

      htmpl.set("elencoComuni.istat",comuneVO.getIstatComune());

      htmpl.set("elencoComuni.istatComune",comuneVO.getIstatComune());

      htmpl.set("elencoComuni.istatProvincia",comuneVO.getIstatProvincia());

      htmpl.set("elencoComuni.cap",comuneVO.getCap());

      htmpl.set("elencoComuni.siglaProvincia",comuneVO.getSiglaProv());

      //

      htmpl.set("elencoComuni.zonaAltimetrica",String.valueOf(comuneVO.getZonaAlt()));

      htmpl.set("elencoComuni.codiceFiscaleComune",comuneVO.getCodfisc());

    }

  }

  htmpl.set("obiettivo", obiettivo);


  it.csi.solmr.presentation.security.Autorizzazione aut=
  (it.csi.solmr.presentation.security.Autorizzazione)
  it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ACCESSO_SISTEMA");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  aut.writeBanner(htmpl,ruoloUtenza,request);


%>

<%= htmpl.text()%>

