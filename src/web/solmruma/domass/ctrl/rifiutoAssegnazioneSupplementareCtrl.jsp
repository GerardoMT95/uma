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


<jsp:useBean id="frmAssegnazioneSupplementareVO" scope="request"
 class="it.csi.solmr.dto.uma.FrmAssegnazioneSupplementareVO">
  <jsp:setProperty name="frmAssegnazioneSupplementareVO" property="*" />
</jsp:useBean>


<%

  String iridePageName = "rifiutoAssegnazioneSupplementareCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "BEGIN rifiutoAssegnazioneSupplementareCtrl");
		  
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  String layoutViewUrl = "/domass/view/rifiutoAssegnazioneSupplementareView.jsp";
  String annullaUrl = "../layout/verificaAssegnazioneSupplementareSalvataBO.htm";
  String NEXT_PAGE="../layout/dettaglioAssegnazioniSupplementare.htm";

 
  Long idAssegnazioneCarburante = frmAssegnazioneSupplementareVO.getIdAssCarbLong();
  SolmrLogger.debug(this, "-- frmAssegnazioneSupplementareVO.getIdAssCarbLong() ="+idAssegnazioneCarburante);
  if(idAssegnazioneCarburante == null || idAssegnazioneCarburante  == 0L){
	String idAssegnazioneCarburanteStr = request.getParameter("idAssCarburante");
	SolmrLogger.debug(this, "-- idAssegnazioneCarburanteStr ="+idAssegnazioneCarburanteStr);
	if(idAssegnazioneCarburanteStr != null){
		idAssegnazioneCarburante = Long.parseLong(idAssegnazioneCarburanteStr);
		SolmrLogger.debug(this, "-- idAssegnazioneCarburante ="+idAssegnazioneCarburante);
	}
  }
  AssegnazioneCarburanteVO assCarbVO = null;
 
  if (request.getParameter("idAssegnazioneCarburante") != null){
    SolmrLogger.debug(this,"request.getParameter(\"idAssegnazioneCarburante\") != null");
    idAssegnazioneCarburante = new Long( request.getParameter("idAssegnazioneCarburante") );
  }
  else{
    SolmrLogger.debug(this,"request.getParameter(\"idAssegnazioneCarburante\") == null");
  }
  SolmrLogger.debug(this,"idAssegnazioneCarburante: " + idAssegnazioneCarburante);

  if(request.getParameter("annulla.x") != null){
    SolmrLogger.debug(this,"-- CASO ANNULLA del RIFIUTA Assegnazione supplementare");
    response.sendRedirect(annullaUrl);
  }


  if(request.getParameter("conferma.x") != null){
	SolmrLogger.debug(this,"-- CASO CONFERMA del RIFIUTA Assegnazione supplementare");

    ValidationErrors errors = new ValidationErrors();
    String motivazione="";
    if ( request.getParameter("note") != null){
      SolmrLogger.debug(this,"-- Caso NOTE valorizzate");	
      motivazione = request.getParameter("note");
      SolmrLogger.debug(this,"--- motivazione RIFIUTA ASSEGNAZIONE SUPPLEMENTARE: "+motivazione);

      if (motivazione!=null && motivazione.trim().length()==0)
      {
        SolmrLogger.debug(this,"motivazione!=null && motivazione.length()==0");
        errors.add("note",new ValidationError("Inserire il motivo del rifiuto"));
      }
      if (motivazione!=null && motivazione.trim().length()>3500)
      {
        SolmrLogger.debug(this,"motivazione!=null && motivazione.trim().length()>3500");
        errors.add("note",new ValidationError("Campo troppo lungo. Massimo 3500 caratteri"));
      }
      if (errors.size()!=0){
    	SolmrLogger.debug(this,"---- if (errors!=null)");    	
    	assCarbVO = umaFacadeClient.getAssegnazioneCarburante(idAssegnazioneCarburante);
    	assCarbVO.setNoteIstruttoria(motivazione);
    	session.setAttribute("DomandaAssegnazioneSupplementare",assCarbVO);
    	
        SolmrLogger.debug(this,"\n\n\n\n\n\n\nerrors: "+errors);
        SolmrLogger.debug(this,"errors.size(): "+errors.size());
        request.setAttribute("errors",errors);
        %>
          <jsp:forward page ="<%=layoutViewUrl%>" />
        <%
      }

    }    
    assCarbVO = umaFacadeClient.getAssegnazioneCarburante(idAssegnazioneCarburante);
    assCarbVO.setNoteIstruttoria(motivazione);
    assCarbVO.setIdUtenteAgg(ruoloUtenza.getIdUtente());

    Long idDomAss = assCarbVO.getIdDomandaAssegnazione();
    SolmrLogger.debug(this,"--- idDomAss: "+idDomAss);
    // (serve per la pagina di dettaglio successiva)
    session.setAttribute("idDomAss", idDomAss);

    SolmrLogger.debug(this,"umaFacadeClient.rifiutaDomandaAssegnazione (da.getIdDomandaAssegnazione(), da.getNote(), profile)");
    umaFacadeClient.rifiutaDomandaAssegnazioneSupplementare(assCarbVO);

    
    SolmrLogger.debug(this, "-- Torno sulla pagina del dettaglio Assegnazioni Supplementari");
    response.sendRedirect(NEXT_PAGE);
    
    return;
  } // FINE CASO CONFERMA


  assCarbVO = umaFacadeClient.getAssegnazioneCarburante(idAssegnazioneCarburante);
  session.setAttribute("DomandaAssegnazioneSupplementare",assCarbVO);

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
