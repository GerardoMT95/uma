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
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>




<%

    String layoutUrl = "/domass/layout/carburanteAssegnabile.htm";
    ValidationException valEx;
    Validator validator = new Validator(layoutUrl);
    Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layoutUrl);
    
%>
  <%@include file = "/include/menu.inc" %>
<%
    SolmrLogger.debug(this, "   BEGIN carburanteAssegnabileView");
    String blk = null;
    FrmDettaglioAssegnazioneVO fdaVO = (FrmDettaglioAssegnazioneVO) request.getAttribute("fdaVO");
    
    DomandaAssegnazione domandaAssegnazione = (DomandaAssegnazione)request.getAttribute("domandaAssegnazione");
  
  
    String eccedenza=(String)request.getAttribute("eccedenza");
    htmpl.set("eccedenza",eccedenza);
    
    if (domandaAssegnazione!=null && domandaAssegnazione.getCalcoloEccedenze()!=null && !domandaAssegnazione.getCalcoloEccedenze().isEmpty())
    {
      for(CodeDescr ecc:domandaAssegnazione.getCalcoloEccedenze())
      {
        htmpl.newBlock("blkEccedenze");
        htmpl.set("blkEccedenze.descEcc", ecc.getDescription());
        htmpl.set("blkEccedenze.litriEcc", ecc.getCode()==null?"":ecc.getCode().toString());
      }
    }
    else
    {
      htmpl.newBlock("blkEccedenzeNonCal");
    }
    
    
    // Se stiamo visualizzando 'Assegnazione Supplemento' sarà valorizzato, altrimenti no (serve per le popup di dettaglio)
    Long numeroSupplemento = (Long)request.getAttribute("numeroSupplemento");
	SolmrLogger.debug(this, "--- numeroSupplemento ="+numeroSupplemento);
	if(numeroSupplemento != null)
	  htmpl.set("numSupplemento", numeroSupplemento.toString());
	else
	  htmpl.set("numSupplemento","");  

    UmaFacadeClient umaClient = new UmaFacadeClient();
    DittaUMAAziendaVO dumaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
    String pageFrom = (String)request.getParameter("pageFrom");
    SolmrLogger.debug(this, "-- pageFrom ="+pageFrom);

    if("../layout/assegnazioni.htm".equalsIgnoreCase(pageFrom))
    {
      blk = "blkMenuElencoAss";
    }
    else if("../layout/dettaglioDomanda.htm".equalsIgnoreCase(pageFrom))
      blk = "blkMenuDettaglioAss";
    else
    {
      blk = "blkMenuVerificaAss";
      if(!pageFrom.equals("../layout/verificaAssegnazioneBO.htm"))
        htmpl.newBlock("blkIndietro");
    }

    htmpl.set("anno", ""+DateUtils.getCurrentYear());
    htmpl.set("pageFrom", pageFrom);

    htmpl.set("idDomAss", request.getParameter("idDomAss"));
    htmpl.set("idDomandaassegnazione", request.getParameter("idDomAss"));   
    
    String descTipoDomanda=null;
    if (SolmrConstants.TIPO_DOMANDA_ACCONTO.equals(domandaAssegnazione.getTipoDomanda()))
    {
      descTipoDomanda=SolmrConstants.DESCRIZIONE_TIPO_DOMANDA_ACCONTO;
    }
    else
    {
      if (SolmrConstants.TIPO_DOMANDA_BASE.equals(domandaAssegnazione.getTipoDomanda()))
      {
        descTipoDomanda=SolmrConstants.DESCRIZIONE_TIPO_DOMANDA_BASE;
      }
    }
    
    htmpl.set("tipoDomanda", descTipoDomanda);
    
    // Anno assegnazione
    int annoDomanda = DateUtils.extractYearFromDate(domandaAssegnazione.getDataRiferimento());
    SolmrLogger.debug(this, "--- anno assegnazione = "+annoDomanda);
    htmpl.set("annoDomanda", ""+annoDomanda);
    
    // Anno recuperato da DB_PARAMETRO ('UMLC') -> Anno dal quale inizia il caricamento delle lavorazioni conto proprio che sostituisce il calcolo sull'ettaro coltura
    Integer annoInizioCaricamentoLavCP = (Integer)request.getAttribute("annoInizioCaricamentoLavCP");   
    int annoInizioLavCp = 9999;
    if(annoInizioCaricamentoLavCP != null)
      annoInizioLavCp = annoInizioCaricamentoLavCP.intValue();
    SolmrLogger.debug(this, "--- annoInizioLavCp ="+annoInizioLavCp);   
    htmpl.set("annoInizioLavCp",""+annoInizioLavCp);
    
    /* -- Nuova gestione per il Conto Proprio : 
       se l'anno di riferimento (DB_DOMANDA_ASSEGNAZIONE.DATA_RIFERIMENTO) >= annoInizioCaricamentoLavCP :
         - NON visualizzare i pulsanti di 'Dettaglio' di F) e G)
    */ 
    if(annoDomanda < annoInizioLavCp){      
      htmpl.newBlock("blkDettaglioF");
      htmpl.set("blkDettaglioF.idDomandaassegnazione", request.getParameter("idDomAss"));
      
      htmpl.newBlock("blkDettaglioG");
      htmpl.set("blkDettaglioG.idDomandaassegnazione", request.getParameter("idDomAss"));
    }
    
    SolmrLogger.debug(this, "--- idDittaUma ="+dumaVO.getIdDittaUMA());   
    htmpl.set("idDittaUma",dumaVO.getIdDittaUMA().toString());

    if(fdaVO.getDataRif()!=null && !"".equals(fdaVO.getDataRif()))
    {
      htmpl.newBlock("blkQuantMaxContoProp");
      htmpl.set("blkQuantMaxContoProp.dataRif",fdaVO.getDataRif());
      SolmrLogger.debug(this, " --- QuantMaxAssContoPropSuccess ="+fdaVO.getQuantMaxAssContoPropSuccess());
      htmpl.set("blkQuantMaxContoProp.quantMaxAssContoPropSuccess",fdaVO.getQuantMaxAssContoPropSuccess());
      SolmrLogger.debug(this, " --- percAssContoPropSuccess ="+fdaVO.getPercAssContoPropSuccess());
      htmpl.set("blkQuantMaxContoProp.percAssContoPropSuccess",fdaVO.getPercAssContoPropSuccess());
    }

    HtmplUtil.setValues(htmpl, fdaVO);
    HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

    it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
    out.print(htmpl.text());

%>

