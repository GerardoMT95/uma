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


<jsp:useBean id="targaVO" scope="request" class="it.csi.solmr.dto.uma.TargaVO">

  <jsp:setProperty name="targaVO" property="*" />

</jsp:useBean>

<jsp:useBean id="dittaProvenienzaVO" scope="request" class="it.csi.solmr.dto.uma.DittaUMAVO">

  <jsp:setProperty name="dittaProvenienzaVO" property="*" />

</jsp:useBean>

<%!

  private static final String VIEW="/macchina/view/macchinaUsataTargaView.jsp";

  private static final String PAGE_NO_TARGA="../layout/macchinaUsataNonTrovataGenere.htm";

  private static final String PAGE_CASO_MATRICE="../layout/macchinaUsataTrovataDatiCasoMatrice.htm";

  private static final String PAGE_CASO_R_ASM="../layout/macchinaUsataTrovataDatiCasoR-ASM.htm";

  private static final String ELENCO="../layout/elencoMacchine.htm";

  private static final String ELENCO_BIS="../layout/elencoMacchineBis.htm";

  private static final String PAGE_TARGA_TOBECONFIG_INESISTENTE="../../layout/confermaTargaNonTrovata.htm";

%>

<%

  String iridePageName = "macchinaUsataTargaCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  try

  {

    DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

    Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

    UmaFacadeClient umaClient = new UmaFacadeClient();

    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

    umaClient.isUtenteAutorizzatoMacchine(idDittaUma,ruoloUtenza);

  }

  catch(Exception e)

  {

    session.setAttribute("notifica", e.getMessage());

    if (request.getParameter("pageFrom")!=null)

    {

      response.sendRedirect(ELENCO_BIS);

    }

    else

    {

      response.sendRedirect(ELENCO);

    }

  }

  try

  {

    if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))

    {

      session.setAttribute("pageFrom","bis");

    }

    else

    {

      session.removeAttribute("pageFrom");

    }

    if (controllerMain(application,session,request,response,targaVO,dittaProvenienzaVO))

    {

      %><jsp:forward page="<%=VIEW%>"/><%

    }

  }

  catch(Exception e)

  {

    ValidationErrors errors=new ValidationErrors();

    errors.add("error",new ValidationError(e.getMessage()));

    request.setAttribute("errors",errors);

    %><jsp:forward page="<%=VIEW%>"/><%

  }

%>

<%!

  private boolean controllerMain(ServletContext application,

                              HttpSession session,

                              HttpServletRequest request,

                              HttpServletResponse response,

                              TargaVO targaVO,

                              DittaUMAVO dittaProvenienzaVO)

      throws Exception

  {

    DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

    Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

    UmaFacadeClient umaClient = new UmaFacadeClient();

    HashMap common;

    if (session.getAttribute("common") instanceof java.util.HashMap)

    {

      common=(HashMap)session.getAttribute("common");

    }

    else

    {

      common=null;

    }

    String conTarga=request.getParameter("conTarga");

    SolmrLogger.debug(this,"common instanceof java.util.HashMap="+(common instanceof java.util.HashMap));

    if (common==null)

    {

      SolmrLogger.debug(this,"ELIMINAZIONE DATI DALLA SESSION E INSERIMENTO VALORI DI DEFAULT");

      common=new HashMap();

      MacchinaVO macchinaVO=new MacchinaVO();

      macchinaVO.setTargaCorrente(targaVO);

      common.put("macchinaVO", macchinaVO);

      common.put("dittaProvenienzaVO",dittaProvenienzaVO);

      common.put("conTarga","yes");

      session.setAttribute("common",common);

    }

    else

    {

      if (common.get("indietro")==null)

      {

        SolmrLogger.debug(this,"indietro");

        MacchinaVO macchinaVO=(MacchinaVO)common.get("macchinaVO");

        macchinaVO.setTargaCorrente(targaVO);

        common.put("dittaProvenienzaVO",dittaProvenienzaVO);

        common.put("conTarga","yes");

      }

      else

      {

        common.remove("indietroMacchinaUsataTarga");

      }

    }

    session.setAttribute("common",common);



    if (request.getParameter("avanti")!=null)

    {

      SolmrLogger.debug(this,"avanti");

      common.put("dittaProvenienzaVO",dittaProvenienzaVO);

      common.put("conTarga",conTarga);

      common.remove("fuoriRegione");

      SolmrLogger.debug(this,"conTarga="+conTarga);

      MacchinaVO macchinaVO=(MacchinaVO)common.get("macchinaVO");

      macchinaVO.setTargaCorrente(targaVO);

      session.setAttribute("common",common);

      String idRegione=umaClient.getRegioneByProvincia(dittaProvenienzaVO.getProvincia());

      String isMacchinaConTarga=request.getParameter("conTarga");

      ValidationErrors errors=validate(targaVO,

                                       dittaProvenienzaVO,

                                       isMacchinaConTarga,

                                       idRegione,

                                       umaClient);

      if (errors!=null)

      {

        request.setAttribute("errors",errors);

      }

      else

      {

        if ("no".equalsIgnoreCase(conTarga))

        {

          targaVO.setNumeroTarga(null);

          targaVO.setIdTarga(null);

          macchinaVO.setDatiMacchinaVO(new DatiMacchinaVO());

          if (!((String)SolmrConstants.get("ID_REGIONE")).equals(idRegione))

          {

            common.put("fuoriRegione","fuoriRegione");

          }

          session.setAttribute("common",common);

          response.sendRedirect(PAGE_NO_TARGA);

          return false;

        }

        targaVO.setIdTarga(targaVO.getIdTarga().trim());

        targaVO.setNumeroTarga(targaVO.getNumeroTarga().trim());

        try

        {

          MacchinaVO mVO=umaClient.getMacchinaByTarga(targaVO.getIdTargaLong(),

              targaVO.getNumeroTarga());

          if (mVO!=null)

          {

            umaClient.isMacchinaRubata(mVO.getIdMacchinaLong());

            umaClient.isUltimaTarga(mVO.getTargaCorrente().getIdNumeroTargaLong());

            umaClient.isMacchinaNonInCarico(mVO.getIdMacchinaLong());

            dittaProvenienzaVO.setDittaUMA(dittaProvenienzaVO.getDittaUMA().trim());



            //Implementazione acquisto usato di una macchina venduta fuori regione - Begin

            if ( umaClient.isProvinciaTOBECONFIGse(dittaProvenienzaVO.getProvincia()).booleanValue() ){

              SolmrLogger.debug(this,"!umaClient.isProvinciaTOBECONFIGse("+dittaProvenienzaVO.getProvincia()+")");

              if (SolmrConstants.ID_REGIONE.equals(idRegione))

              {

                umaClient.wasMacchinaInCarico(mVO.getIdMacchinaLong(),new Long(dittaProvenienzaVO.getDittaUMA()),dittaProvenienzaVO.getProvincia());

              }

              else

              {

                session.setAttribute("AcquistoMacchinaVendutaFuoriRegione", "Yes");

                throw new SolmrException("Attenzione: impossibile proseguire; la macchina risulta già presente negli archivi regionali, controllare il numero targa e/o la ditta di provenienza");

              }

            }

            //Implementazione acquisto usato di una macchina venduta fuori regione - End



            dittaProvenienzaVO.setProvincia(dittaProvenienzaVO.getProvincia().trim().toUpperCase());

            common.put("macchinaVO",mVO);

            session.setAttribute("common",common);

            if (mVO.getMatriceVO()!=null)

            {

              SolmrLogger.debug(this,"CASO_MATRICE");

              response.sendRedirect(PAGE_CASO_MATRICE);

            }

            else

            {

              SolmrLogger.debug(this,"CASO_R_ASM");

              SolmrLogger.debug(this,"Redirecting on "+PAGE_CASO_R_ASM);

              response.sendRedirect(PAGE_CASO_R_ASM);

            }

            return false;

          }

          else

          {

            SolmrLogger.debug(this,"CASO_NO_TARGA");

            macchinaVO.setMatriceVO(new MatriceVO());

            macchinaVO.setDatiMacchinaVO(new DatiMacchinaVO());

            if (((String)SolmrConstants.get("ID_REGIONE")).equals(idRegione))

            {

              session.setAttribute("common",common);

              response.sendRedirect(PAGE_TARGA_TOBECONFIG_INESISTENTE);

            }

            else

            {

              common.put("fuoriRegione","fuoriRegione");

              session.setAttribute("common",common);

              SolmrLogger.debug(this,"common.get(\"fuoriRegione\")="+common.get("fuoriRegione"));

              response.sendRedirect(PAGE_NO_TARGA);

            }

            return false;

          }

        }

        catch(SolmrException e)

        {

          if (SolmrConstants.TARGA_NON_TROVATA.equals(e.getMessage()))

          {

            SolmrLogger.debug(this,"CASO_NO_TARGA (Targa non trovata!)");

            SolmrLogger.debug(this,"numeroTarga = "+macchinaVO.getTargaCorrente().getNumeroTarga());

            macchinaVO.setMatriceVO(new MatriceVO());

            macchinaVO.setDatiMacchinaVO(new DatiMacchinaVO());

            if (((String)SolmrConstants.get("ID_REGIONE")).equals(idRegione))

            {

              session.setAttribute("common",common);

              response.sendRedirect(PAGE_TARGA_TOBECONFIG_INESISTENTE);

            }

            else

            {

              common.put("fuoriRegione","fuoriRegione");

              session.setAttribute("common",common);

              response.sendRedirect(PAGE_NO_TARGA);

            }

            return false;

          }

          throw e;

        }

      }

    }

    return true;

  }



  private it.csi.solmr.util.ValidationErrors validate(TargaVO targaVO,

                                                      DittaUMAVO dittaVO,

                                                      String conTarga,

                                                      String idRegione,

                                                      UmaFacadeClient umaClient)

  {

    ValidationErrors errors=new ValidationErrors();

    if (Validator.isNotEmpty(conTarga))

    {

      if ("yes".equalsIgnoreCase(conTarga))

      {

        if (!Validator.isNotEmpty(targaVO.getIdTarga()))

        {

          errors.add("idTarga",new ValidationError("Selezionare il tipo di targa!"));

        }

        if (!Validator.isNotEmpty(targaVO.getNumeroTarga()))

        {

          errors.add("numeroTarga",new ValidationError("Inserire il numero di targa del veicolo"));

        }

        else

        {

          targaVO.setNumeroTarga(targaVO.getNumeroTarga().trim().toUpperCase());

        }

        //Controllo formato Targa - Begin

        //Verifica che la targa sia in formato UMA o stradale

        // PRNNNNNN o LLNNNL
		
        
        // TOLTI CONTROLLI SUL FORMATO DELLA TARGA PER LA TOBECONFIG
        /*
        try{

          umaClient.isTargaValida(targaVO.getNumeroTarga());

        }catch(SolmrException ex){

          if( ex.getMessage().equalsIgnoreCase( ""+SolmrConstants.get("FORMATO_TARGA_NON_VALIDA")) ){

            errors.add("numeroTarga",new ValidationError( ""+SolmrConstants.get("FORMATO_TARGA_NON_VALIDA") ));

          }

        }*/

        //Controllo formato Targa - End

      }

      else

      {

        if (Validator.isNotEmpty(targaVO.getIdTarga()))

        {

          errors.add("idTarga",new ValidationError("Il tipo di targa non deve essere specificato per una macchina senza targa"));

        }

        if (Validator.isNotEmpty(targaVO.getNumeroTarga()))

        {

          errors.add("numeroTarga",new ValidationError("Il numero targa non deve essere specificato per una macchina senza targa"));

        }

      }

      if (!Validator.isNotEmpty(dittaVO.getProvincia()))

      {

        errors.add("provincia",new ValidationError("Inserire la provincia di appartenenza della ditta uma"));

      }

      else

      {

        dittaVO.setProvincia(dittaVO.getProvincia().trim().toUpperCase());

        if (idRegione==null || "".equals(idRegione))

        {

          errors.add("provincia",new ValidationError("Provincia inesistente"));

        }

      }

      if (!Validator.isNotEmpty(dittaVO.getDittaUMA()))

      {

        errors.add("dittaUMA",new ValidationError("Inserire il numero della ditta uma"));

      }

      else

      {

        if (!Validator.isNumericInteger(dittaVO.getDittaUMA()))

        {

          errors.add("dittaUMA",new ValidationError("Numero di ditta non valido"));

        }

      }

    }

    else

    {

      errors.add("conTarga",new ValidationError("Selezionare se è una macchina con targa o senza targa"));

    }

    if (errors.size()==0)

    {

      return null;

    }

    return errors;

  }



  private void throwValidation(String msg,String validateUrl) throws ValidationException

  {

    ValidationException valEx = new ValidationException("Errore: eccezione="+msg,validateUrl);

    valEx.addMessage(msg,"exception");

    throw valEx;

}

%>



