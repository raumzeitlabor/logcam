var oRequest;
var readedPercent = 1;
 
function createAjax() {
	var xmlhttp;
	if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
		xmlhttp=new XMLHttpRequest();
		return xmlhttp;
	} else {// code for IE6, IE5
		var arrSignatures = ["MSXML2.XMLHTTP.5.0", "MSXML2.XMLHTTP.4.0",
			"MSXML2.XMLHTTP.3.0", "MSXML2.XMLHTTP",
			"Microsoft.XMLHTTP"];

		for (var i=0; i < arrSignatures.length; i++) {
			try {
				xmlhttp = new ActiveXObject(arrSignatures[i]);
				return xmlhttp;
			} catch (oError) {
				//ignore
			}
		}
		throw new Error("MSXML is not installed on your system.");               
    }
}

 

 
function getProgressInfo() {
    oRequest = createAjax();
    oRequest.onreadystatechange = ProcessResponse;
    oRequest.open("get", "/cgi-bin/tscmd?CMD=GET_IU_STATUS", true);
//    oRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
//    var sParams = "";
//    sParams = addPostParam(sParams, "GetUploadedPercentage", "YES");
    oRequest.send(null);
}
 
function update_percent(sFile,uPercent) {
	var pic_obj;
	pic_obj = document.getElementById(sFile + "/ProgressBar");
	if (pic_obj) { 
//		if(uPercent== "100") {
//			document.getElementById(sFile+"/ProgressText").innerHTML = 
//				uPercent + "% uploaded";
//		} else {
//			document.getElementById(sFile+"/ProgressText").innerHTML = 
//				uPercent + "% uploaded...";
//		}

		document.getElementById(sFile+"/ProgressText").innerHTML = 
				uPercent + "%";
		document.getElementById(sFile+"/ProgressBar").style.width = 
			uPercent + "%";

		//alert(sFile + " percent:" + uPercent);
	} else {
		//alert("Can't find " + sFile);
	}
}

function parseList(sResp) {
	if (sResp.indexOf('file:') < 0 )
		return null;

	var final_oft = sResp.indexOf("Success:");
	sResp = sResp.substring(0,final_oft);

	var array = sResp.split('file:');
	array.shift();
	return array
}
function ProcessResponse() {
	var fileArray
	if(oRequest.readyState == 4) {
		//alert("reponse=" + oRequest.responseText);
		fileArray = parseList(oRequest.responseText);
		if (fileArray != null) {
			//      readedPercent = parseInt(oRequest.responseText);
			//alert("array Length = " +  fileArray.length);
			for (var i = 0 ; i < fileArray.length; i++){
				//alert(i  + fileArray[i]);
				var myfile	= fileArray[i]
					var per_start = myfile.indexOf("[");
				var per_end = myfile.indexOf("]");
				var percent = parseInt(myfile.substring(per_start+1,per_end));
				update_percent(myfile.substring(0,per_start),percent);
			} 
		}
	}
}

