<%@ page language="java"
     contentType="text/html"
     isErrorPage="true"
 %>



<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

 SolmrLogger.debug(this,"- cancellaBloccoView.jsp -  INIZIO PAGINA");



 UmaFacadeClient umaClient = new UmaFacadeClient();

 java.io.InputStream layout = application.getResourceAsStream("ditta/layout/cancellaBlocco.htm");

 Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%
 //Correzione Blocco Ditta 19/11/2004 - Begin

 //BloccoDittaVO bloccoVO = (BloccoDittaVO)session.getAttribute("bloccoVO");

 BloccoDittaVO bloccoVO = (BloccoDittaVO)request.getAttribute("bloccoVO");

 //Correzione Blocco Ditta 19/11/2004 - End

 DittaUMAAziendaVO vo = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

 RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

 if(vo.getCuaa()!=null &&!vo.getCuaa().equals("")){

   htmpl.set("CUAA", vo.getCuaa()+" - ");

 }

 String provCompetenza ="";

 /*if(vo.getProvCompetenza()!=null&&!vo.getProvCompetenza().equals("")){

   provCompetenza = umaClient.getProvinciaByIstat(vo.getProvCompetenza());

 }*/

 if(vo.getProvUMA()!=null&&!vo.getProvUMA().equals("")){

   provCompetenza = umaClient.getProvinciaByIstat(vo.getProvUMA());

 }


 htmpl.set("siglaProvUMA",provCompetenza);

 HtmplUtil.setValues(htmpl, vo);

 HtmplUtil.setValues(htmpl, vo);

 htmpl.set("idBloccoDitta",bloccoVO.getIdBloccoDitta().toString());

 htmpl.set("dataBlocco", DateUtils.formatDate(bloccoVO.getDataBlocco()));

 htmpl.set("noteBlocco", bloccoVO.getNote());

 SolmrLogger.debug(this,"[cancellaBloccoView::service] "+bloccoVO.getNote());

 htmpl.set("dataSblocco", DateUtils.getCurrent(DateUtils.DATA));



 it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);



 SolmrLogger.debug(this,"[cancellaBloccoView::service]  -  FINE PAGINA");

%>

<%= htmpl.text()%>