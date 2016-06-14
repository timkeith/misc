#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec::Functions qw(canonpath abs2rel catfile catdir);
use File::Basename qw(basename dirname);
use FindBin ();
use lib "$FindBin::Bin";
use Misc qw(assert note warning error fatal internal);
sub slashes($);
$| = 1;

#print "Buffers: @ARGV\n";

my $cwd = Misc::getcwd();
my $x = shift(@ARGV);
my $testmode = -f $x;
$testmode and $x = Misc::get($x);
#Misc::put('\temp\x.tmp', $x);
my @result = ();
for(split(/\t/, $x)) {
    /(.+?)\s*'(.*)'\s*(.*)/ or print "$_\n" and next;
    my($pre, $file, $post) = ($1, $2, $3);
    if ($file eq '') {
        $file = '.';
    } else {
        my $rel = Misc::subst(abs2rel(Misc::fullpath($file), $cwd), '^\w:' => '');
        $file = $rel if slashes($rel) < slashes($file);
    }
    push(@result, [ $pre, '"' . $file . '"', $post ]);
}
my $result = Misc::columnate(\@result);
chomp($result);
$result =~ s/\n/\t/g unless $testmode;
print $result;
exit;

sub slashes($) {
    local($_) = @_;
    return tr#[/\\]##;
}
