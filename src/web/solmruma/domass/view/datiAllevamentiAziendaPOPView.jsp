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

    SolmrLogger.debug(this,"Caricamento di : datiAllevamentoAziendaPOPView.jsp");

    String layoutUrl = "/domass/layout/datiAllevamentiAziendaPOP.htm";

    ValidationException valEx;

    Validator validator = new Validator(layoutUrl);



    double totaleUBAEqDichiarati = 0;

    double totaleUBASostenibili = 0;

    double totaleUBASostenibiliColture = 0;



    long totaleLitri = 0;



    Vector vect = (Vector)request.getAttribute("vect");

    Vector vectColture = (Vector)request.getAttribute("vectColture");

    SolmrLogger.debug(this,vect.toString());



    Htmpl htmpl = HtmplFactory.getInstance(application)

              .getHtmpl(layoutUrl);

    SolmrLogger.info(this, "Found layout: "+layoutUrl);

    int size = vect.size();

    SolmrLogger.debug(this,"prima del blocco");

    for(int i=0; i<size; i++)

    {

      FrmDettaglioAssegnazioneAllevamentoVO daaVO = (FrmDettaglioAssegnazioneAllevamentoVO)vect.get(i);

      htmpl.newBlock("blkCarburanteAllevamenti");



      htmpl.set("blkCarburanteAllevamenti.descrizioneSpecie", daaVO.getDescrizioneSpecie());

      SolmrLogger.debug(this,"daaVO.getDescrizioneSpecie()"+daaVO.getDescrizioneSpecie());

      htmpl.set("blkCarburanteAllevamenti.descrizioneCategoria", daaVO.getDescrizioneCategoria());

      SolmrLogger.debug(this,"daaVO.getDescrizioneCategoria()"+daaVO.getDescrizioneCategoria());

      htmpl.set("blkCarburanteAllevamenti.quantita", daaVO.getQuantita());

      SolmrLogger.debug(this,"daaVO.getQuantita()"+daaVO.getQuantita());

      htmpl.set("blkCarburanteAllevamenti.unitaDiMisura", daaVO.getUnitaDiMisura());

      SolmrLogger.debug(this,"daaVO.getUnitaDiMisura()"+daaVO.getUnitaDiMisura());

      htmpl.set("blkCarburanteAllevamenti.coefficienteUBA", ((daaVO.getCoefficienteUBA().startsWith(".")?"0":"")+daaVO.getCoefficienteUBA()).replace('.', ','));

      SolmrLogger.debug(this,"daaVO.getCoefficienteUBA()"+daaVO.getCoefficienteUBA());

      htmpl.set("blkCarburanteAllevamenti.UBATotali", ((daaVO.getUBATotali().startsWith(".")?"0":"")+daaVO.getUBATotali()).replace('.', ','));

      SolmrLogger.debug(this,"daaVO.getUBATotali()"+daaVO.getUBATotali());

      htmpl.set("blkCarburanteAllevamenti.quantitaSostenibile", daaVO.getQuantitaSostenibile());

      SolmrLogger.debug(this,"daaVO.getQuantitaSostenibile()"+daaVO.getQuantitaSostenibile());

      htmpl.set("blkCarburanteAllevamenti.UBASostenibili", daaVO.getUBASostenibili());

      SolmrLogger.debug(this,"daaVO.getUBASostenibili()"+daaVO.getUBASostenibili());

      htmpl.set("blkCarburanteAllevamenti.carburanteAllevamento", daaVO.getCarburanteAllevamento());

      SolmrLogger.debug(this,"daaVO.getCarburanteAllevamento()"+daaVO.getCarburanteAllevamento());



      totaleUBAEqDichiarati = totaleUBAEqDichiarati + daaVO.getUBATotaliDouble().doubleValue();

      totaleLitri = totaleLitri + daaVO.getCarburanteAllevamentoLong().longValue();

      totaleUBASostenibili = totaleUBASostenibili + daaVO.getUBASostenibiliDouble().doubleValue();

    }



    size = vectColture.size();

    for(int i=0; i<size; i++)

    {

      FrmDettaglioAssegnazioneColtureVO dacVO = (FrmDettaglioAssegnazioneColtureVO)vectColture.get(i);

      SolmrLogger.debug(this,"dacVO.getUBASostenibiliHADouble()"+dacVO.getUBASostenibiliHADouble());

      totaleUBASostenibiliColture = totaleUBASostenibiliColture + dacVO.getSuperficieUtilizzataDouble().doubleValue()*dacVO.getUBASostenibiliHADouble().doubleValue();

    }



    SolmrLogger.debug(this,"dopo il blocco");



    htmpl.set("totaleUBAEqDichiarati", (""+totaleUBAEqDichiarati).replace('.', ','));

    htmpl.set("totaleUBASostenibili", (""+NumberUtils.arrotonda(totaleUBASostenibili,4)).replace('.', ','));

    htmpl.set("totaleUBASostenibiliColture", (""+NumberUtils.arrotonda(totaleUBASostenibiliColture,4)).replace('.', ','));

    htmpl.set("totaleLitri", ""+totaleLitri);

    String annoRiferimento = (String)request.getAttribute("annoRiferimento"); 
    htmpl.set("annoDiRiferimento", annoRiferimento);

  it.csi.solmr.presentation.security.Autorizzazione aut=
  (it.csi.solmr.presentation.security.Autorizzazione)
  it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ACCESSO_SISTEMA");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  aut.writeBanner(htmpl, ruoloUtenza,request);

    it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

    out.print(htmpl.text());

%>