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
print "</head>\n";
print "<body>\n";
print "<h2>$QUERY_STRING_decode</h2>\n";


#f=$(echo "$QUERY_STRING" | sed -n 's/^.*f=\([^&]*\).*$/\1/p' | sed "s/%20/ /g")

print "<img src=\"$input\"  height=\"480\" width=\"640\"> ";


print "</body></html>\n";


