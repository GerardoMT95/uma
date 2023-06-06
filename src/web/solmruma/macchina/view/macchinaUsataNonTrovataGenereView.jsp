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
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!

  public static final String ASM = "ASM";

  public static final String RIMORCHIO = "R";

  public static final String MAO_TRAINATA = "010";

  public static final String CARRO_UNIFEED = "012";

%>

<%



  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("macchina/layout/MacchinaUsataNonTrovataGenere.htm");
%><%@include file = "/include/menu.inc" %><%
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  Vector genere=new Vector();

  try

  {

    genere=umaClient.getGenereMacchina();

  }

  catch(SolmrException e)

  {

  }





  HashMap common = null;

  MacchinaVO macchinaVO = null;

  MatriceVO matriceVO = null;

  DatiMacchinaVO datiMacchinaVO = null;





  if ( session.getAttribute("common")!=null)

  {

    common = (HashMap) session.getAttribute("common");

    macchinaVO = (MacchinaVO) common.get("macchinaVO");

    matriceVO = macchinaVO.getMatriceVO();

    SolmrLogger.debug(this,"(String)common.get(\"conTarga\"))="+(String)common.get("conTarga"));

    if (matriceVO==null)

    {

      matriceVO=new MatriceVO();

    }

    datiMacchinaVO = macchinaVO.getDatiMacchinaVO();

    if (datiMacchinaVO==null)

    {

      datiMacchinaVO=new DatiMacchinaVO();

    }

  }



  String elencoMacchineUrlHtml="../layout/elencoMacchine.htm";

  boolean hideMatrice="no".equalsIgnoreCase((String)common.get("conTarga"));

  if (hideMatrice)

  {

    SolmrLogger.debug(this,"hide della matrice");

    htmpl.set("hideMatrice","display:none");

    htmpl.newBlock("blkNoNumeroTarga");

  }

  else

  {

    SolmrLogger.debug(this,"show della matrice");

    htmpl.newBlock("blkMatrice");

    htmpl.newBlock("blkNumeroTarga");

    String numeroTarga=macchinaVO.getTargaCorrente().getNumeroTarga();

    htmpl.set("blkNumeroTarga.numeroTarga",numeroTarga);

  }



  int genereSize=genere.size();



  //datiMacchinaVO.setIdCategoria(""+new Long("1"));

  //htmpl.set("pageFrom",request.getParameter("pageFrom"));



  String STRINGA_COMBO_VUOTA="";

  htmpl.set("blkComboGenere1.idGenereMacchina",STRINGA_COMBO_VUOTA);

  htmpl.set("blkComboGenere1.genereMacchinaDesc",STRINGA_COMBO_VUOTA);



  if (!hideMatrice)

  {

    htmpl.set("blkMatrice.blkComboGenere2.idGenereMacchina",STRINGA_COMBO_VUOTA);

    htmpl.set("blkMatrice.blkComboGenere2.genereMacchinaDesc",STRINGA_COMBO_VUOTA);

  }

  boolean conTarga=!("no".equalsIgnoreCase((String)common.get("conTarga")));

  for(int i=0;i<genereSize;i++)

  {

    GenereMacchinaVO genereMacchinaVO=(GenereMacchinaVO)genere.get(i);

    //Valorizzazione ComboGenereMacchina - Asm Rimorchio

    if ( genereMacchinaVO.getAltroGenere().booleanValue() == false)

    {

      SolmrLogger.debug(this,"conTarga="+conTarga);

      SolmrLogger.debug(this,"genereMacchinaVO.getIdGenereMacchina()="+genereMacchinaVO.getIdGenereMacchina());

      if (!conTarga || (conTarga && !ASM.equals(genereMacchinaVO.getCodificaBreve())))

      {

        htmpl.newBlock("blkComboGenere1");

        htmpl.set("blkComboGenere1.idGenereMacchina",genereMacchinaVO.getIdGenereMacchina().toString());

        if (genereMacchinaVO.getIdGenereMacchina().toString().equals(datiMacchinaVO.getIdGenereMacchina()))

        {

          htmpl.set("blkComboGenere1.selectedGenereMacchina1","selected");

        }

        htmpl.set("blkComboGenere1.genereMacchinaDesc",genereMacchinaVO.getDescrizione());

      }

    }

    else

    {

      if ( !hideMatrice )

      {

        //Valorizzazione ComboGenereMacchina - Altro Genere

        htmpl.newBlock("blkMatrice.blkComboGenere2");

        htmpl.set("blkMatrice.blkComboGenere2.idGenereMacchina",genereMacchinaVO.getIdGenereMacchina().toString());

        if (matriceVO!=null)

        {

          if (genereMacchinaVO.getIdGenereMacchina().toString().equals(matriceVO.getIdGenereMacchina()))

          {

            htmpl.set("blkMatrice.blkComboGenere2.selectedGenereMacchina2","selected");

          }

        }

        htmpl.set("blkMatrice.blkComboGenere2.genereMacchinaDesc",genereMacchinaVO.getDescrizione());

      }

    }

  }



  if(datiMacchinaVO!=null)

  {

    htmpl.set("categoriaSelected1",datiMacchinaVO.getIdCategoria());

  }

  if(matriceVO!=null)

  {

    htmpl.set("categoriaSelected2",matriceVO.getIdCategoria());

  }



  //Valorizzazione segnaposto e vettori JavaScript

  for(int i=0;i<genereSize;i++)

  {

    GenereMacchinaVO genereMacchinaVO=(GenereMacchinaVO)genere.get(i);

    htmpl.newBlock("blkGenere");

//    htmpl.set("blkGenere.categoria",""+(i+1));

    htmpl.set("blkGenere.categoria",""+genereMacchinaVO.getIdGenereMacchina());

    Vector categorie=genereMacchinaVO.getCategorieMacchina();

    SolmrLogger.debug(this,"genereMacchinaVO.getCodificaBreve()="+genereMacchinaVO.getCodificaBreve());

    if (conTarga && RIMORCHIO.equals(genereMacchinaVO.getCodificaBreve().trim()))

    {

      categorie=removeCategorieSenzaTarga(categorie);

    }



    int size=categorie.size();



//    htmpl.set("blkGenere.blkCategoria.categoria",""+(i+1));

    htmpl.set("blkGenere.blkCategoria.categoria",""+genereMacchinaVO.getIdGenereMacchina());

    htmpl.set("blkGenere.blkCategoria.index","0");

    htmpl.set("blkGenere.blkCategoria.categoriaDesc",STRINGA_COMBO_VUOTA);

    htmpl.set("blkGenere.blkCategoria.categoriaCod",STRINGA_COMBO_VUOTA);



    for(int j=0;j<size;j++)

    {

      htmpl.newBlock("blkGenere.blkComboCategoria");

      CodeDescr categoria=(CodeDescr) categorie.get(j);

//      htmpl.set("blkGenere.blkCategoria.categoria",""+(i+1));

      htmpl.set("blkGenere.blkCategoria.categoria",""+genereMacchinaVO.getIdGenereMacchina());

      htmpl.set("blkGenere.blkCategoria.index",""+(j+1));

      htmpl.set("blkGenere.blkCategoria.categoriaDesc",(""+categoria.getDescription().trim()));

      htmpl.set("blkGenere.blkCategoria.categoriaCod",(""+categoria.getCode()).trim());

    }

  }





  ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");

  SolmrLogger.debug(this,"errors="+errors);

  HtmplUtil.setErrors(htmpl,errors,request);





  SolmrLogger.debug(this,"matriceVO.getTipoMacchina()="+matriceVO.getTipoMacchina());

  HtmplUtil.setValues(htmpl,datiMacchinaVO,(String)session.getAttribute("pathToFollow"));

  HtmplUtil.setValues(htmpl,matriceVO,(String)session.getAttribute("pathToFollow"));

  HtmplUtil.setValues(htmpl,macchinaVO,(String)session.getAttribute("pathToFollow"));



  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

  out.print(htmpl.text());



%>

<%! private boolean findCode(Integer code,Vector codes)

  {

    if (codes==null || code==null)

    {

      return false;

    }

    int size=codes.size();

    for(int i=0;i<size;i++)

    {

      Long lavCode=(Long)codes.get(i);

      if (code.intValue()==lavCode.longValue())

      {

        return true;

      }

    }

    return false;

  }

  private Vector removeCategorieSenzaTarga(Vector categorie)

  {

    SolmrLogger.debug(this,"removeCategorieSenzaTarga");

    SolmrLogger.debug(this,"categorie.size()="+categorie.size());

    Vector result=new Vector();

    for(int i=0;i<categorie.size();i++)

    {

      CodeDescr categoriaVO=(CodeDescr)categorie.get(i);

      SolmrLogger.debug(this,"secondaryCode="+categoriaVO.getSecondaryCode());

      if (!categoriaVO.getSecondaryCode().equals(CARRO_UNIFEED) &&

          !categoriaVO.getSecondaryCode().equals(MAO_TRAINATA))

      {

        result.add(categoriaVO);

      }

    }

    return result;

  }

%>