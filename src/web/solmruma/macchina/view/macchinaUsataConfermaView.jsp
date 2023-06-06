<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>



<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.jsf.htmpl.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%!

  public static final String ELENCO="../layout/elencoMacchine.htm";

  public static final String ELENCO_BIS="../layout/elencoMacchineBis.htm";

  public static final String DETTAGLIO_MACCHINA="../layout/dettaglioMacchinaDittaDati.htm";

  private static final String ACQUISTA_MACCHINA="../layout/macchinaUsataTarga.htm";

%>



<%

  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("macchina/layout/MacchinaUsataConferma.htm");
%><%@include file = "/include/menu.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  SolmrLogger.debug(this,"dittaUMAAziendaVO.getProvUMA()="+dittaUMAAziendaVO.getProvUMA());

  SolmrLogger.debug(this,"dittaUMAAziendaVO.getProvCompetenza()="+dittaUMAAziendaVO.getProvCompetenza());

  SolmrLogger.debug(this,"dittaUMAAziendaVO.getProvUMADomAss()="+dittaUMAAziendaVO.getProvUMADomAss());



  MovimentiTargaVO movimentiTargaVO= null;

  Modello49VO modello49VO=null;

  if (session.getAttribute("common")!=null)

  {

    if (session.getAttribute("common") instanceof MovimentiTargaVO)

    {

      movimentiTargaVO=(MovimentiTargaVO) session.getAttribute("common");

      //Modifica Attestazione Proprietà da macchina nuova - Begin

      Long idMacchina = new Long(movimentiTargaVO.getIdMacchina());

      if( idMacchina!=null ){

        htmpl.set("idMacchina",""+idMacchina);

      }

      //Modifica Attestazione Proprietà da macchina nuova - End

      if (movimentiTargaVO.getAnnoModello()!=null || movimentiTargaVO.getNumeroModello()!=null)

      {

        modello49VO=new Modello49VO();

        modello49VO.setAnnoModello49(movimentiTargaVO.getAnnoModello());

        modello49VO.setNumeroModello49(movimentiTargaVO.getNumeroModello());

      }

    }

    else

    {

      if (session.getAttribute("common") instanceof Modello49VO)

      {

        modello49VO=(Modello49VO)session.getAttribute("common");

        //Modifica Attestazione Proprietà da macchina nuova - Begin

        Long idMacchina = new Long(modello49VO.getIdMacchina());

        if( idMacchina!=null ){

          htmpl.set("idMacchina",""+idMacchina);

        }

        //Modifica Attestazione Proprietà da macchina nuova - End

      }

      else

      {

        if (session.getAttribute("common") instanceof Long)

        {

          //Modifica Attestazione Proprietà da macchina nuova - Begin

          Long idMacchina = (Long) session.getAttribute("common");

          if( idMacchina!=null ){

            htmpl.set("idMacchina",""+idMacchina);

          }

          //Modifica Attestazione Proprietà da macchina nuova - End

        }

        else

        {

          session.removeAttribute("common");

          response.sendRedirect(ACQUISTA_MACCHINA);

          return;

        }

      }

    }

  }

  if (movimentiTargaVO==null)

  {

    htmpl.newBlock("blkSenzaImmatricolazione");

  }

  else

  {

    htmpl.newBlock("blkImmatricolazione");

  }



  if (movimentiTargaVO!=null || modello49VO!=null)

  {

    htmpl.newBlock("blkTabella");

    if (movimentiTargaVO!=null)

    {

      htmpl.newBlock("blkTabella.blkDatiImmatricolazione");

    }

    if (modello49VO!=null)

    {

      htmpl.newBlock("blkTabella.blkModello49");

    }

  }

  if (movimentiTargaVO!=null)

  {

    //Modifica Attestazione Proprietà da macchina nuova - Begin

    Long idMacchina = new Long(movimentiTargaVO.getIdMacchina());

    if( idMacchina!=null ){

      htmpl.set("idMacchina",""+idMacchina);

    }

    //Modifica Attestazione Proprietà da macchina nuova - End



    TargaVO targaVO=movimentiTargaVO.getDatiTarga()==null?new TargaVO():movimentiTargaVO.getDatiTarga();

    if (targaVO.getPrimoNumeroDisponibile()==null || targaVO.getPrimoNumeroDisponibile().equals(targaVO.getUltimoNumeroDisponibile()))

    {

      htmpl.newBlock("blkUtlimoNumero");

    }

    htmpl.set("blkTabella.blkDatiImmatricolazione.descProvinciaUma",dittaUMAAziendaVO.getDescProvinciaUma());

    if (SolmrConstants.TARGA_STRADALE_MA.equals(targaVO.getIdTarga()) || SolmrConstants.TARGA_STRADALE_RA.equals(targaVO.getIdTarga()) || SolmrConstants.TARGA_MAO.equals(targaVO.getIdTarga()))

    {

      htmpl.set("blkTabella.blkDatiImmatricolazione.tipoTarga","Stradale");

    }

    else

    {

      htmpl.set("blkTabella.blkDatiImmatricolazione.tipoTarga","UMA");

    }

    htmpl.set("blkTabella.blkDatiImmatricolazione.dataInizioValidita",DateUtils.formatDate(new Date()));

    SolmrLogger.debug(this,"targaVO.getNumeroTarga()="+targaVO.getNumeroTarga());

    htmpl.set("blkTabella.blkDatiImmatricolazione.numeroTarga",targaVO.getNumeroTarga());

  }

  if (modello49VO!=null)

  {

    htmpl.set("blkTabella.blkModello49.annoModello49",modello49VO.getAnnoModello49());

    htmpl.set("blkTabella.blkModello49.numeroModello49",modello49VO.getNumeroModello49());

  }

  /*if (session.getAttribute("pageFrom")==null)

  {

    htmpl.set("action",ELENCO);

  }

  else

  {

    htmpl.set("action",ELENCO_BIS);

  }*/

  htmpl.set("action", DETTAGLIO_MACCHINA);

  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

  out.print(htmpl.text());

%>

