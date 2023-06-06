<%@ page language="java" contentType="text/html" isErrorPage="true"%>

<%@ page import="java.util.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.dto.anag.AnagAziendaVO"%>
<%@ page import="java.math.BigDecimal"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%
	String iridePageName = "modificaLavContoTerziCtrl.jsp";
%>
<%@include file="/include/autorizzazione.inc"%>
<%
	SolmrLogger.debug(this, "   BEGIN modificaLavContoTerziCtrl");

  String viewUrl = "/ditta/view/modificaLavContoTerziView.jsp";
  String elencoHtm = "../../ditta/layout/elencoLavContoTerzi.htm";
  String elencoBisHtm = "../../ditta/layout/elencoLavContoTerziBis.htm";
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session
      .getAttribute("dittaUMAAziendaVO");
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  AnnoCampagnaVO annoCampagnaVO = (AnnoCampagnaVO) session
      .getAttribute("annoCampagna");
  HashMap hashCommon = (HashMap) session.getAttribute("hashCommon");
  if (hashCommon == null)
    hashCommon = new HashMap();
    

  String umar = umaFacadeClient.getParametro(SolmrConstants.PARAMETRO_UMAR);  
  
  request.setAttribute("PARAMETRO_UMAR", umar);  
    
  if (request.getParameter("salva.x") != null)
  {
    SolmrLogger.debug(this, "modificaLavContoTerziCtrl - salvataggio");
    Vector vLavContoTerziUpdate = new Vector();
    ValidationErrors errors = validateUpdate(request, (Vector) hashCommon
        .get("vLavContoTerzi"), vLavContoTerziUpdate, umaFacadeClient);
    SolmrLogger.debug(this,"errors.size()=" + errors.size());
    if (errors.size() != 0)
    {
      request.setAttribute("errors", errors);
    }
    else
    {
      try
      {
        //update
        umaFacadeClient.aggiornaLavorazioneContoTerzi(vLavContoTerziUpdate,
            ruoloUtenza);
      }
      catch (SolmrException sexc)
      {
        SolmrLogger.debug(this, "catch SolmrEception sexc");
        if (sexc.getValidationErrors() != null)
        {
          SolmrLogger.debug(this,
              "        if (sexc.getValidationErrors()!=null)");
          ValidationErrors vErrors = sexc.getValidationErrors();
          if (vErrors.size() != 0)
          {
            SolmrLogger.debug(this, "          if (vErrors.size()!=0)");
            request.setAttribute("errors", vErrors);
%>
<jsp:forward page="<%=viewUrl%>" />
<%
	return;
          }
        }
        else
        {
          SolmrLogger.debug(this, "          else (vErrors.size()!=0)");
          ValidationException valEx = new ValidationException(
              "Eccezione di validazione" + sexc.getMessage(), viewUrl);
          valEx.addMessage(sexc.toString(), "exception");
          throw valEx;
        }
        SolmrLogger.debug(this, "        dopo if (sexc.getValidationErrors()!=null)");
      }
      catch (Exception e)
      {
        ValidationException valEx = new ValidationException(
            "Eccezione di validazione" + e.getMessage(), viewUrl);
        valEx.addMessage(e.getMessage(), "exception");
        throw valEx;
      }
      String forwardUrl = elencoHtm;
      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
      {
        forwardUrl = elencoBisHtm;
      }

      // viene utilizzato per mantenere i filtri settati in fase di ricerca nella pagina di Elenco lavorazioni
	  session.setAttribute("paginaChiamante", "modifica");

      session.setAttribute("notifica", "Modifica eseguita con successo");
      response.sendRedirect(forwardUrl);
      return;
    }
  }
  else
  {
    if (request.getParameter("annulla.x") != null)
    {
      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))
      {
        response.sendRedirect(elencoBisHtm);
      }
      else
      {
        response.sendRedirect(elencoHtm);
      }
      // viene utilizzato per mantenere i filtri settati in fase di ricerca nella pagina di Elenco lavorazioni
	  session.setAttribute("paginaChiamante", "modifica");
      return;
    }
    else
    {
      //carico i dati la prima volta che entro nella pagina
      Vector vLavContoTerzi = (Vector) session.getAttribute("vLavContoTerzi");

      HashMap hashMapMacchine = new HashMap();
      HashMap<Long,ZonaAltimetricaVO> hashZonaAlt = new HashMap<Long,ZonaAltimetricaVO>();
      //      Vector  vIdUtente = new Vector();
      Vector vExtIdAzienda = new Vector();
      AnagAziendaVO[] listaAnagAziendaVO = null;
      for (int i = 0; i < vLavContoTerzi.size(); i++)
      {
        LavContoTerziVO lavContoTerzi = (LavContoTerziVO) vLavContoTerzi
            .get(i);
        SolmrLogger.debug(this, "idUtenteAggiornamento: "
            + lavContoTerzi.getExtIdUtenteAggiornamento());
        SolmrLogger.debug(this, "lavContoTerzi.getIdLavorazioneCT(): "
            + lavContoTerzi.getIdLavorazioneCT());
        //      	if(lavContoTerzi.getExtIdUtenteAggiornamento() != null && vIdUtente.contains(lavContoTerzi.getExtIdUtenteAggiornamento()) == false )
        //      	vIdUtente.add(lavContoTerzi.getExtIdUtenteAggiornamento());
        if (lavContoTerzi.getExtIdAzienda() != null
            && vExtIdAzienda.contains(lavContoTerzi.getExtIdAzienda()) == false)
          vExtIdAzienda.add(lavContoTerzi.getExtIdAzienda());
        Vector elencoMacchineUtilizzate = umaFacadeClient
            .findMacchineUtilizzate(lavContoTerzi.getIdLavorazoni(),
                lavContoTerzi.getIdCategoriaUtilizziUma(), new Long(
                    annoCampagnaVO.getAnnoCampagna()), dittaUMAAziendaVO
                    .getIdDittaUMA(), false);
        hashMapMacchine.put(lavContoTerzi.getIdLavorazioneCT(),
            elencoMacchineUtilizzate);
      }
      //      RuoloUtenza[] ruoloUtenza = umaFacadeClient.serviceGetRuoloUtenzaByIdRange((Long[])vIdUtente.toArray(new Long[vIdUtente.size()]),false);
      if (vExtIdAzienda.size() > 0)
      {
        listaAnagAziendaVO = umaFacadeClient.serviceGetListAziendeByIdRange(vExtIdAzienda);
        SolmrLogger.debug(this, "-- Ricerco la zona altimetrica");
        Long idDittaUma = null; // --> non so quanto vale
        hashZonaAlt = umaFacadeClient.getZonaAltByExtIdAziendaRange((Long[]) vExtIdAzienda.toArray(new Long[vExtIdAzienda.size()]),idDittaUma);
      }

      String anno = annoCampagnaVO.getAnnoCampagna();
      String data = null;
      String coefficiente = umaFacadeClient.getValoreParametro(SolmrConstants.PARAMETRO_COEFFICIENTE_CAVALLI_CARBURANTE,anno,data);

      hashCommon.put("vLavContoTerzi", vLavContoTerzi);
      //      hashCommon.put("ruoloUtenzaAgg",ruoloUtenza);
      hashCommon.put("listaAnagAziendaVO", listaAnagAziendaVO);
      hashCommon.put("hashMapMacchine", hashMapMacchine);
      hashCommon.put("hashZonaAlt", hashZonaAlt);
      hashCommon.put("coefficiente", coefficiente);

      session.setAttribute("hashCommon", hashCommon);

      request.setAttribute("vLavContoTerzi", hashCommon
          .get("vLavContoTerzi"));

    }
  }

  //  request.setAttribute("ruoloUtenzaAgg",hashCommon.get("ruoloUtenzaAgg"));
  request.setAttribute("listaAnagAziendaVO", hashCommon
      .get("listaAnagAziendaVO"));
  request
      .setAttribute("hashMapMacchine", hashCommon.get("hashMapMacchine"));
  request.setAttribute("hashZonaAlt", hashCommon.get("hashZonaAlt"));
  request.setAttribute("coefficiente", hashCommon.get("coefficiente"));

  SolmrLogger.debug(this, "modificaSerraCtrl - End");
%>

<jsp:forward page="<%=viewUrl%>" />
<%!private ValidationErrors validateUpdate(HttpServletRequest request, Vector vLavContoTerzi, Vector vLavContoTerziUpdate, UmaFacadeClient umaFacadeClient) throws Exception {

		SolmrLogger.debug(this, "   BEGIN validateUpdate");

		ValidationErrors errors = new ValidationErrors();
		String totGasolioDich = request.getParameter("totGasolioStr");
		String umps = umaFacadeClient.getParametro(SolmrConstants.PARAMETRO_COEFFICIENTE_SUPERFICIE_LAV_CONTO_TERZI);
		Long umpsLong = NumberUtils.parseLong(umps);
		if (umpsLong == null) {
			throw new SolmrException("Attenzione! si è verificato un errore grave. Se il problema persiste contattare l'assistenza tecnica comunicando il seguente messaggio: PARAMETRO "
					+ SolmrConstants.PARAMETRO_COEFFICIENTE_SUPERFICIE_LAV_CONTO_TERZI + " non valido o assente");
		}
		BigDecimal zero = new BigDecimal(0);
		if (!Validator.isEmpty(totGasolioDich)) {
			try {
				BigDecimal totGasolio = new BigDecimal(totGasolioDich.replace(',', '.'));
				if (totGasolio.compareTo(zero) == -1)
					errors.add("totGasolioStr", new ValidationError("Non è possibile inserire un valore negativo"));
			} catch (Exception ex) {
				errors.add("totGasolioStr", new ValidationError("Campo non numerico"));
			}
		}

		for (int i = 0; i < vLavContoTerzi.size(); i++) {
			LavContoTerziVO lavContoTerziVO = (LavContoTerziVO) vLavContoTerzi.get(i);
			LavContoTerziVO lavContoTerziUpdate = loadVO(lavContoTerziVO);
			String idLavContoTerzi = lavContoTerziVO.getIdLavorazioneCT().toString();
			String esecuzioniStr = request.getParameter("esecuzioniStr" + idLavContoTerzi);
			String macchinaUtilizzata = request.getParameter("idMacchina" + idLavContoTerzi);
			String supOreStr = request.getParameter("supOreStr" + idLavContoTerzi);
			String supOreFatturaStr = request.getParameter("supOreFatturaStr" + idLavContoTerzi);
			String gasolioStr = request.getParameter("gasolioStr" + idLavContoTerzi);
			String consumiCalcolatiStr = request.getParameter("consumiCalcolatiStr" + idLavContoTerzi);
			String consumoDichiaratoStr = request.getParameter("consumoDichiaratoStr" + idLavContoTerzi);
			String eccedenzaStr = request.getParameter("eccedenzaStr" + idLavContoTerzi);
			String litriBasePerEsecuzioni = request.getParameter("litriBasePerEsecuzioni" + idLavContoTerzi);

			String numeroFattura = request.getParameter("numeroFattura" + idLavContoTerzi);
			String note = request.getParameter("note" + idLavContoTerzi);

			String maxCarburante = request.getParameter("maxCarburante" + idLavContoTerzi);
			SolmrLogger.debug(this, " --- maxCarburante =" + maxCarburante);
			String maxLitriAcclivitaStr = request.getParameter("maxLitriAcclivita" + idLavContoTerzi);
			SolmrLogger.debug(this, " --- maxLitriAcclivitaStr =" + maxLitriAcclivitaStr);

			String litriAcclivitaStr = request.getParameter("litriAcclivita" + idLavContoTerzi);
			String litriTerDeclivi = request.getParameter("litriTerDeclivi" + idLavContoTerzi);

			boolean scavalco = request.getParameter("scavalco" + idLavContoTerzi) != null;

			SolmrLogger.debug(this, " --- scavalco =" + scavalco);

			lavContoTerziUpdate.setEsecuzioniStr(esecuzioniStr);

			lavContoTerziUpdate.setSupOreStr(supOreStr);
			lavContoTerziUpdate.setSupOreCalcolataStr(supOreStr);
			lavContoTerziUpdate.setSupOreFatturaStr(supOreFatturaStr);
			lavContoTerziUpdate.setGasolioStr(gasolioStr);
			lavContoTerziUpdate.setConsumoCalcolatoStr(consumiCalcolatiStr);
			lavContoTerziUpdate.setConsumoDichiaratoStr(consumoDichiaratoStr);
			lavContoTerziUpdate.setEccedenzaStr(eccedenzaStr);
			lavContoTerziUpdate.setNumeroFatture(numeroFattura);
			lavContoTerziUpdate.setNote(note);
			lavContoTerziUpdate.setTotaleGasolioModStr(totGasolioDich);
			lavContoTerziUpdate.setMaxCarburante(maxCarburante);
			lavContoTerziUpdate.setMaxLitriAcclivita(maxLitriAcclivitaStr);
			lavContoTerziUpdate.setLitriAcclivitaStr(litriAcclivitaStr);
			lavContoTerziUpdate.setScavalco(scavalco);

			int index = lavContoTerziVO.getIdLavorazioneCT().intValue();

			if (note.length() > 1000) {
				errors.add("noteStr" + index, new ValidationError("Inserire al max 1000 caratteri"));
			}

			if (Validator.isEmpty(numeroFattura)) {
				errors.add("numeroFatturaStr" + index, new ValidationError("Campo obbligatorio"));
			} else if (numeroFattura.length() > 200) {
				errors.add("numeroFatturaStr" + index, new ValidationError("Inserire al max 200 caratteri"));
			}

			long esecuzioniInput = 1;
			long numeroEsecuzioni = 1;
			if (lavContoTerziVO.getMaxEsecuzioni() != null) {
				if (Validator.isEmpty(esecuzioniStr)) {
					errors.add("esecuzioniStr" + index, new ValidationError("Campo obbligatorio"));
				} else {
					numeroEsecuzioni = lavContoTerziVO.getMaxEsecuzioni().longValue();
					try {
						esecuzioniInput = Long.parseLong(esecuzioniStr);
					} catch (Exception ex) {
						errors.add("esecuzioniStr" + index, new ValidationError("Valore numerico"));
					}

					if (esecuzioniInput < 0)
						errors.add("esecuzioniStr" + index, new ValidationError("Non è possibile inserire un valore negativo"));

					//@@todo - Da verificare caricamento property flagEscludiEsecuzioni
					//Se FLAG_ESCLUDI_ESECUZIONI = 'N', non controllo il max esecuzioni
					if (lavContoTerziVO.getFlagEscludiEsecuzioni().equalsIgnoreCase("N")) {
						if (esecuzioniInput > numeroEsecuzioni) {
							errors.add("esecuzioniStr" + index, new ValidationError("Non è possibile aumentare il valore del numero esecuzioni"));
						}
					}
				}
			}

			// NOTE : PER LA TOBECONFIG ABBIAMO TOLTO LA VISUALIZZAZIONE DELLA COMBO MACCHINE, QUINDI COMMENTIAMO LA VALIDAZIONE SU QUESTO CAMPO
			/*if (lavContoTerziVO.getTipoUnitaMisura() != null && lavContoTerziVO.getTipoUnitaMisura().equalsIgnoreCase("T")) {
				lavContoTerziUpdate.setIdMacchinaStr(macchinaUtilizzata);

				if (Validator.isEmpty(macchinaUtilizzata)) {
					errors.add("idMacchina" + index, new ValidationError("Campo obbligatorio"));
				} else {
					StringTokenizer token = new StringTokenizer(macchinaUtilizzata, "|");
					lavContoTerziUpdate.setIdMacchinaStr(token.nextToken());
				}

			}*/

			//il campo è modificabile al ribasso solo se extIdAzienda != null
			if (errors.get("esecuzioniStr") == null) {
				if (lavContoTerziVO.getExtIdAzienda() != null) {
					if (Validator.isEmpty(supOreStr)) {
						errors.add("supOreStr" + index, new ValidationError("Campo obbligatorio"));
					} else {

						try {
							BigDecimal supOre = new BigDecimal(supOreStr.replace(',', '.'));
							BigDecimal supMax = lavContoTerziVO.getSupOreCalcolata();
							//System.err.println("lavContoTerziVO.getSupOreCalcolata(): "+lavContoTerziVO.getSupOreCalcolata());
							//System.err.println("lavContoTerziVO.getTipoUnitaMisura(): "+lavContoTerziVO.getTipoUnitaMisura());
							if (SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(lavContoTerziVO.getTipoUnitaMisura())
									|| SolmrConstants.TIPO_UNITA_MISURA_M.equalsIgnoreCase(lavContoTerziVO.getTipoUnitaMisura())) {
								if (supMax != null) {
									BigDecimal delta = supMax.multiply(new BigDecimal(umpsLong.longValue())).setScale(4).divide(new BigDecimal(100), BigDecimal.ROUND_HALF_UP);
									supMax = supMax.add(delta);

									SolmrLogger.debug(this, " --- lavContoTerziVO.getMaxEsecuzioni() =" + lavContoTerziVO.getMaxEsecuzioni());
									BigDecimal maxEsecuzioniBD = (lavContoTerziVO.getMaxEsecuzioni() != null) ? new BigDecimal(lavContoTerziVO.getMaxEsecuzioni().longValue()) : new BigDecimal("1");
									System.err.println("maxEsecuzioniBD : " + maxEsecuzioniBD);
									supMax = supMax.multiply(maxEsecuzioniBD).setScale(4, BigDecimal.ROUND_HALF_UP);

								}
							}

							BigDecimal supOreEsecuzioni = new BigDecimal(supOre.doubleValue());
							//System.err.println("supOreEsecuzioni: " + supOreEsecuzioni);
							if (lavContoTerziVO.getFlagEscludiEsecuzioni().equalsIgnoreCase("N")) {
								BigDecimal esecuzioniInputBD = Validator.isNotEmpty(esecuzioniInput) ? new BigDecimal(esecuzioniInput) : new BigDecimal("1");
								//System.err.println("esecuzioniInputBD: " + esecuzioniInputBD);
								supOreEsecuzioni = supOreEsecuzioni.multiply(esecuzioniInputBD).setScale(4, BigDecimal.ROUND_HALF_UP);
								//System.err.println("supOreEsecuzioni: " + supOreEsecuzioni);
							} else {
								supOreEsecuzioni = supOreEsecuzioni.setScale(4, BigDecimal.ROUND_HALF_UP);
							}
							
							// 09/05/2016 - SMRUMA-710 - La superficie fattura è libera e non deve essere controllata rispetto al numero di esecuzioni
							/* if (supMax != null && supOreEsecuzioni.compareTo(supMax) > 0) {
								if (SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(lavContoTerziVO.getTipoUnitaMisura())) {
									String msgSupDisponibile = "Non è possibile aumentare il valore della superficie oltre il " + umps + "% (valore massimo consentito "
											+ StringUtils.formatDouble4(supMax) + " ha";
									if (lavContoTerziVO.getFlagEscludiEsecuzioni().equalsIgnoreCase("N")) {
										msgSupDisponibile += ", al netto di " + esecuzioniInput + " esecuzioni).";
									} else {
										msgSupDisponibile += ").";
									}
									errors.add("supOreStr" + index, new ValidationError(msgSupDisponibile));
								}
							} else  */
							 
							if (supOreEsecuzioni.compareTo(zero) == -1) {
								errors.add("supOreStr" + index, new ValidationError("Non è possibile inserire un valore negativo"));
							} else if (!Validator.validateDoubleDigit(supOreStr, 10, 4)) {
								errors.add("supOreStr" + index, new ValidationError("Il valore può avere al massimo 10 cifre intere e 4 decimali"));
							}

						} catch (Exception ex) {
							errors.add("supOreStr" + index, new ValidationError("Campo non numerico"));
						}

					}
				}
			}

			// --- VALIDAZINE campo 'Litri acclività'
			SolmrLogger.debug(this, "---- VALIDAZINE campo 'Litri acclività' ---");
			SolmrLogger.debug(this, "--- litriAcclivitaStr =" + litriAcclivitaStr);
			if (!Validator.isEmpty(litriAcclivitaStr)) {
				SolmrLogger.debug(this, "--- Sono necessari i controlli sul campo 'litriAcclivita'");
				// Deve essere un campo numerico positivo con due numeri decimali
				try {
					BigDecimal litriAcclivitaBd = new BigDecimal(litriAcclivitaStr.replace(',', '.'));
					SolmrLogger.debug(this, "--- litriAcclivitaBd =" + litriAcclivitaBd);
					// Il campo deve essere > -1
					BigDecimal valConfronto = new BigDecimal(-1);
					if (litriAcclivitaBd.compareTo(valConfronto) < 0 || litriAcclivitaBd.compareTo(valConfronto) == 0) {
						SolmrLogger.debug(this, "--- litri acclività deve essere un numero positivo");
						errors.add("litriAcclivita" + i, new ValidationError("Indicare un valore positivo"));
					}
					// deve avere 2 numeri decimali	      
					else if (!Validator.validateDoubleDigit(litriAcclivitaStr, 10, 2)) {
						SolmrLogger.debug(this, "--- litri acclività può avere al massimo 10 cifre intere e 2 decimali");
						errors.add("litriAcclivita" + i, new ValidationError("Il valore può avere al massimo 10 cifre intere e 2 decimali"));
					}
					// il valore non può essere maggiore del lavore calcolato
					else {
						BigDecimal maxLitriAcclivita = new BigDecimal(maxLitriAcclivitaStr.replace(',', '.'));
						if (litriAcclivitaBd.compareTo(maxLitriAcclivita) == 1) {
							SolmrLogger.debug(this, "--- litri acclività non può superare il valore calcolato =" + maxLitriAcclivita);
							errors.add("litriAcclivita" + i, new ValidationError("Il valore di litri per acclività non può essere maggiore di " + maxLitriAcclivitaStr + " litri"));
						} else {
							SolmrLogger.debug(this, "--- il valore litriAcclivita è corretto =" + litriAcclivitaBd);
							lavContoTerziUpdate.setLitriAcclivita(litriAcclivitaBd);
						}
					}

				} catch (Exception ex) {
					errors.add("litriAcclivita" + i, new ValidationError("Campo non numerico"));
				}
			}
			// se il campo non è valorizzato metto il valore zero (il campo db è NotNullable)
			else {
				lavContoTerziUpdate.setLitriAcclivita(new BigDecimal(0));
			}
			SolmrLogger.debug(this, "---  litriAcclivita da salvare sul db =" + lavContoTerziUpdate.getLitriAcclivita());

			if (Validator.isEmpty(supOreFatturaStr)) {
				errors.add("supOreFatturaStr" + index, new ValidationError("Campo obbligatorio"));
			} else {

				try {
					BigDecimal supOreFattura = new BigDecimal(supOreFatturaStr.replace(',', '.'));
					if (supOreFattura.compareTo(zero) == -1)
						errors.add("supOreFatturaStr" + index, new ValidationError("Non è possibile inserire un valore negativo"));
					else if (!Validator.validateDoubleDigit(supOreFatturaStr, 10, 4)) {
						errors.add("supOreFatturaStr" + index, new ValidationError("Il valore può avere al massimo 10 cifre intere e 4 decimali"));
					}

				} catch (Exception ex) {
					errors.add("supOreFatturaStr" + index, new ValidationError("Campo non numerico"));
				}

			}

			if (!Validator.isEmpty(consumoDichiaratoStr)) {
				try {
					SolmrLogger.debug(this, "consumoDichiaratoStr: " + consumoDichiaratoStr);
					SolmrLogger.debug(this, "maxCarburante: " + maxCarburante);
					long consumoDichiarato = Long.parseLong(consumoDichiaratoStr);
					if (consumoDichiarato < 0) {
						errors.add("consumoDichiaratoStr" + index, new ValidationError("Non è possibile inserire un valore negativo"));
					}

				} catch (Exception ex) {
					errors.add("consumoDichiaratoStr" + index, new ValidationError("Campo non numerico"));
				}
			} else
				errors.add("consumoDichiaratoStr" + index, new ValidationError("Campo obbligatorio"));

			vLavContoTerziUpdate.add(lavContoTerziUpdate);

		}
		request.setAttribute("vLavContoTerzi", vLavContoTerziUpdate);

		SolmrLogger.debug(this, "   END validateUpdate");

		return errors;
	}

	private LavContoTerziVO loadVO(LavContoTerziVO lavContoTerziVO) {
		LavContoTerziVO lavContoTerziUpdateVO = new LavContoTerziVO();
		lavContoTerziUpdateVO.setIdDittaUma(lavContoTerziVO.getIdDittaUma());
		lavContoTerziUpdateVO.setIdLavorazioneCT(lavContoTerziVO.getIdLavorazioneCT());
		lavContoTerziUpdateVO.setIdCampagnaCT(lavContoTerziVO.getIdCampagnaCT());
		lavContoTerziUpdateVO.setExtIdAzienda(lavContoTerziVO.getExtIdAzienda());
		lavContoTerziUpdateVO.setCuaa(lavContoTerziVO.getCuaa());
		lavContoTerziUpdateVO.setDenominazione(lavContoTerziVO.getDenominazione());
		lavContoTerziUpdateVO.setPartitaIva(lavContoTerziVO.getPartitaIva());
		lavContoTerziUpdateVO.setIndirizzoSedeLegale(lavContoTerziVO.getIndirizzoSedeLegale());
		lavContoTerziUpdateVO.setSupOre(lavContoTerziVO.getSupOre());
		lavContoTerziUpdateVO.setSupOreFattura(lavContoTerziVO.getSupOreFattura());
		lavContoTerziUpdateVO.setGasolio(lavContoTerziVO.getGasolio());
		lavContoTerziUpdateVO.setConsumoCalcolato(lavContoTerziVO.getConsumoCalcolato());
		lavContoTerziUpdateVO.setConsumoDichiarato(lavContoTerziVO.getConsumoDichiarato());
		lavContoTerziUpdateVO.setEccedenza(lavContoTerziVO.getEccedenza());

		lavContoTerziUpdateVO.setNumeroFatture(lavContoTerziVO.getNumeroFatture());
		lavContoTerziUpdateVO.setDescCategoriaUtilizzo(lavContoTerziVO.getDescCategoriaUtilizzo());
		lavContoTerziUpdateVO.setDescComune(lavContoTerziVO.getDescComune());
		lavContoTerziUpdateVO.setDescProvincia(lavContoTerziVO.getDescProvincia());
		lavContoTerziUpdateVO.setDescTipoLavorazione(lavContoTerziVO.getDescTipoLavorazione());
		lavContoTerziUpdateVO.setDescUsoDelSuolo(lavContoTerziVO.getDescUsoDelSuolo());
		lavContoTerziUpdateVO.setDescUnitaMisura(lavContoTerziVO.getDescUnitaMisura());
		lavContoTerziUpdateVO.setTipoUnitaMisura(lavContoTerziVO.getTipoUnitaMisura());
		lavContoTerziUpdateVO.setFlagEscludiEsecuzioni(lavContoTerziVO.getFlagEscludiEsecuzioni());
		lavContoTerziUpdateVO.setTotaleGasolio(lavContoTerziVO.getTotaleGasolio());
		lavContoTerziUpdateVO.setTotaleGasolioMod(lavContoTerziVO.getTotaleGasolioMod());
		lavContoTerziUpdateVO.setSupMassimaTotaleAziendale(lavContoTerziVO.getSupMassimaTotaleAziendale());
		lavContoTerziUpdateVO.setDataCreazione(lavContoTerziVO.getDataCreazione());
		lavContoTerziUpdateVO.setDataUltimoAggiornamento(lavContoTerziVO.getDataUltimoAggiornamento());
		lavContoTerziUpdateVO.setExtIdUtenteAggiornamento(lavContoTerziVO.getExtIdUtenteAggiornamento());
		lavContoTerziUpdateVO.setSedeLegaleAnag(lavContoTerziVO.getSedeLegaleAnag());
		lavContoTerziUpdateVO.setIdLavorazioneOriginaria(lavContoTerziVO.getIdLavorazioneOriginaria());
		lavContoTerziUpdateVO.setDataInizioValidita(lavContoTerziVO.getDataInizioValidita());
		lavContoTerziUpdateVO.setDataFineValidita(lavContoTerziVO.getDataFineValidita());
		lavContoTerziUpdateVO.setDataCessazione(lavContoTerziVO.getDataCessazione());

		lavContoTerziUpdateVO.setIdMacchina(lavContoTerziVO.getIdMacchina());
		lavContoTerziUpdateVO.setIdLavorazoni(lavContoTerziVO.getIdLavorazoni());
		lavContoTerziUpdateVO.setIdUnitaMisura(lavContoTerziVO.getIdUnitaMisura());
		lavContoTerziUpdateVO.setIstatSedeLegaleComune(lavContoTerziVO.getIstatSedeLegaleComune());
		lavContoTerziUpdateVO.setSupOreCalcolata(lavContoTerziVO.getSupOreCalcolata());
		lavContoTerziUpdateVO.setIdCategoriaUtilizziUma(lavContoTerziVO.getIdCategoriaUtilizziUma());
		lavContoTerziUpdateVO.setNumeroEsecuzioni(lavContoTerziVO.getNumeroEsecuzioni());
		lavContoTerziUpdateVO.setNote(lavContoTerziVO.getNote());

		lavContoTerziUpdateVO.setMaxEsecuzioni(lavContoTerziVO.getMaxEsecuzioni());
		lavContoTerziUpdateVO.setLitriBase(lavContoTerziVO.getLitriBase());
		lavContoTerziUpdateVO.setLitriConto3(lavContoTerziVO.getLitriConto3());
		lavContoTerziUpdateVO.setLitriMedioImpasto(lavContoTerziVO.getLitriMedioImpasto());

		lavContoTerziUpdateVO.setMaxCarburante(lavContoTerziVO.getMaxCarburante());
		lavContoTerziUpdateVO.setMaxLitriAcclivita(lavContoTerziVO.getMaxLitriAcclivita());
		lavContoTerziUpdateVO.setLitriAcclivita(lavContoTerziVO.getLitriAcclivita());
		lavContoTerziUpdateVO.setLitriTerDeclivi(lavContoTerziVO.getLitriTerDeclivi());

		lavContoTerziUpdateVO.setScavalco(lavContoTerziVO.isScavalco());

		return lavContoTerziUpdateVO;
	}%>
