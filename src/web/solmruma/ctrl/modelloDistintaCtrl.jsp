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
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.comune.IntermediarioVO" %>
<%@ page import="it.csi.papua.papuaserv.presentation.ws.profilazione.axis.UtenteAbilitazioni" %>

<%!
  private static final String VIEW="../view/modelloDistintaView.jsp";
%>
<%
  String iridePageName = "modelloDistintaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%
  try  {
    UmaFacadeClient umaClient = new UmaFacadeClient();
    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
    UtenteAbilitazioni utenteAbilitazioni = (UtenteAbilitazioni) session.getAttribute("utenteAbilitazioni");

    ValidationErrors errors=new ValidationErrors();
    String strDataInizio = request.getParameter("dataInizioValidita");
    String strDataFine = request.getParameter("dataFineValidita");
    String strOraInizio = request.getParameter("oraInizio");
    String strOraFine = request.getParameter("oraFine");
    String provUMA = request.getParameter("provUMA");
    String idIntermediario = request.getParameter("idIntermediario");
    ValidationError vError = null;

    if (!ruoloUtenza.isUtenteIntermediario()) 
    {
      session.setAttribute("erroreUtente", "Utente non abilitato alla funzione richiesta");
      response.sendRedirect("../layout/stampaElenchi.htm");
      return;
    } 
    else 
    {
      Vector province=umaClient.getProvincieByRegione(it.csi.solmr.etc.SolmrConstants.ID_REGIONE);
      int length=province==null?0:province.size();

      Long idIntermediarioCorrente = utenteAbilitazioni.getEnteAppartenenza().getIntermediario().getIdIntermediario();
      IntermediarioVO listaIntermediari[]=umaClient.serviceGetListaIntermediari(idIntermediarioCorrente,null,
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


      if (request.getParameter("conferma") != null) {
        if (!Validator.isNotEmpty(provUMA)) {
          errors.add("provUMA",new ValidationError("La provincia deve essere valorizzata"));
        }
        Validator.validateDateAll(strDataInizio, "dataInizioValidita", "data inizio validita", errors, true, false);
        Validator.validateDateAll(strDataFine, "dataFineValidita", "data fine validita'", errors, true, false);
        Validator.validateTime(strOraInizio, "oraInizio", "ora Inizio", errors, false);
        Validator.validateTime(strOraFine, "oraFine", "ora Fine", errors, false);
        if (Validator.isEmpty(idIntermediario))
        {
          errors.add("idIntermediario",new ValidationError(UmaErrors.ERRORE_VAL_CAMPO_OBBLIGATORIO));
        }
        if (errors.size()!=0) {
          request.setAttribute("errors", errors);
        }
      }
    }
  }
  catch(Exception e)  {
    ValidationErrors errors=new ValidationErrors();
    errors.add("error",new ValidationError(e.getMessage()));
    request.setAttribute("errors",errors);
  }
%>
<jsp:forward page="<%=VIEW%>"/>

