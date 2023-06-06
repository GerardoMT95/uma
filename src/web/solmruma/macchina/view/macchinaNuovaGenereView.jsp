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



<%

  SolmrLogger.debug(this,"macchinaNuovaGenereView.jsp - Begin");



  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("macchina/layout/MacchinaNuovaGenere.htm");
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



  String elencoMacchineUrlHtml="../layout/elencoMacchine.htm";





  HashMap vecSession = null;

  MacchinaVO macchinaVO = null;

  MatriceVO matriceVO = null;

  DatiMacchinaVO datiMacchinaVO = null;



  SolmrLogger.debug(this,"Recupero oggetti dalla session");



  if ( session.getAttribute("common")!=null){

    SolmrLogger.debug(this,"session.getAttribute(\"common\")!=null");

    vecSession = (HashMap) session.getAttribute("common");

    macchinaVO = (MacchinaVO) vecSession.get("macchinaVO");

    //matriceVO = (MatriceVO) vecSession.get("matriceVO");

    SolmrLogger.debug(this,"macchinaVO: "+macchinaVO);

    matriceVO = macchinaVO.getMatriceVO();

    SolmrLogger.debug(this,"matriceVO: "+matriceVO);

    datiMacchinaVO = (DatiMacchinaVO) vecSession.get("datiMacchinaVO");

    SolmrLogger.debug(this,"datiMacchinaVO: "+datiMacchinaVO);

  }



  if (datiMacchinaVO!=null){

    SolmrLogger.debug(this,"\n\n\nààààààààààààààààààààààààààààààà4");

    SolmrLogger.debug(this,"datiMacchinaVO.getIdGenereMacchinaLong(): "+datiMacchinaVO.getIdGenereMacchinaLong());

    SolmrLogger.debug(this,"datiMacchinaVO.getIdCategoriaLong(): "+datiMacchinaVO.getIdCategoriaLong());

  }



  SolmrLogger.debug(this,"Generazione blocchi di ricerca");



  SolmrLogger.debug(this,"Creazione comboBox genere");

  int genereSize=genere.size();

  SolmrLogger.debug(this,"genereSize: "+genereSize);



  //datiMacchinaVO.setIdCategoria(""+new Long("1"));

  //htmpl.set("pageFrom",request.getParameter("pageFrom"));



  String STRINGA_COMBO_VUOTA="";

  htmpl.set("blkComboGenere1.idGenereMacchina",STRINGA_COMBO_VUOTA);

  htmpl.set("blkComboGenere1.genereMacchinaDesc",STRINGA_COMBO_VUOTA);



  htmpl.set("blkComboGenere2.idGenereMacchina",STRINGA_COMBO_VUOTA);

  htmpl.set("blkComboGenere2.genereMacchinaDesc",STRINGA_COMBO_VUOTA);



  SolmrLogger.debug(this,"Creazione blkComboGenere");

  for(int i=0;i<genereSize;i++)

  {

    GenereMacchinaVO genereMacchinaVO=(GenereMacchinaVO)genere.get(i);



    SolmrLogger.debug(this,"macchina: "+i);

    SolmrLogger.debug(this,"genereMacchinaVO.getIdGenereMacchina(): "+genereMacchinaVO.getIdGenereMacchina());

    SolmrLogger.debug(this,"genereMacchinaVO.getDescrizione(): "+genereMacchinaVO.getDescrizione());



    //Valorizzazione ComboGenereMacchina - Asm Rimorchio

    SolmrLogger.debug(this,"\n\n\n****************************************");

    SolmrLogger.debug(this,"genereMacchinaVO.getAltroGenere().booleanValue(): "+genereMacchinaVO.getAltroGenere().booleanValue());

    if ( genereMacchinaVO.getAltroGenere().booleanValue() == false){

      htmpl.newBlock("blkComboGenere1");

      htmpl.set("blkComboGenere1.idGenereMacchina",""+genereMacchinaVO.getIdGenereMacchina());

      if(datiMacchinaVO!=null){

        if (genereMacchinaVO.getIdGenereMacchina().toString().equals(datiMacchinaVO.getIdGenereMacchina()))

        {

          SolmrLogger.debug(this,"\n\n\n\n+++++++++++++++Session");

          SolmrLogger.debug(this,"genereMacchinaVO.getIdGenereMacchina(): "+genereMacchinaVO.getIdGenereMacchina());

          SolmrLogger.debug(this,"datiMacchinaVO.getIdGenereMacchina(): "+datiMacchinaVO.getIdGenereMacchina());

          htmpl.set("blkComboGenere1.selectedGenereMacchina1","selected");

        }

      }



      htmpl.set("blkComboGenere1.genereMacchinaDesc",""+genereMacchinaVO.getDescrizione() );

    } else{

      //Valorizzazione ComboGenereMacchina - Altro Genere

      htmpl.newBlock("blkComboGenere2");

      htmpl.set("blkComboGenere2.idGenereMacchina",""+genereMacchinaVO.getIdGenereMacchina());

      if (matriceVO!=null){

        if (genereMacchinaVO.getIdGenereMacchina().toString().equals(matriceVO.getIdGenereMacchina()))

        {

          SolmrLogger.debug(this,"\n\n\n\n+++++++++++++++Session");

          SolmrLogger.debug(this,"genereMacchinaVO.getIdGenereMacchina(): "+genereMacchinaVO.getIdGenereMacchina());

          SolmrLogger.debug(this,"matriceVO.getIdGenereMacchina(): "+matriceVO.getIdGenereMacchina());

          htmpl.set("blkComboGenere2.selectedGenereMacchina2","selected");

        }

      }



      htmpl.set("blkComboGenere2.genereMacchinaDesc",""+genereMacchinaVO.getDescrizione() );

    }

  }



  if(datiMacchinaVO!=null){

    htmpl.set("categoriaSelected1",datiMacchinaVO.getIdCategoria());

  }

  if(matriceVO!=null){

    htmpl.set("categoriaSelected2",matriceVO.getIdCategoria());

  }



  //Valorizzazione segnaposto e vettori JavaScript

  for(int i=0;i<genereSize;i++)

  {

    GenereMacchinaVO genereMacchinaVO=(GenereMacchinaVO)genere.get(i);

    htmpl.newBlock("blkGenere");

    htmpl.set("blkGenere.categoria",""+genereMacchinaVO.getIdGenereMacchina());

    Vector categorie=genereMacchinaVO.getCategorieMacchina();

    int size=categorie.size();



    htmpl.set("blkGenere.blkCategoria.categoria",""+genereMacchinaVO.getIdGenereMacchina());

    htmpl.set("blkGenere.blkCategoria.index","0");

    htmpl.set("blkGenere.blkCategoria.categoriaDesc",STRINGA_COMBO_VUOTA);

    htmpl.set("blkGenere.blkCategoria.categoriaCod",STRINGA_COMBO_VUOTA);



    for(int j=0;j<size;j++)

    {

      htmpl.newBlock("blkGenere.blkComboCategoria");

      CodeDescr categoria=(CodeDescr) categorie.get(j);

      htmpl.set("blkGenere.blkCategoria.categoria",""+genereMacchinaVO.getIdGenereMacchina());

      htmpl.set("blkGenere.blkCategoria.index",""+(j+1));

      htmpl.set("blkGenere.blkCategoria.categoriaDesc",(""+categoria.getDescription().trim()));

      htmpl.set("blkGenere.blkCategoria.categoriaCod",(""+categoria.getCode()).trim());

    }

  }





  ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");

  SolmrLogger.debug(this,"errors="+errors);

  HtmplUtil.setErrors(htmpl,errors,request);



  SolmrLogger.debug(this,"\n\n\n\nRiempimento ComboBox");

  /*SolmrLogger.debug(this,datiMacchinaVO.getIdGenereMacchina());

  SolmrLogger.debug(this,datiMacchinaVO.getIdCategoria());*/



  /*SolmrLogger.debug(this,"\n\n\nààààààààààààààààààààààààààààààà5");

  SolmrLogger.debug(this,"datiMacchinaVO.getIdGenereMacchinaLong(): "+datiMacchinaVO.getIdGenereMacchinaLong());

  SolmrLogger.debug(this,"datiMacchinaVO.getIdCategoriaLong(): "+datiMacchinaVO.getIdCategoriaLong());*/



  HtmplUtil.setValues(htmpl,macchinaVO,(String)session.getAttribute("pathToFollow"));

  HtmplUtil.setValues(htmpl,matriceVO,(String)session.getAttribute("pathToFollow"));

  HtmplUtil.setValues(htmpl,datiMacchinaVO,(String)session.getAttribute("pathToFollow"));





  //this.errErrorValExc(htmpl, request, exception);

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

%>