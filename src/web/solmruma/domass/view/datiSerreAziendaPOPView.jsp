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

    SolmrLogger.debug(this,"[datiSerreAziendaPOPView::service] Caricamento di : datiSerreAziendaPOPView.jsp");

    String layoutUrl = "/domass/layout/datiSerreAziendaPOP.htm";

    ValidationException valEx;

    Validator validator = new Validator(layoutUrl);



    long totaleCarburanteSerre = 0;



    Vector vect = (Vector)request.getAttribute("vect");

    SolmrLogger.debug(this,vect.toString());



    Htmpl htmpl = HtmplFactory.getInstance(application)

              .getHtmpl(layoutUrl);

    SolmrLogger.info(this, "Found layout: "+layoutUrl);

    int size = vect.size();

    int totaleVolumeMetriCubi=0;
    int totaleVolumeRidotto=0;
    SolmrLogger.debug(this,"[datiSerreAziendaPOPView::service] prima del blocco");

    for(int i=0; i<size; i++)

    {

      FrmDettaglioAssegnazioneSerreVO dasVO = (FrmDettaglioAssegnazioneSerreVO)vect.get(i);

      htmpl.newBlock("blkCarburanteSerre");



      htmpl.set("blkCarburanteSerre.descrizioneColtura", dasVO.getDescrizioneColtura());

      SolmrLogger.debug(this,"[datiSerreAziendaPOPView::service] getDescrizioneColtura = "+dasVO.getDescrizioneColtura());

      htmpl.set("blkCarburanteSerre.descrizioneForma", dasVO.getDescrizioneForma());

      SolmrLogger.debug(this,"[datiSerreAziendaPOPView::service] getDescrizioneForma = "+dasVO.getDescrizioneForma());

      htmpl.set("blkCarburanteSerre.volumeMetriCubi", dasVO.getVolumeMetriCubi());

      htmpl.set("blkCarburanteSerre.volumeRidotto", StringUtils.checkNull(dasVO.getVolumeRidotto()));

      SolmrLogger.debug(this,"[datiSerreAziendaPOPView::service] getVolumeMetriCubi = "+dasVO.getVolumeMetriCubi());

      htmpl.set("blkCarburanteSerre.mesiDiRiscaldamento", dasVO.getMesiDiRiscaldamento());

      SolmrLogger.debug(this,"[datiSerreAziendaPOPView::service] getMesiDiRiscaldamento = "+dasVO.getMesiDiRiscaldamento());

      htmpl.set("blkCarburanteSerre.giorniRiscaldamentoAnnuali", dasVO.getGiorniRiscaldamentoAnnuali());

      SolmrLogger.debug(this,"[datiSerreAziendaPOPView::service] getGiorniRiscaldamentoAnnuali = "+dasVO.getGiorniRiscaldamentoAnnuali());

      htmpl.set("blkCarburanteSerre.carburanteRiscaldamento", dasVO.getCarburanteRiscaldamento());

      SolmrLogger.debug(this,"[datiSerreAziendaPOPView::service] getCarburanteRiscaldamento = "+dasVO.getCarburanteRiscaldamento());
      
      if (dasVO.getVolumeMetriCubi()!=null) {
        totaleVolumeMetriCubi+=dasVO.getVolumeMetriCubiLong().intValue();
      }

      if (dasVO.getVolumeRidotto()!=null) {
        totaleVolumeRidotto+=dasVO.getVolumeRidotto().intValue();
      }

      totaleCarburanteSerre = totaleCarburanteSerre + dasVO.getCarburanteRiscaldamentoLong().longValue();

    }

    SolmrLogger.debug(this,"[datiSerreAziendaPOPView::service] dopo il blocco");

    htmpl.set("totaleCarburanteSerre", ""+totaleCarburanteSerre);
    htmpl.set("totaleVolumeMetriCubi", String.valueOf(totaleVolumeMetriCubi));
    htmpl.set("totaleVolumeRidotto", String.valueOf(totaleVolumeRidotto));

    String annoRiferimento = (String)request.getAttribute("annoRiferimento");
    htmpl.set("annoDiRiferimento", annoRiferimento);

    it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

  it.csi.solmr.presentation.security.Autorizzazione aut=
  (it.csi.solmr.presentation.security.Autorizzazione)
  it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ACCESSO_SISTEMA");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  aut.writeBanner(htmpl, ruoloUtenza,request);

    out.print(htmpl.text());

%>