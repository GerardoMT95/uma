 <%@ page language="java"
     contentType="text/html"
     isErrorPage="true"
 %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.SolmrConstants"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String iridePageName = "dettaglioAziendaControl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  String ricercaDittaUMAUrl= "/ditta/view/ricercaAzienda.jsp";
  String validateUrl = "/anag/view/dettaglioAziendaView.jsp";

  String dettaglioURL = "/anag/view/dettaglioAziendaView.jsp";

  UmaFacadeClient umaClient = new UmaFacadeClient();
  Validator validator = new Validator(validateUrl);

  ValidationException valEx = null;
  
  session.removeAttribute("annoCampagna");
  
  if(request.getParameter("inserisci.x") != null){
    String identificativoAz = request.getParameter("idAzienda");
    Long idAzienda = Long.decode(identificativoAz);
    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
    AnagAziendaVO anagAziendaVO = null;
    try {
      anagAziendaVO = umaClient.selezionaAzienda(idAzienda);
    }
    catch(SolmrException se) {
      ValidationErrors errors = new ValidationErrors();
      ValidationError error = new ValidationError(se.getMessage());
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher(validateUrl).forward(request, response);
    }
    session.setAttribute("anagAziendaVO",anagAziendaVO);
    %>
       <jsp:forward page = "/ditta/view/nuovaDittaUmaView.jsp" />
    <%
    //response.sendRedirect(request.getContextPath() + numeroDittaUMAUrl);
  }
  else if(request.getParameter("note")!= null)
  {
    session.setAttribute("dettaglioURL",dettaglioURL);
    %>
    <jsp:forward page = "/anag/view/dettaglioAziendaNoteView.jsp" />
    <%
  }
  // Arrivo dalla pagina precedente
  else
  {
    SolmrLogger.debug(this,"devo entrare nell'else del refresh dettagliooooooooooooooooo");
    String rd = request.getParameter("refreshDettaglio");
    SolmrLogger.debug(this,"refreshDettaglio: "+rd);
    if((request.getParameter("refreshDettaglio")!=null && request.getParameter("refreshDettaglio").equals("true"))
       || (session.getAttribute("refreshDettaglio")!=null && session.getAttribute("refreshDettaglio").equals("true")))
    {

      if(session.getAttribute("refreshDettaglio")!=null)
        session.removeAttribute("refreshDettaglio");

      DittaUMAAziendaVO dittaOldVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
      DittaUMAAziendaVO dittaNewVO = null;
      if(dittaOldVO!=null){
        try {
          dittaNewVO = new DittaUMAAziendaVO();
          dittaNewVO.setDittaUMA(dittaOldVO.getDittaUMA());
          dittaNewVO.setProvUMA(dittaOldVO.getProvUMA());
          dittaNewVO = umaClient.getDittaUMAAzienda(dittaNewVO);
          session.setAttribute("dittaUMAAziendaVO",dittaNewVO);
        }
        catch(SolmrException se) {
          ValidationErrors errors = new ValidationErrors();
          ValidationError error = new ValidationError(se.getMessage());
          errors.add("error", error);
          request.setAttribute("errors", errors);
          request.getRequestDispatcher(validateUrl).forward(request, response);
          return;
        }
      }
      else{
        ValidationErrors errors = new ValidationErrors();
        ValidationError error = new ValidationError("Errore di sistema");
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(validateUrl).forward(request, response);
        return;
      }

    }

    %>
     <jsp:forward page = "/anag/view/dettaglioAziendaView.jsp" />
    <%
  }
%>

