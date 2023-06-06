<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.dto.anag.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.etc.uma.UmaErrors"%>
<%!
  private static final String confermaInserimentoAttestazioniUrl = "/macchina/layout/confermaInserimentoComproprietari.htm";
%>
<%

  String iridePageName = "attestazioniNewCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  UmaFacadeClient client = new UmaFacadeClient();
  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  String url = "/macchina/view/attestazioniNewView.jsp";
  ValidationError error = null;
  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  Long idAttestazione = null;
  Vector v_locatari = null;
  Vector v_societa = null;
  Vector v_soggetti = null;
  MacchinaVO macchinaVO = null;
  Long idMacchina = null;
  if(session.getAttribute("common") instanceof MacchinaVO){
    SolmrLogger.debug(this,"Instance of MacchinaVO");
    macchinaVO = (MacchinaVO)session.getAttribute("common");
    idMacchina = macchinaVO.getIdMacchinaLong();
    if (macchinaVO!=null && client.isBloccoMacchinaImportataAnagrafe(macchinaVO)) 
	  {  
	    it.csi.solmr.util.SolmrLogger.debug(this,"[autorizzazione.inc::service:::errorMessage!=null] utente non abilitato: "+it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
	    request.setAttribute("errorMessage",it.csi.solmr.etc.uma.UmaErrors.ERRORE_FLAG_IMPORTABILE);
	    %><jsp:forward page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" /><%
	    return;
	  }
  }
  SolmrLogger.debug(this,"Valore di Id Macchina "+idMacchina);
  // Annulla
  if(request.getParameter("annulla")!=null){
    url = "/macchina/layout/dettaglioMacchinaDittaComproprietari.htm";
  }
  // Salva
  else if (request.getParameter("salva")!=null){
    AttestatoProprietaVO apVO = null;
    // Recupero i vettori di ditta locataria e società collegate
    v_locatari = (Vector)session.getAttribute("v_locatari");
    v_societa = (Vector)session.getAttribute("v_societa");
    v_soggetti = (Vector)session.getAttribute("v_soggetti");
    // Recupero l'elenco dei soggetti selezionati
    HashMap hmDitta = new HashMap();
    int counter = 0;
    String dittaUmaRef = null;
    Vector vIdSoggetto = new Vector();
    while (request.getParameter("dittaUMARef_"+counter)!=null) {
      String currentDitta = request.getParameter("dittaUMARef_"+counter);
      Vector soggetti = null;
      soggetti = (Vector)hmDitta.get(currentDitta);
      if (soggetti==null)
	soggetti = new Vector();
      String daCheck = request.getParameter("checkSoggetto_"+counter);
      SolmrLogger.debug(this,"Valore di daCheck "+request.getParameter("checkSoggetto_"+counter));
      SolmrLogger.debug(this,"Current Ditta???? "+currentDitta);
      if (daCheck!=null&&daCheck.endsWith(currentDitta)) {
        SolmrLogger.debug(this,"Entrüma");
        SolmrLogger.debug(this,"daCheck.indexOf(currentDitta) "+daCheck.indexOf(currentDitta));
	SolmrLogger.debug(this,"Id Persona Fisica calcolato: "+daCheck.substring(0,daCheck.indexOf(currentDitta)-1));
	Long currIdPersFis = Long.valueOf(daCheck.substring(0,daCheck.indexOf(currentDitta)-1));
	//soggetti.add(daCheck.substring(0,daCheck.indexOf(currentDitta)));
	Iterator iterSoggetti = v_soggetti.iterator();
	boolean flagFound = false;
	while (iterSoggetti.hasNext()&&!flagFound) {
	  IntestatariVO currPfVO = (IntestatariVO)iterSoggetti.next();
	  if (currPfVO.getSoggetti().getIdPersonaFisica().equals(currIdPersFis)) {
	    soggetti.add(currIdPersFis);
	    vIdSoggetto.add(currPfVO);
	    flagFound = true;
	  }
	}
      }
      else
        SolmrLogger.debug(this,"Entrüma nen");

      hmDitta.put(currentDitta, soggetti);
      counter++;
    }
    boolean flag = true;
    Set daEnum = hmDitta.keySet();
    Iterator i_enum = daEnum.iterator();
    while (i_enum.hasNext()&&flag) {
      Vector currentVector = (Vector)hmDitta.get(i_enum.next());
      if (currentVector.size()==0)
        flag = false;
    }
    if(!flag){
      SolmrLogger.debug(this,"ERRRRRORE ");
      error = new ValidationError("Inserire almeno un soggetto per ciascuna ditta UMA presente sull''"+
                                  "elenco dei soggetti collegati a ditte individuali utilizzatrici");
      errors = new ValidationErrors();
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher("../../macchina/view/attestazioniNewView.jsp").forward(request, response);
      return;
    }
    // Creo un vettore di ProprietarioVO (uno per ogni ditta, societa e soggetto)
    Vector v_proprietari = new Vector();
    //Vector v_modificati = new Vector();
    Iterator i = v_locatari.iterator();
    SolmrLogger.debug(this,"Valore di v_locatari "+v_locatari.size());
    while(i.hasNext()){
      IntestatariVO intVO = (IntestatariVO)i.next();
      ProprietarioVO propVO = new ProprietarioVO();
      propVO.setTipoProprietario("L");
      propVO.setExtIdAnagraficaLong(intVO.getLocatariaOSocieta().getIdAnagAzienda());
      propVO.setIdProvincia(null);
      propVO.setDittaUma(null);
      /*if(intVO.getFlagAnagAzienda()!=null)
        v_modificati.add(intVO);*/
      v_proprietari.add(propVO);
    }
    i = v_societa.iterator();
    SolmrLogger.debug(this,"Valore di v_societa "+v_societa.size());
    while(i.hasNext()){
      IntestatariVO intVO = (IntestatariVO)i.next();
      ProprietarioVO propVO = new ProprietarioVO();
      propVO.setTipoProprietario("A");
      propVO.setExtIdAnagraficaLong(intVO.getLocatariaOSocieta().getIdAnagAzienda());
      propVO.setIdProvincia(intVO.getIstatProvUMA());
      propVO.setDittaUma(intVO.getDittaUMA());
      /*if(intVO.getFlagAnagAzienda()!=null)
        v_modificati.add(intVO);*/
      v_proprietari.add(propVO);
    }
    SolmrLogger.debug(this,"Valore di vIdSoggetto "+vIdSoggetto.size());
    i = vIdSoggetto.iterator();
    SolmrLogger.debug(this,"Valore di vIdSoggetto "+vIdSoggetto.size());
    while(i.hasNext()){
      SolmrLogger.debug(this,"Entro in IterSoggetti");
      IntestatariVO intVO = (IntestatariVO)i.next();
      ProprietarioVO propVO = new ProprietarioVO();
      propVO.setTipoProprietario("P");
      propVO.setExtIdAnagraficaLong(intVO.getSoggetti().getIdPersonaFisica());
      propVO.setIdProvincia(intVO.getIstatProvUMA());
      propVO.setDittaUma(intVO.getDittaUMA());
      /*if(intVO.getFlagAnagAzienda()!=null||intVO.getFlagPersonaFisica()!=null)
        v_modificati.add(intVO);*/
      v_proprietari.add(propVO);
    }
    SolmrLogger.debug(this,"Valore di v_proprietari "+v_proprietari.size());
    SolmrLogger.debug(this,"Valore di idMaghena "+idMacchina);
    //SolmrLogger.debug(this,"Valore di v_modificati "+v_modificati.size());
    /* Se v_modificati.size == 0 vuol dire che i flag MODIFICATO_INTERMEDIARIO
       su DB_ANAGRAFICA_AZIENDA e DB_PERSONA_FISICA di tutte le "ditte" collegate
       alla macchina sono = null, quindi procedo con la creazione di una nuova
       attestazione. In caso contrario rimando l'utente ad una pagina in cui viene
       avvisato delle modifiche
    */
    /*if(v_modificati.size()==0){
      SolmrLogger.debug(this,"Entro direttamente in inserisci nuova attestazione");*/

    SolmrLogger.debug(this,"idMacchina: "+idMacchina);
    //Controllo univocità Attestato proprietà - Begin
    AttestatoProprietaVO attestatoProprietaVOIntrodotto =
        new AttestatoProprietaVO();
    attestatoProprietaVOIntrodotto.setIdMacchina(""+idMacchina);
    attestatoProprietaVOIntrodotto.setIdProvincia(ruoloUtenza.getIstatProvincia());
    attestatoProprietaVOIntrodotto.setProprietari(v_proprietari);

    HashMap common2 = new HashMap();
    common2.put("v_proprietari",v_proprietari);
    common2.put("idMacchina",idMacchina);

    SolmrLogger.debug(this,"common2.get(\"idMacchina\"): "+(Long)common2.get("idMacchina"));

    SolmrLogger.debug(this,"Before findAttestatiProprietaByIdMacchina");
    if (client.findAttestatiProprietaByIdMacchina(attestatoProprietaVOIntrodotto).booleanValue()==true){
      //Attestato di proprietà già esistente su database
      SolmrLogger.debug(this,"Attestato di proprietà già esistente su database");
    }else{
      //Attestato di proprietà non ancora esistente su database
      SolmrLogger.debug(this,"Attestato di proprietà non ancora esistente su database");
      common2.put("operazione","inserisci");
    }

    session.setAttribute("common2", common2);
    SolmrLogger.debug(this,"confermaInserimentoAttestazioniUrl: "+confermaInserimentoAttestazioniUrl);
    %>
      <jsp:forward page="<%=confermaInserimentoAttestazioniUrl%>"/>
    <%
    return;


    /*try {
      apVO = client.insertAttestazione(idMacchina, v_proprietari, profile);
      request.setAttribute("attestatoNewVO", apVO);
      url = "/macchina/layout/NuovaAttestazioneConferma.htm";
    }
    catch (SolmrException ex) {
      SolmrLogger.debug(this,"ECCEZZZZIONE... "+ex+" - "+ex.getMessage());
      error = new ValidationError(ex.getMessage());
      errors = new ValidationErrors();
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher("../../macchina/view/attestazioniNewView.jsp").forward(request, response);
      return;
    }*/
    //Controllo univocità Attestato proprietà - End
    /*}
    else{
      SolmrLogger.debug(this,"Passa da NuovaAttestazioneModificaConferma.htm");
      url = "/macchina/layout/NuovaAttestazioneModificaConferma.htm";
      session.setAttribute("v_proprietari", v_proprietari);
      request.setAttribute("v_modificati", v_modificati);
    }*/
  }
  // Entro per la prima volta
  else{
    // L'utente deve essere PA la cui provincia di competenza coincide con la
    // provincia di competenza della ditta UMA
/*     if(!ruoloUtenza.isUtenteProvinciale()){
      SolmrLogger.debug(this,"ERRRRRORE PA");
      error = new ValidationError("Utente non abilitato ad effettuare questa operazione!");
      errors = new ValidationErrors();
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher("../../macchina/view/attestazioniDittaView.jsp").forward(request, response);
      return;
    }
    if(ruoloUtenza.getIstatProvincia()!=null&&!ruoloUtenza.getIstatProvincia().equals(dittaVO.getProvUMA())){
      SolmrLogger.debug(this,"ERRRRRORE PA/PROVINCIA UMA");
      error = new ValidationError(UmaErrors.PROVINCIA_FUNZIONARIO_PA_NON_VALIDA);
      errors = new ValidationErrors();
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher("../../macchina/view/attestazioniDittaView.jsp").forward(request, response);
      return;
    } */
    // Controlli su dittaUMA e macchina
    try {
      client.isDittaUmaBloccata(dittaVO.getIdDittaUMA());
    }
    catch (SolmrException ex) {
      SolmrLogger.debug(this,"ERRRRRORE "+ex);
      error = new ValidationError(ex.getMessage());
      errors = new ValidationErrors();
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher("../../macchina/view/attestazioniDittaView.jsp").forward(request, response);
      return;
    }
    try {
      client.isDittaUmaCessata(dittaVO.getIdDittaUMA());
    }
    catch (SolmrException ex) {
      SolmrLogger.debug(this,"ERRRRRORE "+ex);
      error = new ValidationError(ex.getMessage());
      errors = new ValidationErrors();
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher("../../macchina/view/attestazioniDittaView.jsp").forward(request, response);
      return;
    }
    try {
      client.isMacchinaInCarico(idMacchina, dittaVO.getIdDittaUMA());
    }
    catch (SolmrException ex) {
      SolmrLogger.debug(this,"ERRRRRORE "+ex);
      error = new ValidationError(ex.getMessage());
      errors = new ValidationErrors();
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher("../../macchina/view/attestazioniDittaView.jsp").forward(request, response);
      return;
    }
    try {
      v_locatari = client.getDittaLocataria(idMacchina);
      v_societa = client.getSocietaUtilizzatrici(idMacchina);
      v_soggetti = client.getSoggettiIntestatari(idMacchina);
      Vector v_modificati = new Vector();
      session.setAttribute("v_locatari", v_locatari);
      session.setAttribute("v_societa", v_societa);
      session.setAttribute("v_soggetti", v_soggetti);
      if(v_locatari!=null&&v_locatari.size()==0&&
         v_societa!=null&&v_societa.size()==0&&
         v_soggetti!=null&&v_soggetti.size()==0){
        SolmrLogger.debug(this,"ERRRRRORE V_VUOTI");
        error = new ValidationError(""+UmaErrors.get("ERR_NO_PROPRIETARI_PER_ATTESTAZIONE"));
        errors = new ValidationErrors();
        errors.add("error", error);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher("../../macchina/view/attestazioniDittaView.jsp").forward(request, response);
        return;
      }
      if(v_locatari!=null&& v_locatari.size()!=0){
        Iterator i_locatari = v_locatari.iterator();
        while(i_locatari.hasNext()){
          IntestatariVO intVO = (IntestatariVO)i_locatari.next();
          if(intVO.getFlagAnagAzienda()!=null)
            v_modificati.add(intVO);
        }
      }
      if(v_societa!=null&&v_societa.size()!=0){
        Iterator i_societa = v_societa.iterator();
        while(i_societa.hasNext()){
          IntestatariVO intVO = (IntestatariVO)i_societa.next();
          if(intVO.getFlagAnagAzienda()!=null)
            v_modificati.add(intVO);
        }
      }
      if(v_soggetti!=null&&v_soggetti.size()!=0){
        Iterator i_soggetti = v_soggetti.iterator();
        while(i_soggetti.hasNext()){
          IntestatariVO intVO = (IntestatariVO)i_soggetti.next();
          if(intVO.getFlagAnagAzienda()!=null||intVO.getFlagPersonaFisica()!=null)
            v_modificati.add(intVO);
        }
      }
      if(v_modificati.size()!=0){
        // MSG
        request.setAttribute("v_modificati", v_modificati);
        url = "/macchina/layout/NuovaAttestazioneModificaConferma.htm";
      }
    }
    catch (SolmrException ex) {
      SolmrLogger.debug(this,"ERRRRRORE "+ex);
      error = new ValidationError(ex.getMessage());
      errors = new ValidationErrors();
      errors.add("error", error);
      request.setAttribute("errors", errors);
      request.getRequestDispatcher("../../macchina/view/attestazioniDittaView.jsp").forward(request, response);
      return;
    }
  }
  SolmrLogger.debug(this,"- attestazioniNewCtrl.jsp - Fine Pagina");
%>
<jsp:forward page="<%=url%>"/>