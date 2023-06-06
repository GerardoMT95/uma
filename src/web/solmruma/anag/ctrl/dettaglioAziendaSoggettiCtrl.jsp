 <%@ page language="java"
     contentType="text/html"
     isErrorPage="true"
 %>

<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%

  String iridePageName = "dettaglioAziendaSoggettiCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  String validateUrl = "/anag/view/dettaglioAziendaSoggettiView.jsp";

  String errorPage = "/anag/view/dettaglioAziendaSoggettiView.jsp";

  String dettaglioURL = "/anag/view/dettaglioAziendaSoggettiView.jsp";

  it.csi.solmr.client.anag.AnagFacadeClient anagClient = new AnagFacadeClient();

  UmaFacadeClient umaClient = new UmaFacadeClient();

  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

  Validator validator = new Validator(validateUrl);

  Vector soggettiVector = (Vector)session.getAttribute("soggetti");



  if(request.getParameter("note")!= null){

        session.setAttribute("dettaglioURL",dettaglioURL);

        %>

          <jsp:forward page = "/anag/view/dettaglioAziendaNoteView.jsp" />

        <%

  }



  else{

  if(dittaVO!=null){

    if(soggettiVector==null){

      try{

        //soggettiVector = anagClient.getSoggetti(dittaVO.getIdAzienda(), new Date(System.currentTimeMillis()));

        Boolean storico = new Boolean(false);

        soggettiVector = anagClient.getSoggetti(dittaVO.getIdAzienda(), storico);

        session.setAttribute("soggetti",soggettiVector);

      }

      catch (Exception sex) 
      {

        ValidationErrors errors = new ValidationErrors();

        SolmrLogger.error(this, "Valore del messaggio: "+sex.getMessage());

        ValidationError error = new ValidationError(sex.getMessage());

        errors.add("error", error);

        request.setAttribute("errors", errors);

        request.getRequestDispatcher(errorPage).forward(request, response);

        return;

      }

    }

    %>

      <jsp:forward page = "/anag/view/dettaglioAziendaSoggettiView.jsp" />

    <%

    }

  }





%>



