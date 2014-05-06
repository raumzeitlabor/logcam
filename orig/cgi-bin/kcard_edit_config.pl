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
sub login_enable{
    open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");	
	my ($LOGIN_ENABLE, $LOGIN_USER, $LOGIN_PWD);
	while( my $line = <$CONFIG_FILE> ){
        chomp($line);		
        if($line=~/Login-set : (.*)/){		   		  
		   $LOGIN_ENABLE=$1;
           		   
        }
		if($line=~/Login-user : (.*)/){
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
	   if( $AP_FIND == 1 && $line =~ /SSID : (.*)/){
	       $AP_INFO[$i]=$1;
		   $i++;
	   }
	   if( $AP_FIND == 1 && $line =~ /Key : (.*)/){
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
		  if($line =~ /Target IP Addr : 192.168.$local_ip1.(.*)/){
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
my @AP_SELECTED=&ap_setup();
my @FTP_INFO=&ftp_setup();
print "Content-type: text/html\n\n";
print "<html>";
print "<head>";
print "<meta http-equiv=\"content-language\" content=\"zh-tw\">";
print "<meta HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=utf-8\">";
print "<title>Edit-Config</title>";
#if($LOGIN_INFO[0] =~ /Yes/)
#{
#print "<script type=\"text/javascript\">
#   if(document.cookie.length != 0)
#       {}
#   else{
#         //window.alert(\"Successful Recovery-------Justin\");
#		 location.href=\"kcard_login.pl\";        
#   }    
#</script>";
#}
print "<script language=\"javascript\"> 
function myDelete(){
	var oTable = document.getElementById(\"AP_KINDS\");
	//§R°£¸Ó¦æ
	this.parentNode.parentNode.parentNode.removeChild(this.parentNode.parentNode);
}
window.onload=function(){
	var oTable = document.getElementById(\"AP_KINDS\");
	var oTd;
	
	for(var i=0;i<oTable.rows.length;i++){
		oTd = oTable.rows[i].insertCell(2);
		oTd.innerHTML = \"<a href='#'>delete</a>\";
		oTd.firstChild.onclick = myDelete;
	}
}
</script>";
print "<script language=\"javascript\" type=\"text/javascript\">
function control(obj)
{
document.forms['kcard_edit_form'].Host_WPA_KEY.disabled = (obj.checked)?false:true;
}
</script>";
print "<script language=\"javascript\" type=\"text/javascript\">
function Recovery()
<!--
{
    //location.href=\"/cgi-bin/kcard_default.cgi\"; 
	location.href=\"kcard_default.pl\";
    //window.alert(\"Successful Recovery\");
}
//-->
</script>";
print "<style>
<!--
body{
	background-color:#ffdee0;
}
-->
</style>";
print "<SCRIPT type='text/javascript' src='../script/kcard_edit_config.js'></SCRIPT>\n";
print "</head>";
print "<body>";
print "<Form name=\"kcard_edit_form\" action=\"kcard_save_config.pl\" method=\"POST\" target=\"_self\">";
print "<h2>Wifi Information Edit</h2>";
print "<b>Login Setup</b>";	
#print "<select name=\"SCAN_AP\">";
#for (my $i; $i <= $#SCAN_SSID; $i++){
#	 print "<option value=\"$SCAN_SSID[$i][0]\">$SCAN_SSID[$i][0]";	 	 
#}
#print "</select>";
print "<br><b>Login-set      : <I>";
print "<select name=\"Login_Enable\">";
if ( $LOGIN_INFO[0] =~ /Yes/){
      print "<option value=\"Yes\" selected='yes'>Yes";	 	 
	  print "<option value=\"No\">No";	 	 	  
}  
else{ 
      print "<option value=\"Yes\">Yes";	 	 
      print "<option value=\"No\" selected='yes'>No";	 	 
}  
print "</select></I></b>";
print "<br><b>Login-user     : <I><input name=\"Yourname\" id=\"name\" size=\"10\" maxlength=\"12\" value='$LOGIN_INFO[1]'></I></b>";
print "<br><b>Login-password : <I><input name=\"Yourpwd\" type=\"password\" id=\"pwd\" size=\"12\" maxlength=\"10\"  value='$LOGIN_INFO[2]'></I></b>";

print "<br><br><b>Number of APs  : </b>";
print "<a href=\"#\" onClick=\"Insert($AP_SELECTED[0])\">Insert</a>";
print "<table id=\"AP_KINDS\"><OL>";
for (my $i=1; $i<=$AP_SELECTED[0]; $i++){
print "<tr>";
print "<td>AP #$i SSID : <input type=\"text\" name=\"SSID$i\" value=\"$AP_INFO[2*$i-2]\"></td>";
print "<td>KEY : <input type=\"password\" maxlength=\"64\" name=\"KEY$i\" value=\"$AP_INFO[2*$i-1]\"></td>";
print "</tr>";
}
print "</table>";
print "<br><b>FTP Information</b><br>";
print "FTP Login IP : <input type=\"text\" name=\"FTP_PATH\" Value=\"$FTP_INFO[0]\"><br>";
print "FTP Login User : <input type=\"text\" name=\"FTP_User\" Value=\"$FTP_INFO[1]\"><br>";
print "FTP Login Password : <input type=\"password\" name=\"FTP_PWD\" Value=\"$FTP_INFO[2]\"><br>";
print "<br><b>WiFi Information</b><br>";
my $Auto_WiFi=&Auto_WIFI();
print "Auto WIFI      : ";
print "<select name=\"Auto_WIFI\">";
if ( $Auto_WiFi =~ /Yes/){
      print "<option value=\"Yes\" selected='yes'>Yes";	 	 
	  print "<option value=\"No\">No";	 	 	  
}  
else{ 
      print "<option value=\"Yes\">Yes";	 	 
      print "<option value=\"No\" selected='yes'>No";	 	 
}  
print "</select>";
my $WiFi_SD=&WIFI_SSID();
print "<br>SSID : <input type=\"text\" name=\"WIFI_SSID\" Value=\"$WiFi_SD\"><br>";
my $Host_AP=&Host_SSID();
my $Host_AP_backup=&Host_SSID_backup();
#print "<SCRIPT language=\"JavaScript\">
#       <!--
#       onclick=control(this);
#       //-->
#       </SCRIPT>";
#print "<font size=\"2\"><input type=\"checkbox\" name=\"ctr\" onclick=control(this) VALUE=\"true\" CHECKED>(V : Enable Host WPA2)</font>";
my $Host_Switch=&Host_Switch();
$Host_Switch_LEN = length($Host_Switch);
if ($Host_Switch_LEN != 0)
{
print "<font size=\"2\"><input type=\"checkbox\" name=\"ctr\" onclick=control(this) VALUE=\"true\" CHECKED>(V : Enable Host WPA2)</font>";
print "<br>Host WPA2 Key : <input type=\"text\" name=\"Host_WPA_KEY\" maxlength=\"63\" value=\"$Host_AP\">(Please input 8 ~ 63 characters)<br>";
}
else
{
print "<font size=\"2\"><input type=\"checkbox\" name=\"ctr\" onclick=control(this)>(V : Enable Host WPA2)</font>";
print "<br>Host WPA2 Key : <input type=\"text\" disabled name=\"Host_WPA_KEY\" maxlength=\"63\" value=\"$Host_AP_backup\">(Please input 8 ~ 63 characters)<br>";
}
my @sub_ip_addr=&sub_ip_address();
print "Local  IP Address : 192.168.
<input type=\"text\" name=\"Local_IP1\" size=\"4\" value=\"$sub_ip_addr[0]\">.
<input type=\"text\" name=\"Local_IP2\" size=\"4\" value=\"$sub_ip_addr[1]\"><br>";

print "Sender IP Address : 192.168.
<input type=\"text\" name=\"Sender_IP1\" size=\"4\" value=\"$sub_ip_addr[2]\">.
<input type=\"text\" name=\"Sender_IP2\" size=\"4\" value=\"$sub_ip_addr[3]\"><br>";
print "Wireless Channel : ";
print "<select name=\"Channel_Num\">";

for ( my $i=auto; $i<=11; $i++){
     if ( $i == $WiFi_channel){
	   print "<option value=\"$i\" selected='yes' >$i";	 	 
	 }  
	 else{ 
	   print "<option value=\"$i\" >$i";	 	 
	 }  
}

print "</select>";
my @domain=&domain_name();
my @gplus=&gplus_config();
print "<input type=\"hidden\" name=\"GPLUS_ENABLE\" value=\"$gplus[0]\">";
print "<input type=\"hidden\" name=\"GPLUS_SSID\" value=\"$gplus[1]\">";
print "<input type=\"hidden\" name=\"GPLUS_KEY\" value=\"$gplus[2]\">";
print "<input type=\"hidden\" name=\"GPLUS_USER\" value=\"$gplus[3]\">";
print "<input type=\"hidden\" name=\"GPLUS_PASS\" value=\"$gplus[4]\">";

print "<br> Domain Name : 
<input type=\"text\" name=\"domain_name_1\" size=\"12\" maxlength=\"10\" value=\"$domain[0]\">.
<input type=\"text\" name=\"domain_name_2\" size=\"12\" maxlength=\"10\" value=\"$domain[1]\">";

#print "<br><br><b>Buzzer Setting</b><br>";
#print "<input type=\"radio\" name=\"buzzer_disable\" value=\"Disable\"> Disable<br>";
print "<input type=\"hidden\" name=\"buzzer_disable\" value=\"Disable\">";
#print "<input type=\"radio\" name=\"buzzer_enable\" value=\"Enable\" checked='checked'> Enable<br>";

print "<br><br><input type=\"submit\" value=\"Submit All\">&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;";
print "<input type=\"button\" value=\"Back\" onClick=\"Back()\">&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;";
print "<input type=\"button\" value=\"Recovery\" onClick=\"Recovery()\">";
print "</form>";
print "</body>";
print "</html>";


