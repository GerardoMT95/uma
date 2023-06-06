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
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.anag.AnagErrors" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<jsp:useBean id="serraVO" scope="page"
             class="it.csi.solmr.dto.uma.SerraVO">
  <jsp:setProperty name="serraVO" property="*" />
</jsp:useBean>
<%

  String iridePageName = "giorniRiscaldSerraCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  SolmrLogger.debug(this, "BEGIN giorniRiscaldSerraCtrl");
  
  UmaFacadeClient umaClient = new UmaFacadeClient();
  String url="/ditta/ctrl/elencoSerreCtrl.jsp";
  String viewUrl="/ditta/view/giorniRiscaldSerraView.jsp";
  String elenco="/ditta/ctrl/elencoSerreCtrl.jsp";
  String elencoBis="/ditta/ctrl/elencoSerreBisCtrl.jsp";
  String elencoHtm="../../ditta/layout/elencoSerre.htm";
  String elencoBisHtm="../../ditta/layout/elencoSerreBis.htm";
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  
   
  if(request.getParameter("salva.x")!=null){	  
    SolmrLogger.debug(this, "-- CASO salva giorniRiscaldSerraCtrl");    
	// TODO : salvataggio dati su DB_SERRA_RISCALDAMENTO
	List<SerraRiscaldamentoVO> serraRiscaldamentoList = new ArrayList<SerraRiscaldamentoVO>();
	String idSerra = request.getParameter("idSerra");
	Long idSerraL = null;
	if(idSerra != null) {
		idSerraL = Long.parseLong(idSerra);
		SolmrLogger.debug(this, "-- idSerraL ="+idSerraL);
	}
       
    // Controllo se sono stati indicati dei valori per i giorni di riscaldamento e valorizzo la Lista 
    if(request.getParameter("ggDiRiscaldGennaio") != null && !request.getParameter("ggDiRiscaldGennaio").trim().isEmpty()){
    	SolmrLogger.debug(this, " -- ggDiRiscaldGennaio ="+request.getParameter("ggDiRiscaldGennaio"));
    	SerraRiscaldamentoVO riscald = new SerraRiscaldamentoVO();
    	riscald.setIdSerra(idSerraL);
    	riscald.setMese("GENNAIO");
    	riscald.setGiorni(Long.parseLong(request.getParameter("ggDiRiscaldGennaio")));
    	serraRiscaldamentoList.add(riscald);
    } 
    if(request.getParameter("ggDiRiscaldFebbraio") != null && !request.getParameter("ggDiRiscaldFebbraio").trim().isEmpty()){
    	SolmrLogger.debug(this, " -- ggDiRiscaldFebbraio ="+request.getParameter("ggDiRiscaldFebbraio"));
    	SerraRiscaldamentoVO riscald = new SerraRiscaldamentoVO();
    	riscald.setIdSerra(idSerraL);
    	riscald.setMese("FEBBRAIO");
    	riscald.setGiorni(Long.parseLong(request.getParameter("ggDiRiscaldFebbraio")));
    	serraRiscaldamentoList.add(riscald);
    }
    if(request.getParameter("ggDiRiscaldMarzo") != null && !request.getParameter("ggDiRiscaldMarzo").trim().isEmpty()){
    	SolmrLogger.debug(this, " -- ggDiRiscaldMarzo ="+request.getParameter("ggDiRiscaldMarzo"));
    	SerraRiscaldamentoVO riscald = new SerraRiscaldamentoVO();
    	riscald.setIdSerra(idSerraL);
    	riscald.setMese("MARZO");
    	riscald.setGiorni(Long.parseLong(request.getParameter("ggDiRiscaldMarzo")));
    	serraRiscaldamentoList.add(riscald);
    }
    if(request.getParameter("ggDiRiscaldAprile") != null && !request.getParameter("ggDiRiscaldAprile").trim().isEmpty()){
    	SolmrLogger.debug(this, " -- ggDiRiscaldAprile ="+request.getParameter("ggDiRiscaldAprile"));
    	SerraRiscaldamentoVO riscald = new SerraRiscaldamentoVO();
    	riscald.setIdSerra(idSerraL);
    	riscald.setMese("APRILE");
    	riscald.setGiorni(Long.parseLong(request.getParameter("ggDiRiscaldAprile")));
    	serraRiscaldamentoList.add(riscald);
    }
    if(request.getParameter("ggDiRiscaldMaggio") != null && !request.getParameter("ggDiRiscaldMaggio").trim().isEmpty()){
    	SolmrLogger.debug(this, " -- ggDiRiscaldMaggio ="+request.getParameter("ggDiRiscaldMaggio"));
    	SerraRiscaldamentoVO riscald = new SerraRiscaldamentoVO();
    	riscald.setIdSerra(idSerraL);
    	riscald.setMese("MAGGIO");
    	riscald.setGiorni(Long.parseLong(request.getParameter("ggDiRiscaldMaggio")));
    	serraRiscaldamentoList.add(riscald);
    }
    if(request.getParameter("ggDiRiscaldGiugno") != null && !request.getParameter("ggDiRiscaldGiugno").trim().isEmpty()){
    	SolmrLogger.debug(this, " -- ggDiRiscaldGiugno ="+request.getParameter("ggDiRiscaldGiugno"));
    	SerraRiscaldamentoVO riscald = new SerraRiscaldamentoVO();
    	riscald.setIdSerra(idSerraL);
    	riscald.setMese("GIUGNO");
    	riscald.setGiorni(Long.parseLong(request.getParameter("ggDiRiscaldGiugno")));
    	serraRiscaldamentoList.add(riscald);
    }
    if(request.getParameter("ggDiRiscaldLuglio") != null && !request.getParameter("ggDiRiscaldLuglio").trim().isEmpty()){
    	SolmrLogger.debug(this, " -- ggDiRiscaldLuglio ="+request.getParameter("ggDiRiscaldLuglio"));
    	SerraRiscaldamentoVO riscald = new SerraRiscaldamentoVO();
    	riscald.setIdSerra(idSerraL);
    	riscald.setMese("LUGLIO");
    	riscald.setGiorni(Long.parseLong(request.getParameter("ggDiRiscaldLuglio")));
    	serraRiscaldamentoList.add(riscald);
    }
    if(request.getParameter("ggDiRiscaldAgosto") != null && !request.getParameter("ggDiRiscaldAgosto").trim().isEmpty()){
    	SolmrLogger.debug(this, " -- ggDiRiscaldAgosto ="+request.getParameter("ggDiRiscaldAgosto"));
    	SerraRiscaldamentoVO riscald = new SerraRiscaldamentoVO();
    	riscald.setIdSerra(idSerraL);
    	riscald.setMese("AGOSTO");
    	riscald.setGiorni(Long.parseLong(request.getParameter("ggDiRiscaldAgosto")));
    	serraRiscaldamentoList.add(riscald);
    }
    if(request.getParameter("ggDiRiscaldSettembre") != null && !request.getParameter("ggDiRiscaldSettembre").trim().isEmpty()){
    	SolmrLogger.debug(this, " -- ggDiRiscaldSettembre ="+request.getParameter("ggDiRiscaldSettembre"));
    	SerraRiscaldamentoVO riscald = new SerraRiscaldamentoVO();
    	riscald.setIdSerra(idSerraL);
    	riscald.setMese("SETTEMBRE");
    	riscald.setGiorni(Long.parseLong(request.getParameter("ggDiRiscaldSettembre")));
    	serraRiscaldamentoList.add(riscald);
    }
    if(request.getParameter("ggDiRiscaldOttobre") != null && !request.getParameter("ggDiRiscaldOttobre").trim().isEmpty()){
    	SolmrLogger.debug(this, " -- ggDiRiscaldOttobre ="+request.getParameter("ggDiRiscaldOttobre"));
    	SerraRiscaldamentoVO riscald = new SerraRiscaldamentoVO();
    	riscald.setIdSerra(idSerraL);
    	riscald.setMese("OTTOBRE");
    	riscald.setGiorni(Long.parseLong(request.getParameter("ggDiRiscaldOttobre")));
    	serraRiscaldamentoList.add(riscald);
    }
    if(request.getParameter("ggDiRiscaldNovembre") != null && !request.getParameter("ggDiRiscaldNovembre").trim().isEmpty()){
    	SolmrLogger.debug(this, " -- ggDiRiscaldNovembre ="+request.getParameter("ggDiRiscaldNovembre"));
    	SerraRiscaldamentoVO riscald = new SerraRiscaldamentoVO();
    	riscald.setIdSerra(idSerraL);
    	riscald.setMese("NOVEMBRE");
    	riscald.setGiorni(Long.parseLong(request.getParameter("ggDiRiscaldNovembre")));
    	serraRiscaldamentoList.add(riscald);
    }
    if(request.getParameter("ggDiRiscaldDicembre") != null && !request.getParameter("ggDiRiscaldDicembre").trim().isEmpty()){
    	SolmrLogger.debug(this, " -- ggDiRiscaldDicembre ="+request.getParameter("ggDiRiscaldDicembre"));
    	SerraRiscaldamentoVO riscald = new SerraRiscaldamentoVO();
    	riscald.setIdSerra(idSerraL);
    	riscald.setMese("DICEMBRE");
    	riscald.setGiorni(Long.parseLong(request.getParameter("ggDiRiscaldDicembre")));
    	serraRiscaldamentoList.add(riscald);
    }
        
    try{
	    // Salvo i giorni di riscaldamento	    
	    SolmrLogger.debug(this, " -- Salvo i giorni di riscaldamento");	
	    umaClient.salvaRiscaldSerraByIdSerra(serraRiscaldamentoList, idSerraL, ruoloUtenza);      		    
	    
	    // Recupero i giorni salvati per visualizzarli
	    SolmrLogger.debug(this, "--  Recupero i giorni salvati per visualizzarli");
        List<SerraRiscaldamentoVO> giorniRiscaldamentoDb = umaClient.getGiorniRiscaldSerraByIdSerra(idSerraL);
	    request.setAttribute("giorniRiscaldamentoDb", giorniRiscaldamentoDb);
    }
    catch(SolmrException sexc){  
      SolmrLogger.error(this, "-- Exception in giorniRiscaldSerraCtrl ="+sexc.getMessage());	
      ValidationException valEx = new ValidationException("Eccezione ="+sexc.getMessage(),viewUrl);
      valEx.addMessage(sexc.toString(),"exception");
      throw valEx;            
    }
    catch(Exception e){   
      SolmrLogger.error(this, "-- Exception in giorniRiscaldSerraCtrl ="+e.getMessage());	
      ValidationException valEx = new ValidationException();
      valEx.addMessage(e.getMessage(),"exception");
      throw valEx;
    }
    String forwardUrl=elencoHtm;
    if ("bis".equalsIgnoreCase(request.getParameter("pageFrom"))){
      forwardUrl=elencoBisHtm;
    }
    session.setAttribute("notifica","Modifica eseguita con successo");
    response.sendRedirect(forwardUrl);
    return;
  }
  else{
    if (request.getParameter("annulla.x")!=null){
      SolmrLogger.debug(this, "-- CASO annulla giorniRiscaldSerraCtrl");
      SolmrLogger.debug(this, "-- request.getParameter(pageFrom) ="+request.getParameter("pageFrom"));
      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom"))){
        response.sendRedirect(elencoBisHtm);
        SolmrLogger.debug(this, "END giorniRiscaldSerraCtrl");
      }
      else
      {
        response.sendRedirect(elencoHtm);
        SolmrLogger.debug(this, "END giorniRiscaldSerraCtrl");
      }
      return;
    }
    // Se entro nella pagina
    else{   
      SolmrLogger.debug(this, "-- CASO entro nella pagina");
      serraVO=(SerraVO) request.getAttribute("serraVO");
      convertForValidation(umaClient, serraVO);
      request.setAttribute("serraVO",serraVO);
            
      // Recupero i giorni salvati per visualizzarli
      SolmrLogger.debug(this, "-- Recupero i giorni salvati per visualizzarli");
      List<SerraRiscaldamentoVO> giorniRiscaldamentoDb = umaClient.getGiorniRiscaldSerraByIdSerra(serraVO.getIdSerra());
      request.setAttribute("giorniRiscaldamentoDb", giorniRiscaldamentoDb);
      
      SolmrLogger.debug(this, "END giorniRiscaldSerraCtrl");
    }
  }
%>


<jsp:forward page="<%=viewUrl%>"/>
<%!
private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException(msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}
private void convertForValidation(UmaFacadeClient umaFacadeClient, SerraVO serraVO){
	SolmrLogger.debug(this, "BEGIN convertForValidation");
  
    serraVO.setVolumeMetriCubiStr(""+serraVO.getVolumeMetriCubi());

    if (serraVO.getDataCarico()!=null){
      serraVO.setDataCaricoStr(""+DateUtils.formatDate(serraVO.getDataCarico()));
    }
    
    SolmrLogger.debug(this, "END convertForValidation");
}
%>
