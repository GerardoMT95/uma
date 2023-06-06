<%@
  page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>



<%



  java.io.InputStream layout = application.getResourceAsStream("/macchina/layout/sceltaMarcaMatrice.htm");

  Htmpl htmpl = new Htmpl(layout);


  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();



  String descrizioneMarca = request.getParameter("descMarca");

  SolmrLogger.debug(this,"Valore di descrizioneMarca: "+descrizioneMarca);

  String genereMacchina = request.getParameter("idGenereMacchina");

  SolmrLogger.debug(this,"Valore di genereMacchina: "+genereMacchina);

  Vector elencoMarche = null;

  if(descrizioneMarca != null && !descrizioneMarca.equals("") && genereMacchina != null

     && !genereMacchina.equals("")) {

    try {

      elencoMarche = umaFacadeClient.getTipiMarcaByGenereMacchinaAndLikeMarca(Long.decode(genereMacchina),descrizioneMarca.toUpperCase());

    }

    catch(SolmrException se) {

    }

  }

  SolmrLogger.debug(this,"Valore di elencoMarche: "+elencoMarche.size());

  if(elencoMarche != null) {

    if(elencoMarche.size() == 0) {

      htmpl.newBlock("blkChiudi");

      htmpl.set("blkChiudi.exception", (String)UmaErrors.get("ERR_NESSUNA_MARCA_TROVATA"));

    }

    else {

      htmpl.newBlock("blkConfermaChiudi");

      htmpl.newBlock("blkIntestazione");

      Iterator iteraMarche = elencoMarche.iterator();

      while(iteraMarche.hasNext()) {

        htmpl.newBlock("blkElencoMarche");

        CodeDescr code = (CodeDescr)iteraMarche.next();

        htmpl.set("blkElencoMarche.idMarca", code.getCode().toString());

        htmpl.set("blkElencoMarche.descrizione", code.getDescription());

        htmpl.set("blkElencoMarche.matrice", code.getSecondaryCode());

      }

    }

  }

  it.csi.solmr.presentation.security.Autorizzazione aut=
  (it.csi.solmr.presentation.security.Autorizzazione)
  it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ACCESSO_SISTEMA");
  aut.writeBanner(htmpl,ruoloUtenza,request);
%>

<%= htmpl.text()%>

