<%@ page language="java"
         contentType="text/html"
%>

<%@ page import="it.csi.solmr.client.uma.*" %>
<%@ page import="it.csi.solmr.dto.uma.*" %>
<%@ page import="it.csi.solmr.util.*" %>
<%@ page import="it.csi.solmr.etc.SolmrConstants" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="java.util.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  public static final String ELENCO_STORICO = "/domass/view/assegnazioniView.jsp";
  public static final String DETTAGLIO_ASSEGNAZIONE_BASE = "/domass/ctrl/dettaglioDomandaCtrl.jsp";
  public static final String DETTAGLIO_ACCONTO = "/domass/ctrl/dettaglioAssegnazioneAccontoCtrl.jsp";
  public static final String CONFERMA_ELIMINA = "/domass/ctrl/confermaEliminaDomAssCtrl.jsp";
  public static final String ANNULLA = "/domass/ctrl/annulloAssegnazioneCtrl.jsp";
  public static final String ESEGUI_CONTROLLI = "../layout/controlliEsegui.htm";
  public static final String CONTROLLI = "../layout/controlliFine.htm";

 %>
<%

  String iridePageName = "assegnazioniCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%




  session.removeAttribute("common");
  UmaFacadeClient umaFacadeClient = new UmaFacadeClient();
  DittaUMAAziendaVO dumaa = (DittaUMAAziendaVO)session.getAttribute("dittaUMAAziendaVO");
  Long idDittaUma = dumaa.getIdDittaUMA();


  findData(request, umaFacadeClient, idDittaUma, ELENCO_STORICO);

  //Gestisce una sola visualizzazione del messaggio di notifica
  String info=(String)session.getAttribute("notifica");
  if (info!=null)
  {
    session.removeAttribute("notifica");
    throwValidation(info,ELENCO_STORICO);
  }
  
  int sizeResult = 0;
  int paginaCorrente = 0;
  Integer paginaCorrenteInteger = null;
  Vector storAss=(Vector) request.getAttribute("storAss");
  if(request.getParameter("valorePulsante") != null && request.getParameter("valorePulsante").equals("avanti")){
      if(storAss!=null){
        sizeResult = storAss.size();
        SolmrLogger.debug(this,"!!!!!!!!!!!!!! elencoAziendaCtrl.jsp - valore di num_max_rows: "+SolmrConstants.NUM_MAX_ROWS_PAG);
        SolmrLogger.debug(this,"??????????? elencoAziendaCtrl.jsp - numero elementi del vetttore totale: "+sizeResult);
        
        //System.err.println("request.getParameter(\"paginaCorrente\"): "+request.getParameter("paginaCorrente"));
        //paginaCorrenteInteger = ((Integer)request.getAttribute("currPage"));
        paginaCorrenteInteger = new Integer(request.getParameter("paginaCorrente"));
        SolmrLogger.debug(this,"??????????? elencoAziendaCtrl.jsp - pagina corrente: "+paginaCorrenteInteger.intValue());

        if(paginaCorrenteInteger.toString().equals(request.getParameter("totalePagine")))
          paginaCorrente = paginaCorrenteInteger.intValue();
        else
          paginaCorrente = paginaCorrenteInteger.intValue()+1;
          
        //session.removeAttribute("currPage");
        paginaCorrenteInteger = new Integer(paginaCorrente);
        request.setAttribute("currPage",paginaCorrenteInteger);
      }
  }
  else{
    	if(request.getParameter("valorePulsante") != null && request.getParameter("valorePulsante").equals("indietro")){
	      if(storAss!=null){
	        sizeResult = storAss.size();
	        //paginaCorrenteInteger = ((Integer)request.getAttribute("currPage"));
	        
	        //System.err.println("request.getParameter(\"paginaCorrente\"): "+request.getParameter("paginaCorrente"));
	        paginaCorrenteInteger = new Integer(request.getParameter("paginaCorrente"));
	        if(paginaCorrenteInteger.toString().equals("1"))
	          paginaCorrente = paginaCorrenteInteger.intValue();
	        else
	          paginaCorrente = paginaCorrenteInteger.intValue()-1;
	          
	        //session.removeAttribute("currPage");
	        paginaCorrenteInteger = new Integer(paginaCorrente);
	        request.setAttribute("currPage",paginaCorrenteInteger);
	      }
  	  }
	}


  SolmrLogger.debug(this,"\n\n\nsession.getAttribute(\"notifica\"): " + session.getAttribute("notifica"));



  if (request.getParameter("elimina.x")!=null)

  {

    SolmrLogger.debug(this,"///////Elimina");

    %><jsp:forward page="<%=CONFERMA_ELIMINA%>" /><%
  }
  else
  {
    if (request.getParameter("dettaglio.x")!=null)
    {
      Long idDomAss = new Long(request.getParameter("idDomAss"));
			DomandaAssegnazione da = umaFacadeClient.findDomAssByPrimaryKey(idDomAss);
			request.setAttribute("DOMANDA_ASSEGNAZIONE",da);
			if (SolmrConstants.TIPO_DOMANDA_ACCONTO.equals(da.getTipoDomanda()))
			{
		    %><jsp:forward page="<%=DETTAGLIO_ACCONTO%>" /><%
			}
			else
			{
		    %><jsp:forward page="<%=DETTAGLIO_ASSEGNAZIONE_BASE%>" /><%
			}
    }
    else
    {
      if (request.getParameter("annulla.x")!=null)
      {//
        SolmrLogger.debug(this,"///////Annulla");
        Long idDomAss = null;
        if ( request.getParameter("idDomAss")!=null )
        {
          idDomAss = new Long(request.getParameter("idDomAss"));
        }



        DomandaAssegnazione domAss = umaFacadeClient.findDomAssByPrimaryKey(new Long((String)request.getParameter("idDomAss")));



        GregorianCalendar greg = new GregorianCalendar();

        greg.setTime(domAss.getDataRiferimento());

          //Controllo esistenza buoni non restituiti - Begin

          try

          {

            SolmrLogger.debug(this,"\n\n\n\n\n\n\n\n\nAnnulla Domanda !!!!!!!\n\n\n\n\n\n\n\n");

            SolmrLogger.debug(this,"idDomAss: "+idDomAss);

            %><jsp:forward page="<%=ANNULLA%>" /><%

            return;

          }

          catch(Exception e)

          {

            SolmrLogger.debug(this,"Condizioni non valide per annullare la domanda");

            findData(request, umaFacadeClient, idDittaUma, ELENCO_STORICO);

            this.throwValidation(e.getMessage(),ELENCO_STORICO);

          }

          //Controllo esistenza buoni non restituiti - End

      }//

      else

      {

        if (request.getParameter("controlli.x")!=null){

          SolmrLogger.debug(this, "///////Controlli");

          Long idDomanda = new Long(request.getParameter("idDomAss"));

          Hashtable common = new Hashtable();

          common.put("idDomandaAssegnazione", idDomanda);

          //common.put("notifica", "notifica");

          session.setAttribute("common", common);

          response.sendRedirect(CONTROLLI);

          return;

        }

        else{

          if (request.getParameter("base.x")!=null){

            SolmrLogger.debug(this, "///////base");

            Hashtable common = new Hashtable();

            Long idDomanda = null;
            if(request.getParameter("idDomAss")!=null){
              idDomanda = new Long(request.getParameter("idDomAss"));
              common.put("idDomandaAssegnazione", idDomanda);
            }

            common.put("notifica", "base");

            session.setAttribute("common", common);

/* MODIFICA
by Einaudi 20/10/2006 Richiamo sempre dei controlli indipendentemente
dalla data dataInizioGestioneFascicolo

            Date dataInizioGestioneFascicolo = (Date)session.getAttribute("dataInizioGestioneFascicolo");
            Date toDay = new Date();

            if (toDay.after(dataInizioGestioneFascicolo)){
              SolmrLogger.debug(this, "if (toDay.after(dataInizioGestioneFascicolo))");
              response.sendRedirect(ESEGUI_CONTROLLI);
            }else{
              SolmrLogger.debug(this, "else (toDay.after(dataInizioGestioneFascicolo))");
              response.sendRedirect(baseUrl);
            }
*/
              response.sendRedirect(ESEGUI_CONTROLLI);
/* FINE MODIFICA */
            return;

          }

          else  {

            if ( (request.getParameter("supplementare.x")!=null) || (request.getParameter("supplementareMaggiorazione.x")!=null)){
              SolmrLogger.debug(this, "-- CASO supplementare.x  o supplementareMaggiorazione.x");	

              SolmrLogger.debug(this, "///////supplementare");

              Hashtable common = new Hashtable();

              Long idDomanda = null;
              if(request.getParameter("idDomAss")!=null){
                idDomanda = new Long(request.getParameter("idDomAss"));
                common.put("idDomandaAssegnazione", idDomanda);
              }

              if( request.getParameter("supplementare.x")!=null){
              	common.put("notifica", "supplementare");
              }
              else if(request.getParameter("supplementareMaggiorazione.x")!=null){
            	common.put("notifica", "supplementareMaggiorazione");
              }

              session.setAttribute("common", common);

              /** Modifica by Einaudi 26/10/2006
                *  I controlli vengono eseguiti indipendentemente da
                *  dataInizioGestioneFascicolo

              Date dataInizioGestioneFascicolo = (Date)session.getAttribute("dataInizioGestioneFascicolo");
              Date toDay = new Date();

              if (toDay.after(dataInizioGestioneFascicolo)){
                SolmrLogger.debug(this, "if (toDay.after(dataInizioGestioneFascicolo))");
                response.sendRedirect(ESEGUI_CONTROLLI);
              }else{
                SolmrLogger.debug(this, "else (toDay.after(dataInizioGestioneFascicolo))");
                response.sendRedirect(supplementareUrl);
              }
 FINE MODIFICA*/
              response.sendRedirect(ESEGUI_CONTROLLI);
              return;

            }

            else  {

              SolmrLogger.debug(this,"///////Elenco");

              findData(request, umaFacadeClient, idDittaUma, ELENCO_STORICO);

            }
          }

        }

      }

    }

  }

  %>
    <jsp:forward page ="<%=ELENCO_STORICO%>" />
  <%!

    private void findData(HttpServletRequest request,UmaFacadeClient umaClient,Long idDittaUma,String validateUrl)
      throws ValidationException
    {
      try
      {
        Vector storAss=umaClient.findStoricoAssDomByIdDittaUma(idDittaUma);
        request.setAttribute("storAss", storAss);
      }
      catch(Exception e)
      {
        SolmrLogger.debug(this,"\n\n\n\n\n\n\n\n\nException="+e.getMessage());
        SolmrLogger.debug(this,"exception="+e+"\n\n\n\n\n\n\n\n\n");
        throwValidation(e.getMessage(),validateUrl);
      }
    }

    private void throwValidation(String msg,String validateUrl) throws ValidationException
    {
      ValidationException valEx = new ValidationException("Errore: eccezione="+msg,validateUrl);
      valEx.addMessage(msg,"exception");
      throw valEx;
    }

  %>