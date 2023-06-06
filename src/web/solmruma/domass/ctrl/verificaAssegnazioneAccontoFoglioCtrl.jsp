<%@ page language="java" contentType="text/html"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@page import="it.csi.solmr.client.uma.UmaFacadeClient"%>
<%@page import="it.csi.solmr.dto.uma.NumerazioneFoglioVO"%>
<%@page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO"%>
<%@page import="it.csi.solmr.dto.uma.DittaUMAVO"%>
<%@page import="java.util.Vector"%>
<%@page import="it.csi.solmr.util.ValidationErrors"%>
<%@page import="it.csi.solmr.etc.uma.UmaErrors"%>
<%@page import="it.csi.solmr.util.ValidationError"%>
<%@ page import="it.csi.papua.papuaserv.presentation.ws.profilazione.axis.UtenteAbilitazioni" %>


<%!private static final String VIEW                 = "/domass/view/verificaAssegnazioneAccontoFoglioView.jsp";
  private static final String VALIDAZIONE_ESEGUITA = "../layout/verificaAssegnazioneAccontoValidata.htm";%>
<%
  String iridePageName = "verificaAssegnazioneAccontoFoglioCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  UtenteAbilitazioni utenteAbilitazioni = (UtenteAbilitazioni) session.getAttribute("utenteAbilitazioni");
  boolean saltaSceltaFoglioRiga = true;
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  NumerazioneFoglioVO numerazioneFoglioVO = null;
  Long idNumerazioneFoglio = null;
  if (ruoloUtenza.isUtentePA())
  {
	DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
	Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
    DittaUMAVO dittaUmaVO = umaFacadeClient.findByPrimaryKey(idDittaUma);
    numerazioneFoglioVO = umaFacadeClient.findNumerazioneFoglioByUtente(ruoloUtenza, dittaUmaVO.getExtProvinciaUMA());
    saltaSceltaFoglioRiga = numerazioneFoglioVO != null; // Se non ha un suo foglio 
    // (numerazioneFogliVO==null) devo fargliene scegliere uno di un altro utente o 
    // creare uno nuovo
  }
  if (request.getParameter("confermaFoglioRiga") != null)
  {
    String radiobutton = request.getParameter("radiobutton");
    if (radiobutton == null)
    {
      ValidationErrors errors = new ValidationErrors();
      ValidationError error = new ValidationError(
          UmaErrors.ERR_VAL_CAMPO_OBBLIGATORIO);
      errors.add("radiobutton", error);
      request.setAttribute("errors", errors);
    }
    else
    {
      try
      {
        idNumerazioneFoglio = new Long(radiobutton);
        if (idNumerazioneFoglio.longValue()<=0)
        {
          idNumerazioneFoglio=null; // Assegnazione nuovo foglio riga se radiobutton == -1
        }
        saltaSceltaFoglioRiga = true; // L'idNumerazioneFoglio è valido ==> eseguo la validazione
      }
      catch (Exception e)
      {
        ValidationErrors errors = new ValidationErrors();
        ValidationError error = new ValidationError(
            UmaErrors.ERR_VAL_CAMPO_OBBLIGATORIO);
        errors.add("radiobutton", error);
        request.setAttribute("errors", errors);
      }
    }
  }
  if (idNumerazioneFoglio==null && numerazioneFoglioVO != null)
  {
    idNumerazioneFoglio = numerazioneFoglioVO.getIdNumerazioneFoglio();
  }

  if (saltaSceltaFoglioRiga)
  {
    // L'utente non deve scegliere il foglio ==> valido la domanda
    DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
        .getAttribute("dittaUMAAziendaVO");
    umaFacadeClient.validaAcconto(dittaUMAAziendaVO, idNumerazioneFoglio,
        ruoloUtenza, utenteAbilitazioni);
    response.sendRedirect(VALIDAZIONE_ESEGUITA);
    return;
  }
  // Se sono giunto qui è perchè sono un PA senza foglio ==> carico tutti i fogli della provincia
  // di appartenenza
  //Vector numFogliResult = umaFacadeClient.findNumerazioneFoglioByProvincia(ruoloUtenza.getCodiceEnte());
  Vector numFogliResult = umaFacadeClient.findNumerazioneFoglioByProvincia(dittaUmaVO.getExtProvinciaUMA());
  if (numFogliResult != null)
  {
    request.setAttribute("numFogliResult", numFogliResult);
  }
  // Forward sulla view
  request.getRequestDispatcher(VIEW).forward(request, response);
%>