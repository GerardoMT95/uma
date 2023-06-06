<%@ page language="java" contentType="text/html" isErrorPage="true" %>
<%@ page import="it.csi.solmr.business.uma.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!public static final String LIGHT_GREY = " style='background-color:LightGrey' ";%>

<%Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/domass/layout/emissioneBuono.htm");%>

<%@include file = "/include/menu.inc" %>

<%
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  it.csi.solmr.client.uma.UmaFacadeClient umaFacadeClient = new it.csi.solmr.client.uma.UmaFacadeClient();

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

  Long idDomAss = null;
  Long idDittaUma = null;
  Long annoRif = null;
  String provCompetenza ="";

  if(dittaVO.getProvUMA()!=null&&!dittaVO.getProvUMA().equals(""))
    provCompetenza = umaFacadeClient.getProvinciaByIstat(dittaVO.getProvUMA());

  HtmplUtil.setValues(htmpl, request);
  ValidationException valEx = null;
  
  try{      
      if(request.getAttribute("idDomAss")!=null)
        idDomAss = new Long(""+request.getAttribute("idDomAss"));
      else 
      	idDomAss = new Long(""+request.getParameter("idDomAss"));     

      if(request.getAttribute("dittaUma")!=null)
         idDittaUma = new Long(""+request.getAttribute("dittaUma"));
      else 
         idDittaUma = new Long(""+request.getParameter("dittaUma"));      

      if(request.getAttribute("anno")!=null) 
         annoRif = new Long(""+request.getAttribute("anno"));
      else 
      	 annoRif = new Long(""+request.getParameter("anno"));
    
      long sumCPBenz = 0;
      long sumCPGas = 0;
      long sumCTBenz = 0;
      long sumCTGas = 0;
      long sumTotEmessoCPBenz = 0;
      long sumTotEmessoCPGas = 0;
      long sumTotEmessoCTBenz = 0;
      long sumTotEmessoCTGas = 0;
      long dispCPBenz = 0;
      long dispCPGas = 0;
      long dispCTBenz = 0;
      long dispCTGas = 0;
      long riscSerraGas = 0;
      long riscSerraBenz = 0;
      long sumTotEmessoBenzDue = 0;
      long sumTotEmessoGasDue = 0;

      //Controllo carburante prelevato - Begin
      long sumTotPrelevatoSerraBenz = 0;
      long sumTotPrelevatoSerraGas = 0;
      long sumTotPrelevatoCPBenz = 0;
      long sumTotPrelevatoCPGas = 0;
      long sumTotPrelevatoCTBenz = 0;
      long sumTotPrelevatoCTGas = 0;
      //Controllo carburante prelevato - End

      long dispBenzDue = 0;
      long dispGasDue = 0;

      SolmrLogger.debug(this,"\n\n\n\n***************");
      SolmrLogger.debug(this,"Valori emissione: ");
      
      sumCPBenz = new Long(umaFacadeClient.selectContoProprioBenzina(idDomAss)).longValue();
      SolmrLogger.debug(this,"sumCPBenz: "+sumCPBenz);

      sumCPGas = new Long(umaFacadeClient.selectContoProprioGasolio(idDomAss)).longValue();
      SolmrLogger.debug(this,"sumCPGas: "+sumCPGas);
      
      sumCTBenz = new Long(umaFacadeClient.selectContoTerziBenzina(idDomAss)).longValue();
      SolmrLogger.debug(this,"sumCTBenz: "+sumCTBenz);      

      sumCTGas = new Long(umaFacadeClient.selectContoTerziGasolio(idDomAss)).longValue();
      SolmrLogger.debug(this,"sumCTGas: "+sumCTGas);
      
      sumTotEmessoCPBenz = new Long(umaFacadeClient.selectTotEmessoBenzina(idDomAss, 1L)).longValue();
      SolmrLogger.debug(this,"sumTotEmessoCPBenz: "+sumTotEmessoCPBenz);
      
      sumTotEmessoCPGas = new Long(umaFacadeClient.selectTotEmessoGasolio(idDomAss, 1L)).longValue();
      SolmrLogger.debug(this,"sumTotEmessoCPGas: "+sumTotEmessoCPGas);

      sumTotEmessoCTBenz = new Long(umaFacadeClient.selectTotEmessoBenzina(idDomAss, 2L)).longValue();
      SolmrLogger.debug(this,"sumTotEmessoCTBenz: "+sumTotEmessoCTBenz);
      
      sumTotEmessoCTGas = new Long(umaFacadeClient.selectTotEmessoGasolio(idDomAss, 2L)).longValue();
      SolmrLogger.debug(this,"sumTotEmessoCTGas: "+sumTotEmessoCTGas);
      
      //Controllo carburante prelevato - Begin
      SolmrLogger.debug(this,"prima di sumTotPrelevatoBenzDue - selectPrelevatoNonSerra");

      sumTotPrelevatoCPBenz = new Long(umaFacadeClient.selectPrelevatoContoProprio(idDomAss, ""+SolmrConstants.get("ID_BENZINA") )).longValue();
      SolmrLogger.debug(this,"sumTotPrelevatoCPBenz: "+sumTotPrelevatoCPBenz);

      sumTotPrelevatoCPGas = new Long(umaFacadeClient.selectPrelevatoContoProprio(idDomAss, ""+SolmrConstants.get("ID_GASOLIO") )).longValue();
      SolmrLogger.debug(this,"sumTotPrelevatoCPGas: "+sumTotPrelevatoCPGas);

      sumTotPrelevatoCTBenz = new Long(umaFacadeClient.selectPrelevatoContoTerzi(idDomAss, ""+SolmrConstants.get("ID_BENZINA") )).longValue();
      SolmrLogger.debug(this,"sumTotPrelevatoCTBenz: "+sumTotPrelevatoCTBenz);

      sumTotPrelevatoCTGas = new Long(umaFacadeClient.selectPrelevatoContoTerzi(idDomAss, ""+SolmrConstants.get("ID_GASOLIO") )).longValue();
      SolmrLogger.debug(this,"sumTotPrelevatoCTGas: "+sumTotPrelevatoCTGas);
      //Controllo carburante prelevato - End

      //Controllo carburante prelevato - Begin
 	  dispCPBenz = new Long((sumCPBenz) - sumTotEmessoCPBenz - sumTotPrelevatoCPBenz).longValue();
      dispCPGas = new Long((sumCPGas) - sumTotEmessoCPGas - sumTotPrelevatoCPGas).longValue();
      dispCTBenz = new Long((sumCTBenz) - sumTotEmessoCTBenz - sumTotPrelevatoCTBenz).longValue();
      dispCTGas = new Long((sumCTGas) - sumTotEmessoCTGas - sumTotPrelevatoCTGas).longValue();
      
      SolmrLogger.debug(this,"dispCPBenz: "+dispCPBenz+"=("+sumCPBenz+")-"+sumTotEmessoCPBenz+"-"+sumTotPrelevatoCPBenz);
      SolmrLogger.debug(this,"dispCPGas: "+dispCPGas+"=("+sumCPGas+")-"+sumTotEmessoCPGas+"-"+sumTotPrelevatoCPGas);
      SolmrLogger.debug(this,"dispCTBenz: "+dispCTBenz+"=("+sumCTBenz+")-"+sumTotEmessoCTBenz+"-"+sumTotPrelevatoCTBenz);
      SolmrLogger.debug(this,"dispCTGas: "+dispCTGas+"=("+sumCTGas+")-"+sumTotEmessoCTGas+"-"+sumTotPrelevatoCTGas);
      SolmrLogger.debug(this,"\n\n\n\n\n");
      //Controllo carburante prelevato - End     

      riscSerraGas = new Long(umaFacadeClient.selectRiscSerraGasolio(idDomAss)).longValue();
      riscSerraBenz = new Long(umaFacadeClient.selectRiscSerraBenz(idDomAss)).longValue();      

      sumTotEmessoBenzDue = new Long(umaFacadeClient.selectTotEmessoDueBenzina(idDomAss)).longValue();
      sumTotEmessoGasDue = new Long(umaFacadeClient.selectTotEmessoDueGasolio(idDomAss)).longValue();

      //Controllo carburante prelevato - Begin
      sumTotPrelevatoSerraBenz = new Long(umaFacadeClient.selectPrelevatoSerra(idDomAss, ""+SolmrConstants.get("ID_BENZINA") )).longValue();      
      sumTotPrelevatoSerraGas = new Long(umaFacadeClient.selectPrelevatoSerra(idDomAss, ""+SolmrConstants.get("ID_GASOLIO") )).longValue();
      //Controllo carburante prelevato - End

      //Controllo carburante prelevato - Begin      
      dispBenzDue = new Long(riscSerraBenz - sumTotEmessoBenzDue - sumTotPrelevatoSerraBenz).longValue();
      dispGasDue = new Long(riscSerraGas - sumTotEmessoGasDue - sumTotPrelevatoSerraGas).longValue();

      SolmrLogger.debug(this,"dispBenzDue: "+dispBenzDue+"="+riscSerraBenz+"-"+sumTotEmessoBenzDue+"-"+sumTotPrelevatoSerraBenz);
      SolmrLogger.debug(this,"dispGasDue: "+dispGasDue+"="+riscSerraGas+"-"+sumTotEmessoGasDue+"-"+sumTotPrelevatoSerraGas);
      //Controllo carburante prelevato - End

      if(request.getParameter("pageFrom")!=null)
         htmpl.set("pageFrom",request.getParameter("pageFrom"));

      htmpl.set("denominazione", dittaVO.getDenominazione());

      if(dittaVO.getCuaa()!=null &&!dittaVO.getCuaa().equals("")){
         htmpl.set("CUAA", dittaVO.getCuaa()+" - ");
      }

      htmpl.set("dittaUMA", dittaVO.getDittaUMAstr());

      htmpl.set("umaTipoDitta",dittaVO.getTipiDitta());

      htmpl.set("provinciaCompetenza",provCompetenza);

      htmpl.set("anno",""+annoRif);     

      htmpl.set("idDomAss",""+idDomAss);
      htmpl.set("dittaUma",""+idDittaUma);

      htmpl.set("contoProprioBenz",""+sumCPBenz);
      htmpl.set("contoProprioGas",""+sumCPGas);

      htmpl.set("contoTerziBenz",""+sumCTBenz);
      htmpl.set("contoTerziGas",""+sumCTGas);

      long emessoCPBenz = sumTotEmessoCPBenz + sumTotPrelevatoCPBenz;
      htmpl.set("totEmessoCPBenz",""+emessoCPBenz);
	  
      long emessoCPGas = sumTotEmessoCPGas + sumTotPrelevatoCPGas;
      htmpl.set("totEmessoCPGas",""+emessoCPGas);

      long emessoCTBenz = sumTotEmessoCTBenz + sumTotPrelevatoCTBenz;
      htmpl.set("totEmessoCPBenz",""+emessoCPBenz);
	  
      long emessoCTGas = sumTotEmessoCTGas + sumTotPrelevatoCTGas;
      htmpl.set("totEmessoCPGas",""+emessoCPGas);

      htmpl.set("disponibileCPBenz",""+dispCPBenz);
      htmpl.set("disponibileCPGas",""+dispCPGas);

      htmpl.set("disponibileCTBenz",""+dispCTBenz);
      htmpl.set("disponibileCTGas",""+dispCTGas);
            
      htmpl.set("qtaConcAgriCPBenz",""+dispCPBenz);      
      htmpl.set("qtaConcAgriCPGas",""+dispCPGas);      

      htmpl.set("qtaConcAgriCTBenz",""+dispCTBenz);      
      htmpl.set("qtaConcAgriCTGas",""+dispCTGas);      
      
      htmpl.set("riscSerraGas",""+riscSerraGas);
      htmpl.set("riscSerraBenz",""+riscSerraBenz);
      
      /*
      if (!ruoloUtenza.isUtentePA())
        htmpl.set("readonly",SolmrConstants.HTML_READONLY+LIGHT_GREY,null);
      */

	  //25-11-2008 - Nick - CU-GUMA-18 emissione buono di prelievo.
      //long emessoSerraBenz = sumTotEmessoBenzDue + sumTotPrelevatoSerraBenz;
      long emessoSerraBenz = sumTotEmessoBenzDue - sumTotPrelevatoSerraBenz;
      htmpl.set("totEmessoBenzDue",""+emessoSerraBenz);

	  //25-11-2008 - Nick - CU-GUMA-18 emissione buono di prelievo.
      //long emessoSerraGas = sumTotEmessoGasDue + sumTotPrelevatoSerraGas;
      long emessoSerraGas = sumTotEmessoGasDue - sumTotPrelevatoSerraGas;
      htmpl.set("totEmessoGasDue",""+emessoSerraGas);

      htmpl.set("disponibileBenzDue",""+dispBenzDue);
      htmpl.set("disponibileGasDue",""+dispGasDue);

      htmpl.set("qtaConcRiscSerraBenz",""+dispBenzDue);
      htmpl.set("qtaConcRiscSerraGas",""+dispGasDue);      
  }
  catch(Exception ex){
	  SolmrLogger.debug(this,"EXCEPTION!!!!!!!!!!"+ex);
	  ValidationError error = new ValidationError(ex.getMessage());
	
	  if (errors==null)
	  {
	      errors=new ValidationErrors();
	  }
	    
	  errors.add("error", error);
	  request.setAttribute("errors", errors);
  }

  HtmplUtil.setErrors(htmpl, errors, request);
  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl, exception);
%>

<%= htmpl.text()%>