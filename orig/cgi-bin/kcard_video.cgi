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
 
print "Content-type: text/html\n\n";
print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n";
print "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n";
print "<head>\n";
print "<meta http-equiv=\"content-language\" content=\"zh-tw\">\n";
print "<meta HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=utf-8\">\n";
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
print "<body>";
print "<form name=\"kcard_video_form\" ><DIV id=\"photo\"></DIV>";
print "<table border='0' width=\"100%\">";
scan_dir("/www/sd");

print "<script>function Cancel_selected(img_total,img_num){
for(var i=parseInt(img_num); i<parseInt(img_total); i++){
    img_id = \"kimage_\"+i;
    var icheckbox=document.getElementById(img_id);
    icheckbox.checked = false;       
}    
}</script>";
print "<script>function MDWNLD_APPLET(img_total,img_num){
var download_selected=\"\"; 
var download_string=\"\";
var dnld_status=\"\";
var selectFile=\"SelectFile_\"+img_num;
var check_num=0;
for(var i=parseInt(img_num); i<parseInt(img_total); i++){
    img_id = \"kimage_\"+i;
    var icheckbox=document.getElementById(img_id);
    if(icheckbox.checked == true){
	     check_num++;
         download_selected+=icheckbox.getAttribute('name')+\"&\";		 
    }
}
if(check_num > 0){  
	 DIV_id = \"MDWNLD_DIV_\"+img_num;
	 var DIV = document.getElementById(DIV_id);	
 	 DIV.innerHTML = \"<APPLET id=\'Applet_\"+img_num+\"'\"+ \"MAYSCRIPT ARCHIVE='\/multi_download_decode.jar' CODE='download_multi_decode.class' WIDTH='300' HEIGHT='35'><PARAM NAME=test VALUE=20></APPLET>\";	  	  	      
 	 DIV.innerHTML = \"<APPLET id=\'Applet_\"+img_num+\"'\"+ \"MAYSCRIPT ARCHIVE='\/multi_download_decode.jar' CODE='download_multi_decode.class' WIDTH='300' HEIGHT='35'><PARAM NAME=test VALUE=20></APPLET>\";	  
     
         applet_run2 = \"Applet_\"+img_num;
 	 var applet_run = document.getElementById(applet_run2);
 	 applet_run.set_URL_String(\"http://\"+document.links[0].hostname);
 	 applet_run.set_DNLD_FILE(download_selected);	
 	 var object_tmp=document.getElementById(\"MDWNLD_APPLET_\"+img_num);      
 	 applet_run.set_www_dir(object_tmp.getAttribute('name'));
 	 object_tmp= document.getElementById(\"MDWNLD_DIV_\"+img_num);	 	  
 	 applet_run.set_img_dir(object_tmp.getAttribute('name'));
 	 applet_run.set_pic_first(img_num);
 	 applet_run.set_pic_total(img_total);
}	  
}</script>";
print "<script>function Selected_All(img_total,img_num){
for(var i=parseInt(img_num); i<parseInt(img_total); i++){
    img_id = \"kimage_\"+i;
    var icheckbox=document.getElementById(img_id);
    icheckbox.checked = true;        
}    
}</script>";
print "<script> function dnld_show_str(dnld_obj,dnld_str){
     document.all(dnld_obj).innerHTML=dnld_str;			
}</script>";
print "<script>function show_str(msg_str){
/* get select items */
window.alert(msg_str);
}</script>";

print "</table><center>";
print "</center></form>";
print "</body></html>";
