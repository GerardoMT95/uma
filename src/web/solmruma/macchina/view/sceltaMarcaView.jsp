<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>



<%@ page import="java.util.*" %>
<%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.jsf.htmpl.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.client.anag.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%

  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application)

                .getHtmpl("macchina/layout/sceltaMarca.htm");

  Vector marche=null;

  Long idGenere=null;

  String marca=null;



  if ( request.getParameter("idGenere")!=null ){

    idGenere = new Long(request.getParameter("idGenere"));

  }

  else{

    ////////////////Da Eliminare - Utile x test - Inizio

    idGenere = new Long("1");

    ////////////////Da Eliminare - Utile x test - Fine

  }

  SolmrLogger.debug(this,"idGenere: "+idGenere);



  if ( request.getParameter("marca")!=null ){

    marca = request.getParameter("marca");

  }

  SolmrLogger.debug(this,"marca: "+marca);



  try

  {

    SolmrLogger.debug(this,"try1");

    marche=umaClient.getTipiMarcaByGenereMacchinaAndLikeMarca(idGenere, marca);

    SolmrLogger.debug(this,"try2");

  }

  catch(Exception e)

  {

    SolmrLogger.debug(this,"Exception"+e.getMessage());

    marche=new Vector();

  }



  int vectSize=marche.size();

  SolmrLogger.debug(this,"\n\n\n\n******************");

  SolmrLogger.debug(this,"vectSize: "+vectSize);

  htmpl.setStringProcessor(new CustomHTMLStringProcessor());

  htmpl.newBlock("blkSceltaMarca");

  for(int i=0;i<vectSize;i++)

  {

    CodeDescr codeDescVO = (CodeDescr) marche.get(i);

    htmpl.set("blkSceltaMarca.idMarca",""+codeDescVO.getCode());

    htmpl.set("blkSceltaMarca.marcaDesc",codeDescVO.getDescription());

    SolmrLogger.debug(this,"codeDescVO.getCode(): "+codeDescVO.getCode());

    SolmrLogger.debug(this,"codeDescVO.getDescription(): "+codeDescVO.getDescription());

  }

  it.csi.solmr.presentation.security.Autorizzazione.writeException(htmpl,exception);

  it.csi.solmr.presentation.security.Autorizzazione aut=
  (it.csi.solmr.presentation.security.Autorizzazione)
  it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ACCESSO_SISTEMA");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  aut.writeBanner(htmpl,ruoloUtenza,request);

  out.print(htmpl.text());

%>