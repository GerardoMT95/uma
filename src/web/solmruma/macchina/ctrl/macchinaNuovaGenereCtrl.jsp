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
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  public static final String nextUrlRimorchioAsmHtm="../layout/macchinaNuovaDatiCasoR-ASM.htm";
  public static final String nextUrlAltroGenereHtm="../layout/macchinaNuovaDatiCasoMatrice.htm";
  public static final String viewUrl="/macchina/view/macchinaNuovaGenereView.jsp";
  public static final String elencoMacchineUrlHtml="../layout/elencoMacchine.htm";
  public static final String nextMatrice="../layout/macchinaNuovaMatrice.htm";
  public static final String nextDatiMatrice="../layout/macchinaNuovaDatiCasoMatrice.htm";
  public static final String ALTROGENERE = "avantiAltroGenere";
  public static final String RIMORCHIOASM = "avantiRimorchioAsm";
%>

<%

  String iridePageName = "macchinaNuovaGenereCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  UmaFacadeClient umaClient = new UmaFacadeClient();

  if ( session.getAttribute("common")!=null && !(session.getAttribute("common") instanceof HashMap)){
    response.sendRedirect(elencoMacchineUrlHtml);
    return;
  }

  HashMap vecSession = null;
  MacchinaVO macchinaVO = null;
  MatriceVO matriceVO = null;
  DatiMacchinaVO datiMacchinaVO = null;

  SolmrLogger.debug(this,"\n\n\n############");
  if ( session.getAttribute("common")!=null){
    SolmrLogger.debug(this,"session.getAttribute(\"common\")!=null");
    vecSession = (HashMap) session.getAttribute("common");
    macchinaVO = (MacchinaVO) vecSession.get("macchinaVO");
    SolmrLogger.debug(this,"macchinaVO: "+macchinaVO);
    matriceVO = (MatriceVO) vecSession.get("matriceVO");
    if (matriceVO==null){
      //Sto ritornando indietro da Caso Rimorchio-Asm
      matriceVO = new MatriceVO();
    }
    SolmrLogger.debug(this,"matriceVO: "+matriceVO);
    datiMacchinaVO = (DatiMacchinaVO) vecSession.get("datiMacchinaVO");
    if (datiMacchinaVO==null){
      //Sto ritornando indietro da Caso Altro Genere
      datiMacchinaVO = new DatiMacchinaVO();
    }
    SolmrLogger.debug(this,"datiMacchinaVO: "+datiMacchinaVO);
  }
  else{
    SolmrLogger.debug(this,"session.getAttribute(\"common\")==null");
    macchinaVO = new MacchinaVO();
    matriceVO = new MatriceVO();
    datiMacchinaVO = new DatiMacchinaVO();
    vecSession = new HashMap();
    vecSession.put("macchinaVO",macchinaVO);
    vecSession.put("matriceVO",matriceVO);
    vecSession.put("datiMacchinaVO",datiMacchinaVO);
    session.setAttribute("common",vecSession);
  }

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  String idGenereMacchina=null;
  String idCategoria=null;

  //Controllo delle Pre-Condizioni
  try
  {
    SolmrLogger.debug(this,"\n\n\n\n\n\n\n\n\nInserimento !!!!!!!\n\n\n\n\n\n\n\n");
    umaClient.isDittaUmaBloccata(idDittaUma);
    umaClient.isDittaUmaCessata(idDittaUma);

    //Se l'utente è un PA abilitato e appartiene alla provincia della Ditta Uma
    if( ruoloUtenza.isUtenteProvinciale()){
      //umaClient.isFunzionarioPAAutorizzato(ruoloUtenza, idDittaUma);
    }

    //Se l'utente è un intermediario o un impresa agricola
    if( ruoloUtenza.isUtenteIntermediario() ){
      throw new ValidationException("Utente intermediario non abilitato ad operare sulla ditta Uma");
    }
  }
  catch(Exception e)
  {
    session.setAttribute("notifica",e.getMessage());
    response.sendRedirect(elencoMacchineUrlHtml);
    return;
  }

  //Caso di Avanti su Rimorchio o ASM
  if (request.getParameter(RIMORCHIOASM)!=null)
  {
    // Rimorchio Asm
    SolmrLogger.debug(this,RIMORCHIOASM);
    try
    {
      SolmrLogger.debug(this,"request.getParameter(\"idGenereMacchina1\"): "+request.getParameter("idGenereMacchina1"));
      idGenereMacchina = request.getParameter("idGenereMacchina1");

      SolmrLogger.debug(this,"request.getParameter(\"idCategoria1\"): "+request.getParameter("idCategoria1"));
      idCategoria = request.getParameter("idCategoria1");

      ValidationErrors vErr = validateRimorchioAsm(datiMacchinaVO, request);
      if (vErr.size()!=0){
        SolmrLogger.debug(this,"\n\n\n######");
        SolmrLogger.debug(this,"vErr.size()!=0");
        SolmrLogger.debug(this,"vErr: "+vErr);

        request.setAttribute("errors", vErr);
        %><jsp:forward page="<%=viewUrl%>" /><%
        return;
      }
      else{
        SolmrLogger.debug(this,"\n\n\n######");
        SolmrLogger.debug(this,"vErr.size()==0");
      }

      SolmrLogger.debug(this,"\n\n\nààààààààààààààààààààààààààààààà");
      SolmrLogger.debug(this,"datiMacchinaVO.getIdGenereMacchinaLong(): "+datiMacchinaVO.getIdGenereMacchinaLong());
      SolmrLogger.debug(this,"datiMacchinaVO.getIdCategoriaLong(): "+datiMacchinaVO.getIdCategoriaLong());

      SolmrLogger.debug(this,"idGenereMacchina: "+idGenereMacchina);
      SolmrLogger.debug(this,"idCategoria: "+idCategoria);

      String descGenereMacchina = umaClient.getDescGenereMacchina(new Long(idGenereMacchina));
      SolmrLogger.debug(this,"descGenereMacchina: "+descGenereMacchina);
      String descCategoria = umaClient.getDescCategoria(new Long(idCategoria));
      SolmrLogger.debug(this,"descCategoria: "+descCategoria);

      String codBreveGenereMacchina = umaClient.getCodBreveGenereMacchina(new Long(idGenereMacchina));
      SolmrLogger.debug(this,"codBreveGenereMacchina: "+codBreveGenereMacchina);
      String codBreveCategoria = umaClient.getCodBreveCategoria(new Long(idCategoria));
      SolmrLogger.debug(this,"codBreveCategoria: "+codBreveCategoria);

      datiMacchinaVO.setDescGenereMacchina(descGenereMacchina);
      datiMacchinaVO.setDescCategoria(descCategoria);
      datiMacchinaVO.setCodBreveGenereMacchina(codBreveGenereMacchina);
      datiMacchinaVO.setCodBreveCategoriaMacchina(codBreveCategoria);

      SolmrLogger.debug(this,"datiMacchinaVO.getIdGenereMacchina(): "+datiMacchinaVO.getIdGenereMacchina());
      SolmrLogger.debug(this,"datiMacchinaVO.getIdCategoria(): "+datiMacchinaVO.getIdCategoria());
      SolmrLogger.debug(this,"datiMacchinaVO.getDescGenereMacchina(): "+datiMacchinaVO.getDescGenereMacchina());
      SolmrLogger.debug(this,"datiMacchinaVO.getDescCategoria(): "+datiMacchinaVO.getDescCategoria());
      SolmrLogger.debug(this,"datiMacchinaVO.getCodBreveGenereMacchina(): "+datiMacchinaVO.getCodBreveGenereMacchina());
      SolmrLogger.debug(this,"datiMacchinaVO.getCodBreveCategoriaMacchina(): "+datiMacchinaVO.getCodBreveCategoriaMacchina());

      vecSession = new HashMap();
      vecSession.put("macchinaVO",macchinaVO);
      macchinaVO.setMatriceVO(null);
      vecSession.put("datiMacchinaVO",datiMacchinaVO);
      session.setAttribute("common",vecSession);
      response.sendRedirect(nextUrlRimorchioAsmHtm);
      return;

    }
    catch(Exception e)
    {
      this.throwValidation(e.getMessage(),viewUrl);
    }
  }
  else
  {
    //Caso di avanti su Altro genere
    SolmrLogger.debug(this,ALTROGENERE);

    if (request.getParameter("avantiAltroGenere")!=null)
    {
      SolmrLogger.debug(this,"avantiAltroGenere");
      SolmrLogger.debug(this,"macchinaVO: "+macchinaVO);
      vecSession.remove("datiMacchinaVO");
      if(macchinaVO.getMatriceVO()==null){
        macchinaVO.setMatriceVO(new MatriceVO());
        SolmrLogger.debug(this,"macchinaVO.getMatriceVO()==null");
      }
      SolmrLogger.debug(this,"macchinaVO.getMatriceVO(): "+macchinaVO.getMatriceVO());
      ValidationErrors errors=validateAltroGenere(macchinaVO.getMatriceVO(),macchinaVO,request);
      if (errors!=null && errors.size()!=0)
      {
        request.setAttribute("errors",errors);
      }
      else
      {
        matriceVO=macchinaVO.getMatriceVO();
        Vector elencoMatrici=getElencoMatrici(umaClient,
                                          macchinaVO.getMatriceVO().getIdGenereMacchinaLong(),
                                          macchinaVO.getMatriceVO().getIdCategoriaLong(),
                                          macchinaVO.getMatriceVO().getDescMarca(),
                                          macchinaVO.getMatriceVO().getTipoMacchina(),
                                          macchinaVO.getMatriceVO().getNumeroMatrice(),
                                          macchinaVO.getMatriceVO().getNumeroOmologazione());
        if (elencoMatrici==null || elencoMatrici.size()==0)
        {
          setError(request,SolmrConstants.MATRICE_NON_TROVATA);
          %><jsp:forward page="<%=viewUrl%>" /><%
        }
        else
        {
          SolmrLogger.debug(this,"\n\nelencoMatrici.size()="+elencoMatrici.size());
          if (elencoMatrici.size()==1)
          {
            vecSession.put("matriceVO",umaClient.getMatrice((Long)elencoMatrici.get(0)));
            SolmrLogger.debug(this,"\n\n\n######################");
            SolmrLogger.debug(this,"matriceVO: "+matriceVO);
            SolmrLogger.debug(this,"######################");
            session.setAttribute("common",vecSession);
            response.sendRedirect(nextDatiMatrice);
          }
          else
          {
            if (matriceVO.getIdGenereMacchina()!=null){
              idGenereMacchina=matriceVO.getIdGenereMacchina();
              SolmrLogger.debug(this,"idGenereMacchina: "+idGenereMacchina);
              String descGenereMacchina = umaClient.getDescGenereMacchina(new Long(matriceVO.getIdGenereMacchina()));
              String codBreveGenereMacchina = umaClient.getCodBreveGenereMacchina(new Long(idGenereMacchina));
              SolmrLogger.debug(this,"descGenereMacchina: "+descGenereMacchina);
              matriceVO.setDescGenereMacchina(descGenereMacchina);
              matriceVO.setCodBreveGenereMacchina(codBreveGenereMacchina);
            }
            else{
              SolmrLogger.debug(this,"matriceVO.getIdGenereMacchina()==null");
            }

            if (Validator.isNotEmpty(matriceVO.getIdCategoria())){
              idCategoria=matriceVO.getIdCategoria();
              SolmrLogger.debug(this,"idCategoria: "+idCategoria);
              String descCategoria = umaClient.getDescCategoria(new Long(idCategoria));
              String codBreveCategoria = umaClient.getDescCategoria(new Long(idCategoria));
              SolmrLogger.debug(this,"descCategoria: "+descCategoria);
              matriceVO.setDescCategoria(descCategoria);
              matriceVO.setCodBreveCategoriaMacchina(codBreveCategoria);
            }
            else{
              SolmrLogger.debug(this,"matriceVO.getIdCategoria()==null");
            }

            SolmrLogger.debug(this,"\n\n\n*********************");
            SolmrLogger.debug(this,"matriceVO.getIdGenereMacchina(): "+matriceVO.getIdGenereMacchina());
            SolmrLogger.debug(this,"matriceVO.getIdCategoria(): "+matriceVO.getIdCategoria());
            SolmrLogger.debug(this,"matriceVO.getDescGenereMacchina(): "+matriceVO.getDescGenereMacchina());
            SolmrLogger.debug(this,"matriceVO.getDescCategoria(): "+matriceVO.getDescCategoria());
            SolmrLogger.debug(this,"matriceVO.getCodBreveCategoriaMacchina(): "+matriceVO.getCodBreveCategoriaMacchina());
            SolmrLogger.debug(this,"matriceVO.getCodBreveGenereMacchina(): "+matriceVO.getCodBreveGenereMacchina());
            SolmrLogger.debug(this,"*********************");


            vecSession.put("elencoMatrici",elencoMatrici);
            session.setAttribute("common",vecSession);
            response.sendRedirect(nextMatrice);
          }
        }
        return;
      }
    }
    // Caricamento dati ricerca in macchinaNuovaGenere
    SolmrLogger.debug(this,"Caricamento dati ricerca");

    vecSession = new HashMap();
    vecSession.put("macchinaVO",macchinaVO);
    vecSession.put("datiMacchinaVO",datiMacchinaVO);
    session.setAttribute("common",vecSession);
    %><jsp:forward page="<%=viewUrl%>" /><%
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

private void throwValidation(String msg,String validateUrl) throws ValidationException
{
  ValidationException valEx = new ValidationException(msg,validateUrl);
  valEx.addMessage(msg,"exception");
  throw valEx;
}
private void print(MacchinaVO macchinaVO, DatiMacchinaVO datiMacchinaVO, MatriceVO matriceVO){
  SolmrLogger.debug(this,"*************************************" );
  SolmrLogger.debug(this,"datiMacchinaVO.getIdMacchina(): "+datiMacchinaVO.getIdGenereMacchina() );
  SolmrLogger.debug(this,"datiMacchinaVO.getIdCategoria(): "+datiMacchinaVO.getIdCategoria() );

  SolmrLogger.debug(this,"matriceVO.getIdMacchina(): "+datiMacchinaVO.getIdGenereMacchina() );
  SolmrLogger.debug(this,"matriceVO.getIdCategoria(): "+datiMacchinaVO.getIdCategoria() );

  SolmrLogger.debug(this,"*************************************" );
}
private ValidationErrors validateRimorchioAsm(DatiMacchinaVO datiMacchinaVO, HttpServletRequest request){
  ValidationErrors errors =  new ValidationErrors();
  SolmrLogger.debug(this,"request.getParameter(\"idGenereMacchina1\"): "+request.getParameter("idGenereMacchina1"));
  if (!Validator.isNotEmpty(request.getParameter("idGenereMacchina1")))
  {
    datiMacchinaVO.setIdGenereMacchina(null);
    errors.add("idGenereMacchina1",new ValidationError("Selezionare un genere macchina"));
    SolmrLogger.debug(this,"1A");
  }
  else
  {
    SolmrLogger.debug(this,"request.getParameter(\"idGenereMacchina1\"): " + request.getParameter("idGenereMacchina1"));
    datiMacchinaVO.setIdGenereMacchina(request.getParameter("idGenereMacchina1"));
    SolmrLogger.debug(this,"1B");
  }

  if (!Validator.isNotEmpty(request.getParameter("idCategoria1")))
  {
    datiMacchinaVO.setIdCategoria(null);
    errors.add("idCategoria1",new ValidationError("Selezionare una categoria macchina"));
    SolmrLogger.debug(this,"2A");
  }
  else
  {
    SolmrLogger.debug(this,"idCategoria1 : " + request.getParameter("idCategoria1"));
    datiMacchinaVO.setIdCategoria(request.getParameter("idCategoria1"));
    SolmrLogger.debug(this,"2B");
  }

  return errors;
}

private ValidationErrors validateAltroGenere(MatriceVO matriceVO, MacchinaVO macchinaVO, HttpServletRequest request){
  ValidationErrors errors =  new ValidationErrors();
  boolean numeroMatricePresent=false;
  boolean genereMarcaPresent=true;
  boolean numeroOmologazionePresent=false;
  int errorVal=0;

  if (!Validator.isNotEmpty(request.getParameter("numeroOmologazione")))
  {
    matriceVO.setNumeroOmologazione(null);
    numeroOmologazionePresent=false;
    errorVal+=8;
  }
  else
  {
    matriceVO.setNumeroOmologazione(request.getParameter("numeroOmologazione"));
    numeroOmologazionePresent=true;
  }

  if (!Validator.isNotEmpty(request.getParameter("numeroMatrice")))
  {
    matriceVO.setNumeroMatrice(null);
    numeroMatricePresent=false;
    errorVal+=1;
  }
  else
  {
    matriceVO.setNumeroMatrice(request.getParameter("numeroMatrice"));
    numeroMatricePresent=true;
  }
  if (!Validator.isNotEmpty(request.getParameter("idGenereMacchina2")))
  {
    matriceVO.setIdGenereMacchina(null);
    genereMarcaPresent=false;
    errorVal+=2;
  }
  else
  {
    matriceVO.setIdGenereMacchina(request.getParameter("idGenereMacchina2"));
  }

  SolmrLogger.debug(this,"request.getParameter(\"marcaDesc\"): "+request.getParameter("marcaDesc"));
  if (!Validator.isNotEmpty(request.getParameter("marcaDesc")))
  {
    matriceVO.setIdMarca(null);
    matriceVO.setDescMarca(null);
    genereMarcaPresent=false;
    errorVal+=4;
  }
  else
  {
    matriceVO.setIdMarca(request.getParameter("idMarca"));
    matriceVO.setDescMarca(request.getParameter("marcaDesc"));
  }
  SolmrLogger.debug(this,"errorVal="+errorVal);
  SolmrLogger.debug(this,"numeroMatricePresent="+numeroMatricePresent);
  SolmrLogger.debug(this,"genereMarcaPresent="+genereMarcaPresent);
  SolmrLogger.debug(this,"numeroOmologazionePresent="+numeroOmologazionePresent);
  if (!numeroMatricePresent && !genereMarcaPresent && !numeroOmologazionePresent)
  {
    SolmrLogger.debug(this,"Errror!");
    ValidationError valError=new ValidationError("Indicare almeno il numero matrice oppure il numero omologazione oppure la coppia genere macchina, marca");
    if ((errorVal & 8)!=0)
    {
      errors.add("numeroOmologazione",valError);
    }
    if ((errorVal & 4)!=0)
    {
      errors.add("idMarca",valError);
    }
    if ((errorVal & 2)!=0)
    {
      errors.add("idGenereMacchina2",valError);
    }
    if ((errorVal & 1)!=0)
    {
      errors.add("numeroMatrice",valError);
    }
  }

  SolmrLogger.debug(this,"idCategoria2="+request.getParameter("idCategoria2"));
  SolmrLogger.debug(this,"tipoMacchina="+request.getParameter("tipoMacchina"));
  SolmrLogger.debug(this,"numeroOmologazione="+request.getParameter("numeroOmologazione"));
  matriceVO.setIdCategoria(request.getParameter("idCategoria2"));
  matriceVO.setTipoMacchina(request.getParameter("tipoMacchina"));
  matriceVO.setNumeroOmologazione(request.getParameter("numeroOmologazione"));

  return errors;
}

public Vector getElencoMatrici(UmaFacadeClient umaClient,
                               Long idGenereMacchina,
                               Long idCategoria,
                               String descMarca,
                               String tipoMacchina,
                               String numeroMatrice,
                               String numeroOmologazione)
    throws SolmrException
{
  if ("".equals(descMarca))
  {
    descMarca=null;
  }
  if ("".equals(tipoMacchina))
  {
    tipoMacchina=null;
  }
  if ("".equals(numeroMatrice))
  {
    numeroMatrice=null;
  }
  if ("".equals(numeroOmologazione))
  {
    numeroOmologazione=null;
  }
  return umaClient.getElencoMatrici(idGenereMacchina,idCategoria,descMarca,
                                    tipoMacchina,numeroMatrice,numeroOmologazione);
}
%>