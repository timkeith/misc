#!/usr/bin/env perl

# compile perl, putting output into a file
use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin";
use Misc qw(assert note warning error fatal);
sub check($);
$| = 1;
my $opt = Misc::getopt(
    {args => 1},
    '<perl-file>
Check perl file for compile-time errors.',
    'out|o=s<output-file>' => 'put errors in output-file',
);
my($perl) = @ARGV;
my $out_fh = $opt->out ? Misc::do_open('>', $opt->out) : \*STDOUT;
my $st = 0;
if(-d $perl) {
    my @files = grep(/\.(pl|pm)$/, Misc::get_dir($perl));
    for my $file (@files) {
        $st |= check($file);
    }
} else {
    $st |= check($perl);
}
exit($st);

sub check($) {
    my($file) = @_;
    my $full = Misc::subst(Misc::fullpath($file), '[\\/]+' => '\\');
    my $cmd = 'perl -c ';
    if($full =~ /(.*\\+lib)\\+(.*)\.pm$/i) {
        my($lib, $mod) = ($1, $2);
        $mod =~ s/\\/::/g;
        $cmd .= qq{-I$lib -e "use $mod"};
    } else {
        $cmd .= "'-I..;../..' $file";
    }
    my $in = Misc::do_open('-|', "$cmd 2>&1");
    my $st = 0;
    while(<$in>) {
        m/ syntax OK$/ and next;
        s/\r//;
        s/(.*) at (.+?) line (\d+)/$2($3) : $1/;
        print $out_fh $_;
        $st = 1;
    }
    return $st;
}
