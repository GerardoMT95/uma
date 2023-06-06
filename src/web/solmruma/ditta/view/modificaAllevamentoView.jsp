<%@ page language="java"

      contentType="text/html"

      isErrorPage="true"

%>
<%@ page import="java.util.*" %><%@ page import="it.csi.jsf.htmpl.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%

  Vector lavorazioniPraticate= (Vector) request.getAttribute("lavorazioniPraticate");

  AllevamentoVO allevamentoVO=(AllevamentoVO) request.getAttribute("allevamentoVO");

  UmaFacadeClient umaClient = new UmaFacadeClient();

  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl("ditta/layout/modificaAllevamento.htm");
%><%@include file = "/include/menu.inc" %><%

  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();


  Vector specie=new Vector();

  try

  {

    specie=umaClient.getSpecieAnimali();

  }

  catch(SolmrException e)

  {

  }

  int specieSize=specie.size();

  SolmrLogger.debug(this,"\nEntering modificaAllevamentoView.jsp\n");

  htmpl.set("pageFrom",request.getParameter("pageFrom"));

  htmpl.set("categoriaSelected",allevamentoVO.getIdCategoria());

  SolmrLogger.debug(this,"allevamento.getIdCategoria()="+allevamentoVO.getIdCategoria());

  htmpl.newBlock("blkComboSpecie");

  htmpl.set("blkComboSpecie.idSpecie","");

  htmpl.set("blkComboSpecie.specieDesc","");

  for(int i=0;i<specieSize;i++)

  {

    SpecieAnimaleVO specieVO=(SpecieAnimaleVO)specie.get(i);

    htmpl.newBlock("blkComboSpecie");

    htmpl.set("blkComboSpecie.idSpecie",""+specieVO.getIdSpecieAnimale());

    if (specieVO.getIdSpecieAnimale().toString().equals(allevamentoVO.getIdSpecie()))

    {

      htmpl.set("blkComboSpecie.checkedSpecie","selected");

    }

    htmpl.set("blkComboSpecie.specieDesc",""+specieVO.getDescrizione());

  }

  for(int i=0;i<specieSize;i++)

  {

    SpecieAnimaleVO specieVO=(SpecieAnimaleVO)specie.get(i);

    htmpl.newBlock("blkSpecie");

    htmpl.set("blkSpecie.categoria",""+(i+1));

    Vector categorie=specieVO.getCategorieAnimali();

    int size=categorie.size();

    for(int j=0;j<size;j++)

    {

      htmpl.newBlock("blkSpecie.blkCategoria");

      TipoCategoriaAnimaleVO tipoCategoriaAnimaleVO=(TipoCategoriaAnimaleVO) categorie.get(j);

      htmpl.set("blkSpecie.blkCategoria.categoria",""+(i+1));

      htmpl.set("blkSpecie.blkCategoria.index",""+(j+1));

      htmpl.set("blkSpecie.blkCategoria.categoriaDesc",(""+tipoCategoriaAnimaleVO.getDescrizione()).trim());

      htmpl.set("blkSpecie.blkCategoria.categoriaCod",(""+tipoCategoriaAnimaleVO.getIdCategoriaAnimale()).trim());

      htmpl.set("blkSpecie.blkCategoria.unitaMisura",(""+tipoCategoriaAnimaleVO.getUnitaMisura()).trim());

    }

  }

  Vector lavorazioniPossibili=umaClient.getTipiLavorazioniTipoLavorazioneA();

  int lSize=lavorazioniPossibili.size();

  for(int j=0;j<lSize;j++)

  {

    htmpl.newBlock("blkLavorazioni");

    CodeDescr lavorazione=(CodeDescr) lavorazioniPossibili.get(j);

    htmpl.set("blkLavorazioni.code",(""+lavorazione.getCode()).trim());

    htmpl.set("blkLavorazioni.desc",(""+lavorazione.getDescription()).trim());

    SolmrLogger.debug(this,"lavorazioniPraticate="+lavorazioniPraticate);

    if (findCode(lavorazione.getCode(),lavorazioniPraticate))

    {

      htmpl.newBlock("blkLavorazioniPraticate");

      htmpl.set("blkLavorazioniPraticate.code",(""+lavorazione.getCode()).trim());

      htmpl.set("blkLavorazioniPraticate.desc",(""+lavorazione.getDescription()).trim());

    }

  }
  
  if(allevamentoVO.getFlagSoccida() != null && allevamentoVO.getFlagSoccida().equals(SolmrConstants.FLAG_SI))
      htmpl.set("soccida", "Si");

  HtmplUtil.setValues(htmpl,allevamentoVO,(String)session.getAttribute("pathToFollow"));

  ValidationErrors errors=(ValidationErrors)request.getAttribute("errors");

  SolmrLogger.debug(this,"errors="+errors);

  HtmplUtil.setErrors(htmpl,errors,request);

  disableFields(htmpl,session);

  out.print(htmpl.text());

%>

<%!

  private void disableFields(Htmpl htmpl, HttpSession session)
  {
    HashMap parametriUM=(HashMap)session.getAttribute("parametriUM");

    Date umal=(Date)parametriUM.get(SolmrConstants.PARAMETRO_GESTIONE_ALLEVAMENTI);
    Date toDay = new Date();
    if (toDay.after(umal))
    {
      htmpl.set("disabled","disabled='disabled'");
    }
  }

  private boolean findCode(Integer code,Vector codes)

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