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

if(typeof(window.opener)=="undefined") {
  initTimeout();
}

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
    //var url = "../../servlet/RefreshServlet";
    var url = window.location.protocol +
            window.location.host +
            window.location.pathname +
            "/client/RefreshServlet";

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
// This callback function needs to be set to the "onreadystatechange"
// field of the XMLHttpRequest.
//
function processRequest() {
    if (req.readyState == 4) {
      if (req.status == 200) {
        cntRefresh++;
        if(cntRefresh<MAX_TIME_REFRESH){
          initTimeout();
        }
      }
    }
}
//Funzioni per il refresh della sessione - End

//Gestione per singolo click su pulsante di submit - Begin
setTimeout(event_onload, 100);

function noSubmit(){
  return false;
}

function singleClick(){
  for (i=0; i<document.forms.length; i++)
  {
    var itemForm = document.forms[i];
    itemForm.onsubmit=noSubmit;
    //window.alert('itemForm.name: '+itemForm.name);
  }
}

function event_onload()
{
  if(document.forms){
    var i;
    for (i=0; i<document.forms.length; i++)
    {
      var itemForm = document.forms[i];
      itemForm.onsubmit=singleClick;
    }
  }
  else{
    setTimeout(event_onload, 100);
  }
}
//Gestione per singolo click su pulsante di submit - End

// Questa funzione apre un nuovo pop-up solo a condizione che il parametro "richiesta" sia valorizzato
function NewWindow(mypage, myname, w, h, scroll,richiestaModifica) {
  if(richiestaModifica != '') {
    var winl = (screen.width - w) / 2;
    var wint = (screen.height - h) / 2;
    winprops =    'height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable'
    win = window.open(mypage, myname, winprops)
    if (parseInt(navigator.appVersion) >= 4) {
      win.window.focus();
    }
  }
}

function NewWindowComune(mypage, myname, w, h, scroll,provincia,comune) {
  NewWindowComune(mypage, myname, w, h, scroll,provincia,comune,'');
}

function NewWindowComune(mypage, myname, w, h, scroll,provincia,comune,obiettivo) {
  var winl = (screen.width - w) / 2;
  var wint = (screen.height - h) / 2;
  if(provincia ==  '' && comune == '') {
    alert('Inserire una provincia o un comune!');
  }
  else if(!mappaOggetti(provincia) || !mappaOggetti(comune) || !mappaOggetti(obiettivo)) {
  }
  else {
    winprops =    'height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable';
    win = window.open(mypage+'?obiettivo='+obiettivo+'&provincia='+provincia+'&comune='+comune, myname, winprops);
    if (parseInt(navigator.appVersion) >= 4) {
      win.window.focus();
    }
  }
}

function NewWindowStato(mypage, myname, w, h, scroll,stato) {
  var winl = (screen.width - w) / 2;
  var wint = (screen.height - h) / 2;

  if(!mappaOggetti(stato)) {
  }
  else {
    winprops =    'height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable';
    win = window.open(mypage+'?stato='+stato, myname, winprops);
    if (parseInt(navigator.appVersion) >= 4) {
      win.window.focus();
    }
  }
}

function NewWindowStatoObj(mypage, myname, w, h, scroll,stato,obiettivo) {
  var winl = (screen.width - w) / 2;
  var wint = (screen.height - h) / 2;

  if(!mappaOggetti(stato)) {
  }
  else {
    winprops =    'height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable';
    win = window.open(mypage+'?stato='+stato+'&obiettivo='+obiettivo, myname, winprops);
    if (parseInt(navigator.appVersion) >= 4) {
      win.window.focus();
    }
  }
}

// Funzione di controllo per i caratteri non validi
function mappaOggetti(stringa) {

    var nonvalidi = '"<>$�|()^*:;0123456789';
    var trovatocarattere = false;

      if (stringa!=" " && stringa!="") {
        if(eValida(stringa, nonvalidi)) {
        }
        else {
          trovatocarattere = true;
        }
      }
      else {
      }
      if (trovatocarattere) {
        alert('I campi non possono contenere caratteri speciali');
        return false;
      }
      else {
        return true;
      }
}


//queste funzioni controllano lo stato di determinati campi della form
function eValida(stringa,nonammessi) {
  for (var i=0; i< stringa.length; i++) {
    if (nonammessi.indexOf(stringa.substring(i, i+1)) != -1) {
      return false;
    }
  }
  return true;
}


//Funzione per chiudere la finestra di pop-up e valorizzare i campi della finestra padre con i valori selezionati
//precedentemente dall'utente
function confermaComune() {
//alert('sono in confermaComune');
//alert('document.sceltaComune.istat.value ='+document.sceltaComune.istat.value);
if(document.sceltaComune.istat.value != null) {
 var radio;
 var obiettivo = document.sceltaComune.obiettivo.value;
 //alert('obiettivo ='+obiettivo);
 for(var i = 0; i<document.sceltaComune.istat.length || i < 1;i++) {
   radio = document.sceltaComune.istat[i];
   //alert('radio ='+radio);
   if(radio == null) {
     radio = document.sceltaComune.istat;
   }
   if(radio.checked == true) {
 	//alert('radio.checked == true');
 	
 	var provincia = null;
 	var comune = null;
 	var istatComune = null;
 	var cap = null;
 	var istatProvincia = null;
 	var codiceFiscaleComune = null;
 	var zonaAlt = null;
 	
 	if(document.sceltaComune.siglaProvincia[i] != null){
       provincia = document.sceltaComune.siglaProvincia[i].value;
       //alert('provincia ='+provincia);
 	}  
     
 	if(document.sceltaComune.comune[i] != null){
       comune = document.sceltaComune.comune[i].value;
       //alert('comune ='+comune);
 	}  
     
 	if(document.sceltaComune.istatComune[i] != null){
       istatComune = document.sceltaComune.istatComune[i].value;
       //alert('istatComune ='+istatComune);
 	}  
     
 	if(document.sceltaComune.cap[i] != null){
       cap = document.sceltaComune.cap[i].value;
       //alert('cap ='+cap);
 	}  
     
 	if(document.sceltaComune.istatProvincia[i] != null){
       istatProvincia = document.sceltaComune.istatProvincia[i].value;
       //alert('istatProvincia ='+istatProvincia);
 	}  
     
 	if(document.sceltaComune.codiceFiscaleComune[i] != null){
       codiceFiscaleComune = document.sceltaComune.codiceFiscaleComune[i].value;
       //alert('codiceFiscaleComune ='+codiceFiscaleComune);
 	}  
         	
 	if(document.sceltaComune.zonaAltimetrica[i] != null){
       zonaAlt = document.sceltaComune.zonaAltimetrica[i].value;
 	}  
     
     
     if(provincia == null) {
       provincia = document.sceltaComune.siglaProvincia.value;
       //alert('provincia ='+provincia);
     }
     if(comune == null) {
       comune = document.sceltaComune.comune.value;
       //alert('comune ='+comune);
     }
     if(istatComune == null) {
       istatComune = document.sceltaComune.istatComune.value;
       //alert('istatComune ='+istatComune);
     }
     if(cap == null) {
       cap = document.sceltaComune.cap.value;
       //alert('cap ='+cap);
     }
     if(istatProvincia == null) {
       istatProvincia = document.sceltaComune.istatProvincia.value;
       //alert('istatProvincia ='+istatProvincia);
     }
     //
     if(zonaAlt == null) {
       zonaAlt = document.sceltaComune.zonaAltimetrica.value;
     }
     if(codiceFiscaleComune == null) {
       codiceFiscaleComune = document.sceltaComune.codiceFiscaleComune.value;
     }
     // MODIFICA X NUOVA LAV CONTO TERZI
     if (window.opener.document.getElementById("sedeLegaleStr"))
     {
      //alert('comune vale: '+comune);
      //alert('provincia vale: '+provincia);
      var comuneOpener=window.opener.document.getElementById("sedeLegaleStr");
      comuneOpener.value=comune+" ("+provincia+")";         
     }
     
     // FINE MODIFICA
     //alert('prima di obiettivo ='+obiettivo);
	 if(obiettivo == null || obiettivo == '' || obiettivo=='insDittaUma'){
		  //alert('obiettivo ='+obiettivo);          
	
	   //alert('sono prima');
       // AGGIUNTA PER SUPERFICI E VARIAZIONE DITTA UMA
       if (window.opener.document.getElementById("descComune"))
       {
    	 //alert('window.opener.document.getElementById(descComune)');  
         var comuneOpener=window.opener.document.getElementById("descComune");           
         var provinciaOpener=window.opener.document.getElementById("sedelegProvincia");
         if (comuneOpener)
         {
           comuneOpener.value=comune;
           //alert('comuneOpener.value='+comune);
         }
         //alert('provinciaOpener');
         if (provinciaOpener)
         {
           provinciaOpener.value=provincia;
           //alert('provinciaOpener.value='+provincia);
         }
         //alert('close');
         window.close();
         return;
       }
       
       // FINE AGGIUNTA
      alert('setto campi su opener.. ');
      
      //alert('setto provincia ='+provincia);
      //opener.document.form1.siglaProvincia.value = provincia;
      //alert('opener.document.form1.siglaProvincia.value ='+opener.document.form1.siglaProvincia.value);
      
      //alert('setto comune ='+comune);
      opener.document.form1.descComune.value = comune;
      //alert('opener.document.form1.descComune.value ='+opener.document.form1.descComune.value);
      
      //alert('setto istatComune ='+istatComune);
      opener.document.form1.istatComune.value = istatComune;
      //alert('opener.document.form1.istatComune.value ='+opener.document.form1.istatComune);
      
      //alert('setto cap ='+cap);
      opener.document.form1.cap.value = cap;
      //alert('opener.document.form1.cap.value ='+opener.document.form1.cap);
      
      /* if(opener.document.form1.tipiZonaAltimetrica != null) {
     	  for(k=0;k<opener.document.form1.tipiZonaAltimetrica.options.length;k++){
     		  if(opener.document.form1.tipiZonaAltimetrica.options[k].value==zonaAlt.value){
     			  opener.document.form1.tipiZonaAltimetrica.selectedIndex = k;
     		  }
     	  }
       }*/
	    }
    /* else if(obiettivo=='nascita') {
     	opener.document.form1.nascitaComune.value = comune.value;
     	opener.document.form1.descNascitaComune.value = istatComune.value;
     }
     else if(obiettivo=='res') {
     	opener.document.form1.resCAP.value = cap.value;
     	opener.document.form1.descResComune.value = comune.value;
     	opener.document.form1.resComune.value = istatComune.value;
     	opener.document.form1.resProvincia.value = provincia.value;
     }
     else if(obiettivo == 'sedeleg') {
     	opener.document.form1.sedelegCAP.value = cap.value;
     	opener.document.form1.descComune.value = comune.value;
     	opener.document.form1.sedelegComune.value = istatComune.value;
     	opener.document.form1.sedelegProv.value = provincia.value;
     }
     else if (obiettivo == 'nascitaProvCom'){
     	opener.document.form1.nascitaProv.value = provincia.value;
     	opener.document.form1.descNascitaComune.value = comune.value;
     }
     else if(obiettivo == 'insAzienda') {
     	opener.document.form1.descNascitaComune.value = comune.value;
     	opener.document.form1.nascitaComune.value = istatComune.value;
     	opener.document.form1.codiceFiscaleComune.value = codiceFiscaleComune.value;
     	opener.document.form1.nascitaProv.value = provincia.value;
     }
     else if(obiettivo == 'insAziendaProvAndCom') {
     	opener.document.form1.resProvincia.value = provincia.value;
     	opener.document.form1.descResComune.value = comune.value;
     	opener.document.form1.resComune.value = istatComune.value;
     	opener.document.form1.resCAP.value = cap.value;
     }
     else if(obiettivo == 'insSede') {
     	opener.document.form1.sedelegProv.value = provincia.value;
     	opener.document.form1.sedelegComune.value = comune.value;
     	opener.document.form1.sedelegCAP.value = cap.value;
     }
     else
     {
     	if(obiettivo == 'lavContoTerzi') {
     		opener.document.form1.sedeLegaleStr.value = comune.value;
     		opener.document.form1.provinciaStr.value = provincia.value;
     	}
     	else {
     		opener.document.form1.descComune.value = comune.value;
     		opener.document.form1.provincia.value = provincia.value;
     	}
     }*/

	    window.close();
	    return;
   }
 }
 alert('Selezionare un comune!');
}
}

// Funzione per disabilitare il campo stato estero nel caso in cui siano valorizzati provincia,comune o cap
function disabilitaStatoEstero(provincia,comune,cap) {
  if(provincia != '' || comune!= '' || cap != '' ) {
    document.form1.statoEstero.disabled = true;
  }
  else {
    document.form1.statoEstero.disabled = false;
  }
}

// Funzione per disabilitare il campo stato estero oppure i campi provincia comune e cap in base al loro valore
function disabilitaCampo(provincia,comune,cap,statoEstero) {
  if(provincia.value != '' ||  comune.value != '' || cap.value != '') {
    statoEstero.disabled = true;
  }
  else if(statoEstero.value != '') {
    provincia.disabled = true;
    comune.disabled = true;
    cap.disabled = true;
  }
}



function visualError()
{
    oggettoDiv = document.getElementById("messageError");
    if ( (oggettoDiv != null) && (oggettoDiv.innerHTML != '') ){
            window.alert(oggettoDiv.innerHTML);
    }
}

// Utilizzato per la gestione dei pulsanti precedente/successivo negli elenchi di UMA
function goToLine(prev)
{
  document.paginazione.startRow.value=prev;
  document.paginazione.submit();
}


function doForm(hiddenName)
{
  //alert('sono in doform() 1');	
  var divElement=document.getElementById("hiddenElement");
  divElement.innerHTML="<input type='hidden' name='"+hiddenName+"' value=''>";
  //alert('sono in doform() 2');
  document.form1.submit();
}

function doFormPage(hiddenName, page)
{
  var divElement=document.getElementById("hiddenElement");
  divElement.innerHTML="<input type='hidden' name='"+hiddenName+"' value=''>";
  var action=document.form1.action;
  document.form1.action=page;
  document.form1.submit();
  document.form1.action=action;  
}


function pop(page,w,h,target)
{ 
  console.log('window.open in pop');	
  var winl = (screen.width - w) / 2;
  var wint = (screen.height - h) / 2;
  winprops =    'height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars=yes';
  win = window.open(page, target, winprops, "_blank");
  if (parseInt(navigator.appVersion) >= 4)
  {
    win.window.focus();
  }
}

function popR(page,w,h,target)
{
  var winl = (screen.width - w) / 2;
  var wint = (screen.height - h) / 2;
  winprops =    'height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars=yes, resizable=yes';
  win = window.open(page, target, winprops);
  if (parseInt(navigator.appVersion) >= 4)
  {
    win.window.focus();
  }
}

function testLength(controllo,maxLength,doTrunc)
{
    var msg="Lunghezza massima raggiunta\n(" + maxLength + " caratteri)";
    if (doTrunc=="false" && controllo.value.length>=maxLength)
    {
        alert(msg);
        return false;
    }
    if (doTrunc=="true" && controllo.value.length>maxLength)
    {
        msg=msg+"\n\nIl contenuto del campo � stato troncato.";
        controllo.value=controllo.value.substring(0,maxLength);
        alert(msg);
        return false;
    }
    else
        return true;
}

function dotCheck(input)
{
    return input.replace(".",",");
}

function commaCheck(input)
{
    return input.replace(",",".");
}

// Funzione per chiudere la finestra di pop-up e valorizzare i campi della finestra padre con i valori selezionati
// precedentemente dall'utente
function confermaStato() {
  var obiettivo=document.sceltaStato.obiettivo.value;
  if(document.sceltaStato.istat != null) {
    var radio;
    for(var i = 0;i<document.sceltaStato.istat.length || i<1 ;i++) {
      radio = document.sceltaStato.istat[i];
      if(radio==null) {
        radio = document.sceltaStato.istat;
      }
      if(radio.checked == true) {
        var sigla = document.sceltaStato.siglaStato[i];
        if(sigla==null) {
          sigla = document.sceltaStato.siglaStato;
        }
        if (obiettivo=='nascita'){
          opener.document.form1.nascitaStatoEstero.value = sigla.value;
        }
        else if(obiettivo == 'statoEsteroResidenza') {
          opener.document.form1.descStatoEsteroResidenza.value = sigla.value;
        }
        else if(obiettivo == 'statoEsteroSede') {
          opener.document.form1.sedelegEstero.value = sigla.value;
        }
        else {
          opener.document.form1.sedelegEstero.value = sigla.value;
          opener.document.form1.istatStatoEstero.value = radio.value;
        }
        window.close();
        return;
      }
    }
    alert('Selezionare uno stato!');
  }
}

  // Funzione per chiudere la finestra di pop-up e valorizzare i campi della finestra padre con i valori selezionati
  // precedentemente dall'utente
  function confermaMarca() {
    if(document.form1.idMarca != null) {
      var radio;
      var matrice;
      for(var i = 0; i<document.form1.idMarca.length || i < 1;i++) {
        radio = document.form1.idMarca[i];
        if(radio == null) {
          radio = document.form1.idMarca;
        }
        if(radio.checked == true) {
          var descrizioneMarca = document.form1.descrizione[i];
          matrice = document.form1.matrice[i];
          if(descrizioneMarca == null) {
            descrizioneMarca = document.form1.descrizione;
            matrice = document.form1.matrice;
          }

          opener.document.form1.descMarca.value = descrizioneMarca.value;
          opener.document.form1.matriceMarca.value = matrice.value;
          window.close();
          return;
        }
      }
      alert('Selezionare una marca!');
    }
  }
  
  function sendFormToPage(form, page)
  {
    var action=form.action;
    form.action=page;
    form.submit();
    form.action=action;
  }

function selezionaTutti(elementi,checked)
{
  if (elementi)
  {
    if (elementi.length)
    {
      var len=elementi.length;
      for(i=0;i<len;++i)
      {
        elementi[i].checked=checked;
      }
    }
    else
    {
      elementi.checked=checked;
    }
  }
}
  