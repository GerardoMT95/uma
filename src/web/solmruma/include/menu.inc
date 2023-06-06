<%@ page import="it.csi.solmr.util.SolmrLogger" %>
<%@ page import="it.csi.solmr.dto.StringcodeDescription" %>
<%@ page import="it.csi.solmr.util.MessaggisticaUtils" %>
<%
{
  String __iridePageName = (String) request.getAttribute("__iridePageName");
  it.csi.solmr.presentation.security.Autorizzazione autorizzazione=null;

  if (__iridePageName!=null)
  {
    // Utilizzo un iridePageName direttamente al posto dell'autorizzazione per
    // evitare i problemi in cui una controller
    java.util.HashMap iride2mappings=(java.util.HashMap)application.getAttribute("iride2mappings");
    autorizzazione=(it.csi.solmr.presentation.security.Autorizzazione)
      iride2mappings.get(__iridePageName);
  }
  else
  {
    autorizzazione=(it.csi.solmr.presentation.security.Autorizzazione)
      request.getAttribute("__autorizzazione");
  }
  if (autorizzazione!=null)
  {
    autorizzazione.writeGeneralMenu(htmpl,request);
  }
}
%>

<%
	// Visualizzazione testata messaggi utente
    try {
      // prendo i dati da visualizzare dalla sessione
      StringcodeDescription message = MessaggisticaUtils.getMessaggiTestata(session);
	  SolmrLogger.debug(this, "-- messaggio desc " + message.getDescription());
      if (message != null) {
        String messaggiDaLeggere = null;

        if (message.getCode() != null && !message.getCode().equals("0")) {
          if ("1".equals(message.getCode())) {
            messaggiDaLeggere = "C'è un messaggio da leggere";
          }else {
            messaggiDaLeggere = "Ci sono " + message.getCode() + " messaggi da leggere";
          }
        }

        // Aggiunta del blocco js della messaggistica
        htmpl.set("messaggistica", MessaggisticaUtils.getHtmlMessaggistica(session.getServletContext(), message.getDescription(),
                messaggiDaLeggere), null);
      }
    }catch (Exception e) {
    	SolmrLogger.error(this, "Errore richiamo messaggistica " + SolmrLogger.getStackTrace(e));
    }
%>