<%@page import="it.csi.jsf.htmpl.Htmpl"%>
<%@page import="it.csi.jsf.htmpl.HtmplFactory"%>
<%@page import="it.csi.solmr.util.DateUtils"%>
<%@page import="it.csi.solmr.etc.SolmrConstants"%>
<%!// Costanti
  private static final String LAYOUT = "/domass/layout/stampaPrelievi.htm";%>
<%
  Htmpl htmpl = HtmplFactory.getInstance(application).getHtmpl(LAYOUT);
%><%@include file="/include/menu.inc"%>
<%
  //System.err.println("2");
  // Carico l'anno base da cui partire
  // Non c'è rischio NullPointerException perchè la controller garantisce
  // che in request ci sia l'attributo (altrimenti avrebbe generato una
  // eccezione)
  int annoIniziale = ((Integer) request.getAttribute("annoIniziale")).intValue();
  int annoCorrente = DateUtils.getCurrentYear().intValue();
  for (int anno = annoCorrente; anno > annoIniziale; --anno)
  {
    htmpl.newBlock("blkOptionAnno");
    htmpl.set("blkOptionAnno.anno", String.valueOf(anno));
    if (anno == annoCorrente)
    {
      htmpl.set("blkOptionAnno.selected", SolmrConstants.HTML_SELECTED,
          null);
    }
  }
%><%=htmpl.text()%>
