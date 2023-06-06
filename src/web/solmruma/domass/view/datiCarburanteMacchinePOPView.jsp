<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>



<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.StoricoAssegnazioniVO"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%

    SolmrLogger.debug(this,"Entering datiMacchineAziendaPOPView");

    String layoutUrl = "/domass/layout/datiCarburanteMacchinePOP.htm";

    ValidationException valEx;

    Validator validator = new Validator(layoutUrl);



    long carburanteMacchina = 0;



    Vector vect = new Vector();

    vect = (Vector)request.getAttribute("vect");

    SolmrLogger.debug(this,vect.toString());



    Htmpl htmpl = HtmplFactory.getInstance(application)

              .getHtmpl(layoutUrl);

    SolmrLogger.info(this, "Found layout: "+layoutUrl);

    int size = vect.size();

    SolmrLogger.debug(this,"prima del blocco");

    for(int i=0; i<size; i++)

    {

      SolmrLogger.debug(this,"messaggio");

      FrmDettaglioAssegnazioneMacchineVO damVO = (FrmDettaglioAssegnazioneMacchineVO)vect.get(i);

      htmpl.newBlock("blkCarburanteMacchine");

      htmpl.set("blkCarburanteMacchine.descrizioneGenere", damVO.getDescrizioneGenere());

      htmpl.set("blkCarburanteMacchine.descrizioneMarca", damVO.getDescrizioneMarca());

      htmpl.set("blkCarburanteMacchine.tipoMacchina", damVO.getTipoMacchina());

      htmpl.set("blkCarburanteMacchine.potenzaKW", damVO.getPotenzaKW());

      SolmrLogger.debug(this,"PotenzaKW = " + damVO.getPotenzaKW());

      htmpl.set("blkCarburanteMacchine.carburanteAssegnato", damVO.getCarburanteAssegnato());



      carburanteMacchina = carburanteMacchina + damVO.getCarburanteAssegnatoLong().longValue();

    }



    SolmrLogger.debug(this,"dopo il blocco");



    htmpl.set("totCarburanteAssegnato", ""+carburanteMacchina);

    String annoRiferimento = (String)request.getAttribute("annoRiferimento"); 
    htmpl.set("annoDiRiferimento", annoRiferimento);


    it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

  it.csi.solmr.presentation.security.Autorizzazione aut=
  (it.csi.solmr.presentation.security.Autorizzazione)
  it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ACCESSO_SISTEMA");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  aut.writeBanner(htmpl,ruoloUtenza,request);


    out.print(htmpl.text());

    SolmrLogger.debug(this,"Exiting datiMacchineAziendaPOPView");

%>