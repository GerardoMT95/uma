 <%@ page language="java"
     contentType="text/html"
     isErrorPage="true"
 %>

<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.etc.anag.*" %>
<%@ page import="it.csi.solmr.dto.uma.DittaUMAVO" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String iridePageName = "nuovaDittaUmaAnagraficaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%




  String url = "/ditta/view/nuovaDittaUmaAnagraficaView.jsp";

  String avantiUrl = "/ditta/view/nuovaDittaUmaDatiIdentificativiView.jsp";



  session.removeAttribute("dittaUMAAziendaVO");

  AnagFacadeClient anagFacadeClient = new AnagFacadeClient();

  AnagAziendaVO anagAziendaVO = null;

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


  UmaFacadeClient umaClient = new UmaFacadeClient();

  String siglaProvincia="";

  try
  {
    Vector province=umaClient.getProvincieByRegione(it.csi.solmr.etc.SolmrConstants.ID_REGIONE);
    if (province!=null)
    {
      int size=province==null?0:province.size();
      for(int i=0;i<size;i++)
      {
        ProvinciaVO provinciaVO=(ProvinciaVO)province.get(i);
        if (provinciaVO.getIstatProvincia().equals(ruoloUtenza.getIstatProvincia()))
        {
          siglaProvincia=provinciaVO.getSiglaProvincia();
          request.setAttribute("siglaProvincia",siglaProvincia);
          i=size; // Esco dal ciclo
        }
      }
    }
  }
  catch (SolmrException e)
  {
    ValidationErrors errors = new ValidationErrors();

    ValidationError error = new ValidationError(e.getMessage());

    request.setAttribute("errors", errors);

    request.getRequestDispatcher(url).forward(request, response);

    return;
  }


  if(request.getParameter("avanti") != null) {



    ValidationErrors errors = new ValidationErrors();

/*    if (!profile.isUtenteProvinciale())
    {
      ValidationError error = new ValidationError((String)
          it.csi.solmr.etc.SolmrConstants.get("UTENTE_NON_AUTORIZZATO"));

      errors.add("error",error);

      request.setAttribute("errors", errors);

      request.getRequestDispatcher(url).forward(request, response);
      return;
    }*/



    if(!ruoloUtenza.isReadWrite()) {

      ValidationError error = new ValidationError(""+AnagErrors.get("ERR_UTENTE_NON_ABILITATO"));

      errors.add("error",error);

      request.setAttribute("errors", errors);

      request.getRequestDispatcher(url).forward(request, response);

      return;

    }



    String cuaa = request.getParameter("CUAA");

    String partitaIva = request.getParameter("partitaIVA");

    // Per effettuare la ricerca l'utente deve inserire o il cuaa o la partita iva

    if(Validator.isNotEmpty(cuaa) && Validator.isNotEmpty(partitaIva)) {

      ValidationError error = new ValidationError(""+UmaErrors.get("ERR_CUAA_PARTITA_IVA_NO_TOGETHER"));

      errors.add("CUAA",error);

      errors.add("partitaIVA",error);

      request.setAttribute("errors", errors);

      request.getRequestDispatcher(url).forward(request, response);

      return;

    }

    if((cuaa == null  || cuaa.equals("")) && (partitaIva == null || partitaIva.equals(""))) {

      if(cuaa == null || cuaa.equals("")) {

        ValidationError error = new ValidationError(""+UmaErrors.get("ERR_CUAA_PARTITA_IVA_OBBLIGATORI"));

        errors.add("CUAA",error);

      }

      if(partitaIva == null || partitaIva.equals("")){

        ValidationError error = new ValidationError(""+UmaErrors.get("ERR_CUAA_PARTITA_IVA_OBBLIGATORI"));

        errors.add("partitaIVA",error);

      }
    }

    String dittaUmaStr=request.getParameter("dittaUma");
    DittaUMAVO duVO=null;
    if (Validator.isNotEmpty(dittaUmaStr))
    {
      dittaUmaStr=dittaUmaStr.trim();
      Long dittaUma=null;
      try
      {
        dittaUma=new Long(dittaUmaStr);

      }
      catch(Exception e)
      {
        e.printStackTrace();
        ValidationError error = new ValidationError(""+UmaErrors.get("NUMERO_DITTA_NOT_VALID"));
        errors.add("dittaUma",error);
        duVO=null;
      }
      if (dittaUma!=null) // Controllo precedente andato a buon fine
      {
        duVO=new DittaUMAVO();
        duVO.setDittaUMA(dittaUmaStr);
        duVO.setExtProvinciaUMA(siglaProvincia);
        try
        {
          Vector ditte=umaClient.findDittaByVO(duVO);
          if (ditte==null || ditte.size()!=1) // Se ne trovo può essercene solo 1
          // se non ne trovo dovrebbe essere lanciata l'eccezione
          {
            ValidationError error = new ValidationError((String)UmaErrors.get("DITTA_PROVENIENZA_INESISTENTE"));
            errors.add("dittaUma",error);
            duVO=null;
          }
          else
          {
            duVO=(DittaUMAVO)ditte.get(0);
            if (duVO.getDataCessazione()==null) // Se non è cessata ==> errore
            {
              ValidationError error = new ValidationError((String)UmaErrors.get("DITTA_PROVENIENZA_ANCORA_ATTIVA"));
              errors.add("dittaUma",error);
              duVO=null;
            }
          }
        }
        catch(Exception e)
        {
          ValidationError error = new ValidationError((String)UmaErrors.get("DITTA_PROVENIENZA_INESISTENTE"));
          errors.add("dittaUma",error);
        }
        try
        {
          if (duVO!=null)
          {
            if (!umaClient.isDittaUmaProvenienzaDisponibile(duVO.getIdDitta()))
            {
              ValidationError error = new ValidationError((String)UmaErrors.get("DITTA_PROVENIENZA_NON_DISPONIBILE"));
              errors.add("dittaUma",error);
              /**            Impossibile proseguire in quanto la ditta uma di provenienza risulta*/
            }
          }
        }
        catch(Exception e)
        {
          SolmrLogger.error(this, "--- Exception in nuovaDittaUmaAnagraficaCtrl ="+e.getMessage());	
          ValidationError error = new ValidationError((String)it.csi.solmr.etc.SolmrErrors.GENERIC_SYSTEM_EXCEPTION);
          errors.add("error",error);
        }
      }
    }

    if(errors.size() != 0) {

      request.setAttribute("errors", errors);

      request.getRequestDispatcher(url).forward(request, response);

      return;

    }

    // Per il criterio di ricerca impostato dall'utente deve esistere un'azienda agricola attiva

    try {

      anagAziendaVO = anagFacadeClient.findAziendaAttivabyCriterio(cuaa, partitaIva);
      if (anagAziendaVO==null)
      {
        // Workaround: una volta findAziendaAttivaByCriterio se non trovava
        // l'azienda generava una eccezione, ora risponde null ==>
        // Rilancio una eccezione e lascio che il codice del catch faccia il
        // suo dovere (il messaggio della SolmrException non è significativo in
        // quanto viene sovrascritto nel catch)
        throw new SolmrException("Azienda non trovata");
      }
      if (anagAziendaVO.isFlagAziendaProvvisoria())
      {
        ValidationError error = new ValidationError(UmaErrors.ERR_NUOVA_DITTA_SU_AZIENDA_PROVVISORIA);
        if (Validator.isNotEmpty(cuaa))
        {
          errors.add("CUAA", error);
        }
        if (Validator.isNotEmpty(partitaIva))
        {
          errors.add("partitaIVA", error);
        }
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(url).forward(request, response);
        return;
      }
/*
## 01/02/2006 NUOVA
      //051213 - Controllo delega intermediario - Begin
      if (profile.isIntermediario()) {
        SolmrLogger.debug(this, "\n\n\n\n\n\n\n###@@###@@###@@###@@###@@###@@###@@\n\n\n\n\n");
        Date dataInizioGestioneFascicolo = (Date)session.getAttribute("dataInizioGestioneFascicolo");
        if (dataInizioGestioneFascicolo!=null) // Se è null ==> sessione scaduta ==> evito la NullPointerException
        {
          SolmrLogger.debug(this, "dataInizioGestioneFascicolo: "+dataInizioGestioneFascicolo);
          String currentDate = DateUtils.getCurrentDateString();
          SolmrLogger.debug(this, "currentDate: "+currentDate);
          Date toDay = new Date();

          if (toDay.after(dataInizioGestioneFascicolo))
          {
            SolmrLogger.debug(this, "if (toDay.after(dataInizioGestioneFascicolo))");

            SolmrLogger.debug(this, "anagAziendaVO.getIdAzienda(): "+anagAziendaVO.getIdAzienda());

            IntermediarioVO intermediarioVO = umaClient.getIntermediarioByIdUtenteIride(profile.getIdUtente());

            Boolean ricercaSuFigli = new Boolean(true);

            it.csi.solmr.dto.anag.services.DelegaAnagrafeVO delegaAnagrafeVO = umaClient.serviceGetDelega(anagAziendaVO.getIdAzienda(), intermediarioVO.getCodiceFiscale(), ricercaSuFigli, null);
            SolmrLogger.debug(this, "\n\n\n\n\n\n\n[###][###][###][###][###][###]\n\n\n\n\n");
            SolmrLogger.debug(this, "intermediarioVO.getCodiceFiscale(): "+intermediarioVO.getCodiceFiscale());
            SolmrLogger.debug(this, "ricercaSuFigli: "+ricercaSuFigli);
            SolmrLogger.debug(this, "delegaAnagrafeVO: "+delegaAnagrafeVO);

            if(delegaAnagrafeVO==null){

              Boolean isUtenteEsenteDelega = umaClient.serviceIsEsenteDelega(anagAziendaVO.getIdAzienda());

              if(isUtenteEsenteDelega.booleanValue() == false){

                ValidationError error = new ValidationError(AnagErrors.INTERMEDIARIO_SENZA_DELEGA);

                errors.add("error", error);

                request.setAttribute("errors", errors);

                request.getRequestDispatcher(url).forward(request, response);

                return;

              }
            }
          }//if (toDay.after(dataInizioGestioneFascicolo)) -- End
        }
      }
      //051213 - Controllo delega intermediario - End
      */

    }

    catch(SolmrException se) {

      if(cuaa != null && !cuaa.equals("")) {

        ValidationError error = new ValidationError(""+UmaErrors.get("ERR_AZIENDA_CUAA_NON_TROVATA"));

        errors.add("CUAA",error);

        request.setAttribute("errors", errors);

        request.getRequestDispatcher(url).forward(request, response);

        return;

      }

      else {

        ValidationError error = new ValidationError(""+UmaErrors.get("ERR_AZIENDA_PARTITA_IVA_NON_TROVATA"));

        errors.add("partitaIVA",error);

        request.setAttribute("errors", errors);

        request.getRequestDispatcher(url).forward(request, response);

        return;

      }

    }

  
    // Non deve esistere già una ditta UMA attiva associata all'azienda agricola trovata

    try {

      umaClient.isDittaUmaInseribile(anagAziendaVO.getIdAzienda());

    }

    catch(SolmrException se) {

      if(cuaa != null && !cuaa.equals("")) {

        ValidationError error = new ValidationError(""+UmaErrors.get("ERR_DITTA_NO_INSERIBILE_CUAA"));

        errors.add("CUAA",error);

        request.setAttribute("errors", errors);

        request.getRequestDispatcher(url).forward(request, response);

        return;

      }

      else {

        ValidationError error = new ValidationError(""+UmaErrors.get("ERR_DITTA_NO_INSERIBILE_PARTITA_IVA"));

        errors.add("partitaIVA",error);

        request.setAttribute("errors", errors);

        request.getRequestDispatcher(url).forward(request, response);

        return;

      }

    }

    if (duVO!=null)
    {
      HashMap common=new HashMap();
      common.put("dittaUmaVO",duVO);
      session.setAttribute("common",common);
    }
    else
    {
      session.removeAttribute("common");
    }
    session.setAttribute("anagAziendaVO",anagAziendaVO);

    %>

       <jsp:forward page = "<%= avantiUrl %>" />

    <%

  }

  session.removeAttribute("anagAziendaVO");

  %>

    <jsp:forward page = "<%= url %>" />

  <%

%>



