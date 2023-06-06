<%@ page language="java" contentType="text/html" isErrorPage="true"%>

<%@ page import="java.util.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.client.anag.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.dto.anag.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.etc.uma.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="java.text.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%
	String iridePageName = "macchinaNuovaUtilizzoCasoR-ASMCtrl.jsp";
%>
<%@include file="/include/autorizzazione.inc"%>
<%
	DittaUMAAziendaVO dittaUMAAziendaVO = (DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
	Long idDittaUma = dittaUMAAziendaVO.getIdDittaUMA();

	String INDIETRO = "indietroUtilizzo";
	String SALVA = "salva";
	UmaFacadeClient umaClient = new UmaFacadeClient();
	AnagFacadeClient anagClient = new AnagFacadeClient();
	String viewUrl = "/macchina/view/macchinaNuovaUtilizzoCasoR-ASMView.jsp";
	String prevUrlHtml = "../layout/macchinaNuovaDatiCasoR-ASM.htm";
	String nextUrlHtml = "../layout/macchinaNuovaConferma.htm";

	SolmrLogger.debug(this, "dittaUMAAziendaVO.getProvCompetenza(): " + dittaUMAAziendaVO.getProvCompetenza());
	SolmrLogger.debug(this, "dittaUMAAziendaVO.getProvUMA(): " + dittaUMAAziendaVO.getProvUMA());

	RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
	HashMap vecSession = null;
	MacchinaVO macchinaVO = null;
	MatriceVO matriceVO = null;
	DatiMacchinaVO datiMacchinaVO = null;
	UtilizzoVO utilizzoVO = new UtilizzoVO();
	PossessoVO possessoVO = new PossessoVO();
	AnagAziendaVO dittaLeasing = new AnagAziendaVO();
	MovimentiTargaVO movimentiTargaVO = null;

	if (session.getAttribute("common") != null) {
		SolmrLogger.debug(this, "session.getAttribute(\"common\")!=null");
		vecSession = (HashMap) session.getAttribute("common");
		macchinaVO = (MacchinaVO) vecSession.get("macchinaVO");
		SolmrLogger.debug(this, "macchinaVO: " + macchinaVO);
		matriceVO = (MatriceVO) vecSession.get("matriceVO");
		SolmrLogger.debug(this, "matriceVO: " + matriceVO);
		datiMacchinaVO = (DatiMacchinaVO) vecSession.get("datiMacchinaVO");
		SolmrLogger.debug(this, "datiMacchinaVO: " + datiMacchinaVO);
	}

	if (request.getParameter(SALVA) != null) {
		try {
			
			SolmrLogger.debug(this, "Salva su machinaNuovaUtilizzoCasoR-ASM");
			ValidationErrors vErr = null;
			
			String idFormaPossesso = request.getParameter("idFormaPossesso");
			String idSocietaLeasing = request.getParameter("idSocietaLeasing");
			
			ValidationError errValLeas = null;
			
			boolean noDitta = false;
			
			if (idFormaPossesso!=null && idFormaPossesso.equals(SolmrConstants.get("LEASING")) && idSocietaLeasing != null) {
				try {
					SolmrLogger.debug(this, "idSocietaLeasing: " + idSocietaLeasing);
					dittaLeasing = anagClient.findAziendaAttiva(new Long(idSocietaLeasing));
					SolmrLogger.debug(this, "dittaLeasing.getPartitaIVA(): " + dittaLeasing.getPartitaIVA());
					PersonaFisicaVO rapprLegale = anagClient.getTitolareORappresentanteLegaleAzienda(dittaLeasing.getIdAzienda(), new Date());
					dittaLeasing.setRappresentanteLegale(rapprLegale.getNome() + " " + rapprLegale.getCognome());
					possessoVO.setExtIdAzienda(idSocietaLeasing);
				} catch (SolmrException e) {
					SolmrLogger.debug(this, "errore dittaLeasing non trovata");
					noDitta = true;
				}
			}
			
			vErr = validateInputUtilizzoRimorchioAsm(datiMacchinaVO, macchinaVO, utilizzoVO, possessoVO, request, umaClient, anagClient);
		
			if(noDitta){
				vErr.add("societaLeasing", new ValidationError("Ditta non trovata!"));
			}
			else{
				SolmrLogger.debug(this, "ctrl dittaLeasing.getIdAnagAzienda(): " + dittaLeasing.getIdAnagAzienda());
			}
	
			// Salva
			try {
				vecSession = new HashMap();

				vecSession.put("macchinaVO", macchinaVO);
				vecSession.put("datiMacchinaVO", datiMacchinaVO);
				vecSession.put("utilizzoVO", utilizzoVO);
				vecSession.put("possessoVO", possessoVO);
				vecSession.put("anagAziendaVO", dittaLeasing);

				session.setAttribute("common", vecSession);
			} catch (Exception e) {
				SolmrLogger.debug(this, "throwValidation: 1");
				this.throwValidation(e.getMessage(), viewUrl);
			}

			if (vErr.size() != 0) {
				SolmrLogger.debug(this, "vErr.size()!=0");
				SolmrLogger.debug(this, "vErr: " + vErr);
				request.setAttribute("errors", vErr);
%>
<jsp:forward page="<%=viewUrl%>" />
<%
	} else {
				SolmrLogger.debug(this, "vErr.size()==0");
			}

			try {
				SolmrLogger.debug(this, "dittaUMAAziendaVO.getProvCompetenza(): " + dittaUMAAziendaVO.getProvCompetenza());
				movimentiTargaVO = umaClient.acquistaMacchinaNuovaRimorchioAsm(macchinaVO, datiMacchinaVO, possessoVO, utilizzoVO, dittaLeasing, dittaUMAAziendaVO, ruoloUtenza);
			} catch (Exception e) {
				//SolmrLogger.debug(this,"throwValidation: 2");
				//this.throwValidation(e.getMessage(),viewUrl);
				SolmrLogger.debug(this, "SolmrException = " + e.getMessage());
				ValidationErrors errors = new ValidationErrors();
				errors.add("error", new ValidationError(e.getMessage()));
				request.setAttribute("errors", errors);
%>
<jsp:forward page="<%=viewUrl%>" />
<%
	return;
			}

			if (session.getAttribute("common") != null) {
				SolmrLogger.debug(this, "session.getAttribute(\"common\")!=null");
				vecSession = (HashMap) session.getAttribute("common");
				if (datiMacchinaVO.isHasTarga()) {
					vecSession.put("movimentiTargaVO", movimentiTargaVO);
				} else {
					vecSession.put("movimentiTargaVO", null);
				}

				//Modifica Attestazione Proprietà da macchina nuova - Begin
				Long idMacchina = new Long(movimentiTargaVO.getIdMacchina());
				vecSession.put("idMacchina", idMacchina);
				SolmrLogger.debug(this, "idMacchina: " + idMacchina);
				//Modifica Attestazione Proprietà da macchina nuova - End
				session.setAttribute("common", vecSession);
			}

			response.sendRedirect(nextUrlHtml);
			return;
		} catch (Exception e) {
			SolmrLogger.debug(this, "throwValidation: 3");
			this.throwValidation(e.getMessage(), viewUrl);
		}
	} else {
		if (request.getParameter(INDIETRO) != null) {
			// Indietro
			SolmrLogger.debug(this, "Indietro su machinaNuovaUtilizzoCasoR-ASM");
			SolmrLogger.debug(this, "datiMacchinaVO.getIdGenereMacchinaLong(): " + datiMacchinaVO.getIdGenereMacchinaLong());
			SolmrLogger.debug(this, "datiMacchinaVO.getIdCategoriaLong(): " + datiMacchinaVO.getIdCategoriaLong());
			SolmrLogger.debug(this, "prevUrlHtml: " + prevUrlHtml);
			annullaLoad(datiMacchinaVO, macchinaVO, utilizzoVO, possessoVO, dittaLeasing, request);
			response.sendRedirect(prevUrlHtml);
			return;
		}
		// Visualizzazione
		SolmrLogger.debug(this, "Caricamento dati ricerca in macchinaNuovaUtilizzoCasoR-ASM");
		assegnaTipoTarga(request, umaClient, datiMacchinaVO);
		SolmrLogger.debug(this, "datiMacchinaVO.isHasTarga(): " + datiMacchinaVO.isHasTarga());
		SolmrLogger.debug(this, "datiMacchinaVO.getTipoTarga(): " + datiMacchinaVO.getTipoTarga());
		utilizzoVO.setDataCaricoDate(new Date());

		SolmrLogger.debug(this, "2Caricamento dati ricerca in macchinaNuovaDatiCasoR-ASM");
		vecSession = new HashMap();
		vecSession.put("macchinaVO", macchinaVO);
		vecSession.put("datiMacchinaVO", datiMacchinaVO);
		vecSession.put("possessoVO", possessoVO);
		vecSession.put("utilizzoVO", utilizzoVO);

		session.setAttribute("common", vecSession);
%>
<jsp:forward page="<%=viewUrl%>" />
<%
	}
%>

<%!private void throwValidation(String msg, String validateUrl) throws ValidationException {
		ValidationException valEx = new ValidationException(msg, validateUrl);
		valEx.addMessage(msg, "exception");
		throw valEx;
	}

	private void assegnaTipoTarga(HttpServletRequest request, UmaFacadeClient umaClient, DatiMacchinaVO datiMacchinaVO) throws ValidationException {
		final String RIMORCHIO = "R";
		final String ASM = "ASM";
		final String MAOTRAINATA = "010";
		final String CARROUNIFEED = "012";
		final double LIMITE_LORDO = 15;
		String tipoTarga = null;
		final String STRADALERA = "Stradale RA";
		SolmrLogger.debug(this, "1tipoTarga: " + tipoTarga);
		//Tipo Genere = RIMORCHIO	
		SolmrLogger.debug(this, "datiMacchinaVO.getIdCategoriaLong().longValue(): " + datiMacchinaVO.getIdCategoriaLong().longValue());
		SolmrLogger.debug(this, "datiMacchinaVO.getIdGenereMacchinaLong().longValue(): " + datiMacchinaVO.getIdGenereMacchinaLong().longValue());
		if (datiMacchinaVO.getCodBreveGenereMacchina().trim().equalsIgnoreCase(RIMORCHIO)) {
			SolmrLogger.debug(this, "Rimorchio");
			if (datiMacchinaVO.getCodBreveCategoriaMacchina().trim().equalsIgnoreCase(MAOTRAINATA)) {
				SolmrLogger.debug(this, "Rimorchio mao trainata");
				tipoTarga = null;
			} else {
				if (datiMacchinaVO.getCodBreveCategoriaMacchina().trim().equalsIgnoreCase(CARROUNIFEED)) {
					SolmrLogger.debug(this, "Rimorchio carro unifeed");
					tipoTarga = null;
				} else {
					if (tipoTarga == null) {
						SolmrLogger.debug(this, "datiMacchinaVO.getLordoDouble().doubleValue(): " + datiMacchinaVO.getLordoDouble().doubleValue());
						if (datiMacchinaVO.getLordoDouble().doubleValue() <= LIMITE_LORDO) {
							SolmrLogger.debug(this, "Rimorchio limite lordo inferiore o uguale 15");
							tipoTarga = null;
						} else {
							SolmrLogger.debug(this, "Rimorchio limite lordo superiore 15");
							tipoTarga = STRADALERA;
						}
					}
				}
			}
		}
		SolmrLogger.debug(this, "2tipoTarga: " + tipoTarga);
		if (datiMacchinaVO.getCodBreveGenereMacchina().trim().equalsIgnoreCase(ASM)) {
			SolmrLogger.debug(this, "Asm");
			tipoTarga = null;
		}
		SolmrLogger.debug(this, "3tipoTarga: " + tipoTarga);
		if (tipoTarga == null) {
			datiMacchinaVO.setHasTarga(false);
		} else {
			datiMacchinaVO.setHasTarga(true);
		}
		datiMacchinaVO.setTipoTarga(tipoTarga);
	}

	private ValidationErrors validateInputUtilizzoRimorchioAsm(DatiMacchinaVO datiMacchinaVO, MacchinaVO macchinaVO, UtilizzoVO utilizzoVO, PossessoVO possessoVO, HttpServletRequest request,
			UmaFacadeClient umaClient, AnagFacadeClient anagClient) throws Exception {
		final String LEASING = "4";
		final String NOLEGGIO = "2";
		final String TARGA_ASSEGNATA = "auto";
		final String TARGA_SPECIFICATA = "spec";
		final boolean MACCHINA_CON_TARGA = true;
		final boolean MACCHINA_SENZA_TARGA = false;
		int FIRST_ELEMENT = 0;
		final Long TARGA_STRADALE_RA = new Long("2");
		boolean numeroTargaObbl = false;
		ValidationErrors errors = new ValidationErrors();
		//Acquisto nuovo con targa - Borgogno 21/10/2004 - Begin
		String numeroTarga = null;
		TargaVO targaCorrente = new TargaVO();
		SolmrLogger.debug(this, "request.getParameter(\"radioTarga\"): " + request.getParameter("radioTarga"));
		if (Validator.isNotEmpty(request.getParameter("radioTarga"))) {
			SolmrLogger.debug(this, "if (!Validator.isNotEmpty(request.getParameter(\"radioTarga\")))");
			String radioTarga = request.getParameter("radioTarga");
			if (radioTarga.equalsIgnoreCase(TARGA_SPECIFICATA)) {
				SolmrLogger.debug(this, "-----if(radioTarga.equalsIgnoreCase(TARGA_SPECIFICATA))");
				numeroTargaObbl = true;
				SolmrLogger.debug(this, "numeroTargaObbl: " + numeroTargaObbl);
				numeroTarga = request.getParameter("numeroTarga");
				SolmrLogger.debug(this, "numeroTarga: " + numeroTarga);
				if (!Validator.isNotEmpty(request.getParameter("numeroTarga"))) {
					errors.add("numeroTarga", new ValidationError("Specificare un numero targa"));
				}
				macchinaVO.setHasTarga(MACCHINA_CON_TARGA);
			} else if (radioTarga.equalsIgnoreCase(TARGA_ASSEGNATA)) {
				SolmrLogger.debug(this, "if(radioTarga.equalsIgnoreCase(TARGA_ASSEGNATA))");
				macchinaVO.setHasTarga(MACCHINA_SENZA_TARGA);
			}

			SolmrLogger.debug(this, "numeroTargaObbl: " + numeroTargaObbl);
			SolmrLogger.debug(this, "errors.get(\"numeroTarga\"): " + errors.get("numeroTarga"));
			if (numeroTargaObbl && errors.get("numeroTarga") == null) {
				SolmrLogger.debug(this, "if(numeroTargaObbl && errors.get(\"numeroTarga\")==null)");
				SolmrLogger.debug(this, "numeroTarga: " + numeroTarga);
				targaCorrente.setNumeroTarga(numeroTarga);
				targaCorrente.setIdTargaLong(TARGA_STRADALE_RA);
				//macchinaVO.setTargaCorrente(targaCorrente);
				SolmrLogger.debug(this, "targaCorrente.getNumeroTarga(): " + targaCorrente.getNumeroTarga());
				SolmrLogger.debug(this, "targaCorrente.getIdTargaLong(): " + targaCorrente.getIdTargaLong());
				
				// TOLTI CONTROLLI SUL FORMATO DELLA TARGA PER LA TOBECONFIG
				//SolmrLogger.debug(this, "errors = isFormatoTargaValido(" + numeroTarga + "," + TARGA_STRADALE_RA + "," + errors + ")");				
				//errors = isFormatoTargaValido(numeroTarga, TARGA_STRADALE_RA, errors);
				
				SolmrLogger.debug(this, "1errors.size(): " + errors.size());
				SolmrLogger.debug(this, "TARGA_STRADALE_RA: " + TARGA_STRADALE_RA);
				try {
					SolmrLogger.debug(this, "errors = isTargaUnica(" + numeroTarga + "," + TARGA_STRADALE_RA + "," + errors + "," + umaClient + ")");
					errors = isTargaUnica(numeroTarga, TARGA_STRADALE_RA, errors, umaClient);
					SolmrLogger.debug(this, "3errors.size(): " + errors.size());
				} catch (SolmrException sExc) {
					SolmrLogger.debug(this, "sExc.getMessage(): " + sExc.getMessage());
					errors.add("error", new ValidationError(sExc.getMessage()));
				}
			}

			if (macchinaVO.isHasTarga()) {
				String dataPrimaImmatricolazione = request.getParameter("dataPrimaImmatricolazione");

				Validator.validateDateAll(dataPrimaImmatricolazione, "dataPrimaImmatricolazione", "data prima immatricolazione", errors, true, true);
				if (errors.get("dataPrimaImmatricolazione") == null) {
					targaCorrente.setDataPrimaImmatricolazione(DateUtils.parseDate(dataPrimaImmatricolazione));
				}
			}

			macchinaVO.setTargaCorrente(targaCorrente);
		}
		//Acquisto nuovo con targa - Borgogno 21/10/2004 - End

		String dataCarico = request.getParameter("dataCarico");
		Validator.validateDateAll(dataCarico, "dataCarico", "data di carico", errors, true, true);
		if (errors.get("dataCarico") == null) {
			utilizzoVO.setDataCarico(request.getParameter("dataCarico"));
		}

		SolmrLogger.debug(this, "Before if (!Validator.isNotEmpty(request.getParameter(\"idFormaPossesso\")))");
		String idFormaPossesso = request.getParameter("idFormaPossesso");
		String dataScadenzaLeasing = request.getParameter("dataScadenzaLeasing");
		if (!Validator.isNotEmpty(idFormaPossesso)) {
			possessoVO.setIdFormaPossesso(null);
			errors.add("idFormaPossesso", new ValidationError("Inserire la forma possesso"));
			SolmrLogger.debug(this, "1A");
		} else {
			possessoVO.setIdFormaPossesso(request.getParameter("idFormaPossesso"));

			SolmrLogger.debug(this, "idFormaPossesso: " + possessoVO.getIdFormaPossesso());
			SolmrLogger.debug(this, "1B");

			// se idFormaPossesso = 'Leasing' o 'Utilizzo/Noleggio' -> data scadenza obbligatoria     
			if (idFormaPossesso.equals(SolmrConstants.get("LEASING")) || idFormaPossesso.equals(SolmrConstants.get("UTILIZZO_NOLEGGIO"))) {
				if (!Validator.isNotEmpty(dataScadenzaLeasing)) {
					errors.add("dataScadenzaLeasing", new ValidationError("Valorizzare la data scadenza contratto"));
				} else {
					if (!Validator.validateDateF(dataScadenzaLeasing)) {
						errors.add("dataScadenzaLeasing", new ValidationError("Valorizzare la data correttamente"));
					} else {
						Date data = null;
						Date oggi = null;
						try {
							data = UmaBaseVO.parseDate(dataScadenzaLeasing);
							oggi = UmaBaseVO.parseDate(UmaDateUtils.getCurrentDateString());
						} catch (Exception ex) {
							errors.add("dataScadenzaLeasing", new ValidationError("Errore nel formato della data"));
						}
						if (!data.after(oggi)) {
							errors.add("dataScadenzaLeasing", new ValidationError("La data scadenza contratto deve essere superiore alla data odierna"));
						}
					}
				}
				// se idFormaPossesso = 'Leasing' -> società di leasing obbligatoria
				if (idFormaPossesso.equals(SolmrConstants.get("LEASING"))) {
					if (Validator.isEmpty((String) request.getParameter("idSocietaLeasing"))) {
						errors.add("idSocietaLeasing", new ValidationError("Indicare la società di leasing"));
					}
				}
			}
			// in tutti gli altri casi, se viene indicata una data scadenza (facoltativa), deve essere una data valida
			else {
				if (Validator.isNotEmpty(dataScadenzaLeasing)) {
					if (!Validator.validateDateF(dataScadenzaLeasing)) {
						errors.add("dataScadenzaLeasing", new ValidationError("Valorizzare la data correttamente"));
					} else {
						Date data = null;
						Date oggi = null;
						try {
							data = UmaBaseVO.parseDate(dataScadenzaLeasing);
							oggi = UmaBaseVO.parseDate(UmaDateUtils.getCurrentDateString());
						} catch (Exception ex) {
							errors.add("dataScadenzaLeasing", new ValidationError("Errore nel formato della data"));
						}
						if (!data.after(oggi)) {
							errors.add("dataScadenzaLeasing", new ValidationError("La data scadenza contratto deve essere superiore alla data odierna"));
						}
					}
				}
			}

			possessoVO.setDataScadenzaLeasing(request.getParameter("dataScadenzaLeasing"));

		}

		SolmrLogger.debug(this, "request.getParameter(\"idFormaPossesso\"): " + request.getParameter("idFormaPossesso"));

		return errors;
	}

	private void annullaLoad(DatiMacchinaVO datiMacchinaVO, MacchinaVO macchinaVO, UtilizzoVO utilizzoVO, PossessoVO possessoVO, AnagAziendaVO anagAziendaVO, HttpServletRequest request) {
		HttpSession session = request.getSession(false);
		SolmrLogger.debug(this, "annullaLoad");
		possessoVO.setIdFormaPossesso(null);
		possessoVO.setExtIdAzienda(null);
		utilizzoVO.setDataCaricoDate(null);
		possessoVO.setDataScadenzaLeasingDate(null);
		possessoVO.setDataScadenzaLeasingDate(null);
		anagAziendaVO = null;

		if (session.getAttribute("common") != null) {
			HashMap vecSession = (HashMap) session.getAttribute("common");
			vecSession.put("PossessoVO", possessoVO);
			vecSession.put("UtilizzoVO", utilizzoVO);
			session.setAttribute("common", vecSession);
		}
	}

	private Date validateDateAfterToDay(String date, String name, String txtName, ValidationErrors errors, boolean required, boolean minToday) {
		Date valDate = null;
		if (!Validator.isNotEmpty(date)) {
			if (required) {
				errors.add(name, new ValidationError("Inserire la " + txtName));
			}
		} else {
			if (Validator.isDate(date)) {
				if (date.trim().length() != 10) {
					errors.add(name, new ValidationError("Inserire la data nel formato gg/mm/aaaa"));
				} else {
					try {
						valDate = validateDate(date);
					} catch (Exception e) {
						errors.add(name, new ValidationError("Data non valida"));
						return null;
					}
					Date toDay = new Date();
					SolmrLogger.debug(this, "toDay: " + toDay);
					SolmrLogger.debug(this, "minToday: " + minToday);
					SolmrLogger.debug(this, "valDate: " + valDate);
					SolmrLogger.debug(this, "toDay.after(valDate): " + toDay.after(valDate));
					if (minToday && toDay.after(valDate)) {
						SolmrLogger.debug(this, "if (minToday && toDayCal.after(valDate))");
						errors.add(name, new ValidationError("Non è possibile inserire una data anteriore a quella odierna"));
						valDate = null;
					}
				}
			} else {
				errors.add(name, new ValidationError("Data non valida"));
			}
		}
		return valDate;
	}

	// Metodi per la nuova gestione dei messaggi di errore	
	private static Date validateDate(String field) {
		String pattern = "dd/MM/yyyy";
		try {
			return customParseDate(field, pattern, "/");
		} catch (ParseException parseEx) {
			return null;
		}
	}

	private static Date customParseDate(String data, String pattern, String separator) throws ParseException {
		try {
			SimpleDateFormat dateFormatter = null;
			StringTokenizer st = new StringTokenizer(data, separator);
			while (st.hasMoreTokens()) {
				Integer.parseInt(st.nextToken());
			}

			dateFormatter = new SimpleDateFormat(pattern);
			dateFormatter.setLenient(false);
			return dateFormatter.parse(data);
		} catch (NumberFormatException exc) {
			throw new ParseException("La data deve avere campi numerici", 0);
		}
	}

	private ValidationErrors isTargaUnica(String numeroTarga, Long formatoTarga, ValidationErrors errors, UmaFacadeClient umaClient) throws SolmrException {
		final Long TARGA_UMA = new Long("1");
		final Long TARGA_STRADALE_RA = new Long("2");
		final Long TARGA_STRADALE_MA = new Long("3");
		final Long TARGA_MAO = new Long("4");
		TargaVO targaVO = null;
		Long idNumeroTarga = null;

		if (formatoTarga.longValue() == TARGA_UMA.longValue()) {
			SolmrLogger.debug(this, "if(formatoTarga.longValue() == TARGA_UMA.longValue())");
			targaVO = umaClient.findTargaByNumeroAndTipo(numeroTarga, TARGA_UMA);
			idNumeroTarga = targaVO.getIdNumeroTargaLong();
			if (idNumeroTarga != null) {
				errors.add("numeroTarga", new ValidationError("Targa UMA già assegnata"));
				return errors;
			}
		}

		if (formatoTarga.longValue() == TARGA_STRADALE_RA.longValue()) {
			SolmrLogger.debug(this, "if(formatoTarga.longValue() == TARGA_STRADALE_RA.longValue())");
			targaVO = umaClient.findTargaByNumeroAndTipo(numeroTarga, TARGA_STRADALE_RA);
			idNumeroTarga = targaVO.getIdNumeroTargaLong();
			if (idNumeroTarga != null) {
				errors.add("numeroTarga", new ValidationError("Targa STRADALE RA già assegnata"));
				return errors;
			}
		}

		if (formatoTarga.longValue() == TARGA_STRADALE_MA.longValue()) {
			SolmrLogger.debug(this, "if(formatoTarga.longValue() == TARGA_STRADALE_MA.longValue())");
			targaVO = umaClient.findTargaByNumeroAndTipo(numeroTarga, TARGA_STRADALE_MA);
			idNumeroTarga = targaVO.getIdNumeroTargaLong();
			if (idNumeroTarga != null) {
				errors.add("numeroTarga", new ValidationError("Targa STRADALE MA già assegnata"));
				return errors;
			}
		}

		if (formatoTarga.longValue() == TARGA_MAO.longValue()) {
			SolmrLogger.debug(this, "if(formatoTarga.longValue() == TARGA_MAO.longValue())");
			targaVO = umaClient.findTargaByNumeroAndTipo(numeroTarga, TARGA_MAO);
			idNumeroTarga = targaVO.getIdNumeroTargaLong();
			if (idNumeroTarga != null) {
				errors.add("numeroTarga", new ValidationError("Targa MAO già assegnata"));
				return errors;
			}
		}

		return errors;
	}

	/*private ValidationErrors isFormatoTargaValido(String numeroTarga, Long formatoTarga, ValidationErrors errors) {
		final Long TARGA_UMA = new Long("1");
		final Long TARGA_STRADALE_RA = new Long("2");
		final Long TARGA_STRADALE_MA = new Long("3");
		final Long TARGA_MAO = new Long("4");

		Targhe targaValidator = new Targhe();
		boolean targaValida = true;

		if (formatoTarga.longValue() == TARGA_UMA.longValue()) {
			SolmrLogger.debug(this, "formatoTarga.longValue().longValue() == TARGA_UMA");
			targaValida = targaValidator.isValidUMA(numeroTarga);
		}

		SolmrLogger.debug(this, "");
		if (formatoTarga.longValue() == TARGA_STRADALE_RA.longValue() || formatoTarga.longValue() == TARGA_STRADALE_MA.longValue() || formatoTarga.longValue() == TARGA_MAO.longValue()) {
			SolmrLogger.debug(this, "formatoTarga.longValue().longValue() == TARGA_STRADALE_RA,TARGA_STRADALE_MA,TARGA_MAO");
			targaValida = targaValidator.isValid(numeroTarga);
		}

		if (targaValida == false) {
			errors.add("numeroTarga", new ValidationError("" + SolmrConstants.get("FORMATO_TARGA_NON_VALIDA")));
		}

		return errors;
	}*/ %>