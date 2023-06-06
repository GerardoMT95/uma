<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.etc.uma.*"%>
<%!
   private static final String attestazioniConfermaUrl = "/macchina/ctrl/attestazioniNewConfermaCtrl.jsp";
   private static final String elencoAttestazioniUrl = "/macchina/ctrl/attestazioniDittaCtrl.jsp";
   private static final String confermaInserimentoComproprietariUrl = "/macchina/view/confermaInserimentoComproprietariView.jsp";
%>
<%

  String iridePageName = "confermaInserimentoComproprietariCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

   try{
     SolmrLogger.debug(this,"ConfermaInserimentoComproprietariCtrl.jsp - Begin");

     ValidationErrors errors = new ValidationErrors();

     SolmrLogger.debug(this,"request.getParameter(\"conferma\"): "+request.getParameter("conferma"));
     SolmrLogger.debug(this,"request.getParameter(\"annulla\"): "+request.getParameter("annulla"));

     HashMap common2 = (HashMap) session.getAttribute("common2");
     String operazione = (String)common2.get("operazione");
     if( request.getParameter("conferma") != null){
       SolmrLogger.debug(this,"confermaInserimentoComproprietariCtrl - Inserimento attestazione di proprietà");
       SolmrLogger.debug(this,"attestazioniConfermaUrl: "+attestazioniConfermaUrl);
       %>
          <jsp:forward page="<%=attestazioniConfermaUrl%>"/>
       <%
       return;
     }

     SolmrLogger.debug(this,"operazione: "+operazione);
     if("inserisci".equalsIgnoreCase(operazione)){
       SolmrLogger.debug(this,"if(operazione.equalsIgnoreCase(\"inserisci\"))");
       %>
          <jsp:forward page="<%=attestazioniConfermaUrl%>"/>
       <%
       return;
     }

     if(request.getParameter("annulla") != null) {
       SolmrLogger.debug(this,"elencoAttestazioniUrl: "+elencoAttestazioniUrl);
       %>
          <jsp:forward page="<%=elencoAttestazioniUrl%>"/>
       <%
       return;
     }

     SolmrLogger.debug(this,"Redirect su view");
     %>
      <jsp:forward page="<%=confermaInserimentoComproprietariUrl%>"/>
     <%
   }catch(Exception ex){
     ValidationErrors errors = new ValidationErrors();
     errors.add("error", new ValidationError(ex.getMessage()));
     request.setAttribute("errors", errors);
     %>
       <jsp:forward page="<%= confermaInserimentoComproprietariUrl %>"/>
     <%
     return;
   }
%>
