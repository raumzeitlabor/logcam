function Back(){
   history.go(-1);
}
function Delete(Delete_row,AP_SRC_NUM){
     document.getElementById("AP_KINDS").deleteRow(Delete_row-1);
     return (AP_SRC_NUM-1);
}
function Insert(AP_SRC_NUM){
    var oTable = document.getElementById("AP_KINDS");
    var oBody = oTable.tBodies[0];
	var AP_NEW_NUM = (oBody.rows.length-1)/2;
	var NEW_ROW = oBody.rows.length
	var oTr = oBody.insertRow(NEW_ROW);	//插入一行
	var aText = new Array();
	var aInput = new Array();
	var aBold = new Array();
	var aItalic = new Array();
	var oTd;
	//var aNewlink = new Array();;
	
	AP_NEW_NUM += 1;
	if (AP_NEW_NUM > 20) {
		alert("Can't over 20 APs.");
		return -1;
	}
	aText[0] = document.createTextNode(AP_NEW_NUM);    	
	aText[1] = document.createTextNode("SSID:");    
	aInput[0] = document.createElement("input"); 

	aInput[0].type="text";
	aInput[0].name="SSID"+AP_NEW_NUM;
	aInput[0].value="";	
	aInput[0].maxLength="32";	
	
	// Num
	aBold[0] = document.createElement("b"); 

	oTd = oTr.insertCell(0);
	oTd.appendChild(aBold[0]);
	aBold[0].appendChild(aText[0]);
	//oTd.appendChild(aText[0]);
	oTd.rowSpan = "2";	
	oTd.align = "center";
	oTd.width = "30";

	// SSID
	aBold[1] = document.createElement("b"); 
	aItalic[0] = document.createElement("I"); 
	oTd = oTr.insertCell(1);
	oTd.appendChild(aBold[1]);
	oTd.align = "right";
	aBold[1].appendChild(aItalic[0]);
	aItalic[0].appendChild(aText[1]);
	//oTd.appendChild(aText[1]);

	// Input
	oTd = oTr.insertCell(2);
	oTd.appendChild(aInput[0]);
	
	oTd = oTr.insertCell(3);
	oTd.rowSpan = "2";
	oTd.innerHTML = "<a href='#'>delete</a>";
	oTd.firstChild.onclick = myDelete;
	
	aText[2] = document.createTextNode("KEY : ");	
	aInput[1] = document.createElement("input"); 
	aInput[1].type="text";
	aInput[1].name="KEY"+AP_NEW_NUM;
	aInput[1].maxLength="64";
	aInput[1].value="";	

	//Second row
	oTr = oBody.insertRow(NEW_ROW+1);	//插入一行
	// Key
	aBold[2] = document.createElement("b"); 
	aItalic[1] = document.createElement("I"); 
	oTd = oTr.insertCell(0);
	oTd.align = "right";
	oTd.appendChild(aBold[2]);
	aBold[2].appendChild(aItalic[1]);
	aItalic[1].appendChild(aText[2]);
	//oTd.appendChild(aText[2]);

	// Input
	oTd = oTr.insertCell(1);
	oTd.appendChild(aInput[1]);
}
function validate_IPAddress_3rd(ipaddr) 
{
	ipaddr = ipaddr.replace( /\s/g, ""); 
	var re = /^\d{1,3}$/; //regex. check for digits and in

	if (re.test(ipaddr)) {
		if (parseInt(parseFloat(ipaddr)) > 255) {
				alert("The IP address range is illegal ");
				return false;
		}
		return true;
	} else {
		alert("The IP address contains illegal character");
		return false;
	}
}

function validate_IPAddress_4th(ipaddr) 
{
	ipaddr = ipaddr.replace( /\s/g, "") //remove spaces for checking
	var re = /^\d{1,3}$/; //regex. check for digits and in

	if (re.test(ipaddr)) {
		//if the fourth unit/quadrant of the IP is zero
		if (parseInt(parseFloat(ipaddr)) == 0) {
			alert("The IP address range is illegal ");
			return false;
		}

		//if any part is greater than 255
		if (parseInt(parseFloat(ipaddr)) >= 255){
			alert("The IP address range is illegal ");
			return false;
		}

		//if any part is greater than 11 and less than 50
		if (parseInt(parseFloat(ipaddr)) >= 11 && parseInt(parseFloat(ipaddr)) <= 50) {
			alert("The last digit of IP address can't use the range 11~50");
			return false;
		}

		return true;
	} else {
		alert("The IP address contains illegal character");
		return false;
	}
}

function get_utf8_length(string) {
	var utf8length = 0;
	for (var n = 0; n < string.length; n++) {
		var c = string.charCodeAt(n);
		if (c < 128) {
			utf8length++;
		}
		else if((c > 127) && (c < 2048)) {
			utf8length = utf8length+2;
		}
		else {
			utf8length = utf8length+3;
		}
	}
	return utf8length;
}
