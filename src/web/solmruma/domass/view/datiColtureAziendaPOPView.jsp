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

    SolmrLogger.debug(this,"Caricamento di : datiColtureAziendaPOPView.jsp");

    String layoutUrl = "/domass/layout/datiColtureAziendaPOP.htm";

    ValidationException valEx;

    Validator validator = new Validator(layoutUrl);



    double totSupUtil = 0;

    double totUBASostenibili = 0;

    long totLitriColture = 0;

    long totLitriMST = 0;

    long totLitriASM = 0;



    Vector vect = (Vector)request.getAttribute("vect");

    SolmrLogger.debug(this,vect.toString());



    Htmpl htmpl = HtmplFactory.getInstance(application)

              .getHtmpl(layoutUrl);

    SolmrLogger.info(this, "Found layout: "+layoutUrl);


    int size = vect.size();

    SolmrLogger.debug(this,"prima del blocco");

    for(int i=0; i<size; i++)

    {

      FrmDettaglioAssegnazioneColtureVO dacVO = (FrmDettaglioAssegnazioneColtureVO)vect.get(i);

      htmpl.newBlock("blkCarburanteColture");



      htmpl.set("blkCarburanteColture.superficieUtilizzata", ((dacVO.getSuperficieUtilizzata().startsWith(".")?"0":"")+dacVO.getSuperficieUtilizzata()).replace('.', ','));

      htmpl.set("blkCarburanteColture.descrizione", dacVO.getDescrizione());

      htmpl.set("blkCarburanteColture.numeroFascia", dacVO.getNumeroFascia());

      htmpl.set("blkCarburanteColture.UBASostenibiliHA", ((dacVO.getUBASostenibiliHA().startsWith(".")?"0":"")+dacVO.getUBASostenibiliHA()).replace('.', ','));

      htmpl.set("blkCarburanteColture.UBATotali", ((dacVO.getUBATotali().startsWith(".")?"0":"")+dacVO.getUBATotali()).replace('.', ','));

      htmpl.set("blkCarburanteColture.carburanteLavorazione", dacVO.getCarburanteLavorazione());

      htmpl.set("blkCarburanteColture.carburanteMietitrebbiatura", dacVO.getCarburanteMietitrebbiatura());

      htmpl.set("blkCarburanteColture.carburanteEssicazione", dacVO.getCarburanteEssicazione());



      totSupUtil = totSupUtil + dacVO.getSuperficieUtilizzataDouble().doubleValue();

      totUBASostenibili = totUBASostenibili + dacVO.getUBATotaliDouble().doubleValue();

      totLitriColture = totLitriColture + dacVO.getCarburanteLavorazioneLong().longValue();

      totLitriMST = totLitriMST + dacVO.getCarburanteMietitrebbiaturaLong().longValue();

      totLitriASM = totLitriASM + dacVO.getCarburanteEssicazioneLong().longValue();



      SolmrLogger.debug(this,"\n\n############### dacVO.getCarburanteMietitrebbiaturaLong() "+dacVO.getCarburanteMietitrebbiaturaLong());

      SolmrLogger.debug(this,"############### dacVO.getCarburanteEssicazioneLong() "+dacVO.getCarburanteEssicazioneLong());

      SolmrLogger.debug(this,"############### dacVO.getSuperficieUtilizzataDouble() "+dacVO.getSuperficieUtilizzataDouble());

      SolmrLogger.debug(this,"############### totSupUtil "+totSupUtil);

    }

    SolmrLogger.debug(this,"dopo il blocco");



    htmpl.set("totSupUtil", (""+NumberUtils.arrotonda(totSupUtil, 2)).replace('.', ','));

    htmpl.set("totUBASostenibili", (""+NumberUtils.arrotonda(totUBASostenibili,4)).replace('.', ','));

    htmpl.set("totLitriColture", ""+totLitriColture);

    htmpl.set("totLitriMST", ""+totLitriMST);

    htmpl.set("totLitriASM", ""+totLitriASM);

    String annoRiferimento = (String)request.getAttribute("annoRiferimento"); 
    htmpl.set("annoDiRiferimento", annoRiferimento);


    it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

  it.csi.solmr.presentation.security.Autorizzazione aut=
  (it.csi.solmr.presentation.security.Autorizzazione)
  it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ACCESSO_SISTEMA");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  aut.writeBanner(htmpl,ruoloUtenza,request);


    out.print(htmpl.text());

%>