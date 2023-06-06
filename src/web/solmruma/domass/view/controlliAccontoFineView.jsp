<%@ page language="java" contentType="text/html" isErrorPage="true"%><%@ page
	import="it.csi.jsf.htmpl.*"%>
<%@page import="it.csi.solmr.util.HtmplUtil"%>
<%@page import="it.csi.solmr.etc.SolmrConstants"%>
<%@page import="java.util.Vector"%>
<%@page import="it.csi.solmr.dto.uma.FrmControlliPraticaVO"%>
<%@page import="it.csi.solmr.util.ValidationErrors"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>
<%@ page import="it.csi.solmr.util.SolmrLogger" %>
<%@page import="it.csi.solmr.dto.uma.DomandaAssegnazione"%><%!public static final String LAYOUT          = "/domass/layout/controlli.htm";
  public static final String ACCONTO_URL     = "../layout/verificaAssegnazioneAccontoConsumi.htm";
  public static final String VALIDAZIONE_URL = "../layout/verificaAssegnazioneAccontoValida.htm";%>
<%
  SolmrLogger.debug(this, " - controlliAccontoView.jsp - INIZIO PAGINA");

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file="/include/menu.inc"%>
<%
  Vector vErroriControlli = null;
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  vErroriControlli = (Vector) request.getAttribute("vErroriControlli");

  SolmrLogger.debug(this, "vErroriControlli: " + vErroriControlli);
  boolean flagBloccante = false;
  if (vErroriControlli == null || vErroriControlli.size() == 0)
  {
    SolmrLogger.debug(this,
        "[controlliAccontoFine::service] Nessun errore rilevato");
    htmpl.newBlock("blkNoControlli");
  }
  else
  {
    SolmrLogger.debug(this,
        "[controlliAccontoFine::service] Errori/Warning rilevati");

    String lastGruppoControllo = "";
    FrmControlliPraticaVO frmControlliPraticaVO = null;

    for (int i = 0; i < vErroriControlli.size(); i++)
    {
      frmControlliPraticaVO = (FrmControlliPraticaVO) vErroriControlli
          .get(i);

      //Se il gruppo controllo è diverso da quello precedente devo inserire l'intestazione
      if (!frmControlliPraticaVO.getDescGruppoControllo().equals(
          lastGruppoControllo))
      {
        htmpl.newBlock("blkGruppoControllo");
        htmpl.set("blkGruppoControllo.gruppoControllo",
            frmControlliPraticaVO.getDescGruppoControllo());

        lastGruppoControllo = frmControlliPraticaVO
            .getDescGruppoControllo();
      }

      htmpl.newBlock("blkGruppoControllo.blkControllo");
      htmpl.set("blkGruppoControllo.blkControllo.controllo",
          frmControlliPraticaVO.getDescControllo());

      if (false)
      {
        htmpl.set("blkGruppoControllo.blkControllo.errore", "&nbsp;");
      }
      else
      {

        if (frmControlliPraticaVO.getDescMessaggioErrore() != null
            && !frmControlliPraticaVO.getDescMessaggioErrore()
                .equalsIgnoreCase(""))
        {
          //htmpl.set("blkGruppoControllo.blkControllo.errore", frmControlliPraticaVO.getDescMessaggioErrore());
          htmpl.set("blkGruppoControllo.blkControllo.errore",
              frmControlliPraticaVO.getDescMessaggioErrore(), null);
        }
        else
        {
          htmpl.set("blkGruppoControllo.blkControllo.errore", "&nbsp;");
        }

        //Se esiste un errore riscontrato in controlli pratica viene fatta la distinzione
        //se bloccante oppure non bloccante

        if (frmControlliPraticaVO.getDescMessaggioErrore() == null)
        {
          htmpl.newBlock("blkGruppoControllo.blkControllo.blkNoErrore");
          //htmpl.set("blkGruppoControllo.blkControllo.blkNoErrore.linkErrore",SolmrConstants.LINK_IMG_CONTROLLI + SolmrConstants.NAME_IMG_CONTROLLI_OK);
          htmpl.set(
              "blkGruppoControllo.blkControllo.blkNoErrore.linkErrore",
              SolmrConstants.LINK_IMG_CONTROLLI
                  + SolmrConstants.NAME_IMG_CONTROLLI_OK, null);
        }
        else
        {
          if (frmControlliPraticaVO.isBloccante())
          {
            flagBloccante = true;
            htmpl
                .newBlock("blkGruppoControllo.blkControllo.blkErroreBloccante");
            //htmpl.set("blkGruppoControllo.blkControllo.blkErroreBloccante.linkErrore",SolmrConstants.LINK_IMG_CONTROLLI + SolmrConstants.NAME_IMG_CONTROLLI_BLOCCANTE);
            htmpl
                .set(
                    "blkGruppoControllo.blkControllo.blkErroreBloccante.linkErrore",
                    SolmrConstants.LINK_IMG_CONTROLLI
                        + SolmrConstants.NAME_IMG_CONTROLLI_BLOCCANTE, null);
          }
          else
          {
            htmpl
                .newBlock("blkGruppoControllo.blkControllo.blkErroreNonBloccante");
            //htmpl.set("blkGruppoControllo.blkControllo.blkErroreNonBloccante.linkErrore",SolmrConstants.LINK_IMG_CONTROLLI + SolmrConstants.NAME_IMG_CONTROLLI_WARNING);
            htmpl
                .set(
                    "blkGruppoControllo.blkControllo.blkErroreNonBloccante.linkErrore",
                    SolmrConstants.LINK_IMG_CONTROLLI
                        + SolmrConstants.NAME_IMG_CONTROLLI_WARNING, null);
          }
        }
      }
    }

    //Abilitazioni utente e pratica in stato "In bozza" o "Respinto"
    if (!flagBloccante)
    {
      htmpl.newBlock("blkAbilitazioni");
      DomandaAssegnazione accontoVO = (DomandaAssegnazione) request
          .getAttribute("accontoVO");
      //Gestione della presenza di un acconto per valutare se la domanda
      // è in stato trasmessa, o da creare
      if (accontoVO!=null && accontoVO.getIdStatoDomanda().toString().equals(
          SolmrConstants.ID_STATO_DOMANDA_ATTESA_VAL_PA))
      {
        htmpl.set("blkAbilitazioni.ConfermaUrl", VALIDAZIONE_URL);
      }
      else
      {
        htmpl.set("blkAbilitazioni.ConfermaUrl", ACCONTO_URL);
      }
    }
  }

  HtmplUtil.setErrors(htmpl, (ValidationErrors) request
      .getAttribute("errors"), request);

  SolmrLogger.info(this, " - controlliView.jsp - FINE PAGINA");
%><%=htmpl.text()%>
<%
  SolmrLogger.debug(this, " - controlliAccontoView.jsp - FINE PAGINA");
%>
