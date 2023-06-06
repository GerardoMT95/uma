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
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%!

  private static final String DETTAGLIO="/macchina/ctrl/dettaglioMacchinaDittaDatiCtrl.jsp";

  private static final String VIEW="/macchina/view/modificaMacchinaDittaDatiView.jsp";

  private static final String VIEWHTM="../layout/modificaMacchinaDittaDati.htm";

%>

<%


  String iridePageName = "modificaMacchinaDittaDatiCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  Long idMacchina=new Long(request.getParameter("idMacchina"));



  UmaFacadeClient umaClient = new UmaFacadeClient();

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  MacchinaVO mavo = (MacchinaVO)session.getAttribute("common");

  ValidationErrors errors = new ValidationErrors();

  String numeroMatrice = request.getParameter("numeroMatrice");

  SolmrLogger.debug(this,"numeroMatrice: "+numeroMatrice);



  if (request.getParameter("annulla.x")!=null)

  {

    mavo= umaClient.getMacchinaById(idMacchina);

    session.setAttribute("common", mavo);

    %><jsp:forward page="<%=DETTAGLIO%>" /><%

    return;

  }

  else if("cambiaMatrice".equals(request.getParameter("cambiaMatrice")))

  {

    SolmrLogger.debug(this,"cambio numero matrice");

    request.setAttribute("idCategoria", request.getParameter("idCategoria"));



    MatriceVO mvo = mavo.getMatriceVO();

    mvo.setIdCategoria((String)request.getParameter("idCategoria"));

    mavo.setMatriceVO(mvo);



    SolmrLogger.debug(this,"###################################### dentro if");

    isMatriceCompatibile(numeroMatrice, mavo, umaClient, errors);



      SolmrLogger.debug(this,"\n#\n#\n"+errors.size()+" \n#\n#\n");

      if (errors!=null && errors.size()>0)

      {

        request.setAttribute("errors",errors);

        request.setAttribute("numeroMatrice", numeroMatrice);

        %><jsp:forward page="<%=VIEW%>" /><%

        return;

      }



    SolmrLogger.debug(this,"################ mavo : "+mavo);

    SolmrLogger.debug(this,"################ mavo.getIdMacchina()"+mavo.getIdMacchina());

    SolmrLogger.debug(this,"################ mavo.getIdMatrice()"+mavo.getIdMatrice());



    request.setAttribute("common", mavo);

    %><jsp:forward page="<%=VIEW%>" /><%

    return;

  }

  else if (request.getParameter("salva.x")!=null) // SALVA

  {

    SolmrLogger.debug(this,"\n\n\n");

    SolmrLogger.debug(this,"############# salvo la macchina modificata");



    SolmrLogger.debug(this,"mavo.getDatiMacchinaVO(): "+mavo.getDatiMacchinaVO());

    SolmrLogger.debug(this,"mavo.getIdMatriceLong(): "+mavo.getIdMatriceLong());



    if(mavo.getDatiMacchinaVO()!=null)

    {

      DatiMacchinaVO dmvo = mavo.getDatiMacchinaVO();

      dmvo.setMarca(request.getParameter("marca"));

      dmvo.setTipoMacchina(request.getParameter("tipoMacchina"));

      dmvo.setCalorie(request.getParameter("calorie"));

      dmvo.setPotenza(request.getParameter("potenza"));

      dmvo.setIdAlimentazione(request.getParameter("idAlimentazione"));

      dmvo.setIdNazionalita(request.getParameter("idNazionalita"));

      dmvo.setTara(request.getParameter("tara"));

      dmvo.setLordo(request.getParameter("lordo"));

      dmvo.setNumeroAssi(request.getParameter("numeroAssi"));

      dmvo.setIdCategoria(request.getParameter("idCategoria"));



      if(dmvo.getIdCategoriaLong() != null)

      {

        dmvo.setDescCategoria(umaClient.getDescCategoria(dmvo.getIdCategoriaLong()));

        dmvo.setCodBreveCategoriaMacchina(umaClient.getCodBreveCategoria(dmvo.getIdCategoriaLong()));

      }

      else

      {

        dmvo.setDescCategoria("");

        dmvo.setCodBreveCategoriaMacchina("");

      }



      dmvo.setExtIdUtenteAggiornamentoLong(ruoloUtenza.getIdUtente());



      if(request.getAttribute("tara") != null)

        dmvo.setTara( ((String)request.getAttribute("tara")));

      if(request.getAttribute("lordo") != null)

        dmvo.setLordo( ((String)request.getAttribute("lordo")));



      SolmrLogger.debug(this,"################ dmvo.getCalorie() "+dmvo.getCalorie());

      SolmrLogger.debug(this,"################ dmvo.getCodBreveGenereMacchina() "+dmvo.getCodBreveGenereMacchina());

      SolmrLogger.debug(this,"################ dmvo.getDataAggiornamento() "+dmvo.getDataAggiornamento());

      SolmrLogger.debug(this,"################ dmvo.getDescAlimentazione() "+dmvo.getDescAlimentazione());

      SolmrLogger.debug(this,"################ dmvo.getDescCategoria() "+dmvo.getDescCategoria());

      SolmrLogger.debug(this,"################ dmvo.getDescNaz() "+dmvo.getDescNazionalita());

      SolmrLogger.debug(this,"################ dmvo.getIdAlimentazione() "+dmvo.getIdAlimentazione());

      SolmrLogger.debug(this,"################ dmvo.getIdCategoria() "+dmvo.getIdCategoria());

      SolmrLogger.debug(this,"################ dmvo.getIdGenereMacchina() "+dmvo.getIdGenereMacchina());

      SolmrLogger.debug(this,"################ dmvo.getTipoMacchina() "+dmvo.getTipoMacchina());



      SolmrLogger.debug(this,"################ dmvo.getIdCategoria() "+dmvo.getIdCategoria());

      SolmrLogger.debug(this,"################ dmvo.getDescCategoria() "+dmvo.getDescCategoria());

      SolmrLogger.debug(this,"################ dmvo.getCodBreveCategoria() "+dmvo.getCodBreveCategoriaMacchina());



      SolmrLogger.debug(this,"################ dmvo.getTara() "+dmvo.getTara());

      SolmrLogger.debug(this,"################ dmvo.getTaraDouble() "+dmvo.getTaraDouble());

      SolmrLogger.debug(this,"################ dmvo.getLordo() "+dmvo.getLordo());

      SolmrLogger.debug(this,"################ dmvo.getLordoDouble() "+dmvo.getLordoDouble());



    }

    if(mavo.getMatriceVO() != null)

    {

      MatriceVO mvo = mavo.getMatriceVO();

      mvo.setIdCategoria((String)request.getParameter("idCategoria"));

      mavo.setMatriceVO(mvo);

    }

    // cambio i valori di matricolatelaio e matricolamotore nel VO



    mavo.setMatricolaTelaio(request.getParameter("matricolaTelaio"));

    mavo.setMatricolaMotore(request.getParameter("matricolaMotore"));



    mavo.setExtIdUtenteAggiornamentoLong(ruoloUtenza.getIdUtente());



    SolmrLogger.debug(this,"\n########################### matricolaTelaio :"+mavo.getMatricolaTelaio());

    SolmrLogger.debug(this,"########################### matricolaMotore :"+mavo.getMatricolaMotore());

    SolmrLogger.debug(this,"########################### ExtIdUtenteAggiornamento :"+mavo.getExtIdUtenteAggiornamento());

    SolmrLogger.debug(this,"########################### IdMacchina :"+mavo.getIdMacchina());

    SolmrLogger.debug(this,"########################### IdMatrice :"+mavo.getIdMatrice());



    errors = umaClient.validateMacchinaForUpdate(mavo);

    SolmrLogger.debug(this,"+++++++++++++++++++++++++++ errors :"+errors);

    if(mavo.getMatriceVO()!=null)

    {

      isMatriceCompatibile(numeroMatrice, mavo, umaClient, errors);

    }

    SolmrLogger.debug(this,"+++++++++++++++++++++++++++1 errors :"+errors);

    SolmrLogger.debug(this,"errors="+errors);

    if (errors!=null && errors.size()>0)

    {

      request.setAttribute("errors",errors);

      request.setAttribute("matricolaMotore", (String)request.getParameter("matricolaMotore"));

      request.setAttribute("matricolaTelaio", (String)request.getParameter("matricolaTelaio"));

      request.setAttribute("numeroMatrice", (String)request.getParameter("numeroMatrice"));

      request.setAttribute("idCategoria", (String)request.getParameter("idCategoria"));



      %><jsp:forward page="<%=VIEW%>" /><%

      return;

    }



    DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

    Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();



    umaClient.updateMacchina(mavo, ruoloUtenza, idDittaUma);



    SolmrLogger.debug(this,"########################### mavo.getIdMacchinaLong() : "+ mavo.getIdMacchinaLong());

    session.setAttribute("common", umaClient.getMacchinaById(mavo.getIdMacchinaLong()));



    %><jsp:forward page="<%=DETTAGLIO%>" /><%

    return;

  }else

  {

    try

    {

      SolmrLogger.debug(this,"umaClient="+umaClient);

      String idStr= (String) request.getParameter("idMacchina");

      try

      {

        idMacchina=new Long(idStr);

      }

      catch(Exception e)

      {

        // idGenereMacchina=null

        SolmrLogger.debug(this,"Exception : "+e.getMessage());

      }

      SolmrLogger.debug(this,"idMacchina="+idMacchina);

      SolmrLogger.debug(this,"idStr="+idStr);

      SolmrLogger.debug(this,"mavo.getIdMacchinaLong()"+mavo.getIdMacchinaLong());

      SolmrLogger.debug(this,"mavo.getIdMacchina()"+mavo.getIdMacchina());

      SolmrLogger.debug(this,"mavo.getDataAggiornamento()"+mavo.getDataAggiornamento());

    }

    catch(Exception e)

    {

      throwValidation(e.getMessage(),VIEW);

    }



  %><jsp:forward page="<%=VIEW%>" /><%

  }

%>



<%!

private void throwValidation(String msg,String validateUrl) throws ValidationException

{

  ValidationException valEx = new ValidationException(msg,validateUrl);

  valEx.addMessage(msg,"exception");

  throw valEx;

}

%>

<%!

  private void isMatriceCompatibile(String numeroMatrice, MacchinaVO mavo, UmaFacadeClient umaClient, ValidationErrors errors) throws ValidationException

  {

    try

    {

      if(!Validator.isNotEmpty(numeroMatrice))

      {

        errors.add("numeroMatrice", new ValidationError("Il numero matrice è un dato obbligatorio"));

      }

      MatriceVO mvo = umaClient.getMatriceByNumero(numeroMatrice);

      MatriceVO origMVO = mavo.getMatriceVO();

      if(mvo != null)

      {



        /*if(!Validator.isNotEmpty(mvo.getIdCategoria()))

        {

          errors.add("idCategoria", new ValidationError("La categoria è un dato obbligatorio"));

        }*/



        if( (mvo.getIdCategoria()!=null && origMVO.getIdCategoria()!=null)

                 && !(mvo.getIdCategoria().equals(origMVO.getIdCategoria() ))

                 ||

                 (mvo.getIdGenereMacchina()!=null && origMVO.getIdGenereMacchina()!=null)

                 && !(mvo.getIdGenereMacchina().equals(origMVO.getIdGenereMacchina())

            ))

        {

          errors.add("numeroMatrice", new ValidationError("La matrice indicata non può essere assegnata perchè appartiene ad un altro genere macchina o categoria"));

        }

        else

        {

          mavo.setMatriceVO(mvo);

        }

        SolmrLogger.debug(this,"mavo.setMatriceVO(mvo)");

        mavo.setIdMatrice(mavo.getMatriceVO().getIdMatrice());

        SolmrLogger.debug(this,"numero matrice :"+mavo.getMatriceVO().getNumeroMatrice());

      }

      SolmrLogger.debug(this,"fine try");

    }

    catch(SolmrException sex)

    {

      if(sex.getValidationErrors() != null)

      {

        Iterator it = sex.getValidationErrors().get("numeroMatrice");

        if(it.hasNext())

        {

          errors.add("numeroMatrice", (ValidationError)it.next());

        }

      }

      else

      {

        throwValidation(sex.getMessage(), VIEW);

      }

    }

    catch(Exception e)

    {

      SolmrLogger.debug(this,"e : "+e);

      SolmrLogger.debug(this,"\n\n e.getMessage()"+e.getMessage());

      throwValidation(e.getMessage(),VIEW);

    }

  }



%>

