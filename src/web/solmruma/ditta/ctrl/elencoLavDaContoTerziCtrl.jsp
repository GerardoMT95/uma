<%@ page language="java" contentType="text/html" isErrorPage="true"%>

<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@page import="it.csi.solmr.dto.profile.RuoloUtenza"%>


<%
  String referer = "LavDaContoTerzi";
  SolmrLogger.debug(this, "****** referer dentro elencoLavDaContoTerzi: "
      + request.getHeader("referer").indexOf(referer));
  String iridePageName = "elencoLavDaContoTerziCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%

  SolmrLogger.debug(this, "   BEGIN  elencoLavDaContoTerziCtrl");

  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma = dittaUMAAziendaVO.getIdDittaUMA();

  SolmrLogger.debug(this,"---- idDittaUma "+ idDittaUma);
          
  Long extIdAziendaCorrente = dittaUMAAziendaVO.getIdAzienda();
  SolmrLogger.debug(this," ----- extIdAziendaCorrente ="+extIdAziendaCorrente); 
          
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  UmaFacadeClient umaClient = new UmaFacadeClient();
  String url = "/ditta/view/elencoLavDaContoTerziView.jsp";
  String modificaUrl = "/ditta/ctrl/modificaLavDaContoTerziCtrl.jsp";
  String validateUrl = "/ditta/view/elencoLavDaContoTerziView.jsp";
  String insertUrl = "/ditta/ctrl/nuovaLavDaContoTerziCtrl.jsp";
  String deleteUrl = "/ditta/ctrl/confermaEliminaLavDaContoTerziCtrl.jsp";
  session.setAttribute("modificaDaContoTerzi", null);
  String info = (String) session.getAttribute("notifica");

  if (info != null)
  {
    findData(request, umaClient, idDittaUma, extIdAziendaCorrente, url, ruoloUtenza);
    session.removeAttribute("notifica");
    throwValidation(info, validateUrl);
  }

  SolmrLogger.debug(this,
      "[elencoLavDaContoTerziCtrl::service] *************************** idDittaUma "
          + idDittaUma);

  if (request.getParameter("inserisci.x") != null)
  {
    request.setAttribute("flagPulisciSessione", "true");
    session.setAttribute("inserimentoDaContoTerzi", "true");
%><jsp:forward page="<%=insertUrl%>" />
<%
  return;
  }
  else
  {
    if (request.getParameter("storico.x") != null)
    {
      String annoRiferimento = request.getParameter("annoRiferimento");
      SolmrLogger.debug(this, "CASO STORICO ");
      SolmrLogger
          .debug(
              this,
              "sono in elencoLavDaContoTerziCtrl CASO STORICO e annoCampagna  annoRiferimento VALE: "
                  + annoRiferimento);
      if (!StringUtils.isStringEmpty(annoRiferimento))
      {
        AnnoCampagnaVO annoCampagna = new AnnoCampagnaVO();
        annoCampagna.setAnnoCampagna(annoRiferimento);
        session.setAttribute("annoCampagna", annoCampagna);
      }

      String urlStorico = "/ditta/ctrl/elencoLavDaContoTerziBisCtrl.jsp";
%><jsp:forward page="<%=urlStorico%>" />
<%
  return;

    }
    if (request.getParameter("importa.x") != null)
    {
      //String annoRiferimento = request.getParameter("annoRiferimento");
      SolmrLogger.debug(this, "CASO IMPORTAAAAAA ");

      String urlConferma = "/ditta/ctrl/confermaImportaLavDaContoTerziCtrl.jsp";
%><jsp:forward page="<%=urlConferma%>" />
<%
  return;

    }
    else
      if (request.getParameter("ricarica.x") != null)
      {
        try
        {
          SolmrLogger.debug(this, "Sono in RICARICAAAAA ");
          String annoRiferimento = request.getParameter("annoRiferimento");
          SolmrLogger.debug(this, "annoRiferimento VALE: "
              + annoRiferimento);
          if (!StringUtils.isStringEmpty(annoRiferimento))
          {
            AnnoCampagnaVO annoCampagna = new AnnoCampagnaVO();
            annoCampagna.setAnnoCampagna(annoRiferimento);
            session.setAttribute("annoCampagna", annoCampagna);
          }
          //SolmrLogger.debug(this,"VERIFICO LE CONDIZIONI X VIS IL PULSANTE IMPORTA LAVORAZIONI...   ");
          //verificaCondizioniPulsanteImportaLav(request,umaClient);
          DittaUMAAziendaVO dittaUma = (DittaUMAAziendaVO) session
              .getAttribute("dittaUMAAziendaVO");
          if (null != dittaUma && dittaUma.getIdConduzione() != null)
          {
            SolmrLogger.debug(this,
                "[elencoLavDaContoTerziCtrl::ricarica] dittaUma.getIdDittaUMA() VALE: "
                    + dittaUma.getIdDittaUMA());
            SolmrLogger.debug(this,
                "[elencoLavDaContoTerziCtrl::ricarica] IDCONDUZIONE VALE: "
                    + dittaUma.getIdConduzione());
            if (!(dittaUma.getIdConduzione().equalsIgnoreCase("1") || dittaUma
                .getIdConduzione().equalsIgnoreCase("3")))
            {

              throw new Exception(
                  "La ditta effettua solo attivita' per conto proprio, operazione non permessa");

            }
            else
            {
              SolmrLogger.debug(this,"Sono in RICARICAAAAA PRIMA di getVettLavorazioni");
              
              // Filtri non presenti nella pagina -> forzo a Stringa vuota
              String cuaa = null;
              String partitaIva = null;
              String denominazione = null;
              Vector<Long> listIdAzienda = null;
              
              getVettLavorazioni(request, umaClient, dittaUma
                  .getIdDittaUMA(), extIdAziendaCorrente, annoRiferimento, cuaa, partitaIva, denominazione, listIdAzienda, ruoloUtenza);
              SolmrLogger.debug(this,
                  "Sono in RICARICAAAAA DOPO di getVettLavorazioni");
              SolmrLogger.debug(this,
                  "Sono in RICARICAAAAA DOPO di getVettLavorazioni url VALE: "
                      + url);
              // Visualizzazione Lav conto terzi
              //findData(request,umaClient,idDittaUma,url);
              request.removeAttribute("ricarica.x");
%><jsp:forward page="<%=url%>" />
<%
  SolmrLogger.debug(this, "QUIIIIIII");
              return;
            }
          }
          else
            if (dittaUma.getIdConduzione() == null)
              throw new Exception(
                  "La ditta effettua solo attivita' per conto proprio, operazione non permessa");
        }
        catch (Exception e)
        {
          request.setAttribute("errorMessage", e.getMessage());
          SolmrLogger.debug(this, "ERRORE... " + e.getMessage());
          //e.printStackTrace();
%><jsp:forward
	page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
<%
  return;
        }
%><!-- jsp:forward page="<%=modificaUrl%>" /-->
<%
  }
      else
        if (request.getParameter("modifica.x") != null)
        {
          try
          {
            String[] checkBoxSel = request.getParameterValues("checkbox");
            Long[] vIdLav = new Long[checkBoxSel.length];
            for (int i = 0; i < checkBoxSel.length; i++)
            {
              SolmrLogger.debug(this, "ID SELEZIONATI:::::::::::::::::: "
                  + checkBoxSel[i]);
              vIdLav[i] = new Long(checkBoxSel[i]);
            }
            Vector vLavDaContoTerzi = umaClient
                .findLavorazioneContoTerziByIdRange(vIdLav);
            HashMap hmLav = new HashMap();
            for (int i = 0; i < vLavDaContoTerzi.size(); i++)
            {
              LavContoTerziVO lavContoTerziVO = (LavContoTerziVO) vLavDaContoTerzi
                  .get(i);
              if (lavContoTerziVO.getDataFineValidita() != null
                  || lavContoTerziVO.getDataCessazione() != null)
              {
                throw new Exception(
                    "Una delle lavorazioni non è modificabile perchè si riferisce ad un dato storicizzato");
              }
              hmLav.put(lavContoTerziVO.getIdLavorazioneCT(),
                  lavContoTerziVO);
            }
            Vector vLavOrdinato = new Vector();
            for (int i = 0; i < vIdLav.length; i++)
            {
              Long id = vIdLav[i];
              vLavOrdinato.add(i, hmLav.get(id));

            }
            session.setAttribute("vLavDaContoTerzi", vLavOrdinato);
            session.setAttribute("modificaDaContoTerzi", "true");
          }
          catch (Exception e)
          {
            e.printStackTrace();
            request.setAttribute("errorMessage", e.getMessage());
%><jsp:forward
	page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
<%
  return;
          }
%><jsp:forward page="<%=modificaUrl%>" />
<%
  }
        else
        {
          if (request.getParameter("elimina.x") != null)
          {
            try
            {
              String[] checkBoxSel = request.getParameterValues("checkbox");
              Long[] vIdLav = new Long[checkBoxSel.length];
              for (int i = 0; i < checkBoxSel.length; i++)
              {
                vIdLav[i] = new Long(checkBoxSel[i]);
              }
              Vector vLavDaContoTerzi = umaClient
                  .findLavorazioneContoTerziByIdRange(vIdLav);
              for (int i = 0; i < vLavDaContoTerzi.size(); i++)
              {
                LavContoTerziVO lavContoTerziVO = (LavContoTerziVO) vLavDaContoTerzi
                    .get(i);
                if (lavContoTerziVO.getDataFineValidita() != null
                    || lavContoTerziVO.getDataCessazione() != null)
                {
                  throw new Exception(
                      "Una delle lavorazioni non è modificabile perchè si riferisce ad un dato storicizzato");
                }
              }
              session.setAttribute("vLavDaContoTerzi", vIdLav);

            }
            catch (Exception e)
            {
              SolmrLogger.debug(this, "--- Excception in elencoLavDaContoTerziCtrl ="+e.getMessage());
              request.setAttribute("errorMessage", e.getMessage());
%><jsp:forward
	page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
<%
  return;
            }
%><jsp:forward page="<%=deleteUrl%>" />
<%
  }
          else
          {
            // inizio cris
            try
            {
              SolmrLogger.debug(this, "Sono in CARICA DATII");
              SolmrLogger
                  .debug(this,
                      "[elencoLavDaContoTerziCtrl::service] CONTROLLO IDCONDIZIONE");

              if (null != dittaUMAAziendaVO
                  && dittaUMAAziendaVO.getIdConduzione() != null)
              {
                SolmrLogger.debug(this,
                    "[elencoLavDaContoTerziCtrl::service] dittaUma.getIdDittaUMA() VALE: "
                        + dittaUMAAziendaVO.getIdDittaUMA());
                SolmrLogger.debug(this,
                    "[elencoLavDaContoTerziCtrl::service] IDCONDUZIONE VALE: "
                        + dittaUMAAziendaVO.getIdConduzione());
                if (!(dittaUMAAziendaVO.getIdConduzione().equalsIgnoreCase(
                    "1") || dittaUMAAziendaVO.getIdConduzione()
                    .equalsIgnoreCase("3")))
                {
                  throw new Exception(
                      "La ditta effettua solo attività per conto terzi, operazione non permessa");

                }
                else
                {
                  // CARICO DATI
                  findData(request, umaClient, idDittaUma, extIdAziendaCorrente, url, ruoloUtenza);
                  //SolmrLogger.debug(this,"vettLavorazioni vale: "+vettLavorazioni);
                }
              }
              //SolmrLogger.debug(this,"VERIFICO LE CONDIZIONI X VIS IL PULSANTE IMPORTA LAVORAZIONI...   ");
              //verificaCondizioniPulsanteImportaLav(request,umaClient);
            }
            catch (Exception e)

            {
              request.setAttribute("errorMessage", e.getMessage());
%><jsp:forward
	page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
<%
  return;
            }
            // Visualizzazione Lav conto terzi
            findData(request, umaClient, idDittaUma, extIdAziendaCorrente, url, ruoloUtenza);
%><jsp:forward page="<%=url%>" />
<%
  }// end cris

        }
  }// end
%>

<%!private void getVettLavorazioni(HttpServletRequest request,
      UmaFacadeClient umaClient, Long idDittaUma, Long extIdAziendaDittaCorrente, String annoCampagna, String cuaa, String partitaIva, String denominazione,
      Vector<Long> listIdAzienda,
      RuoloUtenza ruoloUtenza) throws SolmrException, Exception
  {
    SolmrLogger.debug(this, "Nel metodo getVettLavorazioni BEGIN....");
    Vector vettLavorazioni = umaClient.findListaLavorazioniContoTerzi(
        idDittaUma, extIdAziendaDittaCorrente, annoCampagna, cuaa, partitaIva, denominazione, listIdAzienda, SolmrConstants.VERSO_LAVORAZIONI_S, false, null);
    HashMap hm = new HashMap();
    if (vettLavorazioni != null && vettLavorazioni.size() > 0)
    {
      for (int i = 0; i < vettLavorazioni.size(); i++)
      {
        LavContoTerziVO elem = (LavContoTerziVO) vettLavorazioni.get(i);

        if (null != elem && elem.getExtIdAzienda() != null)
        {
          SolmrLogger.debug(this, "elem.getExtIdAzienda() vale: "
              + elem.getExtIdAzienda());
          SolmrLogger.debug(this, "PRIMA DI CHIAMARE getAziendaById... ");
          AnagAziendaVO anagAziendaVO = umaClient.serviceGetAziendaById(elem
              .getExtIdAzienda(), new Date(), SianUtils.getSianVO(ruoloUtenza));
          SolmrLogger.debug(this, "DOPO CHIAMATA DI  getAziendaById... ");
          SolmrLogger.debug(this, "anagAziendaVO VALE:  " + anagAziendaVO);
          if (anagAziendaVO != null)
          {
            SolmrLogger.debug(this, "anagAziendaVO.getPartitaIVA() VALE:  "
                + anagAziendaVO.getPartitaIVA());
            SolmrLogger.debug(this, "anagAziendaVO.getDenominazione() VALE:  "
                + anagAziendaVO.getDenominazione());
            SolmrLogger.debug(this, "anagAziendaVO.getDescComune() VALE:  "
                + anagAziendaVO.getDescComune());
            SolmrLogger.debug(this, "anagAziendaVO.getSedelegProv() VALE:  "
                + anagAziendaVO.getSedelegProv());
            SolmrLogger.debug(this,
                "anagAziendaVO.getSedelegIndirizzo() VALE:  "
                    + anagAziendaVO.getSedelegIndirizzo());
            elem.setPartitaIva(anagAziendaVO.getPartitaIVA());
            elem.setCuaa(anagAziendaVO.getCUAA());
            elem.setDenominazione(anagAziendaVO.getDenominazione());
            String desc = anagAziendaVO.getDescComune();
            if (!StringUtils.isStringEmpty(anagAziendaVO.getSedelegProv()))
              desc = desc + " (" + anagAziendaVO.getSedelegProv() + ")";
            elem.setSedeLegaleAnag(desc);
            elem.setIndirizzoSedeLegale(anagAziendaVO.getSedelegIndirizzo());
          }
          else
          {
            throw new SolmrException(
                "Errore grave, se il problema persiste "
                    + "contattare l'assistenza tecnica comunicando il "
                    + "seguente messaggio: "
                    + "Dati azienda non trovati alla data inserimento dichiarazione!");
          }

        }
        hm.put(elem.getIdLavorazioneCT(), elem);
      }
    }
    SolmrLogger.debug(this, "vettLavorazioni vale: " + vettLavorazioni);
    if (vettLavorazioni != null)
      SolmrLogger.debug(this, "vettLavorazioni.size() vale: "
          + vettLavorazioni.size());

    request.getSession().setAttribute("vettLavDaContoTerzi", vettLavorazioni);
    request.getSession().setAttribute("hmDaLavorazioni", hm);
    if (null != vettLavorazioni)
      SolmrLogger.debug(this,
          "Nel metodo getVettLavorazioni vettLavorazioni.size() VALE: "
              + vettLavorazioni.size());
    SolmrLogger.debug(this, "Nel metodo getVettLavorazioni END....");
  }

  private void findData(HttpServletRequest request, UmaFacadeClient umaClient,
      Long idDittaUma, Long extIdAziendaDittaCorrente, String validateUrl, RuoloUtenza ruoloUtenza) throws ValidationException
  {
    try
    {
      SolmrLogger.debug(this,
          "[elencoLavDaContoTerziCtrl::service::::begin] \n\n\n\n\n\n\n\n\nidDittaUma="
              + idDittaUma + " \n\n\n\n\n\n\n\n\n....");
      HttpSession session = request.getSession();
      Vector vettAnniCampagna = umaClient.findAnniCampagnaByIdDittaUma(
          idDittaUma, null, SolmrConstants.VERSO_LAVORAZIONI_S);
      SolmrLogger.debug(this, "vettAnniCampagna vale: " + vettAnniCampagna);
      if (null != vettAnniCampagna && vettAnniCampagna.size() > 0)
      {
        String annoAtt = String.valueOf(UmaDateUtils.getCurrentYear());
        //String annoAttMenoUno=String.valueOf(UmaDateUtils.getCurrentYear().intValue()-1);
        boolean trov1 = false;
        //boolean trov2=false;
        for (int i = 0; i < vettAnniCampagna.size(); i++)
        {
          AnnoCampagnaVO elem = (AnnoCampagnaVO) vettAnniCampagna.get(i);
          if (elem.getAnnoCampagna().equalsIgnoreCase(annoAtt))
          {
            trov1 = true;
          }

        }
        if (!trov1)
        {
          // Aggiungo nell'elenco degli anni l'anno corrente
          AnnoCampagnaVO elem = new AnnoCampagnaVO();
          elem.setAnnoCampagna(String.valueOf(UmaDateUtils.getCurrentYear()));
          SolmrLogger.debug(this,
              " String.valueOf(DateUtils.getCurrentYear()) VALE: "
                  + String.valueOf(UmaDateUtils.getCurrentYear()));
          vettAnniCampagna.add(elem);
        }

      }
      else
      {
        SolmrLogger.debug(this, " CASO VETTANNOCAMPAGNE VUOTO...");
        AnnoCampagnaVO elem = new AnnoCampagnaVO();
        elem.setAnnoCampagna(String.valueOf(UmaDateUtils.getCurrentYear()));
        SolmrLogger.debug(this,
            " String.valueOf(DateUtils.getCurrentYear()) VALE: "
                + String.valueOf(UmaDateUtils.getCurrentYear()));
        vettAnniCampagna.add(elem);
      }
      Collections.sort(vettAnniCampagna);
      SolmrLogger.debug(this, "vettAnniCampagna.size vale: "
          + vettAnniCampagna.size());
      session.setAttribute("LavCTvettAnniCampagna", vettAnniCampagna);

      // Carico la griglia delle lavorazioni

      AnnoCampagnaVO annoCampagna = (AnnoCampagnaVO) session
          .getAttribute("annoCampagna");
      if (annoCampagna != null)
      {
        SolmrLogger.debug(this, "ANNOCAMPAGNA IN SESSION VALE: "
            + annoCampagna.getAnnoCampagna());

      }
      else
      {
        SolmrLogger.debug(this, "ANNOCAMPAGNA IN SESSION E' NULL");
        annoCampagna = new AnnoCampagnaVO();
        annoCampagna.setAnnoCampagna(String.valueOf(UmaDateUtils
            .getCurrentYear()));

      }
      session.setAttribute("annoCampagna", annoCampagna);
      
      // Filtri non presenti nella pagina -> forzo a Stringa vuota
      String cuaa = null;
      String partitaIva = null;
      String denominazione = null;
      Vector<Long> listIdAzienda = null;

      getVettLavorazioni(request, umaClient, idDittaUma, extIdAziendaDittaCorrente, annoCampagna.getAnnoCampagna(), cuaa, partitaIva, denominazione, listIdAzienda, ruoloUtenza);
      SolmrLogger.debug(this, "[elencoLavDaContoTerziCtrl::findData:::::end]");
    }
    catch (Exception e)
    {
      throwValidation(e.getMessage(), validateUrl);
    }
  }

  private void throwValidation(String msg, String validateUrl)
      throws ValidationException
  {
    ValidationException valEx = new ValidationException(msg, validateUrl);
    valEx.addMessage(msg, "exception");
    throw valEx;
  }%>
