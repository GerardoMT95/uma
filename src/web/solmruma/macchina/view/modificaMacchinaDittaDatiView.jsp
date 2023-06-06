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
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%!

  public static final String LAYOUT="/macchina/layout/ModificaMacchinaDittaDati.htm";

%>

<%

  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file = "/include/menu.inc" %><%



  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  MacchinaVO mavo = (MacchinaVO)session.getAttribute("common");

  Long idMacchina=mavo.getIdMacchinaLong();

  DatiMacchinaVO dmvo = mavo.getDatiMacchinaVO();

  TargaVO tvo = mavo.getTargaCorrente();

  MatriceVO mvo = mavo.getMatriceVO();



  DecimalFormat numericFormat2 = new DecimalFormat(SolmrConstants.FORMATO_NUMERIC_1INT_2DEC);



//  SolmrLogger.debug(this,"#################   "+dmvo.getDescGenereMacchina()+"   #################");



  if (mavo==null)

  {

    SolmrLogger.debug(this,"mavo==null");

    mavo=new MacchinaVO(); // Evito nullpointerexception

  }

  if (tvo==null)

  {

    SolmrLogger.debug(this,"tvo==null");

    tvo=new TargaVO(); // Evito nullpointerexception

    tvo.setNumeroTarga("");

    tvo.setDescrizioneTipoTarga("");

  }

  if (mvo==null)

  {

    SolmrLogger.debug(this,"mvo==null");

    mvo=new MatriceVO(); // Evito nullpointerexception

  }



  SolmrLogger.debug(this,"--------------------------- mvo.getCodBreveGenereMacchina() "+mvo.getCodBreveGenereMacchina());

  SolmrLogger.debug(this,"--------------------------- mvo.getIdGenereMacchinaLong() "+mvo.getIdGenereMacchinaLong());

  SolmrLogger.debug(this,"--------------------------- mvo.getIdCategoria() "+mvo.getIdCategoria());



  htmpl.set("idMacchina",  ""+idMacchina);



  if(request.getAttribute("matricolaTelaio") != null)

    htmpl.set("matricolaTelaio", (String)request.getAttribute("matricolaTelaio"));

  else

    htmpl.set("matricolaTelaio", mavo.getMatricolaTelaio());



  if(request.getAttribute("matricolaMotore") != null)

    htmpl.set("matricolaMotore", (String)request.getAttribute("matricolaMotore"));

  else

    htmpl.set("matricolaMotore", mavo.getMatricolaMotore());



  if(mavo.getIdMatrice()!=null)

  {

    htmpl.set("descGenereMacchina", mvo.getDescGenereMacchina());



    htmpl.newBlock("blkMatrice");



    if("MAO".equalsIgnoreCase(mvo.getCodBreveGenereMacchina()))

    {

      htmpl.newBlock("blkMAO");

      String idCategoria = null;

      if(request.getAttribute("idCategoria") != null)

      {

        idCategoria = (String)request.getAttribute("idCategoria");

      }

      else

      {

        idCategoria = mvo.getIdCategoria();

      }

      printCombo(htmpl, umaClient.getCategorieMacchina(mvo.getIdGenereMacchinaLong()), "idCategoria", "descCategoria", idCategoria, "blkMatrice.blkMAO.blkCategoria");

    }

    else

    {

      htmpl.newBlock("blkNotMAO");

      htmpl.set("blkNotMAO.descCategoria", mvo.getDescCategoria());

    }



    UtenteIrideVO utenteIrideVO=umaClient.getUtenteIride(mavo.getExtIdUtenteAggiornamentoLong());

    htmpl.set("blkMatrice.marca", mvo.getDescMarca());

    htmpl.set("blkMatrice.tipoMacchina", mvo.getTipoMacchina());

    if(request.getAttribute("numeroMatrice") != null)

      htmpl.set("blkMatrice.numeroMatrice", (String)request.getAttribute("numeroMatrice"));

    else

      htmpl.set("blkMatrice.numeroMatrice", mvo.getNumeroMatrice());

    htmpl.set("blkMatrice.numeroOmologazione", mvo.getNumeroOmologazione());

    htmpl.set("blkMatrice.descAlimentazione", mvo.getDescAlimentazione());

    htmpl.set("blkMatrice.potenzaCV", mvo.getPotenzaCV());

    htmpl.set("blkMatrice.potenzaKW", mvo.getPotenzaKW());

    htmpl.set("blkMatrice.consumoOrario", mvo.getConsumoOrario());

    htmpl.set("blkMatrice.descTrazione", mvo.getDescTrazione());

    htmpl.set("blkMatrice.descNazionalita", mvo.getDescNazionalita());

    htmpl.set("blkMatrice.dataAggiornamento", mavo.getDataAggiornamento());

    htmpl.set("blkMatrice.nomeUtente",utenteIrideVO.getDenominazione());

    htmpl.set("blkMatrice.nomeEnte",utenteIrideVO.getDescrizioneEnteAppartenenza());

    //Correzione Motori vari 22/11/2004 - Begin
    //if(!"MV".equals(mvo.getCodBreveGenereMacchina().trim()))
    if(!"V".equals(mvo.getCodBreveGenereMacchina().trim()))

    {
      SolmrLogger.debug(this, "\n\n\n\n//***//***//***//***//***//***//***");

      SolmrLogger.debug(this, "blkMatrice.blkMatricolaTelaio");

      htmpl.newBlock("blkMatrice.blkMatricolaTelaio");

      htmpl.set("blkMatrice.blkMatricolaTelaio.matricolaTelaio", mavo.getMatricolaTelaio());

    }

    //Correzione Motori vari 22/11/2004 - End

    Vector noMatricolaMotore = new Vector();

      noMatricolaMotore.add("T");

      noMatricolaMotore.add("MTS");

      noMatricolaMotore.add("MTA");



    if(!noMatricolaMotore.contains(mvo.getCodBreveGenereMacchina().trim()))

    {

      htmpl.newBlock("blkMatrice.blkMatricolaMotore");

      htmpl.set("blkMatrice.blkMatricolaMotore.matricolaMotore", mavo.getMatricolaMotore());

    }

  }

  else

  {

    SolmrLogger.debug(this,"######## dmvo.getDescGenereMacchina()" + dmvo.getDescGenereMacchina());

    SolmrLogger.debug(this,"######## dmvo.getCodBreveGenereMacchina()" + dmvo.getCodBreveGenereMacchina());

    htmpl.set("descGenereMacchina", dmvo.getDescGenereMacchina());

    htmpl.set("descCategoria", dmvo.getDescCategoria());



    if ( dmvo.getTaraDouble() !=null )

    {

      //SolmrLogger.debug(this,"if ( dmvo.getTaraDouble() !=null )");

      //SolmrLogger.debug(this,"dmvo.getTara(): "+dmvo.getTara());

      String tara = numericFormat2.format(dmvo.getTaraDouble());

      SolmrLogger.debug(this,"\n\ntara: "+tara);

      dmvo.setTara( tara.replace('.',',') );

    }

    if ( dmvo.getLordoDouble() !=null )

    {

      //SolmrLogger.debug(this,"if ( dmvo.getLordoDouble() !=null )");

      //SolmrLogger.debug(this,"dmvo.getLordo(): "+dmvo.getLordo());

      String lordo = numericFormat2.format(dmvo.getLordoDouble());

      SolmrLogger.debug(this,"\n\nlordo: "+lordo);

      dmvo.setLordo( lordo.replace('.',',') );

    }



    SolmrLogger.debug(this,"***************************** dmvo.getIdGenereMacchinaLong() "+dmvo.getIdGenereMacchinaLong());

    SolmrLogger.debug(this,"***************************** dmvo.getIdCategoria() "+dmvo.getIdCategoria());

    SolmrLogger.debug(this,"***************************** umaClient.getCategorieMacchina(dmvo.getIdGenereMacchinaLong()).size() "+umaClient.getCategorieMacchina(dmvo.getIdGenereMacchinaLong()).size());



    htmpl.newBlock("blkRimorchiOrASM");

    printCombo(htmpl, umaClient.getCategorieMacchina(dmvo.getIdGenereMacchinaLong()), "idCategoria", "descCategoria", dmvo.getIdCategoria(), "blkRimorchiOrASM.blkCategoria");



    if("R".equals(dmvo.getCodBreveGenereMacchina().trim()))

    {

      htmpl.newBlock("blkRimorchi");



      printCombo(htmpl, umaClient.getTipiNazionalita(), "idNazionalita", "descNazionalita", dmvo.getIdNazionalita(), "blkRimorchi.blkNazionalita");



      SolmrLogger.debug(this,"***************************** dmvo.getExtIdUtenteAggiornamentoLong() "+dmvo.getExtIdUtenteAggiornamentoLong());

      UtenteIrideVO utenteIrideVO=umaClient.getUtenteIride(dmvo.getExtIdUtenteAggiornamentoLong());

      SolmrLogger.debug(this,"***************************** utenteIrideVO "+utenteIrideVO);

      htmpl.set("blkRimorchi.descGenereMacchina", dmvo.getDescGenereMacchina());

      htmpl.set("blkRimorchi.descCategoria", dmvo.getDescCategoria());

      htmpl.set("blkRimorchi.marca", dmvo.getMarca());

      htmpl.set("blkRimorchi.tipoMacchina", dmvo.getTipoMacchina());

      htmpl.set("blkRimorchi.tara", dmvo.getTara());

      htmpl.set("blkRimorchi.lordo", dmvo.getLordo());

      htmpl.set("blkRimorchi.numeroAssi", dmvo.getNumeroAssi());

      htmpl.set("blkRimorchi.dataAggiornamento", dmvo.getDataAggiornamento());

      htmpl.set("blkRimorchi.matricolaTelaio", mavo.getMatricolaTelaio());

      htmpl.set("blkRimorchi.nomeUtente", utenteIrideVO.getDenominazione());

      htmpl.set("blkRimorchi.nomeEnte", utenteIrideVO.getDescrizioneEnteAppartenenza());

    }

    else if("ASM".equals(dmvo.getCodBreveGenereMacchina().trim()))

    {

      htmpl.newBlock("bklASM");



      printCombo(htmpl, umaClient.getTipiAlimentazione(), "idAlimentazione", "descAlimentazione", dmvo.getIdAlimentazione(), "blkASM.blkAlimentazione");

      printCombo(htmpl, umaClient.getTipiNazionalita(), "idNazionalita", "descNazionalita", dmvo.getIdNazionalita(), "blkASM.blkNazionalita");



      UtenteIrideVO utenteIrideVO=umaClient.getUtenteIride(dmvo.getExtIdUtenteAggiornamentoLong());

      htmpl.set("blkASM.descGenereMacchina", dmvo.getDescGenereMacchina());

      htmpl.set("blkASM.descCategoria", dmvo.getDescCategoria());

      htmpl.set("blkASM.marca", dmvo.getMarca());

      htmpl.set("blkASM.tipoMacchina", dmvo.getTipoMacchina());

      htmpl.set("blkASM.calorie", dmvo.getCalorie());

      htmpl.set("blkASM.potenza", dmvo.getPotenza());

      htmpl.set("blkASM.dataAggiornamento", dmvo.getDataAggiornamento());

      htmpl.set("blkASM.matricolaTelaio", mavo.getMatricolaTelaio());

      htmpl.set("blkASM.matricolaMotore", mavo.getMatricolaMotore());

      htmpl.set("blkASM.nomeUtente", utenteIrideVO.getDenominazione());

      htmpl.set("blkASM.nomeEnte", utenteIrideVO.getDescrizioneEnteAppartenenza());

    }

  }

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  HtmplUtil.setValues(htmpl, mavo, (String)session.getAttribute("pathToFollow"));

  HtmplUtil.setErrors(htmpl, (ValidationErrors)request.getAttribute("errors"), request);

  this.errErrorValExc(htmpl, request, exception);

  out.print(htmpl.text());

%>

<%!

  private void errErrorValExc(Htmpl htmpl, HttpServletRequest request, Throwable exc)

  {

    SolmrLogger.debug(this,"\n\n\n\n *********************************** errErrorValExc()");



    if (exc instanceof it.csi.solmr.exception.ValidationException){



      ValidationErrors valErrs = new ValidationErrors();

      valErrs.add("error", new ValidationError(exc.getMessage()) );



      HtmplUtil.setErrors(htmpl, valErrs, request);

    }

  }



  private void printCombo(Htmpl htmpl,Vector comboData,String nameCode,String nameDesc,String selectedCode,String blockName)

    {

      int size=comboData==null?0:comboData.size();

      String blkNameCode=blockName+"."+nameCode;

      String blkNameDesc=blockName+"."+nameDesc;

      htmpl.newBlock(blockName);

      htmpl.set(blkNameCode,null);

      htmpl.set(blkNameDesc,"");

      for(int i=0;i<size;i++)

      {

        CodeDescr cd=(CodeDescr)comboData.get(i);

        String code=cd.getCode().toString();

        htmpl.newBlock(blockName);

        if (code!=null && code.equals(selectedCode))

        {

          htmpl.set(blockName+".selected","selected");

        }

        htmpl.set(blkNameCode,code);

        htmpl.set(blkNameDesc,cd.getDescription());

      }

  }

%>



