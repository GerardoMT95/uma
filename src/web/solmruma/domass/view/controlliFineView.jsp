<%@ page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.uma.FrmControlliPraticaVO" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.DittaUMAAziendaVO" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  public static final String LAYOUT = "/domass/layout/controlli.htm";
  public static final String assegnazioneBaseUrl = "../layout/assegnazioneBase.htm";
  public static final String assegnazioneSupplementareUrl = "../layout/assegnazioneSupplementare.htm";
%>
<%
  SolmrLogger.info(this, " - controlliView.jsp - INIZIO PAGINA");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
    // A causa del fatto che questa pagina ha il menu della assegnazione base
    // ma è inserita nel CU del dettaglio azienda (che è di pertinenza di un
    // altro menu) viene cambiata al volo la classe Autorizzazione per
    // permettere l'utilizzo del gestore di menu corretto.
    it.csi.solmr.presentation.security.Autorizzazione autAssegnazioneBase=
    (it.csi.solmr.presentation.security.Autorizzazione)
    it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ASSEGNAZIONE_BASE");
    request.setAttribute("__autorizzazione",autAssegnazioneBase);
%><%@include file = "/include/menu.inc" %><%  htmpl.setStringProcessor(null);

  Hashtable common = (Hashtable) session.getAttribute("common");
  Long idDomAss = (Long) common.get("idDomandaAssegnazione");
  SolmrLogger.debug(this, "\n\n\n/--//--//--//--//--//--//--//--//--/\n\n\n");
  SolmrLogger.debug(this, "idDomAss: "+idDomAss);
  htmpl.set("idDomAss", ""+idDomAss);

  SolmrLogger.debug(this, "common: "+common);
  String notifica = (String) common.get("notifica");
  SolmrLogger.debug(this, "notifica: "+notifica);

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
  Vector vErroriControlli = null;

  vErroriControlli = (Vector) request.getAttribute("vErroriControlli");

  SolmrLogger.debug(this, "vErroriControlli: " + vErroriControlli);
  if (vErroriControlli == null || vErroriControlli.size() == 0)
  {
    SolmrLogger.debug(this, "if (vErroriControlli == null || vErroriControlli.size() == 0)");
    htmpl.newBlock("blkNoControlli");
  }
  else
  {
    SolmrLogger.debug(this, "else (vErroriControlli == null || vErroriControlli.size() == 0)");

    String lastGruppoControllo = "";
    FrmControlliPraticaVO frmControlliPraticaVO = null;

    Boolean flagBloccante = new Boolean(false);
    for (int i=0 ; i<vErroriControlli.size(); i++)
    {
      frmControlliPraticaVO = (FrmControlliPraticaVO) vErroriControlli.get(i);

      //Se il gruppo controllo è diverso da quello precedente devo inserire l'intestazione
      if (! frmControlliPraticaVO.getDescGruppoControllo().equals(lastGruppoControllo))
      {
        htmpl.newBlock("blkGruppoControllo");
        htmpl.set("blkGruppoControllo.gruppoControllo", frmControlliPraticaVO.getDescGruppoControllo());

        lastGruppoControllo = frmControlliPraticaVO.getDescGruppoControllo();
      }

      htmpl.newBlock("blkGruppoControllo.blkControllo");
      htmpl.set("blkGruppoControllo.blkControllo.controllo", frmControlliPraticaVO.getDescControllo());

      //if (praticaVO.getDataControlloDate() == null) {
      SolmrLogger.debug(this,"\n\n\n\n\n#####################################");
      SolmrLogger.debug(this,"frmControlliPraticaVO.getDescMessaggioErrore(): "+
                        frmControlliPraticaVO.getDescMessaggioErrore());
      SolmrLogger.debug(this,"#####################################\n\n\n\n\n");
      if (false) {
        SolmrLogger.debug(this,"***** DATA NULL");

        //controlli mai eseguiti
        htmpl.set("blkGruppoControllo.blkControllo.errore", "&nbsp;");
      }
      else {

        if(frmControlliPraticaVO.getDescMessaggioErrore()!=null
           &&
           !frmControlliPraticaVO.getDescMessaggioErrore().equalsIgnoreCase(""))
        {
          //htmpl.set("blkGruppoControllo.blkControllo.errore", frmControlliPraticaVO.getDescMessaggioErrore());
           htmpl.set("blkGruppoControllo.blkControllo.errore", frmControlliPraticaVO.getDescMessaggioErrore(),null);
        }
        else{
          htmpl.set("blkGruppoControllo.blkControllo.errore", "&nbsp;");
        }

        //Se esiste un errore riscontrato in controlli pratica viene fatta la distinzione
        //se bloccante oppure non bloccante

        if (frmControlliPraticaVO.getDescMessaggioErrore() == null)
        {
          htmpl.newBlock("blkGruppoControllo.blkControllo.blkNoErrore");
          htmpl.set("blkGruppoControllo.blkControllo.blkNoErrore.linkErrore",SolmrConstants.LINK_IMG_CONTROLLI + SolmrConstants.NAME_IMG_CONTROLLI_OK);
         }
        else
        {
          if (frmControlliPraticaVO.isBloccante())
          {
            flagBloccante = new Boolean(true);
            htmpl.newBlock("blkGruppoControllo.blkControllo.blkErroreBloccante");
            //htmpl.set("blkGruppoControllo.blkControllo.blkErroreBloccante.linkErrore",SolmrConstants.LINK_IMG_CONTROLLI + SolmrConstants.NAME_IMG_CONTROLLI_BLOCCANTE);
            htmpl.set("blkGruppoControllo.blkControllo.blkErroreBloccante.linkErrore",SolmrConstants.LINK_IMG_CONTROLLI + SolmrConstants.NAME_IMG_CONTROLLI_BLOCCANTE,null);
          }
          else
          {
            htmpl.newBlock("blkGruppoControllo.blkControllo.blkErroreNonBloccante");
            //htmpl.set("blkGruppoControllo.blkControllo.blkErroreNonBloccante.linkErrore",SolmrConstants.LINK_IMG_CONTROLLI + SolmrConstants.NAME_IMG_CONTROLLI_WARNING);
            htmpl.set("blkGruppoControllo.blkControllo.blkErroreNonBloccante.linkErrore",SolmrConstants.LINK_IMG_CONTROLLI + SolmrConstants.NAME_IMG_CONTROLLI_WARNING,null);
          }
        }
      }
    }

    //Data controllo
    //if (praticaVO.getDataControlloDate() == null)
    /*if (false)
    {
      htmpl.newBlock("blkNoDataControllo");
    }
    else
    {
      htmpl.newBlock("blkDataControllo");
      //htmpl.set("blkDataControllo.dataControllo", formatFullDate(praticaVO.getDataControlloDate()));
    }*/

    //Abilitazioni utente e pratica in stato "In bozza" o "Respinto"
    if (notifica != null)
    {
      SolmrLogger.debug(this, "if (notifica != null)");

      if(flagBloccante.booleanValue() == false){
        SolmrLogger.debug(this, "if(flagBloccante.booleanValue() == false)");

        htmpl.newBlock("blkAbilitazioni");
        if (notifica.equalsIgnoreCase("base")){
          SolmrLogger.debug(this, "if (notifica.equalsIgnoreCase(\"base\"))");
          htmpl.set("blkAbilitazioni.ConfermaUrl", assegnazioneBaseUrl);
        }
        else{         
          if ( (notifica.equalsIgnoreCase("supplementare")) || (notifica.equalsIgnoreCase("supplementareMaggiorazione"))){
            htmpl.set("blkAbilitazioni.ConfermaUrl", assegnazioneSupplementareUrl);
          }         
        }

      }
    }
    else
    {
      SolmrLogger.debug(this, " -- notifica = null");
      htmpl.newBlock("blkNoAbilitazioni");
    }
  }

  HtmplUtil.setErrors(htmpl, errors, request);

  SolmrLogger.info(this, " - controlliView.jsp - FINE PAGINA");
%>
<%= htmpl.text()%>
<%!
/** @todo riportare questo metodo nel DateUtils di tutte le librerie */
public static String formatFullDate(Date date)
{
  if (date == null)
    return "";

  Calendar cal = Calendar.getInstance(TimeZone.getDefault());
  cal.setTime(date);
  String day = ""+cal.get(Calendar.DAY_OF_MONTH);
  String month = ""+(cal.get(Calendar.MONTH)+1);
  String year = ""+cal.get(Calendar.YEAR);
  String hour = "" + cal.get(Calendar.HOUR_OF_DAY);
  hour = hour.length()==1?"0"+hour:hour;
  String minute = "" + cal.get(Calendar.MINUTE);
  minute = minute.length()==1?"0"+minute:minute;
  String second = "" + cal.get(Calendar.SECOND);
  second = second.length()==1?"0"+second:second;
  if(day.length()==1)
    day="0"+day;
  if(month.length()==1)
    month="0"+month;
  String returnDate;
  try{
    returnDate = day+"/"+month+"/"+year + " " + hour + "." + minute + "." + second;
  }catch(Exception ex){
    returnDate="";
  }
  return returnDate;
}
%>
