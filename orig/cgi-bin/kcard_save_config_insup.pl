#!/usr/bin/perl
my @SSID, @KEY;
my $AP_SET_NUMS=0;   
my $WPA_KEY_LEN=0;   
my $refresh_sd="/bin/sync; /usr/bin/refresh_sd";
my $update_auth="/usr/bin/get_authfile";
my $auth_to_mtd="cp /etc/boa/ia.passwd /mnt/mtd/config";
#my $wsd_to_mtd="cp /mnt/sd/wsd.conf /mnt/mtd/config";
my $dnsd_to_mtd="cp /etc/dnsd.conf /mnt/mtd/config";
my $instant_upload_to_mtd="cp /etc/instant_upload.conf /mnt/mtd/config";
my $udhcpd_to_mtd="cp /etc/udhcpd.conf /mnt/mtd/config";
my $WPA2_Key_backup="/etc/";

sub trim($) {
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
sub AP_INFO_GET{
   for (my $i=1; $i<=20; $i++){
       foreach $Form_key (keys %Form) { 	   
	      #if( $Form_key =~ /SSID$i/ && !($Form{$Form_key} eq "")){     
			#if( $Form_key =~ /^SSID$i/ && length trim($Form{$Form_key}) > 0){
		  if( $Form_key =~ /^SSID$i/) {
              $SSID[$i] = $Form{$Form_key};
			 $AP_SET_NUMS += 1;
	      }
		  
	      if($Form_key =~ /^KEY$i/){
	         $KEY[$i] = $Form{$Form_key};
	      }
       }	 
   }  
   
   return 1;
}
sub save_config{
   open(CONFIG_FILE, ">/mnt/mtd/config/wsd.conf") or die("Could not open wsd.conf");	
   print CONFIG_FILE "Config-State : $CONFIG_STATE\n";
   print CONFIG_FILE "Login-enable : $LOGIN_SET\n";
   print CONFIG_FILE "Login-name : $LOGIN_USR\n";
   print CONFIG_FILE "Login-password : $LOGIN_PWD\n";
   print CONFIG_FILE "[LANGUAGE]\nEnglish\n";
   print CONFIG_FILE "[AP]\n";
   print CONFIG_FILE "AP_ACCOUNT : $AP_SET_NUMS\n";
   for(my $j=1; $j <= 3; $j++){
#	   if (length trim($SSID[$j]) > 0) { 
		   print CONFIG_FILE "SSID : $SSID[$j]\n";
		   print CONFIG_FILE "Key : $KEY[$j]\n";
#	   }
   }	   
   print CONFIG_FILE "[FTP]\n";
   print CONFIG_FILE "FTP Path : $FTP_LOGIN_PATH\n";
   print CONFIG_FILE "User Name : $FTP_LOGIN_User\n";
   print CONFIG_FILE "Password : $FTP_LOGIN_PWD\n";
   print CONFIG_FILE "[Wi-Fi Setting]\n";
   print CONFIG_FILE "Auto WIFI : $Auto_WIFI\n";
   print CONFIG_FILE "Auto OFF : $Auto_OFF\n";
   print CONFIG_FILE "Auto Mode : $Auto_MODE\n";
   print CONFIG_FILE "WIFISSID : $WIFI_SSID\n";
   print CONFIG_FILE "Host WPA2 Key : $Host_WPA_KEY\n";
   if($WPA_KEY_LEN >= 8)
   {
	  if (ctr) {
		  print CONFIG_FILE "Host WPA2 Switch : on\n";
	  } else {
		  print CONFIG_FILE "Host WPA2 Switch : \n";
	  }
      print CONFIG_FILE "Host WPA2 Key Backup : $Host_WPA_KEY\n";
   }
   else
   {
      print CONFIG_FILE "Host WPA2 Switch : \n";
      print CONFIG_FILE "Host WPA2 Key Backup : \n";
   }  
   print CONFIG_FILE "Channel : $CHANNEL_SET\n";
   print CONFIG_FILE "Power Saving : $WIFI_PS_MODE\n";
   print CONFIG_FILE "Domain Name : $DOMAIN_NAME_1.$DOMAIN_NAME_2\n";
   print CONFIG_FILE "My IP Addr : 192.168.$LOCAL_SD_IP1.$LOCAL_SD_IP2\n";
   print CONFIG_FILE "Target IP Addr : 192.168.$Sender_SD_IP1.$Sender_SD_IP2\n";
   my $temp = $Sender_SD_IP2+50;
   print CONFIG_FILE "Receiver IP Addr : 192.168.$Sender_SD_IP1.$temp\n";
   print CONFIG_FILE "[Instant Setup]\n";
   print CONFIG_FILE "GPlus-Enable : $GPLUS_ENABLE\n";
   print CONFIG_FILE "GPlus-SSID : $GPLUS_SSID\n";
   print CONFIG_FILE "GPlus-Key : $GPLUS_KEY\n";
   print CONFIG_FILE "GPlus-User : $GPLUS_USER\n";
   print CONFIG_FILE "GPlus-Password : $GPLUS_PASS\n";

   print CONFIG_FILE "[MISC]\n";
   if ($Form{buzzer_disable}){
       print CONFIG_FILE "Buzzer Mode : $Form{buzzer_disable}\n";
   }else{
       print CONFIG_FILE "Buzzer Mode : Normal\n";
   } 	   
   close(CONFIG_FILE);   
   if (length($LOGIN_USR) >= 5  && length($LOGIN_PWD) >= 3) {
		`$update_auth $LOGIN_USR $LOGIN_PWD > /mnt/mtd/config/ia.passwd`
   }
#`$auth_to_mtd`;
   `$refresh_sd`;
   `$wsd_to_mtd`;
   
   open(DNSD_FILE, ">/etc/dnsd.conf") or die("Could not open dnsd.conf");	
   print DNSD_FILE "$DOMAIN_NAME_1.$DOMAIN_NAME_2 192.168.$LOCAL_SD_IP1.$LOCAL_SD_IP2\n";
   close(DNSD_FILE);
   `$dnsd_to_mtd`;
   
   open(UDHCPD_FILE, ">/etc/udhcpd.conf") or die("Could not open udhcpd.conf");	
   $temp = 11;
   print UDHCPD_FILE "start 192.168.$LOCAL_SD_IP1.$temp\n";
   $temp = 50;
   print UDHCPD_FILE "end   192.168.$LOCAL_SD_IP1.$temp\n";
   print UDHCPD_FILE "max_leases      200\n";
   print UDHCPD_FILE "interface       mlan0\n";
   print UDHCPD_FILE "lease_file      /var/lib/misc/udhcpd.lease\n";
   print UDHCPD_FILE "notify_file     /usr/bin/dhcpd_notify.sh\n";
   print UDHCPD_FILE "option  subnet  255.255.255.0\n";
   print UDHCPD_FILE "option  router  192.168.$LOCAL_SD_IP1.$LOCAL_SD_IP2\n";
   print UDHCPD_FILE "option  dns     192.168.$LOCAL_SD_IP1.$LOCAL_SD_IP2\n";
   print UDHCPD_FILE "option  domain  WIFICARD\n";
   print UDHCPD_FILE "option  lease   86400 #1 day of seconds\n";
   print UDHCPD_FILE "option  mtu     1500\n";
   close(UDHCPD_FILE);
   `$udhcpd_to_mtd`;
     
   system("cp /mnt/mtd/config/wsd.conf /etc/");
   system("rm /tmp/wsd.conf");
   if($WPA_KEY_LEN >= 8)
   {
       #system("cp /mnt/mtd/config/wsd.conf /mnt/mtd/config/wsd_backup.conf");
       #system("cp /mnt/mtd/config/wsd_backup.conf /etc/wsd_backup.conf");
       system("cp /mnt/mtd/config/wsd.conf /mnt/mtd/config/wsd_backup.conf && cp /mnt/mtd/config/wsd_backup.conf /etc/wsd_backup.conf");
   }

   open(INSUP_FILE, ">/etc/instant_upload.conf") or die("Could not open dnsd.conf");	
   print INSUP_FILE "GPlus-Enable : $GPLUS_ENABLE\n";
   print INSUP_FILE "GPlus-Name : $GPLUS_USER\n";
   print INSUP_FILE "GPlus-Password : $GPLUS_PWD\n";
   close(INSUP_FILE);
   `$instant_upload_to_mtd`;

   return 1;
}

# Whether the method used is GET or POST, store the parameters passed in $QueryString
if($ENV{'REQUEST_METHOD'} eq "POST") {
  read(STDIN, $QueryString, $ENV{'CONTENT_LENGTH'});
} else {
  $type = "display_form";
  $QueryString = $ENV{QUERY_STRING};
}

# split the QueryString at &'s to give you a list with each element with a format like "name=value"
@NameValuePairs = split (/&/, $QueryString);

# Split each NameValue pair, replace +'s by spaces, get the character equivalent of any data in hex (%XX) and finally, store it in an associative array
foreach $NameValue (@NameValuePairs) {
  ($Name, $Value) = split (/=/, $NameValue);
  $Value =~ tr/+/ /;
  $Value =~ s/%([\dA-Fa-f][\dA-Fa-f])/ pack ("C",hex ($1))/eg;
  $Form{$Name} = $Value;
}

	$CONFIG_STATE = $Form{CONFIG_STATE};
    $AP_SELECTED = $Form{SCAN_AP};
	$LOGIN_SET = $Form{Login_Enable};
	$LOGIN_USR = $Form{Yourname};
	$LOGIN_PWD = $Form{Yourpwd};
    $FTP_LOGIN_PATH = $Form{FTP_PATH};
	$FTP_LOGIN_User = $Form{FTP_User};
	$FTP_LOGIN_PWD  = $Form{FTP_PWD};
	$WIFI_SSID = $Form{WIFI_SSID};
	$Auto_WIFI = $Form{Auto_WIFI};
	$Auto_OFF = $Form{Auto_OFF};
	$Auto_MODE= $Form{wifi_mode};
	$WIFI_PS_MODE= $Form{wifi_ps_mode};
    $Host_WPA_KEY = $Form{Host_WPA_KEY};
    $ctr = $Form{ctr};
	$LOCAL_SD_IP1 = $Form{Local_IP1};
	$LOCAL_SD_IP2 = $Form{Local_IP2};
	$Sender_SD_IP1 = $Form{Sender_IP1};
	$Sender_SD_IP2 = $Form{Sender_IP2};
	$CHANNEL_SET = $Form{Channel_Num};
	$DOMAIN_NAME_1 = $Form{domain_name_1};
	$DOMAIN_NAME_2 = $Form{domain_name_2};
        
	$GPLUS_ENABLE = $Form{GPLUS_ENABLE};
	$GPLUS_SSID = $Form{GPLUS_SSID};
	$GPLUS_KEY = $Form{GPLUS_KEY};
	$GPLUS_USER = $Form{GPLUS_USER};
	$GPLUS_PASS = $Form{GPLUS_PASS};

        
print "Content-type: text/html", "\n\n";
print "<html><head>";
print "<meta http-equiv=\"content-language\" content=\"zh-tw\">\n";
print "<meta HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=utf-8\">\n";
print "<link href=\"/script/ts.css\" rel=\"stylesheet\" type=\"text/css\" />\n";
print "<title>Save-Config</title>";
print "<SCRIPT language=\"JavaScript\">
<!--
       function Disable_Host_WPA2()
	   {
	     window.alert(\"Host WPA2 Key need greater than or equal to eight characters\");
	   }
//-->
</SCRIPT>";	
#print "<SCRIPT language=\"JavaScript\">
#<!--
#       function Enable_Host_WPA2()
#	   {
#	     window.alert(\"Enable Host WPA2 function successfully\");
#	   }
#//-->
#</SCRIPT>";	  
print "</head>";
print "<body>";
#print "<b>AP selected: </b>$AP_SELECTED<br><br>";
print "<b>Administrato Account</b><br>";
#print "Login Enabled: $LOGIN_SET<br>";
#if($LOGIN_SET =~ /Yes/){
print "Username: $LOGIN_USR<br>";
print "Password: $LOGIN_PWD<br>";
#}else{
#$LOGIN_USR="";
#$LOGIN_PWD="";
#print "Login user: <br>";
#print "Login pwd : <br>";
#}
&AP_INFO_GET();
print "<br><b>Internet Hotspot Settings</b><br>";
my $count = 1;
for (my $i=1; $i<=3; $i++){
#    if (length trim($SSID[$i]) > 0) { 
		print "AP #$count<br>";
		print "&nbsp;&nbsp;&nbsp;&nbsp;SSID : $SSID[$i]<br>";
		print "&nbsp;&nbsp;&nbsp;&nbsp;KEY  : $KEY[$i]<br>";
		$count += 1;
#	}
}

#print "<br><b>FTP Information</b><br>";
#print "FTP Login IP : $FTP_LOGIN_PATH<br>";
#print "FTP Login User : $FTP_LOGIN_User<br>";
#print "FTP Login Password : $FTP_LOGIN_PWD<br>";

print "<br><b>WiFi Settings</b><br>";
#print "Auto WIFI : $Auto_WIFI<br>";
print "SSID : $WIFI_SSID<br>";
$WPA_KEY_LEN = length($Host_WPA_KEY);


if($WPA_KEY_LEN != 0 && $WPA_KEY_LEN >= 8 && $WPA_KEY_LEN <= 63)
{
#system("cp /etc/wsd.conf /etc/wsd_backup.conf");
#`$WPA2_Key_backup`;
#open(FHD, ">/mnt/mtd/config/hostapd.conf") or die("Could not open hostapd.conf");
#print FHD <<EndText;
#interface=mlan0
#logger_syslog=-1
#logger_syslog_level=2
#logger_stdout=-1
#logger_stdout_level=2
#debug=0
#dump_file=/tmp/hostapd.dump
#wpa=2
#wpa_key_mgmt=WPA-PSK
#wpa_pairwise=CCMP
#wpa_group_rekey=600
#wpa_gmk_rekey=86400
#channel=$CHANNEL_SET
#ssid=$WIFI_SSID
#wpa_passphrase=$Host_WPA_KEY
#EndText
#close(FHD);
#print "<SCRIPT language=\"JavaScript\">
#       <!--
#       Enable_Host_WPA2();
#       //-->
#       </SCRIPT>";
}
else 
{
    if($WPA_KEY_LEN == 0)
	{
	   system("rm /mnt/mtd/config/hostapd.conf"); 
	}
	else
	{
	   $Host_WPA_KEY="";
	   print "<SCRIPT language=\"JavaScript\">
       <!--
       Disable_Host_WPA2();
       //-->
       </SCRIPT>";
	   my $Host_keyfile = "/mnt/mtd/config/hostapd.conf";
       if(-e $Host_keyfile) 
       {
           system("rm /mnt/mtd/config/hostapd.conf");
       }
       else
       {
       } 
	}
}
#print "ctr : $ctr<br>";
print "WPA2 Key : $Host_WPA_KEY<br>";
print "Local IP Address : 192.168.$LOCAL_SD_IP1.$LOCAL_SD_IP2<br>";

print "<br><b>WiFi Options</b><br>";
if($Auto_OFF == 0) {
	print "Turn Off WiFi : Never <br>";
} else {
	print "Turn Off WiFi : $Auto_OFF seconds<br>";
}

if($Auto_MODE eq "DS") {
	print "Default Mode : Direct-Share <br>";
} elsif ($Auto_MODE eq "IN") {
	print "Default Mode : Internet <br>";
}

if($WIFI_PS_MODE eq "Yes") {
	print "Power Saving : Enable <br>";
} elsif ($WIFI_PS_MODE eq "No") {
	print "Power Saving : Disable <br>";
}

#print "Local  IP Address : 192.168.$LOCAL_SD_IP1.$LOCAL_SD_IP2<br>";
#print "Sender IP Address : 192.168.$Sender_SD_IP1.$Sender_SD_IP2<br>";
#print "Channel : $CHANNEL_SET<br>";
#print "Domain Name : $DOMAIN_NAME_1.$DOMAIN_NAME_2<br>";
#print "<br><b>Buzzer Setting</b><br>";
#if ($Form{buzzer_disable}){
#print "Buzzer Setup : Disable<br>";
#}else{
#print "Buzzer Setup : Enable<br>";
#}

#print "<br><b>Instant Upload Setting</b><br>";
#print "GPlus-Enable : $GPLUS_ENABLE <br>";
#print "GPlus-User : $GPLUS_USER <br>";
#print "GPlus-Password : $GPLUS_PWD<br>";
#print "GPlus-SSID : $GPLUS_SSID <br>";
#print "GPlus-Key  : $GPLUS_KEY <br>";




my $save_result = &save_config();
if ($save_result){
   print "<br><br><h4>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -- <I>System configureation file saved successfully. </I>--</h4><br>";
   print "<br><br><h4><I>After setting, please power-off your camera and reinsert the Wi-Fi SD card again. All changes will be updated. </I></hr><br>";

   system("/usr/bin/gen_hostapd_config.sh");
}
print "</body></html>";

