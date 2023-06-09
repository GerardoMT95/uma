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
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  public static final String VIEW="/macchina/view/macchinaNuovaDatiCasoMatriceView.jsp";
  public static final String NEXT="../layout/macchinaNuovaUtilizzoCasoMatrice.htm";
  public static final String PREV_RICERCA="../layout/macchinaNuovaGenere.htm";
  public static final String PREV_ELENCO="../layout/macchinaNuovaMatrice.htm";
  public static final String ELENCO_MACCHINE="../layout/elencoMacchine.htm";
%>
<%

  String iridePageName = "macchinaNuovaDatiCasoMatriceCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  if ( session.getAttribute("common")==null || !(session.getAttribute("common") instanceof HashMap)){
    response.sendRedirect(ELENCO_MACCHINE);
    return;
  }
  try
  {
    DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
    Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

    UmaFacadeClient umaClient = new UmaFacadeClient();
    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
    HashMap common = (HashMap) session.getAttribute("common");

    SolmrLogger.debug(this,"\n\n\n*********************************");

    SolmrLogger.debug(this,"request.getParameter(\"indietro\"): "+request.getParameter("indietro"));
    if (request.getParameter("indietro")!=null)
    {
      MacchinaVO macchinaVO=(MacchinaVO)common.get("macchinaVO");
      annullaLoad(macchinaVO, request);

      SolmrLogger.debug(this,"common.get(\"elencoMatrici\"): "+common.get("elencoMatrici"));
      if (common.get("elencoMatrici")!=null)
      {
        response.sendRedirect(PREV_ELENCO);
      }
      else
      {
        session.setAttribute("common",common);
        response.sendRedirect(PREV_RICERCA);
      }
      return;
    }
    else
    {
      MatriceVO matriceVO=(MatriceVO)common.get("matriceVO");
      MacchinaVO macchinaVO=(MacchinaVO)common.get("macchinaVO");
      if (request.getParameter("avanti")!=null)
      {
        ValidationErrors errors=validate(request,macchinaVO,matriceVO);
        SolmrLogger.debug(this,"\n\n\n***********************************");
        SolmrLogger.debug(this,"macchinaVO.getMatricolaMotore(): "+macchinaVO.getMatricolaMotore());
        SolmrLogger.debug(this,"macchinaVO.getMatricolaTelaio(): "+macchinaVO.getMatricolaTelaio());
        SolmrLogger.debug(this,"errors: "+errors);
        if (errors!=null && errors.size()!=0)
        {
          request.setAttribute("errors",errors);
        }
        else
        {
          session.setAttribute("common",common);
          response.sendRedirect(NEXT);
          return;
        }
      }
    }

  }
  catch(Exception e)
  {
    if ( e instanceof SolmrException )
    {
      setError(request,e.getMessage());
    }
    else
    {
      setError(request,"Si � verificato un errore di sistema");
    }
  }
  %><jsp:forward page="<%=VIEW%>" /><%
%>

<%!

  private void setError(HttpServletRequest request, String msg)
  {
    SolmrLogger.debug(this,"\n\n\n\n\n\n\n\n\n\n\nmsg="+msg+"\n\n\n\n\n\n\n\n");
    ValidationErrors errors=new ValidationErrors();
    errors.add("error", new ValidationError(msg));
    request.setAttribute("errors",errors);
  }

  private ValidationErrors validate(HttpServletRequest request,MacchinaVO macchinaVO,MatriceVO matriceVO)
  {
    ValidationErrors errors=new ValidationErrors();
    String matricolaTelaio=request.getParameter("matricolaTelaio");
    String matricolaMotore=request.getParameter("matricolaMotore");
    if (matricolaTelaio!=null)
    {
      matricolaTelaio=matricolaTelaio.trim();
    }
    if (matricolaMotore!=null)
    {
      matricolaMotore=matricolaMotore.trim();
    }
    SolmrLogger.debug(this,"matricolaTelaio="+matricolaTelaio);
    SolmrLogger.debug(this,"matricolaMotore="+matricolaMotore);
    SolmrLogger.debug(this,"isMatricolaTelaioNeeded(matriceVO)="+isMatricolaTelaioNeeded(matriceVO));
    SolmrLogger.debug(this,"isMatricolaMotoreNeeded(matriceVO)="+isMatricolaMotoreNeeded(matriceVO));
    if (isMatricolaTelaioNeeded(matriceVO) && !Validator.isNotEmpty(matricolaTelaio))
    {
      errors.add("matricolaTelaio",new ValidationError("Inserire la matricola del telaio"));
    }

    if (isMatricolaMotoreNeeded(matriceVO) && !Validator.isNotEmpty(matricolaMotore))
    {
      errors.add("matricolaMotore",new ValidationError("Inserire la matricola del motore"));
    }
    if (SolmrConstants.COD_BREVE_GENERE_MACCHINA_MAO.equals(matriceVO.getCodBreveGenereMacchina()) &&
        !Validator.isNotEmpty(matricolaTelaio) &&
          !Validator.isNotEmpty(matricolaMotore))
      {
        ValidationError error=new ValidationError("Inserire la matricola del telaio e la matricola del motore");
        errors.add("matricolaTelaio",error);
        errors.add("matricolaMotore",error);
      }
    macchinaVO.setMatricolaMotore(matricolaMotore);
    macchinaVO.setMatricolaTelaio(matricolaTelaio);
    return errors;
  }

  private boolean isMatricolaTelaioNeeded(MatriceVO matriceVO)
  {
    String codBreveGenereMacchina=matriceVO.getCodBreveGenereMacchina().trim();
    return SolmrConstants.COD_BREVE_GENERE_MACCHINA_T.equals(codBreveGenereMacchina) ||
           SolmrConstants.COD_BREVE_GENERE_MACCHINA_D.equals(codBreveGenereMacchina) ||
           SolmrConstants.COD_BREVE_GENERE_MACCHINA_MTS.equals(codBreveGenereMacchina) ||
           SolmrConstants.COD_BREVE_GENERE_MACCHINA_MTA.equals(codBreveGenereMacchina) ||
           SolmrConstants.COD_BREVE_GENERE_MACCHINA_MC.equals(codBreveGenereMacchina) ||
           SolmrConstants.COD_BREVE_GENERE_MACCHINA_MF.equals(codBreveGenereMacchina) ||
           SolmrConstants.COD_BREVE_GENERE_MACCHINA_MZ.equals(codBreveGenereMacchina);
  }

  private boolean isMatricolaMotoreNeeded(MatriceVO matriceVO)
  {
    String codBreveGenereMacchina=matriceVO.getCodBreveGenereMacchina().trim();
    return SolmrConstants.COD_BREVE_GENERE_MACCHINA_V.equals(codBreveGenereMacchina) ||
           SolmrConstants.COD_BREVE_GENERE_MACCHINA_MC.equals(codBreveGenereMacchina) ||
           SolmrConstants.COD_BREVE_GENERE_MACCHINA_MF.equals(codBreveGenereMacchina) ||
           SolmrConstants.COD_BREVE_GENERE_MACCHINA_MZ.equals(codBreveGenereMacchina);
  }
  private void annullaLoad(MacchinaVO macchinaVO, HttpServletRequest request){
    HttpSession session = request.getSession(false);

    SolmrLogger.debug(this,"annullaLoad");

    SolmrLogger.debug(this,"AVANTIRIMORCHIO");
    macchinaVO.setMatricolaTelaio(null);
    macchinaVO.setMatricolaMotore(null);

    if ( session.getAttribute("common")!=null ){
      HashMap vecSession = (HashMap) session.getAttribute("common");
      vecSession.put("MacchinaVO", macchinaVO);
      session.setAttribute("common",vecSession);
    }
  }
%>
