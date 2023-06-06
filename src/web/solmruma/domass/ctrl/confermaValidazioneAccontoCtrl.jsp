<%@ page language="java" contentType="text/html"%>
<%@page import="it.csi.solmr.dto.uma.DomandaAssegnazione"%>
<%@page import="it.csi.solmr.etc.SolmrConstants"%><%!// Costanti
  private static final String VIEW = "/domass/view/confermaValidazioneAccontoView.jsp";
  private static final String NEXT = "../layout/verificaAssegnazioneAccontoFoglio.htm";%>
<%
  String iridePageName = "confermaValidazioneAccontoCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%
  if (request.getParameter("confermaValida")!=null)
  {
    // Valido la domanda ==> Mando sulla pagina di scelta del foglio ==> se l'utente è
    // un intermediario o una PA (con un suo foglio riga valido), la domanda viene validata 
    // immediatamente, altrimenti se è un PA senza foglio gli viene presentata la pagina
    // incui sceglie se utilizzare il foglio riga di qualche altro utente o di crearne uno
    // nuovo    
    response.sendRedirect(NEXT);
    return;
  }
  if (request.getParameter("annullaValida")!=null)
  {
    DomandaAssegnazione accontoVO=(DomandaAssegnazione)request.getAttribute("accontoVO");
    if (accontoVO.getIdStatoDomanda().longValue()==new Long(SolmrConstants.ID_STATO_DOMANDA_ATTESA_VAL_PA).longValue())
    {
      response.sendRedirect("../layout/verificaAssegnazioneAccontoValida.htm");
    }
    else
    {
      response.sendRedirect("../layout/verificaAssegnazioneAccontoSalvata.htm");
    }
    return;
  }
%>
<jsp:forward page="<%=VIEW%>" />