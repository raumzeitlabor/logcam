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
my $name_width=350;
my $last_width=140;
my $size_width=60;
my $file_height=30;


sub get_last_modified_str
{
	my $file = shift();

	my $date = (stat($file))[9] || die "stat($file): $!\n";
	my $ori_date = localtime($date);
#my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($date);

#	return "($ori_date) $mday-$mon-$year $hour:$min:$sec";
	return $ori_date;
}
sub get_filesize_str
{
	my $file = shift();

	my $size = (stat($file))[7] || die "stat($file): $!\n";

	if ($size > 1099511627776)  #   TiB: 1024 GiB
	{
		return sprintf("%.2f TiB", $size / 1099511627776);
	}
	elsif ($size > 1073741824)  #   GiB: 1024 MiB
	{
		return sprintf("%.2f GiB", $size / 1073741824);
	}
	elsif ($size > 1048576)     #   MiB: 1024 KiB
	{
		return sprintf("%.2f MiB", $size / 1048576);
	}
	elsif ($size > 1024)        #   KiB: 1024 B
	{
		return sprintf("%.2f KiB", $size / 1024);
	}
	else                          #   bytes
	{
		return "$size byte" . ($size == 1 ? "" : "s");
	}
}
# www_dir and img_dir is global var
sub print_dir
{
    local $dir = $_[0];
    local $DH;   
    local $i=0; 
    local $folder_pic_counter=0; 
	local $show_dir;
    local $name = dirname($dir);
	local $filesize;
	local @dirset;
	local @fileset;
	local $color_switch = 0;

    $show_dir = $_[0];
    $show_dir =~ s/\/www\/sd//;
	
	print "<tr class=\"subt\">";
	print "   <td colspan=\"3\" class=\"subt\" > &nbsp;<b>$show_dir  --</b> </td>";
	print "</tr >\n";

	print "<tr >";
	print "<td height=\"$file_height\" width=\"$name_width\"><font size='3'>Name</font></a></td>\n";
	print "<td height=\"$file_height\" width=\"$last_width\"><font size='3'>Last modified</font> </td>\n"; 
	print "<td height=\"$file_height\" width=\"$size_width\"><font size='3'>Size</font> </td>\n"; 
	print "</tr >";

    opendir($DH, $dir) or die $!;

    # Show parent link
	if ($dir ne "/www/sd") {
		print "<tr >\n";
		print "<td height=\"$file_height\" width=\"$name_width\">\n";
		print "   <a href=\"/cgi-bin/file_list.pl?dir=$name\"><img src=\"/back.gif\" border='0'>Parent Directory</a></td>\n";
		print "<td height=\"$file_height\" width=\"$last_width\"> </td>\n"; 
		print "<td height=\"$file_height\" width=\"$size_width\" > </td>\n"; 
		print "</tr >\n";
	}

	local @files = reverse sort {lc $a cmp lc $b} readdir($DH);
    while (local $line = shift @files) {
		next if ($line eq "." || $line eq "..");
		if (-d "$dir/$line") {
			unshift(@dirset, $line);
		}else {
			unshift(@fileset, $line);
		}
	}
    closedir($DH);

	# Show directory first
    while (local $line = shift @dirset) {
		my $date = get_last_modified_str("$dir/$line");

		if ($color_switch == 0) {
			print "<tr BGColor=\"#E1E1E1\">";
			$color_switch = 1;
		}else {
			$color_switch = 0;
			print "<tr BGColor=\"#FFFFFF\">";
		}
		print "<td height=\"$file_height\" width=\"$name_width\">\n"; 
		print "<a style='text-decoration:none;color:black' href=\"/cgi-bin/file_list.pl?dir=$dir/$line\"> <img src=\"/dir.gif\" border='0'><font size='2'> $line </font></a>";
		print "</td>\n";
		print "<td height=\"$file_height\" width=\"$last_width\"><font size='2'> $date </font></td>\n"; 
		print "<td height=\"$file_height\" width=\"$size_width\" align=\"center\"><font size='2'> - </font></td>\n"; 
		print "</tr>\n";
    }

	# show files 
	while (local $line = shift @fileset) {
		my $filesize = get_filesize_str("$dir/$line");
		my $date = get_last_modified_str("$dir/$line");

		if ($color_switch == 0) {
			print "<tr BGColor=\"#E1E1E1\">";
			$color_switch = 1;
		}else {
			$color_switch = 0;
			print "<tr BGColor=\"#FFFFFF\">";
		}

		print "<td height=\"$file_height\" width=\"$name_width\">\n"; 
		print "<a style='text-decoration:none;color:black' href=\"/cgi-bin/wifi_download?fn=$line&fd=$dir \"><img src=\"/text.gif\" border='0'><font size='2'> $line</font> </a>\n ";
		print "</td>\n";
		print "<td height=\"$file_height\" width=\"$last_width\"><font size='2'>$date  </font></td>\n"; 
		print "<td height=\"$file_height\" width=\"$size_width\" align=\"right\"><font size='2'>$filesize  </font></td>\n"; 
		print "</tr>";
    }
}


# Whether the method used is GET or POST, store the parameters passed in $QueryString
if($ENV{'REQUEST_METHOD'} eq "GET") {
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

if (length($Form{dir}) > 0) {
	$list_dir = $Form{dir};
	$list_dir =~ s/\/$//;
} else {
	$list_dir = "/www/sd";
}
if ($list_dir !~ /\/www\/sd/) {
	print "Path error <br>";
	die("Path error");
}

if( $list_dir =~ /\.\./ ) {
	print "Path error <br>";
	die("Path error");
}

print "Content-type: text/html\n\n";
print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n";
print "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n";
print "<head>\n";
print "<link href=\"/script/ts.css\" rel=\"stylesheet\" type=\"text/css\" />\n";
print "<script type=\"text/javascript\" src=\"/script/fs.js\"></script>";
print "<meta http-equiv=\"content-language\" content=\"zh-tw\">\n";
print "<meta HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=utf-8\">\n";
print "<title>File Browse</title>\n";
print "</head>";
print "<body onload='get_file_list(\"$list_dir\")'>";
#print "<a href=\"#Sep 11 08:24:58 \">Sep 11 08:24:58 </a>";
#foreach (sort keys %ENV)
#{
#	  print "<b>$_</b>: $ENV{$_}<br>\n";
#}


print "<table width=100% border=0 >";
print "<tbody id='table_root'>";



#print_dir($list_dir);


print "</tbody>";
print "</table>";
print "</body></html>";
