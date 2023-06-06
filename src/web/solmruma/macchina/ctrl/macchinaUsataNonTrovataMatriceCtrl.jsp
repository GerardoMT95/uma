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
<%@ page import="it.csi.solmr.etc.uma.*" %>
<%@ page import="it.csi.solmr.exception.*" %>
<%@ page import="it.csi.solmr.dto.profile.RuoloUtenza" %>

<%!
  public static final String PREV="../layout/macchinaUsataNonTrovataGenere.htm";
  public static final String NEXT="../layout/macchinaUsataNonTrovataDatiCasoMatrice.htm";
  public static final String VIEW="/macchina/view/macchinaUsataNonTrovataMatriceView.jsp";
  public static final String ELENCO_MACCHINE="../layout/elencoMacchine.htm";
%>
<%

  String iridePageName = "macchinaUsataNonTrovataMatriceCtrl.jsp";
  %><%@include file = "/include/autorizzazione.inc" %><%

  if ( session.getAttribute("common")==null || !(session.getAttribute("common") instanceof HashMap)){
    response.sendRedirect(ELENCO_MACCHINE);
    return;
  }
  try
  {
    DittaUMAAziendaVO dittaUMAAziendaVO=(DittaUMAAziendaVO) session.getAttribute("dittaUMAAziendaVO");
    Long idDittaUma=dittaUMAAziendaVO.getIdDittaUMA();

    UmaFacadeClient umaClient = new UmaFacadeClient();
    RuoloUtenza ruoloUtenza = (RuoloUtenza) session.getAttribute("ruoloUtenza");

    HashMap common = (HashMap) session.getAttribute("common");
    Object obj=common.get("elencoMatrici");
    MacchinaVO macchinaVO=(MacchinaVO)common.get("macchinaVO");
    macchinaVO.setMatricolaMotore(null);
    macchinaVO.setMatricolaTelaio(null);
    if (!(obj instanceof java.util.Vector) || obj==null)
    {
      response.sendRedirect(PREV);
      return;
    }
    Vector elencoMatrici=(Vector)obj;
    if (request.getParameter("avanti")!=null)
    {
      common.put("matriceVO",umaClient.getMatrice((Long)new Long(request.getParameter("idMatrice"))));
      session.setAttribute("common",common);
      response.sendRedirect(NEXT);
      return;
    }
    else
    {
      if (request.getParameter("indietro")!=null)
      {
        response.sendRedirect(PREV);
        return;
      }
    }
/**/
    String startRowStr=request.getParameter("startRow");
    int startRow=0;
    int rows=elencoMatrici.size();

    if (startRowStr!=null)
    {
      try
      {
        startRow=new Integer(startRowStr).intValue();
      }
      catch(Exception e) // Errore, suppongo startrow==0 e quindi non faccio nulla!!!
      {
      }
    }
    int prevPage=startRow-SolmrConstants.NUM_MAX_ROWS_PAG;
    int nextPage=startRow+SolmrConstants.NUM_MAX_ROWS_PAG;
    if (nextPage>=rows)
    {
      nextPage=startRow;
    }
    if (prevPage<=0)
    {
      prevPage=0;
    }
    int maxPage=rows/SolmrConstants.NUM_MAX_ROWS_PAG+(rows%SolmrConstants.NUM_MAX_ROWS_PAG>0?1:0);
    if (rows==0)
    {
      maxPage=1;
    }
    int currentPage=startRow/SolmrConstants.NUM_MAX_ROWS_PAG+1+(startRow%SolmrConstants.NUM_MAX_ROWS_PAG>0?1:0);

    int size=elencoMatrici.size();

    request.setAttribute("startRow",new Long(startRow));
    request.setAttribute("currentPage", new Long(currentPage));
    request.setAttribute("prevPage", new Long(prevPage));
    request.setAttribute("nextPage", new Long(nextPage));
    request.setAttribute("maxPage", new Long(maxPage));
    request.setAttribute("rows",new Long(rows));

/**/

    Vector ids=getIds(elencoMatrici,startRow,SolmrConstants.NUM_MAX_ROWS_PAG);
    request.setAttribute("elencoMatriciPage",umaClient.getRangeMatrici(ids));
  }
  catch(Exception e)
  {
    if ( e instanceof SolmrException )
    {
      setError(request,e.getMessage());
    }
    else
    {
      setError(request,"Si è verificato un errore di sistema");
    }
  }
  %><jsp:forward page="<%=VIEW%>" /><%
%>

<%!

  private void setError(HttpServletRequest request, String msg)
  {
    SolmrLogger.debug(this,"\n\n\n\n\n\n\n\n\n\n\nmsg="+msg+"\n\n\n\n\n\n\n\n");
    ValidationErrors errors=new ValidationErrors();
    errors.add("errors", new ValidationError(msg));
    request.setAttribute("errors",errors);
  }

  private Vector getIds(Vector elencoMatrici,int start, int size)
  {
    int vectSize=elencoMatrici.size();
    Vector result=new Vector();
    for(int i=start;i<vectSize && i<start+size;i++)
    {
      result.add(elencoMatrici.get(i));
    }
    return result;
  }
%>