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
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  public static final String LAYOUT="/macchina/layout/inserimento_marche.htm";
%>
<%
  SolmrLogger.debug(this,"Sono in inserimento_marcheView.jsp");
  UmaFacadeClient umaClient = new UmaFacadeClient();
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%
  //Controllo di ritorno dell'inserimento su ricerca o lista
  String pageFrom=null;
  SolmrLogger.debug(this,"\n\n\n----------------------------");
  if ( session.getAttribute("pageFrom")!=null ){
    SolmrLogger.debug(this,"session.getAttribute(\"pageFrom\"): "+session.getAttribute("pageFrom"));
    pageFrom =(String)session.getAttribute("pageFrom");
    session.removeAttribute("pageFrom");
  }
  else{
    pageFrom =(String)request.getParameter("pageFrom");
  }

  //Gestione dei dati di request in redirect su inserimento
  htmpl.set("pageFrom", pageFrom);
  if (session.getAttribute("genereMacchina")!=null){
    htmpl.set("genereMacchinaSrch", (String)session.getAttribute("genereMacchina"));
  }
  if (session.getAttribute("descrizioneMarca")!=null){
    htmpl.set("descrizioneMarcaSrch", (String)session.getAttribute("descrizioneMarca"));
  }
  if (session.getAttribute("matriceMarca")!=null){
    htmpl.set("matriceMarcaSrch", (String)session.getAttribute("matriceMarca"));
  }

  if(request.getAttribute("genereMacchina") != null)
    printCombo(htmpl, umaClient.getTipiGenereMacchina(), "idGenereMacchina", "descGenereMacchina", (String)request.getAttribute("genereMacchina"), "blkGenereMacchina");
  else
    printCombo(htmpl, umaClient.getTipiGenereMacchina(), "idGenereMacchina", "descGenereMacchina", "", "blkGenereMacchina");
  if(request.getAttribute("descrizioneMarca")!=null)
    htmpl.set("descrizioneMarca", (String)request.getAttribute("descrizioneMarca"));
  if(request.getAttribute("matriceMarca")!=null)
    htmpl.set("matriceMarca", (String)request.getAttribute("matriceMarca"));

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
  out.print(htmpl.text());
%>
<%!
  private void printCombo(Htmpl htmpl,Vector comboData,String nameCode,String nameDesc,String selectedCode,String blockName)
    {
      int size=comboData==null?0:comboData.size();
      String blkNameCode=blockName+"."+nameCode;
      String blkNameDesc=blockName+"."+nameDesc;
      htmpl.newBlock(blockName);

      SolmrLogger.debug(this,"SolmrConstants.get(\"TIPO_GENERE_MACCHINA_RIMORCHIO\"): "+SolmrConstants.get("TIPO_GENERE_MACCHINA_RIMORCHIO"));
      SolmrLogger.debug(this,"SolmrConstants.get(\"TIPO_GENERE_MACCHINA_ASM\"): "+SolmrConstants.get("TIPO_GENERE_MACCHINA_ASM"));

      for(int i=0;i<size;i++)
      {
        CodeDescription cd=(CodeDescription)comboData.get(i);
        String code=cd.getCode().toString();
        String codeShort=cd.getSecondaryCode().toString();

        SolmrLogger.debug(this,"\n\n\n-----------------1Codici:");
        SolmrLogger.debug(this,"1code: "+code);
        SolmrLogger.debug(this,"1codeShort: "+codeShort);

        if ( !codeShort.trim().equalsIgnoreCase(""+SolmrConstants.get("TIPO_GENERE_MACCHINA_RIMORCHIO"))
          && !codeShort.trim().equalsIgnoreCase(""+SolmrConstants.get("TIPO_GENERE_MACCHINA_ASM")) )
        {
          SolmrLogger.debug(this,"\n\n\n-----------------2Codici:");
          SolmrLogger.debug(this,"2code: "+code);
          SolmrLogger.debug(this,"2codeShort: "+codeShort);

          htmpl.newBlock(blockName);
          if (code!=null && code.equals(selectedCode))
          {
            htmpl.set(blockName+".selected","selected");
          }

          SolmrLogger.debug(this,"codeShort: "+codeShort);
          htmpl.set(blkNameCode,code);
          htmpl.set(blkNameDesc,cd.getDescription());
        }
      }
  }
%>
