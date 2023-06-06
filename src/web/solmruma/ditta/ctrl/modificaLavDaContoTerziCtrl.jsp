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
	String iridePageName = "modificaLavDaContoTerziCtrl.jsp";
%><%@include file="/include/autorizzazione.inc"%>
<%
	String viewUrl = "/ditta/view/modificaLavDaContoTerziView.jsp";
	String elencoHtm = "../../ditta/layout/elencoLavDaContoTerzi.htm";
	String elencoBisHtm = "../../ditta/layout/elencoLavDaContoTerziBis.htm";
	RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

	UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
	HashMap hashCommon = (HashMap) session.getAttribute("hashCommon");
	if (hashCommon == null)
		hashCommon = new HashMap();
	if (request.getParameter("salva.x") != null) {
		SolmrLogger.debug(this, "modificaLavDaContoTerziCtrl - salvataggio");
		Vector vLavContoTerziUpdate = new Vector();
		ValidationErrors errors = validateUpdate(request, (Vector) hashCommon.get("vLavDaContoTerzi"), vLavContoTerziUpdate);
		SolmrLogger.debug(this, "errors.size()=" + errors.size());
		if (errors.size() != 0) {
			request.setAttribute("errors", errors);
		} else {

			try {
				//update
				SolmrLogger.debug(this, " -------- proseguo con l'inserimento dati sul db");
				umaFacadeClient.aggiornaLavorazioneContoTerzi(vLavContoTerziUpdate, ruoloUtenza);
			} catch (SolmrException sexc) {
				SolmrLogger.error(this, " --- -SolmrException  =" + sexc.getMessage());
				if (sexc.getValidationErrors() != null) {
					SolmrLogger.debug(this, "        if (sexc.getValidationErrors()!=null)");
					ValidationErrors vErrors = sexc.getValidationErrors();
					if (vErrors.size() != 0) {
						SolmrLogger.debug(this, "          if (vErrors.size()!=0)");
						request.setAttribute("errors", vErrors);
%>
<jsp:forward page="<%=viewUrl%>" />
<%
	return;
					}
				} else {
					SolmrLogger.debug(this, "          else (vErrors.size()!=0)");
					ValidationException valEx = new ValidationException("Eccezione di validazione" + sexc.getMessage(), viewUrl);
					valEx.addMessage(sexc.toString(), "exception");
					throw valEx;
				}
				SolmrLogger.debug(this, "        dopo if (sexc.getValidationErrors()!=null)");
			} catch (Exception e) {
				ValidationException valEx = new ValidationException("Eccezione di validazione" + e.getMessage(), viewUrl);
				valEx.addMessage(e.getMessage(), "exception");
				throw valEx;
			}
			String forwardUrl = elencoHtm;
			if ("bis".equalsIgnoreCase(request.getParameter("pageFrom"))) {
				forwardUrl = elencoBisHtm;
			}

			session.setAttribute("notifica", "Modifica eseguita con successo");
			response.sendRedirect(forwardUrl);
			return;
		}
	} else {
		if (request.getParameter("annulla.x") != null) {
			if ("bis".equalsIgnoreCase(request.getParameter("pageFrom"))) {
				response.sendRedirect(elencoBisHtm);
			} else {
				response.sendRedirect(elencoHtm);
			}
			return;
		} else {
			//carico i dati la prima volta che entro nella pagina
			Vector vLavContoTerzi = (Vector) session.getAttribute("vLavDaContoTerzi");

			//  HashMap<Long,ZonaAltimetricaVO> hashZonaAlt = new HashMap<Long,ZonaAltimetricaVO>();      
			Vector vExtIdAzienda = new Vector();
			AnagAziendaVO[] listaAnagAziendaVO = null;
			for (int i = 0; i < vLavContoTerzi.size(); i++) {
				LavContoTerziVO lavContoTerzi = (LavContoTerziVO) vLavContoTerzi.get(i);
				SolmrLogger.debug(this, "idUtenteAggiornamento: " + lavContoTerzi.getExtIdUtenteAggiornamento());
				SolmrLogger.debug(this, "lavContoTerzi.getIdLavorazioneCT(): " + lavContoTerzi.getIdLavorazioneCT());
				//      	if(lavContoTerzi.getExtIdUtenteAggiornamento() != null && vIdUtente.contains(lavContoTerzi.getExtIdUtenteAggiornamento()) == false )
				//      	vIdUtente.add(lavContoTerzi.getExtIdUtenteAggiornamento());
				if (lavContoTerzi.getExtIdAzienda() != null && vExtIdAzienda.contains(lavContoTerzi.getExtIdAzienda()) == false)
					vExtIdAzienda.add(lavContoTerzi.getExtIdAzienda());
			}
			//      RuoloUtenza[] ruoloUtenza = umaFacadeClient.serviceGetRuoloUtenzaByIdRange((Long[])vIdUtente.toArray(new Long[vIdUtente.size()]),false);
			if (vExtIdAzienda.size() > 0) {
				listaAnagAziendaVO = umaFacadeClient.serviceGetListAziendeByIdRange(vExtIdAzienda);
				DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
				// hashZonaAlt = umaFacadeClient.getZonaAltByExtIdAziendaRange((Long[]) vExtIdAzienda.toArray(new Long[vExtIdAzienda.size()]),dittaUMAAziendaVO.getIdDittaUMA());
			}

			String anno = ((LavContoTerziVO) vLavContoTerzi.get(0)).getAnnoCampagna();
			String data = null;
			String coefficiente = umaFacadeClient.getValoreParametro(SolmrConstants.PARAMETRO_COEFFICIENTE_CAVALLI_CARBURANTE, anno, data);

			// ---- Ricerco la zona altimetrica della ditta Uma sulla quale sto lavorando (me stessa)
			DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
			SolmrLogger.debug(this, "****dittaUMAAziendaVO.getIdDittaUMA() vale: " + dittaUMAAziendaVO.getIdDittaUMA());
			String codiceZonaAlt = null;
			if (null != dittaUMAAziendaVO.getIdDittaUMA()) {
				ZonaAltimetricaVO zonaAltimetrica = umaFacadeClient.getZonaAltByIdDittaUma(dittaUMAAziendaVO.getIdDittaUMA());
				if (zonaAltimetrica != null)
					codiceZonaAlt = zonaAltimetrica.getCodiceZonaAltimetrica();
				SolmrLogger.debug(this, " -- codiceZonaAlt =" + codiceZonaAlt);
			}

			hashCommon.put("vLavDaContoTerzi", vLavContoTerzi);
			hashCommon.put("listaAnagAziendaVO", listaAnagAziendaVO);
			//hashCommon.put("hashZonaAlt", hashZonaAlt);
			hashCommon.put("codiceZonaAlt", codiceZonaAlt);
			hashCommon.put("coefficiente", coefficiente);

			session.setAttribute("hashCommon", hashCommon);

			request.setAttribute("vLavDaContoTerzi", hashCommon.get("vLavDaContoTerzi"));

		}
	}

	request.setAttribute("listaAnagAziendaVO", hashCommon.get("listaAnagAziendaVO"));
	request.setAttribute("hashMapMacchine", hashCommon.get("hashMapMacchine"));
	//request.setAttribute("hashZonaAlt", hashCommon.get("hashZonaAlt"));
	request.setAttribute("codiceZonaAlt", hashCommon.get("codiceZonaAlt"));
	request.setAttribute("coefficiente", hashCommon.get("coefficiente"));

	SolmrLogger.debug(this, "modificaLavDaContoTerziCtrl - End");
%>

<jsp:forward page="<%=viewUrl%>" />
<%!private ValidationErrors validateUpdate(HttpServletRequest request, Vector vLavContoTerzi, Vector vLavContoTerziUpdate) throws Exception {
		ValidationErrors errors = new ValidationErrors();
		BigDecimal zero = new BigDecimal(0);

		for (int i = 0; i < vLavContoTerzi.size(); i++) {
			LavContoTerziVO lavContoTerziVO = (LavContoTerziVO) vLavContoTerzi.get(i);
			LavContoTerziVO lavContoTerziUpdate = loadVO(lavContoTerziVO);
			String idLavContoTerzi = lavContoTerziVO.getIdLavorazioneCT().toString();
			String esecuzioniStr = request.getParameter("esecuzioniStr" + idLavContoTerzi);
			String supOreStr = request.getParameter("supOreStr" + idLavContoTerzi);
			String gasolioStr = request.getParameter("gasolioStr" + idLavContoTerzi);
			String benzinaStr = request.getParameter("benzinaStr" + idLavContoTerzi);
			String note = request.getParameter("note" + idLavContoTerzi);
			String maxCarburante = request.getParameter("maxCarburante" + idLavContoTerzi);

			lavContoTerziUpdate.setEsecuzioniStr(esecuzioniStr);

			lavContoTerziUpdate.setSupOreStr(supOreStr);
			lavContoTerziUpdate.setGasolioStr(gasolioStr);
			lavContoTerziUpdate.setBenzinaStr(benzinaStr);
			lavContoTerziUpdate.setNote(note);
			lavContoTerziUpdate.setMaxCarburante(maxCarburante);

			SolmrLogger.debug(this, "SUP ORE CALCOLATAAAAA: " + lavContoTerziVO.getSupOreCalcolata());
			/*if(lavContoTerziVO.getSupOreCalcolata()==null){
				lavContoTerziUpdate.setMaxCarburante("");
				maxCarburante="";
			}
			else lavContoTerziUpdate.setMaxCarburante(maxCarburante);*/

			if (note.length() > 1000) {
				errors.add("noteStr" + i, new ValidationError("Inserire al max 1000 caratteri"));
			}

			if (lavContoTerziVO.getMaxEsecuzioni() != null) {
				if (Validator.isEmpty(esecuzioniStr)) {
					errors.add("esecuzioniStr" + i, new ValidationError("Campo obbligatorio"));
				} else {
					long numeroEsecuzioni = lavContoTerziVO.getMaxEsecuzioni().longValue();
					long esecuzioniInput = 0;
					try {
						esecuzioniInput = Long.parseLong(esecuzioniStr);
					} catch (Exception ex) {
						errors.add("esecuzioniStr" + i, new ValidationError("Valore numerico"));
					}

					if (esecuzioniInput < 0)
						errors.add("esecuzioniStr" + i, new ValidationError("Non è possibile inserire un valore negativo"));

					if (esecuzioniInput > numeroEsecuzioni) {
						errors.add("esecuzioniStr" + i, new ValidationError("Non è possibile aumentare il valore del numero esecuzioni"));
					}
				}
			}

			//il campo è modificabile al ribasso solo se extIdAzienda != null

			if (Validator.isEmpty(supOreStr)) {
				errors.add("supOreStr" + i, new ValidationError("Campo obbligatorio"));
			} else {

				try {
					BigDecimal supOre = new BigDecimal(supOreStr.replace(',', '.'));
					BigDecimal supMax = lavContoTerziVO.getSupOreCalcolata();

					if (supMax != null && SolmrConstants.TIPO_UNITA_MISURA_M.equalsIgnoreCase(lavContoTerziUpdate.getTipoUnitaMisura())) {
						SolmrLogger.debug(this, "--  CASO TIPO_MISURA = 'M' --");
						supMax = supMax.multiply(new BigDecimal(SolmrConstants.MAX_METRO_L));
						SolmrLogger.debug(this, "--- max superficie per metro lineare =" + supMax);
						if (supOre.compareTo(supMax) > 0) {
							errors.add("supOreStr" + i, new ValidationError("La lunghezza indicata non può essere maggiore di " + StringUtils.formatDouble4(supMax) + " metri"));
						}
					} else if (supMax != null && supOre.compareTo(supMax) > 0) {
						if (SolmrConstants.TIPO_UNITA_MISURA_S.equalsIgnoreCase(lavContoTerziUpdate.getTipoUnitaMisura()))
							errors.add("supOreStr" + i, new ValidationError("Non è possibile aumentare il valore della superficie (valore massimo consentito " + StringUtils.formatDouble4(supMax)
									+ " ha)"));
						else
							errors.add("supOreStr" + i, new ValidationError("Non è possibile aumentare il valore della potenza (valore massimo consentito " + StringUtils.formatDouble4(supMax)
									+ " kw)"));
					} else if (supOre.compareTo(zero) == -1) {
						errors.add("supOreStr" + i, new ValidationError("Non è possibile inserire un valore negativo"));
					} else if (!Validator.validateDoubleDigit(supOreStr, 10, 4)) {
						errors.add("supOreStr" + i, new ValidationError("Il valore può avere al massimo 10 cifre intere e 4 decimali"));
					}
				} catch (Exception ex) {
					errors.add("supOreStr" + i, new ValidationError("Campo non numerico"));
				}

			}

			/*
			if (!Validator.isEmpty(gasolioStr))
			{
			  try
			  {
			    SolmrLogger.debug(this, "gasolio: " + gasolioStr);
			    SolmrLogger.debug(this, "maxCarburante: " + maxCarburante);
			    long gasolio = Long.parseLong(gasolioStr);
			    if (!Validator.isEmpty(maxCarburante)
			        && gasolio > Long.parseLong(maxCarburante))
			    {
			      errors.add("gasolioStr" + i, new ValidationError(
			          "Non è possibile aumentare la quantità"));
			    }
			    else
			      if (gasolio < 0)
			      {
			        errors.add("gasolioStr" + i, new ValidationError(
			            "Non è possibile inserire un valore negativo"));
			      }

			  }
			  catch (Exception ex)
			  {
			    errors.add("gasolioStr" + i, new ValidationError(
			        "Campo non numerico"));
			  }
			}
			 */
			if (!Validator.isEmpty(benzinaStr)) {
				try {
					long benzina = Long.parseLong(benzinaStr);
					SolmrLogger.debug(this, "benzina: " + benzina);
					SolmrLogger.debug(this, "maxCarburante: " + maxCarburante);
					if (!Validator.isEmpty(maxCarburante) && benzina > Long.parseLong(maxCarburante)) {
						errors.add("benzinaStr" + i, new ValidationError("Non è possibile aumentare la quantità"));
					} else if (benzina < 0)
						errors.add("benzinaStr" + i, new ValidationError("Non è possibile inserire un valore negativo"));
				} catch (Exception ex) {
					errors.add("benzinaStr" + i, new ValidationError("Campo non numerico"));
				}
			}

			lavContoTerziUpdate.setSupOreFatturaStr(supOreStr);
			lavContoTerziUpdate.setConsumoCalcolatoStr(gasolioStr);
			lavContoTerziUpdate.setConsumoDichiaratoStr(benzinaStr);

			// setto valore fisso = 0 per LITRI_TERRENI_DECLIVI
			lavContoTerziUpdate.setLitriAcclivita(new BigDecimal(0));

			vLavContoTerziUpdate.add(lavContoTerziUpdate);

		}
		request.setAttribute("vLavDaContoTerzi", vLavContoTerziUpdate);
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
		lavContoTerziUpdateVO.setBenzina(lavContoTerziVO.getBenzina());
		lavContoTerziUpdateVO.setNumeroFatture(lavContoTerziVO.getNumeroFatture());
		lavContoTerziUpdateVO.setDescCategoriaUtilizzo(lavContoTerziVO.getDescCategoriaUtilizzo());
		lavContoTerziUpdateVO.setDescComune(lavContoTerziVO.getDescComune());
		lavContoTerziUpdateVO.setDescProvincia(lavContoTerziVO.getDescProvincia());
		lavContoTerziUpdateVO.setDescTipoLavorazione(lavContoTerziVO.getDescTipoLavorazione());
		lavContoTerziUpdateVO.setDescUsoDelSuolo(lavContoTerziVO.getDescUsoDelSuolo());
		lavContoTerziUpdateVO.setDescUnitaMisura(lavContoTerziVO.getDescUnitaMisura());
		lavContoTerziUpdateVO.setTipoUnitaMisura(lavContoTerziVO.getTipoUnitaMisura());
		lavContoTerziUpdateVO.setTotaleGasolio(lavContoTerziVO.getTotaleGasolio());
		lavContoTerziUpdateVO.setTotaleBenzina(lavContoTerziVO.getTotaleBenzina());
		lavContoTerziUpdateVO.setTotaleGasolioMod(lavContoTerziVO.getTotaleGasolioMod());
		lavContoTerziUpdateVO.setTotaleBenzinaMod(lavContoTerziVO.getTotaleBenzinaMod());
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
		lavContoTerziUpdateVO.setLitriTerDeclivi(lavContoTerziVO.getLitriTerDeclivi());
		lavContoTerziUpdateVO.setMaxCarburante(lavContoTerziVO.getMaxCarburante());

		return lavContoTerziUpdateVO;
	}%>
