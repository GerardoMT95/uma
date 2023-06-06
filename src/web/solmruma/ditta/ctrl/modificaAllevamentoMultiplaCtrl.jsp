<%@ page language="java" contentType="text/html" isErrorPage="true"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@page import="it.csi.solmr.exception.SolmrException"%>
<%@page import="it.csi.solmr.util.NumberUtils"%>
<%@page import="it.csi.solmr.etc.uma.UmaErrors"%>
<%@page import="java.util.Vector"%>
<%@page import="it.csi.solmr.dto.CodeDescr"%>
<%@page import="it.csi.solmr.dto.profile.RuoloUtenza"%>
<%@page import="it.csi.solmr.util.ValidationErrors"%>
<%@page import="it.csi.solmr.util.ValidationError"%>
<%@page import="java.util.HashMap"%>
<%!public static final String VIEW = "/ditta/view/modificaAllevamentoMultiplaView.jsp";%>
<%
  if (request.getParameter("annulla.x") != null)
  {
    String pageFrom = request.getParameter("pageFrom");
    if (pageFrom == null)
    {
      pageFrom = request.getHeader("referer");
    }
    if (pageFrom == null)
    {
      pageFrom = "../layout/elencoAllevamento.htm";
    }
    response.sendRedirect(pageFrom);
    return;
  }
  String iridePageName = "modificaAllevamentoMultiplaCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%
  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");
  Long idDittaUMA = dittaUMAAziendaVO.getIdDittaUMA();
  UmaFacadeClient umaClient = new UmaFacadeClient();
  String aIdAllevamento[] = request.getParameterValues("radiobutton");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  int len = aIdAllevamento == null ? 0 : aIdAllevamento.length;
  if (len == 0)
  {
    throw new SolmrException("Inserire almeno una lavorazione");
  }
  long idAllevamenti[] = null;
  try
  {
    idAllevamenti = NumberUtils.convertStringToLong(aIdAllevamento);
  }
  catch (Exception e)
  {
    // il vettore di id contiene valori non numerici?????
    throw new SolmrException(
        "Uno o più allevamenti indicato ha un id non valido");
  }
  if (request.getParameter("salva.x") != null)
  {
    long idLavorazioni[] = null;
    try
    {
      idLavorazioni = NumberUtils.convertStringToLong(request
          .getParameterValues("lavorazioniEffettuate"));
    }
    catch (Exception e)
    {
      // il vettore di id contiene valori non numerici?????
      throw new SolmrException(
          "Uno o più allevamenti indicato ha un id non valido");
    }
    ValidationErrors errors = null;
    if (idLavorazioni == null)
    {

      errors = new ValidationErrors();
      errors.add("lavorazioniEffettuate", new ValidationError(
          "Inserire almeno una lavorazione"));

    }
    else
    {
      errors = umaClient.modificaAllevamentoMassiva(idDittaUMA,
          idAllevamenti, idLavorazioni, ruoloUtenza);
    }
    if (errors == null || errors.size() == 0)
    {
      String pageFrom = request.getParameter("pageFrom");
      if (pageFrom == null)
      {
        pageFrom = request.getHeader("referer");
      }
      session.setAttribute("notifica", "Modifica eseguita con successo");
      response.sendRedirect(pageFrom);
      return;
    }
    request.setAttribute("errors", errors);
  }
  AllevamentoVO allevamenti[] = umaClient.findAllevamentoByIdRange(idAllevamenti);

  len = allevamenti == null ? 0 : allevamenti.length;
  for (int i = 0; i < len; ++i)
  {
    if (allevamenti[i].getDataFineVal() != null)
    {
      throw new SolmrException(
          UmaErrors.ERRORE_MODIFICA_MULTIPLA_ALLEVAMENTO_STORICIZZATO);
    }
  }

  HashMap<?,?> mapDescrizioniLavorazioni = umaClient
      .getDescrizioniLavorazioniPraticateByIdRange(NumberUtils
          .convertLongBaseArrayToLongObjArray(idAllevamenti));
  request.setAttribute("mapDescrizioniLavorazioni",
      mapDescrizioniLavorazioni);

  request.setAttribute("allevamenti", allevamenti);

  Vector<CodeDescr> lavorazioniPossibili = umaClient
      .getTipiLavorazioniTipoLavorazioneA();
  request.setAttribute("lavorazioniPossibili", lavorazioniPossibili);
%><jsp:forward page="<%=VIEW%>" />