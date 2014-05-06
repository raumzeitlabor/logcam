#!/usr/bin/perl

use strict;
use warnings;

use URI::Escape;
use File::Find;   
use File::Basename;

use JSON::Tiny;
 
sub q {
    my $query_string = '';
    if ($ENV{'REQUEST_METHOD'}) {
          $query_string = $ENV{'QUERY_STRING'};
    } elsif ($ARGV[0]) {
          $query_string = $ARGV[0];
    }

    my %param;
    my @pairs = split(/&/, $query_string);

    foreach (@pairs) {
        my($key, $value) = split(/=/, $_, 2);
        next if !defined $key;
        $param{$key} = uri_unescape($value);
    }

    return \%param;
};

sub list_images {
    find({ wanted => \&process, follow => 1 }, '.');
};

sub ctrl_list {
};
