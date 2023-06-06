<%@ page language="java"

      contentType="text/html"

      isErrorPage="true"

  %>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.dto.comune.IntermediarioVO" %>

<%

  SolmrLogger.debug(this,"[dettaglioBuonoView::service] BEGIN.");

  java.io.InputStream layout = application.getResourceAsStream("/domass/layout/dettaglioBuonoPOP.htm");

  UmaFacadeClient client = new UmaFacadeClient();

  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  HtmplUtil.setErrors(htmpl, errors, request);

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


  Vector v_carb = (Vector)session.getAttribute("v_carb");

  Vector stampe = (Vector)session.getAttribute("stampe");
  HashMap hm = (HashMap)session.getAttribute("ruoloUtenzaLocal");

  BuonoPrelievoVO buonoVO = (BuonoPrelievoVO)session.getAttribute("buonoVO");

  BuonoCarburanteVO carbVO = null;

  boolean reso = request.getAttribute("reso")!=null;

  SolmrLogger.debug(this,"[dettaglioBuonoView::service] Valore di reso??? "+reso);

  String dataModConc = "";

  String dataModPrel = "";

  Long idStatoDomanda = null;

  Long primoIdDomAss = null;

  SolmrLogger.debug(this,"[dettaglioBuonoView::service] Primo IdDomAss "+request.getParameter("primoIdDomAss"));

  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");



  // Settaggio dei dati comuni

  String provCompetenza ="";

  if(dittaVO.getProvUMA()!=null&&!dittaVO.getProvUMA().equals(""))

    provCompetenza = client.getProvinciaByIstat(dittaVO.getProvUMA());

  htmpl.set("provinciaUMA", provCompetenza);

  if(dittaVO.getCuaa()!=null &&!dittaVO.getCuaa().equals("")){

   htmpl.set("CUAA", dittaVO.getCuaa()+" - ");

  }

  HtmplUtil.setValues(htmpl, dittaVO);

  // Valorizzo le voci del menù di sx

  if(reso){

   htmpl.newBlock("blkReso");

   if(buonoVO.getIdDittaUma()!=null&&!buonoVO.getIdDittaUma().equals(new Long("0"))){

     SolmrLogger.debug(this,"[dettaglioBuonoView::service] Entro....");

     htmpl.set("blkReso.dittaUMA", buonoVO.getIdDittaUma().toString());

     SolmrLogger.debug(this,"[dettaglioBuonoView::service] buonoVO.getProvenienza "+buonoVO.getExtProvinciaProvenienza());

     htmpl.set("blkReso.prov", buonoVO.getExtProvinciaProvenienza());

   }

   htmpl.set("quantita", "restituita");

  }

  else{

    if(request.getParameter("primoIdDomAss")!=null&&!request.getParameter("primoIdDomAss").equals(""))

    primoIdDomAss = new Long(request.getParameter("primoIdDomAss"));

    SolmrLogger.debug(this,"[dettaglioBuonoView::service] Confronto tra idDomAss "+primoIdDomAss+" - "+buonoVO.getIdDomandaAssegnazione());

    if(primoIdDomAss!=null && primoIdDomAss.compareTo(buonoVO.getIdDomandaAssegnazione())==0){

      if(request.getParameter("idStatoDomanda")!=null && !request.getParameter("idStatoDomanda").equals("")){

        idStatoDomanda = new Long(request.getParameter("idStatoDomanda"));

        if(idStatoDomanda.toString().equals(SolmrConstants.ID_STATO_DOMANDA_VALIDATA)){

          if(ruoloUtenza.isUtenteProvinciale() || ruoloUtenza.isUtenteRegionale()){

     /*  if (ruoloUtenza.isReadWrite()&&

    ruoloUtenza.getIstatProvincia().equals(dittaVO.getProvUMA())) { */

        htmpl.newBlock("blkAnnulla");

        htmpl.newBlock("blkRestituisci");

        htmpl.newBlock("blkCancella");

     /*  } */ 

            //if (pu.getIstatProvincia().equals(dittaVO.getProvCompetenza())) {
            if (ruoloUtenza.getIstatProvincia()!=null && ruoloUtenza.getIstatProvincia().equals(dittaVO.getProvUMA())) {

              htmpl.newBlock("blk101");

            }

          }

          else if(ruoloUtenza.isUtenteIntermediario()&&ruoloUtenza.isReadWrite()){

            htmpl.newBlock("blkRestituisci");

            htmpl.newBlock("blkCancella");

          }

        }

      }

    }



    htmpl.newBlock("blkNonReso");

    if(buonoVO.getIdDittaUma()!=null&&!buonoVO.getIdDittaUma().equals(new Long("0"))){

      SolmrLogger.debug(this,"[dettaglioBuonoView::service] Entro....");

      htmpl.set("blkNonReso.dittaUMA", buonoVO.getIdDittaUma().toString());

      htmpl.set("blkNonReso.prov", buonoVO.getExtProvinciaProvenienza());

    }

    if(buonoVO.getExtIdIntermediarioEmissione() == null) {
      htmpl.set("interm", "Ufficio UMA Provinciale");
    }
    else {
      IntermediarioVO intermediarioVO = (IntermediarioVO)session.getAttribute("intermediarioVOEmissione");
      String cf = intermediarioVO.getCodiceFiscale();
      String de = intermediarioVO.getDenominazione();
      if(cf == null) {
        cf = "";
      }
      if(de == null) {
        de = "";
      }
      htmpl.set("interm", cf + " - " + de);
    }

    if(buonoVO.getExtIdUtenteEmissione() == null) {
      htmpl.set("utenteEm", "");
    }
    else {
      RuoloUtenza ru = (RuoloUtenza)session.getAttribute("ruUt");
      String dn = ru.getDenominazione();
      String de = ru.getDescrizioneEnte();
      if(dn == null) {
        dn = "";
      }
      if(de == null) {
        de = "";
      }
      htmpl.set("utenteEm", dn + " - " + de);
    }


    htmpl.newBlock("blkColonnaPrel");

    htmpl.newBlock("blkGasolio");

    htmpl.newBlock("blkBenzina");

    htmpl.newBlock("blkTotale");

    htmpl.newBlock("blkModifica");

    htmpl.set("quantita", "concessa");

    if(buonoVO.getDataRestituzione()!=null)

      htmpl.set("blkNonReso.dataRestituzione", DateUtils.formatDate(buonoVO.getDataRestituzione()));

  }

  htmpl.set("idBuonoPrelievo", buonoVO.getIdBuonoPrelievo()!=null?buonoVO.getIdBuonoPrelievo().toString():null);

  htmpl.set("anno", buonoVO.getAnnoRiferimento().toString());

  htmpl.set("blocco", buonoVO.getNumeroBlocco().toString());

  htmpl.set("buono", buonoVO.getNumeroBuono().toString());

  if (buonoVO.getDataEmissione()!=null)

  htmpl.set("dataEmissione", DateUtils.formatDate(buonoVO.getDataEmissione()));

  if(buonoVO.getIdConduzione()!=null){
      htmpl.set("tipoUtilizzo", buonoVO.getIdConduzione().longValue() == 1L ? "Conto proprio" : "Conto terzi");
    }else{
      htmpl.set("tipoUtilizzo", "Serra");
    }


  // Modifica Dati Stampa Buono  Begin

  if (buonoVO.getDataStampa()!=null)

  htmpl.set("dataStampa", DateUtils.formatDate(buonoVO.getDataStampa()));

  htmpl.set("numeroDuplicati", buonoVO.getNumeroDuplicati());

  // Modifica Dati Stampa Buono - End



  htmpl.set("prov", buonoVO.getExtProvinciaProvenienza());

  if(buonoVO.getAnnullato()!=null && buonoVO.getAnnullato().equals(SolmrConstants.FLAG_SI))

    htmpl.set("annullato", SolmrConstants.ANNULLATO);

  if(buonoVO.getCarburantePerSerra()!=null && buonoVO.getCarburantePerSerra().equals(SolmrConstants.CARBURANTE_PER_SERRA))

    htmpl.set("carburanteSerra", SolmrConstants.DESC_CARBURANTE_PER_SERRA);

  if(buonoVO.getDataAggiornamento()!=null)

    dataModConc = DateUtils.formatDate(buonoVO.getDataAggiornamento());

  if(buonoVO.getUtente()!=null)

    dataModConc+= " ("+buonoVO.getUtente()+")";

  SolmrLogger.debug(this,"[dettaglioBuonoView::service] Data Modifica conc "+dataModConc);

  htmpl.set("dataModConc", dataModConc);



  int gPrel = 0;

  int gConc = 0;

  int bPrel = 0;

  int bConc = 0;

  int cTot = 0;

  int pTot = 0;

  int gUltimoPrel=0;
  int bUltimoPrel=0;
  Date gDataUltimoPrel=null;
  Date bDataUltimoPrel=null;



  Iterator i = v_carb.iterator();

  while(i.hasNext()){

    carbVO = (BuonoCarburanteVO)i.next();

    if(carbVO.getDataAggiornamentoPrelievo()!=null)

      dataModPrel = DateUtils.formatDate(carbVO.getDataAggiornamentoPrelievo());

    if(carbVO.getUtenteAggiornamentoPrelievo()!=null)

      dataModPrel+= " ("+carbVO.getUtenteAggiornamentoPrelievo()+")";

    SolmrLogger.debug(this,"[dettaglioBuonoView::service] Data mod prel "+dataModPrel);

    SolmrLogger.debug(this,"[dettaglioBuonoView::service] carbVO ultima mod prel: ("+carbVO.getDataAggiornamentoPrelievo()+" - "+

                       carbVO.getUtenteAggiornamentoPrelievo());

    if(carbVO.getCarburante().equals(SolmrConstants.ID_BENZINA)){

      bPrel += carbVO.getTotQuantitaPrelievo().intValue();

      bConc = carbVO.getQuantitaConcessa().intValue();
      if (carbVO.getQtaUltimoPrelievo()!=null)
      {
        bUltimoPrel=carbVO.getQtaUltimoPrelievo().intValue();
      }
      if (carbVO.getDataUltimoPrelievo()!=null)
      {
        bDataUltimoPrel=carbVO.getDataUltimoPrelievo();
      }
    }

    else if(carbVO.getCarburante().equals(SolmrConstants.ID_GASOLIO)){

      gPrel += carbVO.getTotQuantitaPrelievo().intValue();

      gConc = carbVO.getQuantitaConcessa().intValue();
      if (carbVO.getQtaUltimoPrelievo()!=null)
      {
        gUltimoPrel=carbVO.getQtaUltimoPrelievo().intValue();
      }
      if (carbVO.getDataUltimoPrelievo()!=null)
      {
        gDataUltimoPrel=carbVO.getDataUltimoPrelievo();
      }

    }

  }

  if(!reso)

    htmpl.set("blkModifica.dataModPrel", dataModPrel);

  cTot = gConc+bConc;

  pTot = gPrel+bPrel;



  if(gConc!=0)

    htmpl.set("gasolioConc", gConc+" Litri");

  if(gPrel!=0)

    htmpl.set("blkGasolio.gasolioPrel", gPrel+" Litri");

  if(bConc!=0)

    htmpl.set("benzinaConc", bConc+" Litri");

  if(bPrel!=0)

    htmpl.set("blkBenzina.benzinaPrel", bPrel+" Litri");

  if(cTot!=0)

    htmpl.set("concTot", cTot+" Litri");

  if(pTot!=0)

    htmpl.set("blkTotale.prelTot", pTot+" Litri");

  if(bUltimoPrel!=0)
    htmpl.set("blkBenzina.qtaUltimoPrel", bUltimoPrel+" Litri");
  if(bDataUltimoPrel!=null)
    htmpl.set("blkBenzina.dataUltimoPrel", DateUtils.formatDate(bDataUltimoPrel));


  if(gUltimoPrel!=0)
    htmpl.set("blkGasolio.qtaUltimoPrel", gUltimoPrel+" Litri");
  if(gDataUltimoPrel!=null)
    htmpl.set("blkGasolio.dataUltimoPrel", DateUtils.formatDate(gDataUltimoPrel));


  String fwdUrl=request.getParameter("fwdUrl");

  if (fwdUrl!=null)

    htmpl.set("mod101open","mod101();");


  // AGGIUNTO DA Andrea IL 23/11/2006 PER IL RIEPILOGO STAMPA DEI BUONI
  if(stampe != null && stampe.size() > 0) {
    htmpl.newBlock("blkStampaExist");
    htmpl.newBlock("blkStampa");
    for(int j = 0; j < stampe.size(); j ++) {
      StampaBuonoVO sbvo = (StampaBuonoVO)stampe.get(j);
      Long idUtente = new Long(sbvo.getExtIdUtenteStampa());
      RuoloUtenza ru = (RuoloUtenza)hm.get(idUtente);
      htmpl.set("blkStampaExist.blkStampa.utente", ru.getDenominazione());
      htmpl.set("blkStampaExist.blkStampa.ente", ru.getDescrizioneEnte());
      htmpl.set("blkStampaExist.blkStampa.data", sbvo.getDataStampaFormatted());
    }
  }


  SolmrLogger.debug(this,"[dettaglioBuonoView::service] END.");

%>

<%= htmpl.text()%>