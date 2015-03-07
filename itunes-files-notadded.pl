#!/usr/bin/env perl
# Copyright © 2015 Kevin Spencer <kevin@kevinspencer.org>
#
# Permission to use, copy, modify, distribute, and sell this software and its
# documentation for any purpose is hereby granted without fee, provided that
# the above copyright notice appear in all copies and that both that
# copyright notice and this permission notice appear in supporting
# documentation.  No representations are made about the suitability of this
# software for any purpose.  It is provided "as is" without express or
# implied warranty.
#
################################################################################

use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use File::Find::Rule;
use HTML::Entities;
use URI::Escape;
use strict;
use warnings;

$Data::Dumper::Indent = 1;

our $VERSION = '0.2';

my $BASEDIR = '/Users/' . getpwuid($<) . '/Music/iTunes';
my $FILEDIR = $BASEDIR . '/iTunes Music';
my $XMLFILE = $BASEDIR . '/iTunes Music Library.xml';

my $files_in_library = {};
open(my $fh, '<', $XMLFILE) || die "Could not open $XMLFILE - $!\n";
while (<$fh>) {
    my $line = $_;
    if ($line =~ /<key>Location<\/key><string>file:\/\/localhost(.+)<\/string>/) {
        my $location_hash = md5_hex(decode_entities(uri_unescape($1)));
        $files_in_library->{$location_hash} = 1;
    }
}
close($fh);

my $count = 0;
for my $file (File::Find::Rule->file()->name('*.mp3','*.m4a')->in($BASEDIR)) {
    my $filename_on_disk_hash = md5_hex($file);
    if (! $files_in_library->{$filename_on_disk_hash}) {
        print "!!!$file\n";
        $count++;
    }
}

print "\nFound $count songs on disk not in the library\n";
