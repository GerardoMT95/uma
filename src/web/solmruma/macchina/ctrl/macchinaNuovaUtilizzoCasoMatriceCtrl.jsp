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
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%!
  private static final String VIEW="/macchina/view/macchinaNuovaUtilizzoCasoMatriceView.jsp";
  private static final String PREV="../layout/macchinaNuovaDatiCasoMatrice.htm";
  private static final String NEXT="../layout/macchinaNuovaConferma.htm";
  private static final String MACCHINA_NUOVA="../layout/macchinaNuovaGenere.htm";
%>

<%

  String iridePageName = "macchinaNuovaUtilizzoCasoMatriceCtrl.jsp";
  %>
    <%@include file = "/include/autorizzazione.inc" %>
  <%

  Object commonObj=session.getAttribute("common");
  SolmrLogger.debug(this,"commonObj="+commonObj);
  if (commonObj==null || !(commonObj instanceof java.util.HashMap))
  {
    if (commonObj==null)
    {
      SolmrLogger.debug(this,"commonObj==null");
    }

    if (commonObj instanceof java.util.HashMap)
    {
      SolmrLogger.debug(this,"instanceof java.util.HashMap");
    }

    response.sendRedirect(MACCHINA_NUOVA);
    return;
  }

  try
  {

    DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
    Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
    UmaFacadeClient umaClient = new UmaFacadeClient();
    AnagFacadeClient anagClient = new AnagFacadeClient();
    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
    SolmrLogger.debug(this,"macchinaNuovaUtilizzoCasoMatriceCtrl.jsp");
    SolmrLogger.debug(this,"commonObj="+commonObj);
    if (request.getParameter("salva")!=null)
    {
      SolmrLogger.debug(this,"NEXT");
      HashMap common=(HashMap)session.getAttribute("common");
      MacchinaVO macchinaVO=(MacchinaVO)common.get("macchinaVO");
      //Modifica inserimento matrice puntuale - 210305 - Begin
      MatriceVO matriceVO=(MatriceVO) common.get("matriceVO");
      macchinaVO.setMatriceVO(matriceVO);
      SolmrLogger.debug(this,"macchinaVO.getMatriceVO(): "+macchinaVO.getMatriceVO());
      //Modifica inserimento matrice puntuale - 210305 - End
      ValidationErrors errors=validate(request,umaClient,anagClient,macchinaVO);
      PossessoVO possessoVO=createPossessoVO(request);
      //TargaVO targaVO=macchinaVO.getTargaCorrente();
      TargaVO targaVO=new TargaVO();
      SolmrLogger.debug(this,"targaVO: "+targaVO);
      DittaUMAVO dittaProvenienzaVO=(DittaUMAVO)common.get("dittaProvenienzaVO");
      UtilizzoVO utilizzoVO = new UtilizzoVO();
      AnagAziendaVO dittaLeasing = new AnagAziendaVO();
      String tipoNuovaTarga=null;

      tipoNuovaTarga=getTipoNuovaTarga(matriceVO,"Stradale".equalsIgnoreCase(request.getParameter("tipoTarga")));

      //Se non esistono errori sulla data di carico
      if (errors.get("dataCarico")==null)
      {
        utilizzoVO.setDataCarico(request.getParameter("dataCarico"));
      }
      SolmrLogger.debug(this,"5");
      if (errors!=null && errors.size()==0)
      {
        SolmrLogger.debug(this,"dittaProvenienzaVO="+dittaProvenienzaVO);
        SolmrLogger.debug(this,"tipoNuovaTarga="+tipoNuovaTarga);        
        Long idMovimentazione=null;
        SolmrLogger.debug(this,"prima di istatProvinciaProvenienza");
        macchinaVO.setIdMatrice(matriceVO.getIdMatrice());
        macchinaVO.setDatiMacchinaVO(null);
        SolmrLogger.debug(this,"macchinaVO.getIdMatrice(): "+macchinaVO.getIdMatrice());
        SolmrLogger.debug(this,"Prima di umaClient.acquistaMacchinaNuovaMatrice");
        MovimentiTargaVO movimentiTargaVO=umaClient.acquistaMacchinaNuovaMatrice(macchinaVO, tipoNuovaTarga, possessoVO, utilizzoVO, dittaLeasing, dittaUMAAziendaVO, ruoloUtenza);
        SolmrLogger.debug(this,"dopo di umaClient.acquistaMacchinaNuovaMatrice");
        //session.removeAttribute("common");
        SolmrLogger.debug(this,"movimentiTargaVO: "+movimentiTargaVO);
        common.put("movimentiTargaVO",movimentiTargaVO);
        session.setAttribute("common", common);
        SolmrLogger.debug(this,"request.getParameter(\"tipoTarga\")="+request.getParameter("tipoTarga"));
        response.sendRedirect(NEXT);
        SolmrLogger.debug(this,"do redirect");
        return;
      }
      else
      {
        SolmrLogger.debug(this,"erros="+errors);
        request.setAttribute("errors",errors);
      }
    }
    else
    {
      if (request.getParameter("indietro")!=null)
      {
        SolmrLogger.debug(this,"PREV");
        response.sendRedirect(PREV);
        return;
      }
    }
  }
  catch(SolmrException e)
  {
    SolmrLogger.debug(this,"SolmrException = "+e.getMessage());
    ValidationErrors errors=new ValidationErrors();
    errors.add("error",new ValidationError(e.getMessage()));
    request.setAttribute("errors",errors);
  }
  catch(Exception e)
  {
    SolmrLogger.debug(this,"Errore di sistema="+e.getMessage());
    ValidationErrors errors=new ValidationErrors();
    errors.add("error",new ValidationError("Si è verificato un errore di sistema!"));
    request.setAttribute("errors",errors);
  }
  SolmrLogger.debug(this,"Forward to "+VIEW);
%>
  <jsp:forward page="<%=VIEW%>"/>
<%!

  private ValidationErrors validate(HttpServletRequest request,UmaFacadeClient umaClient, AnagFacadeClient anagClient, MacchinaVO macchinaVO) 
    throws Exception
  {
    ValidationErrors errors=new ValidationErrors();
    String partitaIVA=request.getParameter("partitaIVA");
    String ragioneSociale=request.getParameter("ragioneSociale");
    String dataCarico=request.getParameter("dataCarico");
    String dataPrimaImmatricolazione=request.getParameter("dataPrimaImmatricolazione");
    String dataScadenzaLeasing=request.getParameter("dataScadenzaLeasing");
    String mc824=request.getParameter("mc824");
    String idFormaPossesso=request.getParameter("idFormaPossesso");
    String nuovaTarga=request.getParameter("nuovaTarga");
    String idSocietaLeasing=request.getParameter("idSocietaLeasing");

    //Acquisto nuovo con targa - Borgogno 21/10/2004 - Begin
    final String TARGA_ASSEGNATA = "auto";
    final String TARGA_SPECIFICATA = "spec";
    final Long TARGA_UMA = new Long("1");
    final Long TARGA_STRADALE_RA = new Long("2");
    final Long TARGA_STRADALE_MA = new Long("3");
    final Long TARGA_MAO = new Long("4");

    final String DESC_RADIO_TARGA_STRADALE = "Stradale";
    final String DESC_RADIO_TARGA_UMA = "UMA";

    final boolean MACCHINA_CON_TARGA = true;
    final boolean MACCHINA_SENZA_TARGA = false;

    boolean leasingRequired=SolmrConstants.LEASING.equals(idFormaPossesso) ||
                            SolmrConstants.NOLEGGIO.equals(idFormaPossesso);

    TargaVO targaCorrente = new TargaVO();
    if (mc824!=null)
    {
      targaCorrente.setMc_824(mc824);
    }
    SolmrLogger.debug(this, "targaCorrente.getMc_824(): "+targaCorrente.getMc_824());

    Long tipoTarga = null;
    SolmrLogger.debug(this, "request.getParameter(\"tipoTarga\"): "+request.getParameter("tipoTarga"));
    if (Validator.isNotEmpty(request.getParameter("tipoTarga")))
    {
      SolmrLogger.debug(this, "if (!Validator.isNotEmpty(request.getParameter(\"tipoTarga\")))");

      String tipoTargaParameter = request.getParameter("tipoTarga");

      SolmrLogger.debug(this, "tipoTargaParameter: "+tipoTargaParameter);
      SolmrLogger.debug(this, "DESC_RADIO_TARGA_STRADALE: "+DESC_RADIO_TARGA_STRADALE);
      SolmrLogger.debug(this, "DESC_RADIO_TARGA_UMA: "+DESC_RADIO_TARGA_UMA);

      if(tipoTargaParameter.trim().equalsIgnoreCase(DESC_RADIO_TARGA_STRADALE)){
        SolmrLogger.debug(this, "if(tipoTargaParameter.equalsIgnoreCase(\"Stradale\"))");
        tipoTarga = TARGA_STRADALE_MA;
      }
      else{
        if(tipoTargaParameter.trim().equalsIgnoreCase(DESC_RADIO_TARGA_UMA)){
          SolmrLogger.debug(this, "if(tipoTargaParameter.equalsIgnoreCase(\"UMA\"))");
          tipoTarga = TARGA_UMA;
        }
      }

    }
    SolmrLogger.debug(this, "tipoTarga: "+tipoTarga);

    boolean numeroTargaObbl = false;
    String numeroTarga = null;    
    SolmrLogger.debug(this, "request.getParameter(\"radioTarga\"): "+request.getParameter("radioTarga"));
    if (Validator.isNotEmpty(request.getParameter("radioTarga")))
    {
      SolmrLogger.debug(this, "if (!Validator.isNotEmpty(request.getParameter(\"radioTarga\")))");

      SolmrLogger.debug(this,"dataPrimaImmatricolazione="+dataPrimaImmatricolazione);
	    Validator.validateDateAll(dataPrimaImmatricolazione,"dataPrimaImmatricolazione","data prima immatricolazione",errors,true, true);
	    if(errors.get("dataPrimaImmatricolazione")==null)
	    {    
	      targaCorrente.setDataPrimaImmatricolazione(DateUtils.parseDate(dataPrimaImmatricolazione));
	    }

      String radioTarga = request.getParameter("radioTarga");

      if(radioTarga.equalsIgnoreCase(TARGA_SPECIFICATA))
      {
        SolmrLogger.debug(this, "if(radioTarga.equalsIgnoreCase(TARGA_SPECIFICATA))");
        numeroTargaObbl = true;
        SolmrLogger.debug(this, "numeroTargaObbl: "+numeroTargaObbl);
        numeroTarga = request.getParameter("numeroTarga");
        SolmrLogger.debug(this, "numeroTarga: "+numeroTarga);
        if (!Validator.isNotEmpty(request.getParameter("numeroTarga")))
        {
          errors.add("numeroTarga",new ValidationError("Specificare un numero targa"));
        }
        macchinaVO.setHasTarga(MACCHINA_CON_TARGA);
        SolmrLogger.debug(this, "macchinaVO.setHasTarga()");
      }
      else if(radioTarga.equalsIgnoreCase(TARGA_ASSEGNATA))
      {
        macchinaVO.setHasTarga(MACCHINA_SENZA_TARGA);
        SolmrLogger.debug(this, "if(radioTarga.equalsIgnoreCase(TARGA_ASSEGNATA))");
      }
      
      SolmrLogger.debug(this, "numeroTargaObbl: "+numeroTargaObbl);
      SolmrLogger.debug(this, "errors.get(\"numeroTarga\"): "+errors.get("numeroTarga"));
      if(numeroTargaObbl && errors.get("numeroTarga")==null)
      {
        SolmrLogger.debug(this, "if(numeroTargaObbl && errors.get(\"numeroTarga\")==null)");
        /** @todo  */
        targaCorrente.setNumeroTarga(numeroTarga);
        targaCorrente.setIdTargaLong(tipoTarga);
        SolmrLogger.debug(this, "targaCorrente.getNumeroTarga(): "+targaCorrente.getNumeroTarga());
        SolmrLogger.debug(this, "targaCorrente.getIdTargaLong(): "+targaCorrente.getIdTargaLong());
        SolmrLogger.debug(this, "tipoTarga: "+tipoTarga);
        
        // TOLTI CONTROLLI SUL FORMATO DELLA TARGA PER LA TOBECONFIG
        /*
        if(Validator.isNotEmpty(tipoTarga))
        {
          if(tipoTarga.longValue() == TARGA_STRADALE_MA.longValue())
          {
            SolmrLogger.debug(this, "errors = isFormatoTargaValido("+numeroTarga+","+TARGA_STRADALE_MA+","+errors+")");
            errors = isFormatoTargaValido(numeroTarga, TARGA_STRADALE_MA, errors);
            SolmrLogger.debug(this, "1errors.size(): "+errors.size());
          }
          else
          {
            if(tipoTarga.longValue() == TARGA_UMA.longValue())
            {
              SolmrLogger.debug(this, "errors = isFormatoTargaValido("+numeroTarga+","+TARGA_UMA+","+errors+")");
              errors = isFormatoTargaValido(numeroTarga, TARGA_UMA, errors);
              SolmrLogger.debug(this, "2errors.size(): "+errors.size());
            }
          }
        }
        */
        MatriceVO matriceVO = macchinaVO.getMatriceVO();
        SolmrLogger.debug(this, "matriceVO: "+matriceVO);

        String tipoNuovaTarga=getTipoNuovaTarga(matriceVO,"Stradale".equalsIgnoreCase(request.getParameter("tipoTarga")));
        SolmrLogger.debug(this, "tipoNuovaTarga: "+tipoNuovaTarga);
        SolmrLogger.debug(this, "matriceVO.getCodBreveGenereMacchina().trim(): "+matriceVO.getCodBreveGenereMacchina().trim());

        Long tipoNuovaTargaLong = new Long(tipoNuovaTarga);
        SolmrLogger.debug(this, "errors = isTargaUnica("+numeroTarga+","+tipoNuovaTarga+","+errors+","+umaClient+")");
        errors = isTargaUnica(numeroTarga, tipoNuovaTargaLong, errors, umaClient);
        SolmrLogger.debug(this, "3errors.size(): "+errors.size());        
      }
      macchinaVO.setTargaCorrente(targaCorrente);
    }
    

    SolmrLogger.debug(this,"dataCarico="+dataCarico);
    Validator.validateDateAll(dataCarico,"dataCarico","data di carico",errors,true, true);

    if ("".equals(idFormaPossesso))
    {
      errors.add("idFormaPossesso",new ValidationError("Indicare la forma di possesso"));
    }
    else
    {
      // se idFormaPossesso = 'Leasing' o 'Utilizzo/Noleggio' -> data scadenza obbligatoria     
      if(idFormaPossesso.equals(SolmrConstants.get("LEASING")) ||
         idFormaPossesso.equals(SolmrConstants.get("UTILIZZO_NOLEGGIO")))
      { 
        if(!Validator.isNotEmpty(dataScadenzaLeasing))
        {
          errors.add("dataScadenzaLeasing",new ValidationError("Valorizzare la data scadenza contratto"));
        }
        else
        {
          if(!Validator.validateDateF(dataScadenzaLeasing)) 
          {
            errors.add("dataScadenzaLeasing",new ValidationError("Valorizzare la data correttamente"));
          }
          else
          {
            Date data = null;
            Date oggi = null;
            try
            {
              data = UmaBaseVO.parseDate(dataScadenzaLeasing);
              oggi = UmaBaseVO.parseDate(UmaDateUtils.getCurrentDateString());
            }
            catch(Exception ex)
            {
              errors.add("dataScadenzaLeasing",new ValidationError("Errore nel formato della data"));
            }
            if(!data.after(oggi))
            {
              errors.add("dataScadenzaLeasing",new ValidationError("La data scadenza contratto deve essere superiore alla data odierna"));
            }
          }
        } 
        // se idFormaPossesso = 'Leasing' -> società di leasing obbligatoria
        if(idFormaPossesso.equals(SolmrConstants.get("LEASING")))
        {
          //errors.add("idSocietaLeasing",new ValidationError("Valorizzare la ditta di leasing"));
          if (!Validator.isNotEmpty(idSocietaLeasing))
          {
            errors.add("idSocietaLeasing",new ValidationError("Indicare la società di leasing"));
          }
          else
          {
            if (errors.get("idSocietaLeasing")==null)
            {
              AnagAziendaVO dittaLeasing=null;
              try
              {
                dittaLeasing=anagClient.findAziendaAttiva(new Long(idSocietaLeasing));
                PersonaFisicaVO rapprLegale=anagClient.getTitolareORappresentanteLegaleAzienda(dittaLeasing.getIdAzienda(),new Date());
                dittaLeasing.setRappresentanteLegale(rapprLegale.getNome()+" "+rapprLegale.getCognome());
              }
              catch(SolmrException e)
              {
                ValidationError errVal=new ValidationError("Ditta non trovata!");
                errors.add("societaLeasing", errVal);
              }
              request.setAttribute("dittaLeasing",dittaLeasing);
            }
          }
        }   
      }
      // in tutti gli altri casi, se viene indicata una data scadenza (facoltativa), deve essere una data valida
      else
      {
        if(Validator.isNotEmpty(dataScadenzaLeasing))
        {
          if(!Validator.validateDateF(dataScadenzaLeasing)) 
          {
            errors.add("dataScadenzaLeasing",new ValidationError("Valorizzare la data correttamente"));
          }
          else
          {
            Date data = null;
            Date oggi = null;
            try
            {
              data = UmaBaseVO.parseDate(dataScadenzaLeasing);
              oggi = UmaBaseVO.parseDate(UmaDateUtils.getCurrentDateString());
            }
            catch(Exception ex)
            {
              errors.add("dataScadenzaLeasing",new ValidationError("Errore nel formato della data"));
            }
            if(!data.after(oggi))
            {
              errors.add("dataScadenzaLeasing",new ValidationError("La data scadenza contratto deve essere superiore alla data odierna"));
            }
          }
        }
      }
    }

    /*if (leasingRequired && !Validator.isNotEmpty(idSocietaLeasing))
    {
      errors.add("idSocietaLeasing",new ValidationError("Indicare la società di leasing"));
    }*/

    



    /*SolmrLogger.debug(this,"leasingRequired: "+leasingRequired);
    SolmrLogger.debug(this,"errors.get(\"idSocietaLeasing\"): "+errors.get("idSocietaLeasing"));
    SolmrLogger.debug(this,"dataScadenzaLeasing: "+dataScadenzaLeasing);
    SolmrLogger.debug(this,"errors.get(\"dataCarico\"): "+errors.get("dataCarico"));

    if (leasingRequired && errors.get("dataCarico")==null)
    {

      Validator.validateDateAfterToDay(dataScadenzaLeasing,
                                       "dataScadenzaLeasing",
                                       "data di scadenza del leasing",
                                       errors,
                                       leasingRequired,
                                       true);
    }



    if (leasingRequired && errors.get("idSocietaLeasing")==null)
    {
      AnagAziendaVO dittaLeasing=null;
      try
      {
        dittaLeasing=anagClient.findAziendaAttiva(new Long(idSocietaLeasing));
        SolmrLogger.debug(this,"dittaLeasing.getIdAzienda(): "+dittaLeasing.getIdAzienda());
        PersonaFisicaVO rapprLegale=anagClient.getTitolareORappresentanteLegaleAzienda(dittaLeasing.getIdAzienda(),new Date());
        dittaLeasing.setRappresentanteLegale(rapprLegale.getNome()+" "+rapprLegale.getCognome());
      }
      catch(SolmrException e)
      {
        ValidationError errVal=new ValidationError("Ditta non trovata!");
        errors.add("societaLeasing", errVal);
      }
      request.setAttribute("dittaLeasing",dittaLeasing);
    }*/
    return errors;
  }

  private void throwValidation(String msg,String validateUrl) 
  throws ValidationException
  {
    ValidationException valEx = new ValidationException("eccezione="+msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }

  private PossessoVO createPossessoVO(HttpServletRequest request)
  {
    PossessoVO possessoVO=new PossessoVO();
    possessoVO.setIdFormaPossesso(request.getParameter("idFormaPossesso"));
    possessoVO.setDataScadenzaLeasing(request.getParameter("dataScadenzaLeasing"));
    possessoVO.setDataInizioValidita(request.getParameter("dataCarico"));
    AnagAziendaVO dittaLeasing=(AnagAziendaVO)request.getAttribute("dittaLeasing");

    if (dittaLeasing!=null)
    {
      possessoVO.setExtIdAziendaLong(dittaLeasing.getIdAzienda());
    }
    return possessoVO;
  }



  private String getTipoNuovaTarga(MatriceVO matriceVO,boolean stradale)
  {
    SolmrLogger.debug(this, "matriceVO.getCodBreveGenereMacchina(): "+matriceVO.getCodBreveGenereMacchina());
    String codBreveGenere=matriceVO.getCodBreveGenereMacchina().trim();
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
    return SolmrConstants.TARGA_UMA;
  }

  private ValidationErrors isTargaUnica(String numeroTarga, Long formatoTarga, ValidationErrors errors, UmaFacadeClient umaClient) 
  throws SolmrException
  {
    final Long TARGA_UMA = new Long("1");
    final Long TARGA_STRADALE_RA = new Long("2");
    final Long TARGA_STRADALE_MA = new Long("3");
    final Long TARGA_MAO = new Long("4");
    TargaVO targaVO = null;
    Long idNumeroTarga = null;

    if(formatoTarga.longValue() == TARGA_UMA.longValue())
    {
      SolmrLogger.debug(this, "if(formatoTarga.longValue() == TARGA_UMA.longValue())");
      targaVO = umaClient.findTargaByNumeroAndTipo(numeroTarga,TARGA_UMA);
      idNumeroTarga = targaVO.getIdNumeroTargaLong();
      if (idNumeroTarga!=null)
      {
        errors.add("numeroTarga",new ValidationError("Targa UMA già assegnata"));
        return errors;
      }
    }

    if(formatoTarga.longValue() == TARGA_STRADALE_RA.longValue())
    {
      SolmrLogger.debug(this, "if(formatoTarga.longValue() == TARGA_STRADALE_RA.longValue())");
      targaVO = umaClient.findTargaByNumeroAndTipo(numeroTarga,TARGA_STRADALE_RA);
      idNumeroTarga = targaVO.getIdNumeroTargaLong();
      if (idNumeroTarga!=null)
      {
        errors.add("numeroTarga",new ValidationError("Targa STRADALE RA già assegnata"));
        return errors;
      }
    }

    if(formatoTarga.longValue() == TARGA_STRADALE_MA.longValue())
    {
      SolmrLogger.debug(this, "if(formatoTarga.longValue() == TARGA_STRADALE_MA.longValue())");
      targaVO = umaClient.findTargaByNumeroAndTipo(numeroTarga,TARGA_STRADALE_MA);
      idNumeroTarga = targaVO.getIdNumeroTargaLong();
      if (idNumeroTarga!=null)
      {
        errors.add("numeroTarga",new ValidationError("Targa STRADALE MA già assegnata"));
        return errors;
      }
    }

    if(formatoTarga.longValue() == TARGA_MAO.longValue())
    {
      SolmrLogger.debug(this, "if(formatoTarga.longValue() == TARGA_MAO.longValue())");
      targaVO = umaClient.findTargaByNumeroAndTipo(numeroTarga,TARGA_MAO);
      idNumeroTarga = targaVO.getIdNumeroTargaLong();
      if (idNumeroTarga!=null)
      {
        errors.add("numeroTarga",new ValidationError("Targa MAO già assegnata"));
        return errors;
      }
    }
    return errors;
  }

	private ValidationErrors isFormatoTargaValido(String numeroTarga, Long formatoTarga, ValidationErrors errors)
	{
	  final Long TARGA_UMA = new Long("1");
	  final Long TARGA_STRADALE_RA = new Long("2");
	  final Long TARGA_STRADALE_MA = new Long("3");
	  final Long TARGA_MAO = new Long("4");
	
	  Targhe targaValidator = new Targhe();
	  boolean targaValida = true;
	
	  if(formatoTarga.longValue() == TARGA_UMA.longValue())
	  {
	    SolmrLogger.debug(this, "formatoTarga.longValue() == TARGA_UMA");
	    targaValida = targaValidator.isValidUMA(numeroTarga);
	  }
	  SolmrLogger.debug(this, "targaValidator.isValidUMA("+numeroTarga+"): "+targaValida);
	
	  if(formatoTarga.longValue() == TARGA_STRADALE_RA.longValue()
	     || formatoTarga.longValue() == TARGA_STRADALE_MA.longValue()
	     || formatoTarga.longValue() == TARGA_MAO.longValue())
	  {
	    SolmrLogger.debug(this, "formatoTarga.longValue().longValue() == TARGA_STRADALE_RA,TARGA_STRADALE_MA,TARGA_MAO");
	    targaValida = targaValidator.isValid(numeroTarga);
	  }
	  SolmrLogger.debug(this, "targaValidator.isValid("+numeroTarga+"): "+targaValida);
	
	  if( targaValida == false )
	  {
	    errors.add("numeroTarga",new ValidationError( ""+SolmrConstants.get("FORMATO_TARGA_NON_VALIDA") ));
	  }
	
	  return errors;
	}

%>