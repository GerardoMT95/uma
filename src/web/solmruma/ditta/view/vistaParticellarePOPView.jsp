<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="it.csi.solmr.dto.anag.ParticellaVO" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="it.csi.solmr.exception.services.InvalidParameterException" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%
  SolmrLogger.debug(this,"   BEGIN vistaParticellarePOPView");
  Htmpl htmpl = null;
  try
  {
    htmpl = HtmplFactory.getInstance(application)
                  .getHtmpl("ditta/layout/vistaParticellarePOP.htm");
    UmaFacadeClient umaClient = new UmaFacadeClient();
    
    DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
    StringTokenizer st = new StringTokenizer(request.getParameter("idSuperficie"), "|");
    String istatComune = st.nextToken();
    String idTitoloPossesso = st.nextToken();
    String dataInizioValidita = st.nextToken();
    String flagColturaSecondaria = st.nextToken();
    SolmrLogger.debug(this, "-- flagColturaSecondaria ="+flagColturaSecondaria);
    String dataFineValidita = "";
    if(st.hasMoreElements())
      dataFineValidita = st.nextToken();
    
    Vector<ParticellaColturaVO> particelle = umaClient.vistaParticellare(dittaUMAAziendaVO.getIdDittaUMA(), istatComune, new Long(idTitoloPossesso), 
      dataInizioValidita, dataFineValidita, flagColturaSecondaria);

    int size=particelle.size();

    if (size>0)
    {
      Vector<Long> exIdStoricoParticella=new Vector<Long>();
      /**
       * Per prima cosa scorro il vettore per avere tutti gli idParticella
       * da passare al servizio
       */
      for (int i=0;i<size;i++)
      {
        ParticellaColturaVO particellaColturaVO=(ParticellaColturaVO)particelle.get(i);
        exIdStoricoParticella.add(particellaColturaVO.getExIdStoricoParticella());
      }
      Long exIdStoricoParticellaLong[]= (Long[])exIdStoricoParticella.toArray(new Long[0]);
      DecimalFormat numericFormat4 = new DecimalFormat(SolmrConstants.FORMATO_NUMERIC_1INT_4DEC);
      String supUtilizzata;
      htmpl.newBlock("blkParticelle");
      //Recupero i dati da anagrafe
      ParticellaVO[] particellaVO=umaClient.serviceGetStoricoParticellaByIdRange(exIdStoricoParticellaLong);
      String dataConsistenza=null;
      for (int i=0;i<particellaVO.length;i++)
      {
        for (int j=0;j<size;j++)
        {
          ParticellaColturaVO particellaColturaVO=(ParticellaColturaVO)particelle.get(j);
          if (particellaVO[i].getIdStoricoParticella().longValue()==particellaColturaVO.getExIdStoricoParticella().longValue())
          {
            htmpl.newBlock("blkParticelle.blkParticella");
            htmpl.set("blkParticelle.blkParticella.descComuneParticella",particellaVO[i].getDescComuneParticella());
            htmpl.set("blkParticelle.blkParticella.sezione",particellaVO[i].getSezione());
            try
            {
              htmpl.set("blkParticelle.blkParticella.foglio",particellaVO[i].getFoglio().toString());
            }
            catch(Exception e)
            {
              htmpl.set("blkParticelle.blkParticella.foglio","");
            }
            try
            {
              htmpl.set("blkParticelle.blkParticella.particella",particellaVO[i].getParticella().toString());
            }
            catch(Exception e)
            {
              htmpl.set("blkParticelle.blkParticella.particella","");
            }

            htmpl.set("blkParticelle.blkParticella.subalterno",particellaVO[i].getSubalterno());
            try
            {
              supUtilizzata = numericFormat4.format(Double.parseDouble(particellaVO[i].getSupCatastale()));
            }
            catch(Exception e)
            {
              supUtilizzata="-";
            }
            htmpl.set("blkParticelle.blkParticella.supUtilizzata",supUtilizzata);

            htmpl.set("blkParticelle.blkParticella.titoloPossesso",particellaColturaVO.getTitoloPossesso());
            htmpl.set("blkParticelle.blkParticella.usoPrimario",particellaColturaVO.getUsoPrimario());
            
            String flagColturaSec = particellaColturaVO.getFlagColturaSecondaria();
            SolmrLogger.debug(this, "-- FlagColturaSecondaria ="+flagColturaSec);
            if(flagColturaSec != null && flagColturaSec.equalsIgnoreCase("S"))
              flagColturaSec = "SI";
            else
              flagColturaSec = "";  
            htmpl.set("blkParticelle.blkParticella.colturaSecondaria",flagColturaSec);
            
            
                
            htmpl.set("blkParticelle.blkParticella.flagIrrigabile",particellaColturaVO.getflagIrrigabile()); // Nick 06-02-2009               

            if (particellaColturaVO.getExtIdConsistenza()!=null && !"".equals(particellaColturaVO.getExtIdConsistenza()))
              dataConsistenza= particellaColturaVO.getDataConsistenza();
            try
            {
              supUtilizzata = numericFormat4.format(particellaColturaVO.getSupUtilizzataPrimaria());

            }
            catch(Exception e)
            {
              supUtilizzata="-";
            }
            htmpl.set("blkParticelle.blkParticella.supUtilizzataPrimaria",supUtilizzata);
            
            htmpl.set("blkParticelle.blkParticella.cuaaSocio", particellaColturaVO.getCuaaSocio());            
            htmpl.set("blkParticelle.blkParticella.pivaSocio", particellaColturaVO.getPivaSocio()); 
            htmpl.set("blkParticelle.blkParticella.denomSocio", particellaColturaVO.getDenomSocio()); 
            String sedeLegale = "";
            if(Validator.isNotEmpty(particellaColturaVO.getCuaaSocio()))
            {
              sedeLegale = particellaColturaVO.getSedeLegaleIndirizzoSocio()+" - "+
                 particellaColturaVO.getSedeLegaleComuneSocio()+" ("+
                 particellaColturaVO.getSedeLegaleProvinciaSocio()+")";
            }
            htmpl.set("blkParticelle.blkParticella.sedeLegaleSocio", sedeLegale); 
          }
        }
      }
      if (dataConsistenza!=null)
      {
        htmpl.newBlock("blkDichiarazioneConsistenza");
        htmpl.set("blkDichiarazioneConsistenza.dataConsistenza",dataConsistenza);
      }
    }
    else
    {
      htmpl.newBlock("blkNoParticelle");
      htmpl.set("blkNoParticelle.msg",(String)SolmrConstants.get("MSG_NO_PARTICELLE_DIHIARATE"));
    }

  }
  catch(InvalidParameterException e)
  {
    e.printStackTrace();
    ValidationErrors errors=new ValidationErrors();
    errors.add("error",new ValidationError(e.getMessage()));
    HtmplUtil.setErrors(htmpl, errors, request);
  }
  catch(SolmrException e)
  {
    e.printStackTrace();
    ValidationErrors errors=new ValidationErrors();
    errors.add("error",new ValidationError(e.getMessage()));
    HtmplUtil.setErrors(htmpl, errors, request);
  }
  catch(Exception e)
  {
    e.printStackTrace();
    ValidationErrors errors=new ValidationErrors();
    errors.add("error",new ValidationError((String)SolmrErrors.get("GENERIC_SYSTEM_EXCEPTION")));
    HtmplUtil.setErrors(htmpl, errors, request);
  }

  it.csi.solmr.presentation.security.Autorizzazione aut=
  (it.csi.solmr.presentation.security.Autorizzazione)
  it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ACCESSO_SISTEMA");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  aut.writeBanner(htmpl,ruoloUtenza,request);

  SolmrLogger.debug(this,"   END vistaParticellarePOPView");
  out.print(htmpl.text());
%>
