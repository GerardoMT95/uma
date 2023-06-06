<%@ page language="java"
         contentType="text/html"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.SolmrConstants" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%

  String iridePageName = "rifiutoAssegnazioneCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  String layoutViewUrl = "/domass/view/rifiutoAssegnazioneView.jsp";
  String annullaUrl = "../layout/verificaAssegnazioneSalvataBO.htm";  
  String confermaUrl = "/domass/ctrl/assegnazioniCtrl.jsp";

  Long idDomAss=null;
  DomandaAssegnazione da;
  if ( request.getParameter("idDomAss") != null){
    SolmrLogger.debug(this,"request.getParameter(\"idDomAss\") != null");
    idDomAss = new Long( request.getParameter("idDomAss") );
  }
  else{
    SolmrLogger.debug(this,"request.getParameter(\"idDomAss\") == null");
  }
  SolmrLogger.debug(this,"idDomAss: " + idDomAss);

  if(request.getParameter("annulla.x") != null){
    SolmrLogger.debug(this,"\\\\\\\\\\annulla");
    response.sendRedirect(annullaUrl);
  }


  if(request.getParameter("conferma.x") != null){
    SolmrLogger.debug(this,"\\\\\\\\\\Conferma");

    ValidationErrors errors = new ValidationErrors();
    String motivazione="";
    if ( request.getParameter("note") != null){
      motivazione = request.getParameter("note");
      SolmrLogger.debug(this,"motivazione: "+motivazione);

      if (motivazione!=null && motivazione.length()==0)
      {
        SolmrLogger.debug(this,"motivazione!=null && motivazione.length()==0");
        errors.add("note",new ValidationError("Inserire il motivo del rifiuto"));
      }
      if (motivazione!=null && motivazione.length()>512)
      {
        SolmrLogger.debug(this,"motivazione!=null && motivazione.length()>512");
        errors.add("note",new ValidationError("Campo troppo lungo. Massimo 512 caratteri"));
      }
      if (errors.size()!=0){
        SolmrLogger.debug(this,"      if (errors!=null)");
        da = (DomandaAssegnazione) umaFacadeClient.findDomAssByPrimaryKey(idDomAss);
        da.setNote(motivazione);
        SolmrLogger.debug(this,"      dopo umaFacadeClient.findDomAssByPrimaryKey");
        request.setAttribute("DomandaAssegnazione",da);
        SolmrLogger.debug(this,"\n\n\n\n\n\n\nerrors: "+errors);
        SolmrLogger.debug(this,"errors.size(): "+errors.size());
        request.setAttribute("errors",errors);
        %>
          <jsp:forward page ="<%=layoutViewUrl%>" />
        <%
      }

    }
    SolmrLogger.debug(this,"Dopo request.getParameter(\"note\") != null");

    da = umaFacadeClient.findDomAssByPrimaryKey(idDomAss);
    da.setNote(motivazione);
    da.setUtenteAggiornamento( ruoloUtenza.getIdUtente().intValue() );

    CodeDescr cdDomAss = new CodeDescr();
    cdDomAss.setCode(new Integer(SolmrConstants.ID_STATO_DOMANDA_ANNULLATA));
    cdDomAss.setDescription(SolmrConstants.DESC_STATO_DOMANDA_ANNULLATA);

    SolmrLogger.debug(this,"umaFacadeClient.rifiutaDomandaAssegnazione (da.getIdDomandaAssegnazione(), da.getNote(), profile)");
    umaFacadeClient.rifiutaDomandaAssegnazione (da.getIdDomandaAssegnazione(), da.getNote(), ruoloUtenza);

    %>
      <jsp:forward page ="<%=confermaUrl%>" />
    <%
  }


  da = umaFacadeClient.findDomAssByPrimaryKey(idDomAss);
  request.setAttribute("DomandaAssegnazione", da);

  %>
    <jsp:forward page ="<%=layoutViewUrl%>" />
  <%
  SolmrLogger.debug(this,"rifiutoAssegnazioneCtrl.jsp -  FINE PAGINA");
%>
<%!
  private void throwValidation(String msg,String validateUrl) throws ValidationException
  {
    ValidationException valEx = new ValidationException("Errore: eccezione="+msg,validateUrl);
    valEx.addMessage(msg,"exception");
    throw valEx;
  }
%>
