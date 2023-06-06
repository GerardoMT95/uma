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
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%!
  private static final String VIEW="/macchina/view/modello49View.jsp";
  private static final String VIEW1 = "/macchina/layout/dettaglioMacchinaDittaImmatricolazioni.htm";
  private static final String VIEW2 = "/macchina/layout/dettaglioTarga.htm";
%>
<%

  String iridePageName = "modello49Ctrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  try {
    DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
    Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
    UmaFacadeClient umaClient = new UmaFacadeClient();
    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  
    ValidationErrors errors=new ValidationErrors();
    String strNumeroProtocollo = request.getParameter("numeroProtocollo");
    String strDataProtocollo = request.getParameter("dataProtocollo");
    String strIdPagina = request.getParameter("idPagina");
    String strIdMovimentiTarga = request.getParameter("idMovimentiTarga");
    ValidationError vError = null;

    MovimentiTargaVO mtVO = umaClient.getMovimentazioneById(new Long(strIdMovimentiTarga));
    if ((mtVO.getAnnoModello() == null) && (mtVO.getNumeroModello()) == null) {
      errors.add("error",new ValidationError("Il record selezionato non riguarda un acquisto di macchina proveniente da fuori regione"));
      request.setAttribute("errors",errors);
      if (strIdPagina.equals("0")) {
        %><jsp:forward page="<%=VIEW1%>"/><%
      } else if (strIdPagina.equals("1")) {
        %><jsp:forward page="<%=VIEW2%>"/><%
      }
    } else {
      request.setAttribute("annoModello", mtVO.getAnnoModello());
      request.setAttribute("numeroModello", mtVO.getNumeroModello());
      if (mtVO.getDataProtocolloDate() != null) {
        request.setAttribute("dataProtocollo", DateUtils.formatDate(mtVO.getDataProtocolloDate()));
      } else {
        request.setAttribute("dataProtocollo",null);
      }
      request.setAttribute("numeroProtocollo", mtVO.getProtocolloModello());
    }

    if (request.getParameter("conferma") != null) {
      if (Validator.isNotEmpty(strNumeroProtocollo)!=Validator.isNotEmpty(strDataProtocollo)) {
        vError = new ValidationError("I campi devono essere entrambi valorizzati o entrambi vuoti");
        errors.add("numeroProtocollo",vError);
        errors.add("dataProtocollo",vError);
      } else {
        if (Validator.isNotEmpty(strNumeroProtocollo) && !Validator.isNumericInteger(strNumeroProtocollo)) {
          vError = new ValidationError("Numero protocollo non valido");
          errors.add("numeroProtocollo",vError);
        }
        Validator.validateDateAll(strDataProtocollo, "dataProtocollo", "data protocollo", errors, false, true);
      }
      if (errors.size()!=0) {
       request.setAttribute("errors", errors);
      } else {
       mtVO.setProtocolloModello(strNumeroProtocollo);

       if ((strDataProtocollo != null) && (!strDataProtocollo.equals(""))) {
         mtVO.setDataProtocolloDate(DateUtils.parseDate(strDataProtocollo));
       } else {
         mtVO.setDataProtocolloDate(null);
       }
       umaClient.updateMovimentiTargaProtocollo49(mtVO, ruoloUtenza);
      }
    }
  } catch(Exception e) {
    e.printStackTrace();
    ValidationErrors errors=new ValidationErrors();
    errors.add("error",new ValidationError(e.getMessage()));
    request.setAttribute("errors",errors);
  }
%>
<jsp:forward page="<%=VIEW%>"/>
