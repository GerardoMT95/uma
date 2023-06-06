<%@ page language="java" import="it.csi.iride2.policy.interfaces.*" %>
<%@ page import="it.csi.solmr.dto.profile.DoubleStringcodeDescription" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.iride2.policy.entity.*" %>
<%@ page import="it.csi.iride2.policy.exceptions.*" %>
<%@ page import="it.csi.iride2.iridefed.entity.*" %>
<%@ page import="it.csi.iride2.policy.interfaces.*" %>
<%@ page import="java.rmi.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.exception.SolmrException" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.UtenteIride2VO" %>
<%@ page import="it.csi.solmr.etc.profile.AgriConstants" %>
<%@page import="it.csi.solmr.util.PortaleUtils"%>

<%!
  public static String APPLICATIVO_URL="../servlet/IrideRoleSetter";
  public static String SCELTA_RUOLO_URL="/layout/seleziona_ruolo.htm";
%>

<%
  SolmrLogger.debug(this,"   BEGIN sceltaRuoloPEP");
  final String erroreGenerico = "Si è verificato un errore nella configurazione dei ruoli. Contattare l'assistenza.";
  String messaggioErrore = null;
  String URL_ACCESS_POINT = null;
  Htmpl htmpl = null;
  it.csi.papua.papuaserv.presentation.ws.profilazione.axis.Ruolo[] arrRuoli;

  try
  {
    URL_ACCESS_POINT = (String) session.getAttribute("URL_ACCESS_POINT");
    SolmrLogger.debug(this, "--- URL_ACCESS_POINT ="+URL_ACCESS_POINT);
    //Verifica Sessione
    if(URL_ACCESS_POINT==null)
    {
      SolmrLogger.debug(this, "- invalidate"); 
      session.invalidate();
      response.sendRedirect(it.csi.solmr.etc.SolmrConstants.PAGINA_SESSIONE_SCADUTA);
      return;
    }

      //System.err.println("SCELTA_RUOLO_URL: "+SCELTA_RUOLO_URL);
    htmpl = HtmplFactory.getInstance(application).getHtmpl(SCELTA_RUOLO_URL);

      //Stampa banner
    it.csi.solmr.presentation.security.Autorizzazione autAccessoSistema =
      (it.csi.solmr.presentation.security.Autorizzazione) IrideFileParser.elencoSecurity.get("ACCESSO_SISTEMA");
    autAccessoSistema.writeMenu(htmpl, request);

    //Vector ruoliV = new Vector();
    //messaggioErrore = AgriConstants.PROBLEMI_ACCESSO_IRIDE2;
    UmaFacadeClient umaFacadeClient=new UmaFacadeClient();
    //HashMap ruoliH;
    //it.csi.iride2.policy.entity.Identita id=null;
    boolean uniqueRole = false;
    String codeFirstRole = null;
    String idProcedimento = null;


    it.csi.iride2.policy.entity.Identita id = null;
    if(session.getAttribute("identita")!=null){
      id=(it.csi.iride2.policy.entity.Identita)session.getAttribute("identita");
    }

    request.setAttribute("id", id);


      //Application myApp = (Application) session.getAttribute("myApp");

    idProcedimento = (String) it.csi.solmr.etc.SolmrConstants.ID_TIPO_PROCEDIMENTO_UMA;
    htmpl.set("idProcedimento", idProcedimento);
    //it.csi.iride2.iridefed.entity.Ruolo[] ruoli = null;

    try
	  {
    	SolmrLogger.debug(this," ---- prima di findRuoliForPersonaInApplicazione");
    	SolmrLogger.debug(this," -- codiceFiscale ="+id.getCodFiscale());
    	SolmrLogger.debug(this," -- livelloAutenticazione ="+id.getLivelloAutenticazione());
	    arrRuoli = umaFacadeClient.findRuoliForPersonaInApplicazione(id.getCodFiscale(), id.getLivelloAutenticazione());
	    SolmrLogger.debug(this," ---- dopo di findRuoliForPersonaInApplicazione");
	  }
    catch (SolmrException ex)
    {
      SolmrLogger.error(this,"[sceltaRuoloPEP::service] Rilevata eccezione InternalException nella chiamata a papua findRuoliForPersonaInApplicazione");
      SolmrLogger.dumpStackTrace(this,"[sceltaRuoloPEP::service] Dumping stack trace\n",ex);
      //messaggioErrore = AgriConstants.PROBLEMI_ACCESSO_IRIDE2;
      throw new SolmrException(ex.getMessage());
    }
    catch(RuntimeException ruExc)
    {
      SolmrLogger.error(this,"[LoginPEP::service] Rilevata eccezione RuntimeException nella chiamata a papua findRuoliForPersonaInApplicazione");
      SolmrLogger.dumpStackTrace(this,"[sceltaRuoloPEP::service] Dumping stack trace\n",ruExc);
      //messaggioErrore = AgriConstants.PROBLEMI_ACCESSO_IRIDE2;
      throw new SolmrException(ruExc.getMessage());
    }
    catch (Exception ex)
    {
      SolmrLogger.error(this,"[sceltaRuoloPEP::service] Rilevata eccezione Exception nella chiamata a papua findRuoliForPersonaInApplicazione");
      SolmrLogger.dumpStackTrace(this,"[sceltaRuoloPEP::service] Dumping stack trace\n",ex);
      //messaggioErrore = AgriConstants.PROBLEMI_ACCESSO_IRIDE2;
      throw new SolmrException(ex.getMessage());
    }

      //Ruolo ruolo = ruoli[PRIMO_RUOLO];
      //DoubleStringcodeDescription strCode = null;
      //Ruolo ruolo = null;
      //ruoliH = new HashMap();

      //Modifica gestione portale - 050607 - Begin
      /*if(ruoli.length==1){
        uniqueRole = true;
      }*/
      //Modifica gestione portale - 050607 - End

      /*String PORTAL_NAME = (String) session.getAttribute("PORTAL_NAME");
      SolmrLogger.debug(this, " --- PORTAL_NAME ="+PORTAL_NAME);*/

      //todo
      /*UtenteIride2VO utenteIride2VO = new UtenteIride2VO();
      int cntRuoliAbilitatiRUPAR = 0;
      int cntRuoliAbilitatiSISPIE = 0;
      for(int i=0; i<ruoli.length; i++)
      {
        ruolo = ruoli[i];
        ruoliH.put(ruolo.toString(), ruolo);

        strCode = new DoubleStringcodeDescription();

        utenteIride2VO.setCodiceRuolo(ruolo.toString());

        //Modifica gestione portale - 050607 - Begin
        strCode.setFirstCode(ruolo.toString());
        strCode.setFirstDescription(ruolo.getCodiceRuolo());
        //Modifica gestione portale - 050607 - End
        //strCode.setSecondCode(ruolo.getCodiceDominio());

        //Modifica gestione portale - 050607 - Begin
        SolmrLogger.debug(this, "\n\n\n--Ruolo selezionato: "+ruolo.toString());
        Hashtable htIride2 = getDirittoAccesso(request, ruoliH, ruolo.toString());
        String appName = it.csi.solmr.etc.SolmrConstants.APP_NAME_IRIDE2_SMRUMA;
        String dirittoAccesso = (String) htIride2.get(appName);
        SolmrLogger.debug(this, "\n\n\n--dirittoAccesso: "+dirittoAccesso);
        SolmrLogger.debug(this, "\n\n\n\n\n###############################\n\n\n\n\n");

        if(dirittoAccesso!=null){
          if(utenteIride2VO.isRuoloRUPAR()
             && PORTAL_NAME.equalsIgnoreCase(AgriConstants.NOME_PORTALE_RUPAR))
          {
          //Modifica gestione portale - 050607 - End
            if(cntRuoliAbilitatiRUPAR==0)
            {
              //Utile se esiste un solo ruolo associato
              codeFirstRole = ruolo.toString();
            }
            cntRuoliAbilitatiRUPAR++;

            //Modifica gestione portale - 050607 - Begin
            ruoliV.add(strCode);
            //Modifica gestione portale - 050607 - End
          }
          //Modifica gestione portale - 050607 - Begin
          // Modifica istantanea per gestione portale unificato SISPIE
          //if(utenteIride2VO.isRuoloSISPIE()
          //  && PORTAL_NAME.equalsIgnoreCase(AgriConstants.NOME_PORTALE_SISPIE))
          else
          {
          //Modifica gestione portale - 050607 - End
            if(cntRuoliAbilitatiSISPIE==0)
            {
              //Utile se esiste un solo ruolo associato
              codeFirstRole = ruolo.toString();
            }
            cntRuoliAbilitatiSISPIE++;

            //Modifica gestione portale - 050607 - Begin
            ruoliV.add(strCode);
            //Modifica gestione portale - 050607 - End
          }
        }

        strCode.setFirstCode(ruolo.toString());
        strCode.setFirstDescription(ruolo.getCodiceRuolo());
       //strCode.setSecondCode(ruolo.getCodiceDominio());

        //Modifica gestione portale - 050607 - Begin
        //ruoliV.add(i, strCode);
        //Modifica gestione portale - 050607 - End

      }
      session.setAttribute("ruoliH", ruoliH);
      messaggioErrore = AgriConstants.UTENTE_SENZA_RUOLI_PORTALE;*/

      if(Validator.isEmpty(arrRuoli) ||
        (Validator.isNotEmpty(arrRuoli) && arrRuoli.length==0))
      {
        messaggioErrore = AgriConstants.UTENTE_NON_ABILITATO_PROCEDIMENTO;
        SolmrLogger.debug(this," -- messaggioErrore ="+messaggioErrore);
        throw new SolmrException(messaggioErrore);
      }
      /*else
      {
        //Modifica gestione portale - 050607 - Begin
        if(arrRuoli.size()==1)
        {
          uniqueRole = true;
        }
      }*/

      if(arrRuoli.length> 1) 
	    {
    	  SolmrLogger.debug(this," -- arrRuoli.length> 1");
	      for(int i=0;i<arrRuoli.length;i++)
	      {
	        htmpl.newBlock("blkRuolo");
	        htmpl.set("blkRuolo.ruolo",arrRuoli[i].getCodice());
	        htmpl.set("blkRuolo.descRuolo",arrRuoli[i].getDescrizione());
	        if(request.getParameter("ruolo") != null && arrRuoli[i].getCodice().equals(request.getParameter("ruolo"))) {
	          htmpl.set("blkRuolo.checked","checked", null);
	        }
	      }
	    }

    /*if(ruoliV.size()==0)
    {
      htmpl.set("msgRuolo", "Non esistono ruoli associati all'utente nel procedimento!");
    }*/

    //DoubleStringcodeDescription strCode = null;

    if( arrRuoli.length==1
        ||
        (request.getParameter("conferma")!=null)
        ||
        (request.getParameter("funzione")!=null &&
         request.getParameter("funzione").equalsIgnoreCase("conferma"))
      )
    {

      //ParseXmlIride2 parseXmlIride2 = new ParseXmlIride2();

      if(arrRuoli.length==1 || request.getParameter("ruolo")!=null)
      {    	
        String ruoloString = request.getParameter("ruolo");
        
        if(arrRuoli.length == 1)
        {
          SolmrLogger.debug(this," -- arrRuoli.length==1"); 	
          ruoloString = arrRuoli[0].getCodice();
        }

        /*if(uniqueRole){
          ruoloString = codeFirstRole;
        }

        if(session.getAttribute("ruoliH")!=null){
          ruoliH = (HashMap) session.getAttribute("ruoliH");
        }


        Hashtable htIride2 = getDirittoAccesso(request, ruoliH, ruoloString);

        String codiceFiscale = id.getCodFiscale();
        String denominazione = id.getCognome() + " " + id.getNome();*/

        //Modifica codice ente utente autorgistrato/rappresentante legale - 051025 - Begin
        /*if(ruoloString!=null &&
          (ruoloString.equalsIgnoreCase((String)AgriConstants.get("TITOLARE_CF"))
           ||
           ruoloString.equalsIgnoreCase((String)AgriConstants.get("LEGALE_RAPPRESENTANTE")))
          )
        {
          String infoPersonaEnte = (String) htIride2.get((String)AgriConstants.get("INFO_PERSONA_ENTE"));
          htIride2.put((String)AgriConstants.get("INFO_PERSONA_ENTE"), codiceFiscale);
          infoPersonaEnte = (String) htIride2.get((String)AgriConstants.get("INFO_PERSONA_ENTE"));
        }*/
        //Modifica codice ente utente autorgistrato/rappresentante legale - 051025 - End

        //session.setAttribute("codiceFiscale", codiceFiscale);
        SolmrLogger.debug(this," -- codiceRuolo ="+ruoloString);
        session.setAttribute("codiceRuolo", ruoloString);
        //session.setAttribute("codiceEnte", codiceEnte);
        //session.setAttribute("idProcedimento", idProcedimento);
        //session.setAttribute("denominazione", denominazione);
        //session.setAttribute("ruoloSelezionato", ruoloString);
        //session.setAttribute("htIride2", htIride2);

		SolmrLogger.debug(this, "-- sendRedirect ="+APPLICATIVO_URL);
        response.sendRedirect(APPLICATIVO_URL);
        return;
      }
      else{}
    }
    else{}

    /*if((request.getParameter("funzione")!=null &&
        request.getParameter("funzione").equalsIgnoreCase("annulla")))
    {

      messaggioErrore = "";

	    String urlLoginWhithMessageError = URL_ACCESS_POINT;
	    if (URL_ACCESS_POINT.indexOf("?")<0)
	    {
	      urlLoginWhithMessageError+="?";
	    }
	    else
	    {
	      urlLoginWhithMessageError+="&";
	    }

      urlLoginWhithMessageError+="messaggioErrore=" + messaggioErrore;

      response.sendRedirect(urlLoginWhithMessageError);
    }*/

    

  }
  catch(SolmrException ex)
  {
    SolmrLogger.error(this,"[sceltaRuoloPEP::service] Rilevata eccezione Exception codice #14");
    SolmrLogger.dumpStackTrace(this,"[sceltaRuoloPEP::service] Dumping stack trace\n",ex);
    messaggioErrore = erroreGenerico;
  }
  catch(Exception ex)
  {
    SolmrLogger.error(this,"[sceltaRuoloPEP::service] Rilevata eccezione Exception codice #14");
    SolmrLogger.dumpStackTrace(this,"[sceltaRuoloPEP::service] Dumping stack trace\n",ex);
    messaggioErrore = erroreGenerico;

    //response.sendRedirect(urlLoginWhithMessageError);
  }
  
  
  if(Validator.isNotEmpty(messaggioErrore)) 
  {
    htmpl.newBlock("blkErrore");
    htmpl.set("blkErrore.messaggioErrore", messaggioErrore);
  }
  
  
  //050607 - Gestione messaggi errore - End
  SolmrLogger.debug(this,"[sceltaRuoloPEP:service] END.");
  
//  out.write(htmpl.text());
%>
<%!
  /*private Hashtable leggiXml(String src, String roleSelected)
  {
    java.util.Hashtable htRole = new Hashtable();
      ParseXmlIrideServices parseXmlIrideServices = new ParseXmlIrideServices();
      try {
        htRole = parseXmlIrideServices.creaDocumentDaStringXML(src, roleSelected);
      }
      catch (Exception ex)
      {
        SolmrLogger.error(this,"[sceltaRuoloPEP::service] Rilevata eccezione Exception codice #16");
        SolmrLogger.dumpStackTrace(this,"[sceltaRuoloPEP::service] Dumping stack trace\n",ex);
      }
    return htRole;
  }*/

  /*private String StampaDescRuoli(String codiceRuolo)
  {
    //Modifica visualizzazione ruoli su portale - 050607 - Begin
    String descRuolo = null;
    if(codiceRuolo.equalsIgnoreCase(AgriConstants.ODC))
    {
      descRuolo = AgriConstants.ODC_LABEL;
    }
    if(codiceRuolo.equalsIgnoreCase(AgriConstants.OPR))
    {
      descRuolo = AgriConstants.OPR_LABEL;
    }
    if(codiceRuolo.equalsIgnoreCase(AgriConstants.GDF))
    {
      descRuolo = AgriConstants.GDF_LABEL;
    }
    if(codiceRuolo.equalsIgnoreCase(AgriConstants.REGIONALE_PMN)
       ||codiceRuolo.equalsIgnoreCase(AgriConstants.REGIONALE))
    {
      descRuolo = AgriConstants.REGIONALE_LABEL;
    }
    if(codiceRuolo.equalsIgnoreCase(AgriConstants.REGIONALE_RAS))
    {
      descRuolo = AgriConstants.REGIONALE_RAS_LABEL;
    }
    if(codiceRuolo.equalsIgnoreCase(AgriConstants.ASSESORATO_PMN)
       ||codiceRuolo.equalsIgnoreCase(AgriConstants.ASSESORATO))
    {
      descRuolo = AgriConstants.ASSESORATO_LABEL;
    }
    if(codiceRuolo.equalsIgnoreCase(AgriConstants.PROVINCIALE))
    {
      descRuolo = AgriConstants.PROVINCIALE_LABEL;
    }
    if(codiceRuolo.equalsIgnoreCase(AgriConstants.COMUNITA_MONTANA))
    {
      descRuolo = AgriConstants.COMUNITA_MONTANA_LABEL;
    }
    if(codiceRuolo.equalsIgnoreCase(AgriConstants.INTERMEDIARIO))
    {
      descRuolo = AgriConstants.INTERMEDIARIO_LABEL;
    }
    if(codiceRuolo.equalsIgnoreCase(AgriConstants.ASSISTENZA_CSI))
    {
      descRuolo = AgriConstants.ASSISTENZA_CSI_LABEL;
    }
    if(codiceRuolo.equalsIgnoreCase(AgriConstants.TITOLARE_CF))
    {
      descRuolo = AgriConstants.PERSONA_FISICA_LABEL;
    }
    if(codiceRuolo.equalsIgnoreCase(AgriConstants.COMUNALE))
    {
      descRuolo = AgriConstants.COMUNE_FISICA_LABEL;
    }
    if(codiceRuolo.equalsIgnoreCase(AgriConstants.SAV))
    {
      descRuolo = AgriConstants.SAV_FISICA_LABEL;
    }
    if(codiceRuolo.equalsIgnoreCase(AgriConstants.AZIENDA_NO_CCIAA))
    {
      descRuolo = AgriConstants.AZIENDA_NO_CCIAA_LABEL;
    }
    if(codiceRuolo.equalsIgnoreCase(AgriConstants.LEGALE_RAPPRESENTANTE))
    {
      descRuolo = AgriConstants.LEGALE_RAPPRESENTANTE_FISICA_LABEL;
    }
    return descRuolo;
    //Modifica visualizzazione ruoli su portale - 050607 - Begin
  }*/


  /*private Hashtable getDirittoAccesso(HttpServletRequest request, HashMap ruoliH, String ruoloString)
      throws SolmrException, RemoteException, Exception
  {
    HttpSession session = (HttpSession) request.getSession(false);

    String appName = it.csi.solmr.etc.SolmrConstants.APP_NAME_IRIDE2_SMRUMA;
    Application myApp = (Application) session.getAttribute("myApp");

    String messaggioErrore = null;
    UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

    it.csi.iride2.policy.entity.Identita id = null;
    if(session.getAttribute("identita")!=null){
      id=(it.csi.iride2.policy.entity.Identita)session.getAttribute("identita");
    }

    //it.csi.iride2.iridefed.entity.Ruolo ruolo =
    it.csi.iride2.iridefed.entity.Ruolo ruolo =
       (it.csi.iride2.iridefed.entity.Ruolo) ruoliH.get(ruoloString);


    //Modifica gestione portale - 050607 - End
    String xmlSchemaUser = null;
    try {
      //Utenti registrati su Regione TOBECONFIG non possiedono info-persona associato
      //Utenti Legali rappresentanti non possiedono info-persona associato
      if(!ruolo.toString().equalsIgnoreCase(AgriConstants.TITOLARE_CF)
         &&
         !ruolo.toString().equalsIgnoreCase(AgriConstants.LEGALE_RAPPRESENTANTE)
         &&
         !ruolo.toString().equalsIgnoreCase(AgriConstants.MONITORAGGIO)){

//        it.csi.iride2.policy.entity.UseCase[] useCaseV = umaFacadeClient.findUseCasesForPersonaInApplication(id, myApp);

        UseCase useCase = null;
//        for(int i=0; i<useCaseV.length; i++){
//          useCase = useCaseV[i];
//        }

          //050614 Modifica recupero info-persona - Begin
          String cu = "ACCESSO_SISTEMA";
          useCase = new it.csi.iride2.policy.entity.UseCase(myApp, cu);
          //050614 Modifica recupero info-persona - End

          xmlSchemaUser = umaFacadeClient.getInfoPersonaInUseCase(id, useCase);
      }
      else{

        if(ruolo.toString().equalsIgnoreCase((String)AgriConstants.get("TITOLARE_CF"))){
          xmlSchemaUser = AgriConstants.INFO_PERSONA_TITOLARE_CF;
        }
        if(ruolo.toString().equalsIgnoreCase((String)AgriConstants.get("LEGALE_RAPPRESENTANTE"))){
          xmlSchemaUser = AgriConstants.INFO_PERSONA_LEGALE_RAPPRESENTANTE;
        }
        if(ruolo.toString().equalsIgnoreCase((String)AgriConstants.get("MONITORAGGIO"))){
          xmlSchemaUser = AgriConstants.INFO_PERSONA_MONITORAGGIO;
        }
      }
    }
    catch (IdentitaNonAutenticaException ex)
    {
      SolmrLogger.error(this,"[sceltaRuoloPEP::service] Rilevata eccezione IdentitaNonAutenticaException codice #7");
      SolmrLogger.dumpStackTrace(this,"[sceltaRuoloPEP::service] Dumping stack trace\n",ex);
      messaggioErrore = AgriConstants.UTENTE_NON_ABILITATO_IDENTITA_PROVIDER;
      throw new SolmrException(messaggioErrore);
    }
    catch (InternalException ex)
    {
      SolmrLogger.error(this,"[sceltaRuoloPEP::service] Rilevata eccezione InternalException codice #8");
      SolmrLogger.dumpStackTrace(this,"[sceltaRuoloPEP::service] Dumping stack trace\n",ex);
      messaggioErrore = AgriConstants.PROBLEMI_ACCESSO_IRIDE2;
      throw new SolmrException(messaggioErrore);
    }
    catch (NoSuchUseCaseException ex)
    {
      SolmrLogger.error(this,"[sceltaRuoloPEP::service] Rilevata eccezione NoSuchUseCaseException codice #9");
      SolmrLogger.dumpStackTrace(this,"[sceltaRuoloPEP::service] Dumping stack trace\n",ex);
      messaggioErrore = AgriConstants.UTENTE_NON_ABILITATO_CASO_D_USO_NON_ESISTENTE;
      throw new SolmrException(messaggioErrore);
    }
    catch (NoSuchApplicationException ex)
    {
      SolmrLogger.error(this,"[sceltaRuoloPEP::service] Rilevata eccezione NoSuchApplicationException codice #10");
      SolmrLogger.dumpStackTrace(this,"[sceltaRuoloPEP::service] Dumping stack trace\n",ex);
      messaggioErrore = AgriConstants.UTENTE_NON_ABILITATO_APPLICAZIONE_NON_ESISTENTE;
      throw new SolmrException(messaggioErrore);
    }
    catch(RuntimeException ruExc)
    {
      SolmrLogger.error(this,"[sceltaRuoloPEP::service] Rilevata eccezione RuntimeException codice #11");
      SolmrLogger.dumpStackTrace(this,"[sceltaRuoloPEP::service] Dumping stack trace\n",ruExc);
      messaggioErrore = AgriConstants.PROBLEMI_ACCESSO_IRIDE2;
      throw new SolmrException(messaggioErrore);
    }

    Hashtable htIride2 = leggiXml(xmlSchemaUser, ruoloString);
    SolmrLogger.debug(this, "htIride2: "+htIride2);
    //String dirittoAccesso = (String) htIride2.get(appName);

    return htIride2;
  }*/

%>
<%= htmpl.text()%>
