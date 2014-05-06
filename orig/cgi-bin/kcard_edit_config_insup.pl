#!/usr/bin/perl
my $HWDEV="mlan0";
#my $iwlist_scan="iwlist $HWDEV scan > /tmp/iwlist_scan.txt"; 
#my $WPA2_Key_backup="cp /etc/wsd.conf > /etc/wsd_backup.conf";
my $WiFi_channel;
my $Host_Switch_LEN=0;
#`$WPA2_Key_backup`;
sub wireless_scan{
    if(`$iwlist_scan`){
	}	
    open(my $WIRELESS_FILE, "<", "/tmp/iwlist_scan.txt") or die("Could not open iwlist_scan.txt");
  
    my (@WLAN_SSID);	
	$WLAN_SSID[0][0]="None";
	$WLAN_SSID[0][1]="Off";
	
	my $i=1,$j=0;
	
    while( my $line = <$WIRELESS_FILE> ){
        chomp($line);
        if($line=~/^.*ESSID:"(.*)\"/){		   		  
		   $WLAN_SSID[$i][0]=$1;		   		   
        }
        if($line=~/^.*Encryption key:(.*)/){
		   $WLAN_SSID[$i][1]=$1;		   
		   $i++;		  
		}
   }
     close(WIRELESS_FILE);
	 return (@WLAN_SSID);
}
sub config_state {
    open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");	
	my ($CONFIG_STATE);
	while( my $line = <$CONFIG_FILE> ){
        chomp($line);		
        if($line=~/Config-State : (.*)/){		   		  
		   $CONFIG_STATE=$1;
           		   
        }
   }
   close(CONFIG_FILE);   
   return $CONFIG_STATE;
}

sub login_enable{
    open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");	
	my ($LOGIN_ENABLE, $LOGIN_USER, $LOGIN_PWD);
	while( my $line = <$CONFIG_FILE> ){
        chomp($line);		
        if($line=~/Login-enable : (.*)/){		   		  
		   $LOGIN_ENABLE=$1;
           		   
        }
		if($line=~/Login-name : (.*)/){
		   $LOGIN_USER=$1;
		}
        if($line=~/Login-password : (.*)/){
		   $LOGIN_PWD=$1;
		}        
   }
   close(CONFIG_FILE);   
   return ($LOGIN_ENABLE, $LOGIN_USER, $LOGIN_PWD);
}
sub ap_setup{
   open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");	
   my ($AP_COUNT,$AP_FIND);
   my ($i);
   while( my $line = <$CONFIG_FILE>){
       chomp($line);
	   if($line =~ /AP_ACCOUNT : (.*)/){
	      $AP_COUNT = $1;
          $AP_FIND=1;		  
	   }
	   if( $AP_FIND == 1 && $line =~ /^SSID : (.*)/){
	       $AP_INFO[$i]=$1;
		   $i++;
	   }
	   if( $AP_FIND == 1 && $line =~ /^Key : (.*)/){
	       $AP_INFO[$i]=$1;
		   $i++;
	   }
   }
   close(CONFIG_FILE);      
   return ($AP_COUNT);
}
sub ftp_setup{
   open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");	
	my ($FTP_IP, $FTP_USER, $FTP_PWD);
	while( my $line = <$CONFIG_FILE> ){
        chomp($line);		
        if($line=~/FTP Path : (.*)/){		   		  
		   $FTP_IP=$1; 		   
                }
		if($line=~/User Name : (.*)/){
		   $FTP_USER=$1;
		}
        if($line=~/Password : (.*)/){
		   $FTP_PWD=$1;
		}        
   }
   close(WIRELESS_FILE);   
   return ($FTP_IP, $FTP_USER, $FTP_PWD);
}
sub instant_upload_setup{
#   open(my $CONFIG_FILE, "<", "/etc/instant_upload.conf") or die("Could not open wsd.conf");	
   open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");	
	my ($GPLUS_ENABLE ,$GPLUS_USER, $GPLUS_PWD);
	$GPLUS_ENABLE = "NO";
	while( my $line = <$CONFIG_FILE> ){
        chomp($line);		
		if($line=~/GPlus-Enable : (.*)/){
		   $GPLUS_ENABLE=$1;
		}
		if($line=~/GPlus-Name : (.*)/){
		   $GPLUS_USER=$1;
		}
        if($line=~/GPlus-Password : (.*)/){
		   $GPLUS_PWD=$1;
		}        
   }
   close(CONFIG_FILE);   
   return ($GPLUS_ENABLE, $GPLUS_USER, $GPLUS_PWD);
}
sub ap_selected{
   open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");	
   my ($AP_COUNT);
   while( my $line = <$CONFIG_FILE>){
       chomp($line);
	   if($line =~ /AP_ACCOUNT : (.*)/){
	      $AP_COUNT = $1;
	   }
   }
   close(CONFIG_FILE);      
   return ($AP_COUNT);
}
sub sub_ip_address{
   open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");	
   my ($local_ip1, $local_ip2,$sender_ip1,$sender_ip2);
   while( my $line = <$CONFIG_FILE>){
       chomp($line);
	   if($line =~ /My IP Addr : 192.168.(.*)\./){
	      $local_ip1 = $1;
		  if($line =~ /My IP Addr : 192.168.$local_ip1.(.*)/){
		      $local_ip2 = $1;
		  }
	   }	   
	   if($line =~ /Target IP Addr : 192.168.(.*)\./){
	      $sender_ip1 = $1;
		  if($line =~ /Target IP Addr : 192.168.$sender_ip1.(.*)/){
		      $sender_ip2 = $1;
		  }
	   }	   
   }
   close(CONFIG_FILE); 
   return ($local_ip1, $local_ip2, $sender_ip1, $sender_ip2); 
}

sub WIFI_SSID{
    open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");
    my($WiFi_SD);
    while( my $line = <$CONFIG_FILE>){
	chomp($line);
	if($line =~ /WIFISSID : (.*)/){
	    $WiFi_SD = $1;
	   }
        if($line =~ /Channel : (.*)/){
            $WiFi_channel = $1;
           }
   }
   close(CONFIG_FILE);      
   return ($WiFi_SD);
}

sub Auto_WIFI{
    open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");
    my($Auto_WiFi);
    while( my $line = <$CONFIG_FILE>){
	chomp($line);
	if($line =~ /Auto WIFI : (.*)/){
	    $Auto_WiFi = $1;
	   }
   }
   close(CONFIG_FILE);      
   return ($Auto_WiFi);
}

sub Host_SSID{
    open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");
    my($Host_KEY);
    while( my $line = <$CONFIG_FILE>){
        chomp($line);
           if($line =~ /Host WPA2 Key : (.*)/){
            $Host_KEY = $1;
        }
   }
   close(CONFIG_FILE);      
   return ($Host_KEY);
}

sub Host_Switch{
    open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");
    my($Host_Switch);
    while( my $line = <$CONFIG_FILE>){
        chomp($line);
           if($line =~ /Host WPA2 Key : (.*)/){
            $Host_Switch = $1;
           }
   }
   close(CONFIG_FILE);      
   return ($Host_Switch);
}

sub Wifi_Off {
	open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");
	my($Wifi_Off);
	while( my $line = <$CONFIG_FILE>){
		chomp($line);
		if($line =~ /Auto OFF : (.*)/){
			$Wifi_Off = $1;
		}
	}
	close(CONFIG_FILE);      
	return ($Wifi_Off);
}
sub Host_SSID_backup{
    open(my $CONFIG_FILE, "<", "/etc/wsd_backup.conf") or die("Could not open wsd.conf");
    my($Host_KEY_backup);
    while( my $line = <$CONFIG_FILE>){
        chomp($line);
           if($line =~ /Host WPA2 Key Backup : (.*)/){
            $Host_KEY_backup = $1;
        }
   }
   close(CONFIG_FILE);      
   return ($Host_KEY_backup);
}

sub domain_name{
   open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");	
   my ($domain_name_1,$domain_name_2);
   while( my $line = <$CONFIG_FILE>){
       chomp($line);
	   if($line =~ /Domain Name : (.*)\./){
	      $domain_name_1 = $1;
		  if($line =~ /Domain Name : $domain_name_1.(.*)/){
		  $domain_name_2 = $1;
		  }
	   }
   }
   close(CONFIG_FILE);      
   return ($domain_name_1,$domain_name_2);
}
sub wifi_mode{
   open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");	
   my ($my_wifi_mode);
   while( my $line = <$CONFIG_FILE>){
       chomp($line);
	   if($line =~ /Auto Mode : (.*)/){
	      $my_wifi_mode= $1;
	   }
   }
   close(CONFIG_FILE);      
   return ($my_wifi_mode);
}
sub wifi_ps_mode{
   open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");	
   my ($my_wifi_ps_mode);
   while( my $line = <$CONFIG_FILE>){
       chomp($line);
	   if($line =~ /Power Saving : (.*)/){
	      $my_wifi_ps_mode= $1;
	   }
   }
   close(CONFIG_FILE);      
   return ($my_wifi_ps_mode);
}
sub gplus_config{
    open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");	
	my ($GP_ENABLE, $GP_SSID, $GP_KEY, $GP_USER, $GP_PASS);
	while( my $line = <$CONFIG_FILE> ){
        chomp($line);		
        if($line=~/GPlus-Enable : (.*)/){		   		  
		   $GP_ENABLE=$1;
        }
		if($line=~/GPlus-User : (.*)/){
		   $GP_USER=$1;
		}
        if($line=~/GPlus-Password : (.*)/){
		   $GP_PASS=$1;
		}        
        if($line=~/GPlus-SSID : (.*)/){		   		  
		   $GP_SSID=$1;
        }
        if($line=~/GPlus-Key : (.*)/){		   		  
		   $GP_KEY=$1;
        }
   }
   close(CONFIG_FILE);   
   return ($GP_ENABLE, $GP_SSID, $GP_KEY, $GP_USER, $GP_PASS);
}

#my @SCAN_SSID = &wireless_scan();
my @LOGIN_INFO=&login_enable();
my $CONFIG_INFO=&config_state();
my @AP_SELECTED=&ap_setup();
my @FTP_INFO=&ftp_setup();
my @INSTANT_UPLOAD_INFO=&instant_upload_setup();
my $WIFI_MODE=&wifi_mode();
my $WIFI_PS=&wifi_ps_mode();
print "Content-type: text/html\n\n";
print "<html>";
print "<head>";
print "<meta http-equiv=\"content-language\" content=\"zh-tw\">\n";
print "<meta HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=utf-8\">\n";
print "<link href=\"/script/ts.css\" rel=\"stylesheet\" type=\"text/css\" />\n";
print "<title>Edit-Config</title>\n";
print "<script language=\"javascript\"> 
function myDelete(){
	var oTable = document.getElementById(\"AP_KINDS\");
	var oBody = oTable.tBodies[0];
	var remove_tr1 = this.parentNode.parentNode;
	var tr_index =  remove_tr1.rowIndex;

//	alert(\"This rowIndex=\" + tr_index);
	var remove_tr2 = oBody.rows[tr_index+1];

	for (var i=tr_index+2;i < oBody.rows.length; i+=2) {
		var index_id = Math.floor(i/2) + 1;

//		alert(\"i=\" + i + \"index_id =\" + index_id);
//		alert(\"Modify row \" + i  + \" cells[0].childNodes[0]= \" + oBody.rows[i].cells[0].childNodes[0].innerHTML);

		// AP Num
		oBody.rows[i].cells[0].childNodes[0].innerHTML = (index_id -1);

//		alert(\"Modify row \" + i  + \" cells[1].childNodes[0]= \" + oTable.rows[i].cells[1].childNodes[0].innerHTML);
//		alert(\"Modify row \" + i  + \" cells[2].childNodes[0]= \" + oTable.rows[i].cells[2].childNodes[0].innerHTML);
//		alert(\"Modify row \" + i  + \" cells[2].childNodes[0].childNoes[0] = \" + oTable.rows[i].cells[2].childNodes[0].childNodes[0]);
//		alert(\"Modify row \" + i  + \" cells[2].childNodes[0].childNoes[0].tagName = \" + oTable.rows[i].cells[2].childNodes[0].childNodes[0].tagName);

//		alert(\"Modify row \" + i  + \" cells[2].childNodes[0].childNoes[0].firstChild = \" + oTable.rows[i].cells[2].childNodes[0].childNodes[0].firstChild);
//		alert(\"Modify row \" + i  + \" cells[2].childNodes[0].childNoes[0].firstChild.tagName = \" + oTable.rows[i].cells[2].childNodes[0].childNodes[0].firstChild.tagName);
//		alert(\"Modify row \" + i  + \" cells[2].childNodes[0].childNoes[0].firstChild.name = \" + oTable.rows[i].cells[2].childNodes[0].childNodes[0].firstChild.name);

//		alert(\"Modify row \" + i  + \" cells[2].childNodes[3].tagname= \" + oTable.rows[i].cells[2].childNodes[3].tagName);
//		alert(\"Modify row \" + i  + \" cells[2].childNodes[0] = \" + oTable.rows[i].cells[2].childNodes[0]);
//		alert(\"Modify row \" + i  + \" cells[2].childNodes[0].name = \" + oTable.rows[i].cells[2].childNodes[0].name);
		oBody.rows[i].cells[2].childNodes[0].name = \"SSID\" + (index_id -1);

//		alert(\"Modify row \" + i  + \" cells[2].childNodes[3].tagname= \" + oTable.rows[i+1].cells[2].childNodes[3].tagName);
		oBody.rows[i+1].cells[1].childNodes[0].name = \"KEY\" + (index_id -1);
	}


//	alert(\"Remove rowIndex=\" + remove_tr2.rowIndex);
	this.parentNode.parentNode.parentNode.removeChild(remove_tr2);

//	alert(\"Remove rowIndex=\" + remove_tr1.rowIndex);
	this.parentNode.parentNode.parentNode.removeChild(remove_tr1);
}

//window.onload=function(){
//	var oTable = document.getElementById(\"AP_KINDS\");
//	var oBody = oTable.tBodies[0];
//	var oTd;
//	for(var i=1;i<oBody.rows.length;i++){
//		if (i%2==1) {
//			oTd = oBody.rows[i].insertCell(3);
//			oTd.rowSpan= \"2\";
//			oTd.innerHTML = \"<a href='#'>delete</a>\";
//			oTd.firstChild.onclick = myDelete;
//		}
//	}
//}
</script>";
print "<script language=\"javascript\" type=\"text/javascript\">
function control(obj)
{
document.forms['kcard_edit_form'].Host_WPA_KEY.disabled = (obj.checked)?false:true;
}
</script>\n";

print "<script language=\"javascript\" type=\"text/javascript\">
function check_string(check_value)
{ 
<!--
	for( idx = 0 ; idx < check_value.length; idx++) {
		if ( !((check_value.charAt(idx)>= 'a' && check_value.charAt(idx) <= 'z' ) || (check_value.charAt(idx)>= 'A' && check_value.charAt(idx) <= 'Z' ) || ( check_value.charAt(idx)>= '0' && check_value.charAt(idx) <= '9' )||(check_value.charAt(idx) == '_' ))) {
			return -1;
		}
	}
	return 0;
//-->
}


function check_pass()
{ 
<!--
	with(document.all){
		if(pwd.value!=pwd_confirm.value)
		{
			alert(\"The passwords do not match!\");
			pwd.value = \"\";
			pwd_confirm.value = \"\";
		} else {
			if (Yourname.value.length < 5) {
				alert(\"The Account name is too short! at least 5 characters \");
				return -1;
			}
			if (pwd.value.length < 3) {
				alert(\"The passwords is too short! at least 3 characters \");
				return -1;
			}

			if (check_string(Yourname.value) < 0) {
				alert(\"The account name contains illegal character\");
				return -1;
			}
			if (check_string(pwd.value) < 0) {
				alert(\"The password contains illegal character\");
				return -1;
			}
			if (validate_IPAddress_3rd(Local_IP1.value) == false) {
				return -1;
			}
			if (validate_IPAddress_4th(Local_IP2.value) == false) {
				return -1;
			}
			if (get_utf8_length(WIFI_SSID.value) > 32) {
				alert(\"The maximum length of SSID is 32 characters\");
				return -1;
			}

			document.forms[0].submit();
		} 
	}
//-->
}
function Recovery()
<!--
{
    //location.href=\"/cgi-bin/kcard_default.cgi\"; 
	location.href=\"kcard_default.pl\";
    //window.alert(\"Successful Recovery\");
}
//-->
</script>";

print "<SCRIPT type='text/javascript' src='../script/kcard_edit_config.js'></SCRIPT>\n";
print "</head>";
print "<body>";
print "<Form name=\"kcard_edit_form\" action=\"kcard_save_config_insup.pl\" method=\"POST\" target=\"_self\">";
print "<h2>Settings</h2>\n";
#print "<select name=\"SCAN_AP\">";
#for (my $i; $i <= $#SCAN_SSID; $i++){
#	 print "<option value=\"$SCAN_SSID[$i][0]\">$SCAN_SSID[$i][0]";	 	 
#}
#print "</select>";
#print "<br><b>Login-Set      : <I>";
#print "<select name=\"Login_Enable\">";
#if ( $LOGIN_INFO[0] =~ /Yes/){
#      print "<option value=\"Yes\" selected='yes'>Yes";	 	 
#	  print "<option value=\"No\">No";	 	 	  
#}  
#else{ 
#      print "<option value=\"Yes\">Yes";	 	 
#      print "<option value=\"No\" selected='yes'>No";	 	 
#}  

#print "</select></I></b>";
#print "<br><b>Login-User     : <I><input name=\"Yourname\" id=\"name\" size=\"10\" maxlength=\"12\" value='$LOGIN_INFO[1]'></I></b>";
#print "<br><b>Login-Password : <I><input name=\"Yourpwd\" type=\"password\" id=\"pwd\" size=\"12\" maxlength=\"10\"  value='$LOGIN_INFO[2]'></I></b>";
print "<table border=\"1\" width=\"500\"><tbody>\n";
print "<tr class=\"subt\">\n";
print "   <td colspan=\"2\" class=\"subt\" > <b> Administrator Account</b> </td>\n";
print "</tr >\n";
print "<tr >\n";
print "   <td align=\"right\"width=\"250\"><I><b>User name (Min 5 character) : </b></I> </td>\n";
print "   <td align=\"left\"><b><I><input name=\"Yourname\" id=\"name\" size=\"12\" maxlength=\"20\" value='$LOGIN_INFO[1]'></I></b></td>\n";
print "</tr >\n";
print "<tr >\n";
print "		<td align=\"right\" width=\"250\"><I><b>Password (Min 3 character): </b></I></td>\n";
print "		<td align=\"left\"><b><I><input name=\"Yourpwd\" type=\"password\" id=\"pwd\" size=\"12\" maxlength=\"20\"  value='$LOGIN_INFO[2]'></I></b></td>\n";
print "</tr >\n";
print "<tr >\n";
print "		<td align=\"right\" width=\"250\"><I><b>Confirm Password : </b></I></td>\n";
print "		<td align=\"left\"><b><I><input name=\"Yourpwd_confirm\" type=\"password\" id=\"pwd_confirm\" size=\"12\" maxlength=\"20\"  value='$LOGIN_INFO[2]'></I></b></td>\n";
print "</tr >\n";
print "</tbody></table>\n";

print "<br>";


#print "<br><br><b>Number of APs  : </b>";
#print "<a href=\"#\" onClick=\"Insert($AP_SELECTED[0])\">Insert</a>";
#print "<table id=\"AP_KINDS\"><OL>";
#for (my $i=1; $i<=$AP_SELECTED[0]; $i++){
#print "<tr>";
#print "<td>AP #$i SSID : <input type=\"text\" name=\"SSID$i\" value=\"$AP_INFO[2*$i-2]\"></td>";
#print "<td>KEY : <input type=\"password\" maxlength=\"64\" name=\"KEY$i\" value=\"$AP_INFO[2*$i-1]\"></td>";
#print "</tr>";
#}
#print "</table>";
#print "<br><b>FTP Information</b><br>";

my $Auto_WiFi=&Auto_WIFI();
my $WiFi_SD=&WIFI_SSID();
my $Host_AP=&Host_SSID();
my $Host_AP_backup=&Host_SSID_backup();
my $Host_Switch=&Host_Switch();
my $WIFI_OFF=&Wifi_Off();
my @sub_ip_addr=&sub_ip_address();
$Host_Switch_LEN = length($Host_Switch);


print "<br>\n";
print "<table border=\"1\" width=\"500\"><tbody>";
print "<tr class=\"subt\">";
print "   <td colspan=\"2\" class=\"subt\" > <b> WiFi Settings</b> </td>";
print "</tr >\n";
#print "<tr >";
#print "   <td align=\"right\" width=\"250\"><I><b> Auto WiFi :</b></I> </td> <td align=\"left\">";
#print "<select name=\"Auto_WIFI\">";
#if ( $Auto_WiFi =~ /Yes/){
#      print "<option value=\"Yes\" selected='yes'>Yes";	 	 
#	  print "<option value=\"No\">No";	 	 	  
#}  
#else{ 
#      print "<option value=\"Yes\">Yes";	 	 
#      print "<option value=\"No\" selected='yes'>No";	 	 
#}
#print "</td>";
#print "</tr >";
print "<tr >\n";
print "   <td align=\"right\" width=\"250\"><I><b>  SSID :</b></I></td> <td align=\"left\"><input type=\"text\" name=\"WIFI_SSID\" maxlength=\"32\" Value=\"$WiFi_SD\"></td>";
print "</tr \n>";
print "<tr >\n";
print "   <td align=\"right\" width=\"250\"><I><b> Enable WPA2/PSK Security :</b></I></td> <td align=\"left\">\n";
if ($Host_Switch_LEN != 0) {
	print "<font size=\"2\"><input type=\"checkbox\" name=\"ctr\" onclick=control(this) VALUE=\"true\" CHECKED></font>";
}else {
	print "<font size=\"2\"><input type=\"checkbox\" name=\"ctr\" onclick=control(this)></font>";
}
print "</td>\n";

print "<tr >\n";
print "   <td align=\"right\" width=\"250\"><I><b> Pre-shared key :</b></I></td> <td align=\"left\">\n";
if ($Host_Switch_LEN != 0) {
	print "<input type=\"text\" name=\"Host_WPA_KEY\" maxlength=\"63\" value=\"$Host_AP\"><br>(Please input 8 ~ 63 characters)";
} else {
	print "<input type=\"text\" disabled name=\"Host_WPA_KEY\" maxlength=\"63\" value=\"$Host_AP_backup\"><br>(Please input 8 ~ 63 characters)";
}
print "</td>\n";
print "</tr >\n";

print "<tr >\n";
print "   <td align=\"right\" width=\"250\"><I><b> IP Address :  </b></I></td>\n";
print "   <td align=\"left\"> 192.168.<input type=\"text\" name=\"Local_IP1\" size=\"4\" value=\"$sub_ip_addr[0]\">. <input type=\"text\" name=\"Local_IP2\" size=\"4\" value=\"$sub_ip_addr[1]\">";
print "   <br>(The last digit can't use range 11~50)</td>\n";
print "</tr >\n";

#print "<tr >";
#print "   <td align=\"right\" width=\"250\"><I><b> Wireless Channel:</b></I></td>";
#print "   <td align=\"left\" <I><b>";
#print "<select name=\"Channel_Num\">";
#for ( my $i=auto; $i<=11; $i++){
#     if ( $i == $WiFi_channel){
#	   print "<option value=\"$i\" selected='yes' >$i";	 	 
#	 }  else{ 
#	   print "<option value=\"$i\" >$i";	 	 
#	 }  
#}
#print "</select>";
#print "</b></I></td>";
#print "</tr >";


print "</tbody></table>\n";

# For WiFi Options
print "<br><br>\n";
print "<table border=\"1\" width=\"500\"><tbody>\n";
print "<tr class=\"subt\">";
print "   <td colspan=\"2\" class=\"subt\" > <b> WiFi Options</b> </td>";
print "</tr >\n";
print "<tr >\n";
print "   <td align=\"right\" width=\"250\"><I><b>Default Mode :</b></I></td> <td align=\"left\">\n";
if ($WIFI_MODE =~ /DS/) {
	print "<input type=\"radio\" name=\"wifi_mode\" value=\"DS\" checked> Direct-Share <br>\n";
	print "<input type=\"radio\" name=\"wifi_mode\" value=\"IN\"> Internet \n";
} else {
	print "<input type=\"radio\" name=\"wifi_mode\" value=\"DS\"> Direct-Share <br>\n";
	print "<input type=\"radio\" name=\"wifi_mode\" value=\"IN\" checked> Internet \n";
}
print "</td>\n";
print "</tr >\n";

print "<tr >\n";
print "   <td align=\"right\" width=\"250\"><I><b>Turn Off WiFi :</b></I></td> <td align=\"left\">\n";
if ($WIFI_OFF == 60) {
	print "<input type=\"radio\" name=\"Auto_OFF\" value=\"0\" >  Never <br>\n";
	print "<input type=\"radio\" name=\"Auto_OFF\" value=\"60\" checked>  1 min<br>\n";
	print "<input type=\"radio\" name=\"Auto_OFF\" value=\"300\">  5 mins<br>\n";
	print "<input type=\"radio\" name=\"Auto_OFF\" value=\"600\">  10 mins\n";
} elsif ($WIFI_OFF == 300)  {
	print "<input type=\"radio\" name=\"Auto_OFF\" value=\"0\" >  Never <br>\n";
	print "<input type=\"radio\" name=\"Auto_OFF\" value=\"60\" >  1 min<br>\n";
	print "<input type=\"radio\" name=\"Auto_OFF\" value=\"300\" checked>  5 mins<br>\n";
	print "<input type=\"radio\" name=\"Auto_OFF\" value=\"600\">  10 mins\n";
} elsif ($WIFI_OFF == 600)  {
	print "<input type=\"radio\" name=\"Auto_OFF\" value=\"0\" >  Never <br>\n";
	print "<input type=\"radio\" name=\"Auto_OFF\" value=\"60\" >  1 min<br>\n";
	print "<input type=\"radio\" name=\"Auto_OFF\" value=\"300\" >  5 mins<br>\n";
	print "<input type=\"radio\" name=\"Auto_OFF\" value=\"600\" checked>  10 mins\n";
} else {
	print "<input type=\"radio\" name=\"Auto_OFF\" value=\"0\" checked>  Never <br>\n";
	print "<input type=\"radio\" name=\"Auto_OFF\" value=\"60\" >  1 min<br>\n";
	print "<input type=\"radio\" name=\"Auto_OFF\" value=\"300\" >  5 mins<br>\n";
	print "<input type=\"radio\" name=\"Auto_OFF\" value=\"600\" >  10 mins\n";
}

print "</td>\n";
print "</tr >\n";
print "<tr >\n";
print "   <td align=\"right\" width=\"250\"><I><b>Power Management :</b></I></td> <td align=\"left\">\n";
if ($WIFI_PS =~ /Yes/) {
	print "<input type=\"radio\" name=\"wifi_ps_mode\" value=\"Yes\" checked> Enable <br>\n";
	print "<input type=\"radio\" name=\"wifi_ps_mode\" value=\"No\"> Disable \n";
} else {
	print "<input type=\"radio\" name=\"wifi_ps_mode\" value=\"Yes\"> Enable <br>\n";
	print "<input type=\"radio\" name=\"wifi_ps_mode\" value=\"No\" checked> Disable \n";
}
print "</td>\n";
print "</tr >\n";

print "<tr >\n";


print "</tbody></table>\n";
# End For WiFi Options

print "<br><br>\n";

print "<table id=\"AP_KINDS\" border=\"1\" width=\"500\"><tbody>\n";
print "<tr class=\"subt\">\n";
print "   <td colspan=\"4\" class=\"subt\" > <b> Internet Hotspot Settings</b> </td>\n";
print "</tr >\n";
#for (my $i=1; $i<=$AP_SELECTED[0]; $i++){
for (my $i=1; $i <= 3; $i++){
	print "<tr >\n";
	print "   <td rowspan=\"2\" align=\"center\" width=\"30\"><b> $i </b> </td>\n";
	print "   <td align=\"right\" width=\"200\"><I><b> SSID : </b></I> </td>\n";
	print "   <td align=\"left\" ><input type=\"text\" maxlength=\"32\" name=\"SSID$i\" value=\"$AP_INFO[2*$i-2]\"></td>\n";
	print "</tr >\n";
	print "<tr >\n";
	print "   <td align=\"right\" width=\"200\"><I><b> KEY : </b></I></td>\n";
	print "   <td align=\"left\" ><input type=\"input\" maxlength=\"64\" name=\"KEY$i\" value=\"$AP_INFO[2*$i-1]\"></td>\n";
	print "</tr >\n";
}

#print "<tfoot>\n";
#print "<tr><td align=\"right\" colspan=\"4\"> \n";
#print "   <input type=\"button\" style=\"width: 100px\" value=\"Add Hotspot\" onClick=\"Insert($AP_SELECTED[0])\">\n";
#print "</td> </tr> \n";
#print "</tfoot>\n";

print "</tbody></table>\n";




print "<input type=\"hidden\" name=\"CONFIG_STATE\" value=\"$CONFIG_INFO\">\n";
print "<input type=\"hidden\" name=\"Auto_WIFI\" value=\"Yes\">\n";
#print "<input type=\"hidden\" name=\"Auto_OFF\" value=\"$Wifi_Off\">\n";
print "<input type=\"hidden\" name=\"Channel_Num\" value=\"auto\">\n";
print "<input type=\"hidden\" name=\"FTP_PATH\" value=\"$FTP_INFO[0]\">\n";
print "<input type=\"hidden\" name=\"FTP_User\" value=\"$FTP_INFO[1]\">\n";
print "<input type=\"hidden\" name=\"FTP_PWD\" value=\"$FTP_INFO[2]\">\n";

#print "Local  IP Address : 192.168.
#"<input type=\"text\" name=\"Local_IP1\" size=\"4\" value=\"$sub_ip_addr[0]\">.
#<input type=\"text\" name=\"Local_IP2\" size=\"4\" value=\"$sub_ip_addr[1]\"><br>";

#print "<input type=\"hidden\" name=\"Local_IP1\" size=\"4\" value=\"$sub_ip_addr[0]\">
#<input type=\"hidden\" name=\"Local_IP2\" size=\"4\" value=\"$sub_ip_addr[1]\">";

#print "Sender IP Address : 192.168.
#"<input type=\"text\" name=\"Sender_IP1\" size=\"4\" value=\"$sub_ip_addr[2]\">.
#<input type=\"text\" name=\"Sender_IP2\" size=\"4\" value=\"$sub_ip_addr[3]\"><br>";
print "<input type=\"hidden\" name=\"Sender_IP1\" size=\"4\" value=\"$sub_ip_addr[2]\">
<input type=\"hidden\" name=\"Sender_IP2\" size=\"4\" value=\"$sub_ip_addr[3]\">\n";

my @domain=&domain_name();
my @gplus=&gplus_config();
print "<input type=\"hidden\" name=\"GPLUS_ENABLE\" value=\"$gplus[0]\">\n";
print "<input type=\"hidden\" name=\"GPLUS_SSID\" value=\"$gplus[1]\">\n";
print "<input type=\"hidden\" name=\"GPLUS_KEY\" value=\"$gplus[2]\">\n";
print "<input type=\"hidden\" name=\"GPLUS_USER\" value=\"$gplus[3]\">\n";
print "<input type=\"hidden\" name=\"GPLUS_PASS\" value=\"$gplus[4]\">\n";

#print "<br> Domain Name : 
print "<input type=\"hidden\" name=\"domain_name_1\" size=\"12\" maxlength=\"10\" value=\"$domain[0]\">
<input type=\"hidden\" name=\"domain_name_2\" size=\"12\" maxlength=\"10\" value=\"$domain[1]\">\n";

# Google Plus 
#print "<br><b>Instant Upload</b><br>";
#if ( $INSTANT_UPLOAD_INFO[0] =~ /YES/ ) {
#	print "G+ Enable : <input type=\"checkbox\" name=\"GPLUS_ENABLE\" VALUE=\"YES\" CHECKED /> <br>";
#}else {
#	print "G+ Enable : <input type=\"checkbox\" name=\"GPLUS_ENABLE\" VALUE=\"NO\" /> <br>";
#}
#print "G+ User : <input type=\"text\" name=\"GPLUS_USER\" Value=\"$INSTANT_UPLOAD_INFO[1]\"> \@gmail.com <br>";
#print "G+ Password : <input type=\"password\" name=\"GPLUS_PWD\" Value=\"$INSTANT_UPLOAD_INFO[2]\"><br>";

#print "<br><br><b>Buzzer Setting</b><br>";
#print "<input type=\"radio\" name=\"buzzer_disable\" value=\"Disable\"> Disable<br>";
print "<input type=\"hidden\" name=\"buzzer_disable\" value=\"Disable\">";
#print "<input type=\"radio\" name=\"buzzer_enable\" value=\"Enable\" checked='checked'> Enable<br>";

print "<br>\n";
print "<table border=\"0\" width=\"500\"><tbody>\n";
print "<tr> <td align=\"right\"> \n";
print "		<input type=\"button\" style=\"width: 100px\" onclick=\"check_pass()\" value=\"Submit\">";
print "</td> </tr> \n";
print "</tbody></table>\n";

#print "<input type=\"button\" value=\"Back\" onClick=\"Back()\">&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;";
#print "<input type=\"button\" value=\"Restore defaults\" onClick=\"Recovery()\">";
print "</form>";
print "</body>";
print "</html>";


