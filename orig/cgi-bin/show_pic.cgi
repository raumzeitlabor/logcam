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
my @photoarray;

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
	local $temp_str;
   
    	if( $line =~ /\.AVI$/i || $line =~ /\.MOV$/i || $line =~ /\.MP4$/i ){            
        if($pic_num == 0 || ($pic_num % 5==0)){
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

		print "<td align=\"center\">";
		print "<table border=\"0\" width=\"150\"  cellspacing=\"0\" cellpadding=\"0\">";
		print "<tr><td class=\"album-back\" align=\"center\" width=\"150\" height=\"100\">";
		print        "<A href=$www_dir_encode/$line_href class=\"info\" target=\"_blank\">";
		print "			<span> $line </span>";
		print "			<div class=\"album-pic\"><Img id=\"kimage$pic_num\" alt=\"$line\" src=\"/cgi-bin/thumbnail_video?fn=$img_dir/$line_href\"></div>";
		print "      </A>";
		print "</td></tr>";                                       

        print "<tr><td aligh=\"center\" width=\"150\" height=\"30\">";
		print "<div style=\"overflow:hidden;width:150;height:30;text-align:center\">";
		print "<input type=\"checkbox\" id=\"kimage_$pic_total\" name=\"$line_href\">";   
		if (length($line) <= 12) {
			print "$line";
		}else {
			$temp_str = $line;
			$temp_str = substr($temp_str,0,12);
			print "$temp_str...";
		}
		print "</div>";
		print "</td></tr>"; 
        print "<tr><td align=\"center\" width=\"150\">";
		print "    <A href=\"/cgi-bin/wifi_download?fn=$line_href&fd=$img_dir\" target=\"_blank\">Download</A>";
		print "<br>&nbsp";
		print "</td></tr>";                      
		print "</table>";

#        print "<br><A href=\"/cgi-bin/preview_video.cgi?$www_dir_encode/$line_href\" target=\"_blank\">&nbsp;&nbsp;Preview</A>";                                 
        print "</td>";                   
        if( $pic_num > 0 && ($pic_num % 5 == 4)){
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
    local $i=0; 
    local $number=0; 
    local $show_dir=0; 
	local $folder_pic_counter=0;

    $www_dir = $_[0];
    $www_dir =~ s/\/www//;
    $img_dir = $_[0]; 
    $show_dir = $_[0];
    $show_dir =~ s/\/www\/sd//;
   
    $pic_num=0;
    $pic_first=$pic_total;   
    local @array=();
                                    
    opendir($DH, $dir) or die $!;
    while (local $line = readdir($DH)) 
    {
        if ($line =~ /\.(avi|mpeg|mp4|mpg|mov)$/i) {
			$folder_pic_counter++;
		}
    }
    closedir($DH);

	if ($folder_pic_counter == 0) {
		return;
	}
	print "<tr class=\"subt\">";
	print "   <td colspan=\"5\" class=\"subt\" > &nbsp;<b>$show_dir  -- $folder_pic_counter files </b> </td>";
	print "</tr >";

    opendir($DH, $dir) or die $!;
	local @files = sort readdir($DH);
    while (local $line = shift @files) {
        # Use a regular expression to ignore files beginning with a period
        next if ($line =~ m/^\./);
    
		$array[$i]=$line;
		$i++;

    #	print_thumb($dir, $line);	      
    }
    @photoarray = reverse(@array);
    $number=$#photoarray;
    	#print_thumb($dir, $photoarray[1]);
    for($i=0; $i<=$#photoarray; $i++) {
		print_thumb($dir, $photoarray[$i]);
    }
    closedir($DH);
    
#    print "<tr><td colspan=4 align=left>";
#    
#    if ($pic_num > 0)
#    {
#        print "<input type=\"button\" name=\"ASELECT_$pic_first\" id=\"ASELECT_$pic_first\" onclick=\"Selected_All($pic_total,$pic_first)\" VALUE=\"SELECT_ALL\">";
#        print "<input type=\"button\" name=\"DESELECT_$pic_first\" id=\"DESELECT_$pic_first\" onclick=\"Cancel_selected($pic_total,$pic_first)\" VALUE=\"DESELECT_ALL\">";		
#        print "<input type=\"button\" name=\"$www_dir_encode\" id=\"MDWNLD_APPLET_$pic_first\" onclick=\"MDWNLD_APPLET($pic_total,$pic_first)\" VALUE=\"DOWNLOAD_SELECTED\">";
#    }											
#    print "<div name=\"$img_dir\" id=\"MDWNLD_DIV_$pic_first\"></div>";
#    print "</td></tr>";
    print "<tr><td colspan=5 > <hr /></td></tr>";
}

sub scan_dir
{                
    local $dir = $_[0];
    local $DH;
    local $name = basename($dir);
    #if ($name=~/199_WIFI/)
    #{
    #               }
    #else
    {     
        print_dir($dir);
        
        opendir($DH, $dir) or die $!;
		local @files = sort readdir($DH);
        while (local $line = shift @files) {
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
my $LOGIN_INFO=&login_enable();

# Whether the method used is GET or POST, store the parameters passed in $QueryString
if($ENV{'REQUEST_METHOD'} eq "GET") {
  $QueryString = $ENV{QUERY_STRING};
}

# split the QueryString at &'s to give you a list with each element with a format like "name=value"
@NameValuePairs = split (/&/, $QueryString);

foreach $NameValue (@NameValuePairs) {
  ($Name, $Value) = split (/=/, $NameValue);
  $Value =~ tr/+/ /;
  $Value =~ s/%([\dA-Fa-f][\dA-Fa-f])/ pack ("C",hex ($1))/eg;
  $Form{$Name} = $Value;
}
 
if (length($Form{dir}) > 0) {
	$list_dir = $Form{dir};
	$list_dir =~ s/\/$//;
} else {
	$list_dir = "/www/sd/DCIM";
}

print "Content-type: text/html\n\n";
print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n";
print "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n";
print "<head>\n";
print "<meta http-equiv=\"content-language\" content=\"zh-tw\">\n";
print "<meta HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=utf-8\">\n";
print "<script type=\"text/javascript\" src=\"/script/tslist.js\"></script>";
print "<link href=\"/script/ts.css\" rel=\"stylesheet\" type=\"text/css\" />\n";
print "<title>Video-View</title>\n";
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


print "</head>";
print "<body onload='get_file_list(\"$list_dir\")'>";
print "<center><div id=\"progress\" class=\"progress\" align=\"center\"> </div></center>";
print "<form name=\"kcard_video_form\" >";
print "<table border='0' width=\"100%\" >";
print "<tbody id='table_root'>";

#scan_dir("/www/sd");


print "</tbody>";
print "</table><center>";
print "</center></form>";
print "</body></html>";
