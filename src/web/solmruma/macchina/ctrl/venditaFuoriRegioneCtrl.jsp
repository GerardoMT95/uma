<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>


<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%!

  private static final String VIEW="/macchina/view/venditaFuoriRegioneView.jsp";

  private static final String ELENCO="../layout/elencoMacchine.htm";

  private static final String DETTAGLIO="../layout/dettaglioMacchinaDittaImmatricolazioni.htm";

  private static final String CONFERMA="../layout/venditaFuoriRegioneConferma.htm";

%>

<%

  String iridePageName = "venditaFuoriRegioneCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  try

{

  SolmrLogger.debug(this,"Entro tin venditaFuoriRegioneCtrl");



  UmaFacadeClient umaClient = new UmaFacadeClient();

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");



  String siglaProvincia = request.getParameter("siglaProvincia");

  String numeroDittaUMA = request.getParameter("numeroDittaUMA");

  String tipoTargaAssegnata = request.getParameter("tipoTargaAssegnata");

  String numeroNuovaTarga = request.getParameter("numeroNuovaTarga");



  String annoModello49 = request.getParameter("annoModello49");

  String numeroModello49 = request.getParameter("numeroModello49");



  request.setAttribute("siglaProvincia", siglaProvincia);

  request.setAttribute("numeroDittaUMA", numeroDittaUMA);

  request.setAttribute("tipoTargaAssegnata", tipoTargaAssegnata);

  request.setAttribute("numeroNuovaTarga", numeroNuovaTarga);

  request.setAttribute("numeroModello49", numeroModello49);

  request.setAttribute("annoModello49", annoModello49);



  ValidationErrors errors = new ValidationErrors();

  MacchinaVO mavo = new MacchinaVO();

  MovimentiTargaVO movo = new MovimentiTargaVO();

  SolmrLogger.debug(this,"###");

  if(session.getAttribute("common") instanceof MacchinaVO)

  {

    mavo = (MacchinaVO)session.getAttribute("common");

  }

  else if(request.getParameter("idMacchina")!=null)

  {

    Long idMacchina = new Long((String)request.getParameter("idMacchina"));

    mavo = umaClient.getMacchinaById(idMacchina);

  }
  
  if (mavo!=null && umaClient.isBloccoMacchinaImportataAnagrafe(mavo)) 
  {  
    it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::errorMessage!=null] utente non abilitato: "+it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
    request.setAttribute("errorMessage",it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
    %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
    return;
  }

  movo = umaClient.getUltimaMovimentazioneByIdMacchina(mavo.getIdMacchinaLong());

  SolmrLogger.debug(this,"movo "+movo);

  SolmrLogger.debug(this,"movo.getDatiTarga() "+movo.getDatiTarga());



  if (request.getParameter("annulla")!=null)

  {

    response.sendRedirect(DETTAGLIO);

    return;

    }else  if (request.getParameter("elenco")!=null)

    {

      session.removeAttribute("common");

      response.sendRedirect(ELENCO);

      return;

    }



    if (request.getParameter("conferma")!=null)

    {



      SolmrLogger.debug(this,"#########################################");

      SolmrLogger.debug(this,"errors "+errors);

      SolmrLogger.debug(this,"umaClient "+umaClient);

      SolmrLogger.debug(this,"siglaProvincia "+siglaProvincia);

      SolmrLogger.debug(this,"numeroDittaUMA "+numeroDittaUMA);

      SolmrLogger.debug(this,"numeroNuovaTarga "+numeroNuovaTarga);

      SolmrLogger.debug(this,"tipoTargaAssegnata "+tipoTargaAssegnata);

      SolmrLogger.debug(this,"movo "+movo);

      SolmrLogger.debug(this,"movo.getDatiTarga() "+movo.getDatiTarga());

      SolmrLogger.debug(this,"#########################################");





      validate(errors, umaClient, siglaProvincia, numeroDittaUMA, numeroNuovaTarga, tipoTargaAssegnata, numeroModello49, annoModello49);



      if (errors!=null && errors.size()>0)

      {

        request.setAttribute("errors",errors);



        request.setAttribute("siglaProvincia", siglaProvincia);

        request.setAttribute("numeroDittaUMA", numeroDittaUMA);

        request.setAttribute("numeroNuovaTarga", numeroNuovaTarga);

        request.setAttribute("tipoTargaAssegnata", tipoTargaAssegnata);

        request.setAttribute("numeroModello49", numeroModello49);

        request.setAttribute("annoModello49", annoModello49);



       %><jsp:forward page="<%=VIEW%>" /><%

         return;

      }

      TargaVO tavo = new TargaVO();



      if(movo.getDatiTarga() != null)

      {

        //aveva una targa

        tavo = movo.getDatiTarga();

        SolmrLogger.debug(this,"################### tavo.getIdNumeroTarga()  "+tavo.getIdNumeroTarga());

      }



      if("Stradale".equals(tipoTargaAssegnata))

      {

        tavo.setDescrizioneTipoTarga("Stradale");

        tavo.setIdTarga(getTipoNuovaTarga(mavo, true));

        tavo.setFlagTargaNuova("N");

        tavo.setNumeroTarga(numeroNuovaTarga);

      }

      else

        if ("UMA".equals(tipoTargaAssegnata))

        {

          tavo.setDescrizioneTipoTarga("UMA");

          tavo.setIdTarga(getTipoNuovaTarga(mavo, false));

          tavo.setFlagTargaNuova("N");

          tavo.setNumeroTarga(numeroNuovaTarga);

        }

        else

        {

          //la macchina mantiene la vecchia targa, se presente

          tavo.setDescrizioneTipoTarga("N");

        }



        tavo.setIdMacchinaLong(mavo.getIdMacchinaLong());

        tavo.setMc_824("");

        tavo.setIdProvincia(umaClient.getIstatProvinciaBySiglaProvincia(siglaProvincia));

        tavo.setSiglaProvincia(siglaProvincia);



        mavo.setTargaCorrente(tavo);



        mavo.setNumeroModello49(numeroModello49);

        mavo.setAnnoModello49(annoModello49);



        MovimentiTargaVO mvo = umaClient.venditaFuoriRegione(mavo, numeroDittaUMA, ruoloUtenza);



        SolmrLogger.debug(this,"################### mvo "+mvo);

        SolmrLogger.debug(this,"################### mvo.getDatiTarga() "+mvo.getDatiTarga());



        session.setAttribute("common", mvo);



        SolmrLogger.debug(this,"Vado su "+CONFERMA);

        response.sendRedirect(CONFERMA);

        return;

    }



  %><jsp:forward page="<%=VIEW%>" /><%

    }

    catch(SolmrException ex)

    {

      throwValidation(ex.getMessage(), VIEW);

    }

    catch(Exception e)

    {

      throwValidation("Si è verificato un errore di sistema", VIEW);

    }

%>



<%!

private void throwValidation(String msg,String validateUrl) throws ValidationException

{

  ValidationException valEx = new ValidationException("Eccezione : "+msg,validateUrl);

  valEx.addMessage(msg,"exception");

  throw valEx;

}

private void validate(ValidationErrors errors,UmaFacadeClient umaClient, String siglaProvincia, String numeroDittaUMA, String numeroNuovaTarga, String tipoTargaAssegnata, String numeroModello49, String annoModello49) throws SolmrException

{

  try

  {

    SolmrLogger.debug(this,"########################");

    SolmrLogger.debug(this,"umaClient.getRegioneByProvincia(siglaProvincia) "+umaClient.getRegioneByProvincia(siglaProvincia));

    SolmrLogger.debug(this,"siglaProvincia "+siglaProvincia);

    SolmrLogger.debug(this,"########################");

    if (!Validator.isNotEmpty(siglaProvincia))

    {

      errors.add("siglaProvincia",new ValidationError("Inserire la provincia di destinazione"));

    }

    if(!Validator.isNotEmpty(umaClient.getRegioneByProvincia(siglaProvincia)))

    {

      errors.add("siglaProvincia",new ValidationError("Provincia inesistente"));

    }

    else if(SolmrConstants.ID_REGIONE.equals(umaClient.getRegioneByProvincia(siglaProvincia)))

    {

      errors.add("siglaProvincia",new ValidationError("La provincia di destinazione deve appartenere ad una regione diversa dal TOBECONFIG"));

    }



    boolean numeroModello49Vuoto=false;

    if(!Validator.isNotEmpty(numeroModello49)){

      //vuoto numero modello 49

      numeroModello49Vuoto=true;

      SolmrLogger.debug(this,"1A");

    }else{

      try

      {

        SolmrLogger.debug(this,"2A");

        Long NumeroModello49Long = new Long(numeroModello49);

        long LIMITE_NUMERO_MODELLO49=999999;

        if ( numeroModello49.length()>LIMITE_NUMERO_MODELLO49)

        {

          errors.add("numeroModello49",new ValidationError("Il numero modello 49 deve essere inferiore a "+ LIMITE_NUMERO_MODELLO49));

          SolmrLogger.debug(this,"3A");

        }

      }

      catch (NumberFormatException ex)

      {

        errors.add("numeroModello49",new ValidationError("Il numero modello 49 deve essere numerico"));

        SolmrLogger.debug(this,"4A");

      }

    }



    String messModello49="Valorizzare la coppia numero/anno modello 49";

    if(!Validator.isNotEmpty(annoModello49)){

      SolmrLogger.debug(this,"1B");

      //vuoto anno modello 49

      if(numeroModello49Vuoto==false){

        errors.add("numeroModello49", new ValidationError(messModello49));

        errors.add("annoModello49", new ValidationError(messModello49));

      }

    }else{

      SolmrLogger.debug(this,"2B");

      if(numeroModello49Vuoto==true){

        SolmrLogger.debug(this,"3B");

        errors.add("numeroModello49", new ValidationError(messModello49));

        errors.add("annoModello49", new ValidationError(messModello49));

      }

      else

      {

        try{

          SolmrLogger.debug(this,"4B");

          Long annoModello49Long = new Long(annoModello49);

          long LIMITE_ANNO_MODELLO49_INFERIORE=1900;

          long LIMITE_ANNO_MODELLO49_SUPERIORE=2100;

          if ( annoModello49Long.longValue() < LIMITE_ANNO_MODELLO49_INFERIORE)

          {

            errors.add("annoModello49",new ValidationError("L''anno modello 49 deve essere superiore o uguale a "+ LIMITE_ANNO_MODELLO49_INFERIORE));

            SolmrLogger.debug(this,"5B");

          }else{

            if ( annoModello49Long.longValue() > LIMITE_ANNO_MODELLO49_SUPERIORE)

            {

              errors.add("annoModello49",new ValidationError("L''anno modello 49 deve essere inferiore o uguale a "+ LIMITE_ANNO_MODELLO49_SUPERIORE));

              SolmrLogger.debug(this,"6B");

            }

          }

        }

        catch (NumberFormatException ex)

        {

          errors.add("annoModello49",new ValidationError("L''anno modello 49 deve essere numerico"));

          SolmrLogger.debug(this,"7B");

        }

      }

    }

  }

  catch(SolmrException e)

  {

      throw new SolmrException(e.getMessage());

  }



  if (!Validator.isNotEmpty(numeroDittaUMA))

  {

    errors.add("numeroDittaUMA",new ValidationError("Inserire il numero della ditta di destinazione"));

  }

  else if(numeroDittaUMA.length()>6)

  {

    errors.add("numeroDittaUMA",new ValidationError("Il &quot;Numero Ditta&quot; non può essere più lungo di 6 cifre"));

  }

  if (!Validator.isNumericInteger(numeroDittaUMA))

  {

    errors.add("numeroDittaUMA",new ValidationError("Inserire un valore numerico."));

  }



  if(!"N".equalsIgnoreCase(tipoTargaAssegnata.trim()) && !Validator.isNotEmpty(numeroNuovaTarga))

  {

    errors.add("numeroNuovaTarga",new ValidationError("Inserire il numero della targa."));

  }

}

private String getTipoNuovaTarga(MacchinaVO macchinaVO,boolean stradale)

{

  String codBreveGenere = "";

  if(macchinaVO.getMatriceVO()!=null)

    codBreveGenere=macchinaVO.getMatriceVO().getCodBreveGenereMacchina().trim();

  else if(macchinaVO.getDatiMacchinaVO()!=null)

    codBreveGenere=macchinaVO.getDatiMacchinaVO().getCodBreveGenereMacchina().trim();





  if (SolmrConstants.COD_BREVE_GENERE_MACCHINA_T.equals(codBreveGenere) ||

      SolmrConstants.COD_BREVE_GENERE_MACCHINA_D.equals(codBreveGenere) ||

      SolmrConstants.COD_BREVE_GENERE_MACCHINA_MTS.equals(codBreveGenere) ||

      SolmrConstants.COD_BREVE_GENERE_MACCHINA_MTA.equals(codBreveGenere))

  {

    if (stradale)

    {

      return SolmrConstants.TARGA_STRADALE_MA;

    }

    else

    {

      return SolmrConstants.TARGA_UMA;

    }

  }



  if (SolmrConstants.COD_BREVE_GENERE_MACCHINA_MAO.equals(codBreveGenere))

  {

    if (stradale)

    {

      return SolmrConstants.TARGA_MAO;

    }

    else

    {

      return SolmrConstants.TARGA_UMA;

    }

  }



  if(SolmrConstants.get("COD_BREVE_GENERE_MACCHINA_R").equals(codBreveGenere))

  {

    return SolmrConstants.TARGA_STRADALE_RA;

  }

  return SolmrConstants.TARGA_UMA;

}

%>