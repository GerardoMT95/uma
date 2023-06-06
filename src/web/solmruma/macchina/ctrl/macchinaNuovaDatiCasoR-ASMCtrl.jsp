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
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>


<%

  String iridePageName = "macchinaNuovaDatiCasoR-ASMCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%



  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  String AVANTIRIMORCHIO = "avantiGenereRimorchio";
  String AVANTIASM = "avantiGenereAsm";
  String INDIETRORIMORCHIO = "indietroGenereRimorchio";
  String INDIETROASM = "indietroGenereAsm";

  UmaFacadeClient umaClient = new UmaFacadeClient();
  String url="/macchina/view/macchinaNuovaDatiCasoR-ASMView.jsp";
  String prevUrlRimorchioAsmHtml="../layout/macchinaNuovaGenere.htm";
  String nextUrlRimorchioAsmHtml="../layout/macchinaNuovaUtilizzoCasoR-ASM.htm";
  String viewUrl="/macchina/view/macchinaNuovaDatiCasoR-ASMView.jsp";
  String elencoMacchineUrlHtml="../layout/elencoMacchine.htm";

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  SolmrLogger.debug(this,"request.getParameter(\""+AVANTIRIMORCHIO+"\"): " + request.getParameter(AVANTIRIMORCHIO));
  SolmrLogger.debug(this,"request.getParameter(\""+AVANTIASM+"\"): " + request.getParameter(AVANTIASM));
  SolmrLogger.debug(this,"request.getParameter(\""+INDIETRORIMORCHIO+"\"): " + request.getParameter(INDIETRORIMORCHIO));
  SolmrLogger.debug(this,"request.getParameter(\""+INDIETROASM+"\"): " + request.getParameter(INDIETROASM));

  Long idGenereMacchina=null;
  Long idCategoria=null;

  if ( session.getAttribute("common")!=null && !(session.getAttribute("common") instanceof HashMap)){
    response.sendRedirect(elencoMacchineUrlHtml);
    return;
  }

  HashMap vecSession=null;
  MacchinaVO macchinaVO=null;
  //MatriceVO matriceVO=null;
  DatiMacchinaVO datiMacchinaVO=null;

  if ( session.getAttribute("common")!=null ){
    SolmrLogger.debug(this,"session.getAttribute(\"common\")!=null");
    vecSession = (HashMap) session.getAttribute("common");
    macchinaVO = (MacchinaVO) vecSession.get("macchinaVO");
    SolmrLogger.debug(this,"macchinaVO: "+macchinaVO);
    /*matriceVO = (MatriceVO) vecSession.get("matriceVO");
    SolmrLogger.debug(this,"matriceVO: "+matriceVO);*/
    datiMacchinaVO = (DatiMacchinaVO) vecSession.get("datiMacchinaVO");
    SolmrLogger.debug(this,"datiMacchinaVO: "+datiMacchinaVO);
  }

  if (request.getParameter(AVANTIRIMORCHIO)!=null || request.getParameter(AVANTIASM)!=null)
  {
    // Avanti da macchinaNuovaDatiCasoR-ASM
    SolmrLogger.debug(this,"Avanti da macchinaNuovaDatiCasoR-ASM");

    SolmrLogger.debug(this,AVANTIRIMORCHIO +" or " + AVANTIASM);

    ValidationErrors vErr=null;
    if ((request.getParameter(AVANTIRIMORCHIO))!=null){
      SolmrLogger.debug(this,AVANTIRIMORCHIO);
      vErr = validateInputRimorchio(datiMacchinaVO, macchinaVO, request);
    }
    else{
      SolmrLogger.debug(this,AVANTIASM);
      vErr = validateInputAsm(datiMacchinaVO, macchinaVO, request);
    }
    SolmrLogger.debug(this,"\n\n\n\n\n@@@@@@@@@@@@@@@@@@@@òvErr.size()!=0");
    if (vErr.size()!=0){
      SolmrLogger.debug(this,"\n\n\n######");
      SolmrLogger.debug(this,"vErr.size()!=0");
      SolmrLogger.debug(this,"vErr: "+vErr);

      request.setAttribute("errors", vErr);
      %><jsp:forward page="<%=viewUrl%>" /><%
    }
    else{
      SolmrLogger.debug(this,"\n\n\n######");
      SolmrLogger.debug(this,"vErr.size()==0");
    }

    //request.setAttribute("datiMacchinaVO", datiMacchinaVO);
    // Rimorchio Asm
    SolmrLogger.debug(this,"Rimorchio Asm");

    try
    {
      vecSession = new HashMap();
      vecSession.put("macchinaVO",macchinaVO);
      //vecSession.put("matriceVO",matriceVO);
      vecSession.put("datiMacchinaVO",datiMacchinaVO);
      session.setAttribute("common",vecSession);
      response.sendRedirect(nextUrlRimorchioAsmHtml);
      return;
    }
    catch(Exception e)
    {
      this.throwValidation(e.getMessage(),viewUrl);
    }
  }
  else
  {
    if (request.getParameter(INDIETRORIMORCHIO)!=null || request.getParameter(INDIETROASM)!=null)
    {
      // Indietro da macchinaNuovaDatiCasoR-ASM
      SolmrLogger.debug(this,"Indietro da macchinaNuovaDatiCasoR-ASM");

      annullaLoad(datiMacchinaVO, macchinaVO, request, INDIETRORIMORCHIO);

      SolmrLogger.debug(this,"\n\n\nààààààààààààààààààààààààààààààà3");
      SolmrLogger.debug(this,"datiMacchinaVO.getIdGenereMacchinaLong(): "+datiMacchinaVO.getIdGenereMacchinaLong());
      SolmrLogger.debug(this,"datiMacchinaVO.getIdCategoriaLong(): "+datiMacchinaVO.getIdCategoriaLong());

      SolmrLogger.debug(this,"prevUrlRimorchioAsmHtml: "+prevUrlRimorchioAsmHtml);
      response.sendRedirect(prevUrlRimorchioAsmHtml);
      return;
    }

    // Caricamento dati ricerca in macchinaNuovaDatiCasoR-ASM
    SolmrLogger.debug(this,"Caricamento dati ricerca in macchinaNuovaDatiCasoR-ASM");

    idGenereMacchina=datiMacchinaVO.getIdGenereMacchinaLong();
    idCategoria=datiMacchinaVO.getIdCategoriaLong();

    SolmrLogger.debug(this,"idGenereMacchina: "+idGenereMacchina);
    SolmrLogger.debug(this,"idCategoria: "+idCategoria);

    String descGenereMacchina = umaClient.getDescGenereMacchina(idGenereMacchina);
    SolmrLogger.debug(this,"descGenereMacchina: "+descGenereMacchina);
    String descCategoria = umaClient.getDescCategoria(idCategoria);
    SolmrLogger.debug(this,"descCategoria: "+descCategoria);

    SolmrLogger.debug(this,"datiMacchinaVO.getIdGenereMacchina(): "+datiMacchinaVO.getIdGenereMacchina());
    SolmrLogger.debug(this,"datiMacchinaVO.getIdCategoria(): "+datiMacchinaVO.getIdCategoria());
    SolmrLogger.debug(this,"datiMacchinaVO.getDescGenereMacchina(): "+datiMacchinaVO.getDescGenereMacchina());
    SolmrLogger.debug(this,"datiMacchinaVO.getDescCategoria(): "+datiMacchinaVO.getDescCategoria());

    //datiMacchinaVO.setIdGenereMacchina(""+idGenereMacchina);
    //datiMacchinaVO.setIdCategoria(""+idCategoria);
    datiMacchinaVO.setDescGenereMacchina(descGenereMacchina);
    datiMacchinaVO.setDescCategoria(descCategoria);

    SolmrLogger.debug(this,"2Caricamento dati ricerca in macchinaNuovaDatiCasoR-ASM");
    vecSession = new HashMap();
    vecSession.put("macchinaVO",macchinaVO);
    //vecSession.put("matriceVO",matriceVO);
    vecSession.put("datiMacchinaVO",datiMacchinaVO);
    session.setAttribute("common",vecSession);
    %><jsp:forward page="<%=viewUrl%>" /><%
  }
%>
<%!
private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException(msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}

private ValidationErrors validateInputRimorchio(DatiMacchinaVO datiMacchinaVO, MacchinaVO macchinaVO, HttpServletRequest request){
  ValidationErrors errors =  new ValidationErrors();
  SolmrLogger.debug(this,"Dentro validateInputRimorchio");
  SolmrLogger.debug(this,"datiMacchinaVO: "+datiMacchinaVO);
  SolmrLogger.debug(this,"macchinaVO: "+macchinaVO);
  if (!Validator.isNotEmpty(request.getParameter("marca")))
  {
    datiMacchinaVO.setMarca(null);
    errors.add("marca",new ValidationError("Inserire la marca"));
    SolmrLogger.debug(this,"1A");
  }
  else
  {
    datiMacchinaVO.setMarca(request.getParameter("marca"));
    long LIMITE_MARCA=30;
    if ( request.getParameter("marca").trim().length()>LIMITE_MARCA)
    {
      errors.add("marca",new ValidationError("La marca è limitata a "+ LIMITE_MARCA +" caratteri"));
      SolmrLogger.debug(this,"1B");
    }
    else{
      SolmrLogger.debug(this,"marca: " + datiMacchinaVO.getMarca());
      SolmrLogger.debug(this,"1C");
    }
  }

  if (!Validator.isNotEmpty(request.getParameter("tipoMacchina")))
  {
    datiMacchinaVO.setTipoMacchina(null);
    errors.add("tipoMacchina",new ValidationError("Inserire il tipo della macchina"));
    SolmrLogger.debug(this,"2A");
  }
  else
  {
    datiMacchinaVO.setTipoMacchina(request.getParameter("tipoMacchina"));
    long LIMITE_TIPO_MACCHINA=30;
    if ( request.getParameter("tipoMacchina").trim().length()>LIMITE_TIPO_MACCHINA)
    {
      errors.add("tipoMacchina",new ValidationError("Il tipo macchina è limitato a "+ LIMITE_TIPO_MACCHINA +" caratteri"));
      SolmrLogger.debug(this,"2B");
    }
    else{
      SolmrLogger.debug(this,"tipo macchina: " + datiMacchinaVO.getTipoMacchina());
      SolmrLogger.debug(this,"2C");
    }
  }

  if (!Validator.isNotEmpty(request.getParameter("matricolaTelaio")))
  {
    macchinaVO.setMatricolaTelaio(null);
    errors.add("matricolaTelaio",new ValidationError("Inserire la matricola telaio"));
    SolmrLogger.debug(this,"3A");
  }
  else
  {
    macchinaVO.setMatricolaTelaio(request.getParameter("matricolaTelaio"));
    long LIMITE_MATRICOLA_TELAIO=30;
    if ( request.getParameter("matricolaTelaio").trim().length()>LIMITE_MATRICOLA_TELAIO)
    {
      errors.add("matricolaTelaio",new ValidationError("La matricola telaio è limitata a "+ LIMITE_MATRICOLA_TELAIO +" caratteri"));
      SolmrLogger.debug(this,"3B");
    }
    else{
      SolmrLogger.debug(this,"matricolaTelaio: " + macchinaVO.getMatricolaTelaio());
      SolmrLogger.debug(this,"3B");
    }
  }

  String lordo=request.getParameter("lordo");
  lordo=lordo.replace(',','.');

  String tara=request.getParameter("tara");
  tara=tara.replace(',','.');

  if (!Validator.isNotEmpty(tara))
  {
    SolmrLogger.debug(this,"4A");
    SolmrLogger.info(this, "\n\n\n#### Found error: Il campo Tara è un dato obbligatorio\n\n");
      errors.add("tara", new ValidationError("Il campo Tara è un dato obbligatorio"));
  }
  else
  {
    if (!Validator.isDouble(tara, 0, 999.99, 2))
    {
      SolmrLogger.debug(this,"4B");
      SolmrLogger.info(this, "\n\n\n#### Found error: Valore non valido. Inserire un dato numerico compreso tra 0 e 999,99\n\n");
      errors.add("tara",new ValidationError("Valore non valido. Inserire un dato numerico inferiore a 1000"));
    }
    else
    {
      if (new Double(tara).doubleValue()>999.99 || new Double(tara).doubleValue()<0)
      {
        SolmrLogger.debug(this,"4B");
        SolmrLogger.info(this, "\n\n\n#### Found error: Inserire un dato compreso tra 0,01 e 999,99\n\n");
        errors.add("tara", new ValidationError("Inserire un dato compreso tra 0,99 e 999,99"));
      }
    }
  }
  datiMacchinaVO.setTara(request.getParameter("tara"));

  if (!Validator.isNotEmpty(lordo))
  {
    SolmrLogger.debug(this,"5A");
    SolmrLogger.info(this, "\n\n\n#### Found error: Il campo Lordo è un dato obbligatorio\n\n");
    errors.add("lordo", new ValidationError("Il campo Lordo è un dato obbligatorio"));
  }
  else if (!Validator.isDouble(lordo, 0, 999.99, 2))
  {
    SolmrLogger.debug(this,"5B");
    SolmrLogger.info(this, "\n\n\n#### Found error: Valore non valido. Inserire un dato numerico inferiore a 1000\n\n");
    errors.add("lordo",new ValidationError("Valore non valido. Inserire un dato numerico inferiore a 1000"));
  }
  else if ( (new Double(lordo).doubleValue()>999.99) || (new Double(lordo).doubleValue()<0) )
  {
    SolmrLogger.debug(this,"5C");
    SolmrLogger.info(this, "\n\n\n#### Found error: Inserire un dato compreso tra 0 e 999,99\n\n");
    errors.add("lordo", new ValidationError("Inserire un dato compreso tra 0 e 999,99"));
  }
  else{
    boolean controlloTaraLordo=true;
    /*if(!"012".equals(datiMacchinaVO.getCodBreveCategoriaMacchina()) && !"010".equals(datiMacchinaVO.getCodBreveCategoriaMacchina()))
    {*/
      SolmrLogger.debug(this,"5D");
      /*if( new Double(lordo).compareTo(new Double(15)) > 0 )
      {*/
        SolmrLogger.debug(this,"5E");
        SolmrLogger.info(this, "\n\n\n#### Found error: Il peso Lordo deve essere inferiore o uguale a 15 quintali\n\n");
        //errors.add("lordo", new ValidationError("Il peso Lordo deve essere inferiore o uguale a 15 quintali"));
        //controlloTaraLordo=false;
      //}
    //}
    if(Validator.isNotEmpty(tara) && Validator.isDouble(tara, 0, 999.99, 2) && controlloTaraLordo)
    {
      SolmrLogger.debug(this,"5F");
      if((new Double(lordo)).doubleValue()<(new Double(tara)).doubleValue())
      {
        errors.add("lordo",new ValidationError("Il peso lordo non può essere inferiore alla tara"));
        errors.add("tara", new ValidationError("La tara non può essere maggiore del peso lordo"));
      }
    }
  }

  datiMacchinaVO.setLordo(request.getParameter("lordo"));

  /*if (!Validator.isNotEmpty(request.getParameter("tara")))
  {
    datiMacchinaVO.setTaraDouble(null);
    errors.add("tara",new ValidationError("Inserire la tara"));
    SolmrLogger.debug(this,"4A");
  }
  else
  {
    try
    {
      SolmrLogger.debug(this,"4B1");
      String tara=request.getParameter("tara");
      if (tara!=null){
        SolmrLogger.debug(this,"tara!=null "+tara);
        tara=tara.replace(',','.');
      }else{
        SolmrLogger.debug(this,"tara==null");
      }

      SolmrLogger.debug(this,"4B2");
      datiMacchinaVO.setTaraDouble(new Double(tara));

      if (datiMacchinaVO.getTaraDouble()==null || datiMacchinaVO.getTaraDouble().doubleValue()<=0)
      {
        SolmrLogger.debug(this,"7B");
        SolmrLogger.debug(this,"Error tara="+datiMacchinaVO.getTaraDouble());
        errors.add("tara",new ValidationError("Inserire un valore numerico maggiore di zero"));
      }

      final double LIMITE_TARA = 99999.99;
      if (datiMacchinaVO.getTaraDouble()==null || datiMacchinaVO.getTaraDouble().doubleValue()>LIMITE_TARA)
      {
        SolmrLogger.debug(this,"7B");
        SolmrLogger.debug(this,"Error tara="+datiMacchinaVO.getTaraDouble());
        errors.add("tara",new ValidationError("Inserire un valore numerico inferiore o uguale a "+LIMITE_TARA));
      }
      SolmrLogger.debug(this,"tara : "+datiMacchinaVO.getTaraDouble());
      SolmrLogger.debug(this,"lordo : "+datiMacchinaVO.getLordoDouble());
      SolmrLogger.debug(this,"lordo : "+datiMacchinaVO.getLordo());

    }
    catch (NumberFormatException ex)
    {
      datiMacchinaVO.setTara(request.getParameter("tara"));
      errors.add("tara",new ValidationError("Inserire un valore numerico."));
    }
  }*/

  /*if (!Validator.isNotEmpty(request.getParameter("lordo")))
  {
    datiMacchinaVO.setLordoDouble(null);
    errors.add("lordo",new ValidationError("Inserire il lordo"));
    SolmrLogger.debug(this,"5A");
  }
  else
  {
    try
    {
      SolmrLogger.debug(this,"5B1");
      String lordo=request.getParameter("lordo");
      if (lordo!=null){
        SolmrLogger.debug(this,"lordo!=null "+lordo);
        lordo=lordo.replace(',','.');
      }else{
        SolmrLogger.debug(this,"lordo==null");
      }

      SolmrLogger.debug(this,"5B2");
      datiMacchinaVO.setLordoDouble(new Double(lordo));

      if (datiMacchinaVO.getLordoDouble()==null || datiMacchinaVO.getLordoDouble().doubleValue()<=0)
      {
        SolmrLogger.debug(this,"5C");
        SolmrLogger.debug(this,"Error lordo="+datiMacchinaVO.getLordoDouble());
        errors.add("lordo",new ValidationError("Inserire un valore numerico maggiore di zero"));
      }

      final double LIMITE_LORDO = 99999.99;
      if (datiMacchinaVO.getLordoDouble()==null || datiMacchinaVO.getLordoDouble().doubleValue()>LIMITE_LORDO)
      {
        SolmrLogger.debug(this,"5D");
        SolmrLogger.debug(this,"Error lordo="+datiMacchinaVO.getLordoDouble());
        errors.add("lordo",new ValidationError("Inserire un valore numerico inferiore o uguale a "+LIMITE_LORDO));
      }
      if(datiMacchinaVO.getTaraDouble() != null && datiMacchinaVO.getLordoDouble() != null)
      {
        if(datiMacchinaVO.getLordoDouble().doubleValue()<datiMacchinaVO.getTaraDouble().doubleValue())
        {
          errors.add("lordo",new ValidationError("Il peso lordo non può essere inferiore alla tara"));
          errors.add("tara", new ValidationError("La tara non può essere maggiore del peso lordo"));
        }
      }
    }
    catch (NumberFormatException ex)
    {
      datiMacchinaVO.setLordo(request.getParameter("lordo"));
      errors.add("lordo",new ValidationError("Inserire un valore numerico."));
    }
  }*/

  if (!Validator.isNotEmpty(request.getParameter("numeroAssi")))
  {
    datiMacchinaVO.setNumeroAssiLong(null);
    errors.add("numeroAssi",new ValidationError("Inserire il numero di assi"));
    SolmrLogger.debug(this,"6A");
  }
  else
  {
    try
    {
      SolmrLogger.debug(this,"7A");
      datiMacchinaVO.setNumeroAssiLong(new Long(request.getParameter("numeroAssi")));

      if (datiMacchinaVO.getNumeroAssiLong()==null || datiMacchinaVO.getNumeroAssiLong().longValue()<=0)
      {
        SolmrLogger.debug(this,"7B");
        SolmrLogger.debug(this,"Error numero assi="+datiMacchinaVO.getNumeroAssi());
        errors.add("numeroAssi",new ValidationError("Inserire un valore numerico maggiore di zero"));
      }
      final long LIMITE_NUMERO_ASSI = 9;
      if (datiMacchinaVO.getNumeroAssiLong()==null || datiMacchinaVO.getNumeroAssiLong().longValue()>LIMITE_NUMERO_ASSI)
      {
        SolmrLogger.debug(this,"7D");
        SolmrLogger.debug(this,"Error numero assi="+datiMacchinaVO.getNumeroAssiLong());
        errors.add("numeroAssi",new ValidationError("Inserire un valore numerico inferiore o uguale a "+LIMITE_NUMERO_ASSI));
      }
    }
    catch (NumberFormatException ex)
    {
      datiMacchinaVO.setNumeroAssi(request.getParameter("numeroAssi"));
      errors.add("numeroAssi",new ValidationError("Inserire un valore numerico intero."));
    }
  }

  SolmrLogger.debug(this,"request.getParameter(\"tipiNazionalita\"): "+request.getParameter("tipiNazionalita"));
  if (!Validator.isNotEmpty(request.getParameter("tipiNazionalita")))
  {
    datiMacchinaVO.setIdNazionalita(null);
    errors.add("tipiNazionalita",new ValidationError("Inserire la nazionalità"));
    SolmrLogger.debug(this,"8A");
  }
  else
  {
    datiMacchinaVO.setIdNazionalita(request.getParameter("tipiNazionalita"));
    datiMacchinaVO.setTipiNazionalita(request.getParameter("tipiNazionalita"));
    SolmrLogger.debug(this,"nazionalita: " + datiMacchinaVO.getIdNazionalita());
    SolmrLogger.debug(this,"8B");
  }

  return errors;
}


private ValidationErrors validateInputAsm(DatiMacchinaVO datiMacchinaVO, MacchinaVO macchinaVO, HttpServletRequest request){
  ValidationErrors errors =  new ValidationErrors();
  if (!Validator.isNotEmpty(request.getParameter("marca")))
  {
    datiMacchinaVO.setMarca(null);
    errors.add("marca",new ValidationError("Inserire la marca"));
    SolmrLogger.debug(this,"1A");
  }
  else
  {
    datiMacchinaVO.setMarca(request.getParameter("marca"));
    long LIMITE_MARCA=30;
    if ( request.getParameter("marca").trim().length()>LIMITE_MARCA)
    {
      errors.add("marca",new ValidationError("La marca è limitata a "+ LIMITE_MARCA +" caratteri"));
      SolmrLogger.debug(this,"3B");
    }
    else{
      SolmrLogger.debug(this,"marca: " + datiMacchinaVO.getMarca());
      SolmrLogger.debug(this,"3C");
    }
  }

  if (!Validator.isNotEmpty(request.getParameter("tipoMacchina")))
  {
    datiMacchinaVO.setTipoMacchina(null);
    errors.add("tipoMacchina",new ValidationError("Inserire il tipo della macchina"));
    SolmrLogger.debug(this,"2A");
  }
  else
  {
    datiMacchinaVO.setTipoMacchina(request.getParameter("tipoMacchina"));
    long LIMITE_TIPO_MACCHINA=30;
    if ( request.getParameter("tipoMacchina").trim().length()>LIMITE_TIPO_MACCHINA)
    {
      errors.add("tipoMacchina",new ValidationError("Il tipo macchina è limitato a "+ LIMITE_TIPO_MACCHINA +" caratteri"));
      SolmrLogger.debug(this,"3B");
    }
    else{
      SolmrLogger.debug(this,"tipoMacchina: " + datiMacchinaVO.getTipoMacchina());
      SolmrLogger.debug(this,"3C");
    }
  }

  if (!Validator.isNotEmpty(request.getParameter("matricolaTelaio")))
  {
    macchinaVO.setMatricolaTelaio(null);
    errors.add("matricolaTelaio",new ValidationError("Inserire la matricola telaio"));
    SolmrLogger.debug(this,"3A");
  }
  else
  {
    macchinaVO.setMatricolaTelaio(request.getParameter("matricolaTelaio"));
    long LIMITE_MATRICOLA_TELAIO=30;
    if ( request.getParameter("matricolaTelaio").trim().length()>LIMITE_MATRICOLA_TELAIO)
    {
      errors.add("matricolaTelaio",new ValidationError("Il tipo macchina è limitato a "+ LIMITE_MATRICOLA_TELAIO +" caratteri"));
      SolmrLogger.debug(this,"3B");
    }
    else{
      SolmrLogger.debug(this,"matricolaTelaio: " + macchinaVO.getMatricolaTelaio());
      SolmrLogger.debug(this,"3C");
    }
  }

  macchinaVO.setMatricolaMotore(request.getParameter("matricolaMotore"));

  //071012 - Calcolo calorie(kw=kcal/h * 1/860)
  /*if (!Validator.isNotEmpty(request.getParameter("calorie")))
  {
    datiMacchinaVO.setCalorie(null);
    SolmrLogger.debug(this,"4A");
    SolmrLogger.debug(this,"calorie: " + datiMacchinaVO.getCalorie());
    errors.add("calorie",new ValidationError("Inserire le calorie"));
  }
  else
  {
    datiMacchinaVO.setCalorie(request.getParameter("calorie"));
    Long calorieLong=datiMacchinaVO.getCalorieLong();
    if (calorieLong==null)
    {
      errors.add("calorie",new ValidationError("Inserire un valore numerico maggiore di zero"));
    }
    else
    {
      final long LIMITE_CALORIE = 99999;
      if (calorieLong.longValue()>LIMITE_CALORIE)
      {
        SolmrLogger.debug(this,"5E");
        SolmrLogger.debug(this,"Error calorie="+calorieLong);
        errors.add("calorie",new ValidationError("Inserire un valore numerico inferiore o uguale a "+LIMITE_CALORIE));
      }
    }
  }

  SolmrLogger.debug(this,"5B");
  datiMacchinaVO.setPotenza(request.getParameter("potenza"));
  SolmrLogger.debug(this,"5B");
  if (Validator.isNotEmpty(datiMacchinaVO.getPotenza()))
  {
      Long potenzaLong=datiMacchinaVO.getPotenzaLong();
      if (potenzaLong==null)
      {
        errors.add("potenza",new ValidationError("Inserire un valore numerico maggiore di zero"));
      }
      else
      {
        final long LIMITE_POTENZA = 999;
        if (potenzaLong.longValue()>LIMITE_POTENZA)
        {
          SolmrLogger.debug(this,"5E");
          SolmrLogger.debug(this,"Error potenza="+potenzaLong);
          errors.add("potenza",new ValidationError("Inserire un valore numerico inferiore o uguale a "+LIMITE_POTENZA));
        }
      }
  }
  SolmrLogger.debug(this,"5B");*/

  //071012 - Calcolo calorie(kw=kcal/h * 1/860) - Begin
  boolean calorieCompilatoOk = false;
  boolean potenzaCompilatoOk = false;
  final long MIN_VALUE_CALORIE = 860;
  final long MAX_VALUE_CALORIE = 859569;
  final long RAPPORTO_CALORIE_POTENZA = 860;
  String msgRicalcolo = "Il rapporto tra potenza in Kcal/h e Kw non è rispettato (1 kw = "+RAPPORTO_CALORIE_POTENZA+
                        " Kcal/h). Inserire uno solo dei due valori, il sistema provvede a calcolare il restante.";
  int decimalPlaces = 0;

  datiMacchinaVO.setPotenza(request.getParameter("potenza"));
  if(Validator.isNotEmpty(datiMacchinaVO.getPotenza()))
  {
    long MIN_VALUE_POTENZA = 1;
    long MAX_VALUE_POTENZA = 9999;
    if(!Validator.isNumericInteger(datiMacchinaVO.getPotenza()))
    {
      SolmrLogger.info(this, "\n\n\n#### Found error: Inserire un valore numerico intero.\n\n");
      errors.add("potenza",new ValidationError("Inserire un valore numerico intero."));
    }
    else if((datiMacchinaVO.getPotenzaLong().longValue()>MAX_VALUE_POTENZA || datiMacchinaVO.getPotenzaLong().longValue()<MIN_VALUE_POTENZA))
    {
      SolmrLogger.info(this, "\n\n\n#### Found error: Inserire un dato compreso tra "+MIN_VALUE_POTENZA+" e "+MAX_VALUE_POTENZA+"\n\n");
      errors.add("potenza", new ValidationError("Inserire un dato compreso tra "+MIN_VALUE_POTENZA+" e "+MAX_VALUE_POTENZA));
    }
    else{
      potenzaCompilatoOk = true;
    }
  }

  datiMacchinaVO.setCalorie(request.getParameter("calorie"));
  if (!Validator.isNotEmpty(datiMacchinaVO.getCalorie()))
  {
    SolmrLogger.info(this, "\n\n\n#### Found error: Il campo Calorie è un dato obbligatorio\n\n");
    if(!potenzaCompilatoOk){
      SolmrLogger.info(this, "\n\n\n#### if(!potenzaCompilatoOk)\n\n");
      errors.add("calorie", new ValidationError("Il campo Calorie è un dato obbligatorio"));
    }
  }
  else if(!Validator.isNumericInteger(datiMacchinaVO.getCalorie()))
  {
    SolmrLogger.info(this, "\n\n\n#### Found error: Inserire un valore numerico intero.\n\n");
    errors.add("calorie", new ValidationError("Inserire un valore numerico intero."));
  }
  else if (datiMacchinaVO.getCalorieLong().longValue()>MAX_VALUE_CALORIE || (datiMacchinaVO.getCalorieLong() != null && datiMacchinaVO.getCalorieLong().longValue()<MIN_VALUE_CALORIE))
  {
    SolmrLogger.info(this, "\n\n\n#### Found error: Inserire un dato compreso tra "+MIN_VALUE_CALORIE+" e "+MAX_VALUE_CALORIE+"\n\n");
    errors.add("calorie", new ValidationError("Inserire un dato compreso tra "+MIN_VALUE_CALORIE+" e "+MAX_VALUE_CALORIE));
  }
  else{
    calorieCompilatoOk = true;
  }

  SolmrLogger.debug(this, "potenzaCompilatoOk: "+potenzaCompilatoOk);
  SolmrLogger.debug(this, "calorieCompilatoOk: "+calorieCompilatoOk);

  //Se sono impostati entrambi, valuto se il rapporo è ok
  if((potenzaCompilatoOk)&&(calorieCompilatoOk)){
    SolmrLogger.debug(this, "if((potenzaCompilatoOk)&&(calorieCompilatoOk))");
    //long potenzaCalcolata = datiMacchinaVO.getCalorieLong().longValue() / RAPPORTO_CALORIE_POTENZA;
    BigDecimal calorieBd = new BigDecimal(datiMacchinaVO.getCalorie());
    BigDecimal fattoreConversioneBd = new BigDecimal(RAPPORTO_CALORIE_POTENZA);

    //long potenzaCalcolata = datiMacchinaVO.getCalorieLong().longValue() / RAPPORTO_CALORIE_POTENZA;
    // Divides and truncates the big decimal value.
    BigDecimal potenzaCalcolataBd = calorieBd.divide(fattoreConversioneBd, decimalPlaces, BigDecimal.ROUND_HALF_EVEN);

    if(potenzaCalcolataBd.longValue()!=datiMacchinaVO.getPotenzaLong().longValue()){
      SolmrLogger.info(this, "\n\n\n#### Found error: if(potenzaCalcolata!=datiMacchinaVO.getCalorieLong().longValue())\n\n");
      errors.add("calorie", new ValidationError(msgRicalcolo));
      errors.add("potenza", new ValidationError(msgRicalcolo));
    }
  }

  //Derivo la potenza in kCal/h dai kw
  if((potenzaCompilatoOk)&&(Validator.isEmpty(datiMacchinaVO.getCalorieLong()))){
    SolmrLogger.debug(this, "if((potenzaCompilatoOk)&&(Validator.isEmpty(datiMacchinaVO.getCalorieLong())))");
    long calorieCalcolate = RAPPORTO_CALORIE_POTENZA * datiMacchinaVO.getPotenzaLong().longValue();

    String calorieCalcolateStr = new String(""+calorieCalcolate);
    datiMacchinaVO.setCalorie(calorieCalcolateStr);
  }

  //Derivo la potenza in kw dalle kCal/h
  if((calorieCompilatoOk)&&(Validator.isEmpty(datiMacchinaVO.getPotenzaLong()))){
    SolmrLogger.debug(this, "if((calorieCompilatoOk)&&(Validator.isEmpty(datiMacchinaVO.getPotenzaLong())))");
    BigDecimal calorieBd = new BigDecimal(datiMacchinaVO.getCalorie());
    BigDecimal fattoreConversioneBd = new BigDecimal(RAPPORTO_CALORIE_POTENZA);

    //long potenzaCalcolata = datiMacchinaVO.getCalorieLong().longValue() / RAPPORTO_CALORIE_POTENZA;
    // Divides and truncates the big decimal value.
    BigDecimal potenzaCalcolataBd = calorieBd.divide(fattoreConversioneBd, decimalPlaces, BigDecimal.ROUND_HALF_EVEN);

    datiMacchinaVO.setPotenza(potenzaCalcolataBd.toString());
  }
  //071012 - Calcolo calorie(kw=kcal/h * 1/860) - End


  SolmrLogger.debug(this,"request.getParameter(\"tipiAlimentazione\"): "+request.getParameter("tipiAlimentazione"));
  if (!Validator.isNotEmpty(request.getParameter("tipiAlimentazione")))
  {
    datiMacchinaVO.setIdAlimentazione(null);
    errors.add("tipiAlimentazione",new ValidationError("Inserire il tipo dell'alimentazione"));
    SolmrLogger.debug(this,"6A");
  }
  else
  {
    datiMacchinaVO.setIdAlimentazione(request.getParameter("tipiAlimentazione"));
    datiMacchinaVO.setTipiAlimentazione(request.getParameter("tipiAlimentazione"));
    SolmrLogger.debug(this,"tipiAlimentazione: " + datiMacchinaVO.getTipiAlimentazione());
    SolmrLogger.debug(this,"6B");
  }

  SolmrLogger.debug(this,"request.getParameter(\"tipiNazionalita\"): "+request.getParameter("tipiNazionalita"));
  if (!Validator.isNotEmpty(request.getParameter("tipiNazionalita")))
  {
    datiMacchinaVO.setIdNazionalita(null);
    errors.add("tipiNazionalita",new ValidationError("Inserire la nazionalità"));
    SolmrLogger.debug(this,"7A");
  }
  else
  {
    datiMacchinaVO.setIdNazionalita(request.getParameter("tipiNazionalita"));
    datiMacchinaVO.setTipiNazionalita(request.getParameter("tipiNazionalita"));
    SolmrLogger.debug(this,"tipiNazionalita: " + datiMacchinaVO.getIdNazionalita());
    SolmrLogger.debug(this,"7B");
  }

  return errors;
}

private void annullaLoad(DatiMacchinaVO datiMacchinaVO, MacchinaVO macchinaVO, HttpServletRequest request, String indietro){
  HttpSession session = request.getSession(false);

  SolmrLogger.debug(this,"annullaLoad");
  SolmrLogger.debug(this,"indietro: "+indietro);
  if (request.getParameter(indietro)!=null){
    SolmrLogger.debug(this,"AVANTIRIMORCHIO");
    datiMacchinaVO.setMarca(null);
    datiMacchinaVO.setTipoMacchina(null);
    macchinaVO.setMatricolaTelaio(null);
    datiMacchinaVO.setTaraDouble(null);
    datiMacchinaVO.setLordoDouble(null);
    datiMacchinaVO.setNumeroAssiLong(null);
    datiMacchinaVO.setIdNazionalita(null);
    datiMacchinaVO.setTipiNazionalita(null);
  }
  else{
    SolmrLogger.debug(this,"AVANTIASM");
    datiMacchinaVO.setMarca(null);
    datiMacchinaVO.setTipoMacchina(null);
    macchinaVO.setMatricolaTelaio(null);
    macchinaVO.setMatricolaMotore(null);
    macchinaVO.setTargaCorrente(null);
    datiMacchinaVO.setCalorieLong(null);
    datiMacchinaVO.setPotenzaLong(null);
    datiMacchinaVO.setIdAlimentazione(null);
    datiMacchinaVO.setTipiAlimentazione(null);
    datiMacchinaVO.setIdNazionalita(null);
    datiMacchinaVO.setTipiNazionalita(null);
  }

  if ( session.getAttribute("common")!=null ){
    HashMap vecSession = (HashMap) session.getAttribute("common");
    vecSession.put("DatiMacchinaVO", datiMacchinaVO);
    vecSession.put("MacchinaVO", macchinaVO);
    session.setAttribute("common",vecSession);
  }
}
%>