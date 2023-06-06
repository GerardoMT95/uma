<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%

    String layoutUrl = "/domass/layout/dettaglioCalcoloAssSuppl.htm";
    ValidationException valEx;
    Validator validator = new Validator(layoutUrl);
    Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layoutUrl);
    
%>
  <%@include file = "/include/menu.inc" %>
<%
    SolmrLogger.debug(this, "   BEGIN dettaglioCalcoloAssSupplView");
    
    // Oggetto con i dati da visualizzare nella pagina
    FrmDettaglioAssegnazioneVO fdaVO = (FrmDettaglioAssegnazioneVO) request.getAttribute("fdaVO");    
    DomandaAssegnazione domandaAssegnazione = (DomandaAssegnazione)request.getAttribute("domandaAssegnazione");
    
    // Dati che serviranno alle popup
    Long numeroSupplemento = (Long)request.getAttribute("numeroSupplemento");
	SolmrLogger.debug(this, "--- numeroSupplemento ="+numeroSupplemento);	
	htmpl.set("numSupplemento", numeroSupplemento.toString());	     
    
    Long idDomandaAssegnazione = (Long)request.getAttribute("idDomandaAssegnazione");
    SolmrLogger.debug(this, "--- idDomandaAssegnazione ="+idDomandaAssegnazione);
    htmpl.set("idDomandaassegnazione", idDomandaAssegnazione.toString());
    htmpl.set("idDomAss", idDomandaAssegnazione.toString());
    
    String idAssegnazioneCarburante = (String)request.getAttribute("idAssegnazioneCarburante");
    SolmrLogger.debug(this, "--- idAssegnazioneCarburante ="+idAssegnazioneCarburante); 
    htmpl.set("idAssegnazioneCarburante", idAssegnazioneCarburante);
    
    
    // -------------- *** Valorizzazione campi visualizzati nella pagina *** ------------
    // Note : valorizzo le voci con i risultati del pl DETTAGLIO_ASSEGNAZIONE_CARB() --- 
    
    // Anno : anno di db_domanda_assegnazione.data_riferimento
    int annoDomanda = DateUtils.extractYearFromDate(domandaAssegnazione.getDataRiferimento());
    SolmrLogger.debug(this, "-- anno = "+annoDomanda);
    htmpl.set("annoDomanda", ""+annoDomanda);
           
    // Quantitativo massimo assegnabile conto proprio
    String quantMaxAssegnabileCp = fdaVO.getTotAssContoPropSuccess();
    SolmrLogger.debug(this, "-- quantMaxAssegnabileCp ="+quantMaxAssegnabileCp);
    htmpl.set("totAssContoPropSuccess", quantMaxAssegnabileCp);
    
    // Quantitativo massimo assegnabile serre
    String quantMaxAssegnabileSerre = fdaVO.getQuantMaxAssSerre();
    SolmrLogger.debug(this, "-- quantMaxAssegnabileSerre ="+quantMaxAssegnabileSerre);
    htmpl.set("quantMaxAssSerre", quantMaxAssegnabileSerre);
    
    // ----- Tabella Attività svolte con conduzione in conto proprio
    // A)
    String carbLavorazAumentoSup = fdaVO.getCarbLavorazAumentoSuperficie();
    SolmrLogger.debug(this, "-- carbLavorazAumentoSup ="+carbLavorazAumentoSup);
    htmpl.set("carbLavorazAumentoSup", carbLavorazAumentoSup);
        
    // B)
    String carbLavorazColtSec = fdaVO.getCarbLavorazConColtureSeconarie();
    SolmrLogger.debug(this, "-- carbLavorazColtSec ="+carbLavorazColtSec);
    htmpl.set("carbLavorazColtSec", carbLavorazColtSec);
    
    // C)
    String carbAllevamento = fdaVO.getCarbAllevamento();
    SolmrLogger.debug(this, "-- carbAllevamento ="+carbAllevamento);
    htmpl.set("carbAllevamento", carbAllevamento);
    
    // D)
    String carbLavorazAssBase = fdaVO.getCarbLavorazInAssegnazBaseSaldo();
    SolmrLogger.debug(this, "-- carbLavorazAssBase ="+carbLavorazAssBase);
    htmpl.set("carbLavorazAssBase", carbLavorazAssBase);
    
    // Somma (A + B + C + D)    
    String totLavorazAllevam = fdaVO.getTotLavorazAllevam();
    SolmrLogger.debug(this, "-- totLavorazAllevam ="+totLavorazAllevam);
    htmpl.set("totABCD", totLavorazAllevam);
    
    // E)
    String aumentoCarbAllev = fdaVO.getCarbAumentoAllevamento();
    SolmrLogger.debug(this, "-- aumentoCarbAllev ="+aumentoCarbAllev);
    htmpl.set("aumentoCarbAllev", aumentoCarbAllev);
    
    // F)
    String carbAssegnato = fdaVO.getCarbAssegnato();
    SolmrLogger.debug(this, "-- carbAssegnato ="+carbAssegnato);
    htmpl.set("carbComsumiUnitariPerMacchina", carbAssegnato);
        
    // G)
    String aumentoCarbMacchine = fdaVO.getCarbAumentoMacchine();
    SolmrLogger.debug(this, "-- aumentoCarbMacchine ="+aumentoCarbMacchine);
    htmpl.set("aumentoCarbMacchine", aumentoCarbMacchine);
    
    // H)
    String quantMaxAssLavorazAllevam = fdaVO.getQuantMaxAssLavorazAllevam();
    SolmrLogger.debug(this, "-- quantMaxAssLavorazAllevam ="+quantMaxAssLavorazAllevam);
    htmpl.set("quantAssColtAllev", quantMaxAssLavorazAllevam);
    
    // I)
    String carbLavorazEccezionali = fdaVO.getCarbLavorazEccezionali();
    SolmrLogger.debug(this, "-- carbLavorazEccezionali ="+carbLavorazEccezionali);
    htmpl.set("quantAssLavorazEccez",carbLavorazEccezionali);
    
    
    // Quantitativo massimo assegnabile per attività conto proprio (somma H + I)
    String quantMaxAssContoProp = fdaVO.getQuantMaxAssContoProp();
    SolmrLogger.debug(this, "-- quantMaxAssContoProp ="+quantMaxAssContoProp);
    htmpl.set("quantMassAssegnabAttivCp", quantMaxAssContoProp);
    
    
    // Totale (arrotondamento ai 10 litri superiori) :
    String totAssContoPropSuccess = fdaVO.getTotAssContoPropSuccess();
    SolmrLogger.debug(this, "-- quantMaxAssContoProp ="+quantMaxAssContoProp);
    htmpl.set("totAssContoPropSuccess",totAssContoPropSuccess);
       
    
    
    // ---- Tabella : Carburante per riscaldamento serre
    
    // Limite riscaldamento serre
    String limiteRiscaldamentoSerre = fdaVO.getQuantMaxAssRiscaldam();
    SolmrLogger.debug(this, "-- limiteRiscaldamentoSerre ="+limiteRiscaldamentoSerre);
    htmpl.set("limiteRiscaldamentoSerre", limiteRiscaldamentoSerre);
    
    // Quantitativo massimo assegnabile
    String quantitativoMaxAssegnabile = fdaVO.getCarbAumentoRiscaldamento();
    SolmrLogger.debug(this, "-- quantitativoMaxAssegnabile ="+limiteRiscaldamentoSerre);
    htmpl.set("quantMaxAssRiscaldam", quantitativoMaxAssegnabile);
    
    
    // Totale (arrotondamento ai 10 Litri superiori)
    String quantMaxAssSerre = fdaVO.getQuantMaxAssSerre();
    SolmrLogger.debug(this, "-- quantMaxAssSerre ="+quantMaxAssSerre);
    htmpl.set("quantMaxAssSerre", quantMaxAssSerre);
   

  
    HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
    it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
    
    SolmrLogger.debug(this, "   BEGIN dettaglioCalcoloAssSupplView");
    out.print(htmpl.text());
%>

