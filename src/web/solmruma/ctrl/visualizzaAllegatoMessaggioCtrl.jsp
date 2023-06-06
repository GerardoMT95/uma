<%@ page language="java" contentType="text/html" isErrorPage="false" %><%@ 
page import="it.csi.solmr.util.SolmrLogger"%><%@ 
page import="it.csi.solmr.util.MessaggisticaUtils"%><%

SolmrLogger.info(this, " - visualizzaAllegatoMessaggioCtrl.jsp - INIZIO PAGINA");
    
  Long idAllegato = Long.valueOf(request.getParameter("idAllegato"));
  String nomeFile =request.getParameter("nomeFile");
  
  response.resetBuffer();
  response.setContentType("application/x-download");
  response.addHeader("Content-Disposition", "attachment;filename = "+ nomeFile);
          
  byte[] b = MessaggisticaUtils.getAllegato(idAllegato);
          
  if (b != null && b.length > 0) {
    response.getOutputStream().write(b);
  }
  response.getOutputStream().flush();
  response.getOutputStream().close();

  SolmrLogger.info(this, " - visualizzaAllegatoMessaggioCtrl.jsp - FINE PAGINA");
           
  return;
%>