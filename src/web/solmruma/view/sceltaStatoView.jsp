  <%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>



<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.anag.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>





<%



  AnagFacadeClient anagFacadeClient = new AnagFacadeClient();



  java.io.InputStream layout = application.getResourceAsStream("layout/sceltaStato.htm");

  Htmpl htmpl = new Htmpl(layout);

  String obiettivo=request.getParameter("obiettivo");

  if (obiettivo!=null)

  {

    htmpl.set("obiettivo",obiettivo);

  }

  String statoEstero = request.getParameter("stato");



  Vector elencoStati = null;



  try {

    elencoStati = anagFacadeClient.ricercaStatoEstero(statoEstero,"");

  }

  catch(SolmrException se) {

    htmpl.set("exception",AnagErrors.RICERCASTATOESTERO);

  }

  if(elencoStati != null) {

    htmpl.set("conferma.pathToFollow", (String)session.getAttribute("pathToFollow"));

    Iterator statiIterator = elencoStati.iterator();

    while(statiIterator.hasNext()) {

      ComuneVO comuneVO = (ComuneVO)statiIterator.next();

      htmpl.newBlock("elencoStati");

      htmpl.set("elencoStati.stato",comuneVO.getDescom());

      htmpl.set("elencoStati.istat",comuneVO.getIstatComune());

      htmpl.set("elencoStati.siglaStato",comuneVO.getDescom());

    }

  }



  it.csi.solmr.presentation.security.Autorizzazione aut=
  (it.csi.solmr.presentation.security.Autorizzazione)
  it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ACCESSO_SISTEMA");
   RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  aut.writeBanner(htmpl, ruoloUtenza,request);


  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl, exception);
%>

<%= htmpl.text()%>





