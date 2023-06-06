<%@ page language="java"
    contentType="text/html"
    isErrorPage="true"
%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%
    Vector verificaAssegnazione = (Vector)request.getAttribute("resultVerificaAssegnazione");
    String validateUrl = "/domass/view/assegnazioneBaseView.jsp";
    ValidationException valEx;
    Validator validator = new Validator(validateUrl);
    Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/domass/layout/assegnazioneBase.htm");
%><%@include file = "/include/menu.inc" %><%

    DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

    //IdDittaUma da inviare al calcolo automatico
    Long idDittaUma = (Long) request.getAttribute("idDittaUma");
    Long idDomAss = (Long) request.getAttribute("idDomAss");
    htmpl.set("idDittaUma", ""+idDittaUma);
    htmpl.set("idDomAss", ""+idDomAss);


    ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");
    if(verificaAssegnazione!=null){
      SolmrLogger.debug(this,"\\\\\\\\\\verificaAssegnazione!=null");
      if(verificaAssegnazione.size()>1){
        SolmrLogger.debug(this,"verificaAssegnazione.size()>1");
        SolmrLogger.debug(this,"verificaAssegnazione.elementAt(0): " + verificaAssegnazione.elementAt(0));
        if(verificaAssegnazione.elementAt(0).equals("0"))
          htmpl.newBlock("pulsanteDettaglio");
        else if(verificaAssegnazione.elementAt(0).equals("1"))
          htmpl.newBlock("pulsanteConferma");
        else{
          htmpl.newBlock("pulsanteAvanti");
          if(verificaAssegnazione.elementAt(0).equals("2"))
            htmpl.set("stato_dom_ass", "ATTESA_VALIDAZIONE");
          else
            htmpl.set("stato_dom_ass", "VALIDATA");
        }
        SolmrLogger.debug(this,"verificaAssegnazione.elementAt(1): " + verificaAssegnazione.elementAt(1));
        htmpl.set("messaggioRitorno",""+verificaAssegnazione.elementAt(1));
      }
    }
    else{
      HtmplUtil.setErrors(htmpl, errors, request);
      htmpl.set("messaggioRitorno","");
    }

    DatiModificatiIntermediarioVO dmiVO=(DatiModificatiIntermediarioVO)
        request.getAttribute("datiModificatiIntermediarioVO");
    if (ruoloUtenza.isUtenteProvinciale() || ruoloUtenza.isUtenteRegionale())
    {
      if (needToShow(dmiVO))
      {
        htmpl.newBlock("blkModificaIntermediario");
        if (dmiVO.getModificaDatiDitta().booleanValue())
        {
          SolmrLogger.debug(this,"1");
          htmpl.newBlock("blkModificaIntermediario.blkDatiDitta");
        }
        if (dmiVO.getModificaAnagrafica().booleanValue())
        {
          SolmrLogger.debug(this,"2");
          htmpl.newBlock("blkModificaIntermediario.blkAnagrafica");
        }
        if (dmiVO.getModificaRapprLegaleTitolare().booleanValue())
        {
          SolmrLogger.debug(this,"3");
          htmpl.newBlock("blkModificaIntermediario.blkRapprLegaleTitolare");
        }
        // Scrive solo se ci sono elementi nel vettore
        writeAllevamenti(dmiVO.getElencoAllevamenti(),htmpl);
        writeSerre(dmiVO.getElencoSerre(),htmpl);
        writeSuperficiColture(dmiVO.getElencoSuperfici(),htmpl);
      }
    }

    //20070111 - GUMA-22 Andrea: messaggi gestiti da PlSql: ho
    // commentato la riga sottostante
    //writeSuperficiNonConformi(dmiVO.getSuperficiNonConformi(),htmpl);

    //java.io.InputStream layout = application.getResourceAsStream("/domass/layout/assegnazioneBase.htm");
    //SolmrLogger.info(this, "Found layout: "+layout);

    it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);
    htmpl.set("annoCorrente",""+DateUtils.getCurrentYear());
    out.print(htmpl.text());
%>

<%!
  private boolean needToShow(DatiModificatiIntermediarioVO dmiVO)
  {
    return dmiVO!=null && (dmiVO.getModificaDatiDitta().booleanValue() ||
           dmiVO.getModificaAnagrafica().booleanValue() ||
           dmiVO.getModificaRapprLegaleTitolare().booleanValue() ||
           dmiVO.getElencoSuperfici().size()>0 ||
           dmiVO.getElencoAllevamenti().size()>0 ||
           dmiVO.getElencoSerre().size()>0);
  }
  private void writeAllevamenti(Vector elencoAllevamenti,Htmpl htmpl)
  {
    int size=elencoAllevamenti==null?0:elencoAllevamenti.size();
    for(int i=0;i<size;i++)
    {
      Vector datiAllevamento=(Vector) elencoAllevamenti.get(i);
      htmpl.newBlock("blkModificaIntermediario.blkAllevamento");
      htmpl.set("blkModificaIntermediario.blkAllevamento.quantita", formatNumber(datiAllevamento.get(1).toString()));
      htmpl.set("blkModificaIntermediario.blkAllevamento.descCategoriaAnimale", (String) datiAllevamento.get(2));
      htmpl.set("blkModificaIntermediario.blkAllevamento.unitaDiMisura", (String) datiAllevamento.get(3));
      htmpl.set("blkModificaIntermediario.blkAllevamento.descSpecieAnimale", (String) datiAllevamento.get(4));
    }
  }

  private void writeSerre(Vector elencoSerre,Htmpl htmpl)
  {
    int size=elencoSerre==null?0:elencoSerre.size();
    for(int i=0;i<size;i++)
    {
      Vector datiSerra=(Vector) elencoSerre.get(i);
      htmpl.newBlock("blkModificaIntermediario.blkSerra");
      htmpl.set("blkModificaIntermediario.blkSerra.volume", formatNumber(datiSerra.get(1).toString()));
      htmpl.set("blkModificaIntermediario.blkSerra.descColtura", (String)datiSerra.get(2));
    }
  }

  private void writeSuperficiColture(Vector elencoSuperfici,Htmpl htmpl)
  {
    int size=elencoSuperfici==null?0:elencoSuperfici.size();
    SolmrLogger.debug(this,"elencoSuperfici.size()="+size);
    for(int i=0;i<size;i++)
    {
      htmpl.newBlock("blkModificaIntermediario.blkSuperficie");
      SuperficieAziendaVO superficieVO=(SuperficieAziendaVO) elencoSuperfici.get(i);
      htmpl.set("blkModificaIntermediario.blkSuperficie.descSuperficie", superficieVO.getDenominazione());
      htmpl.set("blkModificaIntermediario.blkSuperficie.descTitoloPossesso", superficieVO.getTitoloPossesso());
      htmpl.set("blkModificaIntermediario.blkSuperficie.numEttari", formatNumber(superficieVO.getSuperficieUtilizzata()));
      Vector elencoColture=superficieVO.getColturePraticate();
      int jSize=elencoColture==null?0:elencoColture.size();
      for(int j=0;j<jSize;j++)
      {
        Vector colturaVect=(Vector)elencoColture.get(j);
        htmpl.newBlock("blkModificaIntermediario.blkSuperficie.blkColtura");
        htmpl.set("blkModificaIntermediario.blkSuperficie.blkColtura.descColtura", (String) colturaVect.get(0));
        htmpl.set("blkModificaIntermediario.blkSuperficie.blkColtura.superficieColtura", formatNumber((String) colturaVect.get(1)));
      }
    }
  }

  private String formatNumber(String str)
  {
    StringBuffer bf=new StringBuffer(str.startsWith(".")?"0":"");
    return bf.append(str.replace('.', ',')).toString();
  }
%>