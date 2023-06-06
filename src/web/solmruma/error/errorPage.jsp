<%@page import="it.csi.solmr.etc.SolmrErrors"%>
<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%
  Htmpl htmpl = HtmplFactory.getInstance(application)
                .getHtmpl("layout/errorPage.htm");
  String errorMessage = null;
  if (exception == null)
  {
    // La pagina è stata chiamata da una forward diretta e non da una eccezione
    // non sottoposta a catch
    if((String)session.getAttribute("errorMessage")!=null){
    	errorMessage=(String)session.getAttribute("errorMessage");
    	session.removeAttribute("errorMessage");
    }
    else{
    	//Retro compatibilita' con precedente gestione errore
    	errorMessage=(String)request.getAttribute("errorMessage");
    }
  }
  else
  {
    errorMessage=exception.getMessage();
  }
  if(errorMessage == null || "".equals(errorMessage.trim())){
	  //Se si verifica questa condizione c'è stato un problema nella gestione dell'errore
	  errorMessage = SolmrErrors.NO_MESSAGE;
  }
  htmpl.set("errorMessage",errorMessage);

  it.csi.solmr.presentation.security.Autorizzazione aut=
  (it.csi.solmr.presentation.security.Autorizzazione)
  it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ACCESSO_SISTEMA");
  it.csi.solmr.dto.profile.RuoloUtenza ruoloUtenza =   (it.csi.solmr.dto.profile.RuoloUtenza)session.getAttribute("ruoloUtenza");
 // session.getAttribute("profile");
  if (ruoloUtenza!=null)
  {
    aut.writeBanner(htmpl,ruoloUtenza,request);
  }
  else
  {
    aut.writeBannerPortalName(htmpl,request);
  }
  if (request.getAttribute("closeOnError")!=null)
  {
    htmpl.newBlock("blkChiudi");
  }
  else
  {
    String closeUrl=(String)request.getAttribute("closeUrl");
    if (closeUrl!=null)
    {
      htmpl.newBlock("blkPageChiudi");
      htmpl.set("blkPageChiudi.href",closeUrl);
    }
    else
    {
      htmpl.newBlock("blkIndietro");
      Object historyNum=request.getAttribute("historyNum");
      if (historyNum!=null)
      {
        htmpl.set("blkIndietro.historyNum",historyNum.toString());
      }
      else
      {
        htmpl.set("blkIndietro.historyNum","-1");
      }
    }
  }
  String layout = (String)request.getAttribute("layout");

  if (layout!=null && !layout.toLowerCase().startsWith("/layout"))
  {
    htmpl.bset("backDir","../");
  }
  out.print(htmpl.text());

%>