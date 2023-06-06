<%@ page language="java" contentType="text/html"%>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="java.util.*"%>

<%
  SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service] BEGIN.");
  String iridePageName = "restituzioneBuoniCtrl.jsp";
%>
  
<%@include file = "/include/autorizzazione.inc" %>

<%
 UmaFacadeClient client = new UmaFacadeClient();
 ValidationError error = null;
 ValidationErrors errors = null;
 String url = "/domass/layout/elencoBuoniEmessi.htm";
 RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
 DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
 BuonoPrelievoVO buonoVO = (BuonoPrelievoVO)session.getAttribute("buonoVO");
 PrelievoVO benzinaVO = null;
 PrelievoVO gasolioVO = null;
 String gasolioConc = request.getParameter("gasolioConc");
 String benzinaConc = request.getParameter("benzinaConc");
 String gasolioPrel = request.getParameter("gasolioPrel");
 String benzinaPrel = request.getParameter("benzinaPrel");
 Vector v_carb = (Vector)session.getAttribute("v_carb");
 
 // 18-11-2008 - Nick - CU-GUMA-15 gestione buoni emessi.  
 String strDataRiferimento = client.getParametro(SolmrConstants.PARAMETRO_DTBP);    
 SolmrLogger.debug(this, "-- strDataRiferimento ="+strDataRiferimento);
 Date dataRiferimento = DateUtils.parseDate(strDataRiferimento);
 request.setAttribute("data_riferimento", dataRiferimento); 
 /////   

 // L'utente ha pigiato "salva"
 if(request.getParameter("salva") != null)
 {
   Long idCarburanteGasolio = null;
   Long idCarburanteBenzina = null;
   if(request.getParameter("idCarburanteGasolio")!=null && !request.getParameter("idCarburanteGasolio").equals(""))
      idCarburanteGasolio = new Long(request.getParameter("idCarburanteGasolio"));
   
   if(request.getParameter("idCarburanteBenzina")!=null && !request.getParameter("idCarburanteBenzina").equals(""))
     idCarburanteBenzina = new Long(request.getParameter("idCarburanteBenzina"));
     
   SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service] Id Carburante Gasolio "+idCarburanteGasolio);
   SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service] Id Carburante Benzina "+idCarburanteBenzina);
   
   Date dataRestituzione = null;
   Date dataEmissione = null;
   Date dataOdierna = DateUtils.parseDate(DateUtils.getCurrent());
   SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service] DATA DI OGGI :::: "+dataOdierna);
   SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service] BUOOOOOOONO VO.... "+buonoVO);
   
   //Inizio controllo date
   //La Data restituzione non dev'essere nulla o inferiore inferiore alla data di emissione
   SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service] Data Restituzione.... "+request.getParameter("dataRestituzione"));
   SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service] Data Emissione.... "+request.getParameter("dataEmissione"));
   SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service] Gasolio.... "+request.getParameter("gasolioConc"));
   SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service] Benzina.... "+request.getParameter("benzinaConc"));
   
   if(request.getParameter("dataRestituzione") != null && !request.getParameter("dataRestituzione").equals("")){      		   
     if(!Validator.validateDateF(request.getParameter("dataRestituzione"))){
       error=new ValidationError(""+UmaErrors.get("FORMATO_DATA_ERRATO"));
       errors = errors==null?new ValidationErrors():errors;
       errors.add("data", error);
     }
     else
     {
       dataRestituzione = DateUtils.parseDate(request.getParameter("dataRestituzione"));
     }
     dataEmissione = DateUtils.parseDate(request.getParameter("dataEmissione"));
     if (dataRestituzione!=null)
     {
       if (dataRestituzione.before(dataEmissione)||dataRestituzione.after(dataOdierna))
       {
         error=new ValidationError(""+UmaErrors.get("ERR_DATA_RESTITUZIONE"));
         errors = errors==null?new ValidationErrors():errors;
         errors.add("data", error);
       }
     }
   }
   else{   	  
     error=new ValidationError(""+UmaErrors.get("ERR_DATA_RESTITUZIONE"));
     errors = errors==null?new ValidationErrors():errors;
     errors.add("data", error);
   }
   //Fine Controllo date

   // Controllo quantità prelevate
   /*if(gasolioPrel != null && !gasolioPrel.equals("") && benzinaPrel!=null && !benzinaPrel.equals("") &&
      (!gasolioConc.equals("0") && (!gasolioPrel.equals("0")||gasolioPrel.equals("0")&& !benzinaConc.equals("0")&&!benzinaPrel.equals("0"))||
       !benzinaConc.equals("0") && (!benzinaPrel.equals("0")||benzinaPrel.equals("0")&& !gasolioConc.equals("0")&&!gasolioPrel.equals("0")))){*/
       
   Long gPrel = null;
   Long bPrel = null;
   Long bConc = null;
   Long gConc = null;
   
   try{
     gPrel = new Long(gasolioPrel);
     bPrel = new Long(benzinaPrel);
     bConc = new Long(benzinaConc);
     gConc = new Long(gasolioConc);
   }
   catch(Exception ex){
     SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service] Eccezione in restituisci buono "+ex+" - "+ex.getMessage());
     error=new ValidationError("Formato del dato non valido!");
     errors = errors==null?new ValidationErrors():errors;
     errors.add("qta", error);
     request.setAttribute("errors", errors);
     request.getRequestDispatcher("/domass/view/restituzioneBuonoView.jsp").forward(request, response);
     return;
   }
   
   if(gasolioPrel!= null &&! gasolioPrel.equals("")&& benzinaPrel!=null && !benzinaPrel.equals("")&&
      gPrel.longValue() >= 0 && bPrel.longValue() >= 0){
     buonoVO.setDataRestituzione(dataRestituzione);
     if("serra".equals(request.getParameter("carburante")))
       buonoVO.setCarburantePerSerra("S");
     if(idCarburanteGasolio!=null&&!idCarburanteGasolio.equals("")){
       gasolioVO = new PrelievoVO();
       gasolioVO.setQtaPrelevata(new Long(gasolioPrel));
       if(ruoloUtenza.getIdUtente()!=null)
         gasolioVO.setIdUtenteAggiornamento(ruoloUtenza.getIdUtente());
       gasolioVO.setDataAggiornamento(dataRestituzione);
       gasolioVO.setIdBuonoCarburante(idCarburanteGasolio);
     }
     if(idCarburanteBenzina!=null&&!idCarburanteBenzina.equals("")){
       benzinaVO = new PrelievoVO();
       benzinaVO.setQtaPrelevata(new Long(benzinaPrel));
       if(ruoloUtenza.getIdUtente()!=null)
         benzinaVO.setIdUtenteAggiornamento(ruoloUtenza.getIdUtente());
       benzinaVO.setDataAggiornamento(dataRestituzione);
       benzinaVO.setIdBuonoCarburante(idCarburanteBenzina);
     }
   }
   else{
     error=new ValidationError(""+UmaErrors.get("CHECK_QTA_PRELEVATA"));
     errors = errors==null?new ValidationErrors():errors;
     errors.add("qta", error);
   }
   if(gPrel.compareTo(gConc) > 0 || bPrel.compareTo(bConc) > 0){
     error=new ValidationError(""+UmaErrors.get("ERR_QTA_PRELEVATA"));
     errors = errors==null?new ValidationErrors():errors;
     errors.add("qta", error);
   }
   boolean isPrelievoGasolio=gPrel!=null && gPrel.longValue()>0;
   boolean isPrelievoBenzina=bPrel!=null && bPrel.longValue()>0;

   boolean isBuono99999=it.csi.solmr.etc.SolmrConstants.NUMERO_BLOCCO.equals(StringUtils.checkNull(buonoVO.getNumeroBlocco()));
   Long qtaUltimoPrelievoB=null;
   Long qtaUltimoPrelievoG=null;
   Date dataUltimoPrelievoG=null;
   Date dataUltimoPrelievoB=null;
   
   // 18-11-2008 - Nick - CU-GUMA-15 gestione buoni emessi.
   if (!isBuono99999 && dataEmissione != null && dataEmissione.before(dataRiferimento))
   {
     errors = errors==null?new ValidationErrors():errors;

     String dataUltimoPrelievoGStr=request.getParameter("dataUltimoPrelievoG");
     dataUltimoPrelievoG=Validator.validateDateAll(dataUltimoPrelievoGStr,"dataUltimoPrelievo","data ultimo prelievo", errors,false,true);
     String dataUltimoPrelievoBStr=request.getParameter("dataUltimoPrelievoB");
     dataUltimoPrelievoB=Validator.validateDateAll(dataUltimoPrelievoBStr,"dataUltimoPrelievo","data ultimo prelievo", errors,false,true);
     boolean isDataUltimoPrelievoB=dataUltimoPrelievoB!=null;
     boolean isDataUltimoPrelievoG=dataUltimoPrelievoG!=null;
     int annoEmissione=DateUtils.extractYearFromDate(dataEmissione);
     if(dataUltimoPrelievoB!=null)
     {
       int anno=DateUtils.extractYearFromDate(dataUltimoPrelievoB);
       if (anno!=annoEmissione)
       {
          errors.add("dataUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_ANNO_EMISSIONE_DIVERSO_ANNO_PRELIEVO));
       }
     }

     if(dataUltimoPrelievoG!=null)
     {
       int anno=DateUtils.extractYearFromDate(dataUltimoPrelievoG);
       if (anno!=annoEmissione)
       {
          errors.add("dataUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_ANNO_EMISSIONE_DIVERSO_ANNO_PRELIEVO));
       }
     }


//     Date dataRestituzioneDate=DateUtils.parseDate(request.getParameter("dataRestituzione"));
     if (errors.get("dataUltimoPrelievo")==null)
     {
       if (isPrelievoBenzina!=isDataUltimoPrelievoB)
       {
          if (isPrelievoBenzina)
          {
            errors.add("dataUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_CAMPO_OBBLIGATORIO));
          }
          else
          {
            errors.add("dataUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_DATO_NON_COMPATIBILE_QTA_PRELEVATA));
          }
       }
       else
       {
          if (dataUltimoPrelievoB!=null)
          {
            if (dataRestituzione!=null && dataUltimoPrelievoB.after(dataRestituzione))
            {
              errors.add("dataUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_DATA_ULTIMO_PRELIEVO_SUCC_DATA_REST));
            }
            if (dataEmissione!=null && dataUltimoPrelievoB.before(dataEmissione))
            {
              errors.add("dataUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_DATA_ULTIMO_PRELIEVO_PREC_DATA_EMISSIONE));
            }
          }
       }
     }

     if (errors.get("dataUltimoPrelievo")==null)
     {
       if (isPrelievoGasolio!=isDataUltimoPrelievoG)
       {
          if (isPrelievoGasolio)
          {
            errors.add("dataUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_CAMPO_OBBLIGATORIO));
          }
          else
          {
            errors.add("dataUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_DATO_NON_COMPATIBILE_QTA_PRELEVATA));
          }
       }
       else
       {
          if (dataUltimoPrelievoG!=null)
          {
            if (dataRestituzione != null && dataUltimoPrelievoG.after(dataRestituzione))
            {
              errors.add("dataUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_DATA_ULTIMO_PRELIEVO_SUCC_DATA_REST));
            }
            if (dataEmissione!=null && dataUltimoPrelievoG.before(dataEmissione))
            {
              errors.add("dataUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_DATA_ULTIMO_PRELIEVO_PREC_DATA_EMISSIONE));
            }
          }
       }
     }

     if (isPrelievoGasolio!=isDataUltimoPrelievoG)
     {
        if (isPrelievoGasolio)
        {
          errors.add("dataUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_CAMPO_OBBLIGATORIO));
        }
        else
        {
          errors.add("dataUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_DATO_NON_COMPATIBILE_QTA_PRELEVATA));
        }
     }

     if (isPrelievoBenzina!=isDataUltimoPrelievoB)
     {
        if (isPrelievoBenzina)
        {
          errors.add("dataUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_CAMPO_OBBLIGATORIO));
        }
        else
        {
          errors.add("dataUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_DATO_NON_COMPATIBILE_QTA_PRELEVATA));
        }
     }


     String qtaUltimoPrelievoGStr=request.getParameter("qtaUltimoPrelievoG");
     String qtaUltimoPrelievoBStr=request.getParameter("qtaUltimoPrelievoB");


     if (Validator.isNotEmpty(qtaUltimoPrelievoBStr))
     {
       try
       {
          qtaUltimoPrelievoB=new Long(qtaUltimoPrelievoBStr);
          long value=qtaUltimoPrelievoB.longValue();
          if (value<0)
          {
            qtaUltimoPrelievoB=null;
            errors.add("qtaUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_VALORE_NON_VALIDO));
          }
          else
          {
            if (isPrelievoBenzina)
            {
              if (value>bPrel.longValue())
              {
                errors.add("qtaUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_QTA_ULTIMO_PRELIEVO_MAGGIORE_QTA_PRELEVATA));
              }
              if (value==0)
              {
                errors.add("qtaUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_QTA_ULTIMO_PRELIEVO_UGUALE_ZERO));
              }
            }
            else
            {
               if (value!=0)
               {
                 errors.add("qtaUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_DATO_NON_COMPATIBILE_QTA_PRELEVATA));
               }
            }
          }
       }
       catch(Exception e)
       {
            errors.add("qtaUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_VALORE_NON_VALIDO));
       }
     }
     else
     {
        if (isPrelievoBenzina)
        {
          errors.add("qtaUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_CAMPO_OBBLIGATORIO));
        }
     }
     if (Validator.isNotEmpty(qtaUltimoPrelievoGStr))
     {
       try
       {
          qtaUltimoPrelievoG=new Long(qtaUltimoPrelievoGStr);
          long value=qtaUltimoPrelievoG.longValue();
          if (value<0)
          {
            qtaUltimoPrelievoG=null;
            errors.add("qtaUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_VALORE_NON_VALIDO));
          }
          else
          {
            if (isPrelievoGasolio)
            {
              if (value>gPrel.longValue())
              {
                errors.add("qtaUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_QTA_ULTIMO_PRELIEVO_MAGGIORE_QTA_PRELEVATA));
              }
              else
              {
                if (value==0)
                {
                  errors.add("qtaUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_QTA_ULTIMO_PRELIEVO_UGUALE_ZERO));
                }
              }
            }
            else
            {
              if (value!=0)
              {
                errors.add("qtaUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_DATO_NON_COMPATIBILE_QTA_PRELEVATA));
              }
            }
          }
       }
       catch(Exception e)
       {
            errors.add("qtaUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_VALORE_NON_VALIDO));
       }
     }
     else
     {
        if (isPrelievoGasolio)
        {
          errors.add("qtaUltimoPrelievo",new ValidationError(UmaErrors.ERRORE_VAL_CAMPO_OBBLIGATORIO));
        }
     }
   } // End "!isBuono99999"      

   if (errors!=null && errors.size()>0)
   {
       request.setAttribute("errors", errors);
       request.getRequestDispatcher("/domass/view/restituzioneBuonoView.jsp").forward(request, response);
       return;
   }
   
   SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service]  :::.:.:.. Effettuo la restituzione... ");
   SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service] Benzina Prelevata "+benzinaPrel);
   SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service] Gasolio Prelevato "+gasolioPrel);
   SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service] Valori del BuonoVO -> "+buonoVO.getIdBuonoPrelievo()+" ->> "+buonoVO.getDataRestituzione()+" ->>> "+buonoVO.getCarburantePerSerra());
   
   try {
     //18-11-2008 - Nick - CU-GUMA-15 gestione buoni emessi.
     boolean bInserisciBuonoBenzina = false;
     boolean bInserisciBuonoGasolio = false;               
     
     if (isBuono99999 || (!isBuono99999 && dataEmissione.before(dataRiferimento))) {
     	 bInserisciBuonoBenzina = true;
   	 	 bInserisciBuonoGasolio = true;
     }
   	 else {
	   	 if (!isBuono99999 && dataEmissione.after(dataRiferimento) && bPrel.longValue() == 0) {   	 	 
	   	 	 bInserisciBuonoBenzina = true;   	 	    	 	    	 	 	 
	   	 }
	   	 
	   	 if (!isBuono99999 && dataEmissione.after(dataRiferimento) && gPrel.longValue() == 0) {
	   	 	 bInserisciBuonoGasolio = true;	
	   	 }
	 }    
	 ///// 	 
   	    	           
     SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service] Valore dei parametri passati.... "+buonoVO+" - "+gasolioVO+" - "+benzinaVO);
     if (gasolioVO!=null)
     {
        gasolioVO.setDataUltimoPrelievo(dataUltimoPrelievoG);
        gasolioVO.setQtaUltimoPrelievo(qtaUltimoPrelievoG);
     }
     if (benzinaVO!=null)
     {
        benzinaVO.setDataUltimoPrelievo(dataUltimoPrelievoB);
        benzinaVO.setQtaUltimoPrelievo(qtaUltimoPrelievoB);
     }
     buonoVO.setExtIdUtenteAggiornamento(ruoloUtenza.getIdUtente());
     
     //18-11-2008 - Nick - CU-GUMA-15 gestione buoni emessi.
     //client.restituisciBuono(buonoVO, gasolioVO, benzinaVO);          
     client.restituisciBuono(buonoVO, gasolioVO, benzinaVO, bInserisciBuonoBenzina, bInserisciBuonoGasolio); 
          
     //session.removeAttribute("buonoVO");
     session.removeAttribute("v_carb");
     url="/domass/layout/elencoBuoniEmessi.htm";
     request.setAttribute("comeBack", "true");
   }
   catch (SolmrException ex) {
     SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service] Eccezione in restituisci buono "+ex+" - "+ex.getMessage());
     error=new ValidationError(ex.getMessage());
     errors = errors==null?new ValidationErrors():errors;
     errors.add("error", error);
     request.setAttribute("errors", errors);
     request.getRequestDispatcher("/domass/view/restituzioneBuonoView.jsp").forward(request, response);
     return;
   }
 } // End "salva"
 else if(request.getParameter("back")!=null){
   url = "/domass/layout/elencoBuoniEmessi.htm";
 }
 else  { // Entro per la prima volta
   url = "/domass/view/restituzioneBuonoView.jsp";
   //Controllo l'eventuale presenza di bruciatori per serra legati alla Ditta UMA
   try {
     if(buonoVO.getAnnoRiferimento().intValue() < 2004)
        client.esisteBruciatore(dittaVO.getIdDittaUMA());                        
   }
   catch (SolmrException ex) {
     request.setAttribute("esisteBruciatore", ex.getMessage());
     SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service] Eccezzzione "+ex.getMessage());
     /*error=new ValidationError(ex.getMessage());
     errors = errors==null?new ValidationErrors():errors;
     errors.add("error", error);
     request.setAttribute("errors", errors);
     request.getRequestDispatcher("/domass/view/restituzioneBuonoView.jsp").forward(request, response);
     return;*/
   }
 }
 SolmrLogger.debug(this,"[restituzioneBuonoCtrl::service] END.");
%>
<jsp:forward page="<%=url%>"/>
