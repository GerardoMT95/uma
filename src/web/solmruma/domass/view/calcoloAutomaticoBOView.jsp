
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
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%!
  private static final String NEXT_PAGE="../layout/calcoloAutomaticoBOfine.htm";
%>
<%
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("domass/layout/calcoloAutomatico.htm");
%><%@include file = "/include/menu.inc" %>
<%  
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  UmaFacadeClient client = new UmaFacadeClient();
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  Long idUtente=ruoloUtenza.getIdUtente();
  htmpl.set("idDittaUma",idDittaUma==null?null:idDittaUma.toString());
  htmpl.set("anno",""+DateUtils.getCurrentYear());
  out.print(htmpl.text());
  out.flush();
  Long idDomAss=null;
  String daNextPage = NEXT_PAGE;
  try
  {
    idDomAss=client.calcoloAutomaticoPL(idDittaUma,idUtente,null);
    client.copiaConsumiRimanenzeDaAccontoInAssegnazioneBase(idDomAss,
      dittaUMAAziendaVO.getIdDittaUMA().longValue(),
      ruoloUtenza.getIdUtente());
  }
  catch(SolmrException e)
  {
    daNextPage = "../../domass/layout/assegnazioni.htm";
    %>
    <script language="javascript1.2">
        alert("<%=e.getMessage()%>");
    </script>
    <%
    //return;
  }
    %>
<script language="javascript1.2">
  window.document.form1.action='<%=daNextPage%>';
  document.form1.idDomAss.value='<%=idDomAss%>';
  window.document.form1.submit();
</script>
