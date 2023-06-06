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
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.dto.comune.IntermediarioVO" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!

  private static final String VIEW="../view/reportBuoniEmessiAnnoCAAView.jsp";

%>

<%
  String iridePageName = "reportBuoniEmessiAnnoCAACtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%
  AnagFacadeClient anagFacadeClient = new AnagFacadeClient();

  Collection provinceUMA = (Collection)anagFacadeClient.getProvinceByRegione(SolmrConstants.ID_REGIONE);
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  
  request.setAttribute("provinceUMA",provinceUMA);

  UmaFacadeClient umaFacadeClient=new UmaFacadeClient();
  IntermediarioVO intermediari[]=null;
  if (ruoloUtenza.isUtenteIntermediario())
  {
    // Tutti gli intermediari della gerarchia di quello a cui appartiene
    // l'utente
    intermediari=umaFacadeClient.serviceGetListaIntermediari(null , ruoloUtenza.getPIVAIntermediario(),SolmrConstants.TIPO_INTERMEDIARIO_CAA,null);
  }
  else
  {
    // Tutti gli intermediari
    intermediari=umaFacadeClient.serviceGetListaIntermediari(null,null,SolmrConstants.TIPO_INTERMEDIARIO_CAA,null);
  }

  if (request.getParameter("conferma")!=null)
  {
    ValidationErrors errors=validate(request,ruoloUtenza);
    if (errors!=null)
    {
      request.setAttribute("errors",errors);
    }
    else
    {
      request.setAttribute("showPdf",Boolean.TRUE);
    }
  }

  request.setAttribute("intermediari",intermediari);

%><jsp:forward page="<%=VIEW%>"/><%!
  /**
   * Valida i dati inseriti dall'utente
   * @param request
   * @return
   */
  protected ValidationErrors validate(HttpServletRequest request, RuoloUtenza ruoloUtenza)
  {
    ValidationErrors errors=new ValidationErrors();
    if (ruoloUtenza.isUtenteProvinciale())
    {
      String istatProvincia=request.getParameter("istatProvincia");
      if (istatProvincia==null || "".equals(istatProvincia.trim()))
      {
        errors.add("istatProvincia",new ValidationError(UmaErrors.ERRORE_VAL_CAMPO_OBBLIGATORIO));
      }
      else
      {
        if (!ruoloUtenza.getIstatProvincia().equals(istatProvincia))
        {
          errors.add("istatProvincia",new ValidationError(UmaErrors.ERRORE_AUT_PROVINCIA_NON_DI_COMPETENZA));
        }
      }
    }
    String annoStr=request.getParameter("anno");
    if (Validator.isEmpty(annoStr))
    {
      errors.add("anno",new ValidationError(UmaErrors.ERRORE_VAL_CAMPO_OBBLIGATORIO));
    }
    else
    {
      Long anno=null;
      try
      {
        anno=new Long(annoStr);
        if (anno.intValue()>DateUtils.getCurrentYear().intValue())
        {
          errors.add("anno",new ValidationError(UmaErrors.ERRORE_VAL_ANNO_POSTERIORE_ATTUALE));
        }
        else
        {
          if (anno.intValue()<1900)
          {
            errors.add("anno",new ValidationError(UmaErrors.ERRORE_VAL_VALORE_NON_VALIDO));
          }
        }
      }
      catch(Exception e)
      {
        errors.add("anno",new ValidationError(UmaErrors.ERRORE_VAL_VALORE_NON_VALIDO));
      }
    }
    String idIntermediario=request.getParameter("idIntermediario");
    if (Validator.isEmpty(idIntermediario))
    {
      errors.add("idIntermediario",new ValidationError(UmaErrors.ERRORE_VAL_CAMPO_OBBLIGATORIO));
    }
    return errors.size()==0?null:errors;
  }

%>



