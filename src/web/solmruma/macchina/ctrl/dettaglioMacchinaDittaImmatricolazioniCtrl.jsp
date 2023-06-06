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
  private static final String VIEW="/macchina/view/dettaglioMacchinaDittaImmatricolazioniView.jsp";
  private static final String NUOVA="/macchina/ctrl/nuovaImmatricolazioneCtrl.jsp";
  private static final String DETTAGLIO="../layout/dettaglioMacchinaDittaImmatricolazioni.htm";
  private static final String CONFERMAELIMINA="../../layout/confermaEliminaUltimaMovimentazione.htm";
  private static final String VENDITAFUORIREG="/macchina/ctrl/venditaFuoriRegioneCtrl.jsp";
%>
<%

  String iridePageName = "dettaglioMacchinaDittaImmatricolazioniCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  try
{
  UmaFacadeClient umaClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  Long idMacchina = null;
  Long idMovimentiTarga = null;
  ValidationErrors errors = new ValidationErrors();

  MacchinaVO mavo = new MacchinaVO();

  if(session.getAttribute("common") instanceof MacchinaVO)
  {
    mavo = (MacchinaVO)session.getAttribute("common");
  }
  if(request.getParameter("idMacchina") != null)
  {
    idMacchina=new Long(((String)request.getParameter("idMacchina")).trim());
    mavo= umaClient.getMacchinaById(idMacchina);
    session.setAttribute("common", mavo);
  }

  if(request.getParameter("idMovimentiTarga") != null)
  {
    idMovimentiTarga=new Long((String)request.getParameter("idMovimentiTarga"));
    SolmrLogger.debug(this,"############### idMovimentiTarga : "+idMovimentiTarga);
  }
  if(request.getAttribute("idMovimentiTarga") != null)
  {
    idMovimentiTarga=new Long((String)request.getAttribute("idMovimentiTarga"));
  }

  if (request.getParameter("nuova")!=null)
  {
    SolmrLogger.debug(this,"Goin' in "+NUOVA);
    DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
    Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

    umaClient.isDittaUmaBloccata(idDittaUma);
    umaClient.isDittaUmaCessata(idDittaUma);
    umaClient.isMacchinaInCarico(mavo.getIdMacchinaLong(), idDittaUma);

    if(mavo.getIdMatriceLong()==null)
      isMacchinaConTarga(errors, umaClient, mavo.getDatiMacchinaVO());
    if (errors!=null && errors.size()>0)
    {
      request.setAttribute("errors",errors);
       %><jsp:forward page="<%=VIEW%>" /><%
         return;
    }
    SolmrLogger.debug(this,"Goin' in "+NUOVA);
    //  response.sendRedirect(NUOVA);
    %><jsp:forward page="<%=NUOVA%>" /><%
      return;
  }

  if (request.getParameter("venditaFuoriReg")!=null)
  {
    SolmrLogger.debug(this,"Goin' in "+VENDITAFUORIREG);
    DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
    Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
    idMacchina = mavo.getIdMacchinaLong();

    umaClient.isDittaUmaBloccata(idDittaUma);
    SolmrLogger.debug(this,"################################## idMacchina : "+idMacchina);
    SolmrLogger.debug(this,"################################## idDittaUma : "+idDittaUma);
    SolmrLogger.debug(this,"################################## dittaUMAAziendaVO.getProvUMA() : "+dittaUMAAziendaVO.getProvUMA());

    umaClient.isMacchinaNonInCarico(mavo.getIdMacchinaLong());

    if (errors!=null && errors.size()>0)
    {
      request.setAttribute("errors",errors);
     %><jsp:forward page="<%=VIEW%>" /><%
       return;
    }
    SolmrLogger.debug(this,"Goin' in "+VENDITAFUORIREG);
  %><jsp:forward page="<%=VENDITAFUORIREG%>" /><%
    return;
  }

  if (request.getParameter("deleteUltimo")!=null)
  {
    DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
    Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

    MovimentiTargaVO curr = umaClient.getUltimaMovimentazioneByIdMacchina(mavo.getIdMacchinaLong());

    SolmrLogger.debug(this,"######################################");
    SolmrLogger.debug(this,"curr "+curr);
    SolmrLogger.debug(this,"######################################");

    if(curr==null)
    {
      throwValidation("Non è stata trovata nessuna movimentazione valida", VIEW);
      return;
    }
    umaClient.isDittaUmaBloccata(idDittaUma);
    umaClient.isDittaUmaCessata(idDittaUma);
    umaClient.isMacchinaInCarico(mavo.getIdMacchinaLong(), idDittaUma);

    int idMov = curr.getIdMovimentazioneLong().intValue();
    if(idMov != 5 && idMov != 6 && idMov != 7 && idMov != 8 && idMov != 9)
    {
      errors.add("error", new ValidationError(""+UmaErrors.get("NO_DELETE_LAST_MOV")));
    }
    if(idMov != 9 && (!curr.getIdProvincia().equals(dittaUMAAziendaVO.getProvUMA())
                      || !curr.getDittaUma().equals(dittaUMAAziendaVO.getDittaUMAstr())))
    {
      errors.add("error", new ValidationError(""+UmaErrors.get("LAST_MOV_DITTA_DIVERSA")));
    }


    if (errors!=null && errors.size()>0)
    {
      request.setAttribute("errors",errors);
       %><jsp:forward page="<%=VIEW%>" /><%
         return;
    }
    response.sendRedirect(CONFERMAELIMINA);
    return;
  }

  %><jsp:forward page="<%=VIEW%>" /><%
    }
    catch(SolmrException ex)
    {
      throwValidation(ex.getMessage(), VIEW);
    }
/*    catch(Exception e)
    {
      throwValidation("Si è verificato un errore di sistema", VIEW);
    }*/
%>

<%!
  public static final String ASM = "ASM";
  public static final String RIMORCHIO = "R";
  public static final String MAO_TRAINATA = "010";
  public static final String CARRO_UNIFEED = "012";

private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException("Eccezione : "+msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}
private void isMacchinaConTarga(ValidationErrors errors,UmaFacadeClient umaClient, DatiMacchinaVO datiMacchinaVO) throws ValidationException
{
  final double LIMITE_LORDO=15;

  String tipoTarga=null;

  final String STRADALERA = "Stradale RA";
  SolmrLogger.debug(this,"1tipoTarga: "+tipoTarga);
  //Tipo Genere = RIMORCHIO
  if (RIMORCHIO.equals(datiMacchinaVO.getCodBreveGenereMacchina().trim()))
  {
    if (MAO_TRAINATA.equals(datiMacchinaVO.getCodBreveCategoriaMacchina().trim()))
    {
      tipoTarga=null;
    }
    else
    {
      if (CARRO_UNIFEED.equals(datiMacchinaVO.getCodBreveCategoriaMacchina().trim()))
      {
        tipoTarga=null;
      }
      else
      {
        if(tipoTarga==null)
        {
          if (datiMacchinaVO.getLordoDouble().doubleValue() <= LIMITE_LORDO)
          {
            tipoTarga=null;
          }
          else
          {
            tipoTarga=STRADALERA;
          }
        }
      }
    }
  }
  if (ASM.equals(datiMacchinaVO.getCodBreveGenereMacchina()))
  {
    SolmrLogger.debug(this,ASM.equals(datiMacchinaVO.getCodBreveGenereMacchina()));
    tipoTarga=null;
  }
  SolmrLogger.debug(this,"3tipoTarga: "+tipoTarga);
  if(tipoTarga==null)
  {
    errors.add("error", new ValidationError(""+UmaErrors.get("NO_ASSEGN_TARGA")));
  }
}

%>