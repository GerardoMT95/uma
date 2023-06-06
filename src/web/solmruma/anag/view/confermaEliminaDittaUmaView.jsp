<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%!
  public static final String MSG_ELIMINA_OK="Eliminazione avvenuta correttamente";
  public static final String MSG_ELIMINA_KO="Eliminazione non avvenuta";
  public static final String PAGE_TO_OK="../../anag/layout/ricercaAzienda.htm";
  public static final String PAGE_TO_KO="../../anag/layout/dettaglioAzienda.htm";
%>
<%
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).
                getHtmpl("/anag/layout/confermaEliminaDittaUma.htm");
	%>
	  <%@include file = "/include/menu.inc" %>
	<%
	
  boolean error=errErrorValExc(htmpl, request, exception);
  if (request.getParameter("conferma.x")!=null)
  {
    SolmrLogger.debug(this,"blkEliminazione-------------------------->");
    htmpl.newBlock("blkEliminazione");
    htmpl.set("blkEliminazione.msg",error?MSG_ELIMINA_KO:MSG_ELIMINA_OK);
    htmpl.set("blkEliminazione.pageTo",error?PAGE_TO_KO:PAGE_TO_OK);
  }
  else
  {
    htmpl.newBlock("blkConferma");
  }
%>
<%= htmpl.text()%>
<%!
  private boolean errErrorValExc(Htmpl htmpl, HttpServletRequest request, Throwable exc)
  {
    SolmrLogger.debug(this,"\n\n\n\n *********************************** 2");
    SolmrLogger.debug(this,"errErrorValExc()");

    if (exc instanceof it.csi.solmr.exception.ValidationException){

      ValidationErrors valErrs = new ValidationErrors();
      valErrs.add("error", new ValidationError(exc.getMessage()) );

      HtmplUtil.setErrors(htmpl, valErrs, request);
      return true;
    }
    return false;
  }
%>