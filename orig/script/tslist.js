var oRequest;
var loaded_count = 0;
var total_pic = 0;
var file_array = new Array();
var dir_array = new Array();
var img_array = new Array();
var file_path;
var list_state = 0;
var entry_count = 0;
var obj_tbl_root;
var obj_progress;
var obj_dir_tbl;
var ie_ver;
var timer_thumb = null;

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
	alert( msg );
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

function is_raw(filename) {
	if (filename.match(/\.((cr2)|(srw)|(rwl)|(rw2)|(raw)|(pef)|(nrw)|(nef)|(kdc)|(k25)|(dcr)|(srf)|(sr2)|(arw)|(orf))$/i)) 
		return true;
	else
		return false;
}

function is_picture(filename) {
	if (filename.match(/\.((jpeg)|(gif)|(bmp)|(jpg)|(gif)|(png)|(dng)|(r3d)|(pxn)|(3fr)|(ari))$/i)) 
		return true;
	else {
		if (is_raw(filename))
			return true;
		return false;
	}
}
function is_video(filename) {
	if (filename.match(/\.((avi)|(mpeg)|(mpg)|(mp4)|(h264)|(mov)|(3gp)|(wmv)|(m2ts))$/i)) 
		return true;
	else
		return false;
}
 
function get_file_list(path) {
	//alert("get_file_list:"  + path);
	//
	ie_ver = getInternetExplorerVersion();
	obj_progress = document.getElementById("progress");
	obj_tbl_root = document.getElementById("table_root");
	update_progress("Loading ." ,0);
    oRequest = createAjax();
//	oRequest.addEventListener("progress", onUpdateProgress, false);
//	oRequest.onprogress=onUpdateProgress;
    oRequest.onreadystatechange = ProcessResponse;
    oRequest.open("get", "/cgi-bin/tslist?PATH=" + encodeURIComponent(path) + "&keeprefresh=" + (new Date().getTime() / 1000), true);
//    oRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
//    var sParams = "";
//    sParams = addPostParam(sParams, "GetUploadedPercentage", "YES");
    oRequest.send(null);

}
function get_video_list(path) {
	//alert("get_file_list:"  + path);
	//
	ie_ver = getInternetExplorerVersion();
	obj_progress = document.getElementById("progress");
	obj_tbl_root = document.getElementById("table_root");
	update_progress("Loading ." ,0);
    oRequest = createAjax();
//	oRequest.addEventListener("progress", onUpdateProgress, false);
//	oRequest.onprogress=onUpdateProgress;
    oRequest.onreadystatechange = ProcessVideoResponse;
    oRequest.open("get", "/cgi-bin/tslist?PATH=" + encodeURIComponent(path) + "&keeprefresh=" + (new Date().getTime() / 1000), true);
//    oRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
//    var sParams = "";
//    sParams = addPostParam(sParams, "GetUploadedPercentage", "YES");
    oRequest.send(null);

}
function onUpdateProgress(e) { 
	if (e.lengthComputable) { 
		var percent_complete = e.loaded/e.total; 
		update_progress("Loading list ..."+ Math.round(percentComplete*100) +"% [ " + Math.round(e.loaded / 1000) + " KB ]",0 );
	} else { 
		// Length not known, to avoid division by zero 
		if (list_state == 3) {
			update_progress("Receving count " + entry_count,0);
			entry_count++;
		}
	} 
} 
function processExifResponse(http_request) {
	if(http_request.readyState == 4 && http_request.status == 200) {
		var str_resp = new String(http_request.responseText);
		var str_start, str_end;
		var str_file = parse_filename_from_exif(str_resp);

		loaded_count++;
		//update_progress("Loading Exif ....   " + loaded_count + "/" + total_pic,0);

		if (loaded_count == total_pic) {
			//hide_progress();
		}

		if (str_file == null) {
			//alert("processExifResponse: str fle = null");
			return 0;
		}
		set_pic_exif(str_file,str_resp);
	}
}

function get_file_exif(path) {
	var ofRequest = createAjax();
    ofRequest.onreadystatechange = function() {
			processExifResponse(ofRequest);
		}
    ofRequest.open("get", "/cgi-bin/tscmd?CMD=GET_EXIF&PIC=" + encodeURIComponent(path), true);
    ofRequest.send(null);
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
		new_td.colSpan="5";
		new_td.width = "100%"
		new_td.innerHTML = "<b> " + src_path + " </b>" + " -- " + fcount + " files";
		new_td.innerHTML += "&nbsp;&nbsp;<input type='button' class='button' onclick='javascript:location.reload(true)' value='Refresh'>";

		new_tr.id = sPath
		new_tr.appendChild(new_td);



		//alert("append dir header " + sPath);
		obj_tbl_root.appendChild(new_tr);
		
		return new_tr;

	} else {
		//alert("Can't find table_root:" + sPath);
		return null;
	}
}
function add_dir_entries(sPath,dir_entries,video_flag) {
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

			if (video_flag)
				new_a.href = "/cgi-bin/show_video.cgi?dir=" + encodeURIComponent(parent_path);
			else
				new_a.href = "/cgi-bin/show_pic.cgi?dir=" + encodeURIComponent(parent_path);
			new_a.appendChild(img_back);
			new_a.appendChild(text_parent);
			
			new_td.height = "30";
			new_td.width = "200";
			new_td.colSpan="5";
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

			if (video_flag)
				new_a.href = "/cgi-bin/show_video.cgi?dir=" +  encodeURIComponent(sPath + "/" + dir_entries[i]);
			else
				new_a.href = "/cgi-bin/show_pic.cgi?dir=" +  encodeURIComponent(sPath + "/" + dir_entries[i]);
			//new_a.setAttribute("style", "text-decoration:none;color:black");
			changeCSS(new_a, "dir_link"); 
			new_a.appendChild(img_dir);
			new_a.appendChild(new_font);
			
			new_td.height = "30";
			new_td.width = "200";
			new_td.colSpan="5";
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

		}
		add_hr(obj_tbl_root);

	} else {
		//alert("Can't find table_root:" + sPath);
	}
}
function create_pic_table(obj_parent) {
	var obj_tbl = document.createElement('table');
	var obj_tbody = document.createElement('tbody');

	obj_tbl.border="0";
	obj_tbl.width ="138";
	obj_tbl.cellSpacing="0";
	obj_tbl.cellPadding="0";
	obj_tbl.appendChild(obj_tbody);
	obj_parent.appendChild(obj_tbl);

	return obj_tbody;

}
function create_pic_filename(obj_pic_tbl,sName) {
	var short_name;
	var new_tr = document.createElement('tr');
	obj_pic_tbl.appendChild(new_tr);

	var new_td = document.createElement('td');
	new_td.align="center";
	new_td.width="138";
	new_td.height="30";
	new_tr.appendChild(new_td);

	if (sName.length > 12) {
		short_name = sName.substring(0,12);
		short_name = short_name + "...";
	} else {
		short_name = sName;
	}

	var obj_div = document.createElement('div');
	obj_div.setAttribute("style", "overflow:hidden;width:138;height:30;text-align:center");
	obj_div.innerHTML = short_name;
	new_td.appendChild(obj_div);
}

function create_pic_dlink(obj_pic_tbl,sPath,sName) {
	var new_tr = document.createElement('tr');
	obj_pic_tbl.appendChild(new_tr);

	var new_td = document.createElement('td');
	new_td.align="center";
	new_td.width="138";
	new_tr.appendChild(new_td);

	var obj_div = document.createElement('A');
	obj_div.href="/cgi-bin/wifi_download?fn=" + encodeURIComponent(sName) + "&fd=" + encodeURIComponent(sPath); 
	obj_div.target = "_blank";
	obj_div.innerHTML = "Download";
	new_td.appendChild(obj_div);


	var obj_br = document.createElement('br');
	new_td.appendChild(obj_br);

	var obj_nbsp= document.createTextNode("\u00a0");
	new_td.appendChild(obj_nbsp);
}
function update_exif() {
	var loop_length = file_array.length
	for (var i = 0 ; i < loop_length; i+=1) {
		get_file_exif(file_path + "/" + file_array[i]);
	}
}

function show_thumb_timeout(serial,callback) {
	var obj_img = img_array[serial];

	//alert("Img " + serial + " Timeout");
	timer_thumb = null;
	obj_img.onload = null;
	loaded_count++; 

	update_progress("Loading thumbnail....   " + loaded_count + "/" + total_pic,0);
	if (loaded_count >= total_pic) {
		update_progress("Loading thumbnail....   Finished",0);
		loaded_count = 0;
		update_exif();
		hide_progress();
	} else {
		callback(serial);
	}
}
function set_thumb_src(obj_img,sName) {
	obj_img.src = "/cgi-bin/thumbNail?fn=" + file_path + "/" + sName;
}
function show_thumb(serial,callback) {
	var obj_img = img_array[serial];

	if (callback) {
		if (timer_thumb != null) {
		//	alert("Timer thumb is not null");
				window.clearTimeout(timer_thumb);
				timer_thumb = null;
		}
		
		// 20 seconds timeout function if onload is failed. 
		timer_thumb = window.setTimeout(function() {
					show_thumb_timeout(serial, callback);
				}, 20000);
	}

	obj_img.onload = function() {
		loaded_count++; 
		update_progress("Loading thumbnail....   " + loaded_count + "/" + total_pic,0);
		if (loaded_count >= total_pic) {
			window.clearTimeout(timer_thumb);
			timer_thumb = null;

			update_progress("Loading thumbnail....   Finished",0);
			loaded_count = 0;
			update_exif();
			hide_progress();
		} else {
			//Display next thumb
			if (callback)  {
				window.clearTimeout(timer_thumb);
				timer_thumb = null;
				callback(serial);
			}
		}
	}

	set_thumb_src(obj_img,file_array[serial]);
}
function set_video_src(obj_img,sName) {
	obj_img.src = "/cgi-bin/thumbnail_video?fn=" + file_path + "/" + sName;
}
function show_video_thumb(serial,callback) {
	var obj_img = img_array[serial];
	obj_img.onload = function() {
		loaded_count++; 
		update_progress("Loading thumbnail....   " + loaded_count + "/" + total_pic,0);
		if (loaded_count == total_pic) {
			update_progress("Loading thumbnail....   Finished",0);
			loaded_count = 0;
			update_exif();
			hide_progress();
		} else {
			//Display next
			if (callback) 
				callback(serial);
		}

	}

	set_video_src(obj_img,file_array[serial]);
}

function create_pic(obj_pic_tbl,sPath,sName, last_flag, video_flag) {
	var obj_a,obj_span, obj_div;

	var img = new Image();
	img.alt = sName;
	img.id = "img" + sPath + "/" + sName;
	img.border ="0";
	if (last_flag == 1) {
		img.src = "/nothumb.jpg";
		loaded_count = 0;
		window.setTimeout(function() {
			if (video_flag)
				update_video();
			else
				update_pic();
			}, 200);

//		img.onload = function () {
//			//update_progress("Loading table ....   Finished",0);
//			loaded_count = 0;
//			if (video_flag)
//				update_video();
//			else
//				update_pic();
//		}
	}


	var new_tr = document.createElement('tr');
	obj_pic_tbl.appendChild(new_tr);

	var new_td = document.createElement('td');
	new_td.align="center";
	changeCSS(new_td,"album-back");
	new_td.width="138";
	new_td.height="100";
	new_tr.appendChild(new_td);


	obj_div = document.createElement('div');
	changeCSS(obj_div,"album-pic");
	obj_div.appendChild(img);

	obj_span = document.createElement('span');
	obj_span.id = sPath + "/" + sName;
	// Need exif here
	obj_span.innerHTML = sName + "<br>";

	obj_a = document.createElement('A');

	if (!video_flag && is_raw(sName)) {
		// Show thumbnail if picture is raw format.
		obj_a.href = "/cgi-bin/thumbNail?fn=" + file_path + "/" + sName;
	} else {
		var src_path = sPath.replace(/^\/www/,'');
		obj_a.href = src_path + "/" + sName;
	}

	changeCSS(obj_a,"info");
	obj_a.target="_blank";
	obj_a.appendChild(obj_span);
	obj_a.appendChild(obj_div);
	new_td.appendChild(obj_a);

	create_pic_filename(obj_pic_tbl,sName);
	create_pic_dlink(obj_pic_tbl,sPath,sName);

	return img;
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
	new_td.height="30";
	new_td.colSpan="5";
	new_td.width = "100%";
	new_td.innerHTML = "<hr />";
	new_tr.appendChild(new_td);
	tbl_obj.appendChild(new_tr);
}

function add_pic(sPath,sName, last_flag, video_flag) {
	var obj_dir_tr;
	var obj_pic_tbl;

	//alert("add_pic:" + sPath + ",pic=" + sName);

	//obj_dir_tbl = document.getElementById(sPath);
	//if (!obj_dir_tbl) { 
		//alert("add_pic :" + "Can't find ID " + sPath);
	//	return ;
	//} 

	// Create pic's td
	var row = get_pic_row(obj_dir_tbl,sPath);
	col = row.insertCell(-1);
	col.align = "center";
	changeCSS(col, "pic_container");

	// Create this pic's table
	obj_pic_tbl = create_pic_table(col, obj_dir_tbl);

    return create_pic(obj_pic_tbl,sPath,sName, last_flag, video_flag);

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
function parse_filename_from_exif(sResp) {
	var str_start, str_end;

	str_start = sResp.indexOf('file: ');
	if (str_start < 0 )
		return null;
	str_end = sResp.indexOf('<br>');
	if (str_end< 0 )
		return null;

	str_start += 'file: '.length;
	var filename= sResp.substring(str_start, str_end);
	//alert("parse_filename_from_exif:" + filename);
	return filename;

}
function set_pic_exif(str_path,str_exif) {
	var span= document.getElementById(str_path);
	var str_start, str_end;
	if (span == null) {
		//alert("Can't find id " + str_path);
		return; 
	}

	str_start = str_exif.indexOf('<br>');
	if (str_start < 0 )
		return null;

	str_end = str_exif.indexOf('Success');
	if (str_start < 0 )
		return null;
	span.innerHTML = span.innerHTML + str_exif.substring(str_start + 5, str_end-1);
}


function update_progress(str_msg, append) {
	if (append) 
		obj_progress.innerHTML += str_msg;
	else
		obj_progress.innerHTML = str_msg;

	obj_progress.style.display = "block";
}
function hide_progress() {
	//alert("hide_process");
	obj_progress.innerHTML = "";
	obj_progress.style.display = "none";
}
function update_pic() {
	var loop_length = file_array.length;
	// for slow IE 6,7
	if (ie_ver > -1  && ie_ver < 8.0) {
		show_thumb(0,show_thumb_callback);
	} else {
		show_thumb(0,show_thumb_callback);
	//	for (i = 0; i < loop_length; i+=1) {
	//		show_thumb(i,null);
	//	}
	}
}
function update_video() {
	var loop_length = file_array.length;
	// for slow IE 6,7
	if (ie_ver > -1  && ie_ver < 8.0) {
			show_video_thumb(0,show_video_callback);
	} else {
		for (i = 0; i < loop_length; i+=1) {
			show_video_thumb(i,null);
		}
	}
}

function show_video_callback(serial) {
	var loop_length;
	var next = serial + 1;
	loop_length = file_array.length;
	if (next < loop_length) {
		//Delay 500ms for IE6,7 to avoid locking.
		window.setTimeout(function() {
				show_video_thumb(next,show_video_callback);
				}, 80);
	}
}

function show_thumb_callback(serial) {
	var loop_length;
	var next = serial + 1;
	loop_length = file_array.length;
	if (next < loop_length) {
		//Delay 500ms for IE6,7 to avoid locking.
		window.setTimeout(function() {
				show_thumb(next,show_thumb_callback);
				}, 80);
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
					if (is_picture(file_info[1])){
						file_array.push (file_info[1]);
					}
				}
			}
			total_pic = file_array.length;
			//update_progress("Loading .... ",0);

			obj_dir_tbl = add_dir_header(file_path,file_array.length);
			add_dir_entries(file_path,dir_array.sort(),0);

			// Create first tr for pictures
			var new_tr = document.createElement('tr');
			if (obj_tbl_root) { 
				obj_tbl_root.appendChild(new_tr);
			}

			if (file_array.length == 0)
				hide_progress();

			loop_length = file_array.length;
			for (var i = 0 ; i < loop_length; i+=1) {
				//update_progress("Loading ....   " + (i+1) + "/" + file_array.length);
				if (i+1 == loop_length)
					obj_img = add_pic(file_path, file_array[i],1);
				else
					obj_img = add_pic(file_path, file_array[i],0);

				img_array[i] = obj_img;
			} 

		} else {
			//alert("No any files");
			obj_dir_tbl = add_dir_header(file_path,file_array.length);
			add_dir_entries(file_path,dir_array,0);
			hide_progress();
		}
	}
}
function ProcessVideoResponse() {
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
					if (is_video(file_info[1])){
						file_array.push (file_info[1]);
					}
				}
			}
			total_pic = file_array.length;
			//update_progress("Loading .... ",0);

			obj_dir_tbl = add_dir_header(file_path,file_array.length);
			add_dir_entries(file_path,dir_array.sort(),1);

			// Create first tr for pictures
			var new_tr = document.createElement('tr');
			if (obj_tbl_root) { 
				obj_tbl_root.appendChild(new_tr);
			}

			if (file_array.length == 0)
				hide_progress();

			loop_length = file_array.length;
			for (var i = 0 ; i < loop_length; i+=1) {
				//update_progress("Loading ....   " + (i+1) + "/" + file_array.length);
				if (i+1 == loop_length)
					obj_img = add_pic(file_path, file_array[i],1,1);
				else
					obj_img = add_pic(file_path, file_array[i],0,1);

				img_array[i] = obj_img;
			} 

		} else {
			//alert("No any files");
			obj_dir_tbl = add_dir_header(file_path,file_array.length);
			add_dir_entries(file_path,dir_array,1);
			hide_progress();
		}
	}
}


