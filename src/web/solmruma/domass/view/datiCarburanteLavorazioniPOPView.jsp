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
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%

    SolmrLogger.debug(this,"Caricamento di : datiCarburanteLavorazioniPOPView.jsp");

    String layoutUrl = "/domass/layout/datiCarburanteLavorazioniPOP.htm";
    ValidationException valEx;
    Validator validator = new Validator(layoutUrl);
    Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(layoutUrl);
    

    // ---------------- Decurtazioni dei Conto Terzi --------------
    Vector vect = (Vector)request.getAttribute("vect");
    long totLitriGasolioLavorazioni = 0;
    long totLitriBenzinaLavorazioni = 0;
    long totCarburanteDecurtato = 0;

    int size = vect.size();
    if(size >0){
      SolmrLogger.debug(this, "-- Ci sono dati relativi alle decurtazioni Conto Terzi");
      htmpl.newBlock("blkDatiCarburanteDecurtato");
      String blk = "blkDatiCarburanteDecurtato.blkCarburanteLavorazioni";

      for(int i=0; i<size; i++){
        FrmDettaglioAssegnazioneLavorazioniVO dalVO = (FrmDettaglioAssegnazioneLavorazioniVO)vect.get(i);
        htmpl.newBlock(blk);

      	htmpl.set(blk+".CUAA", dalVO.getCuaa());
     	htmpl.set(blk+".partitaIVA", dalVO.getPartitaIVA());
      	htmpl.set(blk+".denominazioneAzienda", dalVO.getDenominazioneAzienda());
      	htmpl.set(blk+".descrizioneUsoSuolo", dalVO.getDescrizioneUsoSuolo());
      	htmpl.set(blk+".descrizioneLavorazione", dalVO.getDescrizioneLavorazione());
      	htmpl.set(blk+".numeroEsecuzioni", dalVO.getNumeroEsecuzioni());
      	htmpl.set(blk+".codiceUnitaDiMisura", dalVO.getCodiceUnitaDiMisura());      
      	htmpl.set(blk+".superificieOre", dalVO.getSuperificieOre());
      
      	String gasolioLavorazioni = dalVO.getGasolioLavorazioni()!=null?dalVO.getGasolioLavorazioni():"0";
      	htmpl.set(blk+".gasolioLavorazioni", gasolioLavorazioni);
      
      	String benzinaLavorazioni = dalVO.getBenzinaLavorazioni()!=null?dalVO.getBenzinaLavorazioni():"0";
      	htmpl.set(blk+".benzinaLavorazioni", benzinaLavorazioni);
      	
      	Long carburanteDec = dalVO.getCarburanteDecurtato()!=null?new Long(dalVO.getCarburanteDecurtato()):new Long(0);
      	totCarburanteDecurtato = totCarburanteDecurtato + carburanteDec.longValue();
      	htmpl.set(blk+".carburanteDecurtato", dalVO.getCarburanteDecurtato() != null ? dalVO.getCarburanteDecurtato() :"0");

      	htmpl.set(blk+".numeroFatture", dalVO.getNumeroFatture());

		Long gasolioLavorazioniLong = dalVO.getGasolioLavorazioni()!=null?new Long(dalVO.getGasolioLavorazioni()):new Long(0);
      	totLitriGasolioLavorazioni = totLitriGasolioLavorazioni + gasolioLavorazioniLong.longValue();

		Long benzinaLavorazioniLong = dalVO.getBenzinaLavorazioni()!=null?new Long(dalVO.getBenzinaLavorazioni()):new Long(0);
      	totLitriBenzinaLavorazioni = totLitriBenzinaLavorazioni + benzinaLavorazioniLong.longValue();
      
      }      
      htmpl.set("blkDatiCarburanteDecurtato.totLitriGasolioLavorazioni", ""+totLitriGasolioLavorazioni);
      htmpl.set("blkDatiCarburanteDecurtato.totLitriBenzinaLavorazioni", ""+totLitriBenzinaLavorazioni);
      htmpl.set("blkDatiCarburanteDecurtato.totCarburanteDecurtato",""+totCarburanteDecurtato);
    }
    else{
      SolmrLogger.debug(this, "-- NON ci sono dati relativi alle decurtazioni Conto Terzi");      
    }
    
    
    
    // ---------------- Decurtazioni dei Consorzi --------------
    Vector<FrmDettaglioAssegnazioneLavorazioniVO> decurtazVectConsorzi = (Vector<FrmDettaglioAssegnazioneLavorazioniVO>)request.getAttribute("decurtazVectConsorzi");
    long totLitriGasolioLavorazioniConsorzi = 0;
    long totLitriBenzinaLavorazioniConsorzi = 0;
    long totCarburanteDecurtatoConsorzi = 0;
    if(decurtazVectConsorzi != null && decurtazVectConsorzi.size()>0){
      SolmrLogger.debug(this, "-- Ci sono dati relativi alle decurtazioni Consorzi");
      
      htmpl.newBlock("blkDatiCarburanteDecurtatoConsorzi");
      String blk = "blkDatiCarburanteDecurtatoConsorzi.blkCarburanteLavorazioniConsorzi";

      for(int i=0; i<decurtazVectConsorzi.size(); i++){
        FrmDettaglioAssegnazioneLavorazioniVO dalVO = (FrmDettaglioAssegnazioneLavorazioniVO)decurtazVectConsorzi.get(i);
        htmpl.newBlock(blk);

      	htmpl.set(blk+".CUAA", dalVO.getCuaa());
     	htmpl.set(blk+".partitaIVA", dalVO.getPartitaIVA());
      	htmpl.set(blk+".denominazioneAzienda", dalVO.getDenominazioneAzienda());
      	htmpl.set(blk+".descrizioneUsoSuolo", dalVO.getDescrizioneUsoSuolo());
      	htmpl.set(blk+".descrizioneLavorazione", dalVO.getDescrizioneLavorazione());
      	htmpl.set(blk+".numeroEsecuzioni", dalVO.getNumeroEsecuzioni());
      	htmpl.set(blk+".codiceUnitaDiMisura", dalVO.getCodiceUnitaDiMisura());      
      	htmpl.set(blk+".superificieOre", dalVO.getSuperificieOre());
      
      	String gasolioLavorazioni = dalVO.getGasolioLavorazioni()!=null?dalVO.getGasolioLavorazioni():"0";
      	htmpl.set(blk+".gasolioLavorazioni", gasolioLavorazioni);
      
      	String benzinaLavorazioni = dalVO.getBenzinaLavorazioni()!=null?dalVO.getBenzinaLavorazioni():"0";
      	htmpl.set(blk+".benzinaLavorazioni", benzinaLavorazioni);

		Long gasolioLavorazioniLong = dalVO.getGasolioLavorazioni()!=null?new Long(dalVO.getGasolioLavorazioni()):new Long(0);
      	totLitriGasolioLavorazioniConsorzi = totLitriGasolioLavorazioniConsorzi + gasolioLavorazioniLong.longValue();

		Long benzinaLavorazioniLong = dalVO.getBenzinaLavorazioni()!=null?new Long(dalVO.getBenzinaLavorazioni()):new Long(0);
      	totLitriBenzinaLavorazioniConsorzi = totLitriBenzinaLavorazioniConsorzi + benzinaLavorazioniLong.longValue();
      	
      	
      	Long carburanteDec = dalVO.getCarburanteDecurtato()!=null?new Long(dalVO.getCarburanteDecurtato()):new Long(0);
      	totCarburanteDecurtatoConsorzi = totCarburanteDecurtatoConsorzi + carburanteDec.longValue();
      	htmpl.set(blk+".carburanteDecurtato", dalVO.getCarburanteDecurtato() != null ? dalVO.getCarburanteDecurtato() :"0");      	
      }      
      htmpl.set("blkDatiCarburanteDecurtatoConsorzi.totLitriGasolioLavorazioni", ""+totLitriGasolioLavorazioniConsorzi);
      htmpl.set("blkDatiCarburanteDecurtatoConsorzi.totLitriBenzinaLavorazioni", ""+totLitriBenzinaLavorazioniConsorzi);
      htmpl.set("blkDatiCarburanteDecurtatoConsorzi.totCarburanteDecurtato",""+totCarburanteDecurtatoConsorzi);
    }
    else{
      SolmrLogger.debug(this, "-- NON ci sono dati relativi alle decurtazioni Consorzi");      
    }
    
    
    // Se i due elenchi sono vuoti -> indicarlo all'utente
    if( (vect == null || vect.size() == 0) && (decurtazVectConsorzi == null || decurtazVectConsorzi.size() == 0) ){
      SolmrLogger.debug(this, "-- Non ci sono dati da visualizzare!");
      htmpl.newBlock("blkNoDati");
      htmpl.set("blkNoDati.msgNoDati", "Non sono presenti dati relativi a lavorazioni oggetto di decurtazione");
    }
    
    
    
  
    htmpl.set("annoDiRiferimento", (String)request.getAttribute("annoDomanda"));

    it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

  	it.csi.solmr.presentation.security.Autorizzazione aut=(it.csi.solmr.presentation.security.Autorizzazione)
  	it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ACCESSO_SISTEMA");
  	RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  	aut.writeBanner(htmpl, ruoloUtenza,request);

    out.print(htmpl.text());

%>