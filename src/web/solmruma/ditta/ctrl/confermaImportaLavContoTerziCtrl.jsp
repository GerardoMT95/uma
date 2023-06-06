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
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.anag.AnagErrors" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<jsp:useBean id="serraVO" scope="page"
             class="it.csi.solmr.dto.uma.SerraVO">
  <jsp:setProperty name="serraVO" property="*" />
</jsp:useBean>
<%

  String iridePageName = "confermaImportaLavContoTerziCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  UmaFacadeClient umaClient = new UmaFacadeClient();
  String url="/ditta/ctrl/elencoSerreCtrl.jsp";
  String viewUrl="/ditta/view/confermaImportaLavContoTerziView.jsp";
  String elencoCtrl="/ditta/ctrl/elencoLavContoTerziCtrl.jsp";
  //String elencoBisCtrl="/ditta/ctrl/elencoSerreBisCtrl.jsp";
  String elencoHtm="../layout/elencoLavContoTerzi.htm";
  //String elencoBisHtm="../layout/elencoSerreBis.htm";
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  SolmrLogger.debug(this,"\n\n\n\n\n####################");
  SolmrLogger.debug(this,"request.getParameter(\"idSerra\"): "+request.getParameter("idSerra"));


  String validateUrl=elencoCtrl;
  

  if (request.getParameter("conferma.x")!=null)
  {
    SolmrLogger.debug(this,"conferma.x");
    // Importa lavorazioniii
    Long idSerra=null;
    try
    {
      DittaUMAAziendaVO dittaUma = (DittaUMAAziendaVO)request.getSession().getAttribute("dittaUMAAziendaVO");
      dittaUma.getIdAzienda();
      	
      SolmrLogger.debug(this,"SONO IN CONFERMA DI conferaImprtaLavContoTerziCtrl...");
      AnnoCampagnaVO annoCampagna= (AnnoCampagnaVO)session.getAttribute("annoCampagna");
      SolmrLogger.debug(this,"annoCampagna vale: "+annoCampagna);
      if(annoCampagna!=null &&!StringUtils.isStringEmpty(annoCampagna.getAnnoCampagna()) ){
      	SolmrLogger.debug(this,"PRIMA di chiamare findLavAPreventivo....");
      	Vector vettIdLavPrev= umaClient.findLavAPreventivo(dittaUma.getIdAzienda(),annoCampagna.getAnnoCampagna());
      	SolmrLogger.debug(this,"DOPO findLavAPreventivo....");
      	if(vettIdLavPrev!=null && vettIdLavPrev.size()==0){
      			SolmrLogger.debug(this,"\n\n\n#################forwardUrl: "+elencoCtrl);
    			session.setAttribute("notifica","L''azienda non risulta essere stata indicata come contoterzista in nessun preventivo");
    			//verificaCondizioniPulsanteImportaLav(request,umaClient);
    			response.sendRedirect(elencoHtm);
    			//response.sendRedirect(elencoCtrl);
    			
    			return;
      	}else{
      		// procedo con l'elaborazione
      		/*Long idCampagna=null;
      		if(vettIdLavPrev.size()>0){
      			LavContoTerziVO elem =(LavContoTerziVO)vettIdLavPrev.get(0);
      			idCampagna= elem.getIdCampagnaCT();
      		}
      		annoCampagna.setExtIdUtenteAggiornamento(profile.getIdUtente());
      		annoCampagna.setId_campagnaContoTerzisti(idCampagna);*/
      		
      		// Vado a trovare tutto il recordi di db_campagna
      		Vector vett= umaClient.findAnniCampagnaByIdDittaUma(dittaUma.getIdDittaUMA(),annoCampagna.getAnnoCampagna(), SolmrConstants.VERSO_LAVORAZIONI_E);
      		AnnoCampagnaVO annoCampagnaDaCess=null;
      		if(vett!=null && vett.size()>0){
      			annoCampagnaDaCess= (AnnoCampagnaVO)vett.get(0);
      			annoCampagnaDaCess.setExtIdUtenteAggiornamento(ruoloUtenza.getIdUtente());
      		} 
      		annoCampagna.setExtIdUtenteAggiornamento(ruoloUtenza.getIdUtente());
      		
      		SolmrLogger.debug(this,"PRIMA di chiamare importaLavorazioniContoTerzi....");
      		umaClient.importaLavorazioniContoTerzi(dittaUma.getIdDittaUMA(), annoCampagna, annoCampagnaDaCess,dittaUma.getIdAzienda());
      		SolmrLogger.debug(this,"DOPO importaLavorazioniContoTerzi....");
      		SolmrLogger.debug(this,"\n\n\n#################forwardUrl: "+elencoCtrl);
    		session.setAttribute("notifica","Operazione eseguita con successo");
    		//verificaCondizioniPulsanteImportaLav(request,umaClient);
    		response.sendRedirect(elencoHtm);
    		
      	}
      }
    }
    catch(Exception e)
	      {
	      	SolmrLogger.debug(this,"errorre... "+e.getMessage());
	        throwValidation(e.getMessage(),validateUrl);
	      }

    String forwardUrl=elencoHtm;
   

    SolmrLogger.debug(this,"\n\n\n#################forwardUrl: "+forwardUrl);
    response.sendRedirect(forwardUrl);
    return;
  }
  else{
    if (request.getParameter("annulla.x")!=null)
    {
      SolmrLogger.debug(this,"annulla.x");
      //verificaCondizioniPulsanteImportaLav(request,umaClient);
      response.sendRedirect(elencoHtm);
      return;
    }
    else{
      SolmrLogger.debug(this,"visualizza");
      %>
      <jsp:forward page="<%=viewUrl%>"/>
      <%
    }
  }
%>
<%!
private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException(msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}





%>
