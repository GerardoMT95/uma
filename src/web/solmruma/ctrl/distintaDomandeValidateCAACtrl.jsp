<%@ page import="it.csi.solmr.client.uma.UmaFacadeClient"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.TreeMap"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.util.DateUtils"%>
<%@ page import="it.csi.solmr.dto.ProvinciaVO"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.util.ValidationErrors"%>
<%@ page import="it.csi.solmr.util.ValidationError"%>
<%@ page import="it.csi.solmr.util.Validator"%>
<%@ page import="it.csi.solmr.util.SolmrLogger"%>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors"%>
<%@ page import="it.csi.solmr.exception.SolmrException"%>
<%@ page import="it.csi.solmr.dto.comune.IntermediarioVO"%>
<%@ page import="it.csi.papua.papuaserv.presentation.ws.profilazione.axis.UtenteAbilitazioni" %>

<%!
  private static final String VIEW="/view/distintaDomandeValidateCAAView.jsp";
%><%
  String iridePageName = "distintaDomandeValidateCAACtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

	SolmrLogger.debug(this, "   BEGIN distintaDomandeValidateCAACtrl");
  
  UmaFacadeClient umaFacadeClient=new UmaFacadeClient();
  Vector province=umaFacadeClient.getProvincieByRegione(it.csi.solmr.etc.SolmrConstants.ID_REGIONE);
  int length=province==null?0:province.size();
  TreeMap provinceOrdinate=new TreeMap();
  for(int i=0;i<length;i++)
  {
    ProvinciaVO provinciaVO=(ProvinciaVO)province.get(i);
    provinceOrdinate.put(provinciaVO.getSiglaProvincia(),provinciaVO);
  }
  request.setAttribute("province",provinceOrdinate);

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  UtenteAbilitazioni utenteAbilitazioni = (UtenteAbilitazioni) session.getAttribute("utenteAbilitazioni");
  if(ruoloUtenza.isUtenteIntermediario())
  {
	  Long idIntermediarioCorrente=utenteAbilitazioni.getEnteAppartenenza().getIntermediario().getIdIntermediario();
	  IntermediarioVO listaIntermediari[]=umaFacadeClient.serviceGetListaIntermediari(idIntermediarioCorrente,null,
	  SolmrConstants.TIPO_INTERMEDIARIO_CAA,null);
	
	  TreeMap intermediari=new TreeMap();
	  length=listaIntermediari==null?0:listaIntermediari.length;
	  for(int i=0;i<length;i++)
	  {
	    IntermediarioVO iVO=listaIntermediari[i];
	    String desc = iVO.getCodiceFiscale();
	    if (iVO.getDenominazione()!=null)
	    {
	      desc+=" - "+iVO.getDenominazione();
	    }
	    intermediari.put(desc,iVO);
	  }
	  request.setAttribute("intermediari",intermediari);
	}

  String conferma=request.getParameter("conferma");

  SolmrLogger.debug(this, "   BEGIN parametro conferma = "+conferma);

  if ("conferma".equals(conferma))
  {
    String istatProvincia=request.getParameter("istatProvincia");
    String anno=request.getParameter("anno");
    String idIntermediario=request.getParameter("idIntermediario");
    String dalFoglio=request.getParameter("dalFoglio");
    String alFoglio=request.getParameter("alFoglio");
    ValidationErrors errors=validateRicerca(istatProvincia,anno,idIntermediario,dalFoglio,alFoglio);
    if (errors!=null)
    {
      request.setAttribute("errors",errors);
    }
    else
    {
      ricerca(umaFacadeClient,istatProvincia,anno,idIntermediario,dalFoglio,alFoglio,request);
    }
  }
  else
  {
    if ("report".equals(conferma))
    {
      String istatProvincia=request.getParameter("istatProvincia");
      String anno=request.getParameter("anno");
      String idIntermediario=request.getParameter("idIntermediario");
      String dalFoglio=request.getParameter("dalFoglio");
      String alFoglio=request.getParameter("alFoglio");
      Vector risultatiRicerca=ricerca(umaFacadeClient,istatProvincia,anno,idIntermediario,dalFoglio,alFoglio,request);
      if (risultatiRicerca!=null) // Teoricamente sempre vero
      {
        int numElementi=new Long(request.getParameter("hdnNumElementi")).intValue();
        if (numElementi!=risultatiRicerca.size())
        {
          throw new SolmrException(UmaErrors.ERRORE_DATI_CAMBIATI_SU_DB_PER_RICERCA);
        }
        String indexIntermediario[] = request.getParameterValues("indexIntermediario");
        String rigaIniziale[]= request.getParameterValues("rigaIniziale");
        String rigaFinale[]= request.getParameterValues("rigaFinale");
        ValidationErrors errors=validateReport(indexIntermediario,rigaIniziale,rigaFinale);
        request.setAttribute("errors",errors);
      }
    }
  }

%><jsp:forward page="<%=VIEW%>" /><%!

  protected Vector ricerca(UmaFacadeClient umaFacadeClient,
                         String istatProvincia,
                         String anno,
                         String idIntermediario,
                         String dalFoglio,
                         String alFoglio,
                         HttpServletRequest request)
  throws Exception
  {
    // Mi carico l'elenco degli intermediari che fanno capo a quello indicato
    // dall'utente
    IntermediarioVO intermediari[]=umaFacadeClient.serviceGetListaIntermediari(new Long(idIntermediario),
    null,SolmrConstants.TIPO_INTERMEDIARIO_CAA,SolmrConstants.LIVELLO_INTERMEDIARIO_DI_ZONA);
    int length=intermediari==null?0:intermediari.length;
    long idIntermediari[]=new long[length];
    for(int i=0;i<length;i++)
    {
      idIntermediari[i]=intermediari[i].getIdIntermediarioLong().longValue();
    }
    // Ricerca dei dati sul db
    long dalFoglioLong=new Long(dalFoglio).longValue();
    long alFoglioLong=9999;
    if (Validator.isNotEmpty(alFoglio))
    {
      alFoglioLong=new Long(alFoglio).longValue();
    }
    long annoLong=new Long(anno).longValue();

    Vector risultatiRicerca=umaFacadeClient.getFogliRigaPerDomandeCAA(istatProvincia,
    idIntermediari,annoLong,dalFoglioLong,alFoglioLong);

    if (risultatiRicerca!=null)
    {
      request.setAttribute("risultatiRicerca",risultatiRicerca);
    }
    else
    {
      // Non faccio nulla ==> la view riconoscerà che è stata richiesta una
      // ricerca e non c'è in request il risultato e segnalerà l'opportuno
      // messaggio all'utente
    }
    return risultatiRicerca;
  }

  /**
   * Valida i dati inseriti dall'utente per il report
   * @param request
   * @return
   */
  protected ValidationErrors validateReport(String indexIntermediario[], String rigaIniziale[],
  String rigaFinale[])
  {
    ValidationErrors errors=new ValidationErrors();
    int length=indexIntermediario==null?0:indexIntermediario.length;
    if (length==0)
    {
      errors.add("indexIntermediario",new ValidationError(UmaErrors.ERRORE_SELEZIONARE_ALMENO_UN_ELEMENTO));
    }
    else
    {
      for(int i=0;i<length;i++)
      {
        int index=new Integer(indexIntermediario[i]).intValue();
        String rigaInizialeStr=rigaIniziale[index].trim();
        long rigaInizialeLong=0;
        boolean completeCheck=true;
        try
        {
          if (Validator.isEmpty(rigaInizialeStr))
          {
              errors.add("rigaIniziale"+index,new ValidationError(UmaErrors.ERRORE_VAL_CAMPO_OBBLIGATORIO));
          }
          else
          {
            rigaInizialeLong=new Long(rigaInizialeStr).longValue();
            if (rigaInizialeLong<0 || rigaInizialeLong>9999)
            {
              completeCheck=false;
              errors.add("rigaIniziale"+index,new ValidationError(UmaErrors.ERRORE_VAL_VALORE_NON_VALIDO));
            }
          }
        }
        catch(Exception e)
        {
            completeCheck=false;
            errors.add("rigaIniziale"+index,new ValidationError(UmaErrors.ERRORE_VAL_VALORE_NON_VALIDO));
        }
        String rigaFinaleStr=rigaFinale[index];
        long rigaFinaleLong=0;
        try
        {
          if (Validator.isEmpty(rigaFinaleStr))
          {
              errors.add("rigaFinale"+index,new ValidationError(UmaErrors.ERRORE_VAL_CAMPO_OBBLIGATORIO));
          }
          else
          {
            rigaFinaleLong=new Long(rigaFinaleStr).longValue();
            if (rigaFinaleLong<0 || rigaFinaleLong>9999)
            {
              completeCheck=false;
              errors.add("rigaFinale"+index,new ValidationError(UmaErrors.ERRORE_VAL_VALORE_NON_VALIDO));
            }
            if (completeCheck)
            {
              if (rigaInizialeLong>rigaFinaleLong)
              {
                errors.add("rigaFinale"+index,new ValidationError(UmaErrors.ERRORE_VAL_RIGADA_INFERIORE_A_RIGAA));
              }
            }
          }
        }
        catch(Exception e)
        {
            completeCheck=false;
            errors.add("rigaFinale"+index,new ValidationError(UmaErrors.ERRORE_VAL_VALORE_NON_VALIDO));
        }
      }
    }
    return errors.size()==0?null:errors;
  }


  /**
   * Valida i dati inseriti dall'utente per la ricerca
   * @param request
   * @return
   */
  protected ValidationErrors validateRicerca(String istatProvincia,
                                      String anno,
                                      String idIntermediario,
                                      String dalFoglio,
                                      String alFoglio)
  {
    ValidationErrors errors=new ValidationErrors();
    if (Validator.isEmpty(istatProvincia))
    {
      errors.add("istatProvincia",new ValidationError(UmaErrors.ERRORE_VAL_CAMPO_OBBLIGATORIO));
    }
    if (Validator.isEmpty(anno))
    {
      errors.add("anno",new ValidationError(UmaErrors.ERRORE_VAL_CAMPO_OBBLIGATORIO));
    }
    else
    {
      try
      {
        long annoLong=new Long(anno).longValue();
        if (annoLong<1900 || annoLong>9999)
        {
          errors.add("anno",new ValidationError(UmaErrors.ERRORE_VAL_VALORE_NON_VALIDO));
        }
      }
      catch(Exception e)
      {
          errors.add("anno",new ValidationError(UmaErrors.ERRORE_VAL_VALORE_NON_VALIDO));
      }
    }
    if (Validator.isEmpty(idIntermediario))
    {
      errors.add("idIntermediario",new ValidationError(UmaErrors.ERRORE_VAL_CAMPO_OBBLIGATORIO));
    }

    long dalFoglioL=0;
    long alFoglioL=0;
    if (Validator.isEmpty(dalFoglio))
    {
      errors.add("idIntermediario",new ValidationError(UmaErrors.ERRORE_VAL_CAMPO_OBBLIGATORIO));
    }
    else
    {
      try
      {
        dalFoglioL=new Long(dalFoglio).longValue();
        if (dalFoglioL<1 || dalFoglioL>9999)
        {
          errors.add("dalFoglio",new ValidationError(UmaErrors.ERRORE_VAL_VALORE_NON_VALIDO));
        }
      }
      catch(Exception e)
      {
          errors.add("dalFoglio",new ValidationError(UmaErrors.ERRORE_VAL_VALORE_NON_VALIDO));
      }
    }

    if (Validator.isNotEmpty(alFoglio))
    {
      try
      {
        alFoglioL=new Long(alFoglio).longValue();
        if (alFoglioL<1 || alFoglioL>9999)
        {
          errors.add("alFoglio",new ValidationError(UmaErrors.ERRORE_VAL_VALORE_NON_VALIDO));
        }
        else
        {
          if (alFoglioL<dalFoglioL)
          {
            errors.add("alFoglio",new ValidationError(UmaErrors.ERRORE_VAL_ALFOGLIO_INFERIORE_A_DALFOGLIO));
          }
        }
      }
      catch(Exception e)
      {
          errors.add("alFoglio",new ValidationError(UmaErrors.ERRORE_VAL_VALORE_NON_VALIDO));
      }
    }
    return errors.size()==0?null:errors;
  }
%>
