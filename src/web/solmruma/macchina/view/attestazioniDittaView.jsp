<%@
  page language="java"
  contentType="text/html"
  isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  SolmrLogger.debug(this,"- attestazioniDittaView.jsp -  INIZIO PAGINA");

  java.io.InputStream layout = application.getResourceAsStream("/macchina/layout/dettaglioMacchinaDittaComproprietari.htm");

  Htmpl htmpl = new Htmpl(layout);
%><%@include file = "/include/menu.inc" %><%

  Vector v_attestazioni = (Vector)session.getAttribute("v_attestazioni");

  MacchinaVO macchinaVO = null;

  if(session.getAttribute("common") instanceof MacchinaVO){

    SolmrLogger.debug(this,"Instance of MacchinaVO");

    macchinaVO = (MacchinaVO)session.getAttribute("common");

  }



  if(macchinaVO != null)

    htmpl.set("idMacchina", macchinaVO.getIdMacchina());

  DittaUMAAziendaVO dittaVO = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");


  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  HtmplUtil.setErrors(htmpl, errors, request);

  // Dati ditta Uma

  if(dittaVO.getCuaa()!=null&&!dittaVO.getCuaa().equals(""))

    htmpl.set("CUAA",dittaVO.getCuaa()+" - ");

  htmpl.set("denominazione",dittaVO.getDenominazione());

  htmpl.set("dittaUMA",dittaVO.getDittaUMAstr());

  htmpl.set("umaTipoDitta",dittaVO.getTipiDitta());

  htmpl.set("provincia", dittaVO.getDescProvinciaUma());

  // Dati identificativi del veicolo

  it.csi.solmr.presentation.security.AutorizzazioneMacchine.writeDatiMacchina(htmpl, macchinaVO);

  SolmrLogger.debug(this,"\n\n\n\n\n*-*-*-*-*-*-*-*-*--*-*-*-*-LinkStampe1l");

  SolmrLogger.debug(this,"\n\n\n\n\n*-*-*-*-*-*-*-*-*--*-*-*-*-LinkStampe2l");

  // Dati attestazioni

  AttestatoProprietaVO attestatoVO = null;

  if((ruoloUtenza.isUtenteProvinciale() 
		  || ruoloUtenza.isUtenteRegionale()
		  )
		  && ruoloUtenza.isReadWrite()
		 // && ruoloUtenza.getIstatProvincia().equals(dittaVO.getProvUMA())
	)

      htmpl.newBlock("blkInserisci");

  if(v_attestazioni!=null && v_attestazioni.size()!=0){

    htmpl.newBlock("blkDettaglio");

    //Correzzione Link Stampe

    //if(profile.isUtenteProvinciale())

    //  htmpl.newBlock("blk72");

    htmpl.newBlock("blkProprieta");

    Iterator iter = v_attestazioni.iterator();

    int i = 0;

    //050624 - Calcolo attestato con anno maggiore - Begin
    long idAttestatoPropMax = 0;
    long annoMax = 0;
    while(iter.hasNext()){
      attestatoVO = (AttestatoProprietaVO)iter.next();
      SolmrLogger.debug(this, "\n\n\n\n--##--##--##--##--##--##--##--##");
      SolmrLogger.debug(this, "attestatoVO.getAnnoLong().longValue(): "+attestatoVO.getAnnoLong().longValue());
      SolmrLogger.debug(this, "annoMax: "+annoMax);
      if(attestatoVO.getAnnoLong().longValue() >= annoMax){
        SolmrLogger.debug(this, "if(attestatoVO.getAnnoLong().longValue() >= annoMax)");
        SolmrLogger.debug(this, "@@@@@attestatoVO.getAnnoLong().longValue(): "+attestatoVO.getAnnoLong().longValue());
        annoMax = attestatoVO.getAnnoLong().longValue();
        idAttestatoPropMax = attestatoVO.getIdAttestatoProprietaLong().longValue();
      }
      SolmrLogger.debug(this, "--##--##--##--##--##--##--##--##\n\n\n\n");
    }
    iter = v_attestazioni.iterator();
    //050624 - Calcolo attestato con anno maggiore - End

    while(iter.hasNext()){

      attestatoVO = (AttestatoProprietaVO)iter.next();

      htmpl.newBlock("blkProprieta.blkRigaProprieta");

      //050624 - Calcolo attestato con anno maggiore - Begin
      SolmrLogger.debug(this, "\n\n\n\n--##--##--##--##--##--##--##--##");
      SolmrLogger.debug(this, "idAttestatoPropMax: "+idAttestatoPropMax);
      SolmrLogger.debug(this, "attestatoVO.getIdAttestatoProprietaLong().longValue(): "+attestatoVO.getIdAttestatoProprietaLong().longValue());
      if(idAttestatoPropMax == attestatoVO.getIdAttestatoProprietaLong().longValue()){
        SolmrLogger.debug(this, "if(idAttestatoPropMax == attestatoVO.getIdAttestatoProprietaLong().longValue())");
        htmpl.set("blkProprieta.blkRigaProprieta.checked", "checked");
      }
      SolmrLogger.debug(this, "--##--##--##--##--##--##--##--##\n\n\n\n");
      //050624 - Calcolo attestato con anno maggiore - End

      /*if(i==0)
        htmpl.set("blkProprieta.blkRigaProprieta.checked", "checked");*/

      i++;

      htmpl.set("blkProprieta.blkRigaProprieta.idAttestazione", StringUtils.checkNull(attestatoVO.getIdAttestatoProprieta()));

      htmpl.set("blkProprieta.blkRigaProprieta.prov", StringUtils.checkNull(attestatoVO.getSiglaProv()));

      htmpl.set("blkProprieta.blkRigaProprieta.anno", StringUtils.checkNull(attestatoVO.getAnno()));

      htmpl.set("blkProprieta.blkRigaProprieta.numero", StringUtils.checkNull(attestatoVO.getNumeroModello72()));

      htmpl.set("blkProprieta.blkRigaProprieta.data", StringUtils.checkNull(attestatoVO.getDataAttestazione()));

    }

  }

  SolmrLogger.debug(this,"- attestazioniDittaView.jsp -  FINE PAGINA");

%>

<%= htmpl.text()%>