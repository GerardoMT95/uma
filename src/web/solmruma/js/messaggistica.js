	function messageLoop() {
		__container=document.getElementById("id_div_system_message");
		__scrollText=document.getElementById("id_inner_div_system_message");
		if (__container!=null) {
			var w=__container.clientWidth;
			var left=parseInt(__scrollText.style.left);
			left=left-2;
			if (left<-__scrollText.clientWidth) {
				left=w-5;
			}
	
			__scrollText.style.left=left+"px";
			setTimeout(messageLoop,35);
		}
	}

	function systemMessages(__messageText, numMessage) {
		var divPrecedente=document.getElementById('titoloEmenu');
		
		if (divPrecedente) {
			
			if (__messageText || numMessage) {
				
				var __container=document.createElement("div");
				__container.style.background='#d3d3d3';
				var marquee=document.createElement("marquee");
				marquee.id="marquee_messaggi_testata";
				marquee.style.color='#bf5229';
				marquee.style.width='95%';
				marquee.style.fontWeight="bold";
				marquee.scrollAmount='3';
				marquee.scrollDelay='1';
				marquee.innerHTML=__messageText;
				marquee.onmouseover=ferma;
				marquee.onmouseout=avvia;				

				__container.appendChild(marquee);	
				insertAfter(divPrecedente, __container);			
			
				if (numMessage != '') {
					__imgContainer = document.createElement("a");
					__imgContainer.href="/app.name/layout/messaggi_utente.htm";
					__imgContainer.alt=numMessage;
					__imgContainer.title=numMessage;
					__imgContainer.style.cssFloat="right";
	
					__img=document.createElement("img");
					__img.src="/assets/application/agricoltura/images/msg.png";
					__img.style.height="16px";
					__img.style.width ="16px";
					__img.alt=numMessage;
					
					__imgContainer.appendChild(__img);	
					__imgContainer.style.position="relative";
					insertAfter(divPrecedente, __imgContainer);
				}
			}	
		}	
	}
	
	// This function inserts newNode after referenceNode
	function insertAfter(referenceNode, newNode) {
	    referenceNode.parentNode.insertBefore( newNode, referenceNode.nextSibling );
	}
	function ferma() {
		if (document.getElementById("marquee_messaggi_testata")!=null){
			if(navigator.userAgent.toLowerCase().indexOf('firefox') > -1) { // Firefox
				document.getElementById("marquee_messaggi_testata").setAttribute('scrollamount', 0, 0);
			}
			else{ // IE e CHROME
				document.getElementById("marquee_messaggi_testata").stop();
			}
		}
	}
	function avvia() {
		if (document.getElementById("marquee_messaggi_testata")!=null){
			if(navigator.userAgent.toLowerCase().indexOf('firefox') > -1) { // Firefox
				document.getElementById("marquee_messaggi_testata").setAttribute('scrollamount', 6, 0);
			}
			else{ // IE e CHROME
				document.getElementById("marquee_messaggi_testata").start();
			}
		}
	}	
