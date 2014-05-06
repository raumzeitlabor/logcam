#!/usr/bin/perl
#
# file_upload.pl - Demonstration script for file uploads
# over HTML form.
#
# This script should function as is.  Copy the file into
# a CGI directory, set the execute permissions, and point


use CGI;
use strict;

my $PROGNAME = "kcard_upload.pl";

my $cgi = new CGI();
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
print "Content-type: text/html\n\n";
print "<html><head><title>Upload Form</title>";
print "<style>
<!--
body{
	background-color:#ffdee0;
}
-->
</style>";
print "<body>";
#
# If we're invoked directly, display the form and get out.
#
if($LOGIN_INFO =~ /No/)
{
if (! $cgi->param("button") ) {
	DisplayForm();
	exit;
}
}
else
{
  DisplayForm1();
}
#
# We're invoked from the form. Get the filename/handle.
#
my $upfile = $cgi->param('upfile');

#
# Get the basename in case we want to use it.
#
my $basename = GetBasename($upfile);
my $count = $basename;
$count = tr/a-z //;
if ($basename eq "" )   #to check null string
{
    #print "<h3>--------------Notice------------------<br>"; 
	#print "Please select the image file name.";
	#print "[System supports to upload *.jpg, *.bmp, *.gif, *.png.]<br></h3>"; 	
    exit;	
}

my $basename_src = $basename;
$basename =~ tr/a-z/A-Z/;
if( !($basename =~ /.GIF/ || $basename =~ /.JPG/ || 
      $basename =~ /.PNG/ || $basename =~ /.BMP/))
{
    print "<h3>--------------Notice------------------<br>"; 
	print "$basename_src can\'t upload to server.<br>"; 
	print "[System supports to upload *.jpg, *.bmp, *.gif, *.png.]<br></h3>"; 	
    exit;	
}else{
    #print "<h3>--------------Notice------------------<br>"; 
	#print "$basename_src upload to server.<br>"; 
	#print "[System supports to upload *.jpg, *.bmp, *.gif, *.png.]<br></h3>"; 	
    #exit;	
}
#
# At this point, do whatever we want with the file.
#
# We are going to use the scalar $upfile as a filehandle,
# but perl will complain so we turn off ref checking.
# The newer CGI::upload() function obviates the need for
# this. In new versions do $fh = $cgi->upload('upfile'); 
# to get a legitimate, clean filehandle.
#
no strict 'refs';
#my $fh = $cgi->upload('upfile'); 
#if (! $fh ) {
#	print "Can't get file handle to uploaded file.";
#	exit(-1);
#}

#######################################################
# Choose one of the techniques below to read the file.
# What you do with the contents is, of course, applica-
# tion specific. In these examples, we just write it to
# a temporary file. 
#
# With text files coming from a Windows client, probably
# you will want to strip out the extra linefeeds.
########################################################

#
# Get a handle to some file to store the contents
#
if (! open(OUTFILE, ">../DCIM/198_WIFI/$basename") ) {
	print "Can't open ..\/DCIM\/198_WIFI\/$basename for writing - $!";
	exit(-1);
}

# give some feedback to browser
print "<b>----------------Notice----------------------</b><br>";
print "<b><font color=\"blue\">Saving the file to DCIM/198_WIFI</font></b><br>";

#
# 1. If we know it's a text file, strip carriage returns
#    and write it out.
#
#while (<$upfile>) {
# or 
#while (<$fh>) {
#	s/\r//;
#	print OUTFILE "$_";
#}

#
# 2. If it's binary or we're not sure...
#
my $nBytes = 0;
my $totBytes = 0;
my $buffer = "";
# If you're on Windows, you'll need this. Otherwise, it
# has no effect.
binmode($upfile);
#binmode($fh);
while ( $nBytes = read($upfile, $buffer, 1024) ) {
	print OUTFILE $buffer;
	$totBytes += $nBytes;
}
close(OUTFILE);

#
# Turn ref checking back on.
#
use strict 'refs';

# more lame feedback
print "<b>thanks for uploading $basename ($totBytes bytes)</b><br><br>\n";	
print "<b><font color=\"red\">**Upload Successfully.....</font><br>";
print "</Body></html>";

##############################################
# Subroutines
##############################################

#
# GetBasename - delivers filename portion of a fullpath.
#
sub GetBasename {
	my $fullname = shift;

	my(@parts);
	# check which way our slashes go.
	if ( $fullname =~ /(\\)/ ) {
		@parts = split(/\\/, $fullname);
	} else {
		@parts = split(/\//, $fullname);
	}

	return(pop(@parts));
}

#
# DisplayForm - spits out HTML to display our upload form.
#
sub DisplayForm {
print <<"HTML";
<html>
<head>
<meta http-equiv="content-language" content="zh-tw">
<meta HTTP-EQUIV="content-type" CONTENT="text/html; charset=utf-8">
<title>Upload Form</title>
<script type=\"text/javascript\">
if(document.cookie.length != 0){
}
else{
      location.href=\"kcard_login.pl\";        
} 
</script>

<style>
<!--
body{
	background-color:#ffdee0;
}
-->
</style>
<script LANGUAGE="JavaScript" text="text/javascript">
function check(){

}
</script>
<body>
<h3>Please select a image file to upload. (*.bmp, *.jpg, *.gif, *.png)</h3>
<b><font color="red">(Maximum Siz: 50MB)</font></b>
<form name="upform" method="post" action="/cgi-bin/wifi_upload" enctype="multipart/form-data">
Enter a file to upload: <input type="file" id="upfile" name="upfile" width=\"200\"><br><br>
<input type="submit" name="button" value="Upload File">
</form>
HTML
}

sub DisplayForm1 {
print <<"HTML";
<html>
<head>
<meta http-equiv="content-language" content="zh-tw">
<meta HTTP-EQUIV="content-type" CONTENT="text/html; charset=utf-8">
<title>Upload Form</title>
<script type=\"text/javascript\">
if(document.cookie.length != 0){
}
else{
      location.href=\"kcard_login.pl\";        
} 
</script>

<style>
<!--
body{
	background-color:#ffdee0;
}
-->
</style>
<script LANGUAGE="JavaScript" text="text/javascript">
function check(){

}
</script>
<body>
<h3>Please select a image file to upload. (*.bmp, *.jpg, *.gif, *.png)</h3>
<b><font color="red">(Maximum Siz: 50MB)</font></b>
<form name="upform" method="post" action="/cgi-bin/wifi_upload" enctype="multipart/form-data">
Enter a file to upload: <input type="file" id="upfile" name="upfile" width=\"200\"><br><br>
<input type="submit" name="button" value="Upload File">
</form>
HTML
}
