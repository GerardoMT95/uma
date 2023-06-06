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
<%@ page import="it.csi.solmr.dto.*"%>
<%

  String iridePageName = "inserimentoMatriciCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


   UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

   String inserimentoMatriciUrl = "/macchina/view/inserimentoMatriciView.jsp";
   String confermaInserimentoMatriciUrl = "/macchina/view/confermaInserimentoMatriciView.jsp";
   String inserimentoMatriciOkUrl = "/macchina/view/inserimentoMatriciOkView.jsp";
   String listaMatriciUrl = "/macchina/view/listaMatriciView.jsp";
   String ricercaUrl = "/macchina/view/ricercaMatriceView.jsp";

   ValidationErrors errors = new ValidationErrors();

   MatriceVO matriceVO = (MatriceVO)session.getAttribute("inserimentoMatriceVO");
   // L'utente ha selezionato il pulsante ricerca
   if(request.getParameter("salva") != null) {

     // Recupero i parametri
     String genereMacchina = request.getParameter("idGenereMacchina");
     Long idGenereMacchina = null;
     if(genereMacchina != null && !genereMacchina.equals("")) {
       session.setAttribute("genereMacchina",genereMacchina);
       idGenereMacchina = Long.decode(genereMacchina);
     }
     String categoria = request.getParameter("idCategoria");
     Long idCategoria = null;
     if(categoria != null && !categoria.equals("")) {
       session.setAttribute("categoria",categoria);
       idCategoria = Long.decode(categoria);
     }
     String descrizioneMarca = request.getParameter("descMarca");
     String matriceMarca = request.getParameter("matriceMarca");
     String tipoMacchina = request.getParameter("tipoMacchina");
     String numeroOmologazione = request.getParameter("numeroOmologazione");
     String tipoAlimentazione = request.getParameter("tipiAlimentazione");
     String potenzaCV = request.getParameter("potenzaCV");
     String potenzaKW = request.getParameter("potenzaKW");
     String consumoOrario = request.getParameter("consumoOrario");
     String tipoTrazione = request.getParameter("tipiTrazione");
     String nazionalita = request.getParameter("tipiNazionalita");
     String illuminazione = request.getParameter("illuminazione");

     // Istanzio il VO e gli setto i parametri
     MatriceVO inserisciMatriceVO = new MatriceVO();
     inserisciMatriceVO.setIdGenereMacchina(genereMacchina);
     inserisciMatriceVO.setIdGenereMacchinaLong(idGenereMacchina);
     inserisciMatriceVO.setIdCategoria(categoria);
     inserisciMatriceVO.setIdCategoriaLong(idCategoria);
     inserisciMatriceVO.setDescMarca(descrizioneMarca);
     inserisciMatriceVO.setTipoMacchina(tipoMacchina);
     inserisciMatriceVO.setNumeroOmologazione(numeroOmologazione);
     inserisciMatriceVO.setTipiAlimentazione(tipoAlimentazione);
     inserisciMatriceVO.setPotenzaCV(potenzaCV);
     inserisciMatriceVO.setPotenzaKW(potenzaKW);
     inserisciMatriceVO.setConsumoOrario(consumoOrario);
     inserisciMatriceVO.setIdTrazione(tipoTrazione);
     inserisciMatriceVO.setTipiTrazione(tipoTrazione);
     inserisciMatriceVO.setTipiNazionalita(nazionalita);
     inserisciMatriceVO.setIdNazionalita(nazionalita);
     inserisciMatriceVO.setTipiNazionalita(nazionalita);
     inserisciMatriceVO.setIlluminazione(illuminazione);

     errors = inserisciMatriceVO.validateInserimentoMatrice();

     // Se il genere macchina selezionato prevede una categoria allora quest'ultima è obbligatoria
     Vector elencoCategorie = (Vector)session.getAttribute("elencoCategorie");
     if(elencoCategorie != null) {
       if(elencoCategorie.size() > 0) {
         if(categoria == null || categoria.equals("")) {
           errors.add("categoria",new ValidationError((String)UmaErrors.get("ERR_CATEGORIA_OBBLIGATORIA")));
         }
       }
     }

     // Se l'utente ha valorizzato la marca recupero l'id e controllo che sia compatibile con il genere
     // macchina selezionato
     if(descrizioneMarca != null && !descrizioneMarca.equals("") && genereMacchina != null && !genereMacchina.equals("")) {
       Long idMarca = null;
       try {
         CodeDescr code = umaFacadeClient.ricercaMarcaValidaForGenereMacchina(descrizioneMarca, genereMacchina, matriceMarca);
         idMarca = new Long(code.getCode().longValue());
         matriceMarca = code.getSecondaryCode();
         inserisciMatriceVO.setIdMarcaLong(idMarca);
         inserisciMatriceVO.setMatriceMarca(matriceMarca);
       }
       catch(SolmrException se) {
         errors.add("descMarca",new ValidationError(se.getMessage()));
       }
     }

     session.setAttribute("inserimentoMatriceVO",inserisciMatriceVO);

     // Se si sono verificati degli errori li visualizzo
     if(errors != null && errors.size() > 0) {
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(inserimentoMatriciUrl).forward(request, response);
       return;
     }

     // Effettuati i controlli formali sulla correttezza dei dati verifico che non esista già un record con gli
     // stessi genere, marca, tipo macchina
     boolean result = false;
     try {
       result = umaFacadeClient.checkMarcaAttiva(inserisciMatriceVO.getIdGenereMacchinaLong(),
                                                 inserisciMatriceVO.getIdMarcaLong(),
                                                 inserisciMatriceVO.getTipoMacchina());
     }
     catch(SolmrException se) {
       ValidationError error = new ValidationError(se.getMessage());
       errors.add("error",error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(inserimentoMatriciUrl).forward(request, response);
       return;
     }

     // Se esiste avviso l'utente e lo mando ad una pagina di warning
     if(result) {
       String messaggio = (String)UmaErrors.get("WARNING_MATRICE_ESISTENTE");
       %>
          <jsp:forward page="<%= confermaInserimentoMatriciUrl %>">
          <jsp:param name="messaggio" value="<%=messaggio%>"/>
          </jsp:forward>
       <%
     }

     // Effettuati i controlli formali sulla correttezza dei dati verifico che non esista già un record con lo
     // stesso numeroOmologazione
     boolean result1 = false;
     try {
       result1 = umaFacadeClient.checkMarcaAttivaForNumeroOmologazione(inserisciMatriceVO.getNumeroOmologazione());
     }
     catch(SolmrException se) {
       ValidationError error = new ValidationError(se.getMessage());
       errors.add("error",error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(inserimentoMatriciUrl).forward(request, response);
       return;
     }

     // Se esiste avviso l'utente e lo mando ad una pagina di warning
     if(result1) {
       String messaggio = (String)UmaErrors.get("WARNING_MATRICE_ESISTENTE_OMOLOGAZIONE");
       %>
          <jsp:forward page="<%= confermaInserimentoMatriciUrl %>">
          <jsp:param name="messaggio" value="<%=messaggio%>"/>
          </jsp:forward>
       <%
     }
     // Se non esiste procedo con l'inserimento
     Long primaryKey = null;
     try {
       primaryKey = umaFacadeClient.insertMatrice(inserisciMatriceVO);
     }
     catch(SolmrException se) {
       ValidationError error = new ValidationError(se.getMessage());
       errors.add("error",error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(inserimentoMatriciUrl).forward(request, response);
       return;
     }
     // Recupero la matrice e la mando alla pagina di inserimento effettuato
     matriceVO = null;
     try {
       matriceVO = umaFacadeClient.getMatrice(primaryKey);
     }
     catch(SolmrException se) {
       ValidationError error = new ValidationError(se.getMessage());
       errors.add("error",error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(inserimentoMatriciUrl).forward(request, response);
       return;
     }
     session.removeAttribute("inserisciMatriceVO");
     session.setAttribute("matriceVO",matriceVO);
     %>
        <jsp:forward page="<%= inserimentoMatriciOkUrl %>"/>
     <%
   }
   else if(request.getParameter("annulla") != null) {
     // Rimuovo gli oggetti dalla sessione nel caso in cui arrivassi dall funzionalità di ricerca matrici
     session.removeAttribute("elencoCategorie");
     session.removeAttribute("genereMacchina");
     session.removeAttribute("categoria");
     session.removeAttribute("elencoMatrici");
     session.removeAttribute("ricercaMatriceVO");
     session.removeAttribute("matriceVO");
     session.removeAttribute("indice");
     session.removeAttribute("inserimentoMatriceVO");
     %>
        <jsp:forward page="<%= ricercaUrl %>"/>
     <%
   }
   // L'utente ha cambiato il valore della combo relativa al genere macchina
   else if(request.getParameter("operazione") != null) {
     if(request.getParameter("operazione").equalsIgnoreCase("cambioCategoria")) {
       String genereMacchina = request.getParameter("idGenereMacchina");
       // Recupero il valore di categorie in relazione al genere macchina selezionato
       Vector elencoCategorie = null;
       if(genereMacchina != null) {
         session.setAttribute("genereMacchina",genereMacchina);
         if(!genereMacchina.equals("")) {
           try {
             elencoCategorie = umaFacadeClient.getTipiCategoriaByGenereMacchina(Long.decode(genereMacchina));
           }
           catch(SolmrException se) {
             ValidationError error = new ValidationError(se.getMessage());
             errors.add("error",error);
             request.setAttribute("errors", errors);
             request.getRequestDispatcher(inserimentoMatriciUrl).forward(request, response);
             return;
           }
         }
       }
       // Metto in sessione il vettore contenente l'elenco delle categorie
       if(elencoCategorie != null) {
         session.setAttribute("elencoCategorie",elencoCategorie);
         session.removeAttribute("categoria");
       }
       if(matriceVO != null) {
         matriceVO.setDescMarca(null);
       }
       // Poi ricarico la pagina di ricerca con la combo aggiornata
       %>
          <jsp:forward page="<%= inserimentoMatriciUrl %>"/>
       <%
     }
   }
   // L'utente ha selezionato la funzione di inserisci matrice
   else {
     // Rimuovo gli oggetti dalla sessione nel caso in cui arrivassi dall funzionalità di ricerca matrici
     session.removeAttribute("elencoCategorie");
     session.removeAttribute("genereMacchina");
     session.removeAttribute("categoria");
     session.removeAttribute("elencoMatrici");
     session.removeAttribute("ricercaMatriceVO");
     session.removeAttribute("matriceVO");
     session.removeAttribute("indice");
     session.removeAttribute("inserimentoMatriceVO");
     %>
        <jsp:forward page="<%=  inserimentoMatriciUrl%>"/>
     <%
   }

%>
