<%@ page language="java" contentType="text/html"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%!private static final String VIEW = "/domass/view/verificaAssegnazioneAccontoValidataView.jsp";%>
<%
  //Flag per disabilitare controllo autorizzazione abilitazioni IRIDE AssegnazioneBaseCU.hasCompetenzaDato()
  final String DISABILITA_INTERMEDIARIO = "";
  request.setAttribute("noCheckIntermediario", DISABILITA_INTERMEDIARIO);

  String iridePageName = "verificaAssegnazioneAccontoValidataCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%
  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma = dittaUMAAziendaVO.getIdDittaUMA();

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  
  DomandaAssegnazione accontoVO = umaFacadeClient.findAccontoCorrenteByIdDittaUMA(idDittaUma.longValue());  
  
  FogliRigaVO fogliRigaVO = umaFacadeClient.getFoglioRigaByIdDomandaAssegnazione(accontoVO.getIdDomandaAssegnazione());
  fogliRigaVO.setDataValidazione(checkDate(accontoVO.getDataValidazione()));
  
  // Nick 14-01-2009 - Nuova gestione emissione buoni.
  int iQContoProprioGasolio = umaFacadeClient.selectContoProprioGasolio(accontoVO.getIdDomandaAssegnazione());
  int iQContoProprioBenzina = umaFacadeClient.selectContoProprioBenzina(accontoVO.getIdDomandaAssegnazione());
  int iQContoTerziGasolio = umaFacadeClient.selectContoTerziGasolio(accontoVO.getIdDomandaAssegnazione());
  int iQContoTerziBenzina = umaFacadeClient.selectContoTerziBenzina(accontoVO.getIdDomandaAssegnazione());
  int iQSerraGasolio = umaFacadeClient.selectRiscSerraGasolio(accontoVO.getIdDomandaAssegnazione());
  int iQSerraBenzina = umaFacadeClient.selectRiscSerraBenz(accontoVO.getIdDomandaAssegnazione());
  
  String strCtrlBuonoInserito = "FALSE";
  if (iQContoProprioGasolio+iQContoProprioBenzina+iQContoTerziGasolio+iQContoTerziBenzina+iQSerraGasolio+iQSerraBenzina > 0)
  	  strCtrlBuonoInserito = "TRUE";
  	  
  request.setAttribute("ctrl_buono_inserito", strCtrlBuonoInserito);  	    
  //
  
  request.setAttribute("fogliRigaVO", fogliRigaVO);
  request.setAttribute("accontoVO",accontoVO);
%>
<jsp:forward page="<%=VIEW%>" /><%!//
  //Converte java.util.Date in java.sql.Date
  protected java.sql.Date checkDate(java.util.Date val)
  {
    if (val == null)
    {
      return null;
    }
    return new java.sql.Date(val.getTime());
  }%>
