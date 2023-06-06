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

 UmaFacadeClient umaClient = new UmaFacadeClient();

 java.io.InputStream layout = application.getResourceAsStream("ditta/layout/nuovoBlocco.htm");

 DittaUMAAziendaVO vo = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

 RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");



 Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%


 htmpl.set("dataBlocco", DateUtils.getCurrent(DateUtils.DATA));

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

 //Correzione Blocco Ditta 19/11/2004 - Begin

 //session.removeAttribute("check");

 //Correzione Blocco Ditta 19/11/2004 - End

 it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
%>

<%= htmpl.text()%>