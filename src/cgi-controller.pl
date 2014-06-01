#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../ext";

use CGI;
use URI::Escape;
use File::Find;   
use File::Basename;

use JSON::Tiny qw/encode_json/;

my $q = CGI->new;
print $q->header('application/json');

ctrl_list();
 
sub qstr {
    my $qstr = '';
    if ($ENV{'REQUEST_METHOD'}) {
        $qstr = $ENV{'QUERY_STRING'};
    } elsif ($ARGV[0]) {
        $qstr = $ARGV[0];
    }

    my %param = ();
    my @pairs = split(/&/, $qstr);

    foreach (@pairs) {
        my($key, $value) = split(/=/, $_, 2);
        next if !defined $key;
        $param{$key} = uri_unescape($value);
    }

    return \%param;
}

sub list_images {
    my @files = ();
    find({
        wanted => sub {
            -f && push @files, {
                fname => $_
            };
        },
    }, '.');
    return \@files;
}

sub ctrl_list {
    my $p = qstr;
    if (! defined $p->{'action'}) {
        print encode_json(list_images());
        return;
    } else {
        print encode_json("no action given");
    }
}
