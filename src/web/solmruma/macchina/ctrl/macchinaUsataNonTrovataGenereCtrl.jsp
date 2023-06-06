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
  public static final String NEXT_DATI_R_ASM="../layout/macchinaUsataNonTrovataDatiCasoR-ASM.htm";
  public static final String NEXT_MATRICE="../layout/macchinaUsataNonTrovataMatrice.htm";
  public static final String NEXT_DATI_MATRICE="../layout/macchinaUsataNonTrovataDatiCasoMatrice.htm";
  public static final String PREV="../layout/macchinaUsataTarga.htm";
  public static final String VIEW="/macchina/view/macchinaUsataNonTrovataGenereView.jsp";
  public static final String ELENCO_MACCHINE="../layout/elencoMacchine.htm";
%>
<%

  String iridePageName = "macchinaUsataNonTrovataGenereCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  if ( session.getAttribute("common")==null || !(session.getAttribute("common") instanceof HashMap))
  {
    response.sendRedirect(ELENCO_MACCHINE);
    return;
  }
  try
  {
    DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
    Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

    UmaFacadeClient umaClient = new UmaFacadeClient();
    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

    HashMap common = (HashMap) session.getAttribute("common");
    MacchinaVO macchinaVO=(MacchinaVO) common.get("macchinaVO");
/******************************************************************************/
/*                      AVANTI RIMORCHIO O ASM                                */
/******************************************************************************/
    if (request.getParameter("avantiRimorchioAsm")!=null)
    {
      // Rimorchio Asm
      SolmrLogger.debug(this,"\n\n\n\n\nsono in avantiRimorchioAsm\n\n\n\n");
      try
      {
        String idGenereMacchina = request.getParameter("idGenereMacchina1");
        String idCategoria = request.getParameter("idCategoria1");
        SolmrLogger.debug(this,"macchinaVO="+macchinaVO);
        DatiMacchinaVO datiMacchinaVO=macchinaVO.getDatiMacchinaVO();
        SolmrLogger.debug(this,"datiMacchinaVO="+datiMacchinaVO);
        SolmrLogger.debug(this,"prima validateRimorchioAsm");
        ValidationErrors vErr = validateRimorchioAsm(datiMacchinaVO, request);
        SolmrLogger.debug(this,"dopo validateRimorchioAsm");
        if (vErr.size()!=0)
        {
          request.setAttribute("errors", vErr);
          SolmrLogger.debug(this,"errors="+vErr);
          %><jsp:forward page="<%=VIEW%>" /><%
          return;
        }

        String descGenereMacchina = umaClient.getDescGenereMacchina(new Long(idGenereMacchina));
        String descCategoria = umaClient.getDescCategoria(new Long(idCategoria));
        String codBreveGenereMacchina=umaClient.getCodBreveGenereMacchina(new Long(idGenereMacchina));
        String codBreveCategoria=umaClient.getCodBreveCategoria(new Long(idCategoria));
        datiMacchinaVO.setCodBreveCategoriaMacchina(codBreveCategoria);
        datiMacchinaVO.setCodBreveGenereMacchina(codBreveGenereMacchina);
        datiMacchinaVO.setDescGenereMacchina(descGenereMacchina);
        datiMacchinaVO.setDescCategoria(descCategoria);
        SolmrLogger.debug(this,"codBreveGenereMacchina="+codBreveGenereMacchina);
        SolmrLogger.debug(this,"codBreveCategoria="+codBreveCategoria);

        common.put("macchinaVO",macchinaVO);
        session.setAttribute("common",common);
        response.sendRedirect(NEXT_DATI_R_ASM);
        return;
      }
      catch(Exception e)
      {
        this.setError(request,e.getMessage());
      }
    }

/******************************************************************************/
/*                        AVANTI ALTRO GENERE                                 */
/******************************************************************************/
    if (request.getParameter("avantiAltroGenere")!=null)
    {
      SolmrLogger.debug(this,"avantiAltroGenere");
      ValidationErrors errors=validateAltroGenere(macchinaVO.getMatriceVO(),macchinaVO,request);
      if (errors!=null && errors.size()!=0)
      {
        request.setAttribute("errors",errors);
      }
      else
      {
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
          %><jsp:forward page="<%=VIEW%>" /><%
        }
        else
        {
          SolmrLogger.debug(this,"elencoMatrici.size()="+elencoMatrici.size());
          macchinaVO.setMatricolaMotore(null);
          macchinaVO.setMatricolaTelaio(null);
          if (elencoMatrici.size()==1)
          {
            common.put("matriceVO",umaClient.getMatrice((Long)elencoMatrici.get(0)));
            common.remove("elencoMatrici");
            session.setAttribute("common",common);
            response.sendRedirect(NEXT_DATI_MATRICE);
          }
          else
          {
            Long idGenere=macchinaVO.getMatriceVO().getIdGenereMacchinaLong();
            SolmrLogger.debug(this,"idGenere="+idGenere);
            if (Validator.isNotEmpty(idGenere))
            {
              String codBreveGenereMacchina=umaClient.getCodBreveGenereMacchina(idGenere);
              String descGenereMacchina=umaClient.getDescGenereMacchina(idGenere);
              macchinaVO.getMatriceVO().setCodBreveGenereMacchina(codBreveGenereMacchina);
              macchinaVO.getMatriceVO().setDescGenereMacchina(descGenereMacchina);
            }
            else
            {
              macchinaVO.getMatriceVO().setCodBreveGenereMacchina(null);
              macchinaVO.getMatriceVO().setDescGenereMacchina(null);
            }

            Long idCategoria=macchinaVO.getMatriceVO().getIdCategoriaLong();
            if (Validator.isNotEmpty(idCategoria))
            {
              String codBreveCategoria=umaClient.getCodBreveCategoria(idCategoria);
              String descCategoria=umaClient.getDescCategoria(idCategoria);
              macchinaVO.getMatriceVO().setCodBreveCategoriaMacchina(codBreveCategoria);
              macchinaVO.getMatriceVO().setDescCategoria(descCategoria);
            }
            else
            {
              macchinaVO.getMatriceVO().setCodBreveCategoriaMacchina(null);
              macchinaVO.getMatriceVO().setDescCategoria(null);
            }

            common.put("elencoMatrici",elencoMatrici);
            session.setAttribute("common",common);
            response.sendRedirect(NEXT_MATRICE);
          }
        }
        return;
      }
    }

/******************************************************************************/
/*                              INDIETRO                                      */
/******************************************************************************/
    if (request.getParameter("indietro")!=null)
    {
      common.put("indietro","indietro");
      SolmrLogger.debug(this,"PREV");
      response.sendRedirect(PREV);
      return;
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
      setError(request,"Si è verificato un errore di sistema");
    }
  }
  %><jsp:forward page="<%=VIEW%>" /><%
%>

<%!

private void setError(HttpServletRequest request, String msg)
{
  SolmrLogger.debug(this,"\n\n\n\n\n\n\n\n\n\n\nmsg="+msg+"\n\n\n\n\n\n\n\n");
  ValidationErrors errors=new ValidationErrors();
  errors.add("error", new ValidationError(msg));
  request.setAttribute("errors",errors);
}

private ValidationErrors validateAltroGenere(MatriceVO matriceVO, MacchinaVO macchinaVO, HttpServletRequest request)
{
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

  if (!Validator.isNotEmpty(request.getParameter("marcaDesc")))
  {
    matriceVO.setDescMarca(null);
    genereMarcaPresent=false;
    errorVal+=4;
  }
  else
  {
    matriceVO.setDescMarca(request.getParameter("marcaDesc"));
  }
  SolmrLogger.debug(this,"errorVal="+errorVal);
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
      errors.add("marca",valError);
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

  private ValidationErrors validateRimorchioAsm(DatiMacchinaVO datiMacchinaVO, HttpServletRequest request)
  {
    ValidationErrors errors =  new ValidationErrors();
    SolmrLogger.debug(this,"request.getParameter(\"idGenereMacchina1\"): "+request.getParameter("idGenereMacchina1"));
    if (!Validator.isNotEmpty(request.getParameter("idGenereMacchina1")))
    {
      datiMacchinaVO.setIdGenereMacchina(null);
      errors.add("idGenereMacchina1",new ValidationError("Selezionare un genere macchina"));
    }
    else
    {
      SolmrLogger.debug(this,"request.getParameter(\"idGenereMacchina1\"): " + request.getParameter("idGenereMacchina1"));
      datiMacchinaVO.setIdGenereMacchina(trim(request.getParameter("idGenereMacchina1")));
    }

    if (!Validator.isNotEmpty(request.getParameter("idCategoria1")))
    {
      datiMacchinaVO.setIdCategoria(null);
      errors.add("idCategoria1",new ValidationError("Selezionare una categoria macchina"));
    }
    else
    {
      SolmrLogger.debug(this,"idCategoria1 : " + request.getParameter("idCategoria1"));
      datiMacchinaVO.setIdCategoria(trim(request.getParameter("idCategoria1")));
    }

    return errors;
  }


  public String trim(String str)
  {
    if (str==null)
    {
      return null;
    }
    else
    {
      return str.trim();
    }
  }
 %>