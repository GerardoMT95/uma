<%@ page language="java" %>
<%@ page import="it.csi.solmr.util.SolmrLogger" %>
<%@ page import="it.csi.iride2.policy.entity.Identita" %>
<%@ page import="java.util.StringTokenizer" %>
<%!
  public static String VIEW_URL="../view/sceltaRuoloPEP.jsp";
%>

<%
    SolmrLogger.debug(this,"   BEGIN loginRupar.jsp lettura identita restituita da OP");
    String sIdentita = (String) session.getAttribute("edu.yale.its.tp.cas.client.filter.user");
    SolmrLogger.info(this,"letta identita: " +sIdentita );
    Identita identita =null;
    try {
        identita = new Identita(sIdentita);
    }
    catch (Exception ex)
    {
      SolmrLogger.debug(this,"patch per opAuthop");

      StringTokenizer sTok = new StringTokenizer(sIdentita,"~");
      //skip elelmenti
      sTok.nextElement();
      sTok.nextElement();
      sTok.nextElement();
      sTok.nextElement();
      //mac
      String mac =(String)sTok.nextElement();
      //skip elelmenti
      sTok.nextElement();
      //rap Interna
      String rappresentazioneInterna =(String)sTok.nextElement();

      SolmrLogger.debug(this,"identita ricreata: " +rappresentazioneInterna+ "/" + mac);
      identita = new Identita(rappresentazioneInterna+ "/" + mac);
    }

    SolmrLogger.info(this,"identita ok");

    session.setAttribute("identita",identita);


    /** @todo riunie in Login */


    response.sendRedirect(VIEW_URL);
%>
