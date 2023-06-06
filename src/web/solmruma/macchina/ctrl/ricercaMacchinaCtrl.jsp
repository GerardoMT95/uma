<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  String iridePageName = "ricercaMacchinaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  session.removeAttribute("dittaUMAAziendaVO");
  MacchinaVO ricMacchinaVO = new MacchinaVO();
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  String url = "/macchina/view/ricercaMacchinaView.jsp";
  String errorPage = "/macchina/view/ricercaMacchinaView.jsp";
  String ricPuntualeURL = "/macchina/view/dettaglioMacchinaDatiView.jsp";
  String ricAvanzataURL = "/macchina/view/elencoMacchineTrovateView.jsp";

  Validator validator = null;
  String tipoRicerca = request.getParameter("tipoRicerca");

  if(tipoRicerca != null) {
    session.removeAttribute("currPage");
    session.removeAttribute("macchinaVO");
    session.removeAttribute("elencoIdMacchina");
    session.removeAttribute("elencoMacchina");
    session.removeAttribute("matriceCarattSiNo");
    session.removeAttribute("messaggioTarga");
    session.removeAttribute("ricercaCaratt");
    session.removeAttribute("ricercaAttest");
    session.removeAttribute("indietro");
    session.removeAttribute("v_utilizzi");
    session.removeAttribute("v_attestazioni");
    session.removeAttribute("v_immatricolazioni");


    if(tipoRicerca.equals("ricTarga")){
      TargaVO targaVO = new TargaVO();
      SolmrLogger.debug(this,"Parametro tipo targa is "+request.getParameter("tipoTarga"));
      String idTarga = request.getParameter("tipoTarga");
      targaVO.setIdTarga(idTarga);
      if(idTarga!=null && !idTarga.equals("")){
        targaVO.setIdTargaLong(new Long(idTarga));
      }
      targaVO.setNumeroTarga(request.getParameter("numeroTarga"));
      ricMacchinaVO.setTargaCorrente(targaVO);

      ValidationErrors errors = ricMacchinaVO.validateRicTarga();
      if (! (errors == null || errors.size() == 0)) {
        request.setAttribute("ricMacchinaVO", ricMacchinaVO);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(errorPage).forward(request, response);
        return;
      }
      try{
        MacchinaVO mVO = umaFacadeClient.getMacchinaByTarga(targaVO);
        if(mVO!=null){
          SolmrLogger.debug(this,"macchina non è null");
          session.setAttribute("macchinaVO",mVO);
        }
        if(mVO!=null){
          String messaggioTarga = "";
          if(mVO.getTargaCorrente()!=null){
            if(!mVO.getTargaCorrente().getIdTarga().equals(targaVO.getIdTarga()) ||
               !mVO.getTargaCorrente().getNumeroTarga().equalsIgnoreCase(targaVO.getNumeroTarga())){
              messaggioTarga = "La macchina corrispondente alla targa indicata è stata reimmatricolata";
              session.setAttribute("messaggioTarga",messaggioTarga);
            }
          }
          else{
            messaggioTarga = "La targa impostata nel criterio di ricerca non risulta attiva";
            session.setAttribute("messaggioTarga",messaggioTarga);
          }
        }
        url = ricPuntualeURL;
      }
      catch(SolmrException sex){
        ValidationError error = new ValidationError(sex.getMessage());
        request.setAttribute("ricMacchinaVO", ricMacchinaVO);
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(errorPage).forward(request, response);
        return;
      }
    }
    else if(tipoRicerca.equals("ricCaratt")){
      session.setAttribute("indietro","indietro");
      ValidationErrors errors = null;
      String idGenereMacchina = request.getParameter("idGenereMacchina");
      if(idGenereMacchina==null || idGenereMacchina.equals("")){
        errors = new ValidationErrors();
        errors.add("idGenereMacchina", new ValidationError("Valorizzare il genere"));
        request.setAttribute("ricMacchinaVO", ricMacchinaVO);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(errorPage).forward(request, response);
        return;
      }
      else{
        errors = new ValidationErrors();
        try{
          Vector elencoIdMacchina = null;
          Vector elencoMacchina = null;
          Boolean matriceCarattSiNo = null;
          int sizeResult = 0;
          int numBlock = 1;
          Vector rangeIdMacchina = new Vector();

          ricMacchinaVO.setMatricolaTelaio(request.getParameter("matricolaTelaio"));
          ricMacchinaVO.setMatricolaMotore(request.getParameter("matricolaMotore"));
          String idCategoria = request.getParameter("idCategoria");
          Long idCategoriaLong = null;
          if(idCategoria!=null && !idCategoria.equals(""))
            idCategoriaLong = new Long(idCategoria);
          if(idGenereMacchina.equals(SolmrConstants.ID_GENERE_MACCHINA_ASM.toString()) ||
             idGenereMacchina.equals(SolmrConstants.ID_GENERE_MACCHINA_R.toString())){
            DatiMacchinaVO datiVO = new DatiMacchinaVO();
            datiVO.setIdGenereMacchina(idGenereMacchina);
            datiVO.setIdGenereMacchinaLong(new Long(idGenereMacchina));
            datiVO.setIdCategoria(idCategoria);
            datiVO.setIdCategoriaLong(idCategoriaLong);
            datiVO.setMarca(request.getParameter("marca"));
            datiVO.setTipoMacchina(request.getParameter("tipo"));
            ricMacchinaVO.setDatiMacchinaVO(datiVO);
            elencoIdMacchina = umaFacadeClient.getIdMacchineWithoutMatriceByCaratt(ricMacchinaVO);
            matriceCarattSiNo = Boolean.FALSE;
          }
          else{
            MatriceVO matrVO = new MatriceVO();
            matrVO.setIdGenereMacchina(idGenereMacchina);
            matrVO.setIdGenereMacchinaLong(new Long(idGenereMacchina));
            matrVO.setIdCategoria(idCategoria);
            matrVO.setIdCategoriaLong(idCategoriaLong);
            matrVO.setDescMarca(request.getParameter("marca"));
            matrVO.setTipoMacchina(request.getParameter("tipo"));
            matrVO.setNumeroMatrice(request.getParameter("numeroMatrice"));
            matrVO.setNumeroOmologazione(request.getParameter("numeroOmologazione"));
            ricMacchinaVO.setMatriceVO(matrVO);
            elencoIdMacchina = umaFacadeClient.getIdMacchineWithMatriceByCaratt(ricMacchinaVO);
            matriceCarattSiNo = Boolean.TRUE;
          }
          if(elencoIdMacchina!=null)
            sizeResult = elencoIdMacchina.size();
          int limiteA;
          if(sizeResult<SolmrConstants.NUM_MAX_ROWS_PAG)
            limiteA=sizeResult;
          else
            limiteA=SolmrConstants.NUM_MAX_ROWS_PAG;
          for(int i=(numBlock-1)*SolmrConstants.NUM_MAX_ROWS_PAG; i<limiteA; i++){
            rangeIdMacchina.addElement(elencoIdMacchina.elementAt(i));
          }
          if(matriceCarattSiNo!=null){
            if(matriceCarattSiNo.booleanValue())
              elencoMacchina = umaFacadeClient.getElencoMacchineWithMatriceByCaratt(rangeIdMacchina);
            else
              elencoMacchina = umaFacadeClient.getElencoMacchineWithoutMatriceByCaratt(rangeIdMacchina);
            session.setAttribute("elencoIdMacchina",elencoIdMacchina);
            session.setAttribute("elencoMacchina",elencoMacchina);
            session.setAttribute("matriceCarattSiNo",matriceCarattSiNo);
            // metto in sessione il value object con i parametri della ricerca
            // in modo che se l'utente ritorna all'elenco il sistema effettui
            // nuovamente la ricerca con i parametri impostati in origine
            session.setAttribute("ricercaCaratt",ricMacchinaVO);
            url = ricAvanzataURL;

          }
        }
        catch(SolmrException sex){
          ValidationError error = new ValidationError(sex.getMessage());
          request.setAttribute("ricMacchinaVO", ricMacchinaVO);
          errors.add("error", error);
          request.setAttribute("errors", errors);
          request.getRequestDispatcher(errorPage).forward(request, response);
          return;
        }
      }
    }
    else if(tipoRicerca.equals("ricAttestaz")){
      session.setAttribute("indietro","indietro");
      AttestatoProprietaVO attPropVO = new AttestatoProprietaVO();
      attPropVO.setIdProvincia(request.getParameter("provAttest"));
      attPropVO.setAnno(request.getParameter("annoAttestazione"));
      attPropVO.setNumeroModello72(request.getParameter("numeroAttestazione"));
      ricMacchinaVO.setAttestatoProprietaVO(attPropVO);
      ValidationErrors errors = ricMacchinaVO.validateRicAttestaz();
      if (! (errors == null || errors.size() == 0)) {
        request.setAttribute("ricMacchinaVO", ricMacchinaVO);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(errorPage).forward(request, response);
        return;
      }
      try{
        Vector elencoIdMacchina = null;
        Vector elencoMacchina = null;

        int sizeResult = 0;
        int numBlock = 1;
        Vector rangeIdMacchina = new Vector();
        elencoIdMacchina = umaFacadeClient.getIdMacchineByAttestaz(attPropVO);

        if(elencoIdMacchina!=null)
          sizeResult = elencoIdMacchina.size();
        int limiteA;
        if(sizeResult<SolmrConstants.NUM_MAX_ROWS_PAG)
          limiteA=sizeResult;
        else
          limiteA=SolmrConstants.NUM_MAX_ROWS_PAG;
        for(int i=(numBlock-1)*SolmrConstants.NUM_MAX_ROWS_PAG; i<limiteA; i++){
          rangeIdMacchina.addElement(elencoIdMacchina.elementAt(i));
        }

        elencoMacchina = umaFacadeClient.getElencoMacchineByAttestaz(rangeIdMacchina);
        session.setAttribute("elencoIdMacchina",elencoIdMacchina);
        session.setAttribute("elencoMacchina",elencoMacchina);
        // metto in sessione il value object con i parametri della ricerca
        // in modo che se l'utente ritorna all'elenco il sistema effettui
        // nuovamente la ricerca con i parametri impostati in origine
        session.setAttribute("ricercaAttest",attPropVO);
        url = ricAvanzataURL;
      }
      catch(SolmrException sex){
        ValidationError error = new ValidationError(sex.getMessage());
        request.setAttribute("ricMacchinaVO", ricMacchinaVO);
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(errorPage).forward(request, response);
        return;
      }
    }
  }
  %>
      <jsp:forward page ="<%=url%>" />
  <%
%>
