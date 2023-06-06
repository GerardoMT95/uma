<%@ page language="java"
      contentType="text/html"
      isErrorPage="true"
%>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.etc.*" %>
<%@ page import="it.csi.solmr.dto.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<jsp:useBean id="allevamentoVO" scope="page" class="it.csi.solmr.dto.uma.AllevamentoVO">
  <jsp:setProperty name="allevamentoVO" property="*" />
</jsp:useBean>
<%

  String iridePageName = "modificaAllevamentoCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%


  boolean bIsAfterUMAL=isAfterUMAL(session);
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  UmaFacadeClient umaClient = new UmaFacadeClient();

  String url="/ditta/ctrl/elencoAllevamentoCtrl.jsp";

  String elenco="/ditta/ctrl/elencoAllevamentoCtrl.jsp";

  String elencoBis="/ditta/ctrl/elencoAllevamentoBisCtrl.jsp";

  String viewUrl="/ditta/view/modificaAllevamentoView.jsp";

  String elencoHtm="../../ditta/layout/elencoAllevamento.htm";

  String elencoBisHtm="../../ditta/layout/elencoAllevamentoBis.htm";

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  if (request.getParameter("salva.x")!=null)

  {

    request.setAttribute("allevamentoVO",allevamentoVO);

    Vector lavorazioniPraticate=new Vector();

    String lp[]=request.getParameterValues("lavorazioniEffettuate");

    SolmrLogger.debug(this,"lp="+lp);

    if (lp!=null)

    {

      for(int idx=0;idx<lp.length;idx++)

      {

        LavorazioniPraticateVO lavorazioniVO=new LavorazioniPraticateVO();

        try

        {


        lavorazioniPraticate.add(idx,new Long(lp[idx]));

        }

        catch(Exception e)

        {



        }

      }

    }

    request.setAttribute("lavorazioniPraticate",lavorazioniPraticate);

    ValidationErrors errors=null;
    if (bIsAfterUMAL) // Se è dopo la data del parametro FUMA sono
    { // modificabili solo le lavorazioni e le note
      errors=new ValidationErrors();
      // Aggiungo la validazione sulle note
      String note=allevamentoVO.getNote();
      if (note!=null && note.length()>512)
      {
        errors.add("note",new ValidationError("Campo troppo lungo. Max 512 caratteri"));
      }
    }
    else
    { // Altrimenti valido tutti i dati
      errors=allevamentoVO.validateUpdate();
    }

    if (lavorazioniPraticate!=null && lavorazioniPraticate.size()==0)

    {

      errors.add("lavorazioniEffettuate",new ValidationError("Inserire almeno una lavorazione"));

    }

    if (errors.size()!=0)

    {

      request.setAttribute("errors",errors);
      if (bIsAfterUMAL)
      {
        String note=allevamentoVO.getNote();
        try
        {
          allevamentoVO=umaClient.findAllevamentoByID(allevamentoVO.getIdAllevamento());
          allevamentoVO.setIdCategoria(allevamentoVO.getTipoCategoriaAnimaleVO().getIdCategoriaAnimale().toString());
          allevamentoVO.setIdSpecie(allevamentoVO.getTipoCategoriaAnimaleVO().getTipoSpecieAnimale().getCode().toString());
          Date dataCarico=allevamentoVO.getDataCarico();
          if (dataCarico!=null)
          {
            allevamentoVO.setDataCaricoStr(DateUtils.formatDate(dataCarico));
          }
          Date dataScarico=allevamentoVO.getDataScarico();
          if (dataScarico!=null)
          {
            allevamentoVO.setDataScaricoStr(DateUtils.formatDate(dataScarico));
          }
          allevamentoVO.setQuantitaStr(allevamentoVO.getQuantita().toString());
          request.setAttribute("allevamentoVO",allevamentoVO);
        }
        catch(Exception ex)
        {
          ex.printStackTrace();
        }
        allevamentoVO.setNote(note);
      }

    }

    else

    {

      try

      {

//        allevamentoVO.setIdAllevamento(new Long(request.getParameter());
        if (bIsAfterUMAL)
        {
          umaClient.updateAllevamentoAfterFUMA(idDittaUma,allevamentoVO,lavorazioniPraticate,ruoloUtenza);
        }
        else
        {
          umaClient.updateAllevamento(idDittaUma,allevamentoVO,lavorazioniPraticate,ruoloUtenza);
        }

      }

      catch(SolmrException e)

      {

        errors= e.getValidationErrors();

        if (errors!=null)

        {

          request.setAttribute("errors",errors);

          if (bIsAfterUMAL)
          {
            String note=allevamentoVO.getNote();
            try
            {
              allevamentoVO=umaClient.findAllevamentoByID(allevamentoVO.getIdAllevamento());
              allevamentoVO.setIdCategoria(allevamentoVO.getTipoCategoriaAnimaleVO().getIdCategoriaAnimale().toString());
              allevamentoVO.setIdSpecie(allevamentoVO.getTipoCategoriaAnimaleVO().getTipoSpecieAnimale().getCode().toString());
              Date dataCarico=allevamentoVO.getDataCarico();
              if (dataCarico!=null)
              {
                allevamentoVO.setDataCaricoStr(DateUtils.formatDate(dataCarico));
              }
              Date dataScarico=allevamentoVO.getDataScarico();
              if (dataScarico!=null)
              {
                allevamentoVO.setDataScaricoStr(DateUtils.formatDate(dataScarico));
              }
              allevamentoVO.setQuantitaStr(allevamentoVO.getQuantita().toString());
              request.setAttribute("allevamentoVO",allevamentoVO);
            }
            catch(Exception ex)
            {
              ex.printStackTrace();
            }
            allevamentoVO.setNote(note);
          }

          %><jsp:forward page="<%=viewUrl%>"/><%

          return;

        }

        ValidationException valEx=new ValidationException("",viewUrl);

        SolmrLogger.debug(this,"\n\nException="+e.getMessage()+"\n\n");

        valEx.addMessage(e.getMessage(),"exception");

        throw valEx;

      }

      String forwardUrl=elencoHtm;

      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))

      {

        forwardUrl=elencoBisHtm;

      }

      session.setAttribute("notifica","Modifica eseguita con successo");

      response.sendRedirect(forwardUrl);

      return;

//      response.sendRedirect(forwardUrl+"?notifica=modifica");

/*      ValidationException valEx=new ValidationException("",url);

      valEx.addMessage("Aggiornamento eseguito con successo","exception");

      throw valEx;*/

    }

  }

  else

  {

    if (request.getParameter("annulla.x")!=null)

    {

      if ("bis".equalsIgnoreCase(request.getParameter("pageFrom")))

      {

        response.sendRedirect(elencoBisHtm);

      }

      else

      {

        response.sendRedirect(elencoHtm);

      }

      return;

    }

    else

    {

      SolmrLogger.debug(this,"modificaAllevamentoCtrl called by elencoAllevamentoCtrl");

      allevamentoVO=umaClient.findAllevamentoByID(new Long(request.getParameter("radiobutton")));

      convertForValidation(allevamentoVO);

      SolmrLogger.debug(this,"allevamentoVO.getIdAllevamento()"+allevamentoVO.getIdAllevamento());

      request.setAttribute("allevamentoVO",allevamentoVO);

      request.setAttribute("lavorazioniPraticate",convertLavorazioniPraticate(umaClient.getLavorazioniPraticate(allevamentoVO.getIdAllevamento())));

    }

  }



%>

<jsp:forward page="<%=viewUrl%>"/>

<%!

private void setFieldsAfterErrors()
{

}

  private boolean isAfterUMAL(HttpSession session)
  {
    HashMap parametriUM=(HashMap)session.getAttribute("parametriUM");

    Date umal=(Date)parametriUM.get(SolmrConstants.PARAMETRO_GESTIONE_ALLEVAMENTI);
    Date toDay = new Date();
    return toDay.after(umal);
  }


/*

 * Converte il vettore di contente le lavorazioni praticate come vettore di oggetti

 * LavorazioniPraticateVO in un vettore di Long necessario alla visualizzazione.

 */

  private Vector convertLavorazioniPraticate(Vector lavorazioniPraticate)

  {

    int size=lavorazioniPraticate!=null?lavorazioniPraticate.size():0;

    SolmrLogger.debug(this,"lavorazioniPraticate="+lavorazioniPraticate.size());

    SolmrLogger.debug(this,"lavorazioniPraticate.size()="+lavorazioniPraticate==null?0:lavorazioniPraticate.size());

    Vector result=new Vector();

    for(int i=0;i<size;i++)

    {

      result.add(new Long(((LavorazioniPraticateVO)lavorazioniPraticate.get(i)).getTipoLitriAllevamentoVO().getTipoLavorazioni().getCode().longValue()));

      SolmrLogger.debug(this,"getIdLavorazioniPraticate()="+((LavorazioniPraticateVO)lavorazioniPraticate.get(i)).getTipoLitriAllevamentoVO().getTipoLavorazioni().getCode());

    }

    return result;

  }

/*

 * Esegue le conversioni necessarie per la visualizzazione e la validazione dei dati:

 * sposta i valori dei campi Long e Date nelle corrispondenti variabili String.

 */

private void convertForValidation(AllevamentoVO allevamentoVO)

  {

    allevamentoVO.setIdCategoria(""+allevamentoVO.getTipoCategoriaAnimaleVO().getIdCategoriaAnimale());

    allevamentoVO.setIdSpecie(""+allevamentoVO.getTipoCategoriaAnimaleVO().getTipoSpecieAnimale().getCode().longValue());

    allevamentoVO.setDataCaricoStr(DateUtils.formatDate(allevamentoVO.getDataCarico()));

    allevamentoVO.setQuantitaStr(""+allevamentoVO.getQuantita());

  }

%>

