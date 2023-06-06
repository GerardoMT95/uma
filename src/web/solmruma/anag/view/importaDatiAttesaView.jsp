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
  public static final String LAYOUT = "/anag/layout/importaDatiAttesa.htm";
  private static final String NEXT_PAGE = "../layout/importaDatiFine.htm";
  private static final String PAGE_SCELTA_IMPORT_SOCI ="../layout/sceltaImportaDatiSoci.htm";
%>

<%
  SolmrLogger.debug(this, "    BEGIN importaDatiAttesaView.jsp");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

  HashMap hmCommon = null;


  //Visualizzo immediatamente la form per l'attesa
  SolmrLogger.debug(this, "-- Visualizzo immediatamente la form per l'attesa");
  out.print(htmpl.text());
  out.flush();

  //Oggetto tenuto in sessione creato in sincronizza dati
  if (session.getAttribute("common") instanceof HashMap)
  {
    hmCommon = (HashMap) session.getAttribute("common");

    if (hmCommon.get("dataDichiarazioneConsistenza") == null)
    {
      //Oggetto common non proveniente da modifica regime aiuto
      hmCommon = new HashMap();
    }
  }
  else
  {
    //Oggetto common contenente le informazioni per la funzionalità di sincronizza dati
    hmCommon = new HashMap();
  }
  session.removeAttribute("common");
  Hashtable common = new Hashtable();

  Long idDittaUma = dittaVO.getIdDittaUMA();
  Long annoAssegnazione = new Long(DateUtils.getCurrentYear().longValue());
  String tipoControllo = SolmrConstants.TIPO_CONTROLLO_PL_B;
  String tipoFase = SolmrConstants.TIPO_FASE_PL_IMPORTA_DATI;
  Long idUtenteAggiornamento = ruoloUtenza.getIdUtente();

  //effettuo i controlli
  SolmrLogger.debug(this, "idDittaUma: " +idDittaUma);
  SolmrLogger.debug(this, "annoAssegnazione: " + annoAssegnazione);
  SolmrLogger.debug(this, "tipoControllo: " + tipoControllo);
  SolmrLogger.debug(this, "tipoFase: " + tipoFase);

  Long result = null;
  try{    
    // ------ Chiamata a PACK_CONTROLLI
    SolmrLogger.debug(this, "--- Chiamata a PACK_CONTROLLI ----");
    result = umaFacadeClient.preControlliPraticaPL(idDittaUma, annoAssegnazione, tipoControllo, tipoFase);
  }
  catch(SolmrException agriExc){
    SolmrLogger.error(this, "-- SolmrException con la chiamata a PACK_CONTROLLI ="+agriExc.getMessage());
    
    //Errori da visualizzare nella pagina finale
    result = new Long(SolmrConstants.RISULTATO_PL_IMPORTA_DATI_ERRORE_GRAVE);
    SolmrLogger.debug(this,"******* tipo errore: " + result);
    SolmrLogger.debug(this,"******* tipo errore: " + result);
    String msgCreazione = agriExc.getMessage();
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
  		SolmrLogger.debug(this, "   END importaDatiAttesaView");  
  }
  catch(Exception ex){
    SolmrLogger.error(this, "-- Exception con la chiamata a PACK_CONTROLLI ="+ex.getMessage());
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
  		SolmrLogger.debug(this, "   END importaDatiAttesaView");  
  }     

  SolmrLogger.debug(this, "-- result PACK_CONTROLLI ="+result);
  // PACK_CONTROLLI è andato a buon fine
  if (result != null && result.longValue() == new Long(SolmrConstants.RISULTATO_PL_NESSUN_ERRORE).longValue()){
      SolmrLogger.debug(this, "--- Il PACK_CONTROLLI non ha restituito errori");
      
      // Controllare se l'azienda è una cooperativa o un consorzio, in tal caso andare sulla pagina intermedia di scelta importa dati soci     
      boolean isConsorzioCooperativa = umaFacadeClient.isDittaConsorzioCooperativa(dittaVO.getIdAzienda());
      SolmrLogger.debug(this, "-- isConsorzioCooperativa ="+isConsorzioCooperativa);
     
    // -------- CASO l'azienda e' un CONSORZIO o una COOPERATIVA
    if(isConsorzioCooperativa){
        SolmrLogger.debug(this, "-- L'azienda e' una COOPERATIVA o un CONSORZIO");
        SolmrLogger.debug(this, "-- passare alla pagina intermedia, per scegliere se importare i dati dei terreni dei soci o no");
        %>

		<script language="javascript1.2">
		  window.document.form1.action='<%=PAGE_SCELTA_IMPORT_SOCI%>';
		  window.document.form1.submit();
		</script>
		<%		  
		  out.flush();		  
		  SolmrLogger.debug(this, "  END importaDatiAttesaView");
    }// fine caso CONSORZIO o COOPERATIVA      
    else{    
      // -------- CASO l'azienda NON e' un CONSORZIO o una COOPERATIVA   
      // --> passare in input 'N' per il parametro 'importaDatiSoci'
      try{
        SolmrLogger.debug(this, "---- Chiamata a PACK_IMPORTA_DATI.IMPORTA_DATI");
        String importaDatiSoci ="N";
        result = umaFacadeClient.sincronizzaProcedimentoPL(idDittaUma, ruoloUtenza, importaDatiSoci);
        SolmrLogger.debug(this, "-- result di PACK_IMPORTA_DATI ="+result);
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
  		SolmrLogger.debug(this, "   END importaDatiAttesaView");    
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
  		SolmrLogger.debug(this, "   END importaDatiAttesaView");   
      } 
		
	  // E' stato tornato in output il valore 0	
      if (result.longValue() == new Long(SolmrConstants.RISULTATO_PL_NESSUN_ERRORE).longValue()){
         SolmrLogger.debug(this, "-- la chiamata a PACK_IMPORTA_DATI.IMPORTA_DATI e' andata a buon fine");   
         
         // -- memorizzo il risultato andato a buon fine della chiamata ai PL
         SolmrLogger.debug(this, "-- Memorizzo il risultato andato a buon fine");
         common.put("risCreazione", "" + result);
         common.put("msgCreazione", SolmrConstants.MSG_PL_IMPORTA_NESSUN_ERRORE);
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
  		SolmrLogger.debug(this, "   END importaDatiAttesaView");   
    }// fine CASO i PL non hanno dato errori
     
  }// fine CASO l'azienda NON è una COOPERATIVA o un CONSORZIO

  HtmplUtil.setErrors(htmpl, errors, request);
  
}// fine CASO il PACK_CONTROLLI non ha restituito errori
  
%>