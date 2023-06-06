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
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%

  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application)

                .getHtmpl("layout/sceltaComuneMultipla.htm");

  Vector provincie=getProvincieByRegione(request.getParameter("idRegione"),umaClient);;

  Vector comuniSelezionati=getComuniSelezionati(request.getParameterValues("istatComune"),umaClient);

  String istatProvincia=findIstatProvincia(comuniSelezionati,provincie);

  SolmrLogger.debug(this,"istatProvincia="+istatProvincia);

  int vectSize=0;

  vectSize=provincie.size();

  htmpl.set("onlyOne",request.getParameter("onlyOne"));

  for(int i=0;i<vectSize;i++)

  {

    ProvinciaVO provinciaVO=(ProvinciaVO) provincie.get(i);

    htmpl.newBlock("blkProvincia");

    htmpl.set("blkProvincia.idProvincia",provinciaVO.getIstatProvincia());

    htmpl.set("blkProvincia.descProvincia",provinciaVO.getDescrizione());

    SolmrLogger.debug(this,"provinciaVO.getIstatProvincia()="+provinciaVO.getIstatProvincia());

    if (istatProvincia!=null && istatProvincia.equals(provinciaVO.getIstatProvincia()))

    {

      htmpl.set("blkProvincia.selected","selected");

    }

  }

/*  vectSize=elencoComuni.size();

  for(int i=0;i<vectSize;i++)

  {

    ComuneVO comune=(ComuneVO) elencoComuni.get(i);

    htmpl.newBlock("blkComune");

    SolmrLogger.debug(this,"comune["+i+"]="+comune.getDescom());

    htmpl.set("blkComune.istatComune",comune.getIstatComune());

    htmpl.set("blkComune.descrizione",comune.getDescom());

  }

*/

  vectSize=comuniSelezionati.size();

  for(int i=0;i<vectSize;i++)

  {

    ComuneVO comune=(ComuneVO) comuniSelezionati.get(i);

    htmpl.newBlock("blkComune");

    htmpl.set("blkComuneSelezionato.istatComune",comune.getIstatComune());

    htmpl.set("blkComuneSelezionato.descrizione",comune.getDescom());

  }

  int prSize=provincie.size();

  for(int i = 0; i < prSize; i++)

  {

    ProvinciaVO provinciaVO=(ProvinciaVO) provincie.get(i);

    SolmrLogger.debug(this,"istat_provincia="+provinciaVO.getIstatProvincia());

    Vector elencoComuni=getElencoComuniByProvincia(provinciaVO.getIstatProvincia(),umaClient);

    htmpl.newBlock("provincia");

    htmpl.set("provincia.indexProvincia", ""+i);

    int ecSize=elencoComuni.size();

    htmpl.setStringProcessor(null);

    for(int j = 0; j < ecSize; j++)

    {

      ComuneVO comune=(ComuneVO) elencoComuni.get(j);

      htmpl.newBlock("provincia.comune");

      htmpl.set("provincia.comune.indexProvincia", ""+i);

      htmpl.set("provincia.comune.index", ""+j);

      htmpl.set("provincia.comune.nomeComune", "\"" +comune.getDescom()+"\"");

      htmpl.set("provincia.comune.istatComune", "'"+comune.getIstatComune()+"'");

    }

  }

  this.errErrorValExc(htmpl, request, exception);

  it.csi.solmr.presentation.security.Autorizzazione aut=
  (it.csi.solmr.presentation.security.Autorizzazione)
  it.csi.solmr.util.IrideFileParser.elencoSecurity.get("ACCESSO_SISTEMA");
  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");
  aut.writeBanner(htmpl,ruoloUtenza,request);

  out.print(htmpl.text());

%>

<%!

  private Vector getProvincieByRegione(String idRegione,UmaFacadeClient umaClient)

  {

    if (idRegione==null)

    {

      return new Vector();

    }

    Vector provincie;

    try

    {

      provincie=umaClient.getProvincieByRegione(idRegione);

    }

    catch(Exception e)

    {

      SolmrLogger.debug(this,"exception="+e.getMessage());

      provincie=new Vector();

    }

    return provincie;

  }



  private Vector getComuniSelezionati(String vettComuni[], UmaFacadeClient umaClient)

  {

    if (vettComuni==null)

    {

      return new Vector();

    }

    Vector comuniSelezionati=new Vector();

    for(int i=0;i<vettComuni.length;i++)

    {

      try

      {

       comuniSelezionati.add(umaClient.getComuneByISTAT(vettComuni[i]));

      }

      catch(Exception e)

      {

      }

    }

    return comuniSelezionati;

  }



  private Vector getElencoComuniByProvincia(String siglaProvincia, UmaFacadeClient umaClient)

  {

    try

    {

      return umaClient.getAllComuniByProvincia(siglaProvincia);

    }

    catch(Exception e)

    {

      return new Vector();

    }

  }



  private String findIstatProvincia(Vector comuniSelezionati,Vector provincie)

  {

    if (comuniSelezionati!=null && comuniSelezionati.size()!=0)

    {

      ComuneVO comuneVO=(ComuneVO) comuniSelezionati.get(0);

      return comuneVO.getIstatProvincia();

    }

    if (comuniSelezionati!=null && comuniSelezionati.size()!=0)

    {

      ProvinciaVO provinciaVO=(ProvinciaVO) provincie.get(0);

      return provinciaVO.getIstatProvincia();

    }

    return "";

  }



%>

<%!

  private void errErrorValExc(Htmpl htmpl, HttpServletRequest request, Throwable exc)

  {

    SolmrLogger.debug(this,"\n\n\n\n *********************************** 2");

    SolmrLogger.debug(this,"errErrorValExc()");



    if (exc instanceof it.csi.solmr.exception.ValidationException){



      ValidationErrors valErrs = new ValidationErrors();

      valErrs.add("error", new ValidationError(exc.getMessage()) );



      HtmplUtil.setErrors(htmpl, valErrs, request);

    }

  }

%>