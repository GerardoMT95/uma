  <%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>

<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.dto.anag.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%



  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  AnagFacadeClient anagFacadeClient = new AnagFacadeClient();



  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/macchina/layout/ricercaMacchina.htm");
%><%@include file = "/include/menu.inc" %><%

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  //Valorizza segnaposto errore htmpl

  HtmplUtil.setErrors(htmpl, errors, request);

  //Valorizza segnaposto htmpl



  HtmplUtil.setValues(htmpl, request);







  Vector genere=new Vector();

  try{

    genere=umaFacadeClient.getGenereMacchina();

  }

  catch(SolmrException e){

  }



  MacchinaVO ricMacchinaVO = (MacchinaVO)request.getAttribute("ricMacchinaVO");

  if(ricMacchinaVO!=null){



  }

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  htmpl.set("ASM",SolmrConstants.ID_GENERE_MACCHINA_ASM.toString());

  htmpl.set("RIMORCHIO",SolmrConstants.ID_GENERE_MACCHINA_R.toString());



  SolmrLogger.debug(this,"Creazione comboBox genere");

  int genereSize=genere.size();

  SolmrLogger.debug(this,"genereSize: "+genereSize);



  String STRINGA_COMBO_VUOTA="";

  htmpl.set("blkComboGenere.idGenereMacchina",STRINGA_COMBO_VUOTA);

  htmpl.set("blkComboGenere.genereMacchinaDesc",STRINGA_COMBO_VUOTA);





  SolmrLogger.debug(this,"Creazione blkComboGenere");

  for(int i=0;i<genereSize;i++){

    GenereMacchinaVO genereMacchinaVO=(GenereMacchinaVO)genere.get(i);

    htmpl.newBlock("blkComboGenere");

    htmpl.set("blkComboGenere.idGenereMacchina",""+genereMacchinaVO.getIdGenereMacchina());

    if(ricMacchinaVO!=null){

      String genereSelezionato = null;

      if(ricMacchinaVO.getMatriceVO()!= null && ricMacchinaVO.getMatriceVO().getIdGenereMacchina()!=null)

        genereSelezionato = ricMacchinaVO.getMatriceVO().getIdGenereMacchina();

      else if(ricMacchinaVO.getDatiMacchinaVO()!= null && ricMacchinaVO.getDatiMacchinaVO().getIdGenereMacchina()!=null)

        genereSelezionato = ricMacchinaVO.getDatiMacchinaVO().getIdGenereMacchina();

      if(genereSelezionato != null && genereMacchinaVO.getIdGenereMacchina().toString().equals(genereSelezionato))

        htmpl.set("blkComboGenere.checkedGenereMacchina","selected");

    }

    htmpl.set("blkComboGenere.genereMacchinaDesc",""+genereMacchinaVO.getDescrizione());

  }



  if(ricMacchinaVO!=null){

    if(ricMacchinaVO.getMatriceVO()!= null && ricMacchinaVO.getMatriceVO().getIdCategoria()!=null)

      htmpl.set("categoriaSelected",ricMacchinaVO.getMatriceVO().getIdCategoria());

    else if(ricMacchinaVO.getDatiMacchinaVO()!= null && ricMacchinaVO.getDatiMacchinaVO().getIdCategoria()!=null)

      htmpl.set("categoriaSelected",ricMacchinaVO.getDatiMacchinaVO().getIdCategoria());

  }

  //Valorizzazione segnaposto e vettori JavaScript

  for(int i=0;i<genereSize;i++){

    GenereMacchinaVO genereMacchinaVO=(GenereMacchinaVO)genere.get(i);

    htmpl.newBlock("blkGenere");

    //htmpl.set("blkGenere.categoria",""+(i+1));

    htmpl.set("blkGenere.categoria",""+genereMacchinaVO.getIdGenereMacchina());

    Vector categorie=genereMacchinaVO.getCategorieMacchina();

    int size=categorie.size();



    //htmpl.set("blkGenere.blkCategoria.categoria",""+(i+1));

    htmpl.set("blkGenere.blkCategoria.categoria",""+genereMacchinaVO.getIdGenereMacchina());

    htmpl.set("blkGenere.blkCategoria.index","0");

    htmpl.set("blkGenere.blkCategoria.categoriaDesc",STRINGA_COMBO_VUOTA);

    htmpl.set("blkGenere.blkCategoria.categoriaCod",STRINGA_COMBO_VUOTA);



    for(int j=0;j<size;j++){

      htmpl.newBlock("blkGenere.blkComboCategoria");

      CodeDescr categoria=(CodeDescr) categorie.get(j);

      //htmpl.set("blkGenere.blkCategoria.categoria",""+(i+1));

      htmpl.set("blkGenere.blkCategoria.categoria",""+genereMacchinaVO.getIdGenereMacchina());

      htmpl.set("blkGenere.blkCategoria.index",""+(j+1));

      htmpl.set("blkGenere.blkCategoria.categoriaDesc",(""+categoria.getDescription().trim()));

      htmpl.set("blkGenere.blkCategoria.categoriaCod",(""+categoria.getCode()).trim());

    }

  }



  Collection collTipoTarga = (Collection)umaFacadeClient.getTipiTarga();



  if(collTipoTarga!=null&&collTipoTarga.size()>0){

    Iterator iterTipoTarga = collTipoTarga.iterator();

    while(iterTipoTarga.hasNext()){

      CodeDescr cdTipoTarga = (CodeDescr)iterTipoTarga.next();

      htmpl.newBlock("comboTipoTarga");

      htmpl.set("comboTipoTarga.idTipoTarga",""+cdTipoTarga.getCode());

      htmpl.set("comboTipoTarga.descTipoTarga",cdTipoTarga.getDescription());



      if(ricMacchinaVO!=null &&

         ricMacchinaVO.getTargaCorrente()!= null &&

         ricMacchinaVO.getTargaCorrente().getIdTargaLong()!= null &&

         cdTipoTarga.getCode().toString().equals(ricMacchinaVO.getTargaCorrente().getIdTargaLong().toString())){

        htmpl.set("comboTipoTarga.selected","selected");

      }

    }

  }



  Collection collProvAttest = (Collection)anagFacadeClient.getProvinceByRegione(SolmrConstants.ID_REGIONE);



  if(collProvAttest!=null&&collProvAttest.size()>0)

  {

    Iterator iterProvincia = collProvAttest.iterator();

    while(iterProvincia.hasNext()){

      ProvinciaVO provinciaVO = (ProvinciaVO)iterProvincia.next();

      htmpl.newBlock("comboProvAttest");

      htmpl.set("comboProvAttest.idProvAttest",""+provinciaVO.getIstatProvincia());

      htmpl.set("comboProvAttest.siglaProvAttest",provinciaVO.getSiglaProvincia());

      if(ricMacchinaVO!=null &&

         ricMacchinaVO.getAttestatoProprietaVO() != null &&

         ricMacchinaVO.getAttestatoProprietaVO().getIdProvincia() != null &&

         provinciaVO.getIstatProvincia().equals(ricMacchinaVO.getAttestatoProprietaVO().getIdProvincia())){

        htmpl.set("comboProvAttest.idProvAttestSel","selected");

      }

    }

  }

  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

%>

<%= htmpl.text()%>