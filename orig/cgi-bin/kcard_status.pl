#!/usr/bin/perl
my $HWDEV="mlan0";
my $if_net="/sbin/ifconfig $HWDEV";
my $iw_net="/bin/iwconfig $HWDEV > /tmp/iwconfig_maln0.txt";
my $Host_Channel = &Channel();
my $WPA2_Channel = "/bin/iwconfig $HWDEV channel $Host_Channel"; 
`$WPA2_Channel`;
my $iwlist_channel="/bin/iwlist $HWDEV channel > /tmp/iwlist_channel.txt";
my $dhcp_list="/usr/bin/dumpleases -f /var/lib/misc/udhcpd.lease > /tmp/dhcpd.lease";
`$dhcp_list`;

sub ifconfig_info
{
    my($LAN_MAC,$LAN_IP,$LAN_MASK); 

	
    if (`$if_net`=~/^.*HWaddr(.*)/) {	
    $LAN_MAC=uc($1);
    }

    if (`$if_net`=~/inet addr:(.*)\ Bcast.*/) {
    $LAN_IP=$1;
    }
   
    if (`$if_net`=~/.*Mask:(.*)/) {
    $LAN_MASK=$1;
    }

    return ($LAN_MAC, $LAN_IP, $LAN_MASK);
}
sub wireless_info
{
     if ( -f "/tmp/iwconfig_maln0.txt"){
	     
	 }else{
	     `$iw_net`;
	 }
     open(my $WIRELESS_FILE, "<", "/tmp/iwconfig_maln0.txt") or die("Could not open iwconfig_maln0.txt");
  
     my ($WLAN_SSID, $WLAN_CHANNEL, $WLAN_MODE, $WLAN_MAC);
	     
     while( my $line = <$WIRELESS_FILE> ){
        chomp($line);
        if ($line=~/$HWDEV     (.*)\ ESSID:*/){
        $WLAN_MODE=$1;
		}        
		
		if ($line=~/Access Point: (.*)\ Bit*/) {  #for AP mode
        $WLAN_MAC=$1;
		last;		
        }
		if ($line=~/Cell: (.*)\ Bit*/) {  #for ad-hoc mode
        $WLAN_MAC=$1;
		last;		
        }
		
		
        if ($line=~/^.*ESSID:"(.*)\"  Nickname.*/) {	
        $WLAN_SSID=uc($1);
		}             		
     }
     close(WIRELESS_FILE);
	 
	  if ( -f "/tmp/iwlist_channel.txt"){
	     
	 }else{
	     `$iwlist_channel`;
	 }
	 
	 open(my $WIRELESS_FILE, "<", "/tmp/iwlist_channel.txt") or die("Could not open iwlist_channel.txt");
	 while( my $line = <$WIRELESS_FILE> ){
        chomp($line);		
		if($line=~/^.*GHz \(Channel (.*)\)/){
        $WLAN_CHANNEL=uc($1);
        last;		
        }            
     }
     close(WIRELESS_FILE);
	 
	 return ($WLAN_SSID, $WLAN_CHANNEL, $WLAN_MODE, $WLAN_MAC);
}
sub firmware_version
{
     open(my $VER_FILE, "<", "/etc/version.txt") or die("Could not open version.txt");
  
     my ($PRODUCT, $VERSION, $BUILD_DATE, $REVISION);
	     
     while( my $line = <$VER_FILE> ){
        chomp($line);        
        if($line=~/Product Name     : (.*)/){
		$PRODUCT=$1;
		}
        if($line=~/Firmware Version : (.*)/){
		$VERSION=$1;
		}
		if($line=~/Build Date       : (.*)/){
		$BUILD_DATE=$1;
		}
		if($line=~/Revision         : (.*)/){
		$REVISION=$1;
		last;
		}
     }
     close(VER_FILE);
	 
	 return ($PRODUCT, $VERSION, $BUILD_DATE, $REVISION);
} 
sub ts_version 
{
     open(my $VER_FILE, "<", "/ts_version.inc") or die("Could not open ts_version.inc");
  
     my ($BUILD_DATE, $REVISION);
	     
     while( my $line = <$VER_FILE> ){
        chomp($line);        
		if($line=~/Build Date : (.*)/){
			$BUILD_DATE=$1;
		}
		if($line=~/Revision : (.*)/){
			$REVISION=$1;
			last;
		}
     }
     close(VER_FILE);
	 
	 return ($BUILD_DATE, $REVISION);
}
sub net_info
{
     open(my $VER_FILE, "<", "/var/run/net.info") or die("Could not open ts_version.inc");
  
     my ($MODE,$USER_MODE);
	     
     while( my $line = <$VER_FILE> ){
        chomp($line);        
		if($line=~/mode=(.*)/){
			$MODE=$1;
			if ($MODE =~ /server/){
				$USER_MODE="Direct Share";
			}
			if ($MODE =~ /client/){
				$USER_MODE="Internet";
			}
			if ($MODE =~ /is/){
				$USER_MODE="Instant Setup";
			}
			if ($MODE =~ /iu/){
				$USER_MODE="Instant Upload";
			}
			last;
		}
     }
     close(VER_FILE);
	 
	 return ($USER_MODE);
}
sub dhcp_info 
{
     open(my $DHCP_FILE, "<", "/tmp/dhcpd.lease") or die("Could not open dhcpd.lease");
  
     my ($WLAN_MAC,$IP_ADDR,$HOST_NAME,$EXPIRE_IN);
	 my @sec_array;
	 my $count = 0;
#	print ">>>> dhcp_info <<<<<";
	     
     while( my $line = <$DHCP_FILE> ){
        chomp($line);
        if ($line=~/(\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(\S+)\s+(\S+).*/) {
			$WLAN_MAC=$1;
			$IP_ADDR=$2;
			$HOST_NAME=$3;
			$EXPIRE_IN=$4;

			$sec_array[$count][0] = $HOST_NAME;
			$sec_array[$count][1] = $IP_ADDR;
			$sec_array[$count][2] = $WLAN_MAC;
#$sec_array[$count][3] = $4;
			$count++;
		}        
     }
     close(DHCP_FILE);
	 
	 return @sec_array;
}

sub Channel{
    open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");
    my($Host_Channel);
    while( my $line = <$CONFIG_FILE>){
        chomp($line);
           if($line =~ /Channel : (.*)/){
            $Host_Channel = $1;
           }
   }
   close(CONFIG_FILE);      
   return ($Host_Channel);
}

sub login_enable{
    open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");	
	my ($LOGIN_INFO);
	while( my $line = <$CONFIG_FILE> ){
        chomp($line);		
        if($line=~/Login-set : (.*)/){		   		  
		   $LOGIN_INFO=$1;   		   
        }
		
   }
   close(CONFIG_FILE);   
   return ($LOGIN_INFO);
}

my @LAN_INFO = &ifconfig_info();
my @WLAN_INFO = &wireless_info();
my @NET_INFO = &net_info();
my @SYS_VERSION = &firmware_version();
my @TS_VERSION = &ts_version();
my $LOGIN_INFO=&login_enable();
print "Content-type: text/html\n\n";
print "<html>";
print "<head>";
print "<meta http-equiv=\"content-language\" content=\"zh-tw\">\n";
print "<meta HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=utf-8\">\n";
print "<link href=\"/script/ts.css\" rel=\"stylesheet\" type=\"text/css\" />\n";
print "<title>Network-Config</title>\n";
my @DHCP_INFO = &dhcp_info();
if($LOGIN_INFO =~ /Yes/)
{
print "<script type=\"text/javascript\">
   if(document.cookie.length != 0){
      	      	   
   }else{
         //if( confirm(\"Please login first!!\"))
             location.href=\"kcard_login.pl\";
         //else
           //  location.href=\"../page.html\";
   } 
</script>";
}
print "</head>";
print "<body>";
print "<h2>Information</h2>";
print "<table border=\"1\" width=\"600\"><tbody>";
print "<tr class=\"subt\">";
print "   <td colspan=\"2\" class=\"subt\" > <b>LAN</b> </td>";
print "</tr >";
print "<tr >";
print "   <td width=\"250\" align=\"right\"><I><b> MAC Address</b></I> :</td> <td align=\"right\"> $LAN_INFO[0]</td>";
print "</tr >";
print "<tr >";
print "   <td width=\"250\" align=\"right\"><I><b>  IP Address</b></I> :</td> <td align=\"right\"> $LAN_INFO[1]</td>";
print "</tr >";
print "<tr >";
print "   <td width=\"250\" align=\"right\"><I><b> Subnet Mask</b></I> :</td> <td align=\"right\"> $LAN_INFO[2]</td>";
print "</tr >";
print "</tbody></table>";


print "<br>";

print "<table border=\"1\" width=\"600\"><tbody>";
print "<tr class=\"subt\">";
print "   <td colspan=\"2\" class=\"subt\"> <b>Firmware</b> </td>";
print "</tr >";

#print "<I><b>   Product Name</b></I> : $SYS_VERSION[0]<br>";
print "<tr >";
print "   <td width=\"250\" align=\"right\"><I><b>   Version :</td> <td align=\"right\"> </b></I>$TS_VERSION[1] </td>";
print "</tr >";
print "<tr >";
print "   <td width=\"250\" align=\"right\"><I><b>   Build Date :</td> <td align=\"right\"> </b></I>$TS_VERSION[0]</td>";
print "</tr >";
print "</tbody></table>";
#print "<I><b>   Revision</b></I> : $SYS_VERSION[3]<br>";

print "<br>";

print "<table border=\"1\" width=\"600\"><tbody>";
print "<tr class=\"subt\">";
print "   <td colspan=\"2\" class=\"subt\" > <b>Wireless</b> </td>";
print "</tr >";
print "<tr >";
print "   <td width=\"250\" align=\"right\"><I><b>        Mode :</td> <td align=\"right\"> </b></I>$NET_INFO[0]</td>";
print "</tr >";
print "<tr >";
print "   <td width=\"250\" align=\"right\"><I><b> Name (SSID) :</td> <td align=\"right\"> </b></I>$WLAN_INFO[0]</td>";
print "</tr >";
print "<tr >";
print "   <td width=\"250\" align=\"right\"><I><b>     Channel :</td> <td align=\"right\"> </b></I>$WLAN_INFO[1]</td>";
print "</tr >";
#print "<tr >";
#print "   <td width=\"250\" align=\"right\"><I><b> MAC Address :</td> <td align=\"right\"> </b></I>$WLAN_INFO[3]</td>";
#print "</tr >";
print "</tbody></table>";


if ($NET_INFO[0] =~ /Direct\ Share/) {
	print "<br>";
	print "<table border=\"1\" width=\"600\"><tbody>";
	print "<tr class=\"subt\">";
	print "   <td colspan=\"4\" class=\"subt\" > <b>Wireless Client</b> </td>";
	print "</tr >";
	print "<tr >";
	print "   <td width=\"300\" align=\"left\"><I><b> Host Name </b></I></td>";
	print "   <td width=\"150\" align=\"left\"><I><b> IP Address </b></I></td>";
	print "   <td width=\"150\" align=\"left\"><I><b> Mac Address </b></I></td>";
#	print "   <td width=\"100\" align=\"left\"> Expires in </td>";
	print "</tr >";
	foreach my $food (@DHCP_INFO) {
		print "<tr >";
		foreach my $food2 (@$food) {
			print "   <td align=\"left\"> $food2 </td>";
		}
		print "</tr >";
	}
	print "</tbody></table>";
}

print "</body>";
print "</html>";
