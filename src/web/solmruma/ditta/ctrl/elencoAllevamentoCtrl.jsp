<%@ page language="java" contentType="text/html" isErrorPage="true"%>



<%@ page import="java.util.*"%>
<%@ page import="it.csi.jsf.htmpl.*"%>
<%@ page import="it.csi.solmr.client.uma.*"%>
<%@ page import="it.csi.solmr.client.anag.*"%>
<%@ page import="it.csi.solmr.util.*"%>
<%@ page import="it.csi.solmr.dto.uma.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.dto.*"%>
<%@ page import="it.csi.solmr.etc.*"%>
<%@ page import="it.csi.solmr.etc.uma.*"%>
<%@ page import="it.csi.solmr.exception.*"%>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>



<%!

  public static String URL="/ditta/view/elencoAllevamentoView.jsp";

  public static String MODIFICA_URL="/ditta/ctrl/modificaAllevamentoCtrl.jsp";

  public static String VALIDATE_URL="/ditta/view/elencoAllevamentoView.jsp";

  public static String INSERT_URL="/ditta/ctrl/nuovoAllevamentoCtrl.jsp";

  public static String DELETE_URL="/ditta/ctrl/confermaEliminaAllevamentoCtrl.jsp";

%>

<%

  String iridePageName = "elencoAllevamentoCtrl.jsp";
  %><%@include file="/include/autorizzazione.inc"%>
<%

  SolmrLogger.debug(this, "   BEGIN elencoAllevamentoCtrl"); 
  DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");

  Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

  SolmrLogger.debug(this,"[elencoAllevamentoCtrl::service] idDittaUma="+idDittaUma);

  UmaFacadeClient umaClient = new UmaFacadeClient();

  RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

  String info=(String)session.getAttribute("notifica");
  //System.err.println("info="+info);
  if (info!=null)

  {

    findData(request,umaClient,idDittaUma,URL);

    session.removeAttribute("notifica");

    throwValidation(info,VALIDATE_URL);

  }
  //System.err.println("passato info="+info);

  if (request.getParameter("inserisci.x")!=null)

  {
	 SolmrLogger.debug(this, "   END elencoAllevamentoCtrl"); 
      %><jsp:forward page="<%=INSERT_URL%>" />
<%

      return;
  }

  else

  {

    if (request.getParameter("modifica.x")!=null)

    {

      try

      {

        AllevamentoVO allevamentoVO=(AllevamentoVO) umaClient.findAllevamentoByID(new Long(request.getParameter("radiobutton")));

        if (allevamentoVO.getDataFineVal()!=null)

        {

          throw new Exception("Allevamento non modificabile perchè riferito ad un dato storicizzato");

        }

      }

      catch(Exception e)

      {

        request.setAttribute("errorMessage",e.getMessage());
        %><jsp:forward
	page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
<%
        return;

      }
      SolmrLogger.debug(this, "   END elencoAllevamentoCtrl");

      %><jsp:forward page="<%=MODIFICA_URL%>" />
<%

    }

    else

    {

      if (request.getParameter("elimina.x")!=null)

      {

        // Eliminazione allevamento

        Long idAllevamento=null;

        SolmrLogger.debug(this,"[elencoAllevamentoCtrl::service] -------------------------------- ELIMINAZIONE --------------------------------");

        try

        {
          AllevamentoVO allevamentoVO=(AllevamentoVO) umaClient.findAllevamentoByID(new Long(request.getParameter("radiobutton")));

          if (allevamentoVO.getDataFineVal()!=null)

          {

            throw new Exception("Allevamento non modificabile perchè riferito ad un dato storicizzato");

          }

        }

        catch(Exception e)

        {
          request.setAttribute("errorMessage",e.getMessage());
          SolmrLogger.debug(this, "   END elencoAllevamentoCtrl");
          %><jsp:forward
	page="<%=it.csi.solmr.etc.SolmrConstants.JSP_ERROR_PAGE%>" />
<%
          return;
        }

        // Controlli superati positivamente

        SolmrLogger.debug(this, "   END elencoAllevamentoCtrl");

        %><jsp:forward page="<%=DELETE_URL%>" />
<%

      }

      else

      {

         // Visualizzazione allevamenti

        findData(request,umaClient,idDittaUma,URL);
        SolmrLogger.debug(this, "   END elencoAllevamentoCtrl");

        %><jsp:forward page="<%=URL%>" />
<%

      }

    }

  }

%>



<%!

private void findData(HttpServletRequest request,UmaFacadeClient umaClient,Long idDittaUma,String validateUrl)

    throws ValidationException

{

  try

  {
	
    Vector allevamenti=umaClient.getAllevamenti(idDittaUma,new Boolean(true));

    request.setAttribute("elencoAllevamenti",allevamenti);

  }

  catch(Exception e)

  {

    throwValidation(e.getMessage(),validateUrl);

  }

}

private void throwValidation(String msg,String validateUrl) throws ValidationException

{

  ValidationException valEx = new ValidationException(msg,validateUrl);

  valEx.addMessage(msg,"exception");

  throw valEx;

}

%>