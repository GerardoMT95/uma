// Variabili globali comuni

// Questo flag  indica se il browser deve ignorare gli eventi del mouse
// Viene impostato e utilizzato dalle funzioni filterEvents() e ignoreEvents()

var flagIgnoreEvents = false;

/**
 * RENEW SESSION
 */
//Gestione refresh sessione

//Funzioni per il refresh della sessione - Begin
var req;
var isIE;
var timeout = 1680000; // ms = 28m
//var timeout = 45000; // ms = 45s
var cntRefresh = 0;
var MAX_TIME_REFRESH = 3;

//Inizializzazione gestione refresh - Begin
if(!(window.opener)) {
  //alert("window.opener Š null");
  initTimeout();
}
/*else {
  alert("window.opener non Š null");
}*/
//Inizializzazione gestione refresh - End

function initTimeout() {
  setTimeout("refreshSession()",timeout);
}

// (3) JavaScript function in which XMLHttpRequest JavaScript object is created.
// Please note that depending on a browser type, you create
// XMLHttpRequest JavaScript object differently.  Also the "url" parameter is not
// used in this code (just in case you are wondering why it is
// passed as a parameter).
//
function initRequest(url) {
    if (window.XMLHttpRequest) {
        req = new XMLHttpRequest();
    } else if (window.ActiveXObject) {
        isIE = true;
        req = new ActiveXObject("Microsoft.XMLHTTP");
    }
}

// (2) Event handler that gets invoked whenever a user types a character
// in the input form field whose id is set as "name".  This event
// handler invokes "initRequest(url)" function above to create XMLHttpRequest
// JavaScript object.
//
function refreshSession() {
    //window.alert('Get new Request');
    var url = "../../servlet/RefreshServlet";
    //window.alert('Get new Request');

    // Invoke initRequest(url) to create XMLHttpRequest object
    initRequest(url);

    // The "processRequest" function is set as a callback function.
    // (Please note that, in JavaScript, functions are first-class objects: they
    // can be passed around as objects.  This is different from the way
    // methods are treated in Java programming language.)
    req.onreadystatechange = processRequest;
    req.open("GET", url, true);
    req.send(null);
}

// (4) Callback function that gets invoked asynchronously by the browser
// when the data has been successfully returned from the server.
// (Actually this callback function gets called every time the value
// of "readyState" field of the XMLHttpRequest object gets changed.)
// This callbac function needs to be set to the "onreadystatechange"
// field of the XMLHttpRequest.
//
function processRequest() {
    if (req.readyState == 4) {
      if (req.status == 200) {
        cntRefresh++;
        //window.alert('cntRefresh: '+cntRefresh);
        if(cntRefresh<MAX_TIME_REFRESH){
          //window.alert('if('+cntRefresh+'<'+MAX_TIME_REFRESH+')');
          initTimeout();
        }
        else{
          //window.alert('else('+cntRefresh+'<'+MAX_TIME_REFRESH+')');
        }
      }
    }
}
//Funzioni per il refresh della sessione - End

// Ignora o meno gli eventi del mouse a seconda del valore della variabile globale flagIgnoreEvents
function filterEvents() {
  if ( flagIgnoreEvents ) {
   	window.event.returnValue = false;
  } else {
  	// Mettere qui eventuali messaggi per l'utente
  }
  return true;
}

function ignoreEvents() {
  flagIgnoreEvents = true;
}

//Funzione di LogOut
function logout() {
  if(confirm('Si desidera abbandonare il servizio?'))
  {
    if(window.opener)
    {
      if(!window.opener.closed)
      {
        window.opener.opener = self;
        window.opener.close();
      }
    }
    window.opener = self;
    window.close();
    abandonSession();
  }
}
// Questa funzione apre un nuovo pop-up solo
//a condizione che il parametro "richiesta" sia valorizzato
function NewWindow(mypage, myname, w, h, scroll,richiestaModifica)
{
  if(richiestaModifica != '')
  {
    var winl = (screen.width - w) / 2;
    var wint = (screen.height - h) / 2;
    winprops =    'height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable';
    win = window.open(mypage, myname, winprops);
    if (parseInt(navigator.appVersion) >= 4)
    {
      win.window.focus();
    }
  }
}
//Chiamata al Server x il LogOut
function abandonSession()
{
  NewWindow('../layout/logOut.shtml', 'ChiusuraSessione', '800px', '350px', false, 'Visualizza');
}



  /*** Disabilita tasto indietro ***/

  if (history.length > 0) history.go(+1);

  /*** Disabilita tasto indietro ***/



  /*** Stampa PDF ***/

  function stampaPdf(documentForm, action)
  {
    var d = new Date();
    var unique = (d.getUTCHours() * 60 + d.getUTCMinutes()) * 60 + d.getUTCSeconds();
    var target = "stampa" + unique;
    popPdf("", 645, 500, target);

    var oldTarget = documentForm.target;
    var oldAction = documentForm.action;

    documentForm.target = target;
    documentForm.action = action;
    documentForm.submit();

    documentForm.target = oldTarget;
    documentForm.action = oldAction;
    return;
  }

  function popPdf(page,w,h,target)
  {
    var winl = (screen.width - w) / 2;
    var wint = (screen.height - h) / 2;
    winprops = 'height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars=yes,resizable=yes';
    win = window.open(page, target, winprops);
    if (parseInt(navigator.appVersion) >= 4)
    {
      win.window.focus();
    }
  }

  /*** Stampa PDF ***/

  function stampaExcel(documentForm, action, w, h, target)
  {
    popPdf("", w, h, target);

    var oldTarget = documentForm.target;
    var oldAction = documentForm.action;

    documentForm.target = target;
    documentForm.action = action;
    documentForm.submit();

    documentForm.target = oldTarget;
    documentForm.action = oldAction;
    return;
  }

  function popExcel(page, w, h, target)
  {
    if (w == '' || w == 0)
    {
      w = 800;
    }
    if (h == '' || h == 0)
    {
      h = 430;
    }
    var winl = (screen.width - w) / 2;
    var wint = (screen.height - h) / 2;
    var winprops ='toolbar=no,location=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes,width='+w+',height='+h+',top='+wint+',left='+winl;
    var win = window.open(page, target, winprops);
    if (parseInt(navigator.appVersion) >= 4)
    {
      win.window.focus();
    }
  }

  // Valorizza l'input-item elementName con il valore indicato da elementValue,
  // imposta l'action della form formName al valore specificato da actionValue
  // ed esegue il submit.
  // Prima di richiamare questa funzione, e' consigliabile richiamare la funzione ignoreEvents() per far si' che
  // il browser ignori gli eventi del mouse, prevenendo quindi da doppio-click, ecc.
  // Se il documento non contiene la form formName e/o l'elemento elementName, non viene impostato il valore
  // per l'attributo "action" e/o per l'input-item "elementName" e la funzione restituisce false.
  // Se tutti i parametri sono validi, la funzione restituisce true.
  // Parametri:
  //    - formName:       nome della form
  //    - actionValue:    valore per l'attributo "action" della form
  //    - elementName:    nome dell'input-item da valorizzare prima di eseguire il submit della form
  //    - elementValue:   valore da assegnare all'input-item identifiato da operationName
  function submitForm(formName,actionValue,elementName,elementValue) {

    var theForm     = null;   // Riferimento alla form identificata da formName
    var theElement  = null;   // Riferimento all'input-item identificato da elementName
    var returnValue = null;   // Valore di ritorno

    // Riferimento alla form
    theForm = document.forms[formName];

    if ( theForm && (theForm != null) ) {
      // La form indicata esiste: posso proseguire
      // Riferimento all'input-item
      theElement = theForm.elements[elementName];

      if ( theElement && (theElement != null) ) {

        // L'input-item indicato esiste: posso proseguire solo se flagIgnoreEvents e' false
        theForm.action    = actionValue;
        theElement.value  = elementValue;
        theForm.submit();
        returnValue = true;
      } else {
        // L'input-item indicato non esiste: termino
        returnValue = false;
      }
    } else {
      // La form indicata non esiste: termino
      returnValue = false;
    }

    return returnValue;

  }

  // Come submitForm() ma senza la gstione dell'input-item elementName (che di fatto viene ignorato).
  function submitFormFast(formName,actionValue) {

    var theForm     = null;   // Riferimento alla form identificata da formName
    var returnValue = null;   // Valore di ritorno

    // Riferimento alla form
    theForm = document.forms[formName];

    if ( theForm && (theForm != null) ) {
      // La form indicata esiste: posso proseguire
      theForm.action    = actionValue;
      theForm.submit();
      returnValue = true;

    } else {
      // La form indicata non esiste: termino
      returnValue = false;
    }

    return returnValue;

  }

    // Verifica che sia stato selezionato un valore da una serie di radio-button.
    //
    // Parametri:
    // - fqName: nome dei radio-button. Deve essere indicato in maniera completa
    //           includendo anche il nome della form e il riferimento all'oggetto document.
    //
    // Risultato:
    // - True  se e' stato selezionato un radio-button
    // - False se non e' stato selezionato alcun radio-button
    //
    // Esempio:
    // Per verificare la selezione su una serie di radio-button di nome "seleziona"
    // contenuta in una form di nome "dati", invocare la funzione con:
    //
    //               verificaSeleziona(document.dati.seleziona);
    //
    // oppure con:
    //
    //               verificaSeleziona(document.forms['dati'].elements['seleziona']);
    function verificaSelezione( fqName ) {

        if ( fqName != null ) {
            if ( (! fqName.length) && (fqName.checked) ) {
                return true;
            }
            if ( fqName.length > 0 ) {
                for( i = 0; i < fqName.length; i++ ) {
                    if ( fqName[ i ].checked ) {
                        return true;
                    }
                }
            }
        }
        return false;
    }


    //Setta il campo hidden 'operazione' con l'operazione da effettuare
    //all'interno del form deve esistere un campo hidden con nome 'operazione'
    function go(operazione){
      document.forms[0].operazione.value=operazione;
      document.forms[0].submit();
    }

    function getSelezione( radioName ) {

        if ( radioName != null ) {
            if ( (! radioName.length) && (radioName.checked) ) {
                return radioName.value;
            }
            if ( radioName.length > 0 ) {
                for( i = 0; i < radioName.length; i++ ) {
                    if ( radioName[ i ].checked ) {
                        return radioName[i].value;
                    }
                }
            }
        }
        return "-1";
    }


    function setCheckboxStatus(formName,checkboxName,status) {
        var objForm = document.forms[formName];
        if ( objForm ) {
            // La form esiste
            var objChkBox = objForm.elements[checkboxName];
            if ( objChkBox ) {
                // La checkbox esiste
                var len = objChkBox.length;

                if ( len ) {
                    // Checkbox multipla
                    for ( i = 0; i < len; i++ ) {
                        objChkBox[ i ].checked = status;
                    }
                } else {
                    // Checkbox singola
                    objChkBox.checked = status;
                }
            }
        }
    }

    function selectAllCheckBox(formName,checkboxName) {
        setCheckboxStatus(formName,checkboxName,true);
    }

    function deselectAllCheckBox(formName,checkboxName) {
        setCheckboxStatus(formName,checkboxName,false);
    }

  function goToPdf(pdf, form, message)
  {
    var radio = document.form1.radiobutton;
    if (! radio)
    {
      alert(message);
      return;
    }
    if (! radio.length)
    {
      if (radio.checked)
      {
        stampaPdf(form, pdf);
        return;
      }
    }
    else
    {
      for (i=0; i<radio.length; i++)
      {
        if (radio[i].checked)
        {
          stampaPdf(form, pdf);
          return;
        }
      }
    }
    alert(message);
  }

  function submitFormFunzione(form, funzione)
  {
    form.funzione.value = funzione;
    form.submit();
  }

    /*
     * Aggiunto da Michele il 26/05/2006
     * Blocco l'utilizzo del tasto "Invio" perché
     * ho notato che può creare qualche problema,
     * specialmente con la paginazione, ma non solo.
     */
    function checkCR(evt) {
      var evt  = (evt) ? evt : ((event) ? event : null);
      var node = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null);
      if ((evt.keyCode == 13) && (node.type=="text")) {return false;}
    }
    document.onkeypress = checkCR;
    
function setHiddenOperazione(form, operazione) {
  form.operazione.value = operazione;
}
