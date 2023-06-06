<%@ page language="java"
         contentType="text/html"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.SolmrConstants" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%!
  public static final String VIEW_URL="/domass/view/dettaglioVerificaAssegnazioneView.jsp";
  public static final String ANNULLA_URL = "/domass/ctrl/annulloAssegnazioneCtrl.jsp";
%>
<%

  String iridePageName = "dettaglioVerificaAssegnazioneCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  try
  {

    Long idDomAss = null;
    if ( request.getParameter("idDomAss")!=null ){
      idDomAss = new Long(request.getParameter("idDomAss"));
    }

    UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
    DomandaAssegnazione da = umaFacadeClient.findDomAssByPrimaryKey(idDomAss);

    Long idDittaUma = new Long(da.getIdDitta());
    GregorianCalendar greg = new GregorianCalendar();
    greg.setTime(da.getDataRiferimento());
    long anno = greg.get(GregorianCalendar.YEAR);

    //caricamento dettaglioVerificaAssegnazioneCtrl
    Vector assegnazioniCarburante=umaFacadeClient.getAssegnazioniCarburante(idDomAss,"B");
    Vector consumiRimanenze=umaFacadeClient.getConsumiRimanenze(idDomAss);    
    DomandaAssegnazione acconto=umaFacadeClient.findAccontoNonAnnullatoByIdDomandaBase(idDomAss.longValue());
    if (acconto!=null)
    {
	  Vector assegnazioneAcconto=umaFacadeClient.getAssegnazioniCarburante(acconto.getIdDomandaAssegnazione(),"B");
      request.setAttribute("assegnazioneAcconto",assegnazioneAcconto);
      request.setAttribute("acconto",acconto);
      
	    int iSize=assegnazioneAcconto==null?0:assegnazioneAcconto.size();
	    //if (iSize==1)
	    if (iSize!=0)
	    {
	      AssegnazioneCarburanteVO assegnazioneCarburanteVO= ((AssegnazioneCarburanteAggrVO)assegnazioneAcconto.get(0)).getAssegnazioneCarburante();
          UtenteIrideVO utenteIrideVO=umaFacadeClient.getUtenteIride(assegnazioneCarburanteVO.getIdUtenteAgg());
	      request.setAttribute("accontoUtenteIrideVO",utenteIrideVO);
	    }
      
      
    }
    Vector utentiIride=new Vector();
    Vector utentiIrideConsRim=new Vector();

    int iSize=assegnazioniCarburante==null?0:assegnazioniCarburante.size();
    //if (iSize==1)
    if (iSize!=0)
    {
      AssegnazioneCarburanteVO assegnazioneCarburanteVO= ((AssegnazioneCarburanteAggrVO)assegnazioniCarburante.get(0)).getAssegnazioneCarburante();
      try
      {
        UtenteIrideVO utenteIrideVO=umaFacadeClient.getUtenteIride(assegnazioneCarburanteVO.getIdUtenteAgg());
        utentiIride.add(utenteIrideVO);
      }
      catch(Exception e)
      {
        utentiIride.add(new UtenteIrideVO());
      }
    }

    iSize=consumiRimanenze==null?0:consumiRimanenze.size();
    if (iSize!=0)
    {
      ConsumoRimanenzaVO consumoRimanenzaVO= (ConsumoRimanenzaVO)consumiRimanenze.get(0);
      try
      {
        UtenteIrideVO utenteIrideVO=umaFacadeClient.getUtenteIride(consumoRimanenzaVO.getIdUtenteAgg());
        utentiIrideConsRim.add(utenteIrideVO);
      }
      catch(Exception e)
      {
        utentiIrideConsRim.add(new UtenteIrideVO());
      }
    }

    request.setAttribute("utentiIride",utentiIride);
    request.setAttribute("utentiIrideConsRim",utentiIrideConsRim);
    request.setAttribute("assegnazioniCarburante",assegnazioniCarburante);
    request.setAttribute("consumiRimanenze",consumiRimanenze);

    if (request.getParameter("annulla.x")!=null)
    {
          %><jsp:forward page="<%=ANNULLA_URL%>" /><%
          return;
    }

  }
  catch(SolmrException e)
  {
    ValidationErrors errors=new ValidationErrors();
    errors.add("error",new ValidationError(e.getMessage()));
    request.setAttribute("errors",errors);
  }
  /*catch(Exception e)
  {
    ValidationErrors errors=new ValidationErrors();
    errors.add("error",new ValidationError("Si è verificato un errore di sistema"));
    request.setAttribute("errors",errors);
  }*/
%>

<jsp:forward page ="<%=VIEW_URL%>" />