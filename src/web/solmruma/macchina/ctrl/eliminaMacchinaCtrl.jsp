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
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String iridePageName = "eliminaMacchinaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  String url = "../layout/elencoMacchine.htm";

  SolmrLogger.debug(this, "   BEGIN eliminaMacchinaCtrl");

  ValidationException valEx = null;
  Validator validator = new Validator(url);
  ValidationErrors errors = new ValidationErrors();

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  UmaFacadeClient umaClient = new UmaFacadeClient();
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  Long idMacchina = null;

  try{
    if(request.getParameter("submit")!= null){
      SolmrLogger.debug(this,"HO CLICKATO CONFERMA!!!!!");
      //ho clickato "conferma"
      if(session.getAttribute("idMacchina")!=null)
        idMacchina = new Long(""+session.getAttribute("idMacchina"));
      
      SolmrLogger.debug(this,"eliminaMacchinaCtrl idMacchina: "+idMacchina);
      SolmrLogger.debug(this,"eliminaMacchinaCtrl provincia è: "+ruoloUtenza.getIstatProvincia());
            
      umaClient.eliminaMacchina(idMacchina, ruoloUtenza.getIstatProvincia());
      
      url = "../layout/elencoMacchine.htm";
      session.removeAttribute("currentPage");
      response.sendRedirect(url);
      SolmrLogger.debug(this, "   END eliminaMacchinaCtrl");
      return;
    }
    else if(request.getParameter("submit2")!=null){
      SolmrLogger.debug(this,"Chiudi...");
      url = "../layout/elencoMacchine.htm";
      response.sendRedirect(url);
      SolmrLogger.debug(this, "   END eliminaMacchinaCtrl");
      return;
    }
    else{

      Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
      DittaUMAVO dUMAVO = umaClient.findDittaVOByIdDitta(idDittaUma);

	  //controlli sul profilo utente
      SolmrLogger.debug(this,"ISTAT provincia del profilo utente: "+ruoloUtenza.getIstatProvincia());
      SolmrLogger.debug(this,"ISTAT provincia della ditta uma:    "+dUMAVO.getExtProvinciaUMA());

      if(ruoloUtenza.getIstatProvincia().length()==0 || !ruoloUtenza.getIstatProvincia().equals(dUMAVO.getExtProvinciaUMA())){
        ValidationError error = new ValidationError(""+UmaErrors.get("UTENTE_NON_AUTORIZZATO_ELIMINAZIONE_MACCHINA"));
        //SolmrLogger.debug(this,"eliminaMacchinaCtrl: "+""+UmaErrors.get("UmaErrors.UTENTE_NON_AUTORIZZATO_ELIMINAZIONE_MACCHINA"));
        errors.add("error", error);
        request.setAttribute("notifica", UmaErrors.get("UTENTE_NON_AUTORIZZATO_ELIMINAZIONE_MACCHINA"));
        //request.getRequestDispatcher(url).forward(request, response);
        response.sendRedirect(url);
        SolmrLogger.debug(this, "   END eliminaMacchinaCtrl");
        return;
      }
      //fine controlli sul profilo utente

      else{
        umaClient.isDittaUmaCessata(idDittaUma);
        umaClient.isDittaUmaBloccata(idDittaUma);
        if(request.getParameter("idMacchina")!=null && !request.getParameter("idMacchina").equals("")){
          SolmrLogger.debug(this," --------- idMacchina: "+request.getParameter("idMacchina"));
          idMacchina = new Long(request.getParameter("idMacchina"));
          
          MacchinaVO mVO=umaClient.getMacchinaById(idMacchina);
          
          if (mVO!=null && umaClient.isBloccoMacchinaImportataAnagrafe(mVO)) 
		      {  
		        it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::errorMessage!=null] utente non abilitato: "+it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
		        request.setAttribute("errorMessage",it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
		        %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
		        return;
		      }
          
          SolmrLogger.debug(this," --- CONTROLLI PRIMA DI EFFETTUARE L'ELIMINA");
          umaClient.isMacchinaInUtilizzo(idMacchina, idDittaUma);
          umaClient.selectAttestatoProprieta(idMacchina);
          umaClient.selectAssegnazioneCarburanteForMacchina(idMacchina);                              
          umaClient.isMacchinaInRottamazione(idMacchina);      
                       
          session.setAttribute("idMacchina", idMacchina);
          url = "../view/eliminaMacchinaView.jsp";
        }
      }
    }
  }catch(SolmrException ex){
    SolmrLogger.debug(this,"---------------------------------------------------------");
    SolmrLogger.debug(this," --- SolmrException in eliminaMacchinaCtrl ="+ex.getMessage());
    url = "../layout/elencoMacchine.htm";
    ValidationError error = new ValidationError(ex.getMessage());    
    errors.add("error", error);
    session.setAttribute("notifica", ex.getMessage());
    session.setAttribute("eliminaVar","eliminaVar");
    SolmrLogger.debug(this,"eliminaVar settato");
    //request.getRequestDispatcher(url).forward(request, response);
    //return;
    response.sendRedirect(url);
    SolmrLogger.debug(this, "   END eliminaMacchinaCtrl");
    return;
  }
  
  SolmrLogger.debug(this, "   END eliminaMacchinaCtrl");
%>
<jsp:forward page="<%=url%>"/>