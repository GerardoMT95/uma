<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>

<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.etc.anag.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.anag.services.DelegaAnagrafeVO" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.papua.papuaserv.presentation.ws.profilazione.axis.UtenteAbilitazioni" %>

<%!
  private static final String ricercaURL = "/anag/view/ricercaAziendaUMAView.jsp";
  private static final String HOME_RAPP_LEGALE = "../layout/elencoAziendeRapLegale.htm";
%>

<%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  UtenteAbilitazioni utenteAbilitazioni = (UtenteAbilitazioni) session.getAttribute("utenteAbilitazioni");
  session.removeAttribute("dittaUMAAziendaVO");
  String iridePageName = "ricercaAziendaUMACtrl.jsp";
%>
  <%@include file = "/include/autorizzazione.inc" %>
<%

//<jsp:useBean id="dittaAziendaVO" scope="request" class="it.csi.solmr.dto.uma.DittaUMAAziendaVO">
//  <jsp:setProperty name="dittaAziendaVO" property="*" />
//</jsp:useBean>
  //dittaAziendaVO.setTipiDitta(request.getParameter("TipiDitta"));


  session.removeAttribute("annoCampagna");
  DittaUMAAziendaVO dittaAziendaVO = new DittaUMAAziendaVO();

  if(dittaAziendaVO.getDittaUMAstr()!=null && !dittaAziendaVO.getDittaUMAstr().equals(""))
    dittaAziendaVO.setDittaUMA(new Long(dittaAziendaVO.getDittaUMAstr()));



  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  DittaUMAAziendaVO dittaUMAAziendaVO = null;
  Vector vectIdAziendaDitta = null;
  int numBlock = 1;
  int sizeResult = 0;



  String url = "/anag/view/ricercaAziendaUMAView.jsp";
  String errorPage = "/anag/view/ricercaAziendaUMAView.jsp";
  String ricPuntualeURL = "/anag/view/dettaglioAziendaView.jsp";
  String ricAvanzataURL = "/anag/view/elencoAziendeView.jsp";
  ValidationException valEx = null;
  Validator validator = null;



  if(request.getParameter("ricercaPuntuale") != null) 
  {
    //Eliminazione dalla sessione dei valori della Ditta Uma
    session.removeAttribute("currPage");
    session.removeAttribute("rangeAziendaDitta");
    session.removeAttribute("vectIdAziendaDitta");
    session.removeAttribute("dittaUMAAziendaVO");
    session.removeAttribute("personaVO");
    session.removeAttribute("soggetti");

    String dittaUMAstr = request.getParameter("dittaUMAstr");
    if(Validator.isNotEmpty(dittaUMAstr))
    {
      dittaUMAstr = dittaUMAstr.trim();
    }
    String provUMA = request.getParameter("provUMA");
    dittaAziendaVO.setDittaUMAstr(dittaUMAstr);
    dittaAziendaVO.setProvUMA(provUMA);
    dittaAziendaVO.setCuaa(null);
    dittaAziendaVO.setPartitaIVA(null);
    dittaAziendaVO.setDenominazione(null);
    dittaAziendaVO.setSedelegComune(null);

    dittaAziendaVO.setTipiStatoDomanda(null);
    dittaAziendaVO.setTipiIntermediarioUmaProv(null);
    dittaAziendaVO.setProvUMADomAss(null);
    
    ValidationErrors errors = dittaAziendaVO.validatePuntuale();
    if (! (errors == null || errors.size() == 0)) 
    {
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(errorPage).forward(request, response);
      return;
    }



    try 
    {
      dittaUMAAziendaVO = umaFacadeClient.getDittaUMAAzienda(dittaAziendaVO);
      if(dittaUMAAziendaVO!=null && dittaUMAAziendaVO.getIdAnagAzienda()!=null)
      {
        session.setAttribute("dittaUMAAziendaVO",dittaUMAAziendaVO);
        iridePageName = "dettaglioAziendaControl.jsp";
        %>
          <%@include file = "/include/autorizzazione.inc" %>
        <%
        url = ricPuntualeURL;
      }
      else
        throw new SolmrException("Nessun risultato trovato");
    }

    catch (SolmrException sex) 
    {
      ValidationError error = new ValidationError(sex.getMessage());
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(errorPage).forward(request, response);
      return;
    }
  }
  else if(request.getParameter("ricercaAvanzata") != null) 
  {
    session.removeAttribute("currPage");
    session.removeAttribute("rangeAziendaDitta");
    session.removeAttribute("vectIdAziendaDitta");
    session.removeAttribute("dittaUMAAziendaVO");
    session.removeAttribute("personaVO");
    session.removeAttribute("soggetti");

    String cuaa = request.getParameter("cuaa");
    if(Validator.isNotEmpty(cuaa))
    {
      cuaa = cuaa.trim();
    }
    String partitaIVA = request.getParameter("partitaIVA");
    if(Validator.isNotEmpty(partitaIVA))
    {
      partitaIVA = partitaIVA.trim();
    }
    String denominazione = request.getParameter("denominazione");
    if(Validator.isNotEmpty(denominazione))
    {
      denominazione = denominazione.trim();
    }
    String provincia = request.getParameter("sedelegProvincia");
    String comune = request.getParameter("descComune");
    String sedelegEstero = request.getParameter("sedelegEstero");
    String cap = request.getParameter("cap");
    String istatComune = request.getParameter("istatComune");
    dittaAziendaVO.setDittaUMAstr(null);
    dittaAziendaVO.setProvUMA(null);

    dittaAziendaVO.setTipiStatoDomanda(null);
    dittaAziendaVO.setTipiIntermediarioUmaProv(null);
    dittaAziendaVO.setProvUMADomAss(null);
    dittaAziendaVO.setCuaa(cuaa);
    dittaAziendaVO.setPartitaIVA(partitaIVA);
    dittaAziendaVO.setDenominazione(denominazione);
    dittaAziendaVO.setSedelegProvincia(provincia);
    dittaAziendaVO.setSedelegComune(comune);
    dittaAziendaVO.setSedelegEstero(sedelegEstero);
    ValidationErrors errors = dittaAziendaVO.validateAvanzata();

    if (! (errors == null || errors.size() == 0)) 
    {
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(errorPage).forward(request, response);
      return;
    }

    if(comune == null || comune.equals("")) 
    {
      dittaAziendaVO.setSedelegComune(sedelegEstero);
    }



    try 
    {
      boolean attivita = true;
      if(request.getParameter("attivita")==null) 
      {
        attivita = false;
      }

      session.setAttribute("attivita",String.valueOf(attivita));
      vectIdAziendaDitta = umaFacadeClient.getListIdAziendeDitte(dittaAziendaVO, attivita);
      sizeResult=vectIdAziendaDitta.size();
      if(sizeResult==0)
      {
        throw new SolmrException("Nessun risultato trovato");
      }
      else
      {
        session.removeAttribute("attivita");
        session.setAttribute("vectIdAziendaDitta",vectIdAziendaDitta);
        Vector rangeIdAziendaDitta = new Vector();
        int limiteA;
        if(sizeResult<SolmrConstants.NUM_MAX_ROWS_PAG)
          limiteA=sizeResult;
        else
          limiteA=SolmrConstants.NUM_MAX_ROWS_PAG;
        for(int i=(numBlock-1)*SolmrConstants.NUM_MAX_ROWS_PAG;i<limiteA;i++)
        {
          rangeIdAziendaDitta.addElement(vectIdAziendaDitta.elementAt(i));
        }

        Vector rangeAziendaDitta = umaFacadeClient.getListAziendeDitteByRange(rangeIdAziendaDitta);
        session.setAttribute("rangeAziendaDitta",rangeAziendaDitta);
        url = ricAvanzataURL;
      }
    }
    catch (SolmrException sex) 
    {
      ValidationError error = new ValidationError(sex.getMessage());
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(errorPage).forward(request, response);
      return;
    }
  }
  else if(request.getParameter("ricercaDomAss") != null) 
  {
	SolmrLogger.debug(this, "-- Ricerca per domanda di assegnazione --");  
    session.removeAttribute("currPage");
    session.removeAttribute("rangeAziendaDitta");
    session.removeAttribute("vectIdAziendaDitta");
    session.removeAttribute("dittaUMAAziendaVO");
    session.removeAttribute("personaVO");
    session.removeAttribute("soggetti");

    String tipiStatoDomanda = request.getParameter("tipiStatoDomanda");
    //String tipiIntermediarioUmaProv = request.getParameter("tipiIntermediarioUmaProv");
    String tipiIntermediarioUmaProv;
    if(ruoloUtenza.isUtenteIntermediario())
    {
      tipiIntermediarioUmaProv =  new Long(utenteAbilitazioni.getEnteAppartenenza().getIntermediario().getIdIntermediario()).toString(); // (String)request.getAttribute("intermediario");
    }
    else
      tipiIntermediarioUmaProv = request.getParameter("intermUmaProv");
    
    SolmrLogger.debug(this, "tipiIntermediarioUmaProv ="+tipiIntermediarioUmaProv);

    String idUfficioUma = request.getParameter("uffUMADomAss");
    SolmrLogger.debug(this, "-- idUfficioUma selezionato ="+idUfficioUma);
    
    String provUMADomAss = request.getParameter("provUMADomAss");
    SolmrLogger.debug(this, "-- provUMADomAss selezionato ="+provUMADomAss);
    
    String statoLibrettoDomAss = request.getParameter("statoLibrettoDomAss");
    SolmrLogger.debug(this, "-- statoLibrettoDomAss selezionato ="+statoLibrettoDomAss);
    
    dittaAziendaVO.setDittaUMAstr(null);
    dittaAziendaVO.setProvUMA(null);
    dittaAziendaVO.setCuaa(null);
    dittaAziendaVO.setPartitaIVA(null);
    dittaAziendaVO.setDenominazione(null);
    dittaAziendaVO.setSedelegProvincia(null);
    dittaAziendaVO.setSedelegComune(null);

    SolmrLogger.debug(this, "-- tipiStatoDomanda selezionato ="+tipiStatoDomanda);
    dittaAziendaVO.setTipiStatoDomanda(tipiStatoDomanda);
    dittaAziendaVO.setTipiIntermediarioUmaProv(tipiIntermediarioUmaProv);
    dittaAziendaVO.setUfficioUma(idUfficioUma);
    dittaAziendaVO.setProvUMADomAss(provUMADomAss);
    dittaAziendaVO.setStatoLibretto(statoLibrettoDomAss);
    dittaAziendaVO.setDataRifDa(request.getParameter("dataRifDa"));
    dittaAziendaVO.setDataRifA(request.getParameter("dataRifA"));

    ValidationErrors errors = dittaAziendaVO.validateDomAss();

    if (! (errors == null || errors.size() == 0)) 
    {
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(errorPage).forward(request, response);
      return;
    }

    try 
    {
      if(dittaAziendaVO.getDataRifDa()!=null && !dittaAziendaVO.getDataRifDa().equals(""))
        dittaAziendaVO.setDataRifDaDate(DateUtils.parseDate(dittaAziendaVO.getDataRifDa()));

      if(dittaAziendaVO.getDataRifA()!=null && !dittaAziendaVO.getDataRifA().equals(""))
        dittaAziendaVO.setDataRifADate(DateUtils.parseDate(dittaAziendaVO.getDataRifA()));
      else
        dittaAziendaVO.setDataRifADate(DateUtils.parseDate(DateUtils.getCurrent()));

      vectIdAziendaDitta = umaFacadeClient.getListIdAziendeDitteByDomAss(dittaAziendaVO, ruoloUtenza);

      sizeResult=vectIdAziendaDitta.size();
      if(sizeResult==0)
      {
        throw new SolmrException("Nessun risultato trovato");
      }
      else
      {
        session.setAttribute("vectIdAziendaDitta",vectIdAziendaDitta);
        Vector rangeIdAziendaDitta = new Vector();
        int limiteA;
        if(sizeResult<SolmrConstants.NUM_MAX_ROWS_PAG)
          limiteA=sizeResult;
        else
          limiteA=SolmrConstants.NUM_MAX_ROWS_PAG;

        for(int i=(numBlock-1)*SolmrConstants.NUM_MAX_ROWS_PAG;i<limiteA;i++)
        {
          rangeIdAziendaDitta.addElement(vectIdAziendaDitta.elementAt(i));
        }

        Vector rangeAziendaDitta = umaFacadeClient.getListAziendeDitteByRangeDomAss(rangeIdAziendaDitta);
        session.setAttribute("rangeAziendaDitta",rangeAziendaDitta);
        url = ricAvanzataURL;
      }
    }
    catch (SolmrException sex) 
    {
      ValidationError error = new ValidationError(sex.getMessage());
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(errorPage).forward(request, response);
      return;
    }
  }

  %>
  <jsp:forward page ="<%=url%>" />

 