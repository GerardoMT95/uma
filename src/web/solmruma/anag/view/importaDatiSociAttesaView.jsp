<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  public static final String LAYOUT_ATTESA = "/anag/layout/importaDatiAttesa.htm";  
  private static final String NEXT_PAGE = "../layout/importaDatiFine.htm";
%>

<%
   SolmrLogger.debug(this, " BEGIN importaDatiSociAttesaView");  
   Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT_ATTESA);
%><%@include file = "/include/menu.inc" %><%

  //Visualizzo immediatamente la form per l'attesa
  SolmrLogger.debug(this, "-- Visualizzo immediatamente la form per l'attesa dopo la scelta importa dati soci");
  out.print(htmpl.text());
  out.flush();  
  
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  
  String importaDatiSoci = (String)request.getAttribute("importaDatiSoci");
  SolmrLogger.debug(this, "-- importaDatiSoci ="+importaDatiSoci);
  
  // -- Note : se arriviamo su questa pagina 'importaDatiSoci' DEVE essere valorizzato 
  if(importaDatiSoci != null && !importaDatiSoci.equals("")){
    SolmrLogger.debug(this, "---  chiamare PACK_IMPORTA_DATI");
        
    session.removeAttribute("common");           
    // memorizzo il risultato per la pagina finale
    Hashtable common = new Hashtable();
    
    UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
    Long result = null;
    try{
        SolmrLogger.debug(this, "---- Chiamata a PACK_IMPORTA_DATI.IMPORTA_DATI");       
        Long idDittaUma = dittaVO.getIdDittaUMA();
        result = umaFacadeClient.sincronizzaProcedimentoPL(idDittaUma, ruoloUtenza, importaDatiSoci);
      }
      catch(SolmrException ex){
        SolmrLogger.error(this, "-- SolmrException con la chiamata di PACK_IMPORTA_DATI.IMPORTA_DATI: "+ex.getMessage());                
          
        //Errori da visualizzare nella pagina finale
   		result = new Long(SolmrConstants.RISULTATO_PL_IMPORTA_DATI_ERRORE_GRAVE);
    	SolmrLogger.debug(this,"******* tipo errore: " + result);
    	SolmrLogger.debug(this,"******* tipo errore: " + result);
    	String msgCreazione = ex.getMessage();
    	common.put("risCreazione", "" + result);
    	common.put("msgCreazione", msgCreazione);
    	session.setAttribute("common", common);   
    	
    	%>
    	<script language="javascript1.2">
  			window.document.form1.action='<%=NEXT_PAGE%>';
  			window.document.form1.submit();
		</script>
		<%  
  		// --> pagina finale con risultato dell'importa
  		SolmrLogger.debug(this, "-- vado sulla pagina finale con il risultato dell'importa");
  		out.flush();
  		SolmrLogger.debug(this, "   END sceltaImportaDatiSociView");     
      }
      catch(Exception ex){
        SolmrLogger.error(this, "-- Exception con la chiamata a PACK_IMPORTA_DATI ="+ex.getMessage());
        common.put("risCreazione", "" + SolmrConstants.RISULTATO_PL_ERRORE_SISTEMA);
        common.put("msgCreazione", ex.getMessage());
        session.setAttribute("common", common);  
        
        %>
    	<script language="javascript1.2">
  			window.document.form1.action='<%=NEXT_PAGE%>';
  			window.document.form1.submit();
		</script>
		<%  
  		// --> pagina finale con risultato dell'importa
  		SolmrLogger.debug(this, "-- vado sulla pagina finale con il risultato dell'importa");
  		out.flush();
  		SolmrLogger.debug(this, "   END sceltaImportaDatiSociView");    
      }

      if (result != null && result.longValue() == new Long(SolmrConstants.RISULTATO_PL_NESSUN_ERRORE).longValue()){
         SolmrLogger.debug(this, "-- la chiamata a PACK_IMPORTA_DATI.IMPORTA_DATI e' andata a buon fine");      
         
         // -- memorizzo il risultato andato a buon fine
         common.put("risCreazione", "" + result);
         common.put("msgCreazione", SolmrConstants.MSG_PL_IMPORTA_NESSUN_ERRORE);
         session.setAttribute("common", common); 
         
         %>
      
        <script language="javascript1.2">
          window.document.form1.action='<%=NEXT_PAGE%>';
          window.document.form1.submit();
       </script>
      <%     
        SolmrLogger.debug(this, "   END importaDatiSociAttesaView");
        out.flush();           
   }
    
    HtmplUtil.setErrors(htmpl, errors, request);
        
  }
  
  
  
%>
