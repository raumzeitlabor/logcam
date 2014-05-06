#!/usr/bin/perl
use URI::Escape;
my $QUERY_STRING_decode;
my $input = $ENV{'QUERY_STRING'};

$QUERY_STRING_decode=uri_unescape("$input");

print "Content-type: text/html\n\n";
print "<html><head>";
print "<meta http-equiv=\"content-language\" content=\"zh-tw\">";
print "<meta HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=utf-8\">";
print "<title>$QUERY_STRING_decode</title>";

print "<SCRIPT language=\"JavaScript\">
<!--
function Special_characters()
{
window.alert(\"File path can't include %\");
}
//-->
</SCRIPT>";	
if($QUERY_STRING_decode=~/%/)
{
print "<SCRIPT language=\"JavaScript\">
<!--
Special_characters();
//-->
</SCRIPT>";
}
print "</head>\n";
print "<body>\n";
print "<h2>$QUERY_STRING_decode</h2>\n";
print "<P>";
print "<embed src=\"$input\" width=\"320\" height=\"256\" /></embed>";
print "</body></html>\n";


