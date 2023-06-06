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

<%!

  public final static String PREV="../layout/macchinaUsataNonTrovataGenere.htm";

  public final static String NEXT="../layout/macchinaUsataNonTrovataUtilizzoCasoR-ASM.htm";

  public final static String VIEW="/macchina/view/macchinaUsataNonTrovataDatiCasoR-ASMView.jsp";

  public final static String ACQUISTO_MACCHINA="../layout/macchinaUsataTarga.htm";

  public final static String AVANTIRIMORCHIO = "avantiGenereRimorchio";

  public final static String AVANTIASM = "avantiGenereAsm";

  public final static String INDIETRORIMORCHIO = "indietroGenereRimorchio";

  public final static String INDIETROASM = "indietroGenereAsm";

  public static final String ASM = "ASM";

  public static final String RIMORCHIO = "R";

  public static final String MAO_TRAINATA = "010";

  public static final String CARRO_UNIFEED = "012";

%>



<%

  String iridePageName = "macchinaUsataNonTrovataDatiCasoR-ASMCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  try

  {

    SolmrLogger.debug(this,"macchinaUsataNonTrovataDatiCasoR-ASMCtrl.jsp - Begin");



    DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

    Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();





    UmaFacadeClient umaClient = new UmaFacadeClient();



    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");



    SolmrLogger.debug(this,"request.getParameter(\""+AVANTIRIMORCHIO+"\"): " + request.getParameter(AVANTIRIMORCHIO));

    SolmrLogger.debug(this,"request.getParameter(\""+AVANTIASM+"\"): " + request.getParameter(AVANTIASM));

    SolmrLogger.debug(this,"request.getParameter(\""+INDIETRORIMORCHIO+"\"): " + request.getParameter(INDIETRORIMORCHIO));

    SolmrLogger.debug(this,"request.getParameter(\""+INDIETROASM+"\"): " + request.getParameter(INDIETROASM));



    Long idGenereMacchina=null;

    Long idCategoria=null;



    if ( session.getAttribute("common")==null || !(session.getAttribute("common") instanceof HashMap))

    {

      response.sendRedirect(ACQUISTO_MACCHINA);

      return;

    }



    HashMap common=null;

    MacchinaVO macchinaVO=null;

    MatriceVO matriceVO=null;

    DatiMacchinaVO datiMacchinaVO=null;



    SolmrLogger.debug(this,"session.getAttribute(\"common\")!=null");

    common = (HashMap) session.getAttribute("common");

    macchinaVO = (MacchinaVO) common.get("macchinaVO");

    SolmrLogger.debug(this,"macchinaVO: "+macchinaVO);

    datiMacchinaVO = (DatiMacchinaVO) macchinaVO.getDatiMacchinaVO();

    SolmrLogger.debug(this,"datiMacchinaVO: "+datiMacchinaVO);



    boolean noTarga="no".equalsIgnoreCase((String)common.get("conTarga"));

    SolmrLogger.debug(this,"noTarga="+noTarga);

    SolmrLogger.debug(this,request.getParameter(AVANTIRIMORCHIO)+" "+request.getParameter(AVANTIASM));

    if (request.getParameter(AVANTIRIMORCHIO)!=null || request.getParameter(AVANTIASM)!=null)

    {

      // Avanti da macchinaNuovaDatiCasoR-ASM

      SolmrLogger.debug(this,"Avanti da macchinaUsataNonTrovataDatiCasoR-ASM");



      SolmrLogger.debug(this,AVANTIRIMORCHIO +" or " + AVANTIASM);



      ValidationErrors vErr=null;

      if ((request.getParameter(AVANTIRIMORCHIO))!=null){

        SolmrLogger.debug(this,AVANTIRIMORCHIO);

        vErr = validateInputRimorchio(datiMacchinaVO, macchinaVO, request, noTarga);

      }

      else{

        SolmrLogger.debug(this,AVANTIASM);

        vErr = validateInputAsm(datiMacchinaVO, macchinaVO, request,noTarga);

      }

      if (vErr.size()!=0)

      {

        request.setAttribute("errors", vErr);

        %><jsp:forward page="<%=VIEW%>" /><%

      }



      //request.setAttribute("datiMacchinaVO", datiMacchinaVO);

      // Rimorchio Asm

      SolmrLogger.debug(this,"Rimorchio Asm");



      common.put("macchinaVO",macchinaVO);

      session.setAttribute("common",common);

      response.sendRedirect(NEXT);

      return;

    }

    else

    {

      if (request.getParameter(INDIETRORIMORCHIO)!=null || request.getParameter(INDIETROASM)!=null)

      {

        // Indietro da macchinaNuovaDatiCasoR-ASM

        SolmrLogger.debug(this,"Indietro da macchinaNuovaDatiCasoR-ASM");



        annullaLoad(common, datiMacchinaVO, macchinaVO, request, INDIETRORIMORCHIO);



        SolmrLogger.debug(this,"\n\n\nààààààààààààààààààààààààààààààà3");

        SolmrLogger.debug(this,"datiMacchinaVO.getIdGenereMacchinaLong(): "+datiMacchinaVO.getIdGenereMacchinaLong());

        SolmrLogger.debug(this,"datiMacchinaVO.getIdCategoriaLong(): "+datiMacchinaVO.getIdCategoriaLong());



        SolmrLogger.debug(this,"PREV: "+PREV);

        response.sendRedirect(PREV);

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

      common.put("macchinaVO",macchinaVO);

      session.setAttribute("common",common);

      %><jsp:forward page="<%=VIEW%>" /><%

    }

  }

  catch(Exception e)

  {

    if ( e instanceof SolmrException )

    {

      setError(request,e.getMessage());

    }

    else

    {

      e.printStackTrace();

      setError(request,"Si è verificato un errore di sistema");

    }

    %><jsp:forward page="<%=VIEW%>" /><%

  }

%>

<%!



  private void setError(HttpServletRequest request, String msg)

  {

    SolmrLogger.debug(this,"\n\n\n\n\n\n\n\n\n\n\nmsg="+msg+"\n\n\n\n\n\n\n\n");

    ValidationErrors errors=new ValidationErrors();

    errors.add("error", new ValidationError(msg));

    request.setAttribute("errors",errors);

  }



  private ValidationErrors validateInputRimorchio(DatiMacchinaVO datiMacchinaVO, MacchinaVO macchinaVO, HttpServletRequest request, boolean noTarga)

  {

    ValidationErrors errors =  new ValidationErrors();

    if (!Validator.isNotEmpty(request.getParameter("marca")))

    {

      datiMacchinaVO.setMarca(null);

      errors.add("marca",new ValidationError("Inserire la marca"));

    }

    else

    {

      if (!Validator.isNotEmpty(request.getParameter("marca").trim()))

      {

        datiMacchinaVO.setMarca(null);

        errors.add("marca",new ValidationError("Inserire la marca"));

      }

      else

      {

        datiMacchinaVO.setMarca(request.getParameter("marca"));

        long LIMITE_MARCA=30;

        if ( request.getParameter("marca").trim().length()>LIMITE_MARCA)

        {

          errors.add("marca",new ValidationError("La marca è limitata a "+ LIMITE_MARCA +" caratteri"));

        }

      }

    }



    if (!Validator.isNotEmpty(request.getParameter("tipoMacchina")))

    {

      datiMacchinaVO.setTipoMacchina(null);

      errors.add("tipoMacchina",new ValidationError("Inserire il tipo della macchina"));

    }

    else

    {

      if (!Validator.isNotEmpty(request.getParameter("tipoMacchina").trim()))

      {

        datiMacchinaVO.setTipoMacchina(null);

        errors.add("tipoMacchina",new ValidationError("Inserire il tipo della macchina"));

      }

      else

      {

        datiMacchinaVO.setTipoMacchina(request.getParameter("tipoMacchina"));

        long LIMITE_TIPO_MACCHINA=30;

        if ( request.getParameter("tipoMacchina").trim().length()>LIMITE_TIPO_MACCHINA)

        {

          errors.add("tipoMacchina",new ValidationError("Il tipo macchina è limitato a "+ LIMITE_TIPO_MACCHINA +" caratteri"));

        }

      }

    }



    if (!Validator.isNotEmpty(request.getParameter("matricolaTelaio")))

    {

      macchinaVO.setMatricolaTelaio(null);

      errors.add("matricolaTelaio",new ValidationError("Inserire la matricola telaio"));

    }

    else

    {

      macchinaVO.setMatricolaTelaio(request.getParameter("matricolaTelaio"));

      long LIMITE_MATRICOLA_TELAIO=30;

      if ( request.getParameter("matricolaTelaio").trim().length()>LIMITE_MATRICOLA_TELAIO)

      {

        errors.add("matricolaTelaio",new ValidationError("La matricola telaio è limitata a "+ LIMITE_MATRICOLA_TELAIO +" caratteri"));

      }

    }



    if (!Validator.isNotEmpty(request.getParameter("tara")))

    {

      datiMacchinaVO.setTaraDouble(null);

      errors.add("tara",new ValidationError("Inserire la tara"));

    }

    else

    {

      try

      {

        String tara=request.getParameter("tara");

        if (tara!=null)

        {

          tara=tara.replace(',','.');

        }



        datiMacchinaVO.setTaraDouble(new Double(tara));



        if (datiMacchinaVO.getTaraDouble()==null || datiMacchinaVO.getTaraDouble().doubleValue()<=0)

        {

          errors.add("tara",new ValidationError("Inserire un valore numerico maggiore di zero"));

        }



        final double LIMITE_TARA=999.99;

/*        if (!Validator.isDouble(datiMacchinaVO.getTara(), 0, LIMITE_TARA,2))

        {

          errors.add("tara",new ValidationError("Inserire un valore numerico compreso tra 0 e "+LIMITE_TARA+" con al massimo 2 cifre decimali"));

        }

        else

        {*/

          if (datiMacchinaVO.getTaraDouble()==null || datiMacchinaVO.getTaraDouble().doubleValue()>LIMITE_TARA)

          {

            errors.add("tara",new ValidationError("Inserire un valore numerico inferiore o uguale a "+new Double(LIMITE_TARA).toString().replace('.',',')));

          }

/*        }*/

      }

      catch (NumberFormatException ex)

      {

        datiMacchinaVO.setTara(request.getParameter("tara"));

        errors.add("tara",new ValidationError("Inserire un valore numerico."));

      }

    }



    if (!Validator.isNotEmpty(request.getParameter("lordo")))

    {

      datiMacchinaVO.setLordoDouble(null);

      errors.add("lordo",new ValidationError("Inserire il lordo"));

    }

    else

    {

      try

      {

        SolmrLogger.debug(this,"5B1");

        String lordo=request.getParameter("lordo");

        if (lordo!=null)

        {

          lordo=lordo.replace(',','.');

        }



        datiMacchinaVO.setLordoDouble(new Double(lordo));



        if (datiMacchinaVO.getLordoDouble()==null || datiMacchinaVO.getLordoDouble().doubleValue()<=0)

        {

          errors.add("lordo",new ValidationError("Inserire un valore numerico maggiore di zero"));

        }



        double LIMITE_LORDO;

        if (noTarga && !isMAOTrainataCarroUnifeed(datiMacchinaVO))

/*            !(((String) SolmrConstants.get("ID_CATEGORIA_MAO_TRAINATA")).equals(datiMacchinaVO.getIdCategoria()) ||

            ((String) SolmrConstants.get("ID_CATEGORIA_CARRO_UNIFEED")).equals(datiMacchinaVO.getIdCategoria())))*/

        {

          LIMITE_LORDO=15;

        }

        else

        {

          LIMITE_LORDO=999.99;

        }

/*        if (!Validator.isDouble(datiMacchinaVO.getTara(), 0, LIMITE_LORDO,2))

        {

          errors.add("tara",new ValidationError("Inserire un valore numerico compreso tra 0 e "+LIMITE_LORDO+" con al massimo 2 cifre decimali"));

        }

        else

        {*/

          if (datiMacchinaVO.getLordoDouble()==null || datiMacchinaVO.getLordoDouble().doubleValue()>LIMITE_LORDO)

          {

            errors.add("lordo",new ValidationError("Inserire un valore numerico inferiore o uguale a "+LIMITE_LORDO));

          }

          if (!noTarga && (datiMacchinaVO.getLordoDouble()==null || datiMacchinaVO.getLordoDouble().doubleValue()<=15))

          {

            errors.add("lordo",new ValidationError("Per macchina con targa il valore del lordo deve essere superiore a 15,00 quintali"));

          }

/*        }*/

      }

      catch (NumberFormatException ex)

      {

        datiMacchinaVO.setLordo(request.getParameter("lordo"));

        errors.add("lordo",new ValidationError("Inserire un valore numerico."));

      }

    }



    if (!Validator.isNotEmpty(request.getParameter("numeroAssi")))

    {

      datiMacchinaVO.setNumeroAssiLong(null);

      errors.add("numeroAssi",new ValidationError("Inserire il numero di assi"));

    }

    else

    {

      try

      {

        datiMacchinaVO.setNumeroAssiLong(new Long(request.getParameter("numeroAssi")));



        if (datiMacchinaVO.getNumeroAssiLong()==null || datiMacchinaVO.getNumeroAssiLong().longValue()<=0)

        {

          errors.add("numeroAssi",new ValidationError("Inserire un valore numerico maggiore di zero"));

        }

        final long LIMITE_NUMERO_ASSI = 9;

        if (datiMacchinaVO.getNumeroAssiLong()==null || datiMacchinaVO.getNumeroAssiLong().longValue()>LIMITE_NUMERO_ASSI)

        {

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

    }

    else

    {

      datiMacchinaVO.setIdNazionalita(request.getParameter("tipiNazionalita"));

      datiMacchinaVO.setTipiNazionalita(request.getParameter("tipiNazionalita"));

    }

    java.text.DecimalFormat numericFormat2 = new java.text.DecimalFormat(SolmrConstants.FORMATO_NUMERIC_1INT_2DEC);


    if (Validator.isNotEmpty(datiMacchinaVO.getLordoDouble()))

    {
      datiMacchinaVO.setLordo(numericFormat2.format(datiMacchinaVO.getLordoDouble()));

    }

    if (Validator.isNotEmpty(datiMacchinaVO.getTaraDouble()))

    {

      datiMacchinaVO.setTara(numericFormat2.format(datiMacchinaVO.getTaraDouble()));

    }


    Double lordoDouble=datiMacchinaVO.getLordoDouble();

    Double taraDouble=datiMacchinaVO.getTaraDouble();

    if(lordoDouble!=null &&

       taraDouble!=null &&

       lordoDouble.doubleValue()<=taraDouble.doubleValue())

    {

      errors.add("tara", new ValidationError("La tara deve essere inferiore del peso lordo"));

      errors.add("lordo",new ValidationError("Il peso lordo deve essere superiore alla tara"));

    }

    return errors;

  }





  private ValidationErrors validateInputAsm(DatiMacchinaVO datiMacchinaVO, MacchinaVO macchinaVO, HttpServletRequest request, boolean noTarga)

  {

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


    //071012 - Calcolo calorie(kw=kcal/h * 1/860) - Begin
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

          errors.add("calorie",new ValidationError("Inserire un valore numerico inferiore a "+LIMITE_CALORIE));

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

            errors.add("potenza",new ValidationError("Inserire un valore numerico inferiore a "+LIMITE_POTENZA));

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

      errors.add("nazionalita",new ValidationError("Inserire la nazionalità"));

      SolmrLogger.debug(this,"7A");

    }

    else

    {

      datiMacchinaVO.setIdNazionalita(request.getParameter("tipiNazionalita"));

      datiMacchinaVO.setTipiNazionalita(request.getParameter("tipiNazionalita"));

      SolmrLogger.debug(this,"nazionalita: " + datiMacchinaVO.getIdNazionalita());

      SolmrLogger.debug(this,"7B");

    }



    return errors;

  }



  private void annullaLoad(HashMap common,DatiMacchinaVO datiMacchinaVO, MacchinaVO macchinaVO, HttpServletRequest request, String indietro)

  {

    HttpSession session = request.getSession(false);



    SolmrLogger.debug(this,"annullaLoad");

    SolmrLogger.debug(this,"indietro: "+indietro);

    if (request.getParameter(indietro)!=null)

    {

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

    else

    {

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

    SolmrLogger.debug(this,"conTarga="+common.get("conTarga"));

    macchinaVO.setDatiMacchinaVO(datiMacchinaVO);

    common.put("macchinaVO", macchinaVO);

    session.setAttribute("common",common);

  }

  private boolean isMAOTrainataCarroUnifeed(DatiMacchinaVO dmVO)

  {

    return RIMORCHIO.equals(dmVO.getCodBreveGenereMacchina().trim()) &&

        (MAO_TRAINATA.equals(dmVO.getCodBreveCategoriaMacchina()) ||

        CARRO_UNIFEED.equals(dmVO.getCodBreveCategoriaMacchina()));

  }

%>



