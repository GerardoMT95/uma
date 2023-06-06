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

  String iridePageName = "ricercaMatriceCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


   UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

   String ricercaMatriceUrl = "/macchina/view/ricercaMatriceView.jsp";
   String listaMatriciUrl = "/macchina/view/listaMatriciView.jsp";

   ValidationErrors errors = new ValidationErrors();

   // L'utente ha selezionato il pulsante ricerca
   if(request.getParameter("ricerca") != null) {
     // Rimuovo l'id genere macchina dalla sessione
     session.removeAttribute("genereMacchina");
     // Recupero i parametri
     String genereMacchina = request.getParameter("idGenereMacchina");
     if(genereMacchina != null) {
       session.setAttribute("genereMacchina",genereMacchina);
     }
     String categoria = request.getParameter("idCategoria");
     if(categoria != null) {
       session.setAttribute("categoria",categoria);
     }
     String marca = request.getParameter("descMarca");
     String tipo = request.getParameter("tipoMacchina");
     String numeroMatrice = request.getParameter("numeroMatrice");
     String numeroOmologazione = request.getParameter("numeroOmologazione");
     // Creo il VO e setto i parametri al suo interno
     MatriceVO ricercaMatriceVO = new MatriceVO();
     ricercaMatriceVO.setIdGenereMacchina(genereMacchina);
     ricercaMatriceVO.setIdCategoria(categoria);
     ricercaMatriceVO.setDescMarca(marca);
     ricercaMatriceVO.setTipoMacchina(tipo);
     ricercaMatriceVO.setNumeroMatrice(numeroMatrice);
     ricercaMatriceVO.setNumeroOmologazione(numeroOmologazione);
     // Effettuo la validazione dei dati
     errors = ricercaMatriceVO.validateRicMatrice();

     Vector elencoCategorie = (Vector)session.getAttribute("elencoCategorie");
     if(elencoCategorie != null) {
       if(elencoCategorie.size() > 0) {
         if(categoria == null || categoria.equals("")) {
           errors.add("categoria",new ValidationError((String)UmaErrors.get("ERR_CATEGORIA_OBBLIGATORIA")));
         }
       }
     }

     // Se si sono verificati degli errori li visualizzo
     if(errors != null && errors.size() > 0) {
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(ricercaMatriceUrl).forward(request, response);
       return;
     }
     // Effettuo la ricerca delle matrici in relazione ai parametri inseriti dall'utente
     Vector elencoMatrici = null;
     Long idCategoria = null;
     if(categoria != null && !categoria.equals("")) {
       idCategoria = Long.decode(categoria);
     }
     try {
       elencoMatrici = umaFacadeClient.getListaMatrici(Long.decode(genereMacchina), idCategoria, marca,
                                                                    tipo, numeroMatrice, numeroOmologazione);
     }
     catch(SolmrException se) {
       ValidationError error = new ValidationError(se.getMessage());
       errors.add("error",error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(ricercaMatriceUrl).forward(request, response);
       return;
     }
     // Se non sono state trovate matrici in relazione ai criteri selezionati avviso l'utente
     if(elencoMatrici.size() == 0) {
       ValidationError error = new ValidationError((String)UmaErrors.get("ERR_NESSUNA_MATRICE_TROVATA"));
       errors.add("error",error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(ricercaMatriceUrl).forward(request, response);
       return;
     }

     String descrizioneGenere = null;
     try {
       descrizioneGenere = umaFacadeClient.getDescGenereMacchina(Long.decode(genereMacchina));
     }
     catch(SolmrException se) {
       ValidationError error = new ValidationError((String)UmaErrors.get("ERR_SISTEMA"));
       errors.add("error",error);
       request.setAttribute("errors", errors);
       request.getRequestDispatcher(ricercaMatriceUrl).forward(request, response);
       return;
     }
     ricercaMatriceVO.setDescGenereMacchina(descrizioneGenere);

     String descrizioneCategoria = null;
     if(categoria != null && !categoria.equals("")) {
       try {
         descrizioneCategoria = umaFacadeClient.getDescCategoria(Long.decode(categoria));
       }
       catch(SolmrException se) {
         ValidationError error = new ValidationError((String)UmaErrors.get("ERR_SISTEMA"));
         errors.add("error",error);
         request.setAttribute("errors", errors);
         request.getRequestDispatcher(ricercaMatriceUrl).forward(request, response);
         return;
       }
     }
     ricercaMatriceVO.setDescCategoria(descrizioneCategoria);
     // Se le trova ripulisco la sessione
     session.removeAttribute("elencoCategorie");
     session.removeAttribute("genereMacchina");
     session.removeAttribute("categoria");

     // E metto invece il vettore contenente le matrici
     session.setAttribute("elencoMatrici",elencoMatrici);
     session.setAttribute("ricercaMatriceVO",ricercaMatriceVO);

     // E vado alla pagina di elenco
     %>
        <jsp:forward page="<%= listaMatriciUrl %>"/>
     <%
   }
   // L'utente ha modificato il valore contenuto nella combo genere
   else if(request.getParameter("operazione") != null) {
     // Recupero il valore presente nella combo genere
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
           request.getRequestDispatcher(ricercaMatriceUrl).forward(request, response);
           return;
         }
       }
     }
     String marca = request.getParameter("descMarca");
     String tipo = request.getParameter("tipoMacchina");
     String numeroMatrice = request.getParameter("numeroMatrice");
     String numeroOmologazione = request.getParameter("numeroOmologazione");
     // Creo il VO e setto i parametri al suo interno
     MatriceVO ricercaMatriceVO = new MatriceVO();
     ricercaMatriceVO.setDescMarca(marca);
     ricercaMatriceVO.setTipoMacchina(tipo);
     ricercaMatriceVO.setNumeroMatrice(numeroMatrice);
     ricercaMatriceVO.setNumeroOmologazione(numeroOmologazione);
     session.setAttribute("ricercaMatriceVO",ricercaMatriceVO);
     // Metto in sessione il vettore contenente l'elenco delle categorie
     if(elencoCategorie != null) {
       session.setAttribute("elencoCategorie",elencoCategorie);
     }
     // Poi ricarico la pagina di ricerca con la combo aggiornata
     %>
        <jsp:forward page="<%= ricercaMatriceUrl %>"/>
     <%
   }
   // L'utente ha selezionato la funzione di gestione matrice
   else {
     // Rimuovo l'elenco delle categorie dalla sessione
     session.removeAttribute("elencoCategorie");
     session.removeAttribute("genereMacchina");
     session.removeAttribute("categoria");
     session.removeAttribute("elencoMatrici");
     session.removeAttribute("ricercaMatriceVO");
     session.removeAttribute("matriceVO");
     session.removeAttribute("indice");
     %>
        <jsp:forward page="<%= ricercaMatriceUrl %>"/>
     <%
   }

%>
