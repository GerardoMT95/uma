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
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
  SolmrLogger.debug(this, "buoniPrelievoView.jsp - Begin");

  java.io.InputStream layout = application.getResourceAsStream("/domass/layout/elencoBuoniEmessi.htm");

  UmaFacadeClient client = new UmaFacadeClient();

  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
  Vector v_buoni = (Vector)request.getAttribute("v_buoni");

  BuonoPrelievoVO buonoVO = null;

  Vector v_domass = (Vector)session.getAttribute("v_domass");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

  Long idStatoDomanda = null;

  Long idDomAss = (Long)request.getAttribute("idDomAss");

  DomandaAssegnazione domAssToCompare = null;

  String provCompetenza ="";



  //04/03/23 - Problema selezione buono - Begin

  /*String idBuonoPrelievoSelected = null;

  if (request.getParameter("radiobuttonPrelievo")!=null)

    idBuonoPrelievoSelected = request.getParameter("radiobuttonPrelievo");

  if (request.getParameter("radiobuttonRest")!=null)

    idBuonoPrelievoSelected = request.getParameter("radiobuttonRest");*/

  String idBuonoPrelievo = request.getParameter("idBuonoPrelievo");
  if(idBuonoPrelievo == null) {
    idBuonoPrelievo = request.getParameter("idBuono");
  }

  //04/03/23 - Problema selezione buono - End



  boolean isOnThisProvRW = ruoloUtenza!=null&&dittaUMAAziendaVO!=null&&

         ruoloUtenza.isUtenteProvinciale()&&

         ruoloUtenza.getIstatProvincia().equalsIgnoreCase(dittaUMAAziendaVO.getProvUMA())&&

         ruoloUtenza.isReadWrite();

  boolean isThisProvComp = ruoloUtenza!=null&&dittaUMAAziendaVO!=null&&

                           ruoloUtenza.getIstatProvincia().equalsIgnoreCase(dittaUMAAziendaVO.getProvCompetenza());

  boolean isThisProv = ruoloUtenza!=null&&dittaUMAAziendaVO!=null&&

                           ruoloUtenza.getIstatProvincia().equalsIgnoreCase(dittaUMAAziendaVO.getProvUMA());



  int totale = 0;

  if(dittaUMAAziendaVO.getProvUMA()!=null&&!dittaUMAAziendaVO.getProvUMA().equals(""))

    provCompetenza = client.getProvinciaByIstat(dittaUMAAziendaVO.getProvUMA());

  // Settaggio dei dati comuni

  if(dittaUMAAziendaVO.getCuaa()!=null &&!dittaUMAAziendaVO.getCuaa().equals("")){

   htmpl.set("CUAA", dittaUMAAziendaVO.getCuaa()+" - ");

  }

  htmpl.set("provinciaUMA",provCompetenza);

  HtmplUtil.setValues(htmpl,dittaUMAAziendaVO);

  // Caricamento combo domandaAssegnazione

  DomandaAssegnazione daVO = null;

  Iterator iter = v_domass.iterator();

  while(iter.hasNext()){

    daVO = (DomandaAssegnazione)iter.next();

    htmpl.newBlock("blkOptionDomAss");

    htmpl.set("blkOptionDomAss.idDomAss", daVO.getIdDomandaAssegnazione().toString());

    htmpl.set("blkOptionDomAss.anno", String.valueOf(DateUtils.extractYearFromDate(daVO.getDataRiferimento())));

    htmpl.set("blkOptionDomAss.giorno", String.valueOf(DateUtils.extractDayFromDate(daVO.getDataRiferimento())));

    htmpl.set("blkOptionDomAss.mese", String.valueOf(DateUtils.extractMonthFromDate(daVO.getDataRiferimento())));

    htmpl.set("blkOptionDomAss.stato", daVO.getStrStatoDomanda());

    //SolmrLogger.debug(this, "Compare id Dom Ass .... "+idDomAss+" - "+daVO.getIdDomandaAssegnazione());

    if(daVO.getIdDomandaAssegnazione().equals(idDomAss)){

      //SolmrLogger.debug(this, "daVO.getIdStatoDomanda() "+daVO.getIdStatoDomanda());

      idStatoDomanda = daVO.getIdStatoDomanda();

      htmpl.set("idStatoDomanda", idStatoDomanda.toString());

      htmpl.set("blkOptionDomAss.selected", "selected");

    }

  }

  //SolmrLogger.debug(this, "Valore di v_buoni??? "+v_buoni);

  //SolmrLogger.debug(this, "Valore di idStatoDomanda???? "+idStatoDomanda);



  domAssToCompare = (DomandaAssegnazione)v_domass.elementAt(0);

  htmpl.set("primoIdDomAss", domAssToCompare.getIdDomandaAssegnazione().toString());



  SolmrLogger.debug(this, "\n\n\n\n\n*+*+*+*+*+*+*+*+*+*+*+*");

  if(v_buoni!= null&& v_buoni.size()!=0){

    // INIZIO CONTROLLI (Architettura alberata dal prode Romanello....)

    //SolmrLogger.debug(this, "Compare idDomAss "+idDomAss+" - "+domAssToCompare.getIdDomandaAssegnazione());

    if(idDomAss.equals(domAssToCompare.getIdDomandaAssegnazione())&&

       (idStatoDomanda.equals(SolmrConstants.ID_STATO_DOMANDA_BOZZA)||

       idStatoDomanda.equals(SolmrConstants.ID_STATO_DOMANDA_ATTESA_VAL_PA)||

       idStatoDomanda.equals(SolmrConstants.ID_STATO_DOMANDA_RESPINTA))){

      //SolmrLogger.debug(this, "Entro qua");

      // Disabilita tutte le funzioni

      htmpl.set("msg", ""+UmaErrors.get("DOMASS_NON_COMPLETATA_BUONO_PRELIEVO"));

    }

    else{

      // INIZIA VISUALIZZA ELENCO BUONI

      //SolmrLogger.debug(this, "Entro qua 1");

      Iterator i_buoni = v_buoni.iterator();

      while(i_buoni.hasNext()){

        buonoVO = (BuonoPrelievoVO)i_buoni.next();

        totale+= buonoVO.getQtaConcessa().intValue();

      }

      //SolmrLogger.debug(this, "TOTALE QTA CONCESSA: "+totale+" LITRI");

      SolmrLogger.debug(this, "\n\n\n*****************");

      SolmrLogger.debug(this, "totale: "+totale);

      if(totale >=0){

        SolmrLogger.debug(this, "if(totale >=0)");

        //SolmrLogger.debug(this, "Entro qua 2");

        // Visualizzo Buoni Prelievo

  //htmpl.newBlock("blkMenuBuoni.blkVISUALIZZA_BUONO.blkDettaglio1");

  htmpl.newBlock("blkPrelievo");

        i_buoni = v_buoni.iterator();

        int cont = 0;

        //String idBuonoPrelievo = request.getParameter("idBuonoPrelievo");

        while(i_buoni.hasNext()){

          SolmrLogger.debug(this, "while(i_buoni.hasNext())");

          htmpl.newBlock("blkPrelievo.blkRigaPrelievo");

          buonoVO = (BuonoPrelievoVO)i_buoni.next();



          htmpl.set("blkPrelievo.blkRigaPrelievo.idBuono", buonoVO.getIdBuonoPrelievo().toString());

          htmpl.set("blkPrelievo.blkRigaPrelievo.blocco", buonoVO.getNumeroBlocco().toString());

          htmpl.set("blkPrelievo.blkRigaPrelievo.buono", buonoVO.getNumeroBuono().toString());

          htmpl.set("blkPrelievo.blkRigaPrelievo.dataEmissione", DateUtils.formatDate(buonoVO.getDataEmissione()));

          htmpl.set("blkPrelievo.blkRigaPrelievo.qtaConcessa", buonoVO.getQtaConcessa().toString());

          htmpl.set("blkPrelievo.blkRigaPrelievo.qtaPrelevata", buonoVO.getQtaPrelevata().toString());

          if(buonoVO.getDataRestituzione()!=null)

            htmpl.set("blkPrelievo.blkRigaPrelievo.dataRestituzione", DateUtils.formatDate(buonoVO.getDataRestituzione()));

          if(buonoVO.getIdConduzione()!=null){
            htmpl.set("blkPrelievo.blkRigaPrelievo.tipoUtilizzo", buonoVO.getIdConduzione().longValue() == 1L ? "Conto proprio" : "Conto terzi");
          }else{
            htmpl.set("blkPrelievo.blkRigaPrelievo.tipoUtilizzo", "Serra");
          }

          if(buonoVO.getExtProvinciaProvenienza()!=null)

            htmpl.set("blkPrelievo.blkRigaPrelievo.prov", buonoVO.getExtProvinciaProvenienza());

          if(buonoVO.getIdDittaUma()!=null&&!buonoVO.getIdDittaUma().equals(new Long("0")))

            htmpl.set("blkPrelievo.blkRigaPrelievo.dittaUma", buonoVO.getIdDittaUma().toString());

          if(buonoVO.getAnnullato()!=null && buonoVO.getAnnullato().equals(SolmrConstants.FLAG_SI))

            htmpl.set("blkPrelievo.blkRigaPrelievo.annullato", SolmrConstants.ANNULLATO);

          //04/03/23 - Problema selezione buono - Begin

          //if (buonoVO.getIdBuonoPrelievo().toString().equals(idBuonoPrelievo))

          SolmrLogger.debug(this, "cont: "+cont);

          //if(idBuonoPrelievoSelected!=null){

            if(cont==0)

            {

              //idBuonoPrelievo = "" + buonoVO.getIdBuonoPrelievo();

              htmpl.set("blkPrelievo.blkRigaPrelievo.checked", "checked");

              if(idBuonoPrelievo!=null){

                htmpl.bset("primoIdBuonoPrelievo", idBuonoPrelievo);

              }

            }

          /*}

          else{

            if(buonoVO.getIdBuonoPrelievo().toString().equals(idBuonoPrelievoSelected)){

              htmpl.set("blkPrelievo.blkRigaPrelievo.checked", "checked");

              htmpl.bset("primoIdBuonoPrelievo", idBuonoPrelievoSelected);

            }

          }*/

          //04/03/23 - Problema selezione buono - End

          cont++;

        }

      }

      else if(totale <0){

        SolmrLogger.debug(this, "if(totale <0)");

        //SolmrLogger.debug(this, "Entro qua 3a");

        // Visualizzo Buoni Restituzione

        //@@//htmpl.newBlock("blkRestituzione");

  //htmpl.newBlock("blkMenuBuoni.blkVISUALIZZA_BUONO.blkDettaglio2");

        i_buoni = v_buoni.iterator();

        int conta = 0;

        while(i_buoni.hasNext()){

          //@@//htmpl.newBlock("blkRigaRestituzione");

          buonoVO = (BuonoPrelievoVO)i_buoni.next();

          //04/03/23 - Problema selezione buono - Begin

          //if (buonoVO.getIdBuonoPrelievo().toString().equals(idBuonoPrelievo))

          SolmrLogger.debug(this, "conta: "+conta);

          //if(idBuonoPrelievoSelected!=null){

            if(conta==0)

            {

              //idBuonoPrelievo = "" + buonoVO.getIdBuonoPrelievo();

              //htmpl.set("blkPrelievo.blkRigaPrelievo.checked", "checked");

              htmpl.set("blkRestituzione.blkRigaRestituzione.checked", "checked");

              if(idBuonoPrelievo!=null){

                htmpl.bset("primoIdBuonoPrelievo", idBuonoPrelievo);

              }

            }

          /*}

          else{

            if(buonoVO.getIdBuonoPrelievo().toString().equals(idBuonoPrelievoSelected)){

              htmpl.set("blkPrelievo.blkRigaPrelievo.checked", "checked");

              htmpl.bset("primoIdBuonoPrelievo", idBuonoPrelievoSelected);

            }

          }*/

          /*if(conta==0)

          {

            htmpl.set("blkRestituzione.blkRigaRestituzione.checked","checked");

            //htmpl.bset("primoIdBuonoPrelievo", buonoVO.getIdBuonoPrelievo().toString());

          }*/

          //04/03/23 - Problema selezione buono - End

          conta++;

          htmpl.set("blkRestituzione.blkRigaRestituzione.idBuono", buonoVO.getIdBuonoPrelievo().toString());

          htmpl.set("blkRestituzione.blkRigaRestituzione.blocco", buonoVO.getNumeroBlocco().toString());

          htmpl.set("blkRestituzione.blkRigaRestituzione.buono", buonoVO.getNumeroBuono().toString());

          htmpl.set("blkRestituzione.blkRigaRestituzione.dataEmissione", DateUtils.formatDate(buonoVO.getDataEmissione()));

          htmpl.set("blkRestituzione.blkRigaRestituzione.qtaRestituita", buonoVO.getQtaConcessa().toString());

          htmpl.set("blkRestituzione.blkRigaRestituzione.prov", buonoVO.getExtProvinciaProvenienza());

          htmpl.set("blkRestituzione.blkRigaRestituzione.dittaUma", buonoVO.getIdDittaUma().toString());

          if(buonoVO.getAnnullato()!=null && buonoVO.getAnnullato().equals(SolmrConstants.FLAG_SI ))

            htmpl.set("blkRestituzione.blkRigaRestituzione.annullato", SolmrConstants.ANNULLATO);

        }

      }

      // FINE VISUALIZZA ELENCO BUONI

    }

    if(totale>0){

      //SolmrLogger.debug(this, "Entro qua 2b");

      if(idDomAss.equals(domAssToCompare.getIdDomandaAssegnazione())){

        //SolmrLogger.debug(this, "Entro qua 3");

        //SolmrLogger.debug(this, "Vediamo quanto vale id stato domanda... "+idStatoDomanda+" - "+SolmrConstants.ID_STATO_DOMANDA_VALIDATA);

        if(idStatoDomanda.toString().equals(SolmrConstants.ID_STATO_DOMANDA_VALIDATA)){

          ///SolmrLogger.debug(this, "Entro qua 4");

    //if (pu.isUtenteProvinciale()) htmpl.newBlock("blk101");

          //if (isThisProvComp) htmpl.newBlock("blk101");
          //@@//if (isThisProv) htmpl.newBlock("blk101");

          /*//@@//if(isOnThisProvRW){

            //SolmrLogger.debug(this, "Entro qua 5");

            // Abilita tutte le funzioni

            htmpl.newBlock("blkAnnulla");

            htmpl.newBlock("blkRestituisci");

            htmpl.newBlock("blkCancella");

          }

          else if(pu.isIntermediario()&&pu.isReadWriteOnUma()){

            //SolmrLogger.debug(this, "Entro qua 6");

            // Abilito solo "Restituzione Buono" e "Cancella restituzione buono"

            htmpl.newBlock("blkRestituisci");

            htmpl.newBlock("blkCancella");

          }*/

        }

        else if(idStatoDomanda.toString().equals(SolmrConstants.ID_STATO_DOMANDA_ANNULLATA)){

          //SolmrLogger.debug(this, "Entro qua 7");

          htmpl.set("exc", ""+UmaErrors.get("DOMASS_ANNULLATA_BUONO_PRELIEVO"));

          // Disabilito tutte le funzioni

        }

      }

      /*//@@//else{

        try {

          client.existNextDomAss(idDomAss, dittaUMAAziendaVO.getIdDittaUMA());

          // 24/03/04 - Errore Attivazione pulsanti Restituisci, Cancella restituzione Buono - Begin

          if (isOnThisProvRW || (pu.isIntermediario()&&pu.isReadWriteOnUma())) {

          //if (isOnThisProvRW) {

      htmpl.newBlock("blkRestituisci");

      htmpl.newBlock("blkCancella");

          }

          // 24/03/04 - Errore Attivazione pulsanti Restituisci, Cancella restituzione Buono - End

        }

        catch (Exception ex) {

          SolmrLogger.debug(this, "Esistono Domande Assegnazione successive con stato = VALIDATA o = "+

                             "IN ATTESA DI VALIDAZIONE PA");

        }

      }*/

      // FINE CONTROLLI

    }

    // AGGIUNTO il 12/01/2004 perché bisogna permettere la stampa del buono di restituzione carburante

    // relativo all'ultima domanda di assegnazione

    /*//@@//else if(totale <0)

    {

      if(idDomAss.equals(domAssToCompare.getIdDomandaAssegnazione()))

        if(idStatoDomanda.toString().equals(SolmrConstants.ID_STATO_DOMANDA_VALIDATA))

          if(pu.isUtenteProvinciale())

            if (isThisProvComp) htmpl.newBlock("blk101");

    }*/

  }

  /*SolmrLogger.debug(this, "Controllo per il link emissione.... "+domAssToCompare.getIdStatoDomanda()+" "

                       +SolmrConstants.ID_STATO_DOMANDA_VALIDATA);

  SolmrLogger.debug(this, "Valori di domAss "+idDomAss+" - "+domAssToCompare);*/

  htmpl.set("totale", ""+totale);

  /*//@@//if(totale>=0){

    if(idDomAss!=null){

      if(idDomAss.equals(domAssToCompare.getIdDomandaAssegnazione())){

        if(domAssToCompare.getIdStatoDomanda().toString().equals(SolmrConstants.ID_STATO_DOMANDA_VALIDATA)&&

           isOnThisProvRW){

          //SolmrLogger.debug(this, "Entro in emissione");

          htmpl.newBlock("blkEmissione");

        }

      }

    }

    else{

      if(domAssToCompare.getIdStatoDomanda().toString().equals(SolmrConstants.ID_STATO_DOMANDA_VALIDATA)&&

         isOnThisProvRW){

        //SolmrLogger.debug(this, "Entro in emissione");

        htmpl.newBlock("blkEmissione");

      }

    }

  }*/

  if(request.getAttribute("msg")!=null)

    htmpl.set("msg", (String)request.getAttribute("msg"));

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  HtmplUtil.setErrors(htmpl, errors, request);



  if (request.getParameter("fwdUrl")!=null)

    htmpl.set("mod101open","mod101();");



  SolmrLogger.debug(this, "buoniPrelievoView.jsp - End");

%>

<%= htmpl.text()%>