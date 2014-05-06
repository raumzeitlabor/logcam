var oRequest;
var loaded_count = 0;
var total_pic = 0;
var file_array = new Array();
var dir_array = new Array();
var info_array = new Array();
var file_path;
var list_state = 0;
var entry_count = 0;
var obj_tbl_root;
var obj_progress;
var obj_dir_tbl;
var ie_ver;
var entry_index = 0;
var name_width="350";
var last_width="140";
var size_width="60";
var row_height="30";


function getInternetExplorerVersion()
	// Returns the version of Windows Internet Explorer or a -1
	// (indicating the use of another browser).
{
	var rv = -1; // Return value assumes failure.
	if (navigator.appName == 'Microsoft Internet Explorer')
	{
		var ua = navigator.userAgent;
		var re  = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
		if (re.exec(ua) != null)
			rv = parseFloat( RegExp.$1 );
	}
	return rv;
}
function checkIEVersion()
{
	var msg = "You're not using Windows Internet Explorer.";
	var ver = getInternetExplorerVersion();
	if ( ver> -1 )
	{
		if ( ver>= 9.0 )
			msg = "You're using Windows Internet Explorer 9.";
		else if ( ver>= 8.0 )
			msg = "You're using Windows Internet Explorer 8.";
		else if ( ver == 7.0 )
			msg = "You're using Windows Internet Explorer 7.";
		else if ( ver == 6.0 )
			msg = "You're using Windows Internet Explorer 6.";
		else
			msg = "You should upgrade your copy of Windows Internet Explorer";
	}
	//alert( msg );
}
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

function changeCSS(obj,s_classname)
{
	obj.setAttribute("class", s_classname);
	obj.setAttribute("className", s_classname);  //IE
	obj.className = s_classname;
	return;
}
 

 
function get_file_list(path) {
	//alert("get_file_list:"  + path);
	file_path = path;
	ie_ver = getInternetExplorerVersion();
	obj_progress = document.getElementById("progress");
	obj_tbl_root = document.getElementById("table_root");
	//update_progress("Loading ." ,0);
    oRequest = createAjax();
    oRequest.onreadystatechange = ProcessResponse;
    oRequest.open("get", "/cgi-bin/tslist?PATH=" + encodeURIComponent(path) + "&keeprefresh=" + (new Date().getTime() / 1000), true);

    oRequest.send(null);

}
function get_file_info(index) {
	path = file_path + "/" + file_array[index];
    oRequest = createAjax();
    oRequest.onreadystatechange = function() { 
		ProcessInfoResponse(index);
	}
	info_array[index] = oRequest;
    oRequest.open("get", "/cgi-bin/tscmd?CMD=GET_FILE_INFO&FILE=" + encodeURIComponent(path), true);
    oRequest.send(null);
}

 

 
function add_dir_header(sPath,fcount) {
	var obj_tbl_dir;
	obj_tbl_dir = document.getElementById(sPath);
	if (obj_tbl_dir) {
		//alert("dir header has existed. " + sPath);
		return obj_tbl_dir;
	}

	if (obj_tbl_root) { 
		var row,col;
		var new_tr = document.createElement('tr');
		var new_td = document.createElement('td');
		var src_path = sPath.replace(/^\/www\/sd/,'');

		// Title 
		changeCSS(new_td,"subt");
		new_td.colSpan="3";
		new_td.width = "100%"
		new_td.innerHTML = "<b> " + src_path + " </b>" + " -- " + fcount + " files";

		new_tr.id = sPath
		new_tr.appendChild(new_td);
		//alert("append dir header " + sPath);
		obj_tbl_root.appendChild(new_tr);

		// Header field
		new_tr = document.createElement('tr');
		new_td = document.createElement('td');
		new_td.innerHTML = "<font size='3'>Name</font>";
		new_td.height = row_height;
		new_td.width = name_width;
		new_tr.appendChild(new_td);

		new_td = document.createElement('td');
		new_td.innerHTML = "<font size='3'>Last modified</font>";
		new_td.height = row_height;
		new_td.width = last_width;
		new_tr.appendChild(new_td);

		new_td = document.createElement('td');
		new_td.innerHTML = "<font size='3'>Size</font>";
		new_td.height = row_height;
		new_td.width = size_width;
		new_tr.appendChild(new_td);

		obj_tbl_root.appendChild(new_tr);
		
		return new_tr;

	} else {
		//alert("Can't find table_root:" + sPath);
		return null;
	}
}
function add_dir_entries(sPath,dir_entries) {
	if (obj_tbl_root) { 
		var row,col;

		//Parent link
		if (sPath != "/www/sd") {
			var parent_path = sPath.substring(0, sPath.lastIndexOf('/'));
			var img_back = document.createElement('img');
			var text_parent = document.createTextNode("Parent Directory");

			//alert("Add parent link:" + sPath);

			new_tr = document.createElement('tr');
			new_td = document.createElement('td');
			new_a = document.createElement('A');
			
			img_back.src = "/back.gif";
			img_back.border = "0";

			new_a.href = "/cgi-bin/file_list.pl?dir=" + encodeURIComponent(parent_path);
			new_a.appendChild(img_back);
			new_a.appendChild(text_parent);
			
			new_td.height = row_height;
			new_td.width = name_width;
			new_td.colSpan="3";
			new_td.appendChild(new_a);
			new_tr.appendChild(new_td);

			obj_tbl_root.appendChild(new_tr);
		}

		var loop_length = dir_entries.length;
		//alert("Add dir entries = " + dir_entries.length);
		for (var i = 0 ; i < loop_length; i+=1) {
			new_tr = document.createElement('tr');
			new_td = document.createElement('td');
			new_a = document.createElement('A');
			var img_dir = document.createElement('img');
			var new_font = document.createElement('font');
			
			new_font.size = "2";
			new_font.innerHTML = dir_entries[i];

			img_dir.src = "/dir.gif";
			img_dir.border = "0";

			new_a.href = "/cgi-bin/file_list.pl?dir=" + encodeURIComponent(sPath + "/" + dir_entries[i]);
			//new_a.setAttribute("style", "text-decoration:none;color:black");
			changeCSS(new_a, "dir_link"); 
			new_a.appendChild(img_dir);
			new_a.appendChild(new_font);
			
			new_td.height = row_height;
			new_td.width = name_width;
			new_td.colSpan="3";
			new_td.appendChild(new_a);
			new_tr.appendChild(new_td);

			if (i % 2 == 0) {
				new_tr.setAttribute("BGColor", "#E1E1E1");
				new_tr.style.backgroundColor= '#E1E1E1';
			} else {
				new_tr.setAttribute("BGColor", "#FFFFFF");
				new_tr.style.backgroundColor= '#FFFFFF';
			}
			//alert("append dir " + dir_entries[i]);
			obj_tbl_root.appendChild(new_tr);
			entry_index = i;

		}
		//add_hr(obj_tbl_root);

	} else {
		//alert("Can't find table_root:" + sPath);
	}
}
function update_exif() {
	var loop_length = file_array.length
	for (var i = 0 ; i < loop_length; i+=1) {
		get_file_exif(file_path + "/" + file_array[i]);
	}
}


function get_time_id(sPath, sName){
	return "time_" + sPath + "/" + sName;
}

function get_size_id(sPath, sName){
	return "size_" + sPath + "/" + sName;
}

function create_file_row(sPath,sName) {
	var new_tr = document.createElement('tr');

	if (entry_index % 2 == 0) {
		new_tr.setAttribute("BGColor", "#E1E1E1");
		new_tr.style.backgroundColor= '#E1E1E1';
	} else {
		new_tr.setAttribute("BGColor", "#FFFFFF");
		new_tr.style.backgroundColor= '#FFFFFF';
	}

	var new_td = document.createElement('td');
	new_td.height=row_height;
	new_td.width=name_width;
	new_tr.appendChild(new_td);

	obj_a = document.createElement('A');
	obj_a.href = "/cgi-bin/wifi_download?fn=" +  encodeURIComponent(sName) + "&fd=" + encodeURIComponent(sPath);
	changeCSS(obj_a, "dir_link"); 
	new_td.appendChild(obj_a);


	obj_img = document.createElement('img');
	obj_img.src = "/text.gif";
	obj_img.border = "0";
	obj_a.appendChild(obj_img);

	obj_font = document.createElement('font');
	obj_font.size = "2";
	obj_font.innerHTML = sName;
	obj_a.appendChild(obj_font);

	//last modified time
	new_td = document.createElement('td');
	new_td.height=row_height;
	new_td.width=last_width;
	obj_font = document.createElement('font');
	obj_font.size = "2";
	obj_font.id = get_time_id(sPath, sName);
	new_td.appendChild(obj_font);
	new_tr.appendChild(new_td);

	//Size
	new_td = document.createElement('td');
	new_td.height=row_height;
	new_td.width=size_width;
	new_td.align ="right";
	obj_font = document.createElement('font');
	obj_font.size = "2";
	obj_font.id = get_size_id(sPath, sName);
	new_td.appendChild(obj_font);
	new_tr.appendChild(new_td);

	return new_tr;
}
function my_insert_last_row(tbl_obj) {
	var new_tr = document.createElement('tr');
	tbl_obj.appendChild(new_tr);
	return new_tr;
}
function get_pic_row(tbl_obj, sPath) {
	var rows;

	row = obj_tbl_root.rows[obj_tbl_root.rows.length -1];
	if (row.cells.length >= 5) {
		row = my_insert_last_row(obj_tbl_root);
	} 
	return row;
}
function add_hr(tbl_obj) {
	var new_tr = document.createElement('tr');
	var new_td = document.createElement('td');
	new_td.height=row_height;
	new_td.colSpan="3";
	new_td.width = "100%";
	new_td.innerHTML = "<hr />";
	new_tr.appendChild(new_td);
	tbl_obj.appendChild(new_tr);
}

function add_file(sPath,sName) {
	var obj_row;

    obj_row = create_file_row(sPath,sName);
	obj_tbl_root.appendChild(obj_row);

}
function parse_file_list(sResp) {
	var str_start, str_end;
	str_start = sResp.indexOf('FileName0');
	if (str_start < 0 )
		return null;

	str_end = sResp.indexOf('&FileCount=');
	if (str_end < 0 )
		return null;

	sResp = sResp.substring(str_start, str_end);

	var array = sResp.split('&');
	return array
}
function parse_file_count(sResp) {
	str_start = sResp.indexOf('&FileCount=');
	if (str_start < 0 )
		return null;
	var count = sResp.substring(str_start+'&FileCount='.length, sResp.length);
	//alert("parse_file_count:[" + count + "]");
	return parseInt(count);
}



function update_progress(str_msg, append) {
//	if (append) 
//		obj_progress.innerHTML += str_msg;
//	else
//		obj_progress.innerHTML = str_msg;
//
//	obj_progress.style.display = "block";
}
function hide_progress() {
	//alert("hide_process");
///	obj_progress.innerHTML = "";
///	obj_progress.style.display = "none";
}
function update_file_size(index, str_resp) {
	/* Get path string */
	str_start =  str_resp.indexOf('File size: ');
	if (str_start < 0) {
		//alert("Can't find filesize " + responseText);
		return;
	}
	str_start += 'File size: '.length;

	str_end = str_resp.indexOf(' byte',str_start);
	if (str_end < 0) {
		//alert("Can't find bytes" + responseText);
		return;
	}

	file_size = parseInt(str_resp.substring(str_start,str_end));
	//alert("index " + index + " size " + file_size);

	sPath = file_path;
	sName = file_array[index];

	str_size = get_file_size_str(file_size);
	obj_size = document.getElementById(get_size_id(sPath, sName));
	if (obj_size) {
		obj_size.innerHTML = str_size;
	} else {
		//alert("Can't find size id=" + get_size_id(sPath, sName));
	}
}
function update_file_time(index, str_resp) {
	/* Get path string */
	str_start =  str_resp.indexOf('Last file modification: ');
	if (str_start < 0) {
		//alert("Can't find time" + str_resp);
		return;
	}
	str_start += 'Last file modification: '.length;

	str_end = str_resp.indexOf('Success:',str_start);
	if (str_end < 0) {
		//alert("Can't find Success:" + str_resp);
		return;
	}
	str_end = str_end -1;

	str_time = str_resp.substring(str_start,str_end);

	sPath = file_path;
	sName = file_array[index];

	obj_size = document.getElementById(get_time_id(sPath, sName));
	if (obj_size) {
		obj_size.innerHTML = str_time;
	} else {
		//alert("Can't find size id=" + get_time_id(sPath, sName));
	}
}


function get_file_size_str(size) 
{
	var ret;

	if (size > 1099511627776)  {
		ret = size / 1099511627776;
		return ret.toFixed(2) + "TB";
	} else if (size > 1073741824)  {
		ret = size / 1073741824;
		return ret.toFixed(2) + "GB";
	} else if (size > 1048576) {
		ret = size / 1048576
		return ret.toFixed(2) + "MB";
	} else if (size > 1024) {
		ret = size / 1024
		return ret.toFixed(2) + "KB";
	} else {
		return size + " byte" + (size == 1 ? "" : "s");
	}
}


function ProcessInfoResponse(index) 
{
	var fileArray;
	var file_count;
	var loop_length;

	oReq = info_array[index];
	if (oReq.readyState == 1) {
		list_state  = 1;
	}
	if (oReq.readyState == 2) {
		list_state  = 2;
	}
	if (oReq.readyState == 3) {
		list_state  = 3;
		update_progress(".", 1);
	}

	if(oReq.readyState == 4) {
		var str_start, str_end;
		var str_resp;
		var obj_table = null;
		var obj_img;

		list_state  = 4;
		update_progress(".", 1);
		//alert("reponse=" + oReq.responseText);
		str_resp = oReq.responseText;

		update_file_size(index, str_resp);
		update_file_time(index, str_resp);
	}
}


function ProcessResponse() {
	var fileArray;
	var file_count;
	var loop_length;

	if (oRequest.readyState == 1) {
		list_state  = 1;
	}
	if (oRequest.readyState == 2) {
		list_state  = 2;
	}
	if (oRequest.readyState == 3) {
		list_state  = 3;
		update_progress(".", 1);
	}

	if(oRequest.readyState == 4) {
		var str_start, str_end;
		var str_resp;
		var obj_table = null;
		var obj_img;

		list_state  = 4;
		update_progress(".", 1);
		//alert("reponse=" + oRequest.responseText);
		str_resp = oRequest.responseText;

		/* Get path string */
		str_start =  str_resp.indexOf('TS list1 List Files = ');
		str_start += 'TS list1 List Files = '.length + 1;

		str_end = str_resp.indexOf('FileName');
		if (str_end == -1) 
			str_end = str_resp.indexOf('FileCount=0');
		if (str_end == -1) 
			return;
			
		str_end -= 1;
		file_path = str_resp.substring(str_start,str_end);

		fileArray = parse_file_list(oRequest.responseText);

		if (fileArray != null) {
			file_count = parse_file_count(oRequest.responseText);

			loop_length = fileArray.length;
			for (var i = 0 ; i < loop_length; i+=2) {
				var myfile = fileArray[i]
				var mytype = fileArray[i+1];
				var file_info = new Array();
				var file_type = new Array();
				var rest_directory = new Array();
				
				myfile = myfile.replace(/FileName/g, '');
				mytype = mytype.replace(/FileType/g, '');
				file_info = myfile.split('=');
				file_type = mytype.split('=');

				if (file_type[1] == "Directory") {
					dir_array.push (file_info[1]);
				} else {
					file_array.push (file_info[1]);
				}
			}
			total_pic = file_array.length;
			//update_progress("Loading .... ",0);

			obj_dir_tbl = add_dir_header(file_path,file_array.length);
			add_dir_entries(file_path,dir_array.sort());

			if (file_array.length == 0) {
				hide_progress();
			}

			loop_length = file_array.length;
			for (var i = 0 ; i < loop_length; i+=1) {
				//update_progress("Loading ....   " + (i+1) + "/" + file_array.length);
				entry_index++;
				add_file(file_path, file_array[i]);

				get_file_info(i);
			} 

		} else {
			//alert("No any files");
			obj_dir_tbl = add_dir_header(file_path,file_array.length);
			add_dir_entries(file_path,dir_array,0);
			hide_progress();
		}
	}
}



