<%@ page language="java"
     contentType="text/html"
     isErrorPage="true"
 %>



<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%



 UmaFacadeClient umaClient = new UmaFacadeClient();

 java.io.InputStream layout = application.getResourceAsStream("ditta/layout/elencoBlocchi.htm");

 UmaFacadeClient client = new UmaFacadeClient();

 Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
 BloccoDittaVO bloccoVO = null;

 DittaUMAAziendaVO vo = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

 RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

 //Correzione Blocco Ditta 22/11/2004 - Begin

 //Vector v_blocchi =(Vector)session.getAttribute("v_blocchi");
 Vector v_blocchi = (Vector) request.getAttribute("v_blocchi");

 //Correzione Blocco Ditta 22/11/2004 - End

 //session.removeAttribute("dittaUma");

 if(vo.getCuaa()!=null &&!vo.getCuaa().equals("")){

   htmpl.set("CUAA", vo.getCuaa()+" - ");

 }

 //Correzione Blocco Ditta 19/11/2004 - Begin

 String provCompetenza ="";

 provCompetenza = (String) request.getAttribute("provCompetenza");

 //Correzione Blocco Ditta 19/11/2004 - End

 htmpl.set("siglaProvUMA",provCompetenza);

 HtmplUtil.setValues(htmpl, vo);



 if(v_blocchi.size()!=0){

   htmpl.set("vectorSize",  new String(""+ v_blocchi.size()+""));

   htmpl.newBlock("blkBlocco");

   Iterator iter = v_blocchi.iterator();

   int i = 1;

   while(iter.hasNext()){

     bloccoVO = (BloccoDittaVO)iter.next();

     htmpl.newBlock("blkRigaBlocco");

     htmpl.set("blkBlocco.blkRigaBlocco.dataBlocco", DateUtils.formatDate(bloccoVO.getDataBlocco()));

     htmpl.set("blkBlocco.blkRigaBlocco.utenteBlocco", bloccoVO.getUtenteBlocco());

     if(bloccoVO.getDataSblocco()!=null){

       htmpl.set("blkBlocco.blkRigaBlocco.dataSblocco", DateUtils.formatDate(bloccoVO.getDataSblocco()));

       htmpl.set("blkBlocco.blkRigaBlocco.utenteSblocco", bloccoVO.getUtenteSblocco());

     }

     htmpl.set("blkBlocco.blkRigaBlocco.val", ""+i+"");

     htmpl.set("blkBlocco.blkRigaBlocco.notaBlocco", bloccoVO.getNote());

     i++;

   }

 }

 ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

 HtmplUtil.setErrors(htmpl, errors, request);

 SolmrLogger.debug(this,"- bloccoDittaView.jsp -  FINE PAGINA");

%>

<%= htmpl.text()%>