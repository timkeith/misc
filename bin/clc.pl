#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec::Functions qw(catfile catdir);
use File::Basename qw(basename);
use lib File::Basename::dirname __FILE__;
use lib catfile($ENV{ROOT}, 'bin');
use Misc qw(dirname assert note warning error fatal internal trace tracei);

my $cmd = "@ARGV";
print eval $cmd;
print "\n";
