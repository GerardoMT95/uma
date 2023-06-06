<%@ page language="java"

    contentType="text/html"

    isErrorPage="true"

%>
<%@ page import="java.util.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.anag.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO" %>
<%@ page import="it.csi.jsf.htmpl.Htmpl"%>
<%@ page import="it.csi.solmr.dto.uma.DittaUMAVO"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  private String NEXT = "../layout/nuovaDittaUmaConfermaInserimento.htm";
%>
<%
  java.io.InputStream layout = application.getResourceAsStream("/ditta/layout/nuovaDittaUmaAttendere.htm");
  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %>
<%=htmpl.text()%><%
  out.flush();

  String tipoConduzione = request.getParameter("tipiConduzione");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  UmaFacadeClient umaClient = new UmaFacadeClient();

  AnagFacadeClient anagFacadeClient = new AnagFacadeClient();

  AnagAziendaVO anagAziendaVO = (AnagAziendaVO)session.getAttribute("anagAziendaVO");

  DittaUMAVO dittaUmaVO=(DittaUMAVO)request.getAttribute("dittaUmaVO");
  //Inserisco la nuova Ditta UMA

 long primaryKey = 0;

 try {

   Object commonObj=session.getAttribute("common");
   DittaUMAVO duVO=null;
   if (commonObj!=null && commonObj instanceof HashMap)
   {
     HashMap common=(HashMap)commonObj;
     duVO=(DittaUMAVO)common.get("dittaUmaVO");
     dittaUmaVO.setIdDittaUmaProv(duVO.getIdDitta());
   }
   primaryKey = umaClient.insertDittaUMA(dittaUmaVO);

 }

 catch(SolmrException se)
 {
   SolmrLogger.debug(this,"Eccezione: "+se.getMessage());
   doError(se.getMessage(),out);
   return;

 }
 // Recupero i dati della nuova ditta UMA inserita
 try {

   dittaUmaVO = umaClient.findByPrimaryKey(new Long(primaryKey));

 }

 catch(SolmrException se) {

   doError("Si è verificato un errore durante il recupero dei dati della nuova ditta UMA inserita!",out);
   return;
 }

 if(tipoConduzione != null && !tipoConduzione.equals("")) {

   try {

     tipoConduzione = umaClient.getDescriptionFromCode(SolmrConstants.TAB_TIPO_CONDUZIONE,

         new Integer(tipoConduzione));

   }

   catch(SolmrException se) {

     doError(UmaErrors.ERR_TIPI_CONDUZIONE_RICERCA,out);
     return;

   }

 }

 String descrizioneProvincia = null;

 try {

   descrizioneProvincia = umaClient.getProvinciaByIstat(dittaUmaVO.getExtProvinciaUMA());

 }

 catch(SolmrException se) {

   doError(se.getMessage(),out);
   return;

 }

 dittaUmaVO.setTipiConduzione(tipoConduzione);

 dittaUmaVO.setDescExtProvinciaUMA(descrizioneProvincia);

 session.setAttribute("dittaUmaVO",dittaUmaVO);
 doNextPage(out);

%><%!
  private void doError(String message,java.io.Writer out)
      throws java.io.IOException
  {
    message=replace(message,"''","'");
    message=replace(message,"'","\\'");
    out.write("<script language='javascript1.2'>\n"+
              "window.alert('"+message+"')\n"+
              "</script>");
    out.flush();
  }

  private void doNextPage(java.io.Writer out)
      throws java.io.IOException
  {
    out.write("<script language='javascript1.2'>"+
              "\ndocument.formNext.submit();"+
              "\n</script>");
    out.flush();
  }

  private String replace(String theString,String oldString,String newString)
  {
    int index=theString.indexOf(oldString);
    while (index>-1)
    {
      theString=theString.substring(0,index)+newString+theString.substring(index+oldString.length());
      index=theString.indexOf(oldString,index+1+oldString.length());
    }
    return theString;
  }
%>


