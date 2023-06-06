  <%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
  %>

<%@ page import="it.csi.solmr.business.uma.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>





<%

  SolmrLogger.debug(this,"Entro in lista_marcheView.jsp");

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("/macchina/layout/lista_marche.htm");
%><%@include file = "/include/menu.inc" %><%

  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();

  ValidationErrors errors = (ValidationErrors)request.getAttribute("errors");

  int totalePagine;

  int pagCorrente;

  int numeroRecord;

  Integer currPage;



  String genereMacchina;

  String descrizioneMarca;

  String matriceMarca;

  if(request.getAttribute("genereMacchina")!=null){

    genereMacchina = (String)request.getAttribute("genereMacchina");

  }

  else{

    genereMacchina = (String)session.getAttribute("genereMacchina");

  }

  if(request.getAttribute("descrizioneMarca")!=null){

    descrizioneMarca = (String)request.getAttribute("descrizioneMarca");

  }

  else{

    descrizioneMarca = (String)session.getAttribute("descrizioneMarca");

  }

  if(request.getAttribute("descrizioneMarca")!=null){

    matriceMarca = (String)request.getAttribute("matriceMarca");

  }

  else{

    matriceMarca = (String)session.getAttribute("matriceMarca");

  }



  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  Vector elencoIdMarca = (Vector)session.getAttribute("elencoIdMarca");

  Vector elencoMarca = (Vector)session.getAttribute("elencoMarca");



  SolmrLogger.debug(this,"\n\n\n\n************************************");

  if(elencoIdMarca!=null){

    SolmrLogger.debug(this,"1elencoIdMarca.size(): "+elencoIdMarca.size());

  }

  else{

    SolmrLogger.debug(this,"2elencoIdMarca.size(): 0");

  }

  if(elencoMarca!=null){

    SolmrLogger.debug(this,"1elencoMarca.size(): "+elencoMarca.size()+"\n\n\n");

  }

  else{

    SolmrLogger.debug(this,"2elencoMarca.size(): 0");

  }



  SolmrLogger.debug(this,"\n\n\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");

  SolmrLogger.debug(this,"#lista_marcheView genereMacchina :"+genereMacchina);

  SolmrLogger.debug(this,"#lista_marcheView descrizioneMarca :"+descrizioneMarca);

  SolmrLogger.debug(this,"#lista_marcheView matriceMarca :"+matriceMarca);

  //SolmrLogger.debug(this,"#lista_marcheView pagCorrente :"+pagCorrente);

  SolmrLogger.debug(this,"#lista_marcheView elencoIdMarca :"+elencoIdMarca);

  SolmrLogger.debug(this,"#lista_marcheView elencoMarca :"+elencoMarca);

  SolmrLogger.debug(this,"session.getAttribute(\"currPage\"): "+session.getAttribute("currPage"));

  SolmrLogger.debug(this,"\n\n\n");



  pagCorrente=1;

  totalePagine=1;

  numeroRecord=0;

  if(session.getAttribute("currPage")!=null)

    pagCorrente = ((Integer)session.getAttribute("currPage")).intValue();



  if(elencoIdMarca!=null)

  {

    SolmrLogger.debug(this,"\n\n\n+++++++++++++++++++++++++++");

    SolmrLogger.debug(this,"elencoIdMarca!=null");

    totalePagine=elencoIdMarca.size()/SolmrConstants.NUM_MAX_ROWS_PAG;

    SolmrLogger.debug(this,"\n\n\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");

    SolmrLogger.debug(this,"totalePagine: "+totalePagine);

    SolmrLogger.debug(this,"\n\n\n");



    int resto = elencoIdMarca.size()%SolmrConstants.NUM_MAX_ROWS_PAG;

    if(resto!=0)

      totalePagine+=1;

    numeroRecord = elencoIdMarca.size();

    currPage = new Integer(pagCorrente);

    session.setAttribute("currPage",currPage);



    if(pagCorrente>1)

      htmpl.newBlock("bottoneIndietro");

    if(pagCorrente<totalePagine)

      htmpl.newBlock("bottoneAvanti");

  }



  htmpl.set("currPage",""+pagCorrente);

  htmpl.set("totPage",""+totalePagine);

  htmpl.set("numeroRecord",""+numeroRecord);



  SolmrLogger.debug(this,"----------------------genereMacchina "+genereMacchina);



  String descGenereMacchina;

  if( genereMacchina!=null && (!genereMacchina.trim().equalsIgnoreCase(""))  ){

    SolmrLogger.debug(this,"\n\n\n**********************************");

    SolmrLogger.debug(this,"genereMacchina: "+genereMacchina);

    descGenereMacchina = umaFacadeClient.getDescGenereMacchina(new Long(genereMacchina));

    request.setAttribute("genereMacchina", descGenereMacchina);

    htmpl.set("descGenereMacchina", descGenereMacchina);

  }



  htmpl.set("genereMacchina", genereMacchina);

  htmpl.set("descrizioneMarca", descrizioneMarca);

  htmpl.set("matriceMarca", matriceMarca);



  if(!ruoloUtenza.isUtenteIntermediario()) {

    if(ruoloUtenza.isUtenteRegionale()) {

      htmpl.newBlock("blkSelMarca");

    }

  }



  if(elencoMarca!=null && elencoMarca.size()>0)

  {

    for(int i=0; i<elencoMarca.size();i++)

    {

      MarcaVO marcaVO = (MarcaVO)elencoMarca.get(i);

      htmpl.newBlock("blkMarche");



      //Visualizzazione Radio Button

      if(!ruoloUtenza.isUtenteIntermediario()) {

        if(ruoloUtenza.isUtenteRegionale()) {

          htmpl.newBlock("blkMarche.blkSelMarcaCheckBox");

          htmpl.set("blkMarche.blkSelMarcaCheckBox.idMarca",marcaVO.getIdMarca());

        }

      }



      String matrice = marcaVO.getMatrice();

      SolmrLogger.debug(this,"-------------------getIdGenereMacchina "+marcaVO.getIdGenereMacchina());

      SolmrLogger.debug(this,"-------------------getMatrice "+marcaVO.getMatrice());

      if ( matrice!=null ){

        SolmrLogger.debug(this,"-------------------matrice.substring(0,1) "+marcaVO.getMatrice().substring(0,1));

      }



      String genere = null;

      if( marcaVO.getIdGenereMacchinaLong()!=null ){

        genere = umaFacadeClient.getDescGenereMacchina(marcaVO.getIdGenereMacchinaLong());

      }

      String marca = marcaVO.getDescrizioneMarca();



      SolmrLogger.debug(this,matrice + " " +genere+" "+marca);

//umaFacadeClient.getDescGenereMacchina(new Long(genereMacchina))

      htmpl.set("blkMarche.matrice",matrice);

      htmpl.set("blkMarche.genere",genere);

      htmpl.set("blkMarche.marca",marca);

    }

  }

  HtmplUtil.setErrors(htmpl, errors, request);

  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

SolmrLogger.debug(this,"htmpl.text()");

%>

<%= htmpl.text()%>



<%!

  private String nvl(String valore){

    String result = "";

    if(valore!=null)

      result = valore;

    return result;

  }

%>

