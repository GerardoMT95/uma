
<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%!
  private static final String NEXT_PAGE="../layout/calcoloAutomaticoFOfine.htm";
%>
<%
  UmaFacadeClient client = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("domass/layout/calcoloAutomatico.htm");
%><%@include file = "/include/menu.inc" %>
<%  
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
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
    SolmrLogger.debug(this,"\n\ncalcoloAutomatico");
    SolmrLogger.debug(this,"client="+client);
    idDomAss=client.calcoloAutomaticoPL(idDittaUma,idUtente,idUtente);
    SolmrLogger.debug(this,"done.\n\n");
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
  window.document.form1.idDomAss.value='<%=idDomAss%>';
  window.document.form1.submit();
</script>
