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
<%

  String iridePageName = "modificaMatriciCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


   UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

   String modificaMatriceUrl = "/macchina/view/modificaMatriciView.jsp";
   String listaMatriciUrl = "/macchina/view/listaMatriciView.jsp";
   String confermaModificaMatriciOmologazioneUrl = "/macchina/view/confermaModificaMatriciOmologazioneView.jsp";
   String modificaMatriciOkView = "/macchina/view/modificaMatriciOkView.jsp";
   String ricercaMatriceUrl = "/macchina/view/ricercaMatriceView.jsp";

   ValidationErrors errors = new ValidationErrors();
   if(request.getParameter("salva") != null) {
     MatriceVO modificaMatriceVO = (MatriceVO)session.getAttribute("matriceVO");
     // Recupero i parametri modificati
     String tipoMacchina = request.getParameter("tipoMacchina");
     String numeroOmologazione = request.getParameter("numeroOmologazione");
     String tipiAlimentazione = request.getParameter("tipiAlimentazione");
     String potenzaCV = request.getParameter("potenzaCV");
     String potenzaKW = request.getParameter("potenzaKW");
     String consumoOrario = request.getParameter("consumoOrario");
     String tipiTrazione = request.getParameter("tipiTrazione");
     String nazionalita = request.getParameter("tipiNazionalita");
     String illuminazione = request.getParameter("illuminazione");
     // Setto i nuovi valori all'interno del VO
     modificaMatriceVO.setTipoMacchina(tipoMacchina);
     modificaMatriceVO.setNumeroOmologazione(numeroOmologazione);
     modificaMatriceVO.setTipiAlimentazione(tipiAlimentazione);
     modificaMatriceVO.setIdAlimentazione(tipiAlimentazione);
     modificaMatriceVO.setPotenzaCV(potenzaCV);
     modificaMatriceVO.setPotenzaKW(potenzaKW);
     modificaMatriceVO.setConsumoOrario(consumoOrario);
     modificaMatriceVO.setTipiTrazione(tipiTrazione);
     modificaMatriceVO.setIdTrazione(tipiTrazione);
     modificaMatriceVO.setTipiNazionalita(nazionalita);
     modificaMatriceVO.setIdNazionalita(nazionalita);
     modificaMatriceVO.setIlluminazione(illuminazione);

     // Metto l'oggetto in sessione
     session.removeAttribute("matriceVO");
     session.setAttribute("matriceVO",modificaMatriceVO);

     // Effettuo la validazione dei dati
     errors = modificaMatriceVO.validateModificaMatrice();
     // Se si sono verificati degli errori li visualizzo
     if(errors != null && errors.size() > 0) {
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(modificaMatriceUrl).forward(request, response);
       return;
     }
     // Controllo che non esista un altro record con lo stesso numero omologazione
     boolean result = false;
     try {
       result = umaFacadeClient.checkMatriceAttivaForNumeroOmologazioneExceptItself(modificaMatriceVO.getNumeroOmologazione(),
                                                                                    modificaMatriceVO.getIdMatriceLong());
     }
     catch(SolmrException se) {
       ValidationError error = new ValidationError(se.getMessage());
       errors.add("error",error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(modificaMatriceUrl).forward(request, response);
       return;
     }
     // Se esiste avviso l'utente e lo mando ad una pagina di warning
     if(result) {
       String messaggio = (String)UmaErrors.get("WARNING_MATRICE_ESISTENTE_OMOLOGAZIONE");
       %>
          <jsp:forward page="<%= confermaModificaMatriciOmologazioneUrl %>">
          <jsp:param name="messaggio" value="<%=messaggio%>"/>
          </jsp:forward>
       <%
     }
     // Altrimenti effettuo la modifica dei dati
     try {
       umaFacadeClient.updateMatrice(modificaMatriceVO);
     }
     catch(SolmrException se) {
       ValidationError error = new ValidationError(se.getMessage());
       errors.add("error",error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(modificaMatriceUrl).forward(request, response);
       return;
     }
     // E mando l'utente alla pagina di conferma modifica dati....
     %>
        <jsp:forward page="<%= modificaMatriciOkView %>"/>
     <%
   }
   // L'utente ha selezionato il tasto annulla
   else if(request.getParameter("annulla") != null) {
     session.removeAttribute("matriceVO");
     session.removeAttribute("ricercaMatriceVO");
     %>
       <jsp:forward page="<%= ricercaMatriceUrl %>"/>
     <%
   }
   // L'utente ha selezionato la funzione modifica matrice
   else {
     session.removeAttribute("matriceVO");
     // Seleziono la matrice che voglio modificare
     String matrice = request.getParameter("idMatrice");
     Long idMatrice = Long.decode(matrice);
     // Recupero l'oggetto matriceVO che voglio modificare
     MatriceVO modificaMatriceVO = null;
     try {
       modificaMatriceVO = umaFacadeClient.getMatrice(idMatrice);
     }
     catch(SolmrException se) {
       ValidationError error = new ValidationError(se.getMessage());
       errors.add("error",error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(listaMatriciUrl).forward(request, response);
       return;
     }
     session.setAttribute("matriceVO",modificaMatriceVO);
     // Vado alla pagina di modifica
     %>
       <jsp:forward page="<%= modificaMatriceUrl %>"/>
     <%
   }
%>
