#!/usr/bin/perl
use URI::Escape;
use File::Find;   
use File::Basename;
 
my $pic_num = 0; 
my $pic_total=0;
my $pic_first=0;
my $www_dir;
my $line_href;
my $img_dir;
my $www_dir_encode;

sub getStrHex 
{
    local $filename = $_[0];
    local @myArray=unpack('C*', $filename);    
    local $myStringHex = '';
    local $c;
    
    foreach $c (@myArray) {
      $myStringHex .= sprintf ("%lx", $c) . ",";
    }
    return  $myStringHex;
}  

# www_dir and img_dir defined at print_dir 
sub print_thumb
{
    local $full_path = $_[1];
    local $dir = $_[0]; 
    local $line = basename($_[1]);    
	local $mirror_base = "/mnt/mtd/instant_uploaded";
	local $up_base = "/var/run/is/UP";
	local $upload_flag = 0;
	local $show_bar = 0;
	local $video_type = 0;
	local $init_prog_text ;
	local $init_prog_percent= 0;
   
    if( $line =~ /\.JPG/i || $line =~ /\.RAW/i || $line =~ /\.BMP/i || $line =~ /\.PNG/i  || $line =~ /\.GIF/i 
			||$line =~ /\.3FR/i ||$line =~ /\.ARI/i|| $line =~ /\.ARW/i||$line =~ /\.SRF/i||$line =~ /\.SR2/i
			||$line =~ /\.BAY/i||$line =~ /\.CRW/i||$line =~ /\.CR2/i||$line =~ /\.CAP/i||$line =~ /\.IIQ/i
			||$line =~ /\.EIP/i|| $line =~ /\.DCS/i||$line =~ /\.DCR/i||$line =~ /\.DRF/i||$line =~ /\.K25/i
			||$line =~ /\.KDC/i||$line =~ /\.DNG/i||$line =~ /\.ERF/i||$line =~ /\.FFF/i||$line =~ /\.MEF/i
			|| $line =~ /\.MOS/i||$line =~ /\.MRW/i||$line =~ /\.NEF/i||$line =~ /\.NRW/i||$line =~ /\.ORF/i
			||$line =~ /\.PEF/i||$line =~ /\.PXN/i||$line =~ /\.R3D/i||$line =~ /\.RAF/i|| $line =~ /\.RWL/i
			||$line =~ /\.DNG/i||$line =~ /\.RWZ/i||$line =~ /\.SRW/i||$line =~ /\.X3F/i 
			|| $line =~ /\.AVI/i || $line =~ /\.MOV/i || $line =~ /\.MP4/i ){            

		if ($line =~ /\.AVI/i || $line =~ /\.MOV/i || $line =~ /\.MP4/i ) {
			$video_type = 1;
		}

        if($pic_num == 0 || ($pic_num % 4==0)){
            print "<tr>";
        }
        $line_href=uri_escape("$line");
        while($www_dir=~/%20/)
        {
          $www_dir =~s/%20/ /;
        }
        $www_dir_encode=uri_escape("$www_dir");
        while($www_dir_encode=~/%2F/)
        {
          $www_dir_encode =~s/%2F/\//;
          #$www_dir_encode =~s/25//g;
        }
        $img_dir="\/www$www_dir_encode";  
		$upload_flag = 0;
                 
		if ($video_type == 1) {
			print "<td width=\"150\"><A href=$www_dir_encode/$line_href target=\"_blank\"><Img id=\"kimage$pic_num\" src=\"/cgi-bin/thumbnail_video?fn=$img_dir/$line_href\" width=\"120\" height=\"120\"></A>";                                       
		} else {
			print "<td width=\"150\"><A href=$www_dir_encode/$line_href target=\"_blank\"><Img id=\"kimage$pic_num\" src=\"/cgi-bin/thumbNail?fn=$img_dir/$line_href\" width=\"120\" height=\"120\"></A>";                                       
		}
        #print "<br><input type=\"checkbox\" id=\"kimage_$pic_total\" name=\"$line_href\">";   
        print "<br><A href=$www_dir_encode/$line_href target=\"_blank\">$line<br>"; 
#        print "<A href=\"/cgi-bin/wifi_download?fn=$line_href&fd=$img_dir\" target=\"_blank\">Download</A>";                      
#        print "<br><A href=\"/cgi-bin/preview_photo.cgi?$www_dir_encode/$line_href\" target=\"_blank\">&nbsp;&nbsp;Preview</A>";                                 
#		print "TEST $mirror_base/mnt$www_dir_encode/$line_href";
		if (-e "$mirror_base/mnt$www_dir_encode/$line_href") {
#print "<b>[Uploaded] </b><br>";
			$show_bar = 1;

			$init_prog_text="Uploaded";
			$init_prog_percent= 100;
		} elsif (-e "$up_base/mnt$www_dir_encode/$line_href") {
#print "<b>[Uploading] </b><br>";
			$show_bar = 1;
			$init_prog_text="Uploading";
			$init_prog_percent= 0;
		} else {
#print "<b>[Not Uploaded] </b><br>";
			$show_bar = 1;
			$init_prog_text="Not Uploaded";
			$init_prog_percent= 0;
		}
		if ( $show_bar == 1) {
			print "<div id=\"divProgress\" style=\"width:90%;height:0.3cm;display:\"\";\">";
			print "<span id=\"/mnt$www_dir_encode/$line_href/ProgressText\">$init_prog_percent%</span><br />";
#			print "	<div style=\"border:1px solid #000000;width:100%;\">";
			print "	<div style=\"border:0px;width:100%;\">";
			print "	<table id=\"/mnt$www_dir_encode/$line_href/ProgressBar\" align=\"left\" cellpadding=\"0\" cellspacing=\"0\" ";
#print "		style=\"width:0px; height:100%; border-width:1px; border-style:solid; border-color:#fff #555 #555 #fff;\">";
			print "		style=\"width:$init_prog_percent%; height:100%; border-width:1px; border-style:solid; border-color:#fff #555 #555 #fff;\">";
			print "   <tr>";
			print "   <td style=\"width:100%;background-color:#0000FF;\"> </td>";
			print "   </tr>";
			print "   </table>";
			print "   </div>";
			print "</div>";
		}

        print "</td>";                   

        if( $pic_num > 0 && ($pic_num % 4 == 3)){
            print "</tr>";                                   
        }                  
        $pic_num++;
        $pic_total++;                                
    }
}

# www_dir and img_dir is global var
sub print_dir
{
    local $dir = $_[0];
    local $DH;   
	local $pic_totol;

    $www_dir = $_[0];
    $www_dir =~ s/\/www//;
    $img_dir = $_[0]; 
    
    $pic_num=0;
    $pic_first=$pic_total;   

	$pic_total = 0;
    opendir($DH, $dir) or die $!;
    while (local $line = readdir($DH)) 
    {
        # Use a regular expression to ignore files beginning with a period
        next if ($line =~ m/^\./);

		if( $line =~ /\.JPG/i || $line =~ /\.RAW/i || $line =~ /\.BMP/i || $line =~ /\.PNG/i  || $line =~ /\.GIF/i 
			||$line =~ /\.3FR/i ||$line =~ /\.ARI/i|| $line =~ /\.ARW/i||$line =~ /\.SRF/i||$line =~ /\.SR2/i
			||$line =~ /\.BAY/i||$line =~ /\.CRW/i||$line =~ /\.CR2/i||$line =~ /\.CAP/i||$line =~ /\.IIQ/i
			||$line =~ /\.EIP/i|| $line =~ /\.DCS/i||$line =~ /\.DCR/i||$line =~ /\.DRF/i||$line =~ /\.K25/i
			||$line =~ /\.KDC/i||$line =~ /\.DNG/i||$line =~ /\.ERF/i||$line =~ /\.FFF/i||$line =~ /\.MEF/i
			|| $line =~ /\.MOS/i||$line =~ /\.MRW/i||$line =~ /\.NEF/i||$line =~ /\.NRW/i||$line =~ /\.ORF/i
			||$line =~ /\.PEF/i||$line =~ /\.PXN/i||$line =~ /\.R3D/i||$line =~ /\.RAF/i|| $line =~ /\.RWL/i
			||$line =~ /\.DNG/i||$line =~ /\.RWZ/i||$line =~ /\.SRW/i||$line =~ /\.X3F/i 
			|| $line =~ /\.AVI/i || $line =~ /\.MOV/i || $line =~ /\.MP4/i ){            
			$pic_total++;
		}
    
    }
    closedir($DH);

                                    
	if ($pic_total > 0) {
		print "<tr><td colspan=4 align=left>Folder > $www_dir &nbsp&nbsp - $pic_total files";
		print "</td></tr>";	
		opendir($DH, $dir) or die $!;
		while (local $line = readdir($DH)) 
		{
# Use a regular expression to ignore files beginning with a period
			next if ($line =~ m/^\./);

			print_thumb($dir, $line);	      
		}
		closedir($DH);

		print "<tr height=\"30\"><td colspan=4 align=left>";

#if ($pic_num > 0)
#{
#    print "<input type=\"button\" name=\"ASELECT_$pic_first\" id=\"ASELECT_$pic_first\" onclick=\"Selected_All($pic_total,$pic_first)\" VALUE=\"SELECT_ALL\">";
#    print "<input type=\"button\" name=\"DESELECT_$pic_first\" id=\"DESELECT_$pic_first\" onclick=\"Cancel_selected($pic_total,$pic_first)\" VALUE=\"CANCEL_ALL\">";		
#    print "<input type=\"button\" name=\"$www_dir_encode\" id=\"MDWNLD_APPLET_$pic_first\" onclick=\"MDWNLD_APPLET($pic_total,$pic_first)\" VALUE=\"Multi-download\">";
#}											
#print "<div name=\"$img_dir\" id=\"MDWNLD_DIV_$pic_first\"></div>";
		print "</td></tr>";
	}
}

sub scan_dir
{                
    local $dir = $_[0];
    local $DH;
    local $name = basename($dir);
    if ($name=~/199_WIFI/)
    {
    }
    else
    {     
        print_dir($dir);
        
        opendir($DH, $dir) or die $!;
        while (local $line = readdir($DH)) 
        {              
            next if ($line =~ m/^\./);
            local $file = "$dir/$line";
            # Use a regular expression to ignore files beginning with a period
            if (-d $file)
            {
                scan_dir($file);    
            }                   	    
        }
        closedir($DH);    
    }  
}
sub is_config{
	`/usr/bin/gen_is_config.sh /etc/json/is_wifi_list.json /tmp/is.conf`;
    open(my $CONFIG_FILE, "<", "/tmp/is.conf") or die("Could not open is.conf");	
    my ($USER_NAME,$EMAIL,$ACCESS_TOKEN);
	while( my $line = <$CONFIG_FILE> ){
        chomp($line);		
        if($line=~/user_name=(.*)/){		   		  
		   $USER_NAME=$1;   		   
        }
        if($line=~/email=(.*)/){		   		  
		   $EMAIL=$1;   		   
        }
        if($line=~/access_token=(.*)/){		   		  
		   $ACCESS_TOKEN=$1;   		   
        }
   }
   close(CONFIG_FILE);   
   return ($USER_NAME,$EMAIL,$ACCESS_TOKEN);
}
sub is_wifi_config{
	`/usr/bin/gen_is_config.sh /etc/json/is_wifi_list.json /tmp/is.conf`;
   open(my $CONFIG_FILE, "<", "/tmp/is.conf") or return 0;
   my ($i,$count);
   my ($AP_COUNT);

   $count = 0;
   while( my $line = <$CONFIG_FILE>){
       chomp($line);
	   if($line =~ /wifi_count=(.*)/){
	      $AP_COUNT = $1;
          $AP_FIND=1;		  
	   }
	   if( $line =~ /ssid$count=(.*)/){
	       $AP_INFO[$i]=$1;
		   $i++;
	   }
	   if( $line =~ /priority$count=(.*)/){
	       $AP_INFO[$i]=$1;
		   $i++;
		   $count++;
	   }
   }
   close(CONFIG_FILE);      
   return ($AP_COUNT);
}

sub gplus_enable{
    open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");	
	my ($GPLUS_INFO);
	while( my $line = <$CONFIG_FILE> ){
        chomp($line);		
        if($line=~/GPlus-Enable : (.*)/){		   		  
		   $GPLUS_INFO=$1;   		   
        }
   }
   close(CONFIG_FILE);   
   return ($GPLUS_INFO);
}
sub login_enable{
	open(my $CONFIG_FILE, "<", "/etc/wsd.conf") or die("Could not open wsd.conf");	
	my ($LOGIN_INFO);
	while( my $line = <$CONFIG_FILE> ){
		chomp($line);		
		if($line=~/Login-Set : (.*)/){				  
			$LOGIN_INFO=$1;			   
		}

	}
	close(CONFIG_FILE);   
	return ($LOGIN_INFO);
}
my $LOGIN_INFO=&login_enable();
my $GPLUS_INFO=&gplus_enable();
my @IS_INFO=&is_config();
my $IS_WIFI_INFO=&is_wifi_config();
print "Content-type: text/html\n\n";
print "<html>";
print "<head>";
print "<meta http-equiv=\"content-language\" content=\"zh-tw\">";
print "<meta HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=utf-8\">";
print "<title>Photo-View</title>";
print "<script type='text/javascript' src='../script/instant_upload.js'></script>\n";

if($GPLUS_INFO =~ /YES/) {
	print "<script type='text/javascript'> var timer_id = window.setInterval(getProgressInfo, 500); </script>\n";
}

if($LOGIN_INFO =~ /Yes/)
{
print "<script type=\"text/javascript\">
   if(document.cookie.length != 0)
       {}
   else{
         location.href=\"kcard_login.pl\";        
   } 
</script>";
}
print "<style>
<!--
body{
	background-color:#e0f1f4;
	margin-left:2em;
}
-->
</style>";
print "</head>";
print "<body>";
print "<h2>Instant Upload Information</h2>";

if($GPLUS_INFO =~ /YES/)
{
	print "<I><b> User Name</b></I> : $IS_INFO[0]<br>";
	print "<I><b> Email </b></I> : $IS_INFO[1]<br>";
	print "<I><b> Access Token</b></I> : $IS_INFO[2]<br>";
	print "<br><b>Wifi List</b><br>";
	for ( my $i=0; $i < $IS_WIFI_INFO; $i++){
		print "<b> AP $i </b><br>";
		print "<I><b>&nbsp&nbsp Name (SSID) : </b></I>$AP_INFO[$i*2]<br>";
		print "<I><b>&nbsp&nbsp Priority : </b></I>$AP_INFO[$i*2+1]<br>";
	}
} else {
	print "<I><b> Instant Upload is disabled. </b></I><br>";
}
print "<p><p>";

print "<form name=\"kcard_photo_form\"><DIV id=\"photo\"></DIV>";
print "<table border='0'>";
#---- push @directories, "/www/sd/DCIM/"; 
#print "<td colspan=4 align=left>Folder > DCIM </td>";                   
#---- find(\&wanted, @directories);
scan_dir("/www/sd");

print "</table>";
#print "<br>PS : Java plug-in need 1.7.0_03 above <br>";
print "</form>";
print "</body></html>";
