<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>

<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.StoricoAssegnazioniVO"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@page import="it.csi.solmr.etc.SolmrConstants"%> 
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
    String layoutUrl = "/domass/layout/assegnazioni.htm";
    ValidationException valEx;
    Validator validator = new Validator(layoutUrl);

    Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layoutUrl);
    // A causa del fatto che questa pagina ha il menu della assegnazione base
    // ma è inserita nel CU del dettaglio azienda (che è di pertinenza di un
    // altro menu) viene cambiata al volo la classe Autorizzazione per
    // permettere l'utilizzo del gestore di menu corretto.
    it.csi.solmr.presentation.security.Autorizzazione autAssegnazioneBase=
    (it.csi.solmr.presentation.security.Autorizzazione)
    it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ASSEGNAZIONE_BASE");
    request.setAttribute("__autorizzazione",autAssegnazioneBase);
%><%@include file = "/include/menu.inc" %><%
    SolmrLogger.info(this, "Found layout: "+layoutUrl);

    SolmrLogger.debug(this, "BEGIN assegnazioniView");

    UmaFacadeClient umaClient = new UmaFacadeClient();
    DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) request.getSession().getAttribute("dittaUMAAziendaVO");
    
    boolean cancella = request.getParameter("canc") != null;

    Vector storAss = (Vector) request.getAttribute("storAss");

    int numDomAss = storAss.size(); // lunghezza del vettore;
    StoricoAssegnazioniVO stor;
    
	  int totalePagine;
	
	  int pagCorrente;
	
	  Integer currPage;

    
		//if(session.getAttribute("currPage")==null)
		if(request.getAttribute("currPage")==null)
	
	    pagCorrente=1;
	
	  else
			//pagCorrente = ((Integer)session.getAttribute("currPage")).intValue();
	    pagCorrente = ((Integer)request.getAttribute("currPage")).intValue();
	
	  if(storAss!=null){
	
	    totalePagine=storAss.size()/SolmrConstants.NUM_MAX_ROWS_PAG;
	
	    int resto = storAss.size()%SolmrConstants.NUM_MAX_ROWS_PAG;
	
	    if(resto!=0)
	
	      totalePagine+=1;
	
	    htmpl.set("currPage",""+pagCorrente);
	
	    htmpl.set("totPage",""+totalePagine);
	
	    htmpl.set("numeroRecord",""+storAss.size());
	
	    currPage = new Integer(pagCorrente);
	
	    session.setAttribute("currPage",currPage);
	
	    if(pagCorrente>1)
	
	      htmpl.newBlock("bottoneIndietro");
	
	    if(pagCorrente<totalePagine)
	
	      htmpl.newBlock("bottoneAvanti");
	
	  }
    

    htmpl.newBlock("BLK_INTEST_ASSEGNAZIONE");

    if( numDomAss!=0 ){
        if( request.getAttribute("idDittaUma")!=null )
        {
          SolmrLogger.debug(this,"request.getAttribute(\"idDittaUma\")!=null");
          htmpl.set("idDittaUMA", ""+(Long) request.getAttribute("idDittaUma"));
        }
        else
        {
          SolmrLogger.debug(this,"request.getAttribute(\"idDittaUma\")==null");
        }

  		int baseIntervallo = SolmrConstants.NUM_MAX_ROWS_PAG * (pagCorrente-1);
  		int limiteIntervallo = pagCorrente * SolmrConstants.NUM_MAX_ROWS_PAG;
  		if(numDomAss < limiteIntervallo)
  		{
  			limiteIntervallo = numDomAss;
  		}
  			
  	  Long year = null;
  	  
        for(int i=baseIntervallo;i<limiteIntervallo;i++)
        {
          htmpl.newBlock("BLKASSEGNAZIONE");

          stor = (StoricoAssegnazioniVO) storAss.get(i);
          boolean agriwellOn = Validator.isNotEmpty(stor.getIdentificativoDomanda());
          
          if( year==null || year.compareTo(stor.getAnno())!=0 ){
  	        
          	year = stor.getAnno();

          	DomandaAssegnazione accontoValidato = umaClient.findAccontoValidatoByIdDittaUMA(dittaUMAAziendaVO.getIdDittaUMA(), year);
          	
  	        Long qaCp = stor.getAssegnazioneCP();
  	        Long qaCt = stor.getAssegnazioneCT();
  	        Long qaSr = stor.getAssegnazioneSR();
  	        //Long qpMa = new Long(0);
  	        Long qpCP = new Long(0);
  	        Long qpCT = new Long(0);
  	        Long qpSr = new Long(0);
  	        
  	        if(stor.getTipoDomanda().equals("A") && !SolmrConstants.DESC_STATO_DOMANDA_ACCONTO_VALIDATO.equalsIgnoreCase(stor.getDescrizioneStatoDomanda())){
  	          if(accontoValidato!=null){
     	          qaCp = new Long(0); qaCt = new Long(0); qaSr = new Long(0);
  	          }
  	        }
  	        
  	        //Se la prima domanda è una supplementare allora le quantità prelevate sono 0 di partenza altrimenti prendo come valore di partenza la base o l'acconto
  	        if(!SolmrConstants.DESC_STATO_DOMANDA_ANNULLATA.equalsIgnoreCase(stor.getDescrizioneStatoDomanda()) 
  	            && !SolmrConstants.DESC_STATO_DOMANDA_ACCONTO_SOSTITUITO.equalsIgnoreCase(stor.getDescrizioneStatoDomanda())
  	            && !SolmrConstants.TIPO_DOMANDA_SUPPLEMENTARE.equals(stor.getTipoDomanda())){
  		        //qpMa = stor.getPrelevataMA();
  		        qpCP = stor.getPrelevataCP();
  		        qpCT = stor.getPrelevataCT();
  		        qpSr = stor.getPrelevataSR();
  	        }
  	        //CALCOLO TOTALI PER ANNO
  	        if(i<limiteIntervallo-1){
  		        for(int j=i;j<limiteIntervallo;j++){
  		        	if(storAss.size() == (j+1)){
  		        		//Il limiteIntervallo è più grande delle assegnazioni presenti, mi devo fermare
  		        		break;
  		        	}
  		        	StoricoAssegnazioniVO next = (StoricoAssegnazioniVO) storAss.get(j+1);
  		        	if(year.compareTo(next.getAnno())==0){
  		        		
  		        		if(!agriwellOn){
  		        			agriwellOn = Validator.isNotEmpty(next.getIdentificativoDomanda());
  		        		}
  		        		
  		        		if(!SolmrConstants.DESC_STATO_DOMANDA_ANNULLATA.equalsIgnoreCase(next.getDescrizioneStatoDomanda())&&(!SolmrConstants.DESC_STATO_DOMANDA_ACCONTO_SOSTITUITO.equalsIgnoreCase(next.getDescrizioneStatoDomanda()))){
  		              if(!(next.getTipoDomanda().equals("A") && !SolmrConstants.DESC_STATO_DOMANDA_ACCONTO_VALIDATO.equalsIgnoreCase(next.getDescrizioneStatoDomanda()) && accontoValidato!=null)){  
  		        		    qaCp += next.getAssegnazioneCP();
  			    	        qaCt += next.getAssegnazioneCT();
  			    	        qaSr += next.getAssegnazioneSR();
  			    	        //La quantità prelevata è uguale alla somma delle qta prelevate per le domande valide di base e acconto
  			    	        if(!SolmrConstants.TIPO_DOMANDA_SUPPLEMENTARE.equals(stor.getTipoDomanda()) || (SolmrConstants.TIPO_DOMANDA_SUPPLEMENTARE.equals(stor.getTipoDomanda()) && !SolmrConstants.TIPO_DOMANDA_SUPPLEMENTARE.equals(next.getTipoDomanda()))){
  				    	    	//qpMa += next.getPrelevataMA();
  				    	    	qpCP = next.getPrelevataCP();
  				    	    	qpCT = next.getPrelevataCT();  				    	    	
  				    	    	qpSr += next.getPrelevataSR();	
  			    	        }
  		              }
  		        		}
  		        	}else{
  		        		//Esaurite le assegnazioni per l'anno in esame
  		        		break;
  		        	}
  		        }
  	        }
  	        
  	        htmpl.newBlock("BLKASSEGNAZIONE.BLKANNOASSEGNAZIONE");
  	        htmpl.set("BLKASSEGNAZIONE.BLKANNOASSEGNAZIONE.anno", "" + year);
  	        htmpl.set("BLKASSEGNAZIONE.BLKANNOASSEGNAZIONE.rimenzaCP", "" + stor.getRimanenzaCP());
  	        htmpl.set("BLKASSEGNAZIONE.BLKANNOASSEGNAZIONE.rimenzaCT", "" + stor.getRimanenzaCT());
  	        htmpl.set("BLKASSEGNAZIONE.BLKANNOASSEGNAZIONE.rimenzaSR", "" + stor.getRimanenzaSR());
  	        htmpl.set("BLKASSEGNAZIONE.BLKANNOASSEGNAZIONE.consumoCP", "" + stor.getConsumoCP());
  	        htmpl.set("BLKASSEGNAZIONE.BLKANNOASSEGNAZIONE.consumoCT", "" + stor.getConsumoCT() );
  	        htmpl.set("BLKASSEGNAZIONE.BLKANNOASSEGNAZIONE.consumoSR", "" + stor.getConsumoSR() );
  	        htmpl.set("BLKASSEGNAZIONE.BLKANNOASSEGNAZIONE.assegnCP", "" + qaCp );
  	        htmpl.set("BLKASSEGNAZIONE.BLKANNOASSEGNAZIONE.assegnCT", "" + qaCt );
  	        htmpl.set("BLKASSEGNAZIONE.BLKANNOASSEGNAZIONE.assegnSR", "" + qaSr );
  	        //htmpl.set("BLKASSEGNAZIONE.BLKANNOASSEGNAZIONE.quantPrelMA", "" + qpMa );
  	        htmpl.set("BLKASSEGNAZIONE.BLKANNOASSEGNAZIONE.quantPrelCP", "" + qpCP );
  	        htmpl.set("BLKASSEGNAZIONE.BLKANNOASSEGNAZIONE.quantPrelCT", "" + qpCT );
  	        htmpl.set("BLKASSEGNAZIONE.BLKANNOASSEGNAZIONE.quantPrelSR", "" + qpSr );
  	        
  	        if(agriwellOn)
  	        {
  	          htmpl.newBlock("BLKASSEGNAZIONE.BLKANNOASSEGNAZIONE.blkLinkAgriWell");
  	          htmpl.set("BLKASSEGNAZIONE.BLKANNOASSEGNAZIONE.blkLinkAgriWell.anno", ""+stor.getAnno());
  	        }
          }

          //Seleziono la prima Domanda di Assegnazione corrisponde alla più recente - Begin
          if (i==0){
            htmpl.set("BLKASSEGNAZIONE.checked", "checked");
          }
          //Seleziono la prima Domanda di Assegnazione corrisponde alla più recente - End
          SolmrLogger.debug(this,"stor.getIdDomAss(): " + stor.getIdDomAss());
          
          String tipoDomanda=stor.getTipoDomanda();
          
          /* if(SolmrConstants.TIPO_DOMANDA_SUPPLEMENTARE.equals(tipoDomanda)){
          	//Per la gestione delle domande supplementari mi servono sia id assegnazione carburante che id domanda assegnazione
          	// S_IDASSCARB-IDDOMASS
  	        htmpl.set("BLKASSEGNAZIONE.idDomAss", "S_" + stor.getIdAssCarb() + "-" +stor.getIdDomAss() );
          }else{
  	        htmpl.set("BLKASSEGNAZIONE.idDomAss", "" + stor.getIdDomAss() );
          } */
          
          //Per il momento gestiamo tutto con l'id base senza gestire il supplemento
  	      htmpl.set("BLKASSEGNAZIONE.idDomAss", "" + stor.getIdDomAss() );
          
          String descTipoDomanda=null;
          if (SolmrConstants.TIPO_DOMANDA_ACCONTO.equals(tipoDomanda))
          {
          	descTipoDomanda = SolmrConstants.DESCRIZIONE_TIPO_DOMANDA_ACCONTO;
          }
          else if (SolmrConstants.TIPO_DOMANDA_BASE.equals(tipoDomanda))
  		{
  	        descTipoDomanda = SolmrConstants.DESCRIZIONE_TIPO_DOMANDA_BASE;
  	    }
          else if(SolmrConstants.TIPO_DOMANDA_SUPPLEMENTARE.equals(tipoDomanda)){
  	       	descTipoDomanda = SolmrConstants.DESCRIZIONE_TIPO_DOMANDA_SUPPLEMENTARE + " " + stor.getNumeroSupplemento();
          }
          
          htmpl.set("BLKASSEGNAZIONE.tipologia", descTipoDomanda);
          htmpl.set("BLKASSEGNAZIONE.anno", "" + stor.getAnno());
          htmpl.set("BLKASSEGNAZIONE.identificativoDomanda", stor.getIdentificativoDomanda());
          htmpl.set("BLKASSEGNAZIONE.stato", "" + stor.getDescrizioneStatoDomanda());
          htmpl.set("BLKASSEGNAZIONE.assegnCP", "" + stor.getAssegnazioneCP() );
          htmpl.set("BLKASSEGNAZIONE.assegnCT", "" + stor.getAssegnazioneCT() );
          htmpl.set("BLKASSEGNAZIONE.assegnSR", "" + stor.getAssegnazioneSR() );
          //htmpl.set("BLKASSEGNAZIONE.quantPrelMA", "" + stor.getPrelevataMA() );
          htmpl.set("BLKASSEGNAZIONE.quantPrelCP", "" + stor.getPrelevataCP() );
  	      htmpl.set("BLKASSEGNAZIONE.quantPrelCT", "" + stor.getPrelevataCT() );
          htmpl.set("BLKASSEGNAZIONE.quantPrelSR", "" + stor.getPrelevataSR() );
          
          /* if(Validator.isNotEmpty(stor.getIdentificativoDomanda()))
          {
            htmpl.newBlock("BLKASSEGNAZIONE.blkLinkAgriWell");
            htmpl.set("BLKASSEGNAZIONE.blkLinkAgriWell.anno", ""+stor.getAnno());
          } */
          
          if (i==0){
            htmpl.set("BLKASSEGNAZIONE.firstLine", "style='color:red'");
          }
        }
      }else{
      //Non esiste Domanda di Assegnazione
      //Disabilita pulsanti che agiscono sulle Domande di Assegnazione
      htmpl.set("disvisualizza", "style=cursor:default disabled");
      //htmpl.set("discrea", "style=cursor:default disabled");
      htmpl.set("discancella", "style=cursor:default disabled");
      htmpl.set("diselenco", "style=cursor:default disabled");
      htmpl.set("message","Nessuna Domanda di Assegnazione Presente.");
    }

    /*
    if(cancella) {
      htmpl.set("exception","Cancellazione eseguita!");
    }
    */


    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

    if(ruoloUtenza.isReadWrite()&&
       (ruoloUtenza.isUtenteIntermediario()||
       ruoloUtenza.getIstatProvincia().equalsIgnoreCase(dittaUMAAziendaVO.getProvUMA())))
    {
      htmpl.set("linkAssegnazione.annoDiRiferimento", ""+DateUtils.getCurrentYear());
    }

    //this.errErrorValExc(htmpl, request, exception);
    HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);
	
    out.print(htmpl.text());
%>
