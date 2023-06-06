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
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!

  public static final String LAYOUT="macchina/layout/MacchinaUsataTrovataDatiCasoR-ASM.htm";

%>

<%



//---------------- Ricerca in sessione delle variabili necessarie --------------

  HashMap common=(HashMap) session.getAttribute("common");

  MacchinaVO macchinaVO=(MacchinaVO)get(common,"macchinaVO");

  DittaUMAVO dittaProvenienzaVO=(DittaUMAVO)get(common,"dittaProvenienzaVO");

  DittaUMAVO dittaUmaVO=(DittaUMAVO)session.getAttribute("dittaUmaVO");

//------------------------------------------------------------------------------

  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  String pathToFollow=(String)request.getAttribute("pathToFollow");

  SolmrLogger.debug(this,"macchinaVO.getDatiMacchinaVO()="+macchinaVO.getDatiMacchinaVO());

  HtmplUtil.setValues(htmpl,macchinaVO.getDatiMacchinaVO(),pathToFollow);

  HtmplUtil.setValues(htmpl,macchinaVO,pathToFollow);

  errErrorValExc(htmpl, request, exception);

%>



<%=htmpl.text()%>



<%!

  private void errErrorValExc(Htmpl htmpl, HttpServletRequest request, Throwable exc)

  {

    SolmrLogger.debug(this,"\n\n\n\n *********************************** 2");

    SolmrLogger.debug(this,"errErrorValExc()");



    if (exc instanceof it.csi.solmr.exception.ValidationException)

    {

      ValidationErrors valErrs = new ValidationErrors();

      valErrs.add("error", new ValidationError(exc.getMessage()) );



      HtmplUtil.setErrors(htmpl, valErrs, request);

    }

  }

  private Object get(HashMap common,String name)

  {

    if (common==null)

    {

      return null;

    }

    return common.get(name);

  }

%>

