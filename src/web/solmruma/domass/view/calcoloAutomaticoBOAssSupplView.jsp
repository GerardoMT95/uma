
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
  private static final String NEXT_PAGE="../layout/calcoloAutomaticoBOfineAssSuppl.htm";
%>
<%
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("domass/layout/calcoloAutomaticoAssegnazioneSuppl.htm");
%><%@include file = "/include/menu.inc" %>
<%  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  SolmrLogger.debug(this, "   BEGIN calcoloAutomaticoBOAssSupplView");
  
  UmaFacadeClient client = new UmaFacadeClient();
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();
  Long idUtente=ruoloUtenza.getIdUtente();
  htmpl.set("idDittaUma",idDittaUma==null?null:idDittaUma.toString());
  
  
 //Titolo del Supplemento (Supplemento anno xxxx o Supplemento Maggiorazione)
 SolmrLogger.debug(this,"-- Setto il titolo del Supplemento");
 Hashtable common = (Hashtable) session.getAttribute("common");
 String tipoAssegnazioneSupplementare ="";
 if(common != null){
	  String notifica = (String) common.get("notifica");
	  SolmrLogger.debug(this, "--- notifica: " + notifica);
	  if(notifica.equalsIgnoreCase("supplementare")){
		 htmpl.newBlock("blkTitoloAssSuppl");
		 htmpl.set("blkTitoloAssSuppl.anno", ""+DateUtils.getCurrentYear());
		 htmpl.set("anno",""+DateUtils.getCurrentYear());
		 tipoAssegnazioneSupplementare = SolmrConstants.ASSESGNAZIONE_SUPPLEMENTARE_ANNO;
	  }
	  else if(notifica.equalsIgnoreCase("supplementareMaggiorazione")){
		 htmpl.newBlock("blkTitoloAssSupplementareMaggiorazione");
		 UmaFacadeClient umaClient = new UmaFacadeClient();
		 CampagnaMaggiorazioneVO campagnaMaggVo = umaClient.getCampagnaMaggiorazionebySysdate();
		 if(campagnaMaggVo != null){
		   htmpl.set("blkTitoloAssSupplementareMaggiorazione.titoloAssSupplMagg", campagnaMaggVo.getTitoloBreveMaggiorazione().toUpperCase());
		 }
		 tipoAssegnazioneSupplementare = SolmrConstants.ASSESGNAZIONE_SUPPLEMENTARE_MAGGIORAZIONE;
	  }
 }
  
  
  
  out.print(htmpl.text());
  out.flush();
  
  String daNextPage = NEXT_PAGE;
  
  Long idDomandaAssegnazione = null;
  Long numSupplemento = null; 
  try{
	SolmrLogger.debug(this, "-- tipoAssegnazioneSupplementare ="+tipoAssegnazioneSupplementare); 
    SolmrLogger.debug(this,"-- chiamata a calcoloAutomatico");    
    Long[] cdOutputCalcoloSupplemento = client.calcoloAutomaticoAssSupPL(idDittaUma,idUtente,null,tipoAssegnazioneSupplementare);
    // nella prima posizione ci sarà 'idDomandaAssegnazione'    
    idDomandaAssegnazione = cdOutputCalcoloSupplemento[0];
    SolmrLogger.debug(this, "-- idDomandaAssegnazione restituita da PCK_CALCOLO_SUPPLEMETO = "+idDomandaAssegnazione);
    // nella seconda posizione ci sarà 'numSupplemento'
    numSupplemento = cdOutputCalcoloSupplemento[1];
    SolmrLogger.debug(this, "-- numSupplemento restituita da PCK_CALCOLO_SUPPLEMETO = "+numSupplemento);     
  }
  catch(SolmrException e)
  {
    SolmrLogger.error(this, "--- SolmrException in calcoloAutomaticoBOAssSupplView ="+e.getMessage());
    daNextPage = "../../domass/layout/assegnazioni.htm";
    %>
    <script language="javascript1.2">
        alert("<%=e.getMessage()%>");
    </script>
    <%
    //return;
  }
  finally{
    SolmrLogger.debug(this, "   END calcoloAutomaticoBOAssSupplView");
  }
    %>
<script language="javascript1.2">
  window.document.form1.action='<%=daNextPage%>';
  window.document.form1.idDomAss.value='<%=idDomandaAssegnazione%>';
  window.document.form1.numSupplemento.value='<%=numSupplemento%>';
  window.document.form1.submit();
</script>
