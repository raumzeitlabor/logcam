#!/usr/bin/perl

my $default_wsd="cp /home/mtd/config/wsd.conf /mnt/mtd/config";
my $default_wsd_backup="cp /home/mtd/config/wsd_backup.conf /mnt/mtd/config";
my $remove_hostapd="rm /mnt/mtd/config/hostapd.conf";
`$default_wsd`;
`$default_wsd_backup`;
`$remove_hostapd`;
system("cp /mnt/mtd/config/wsd.conf /etc/wsd.conf && cp /mnt/mtd/config/wsd_backup.conf /etc/wsd_backup.conf");

print "Content-type: text/html\n\n";
print "<html>";
print "<head>";
print "<meta http-equiv=\"content-language\" content=\"zh-tw\">";
print "<meta HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=utf-8\">";
print "<meta HTTP-EQUIV=\"refresh\" content=\"5; URL=kcard_edit_config.pl\">";
print "<title>Recovery</title>";
print "<style>
<!--
body{
	background-color:#ffdee0;
}
-->
</style>";
print "</head>";
print "<body>";
print "<br><br><h1>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; !! <I>Successful Recovery !!</I></h1><br>";
print "</body>";
print "</html>";