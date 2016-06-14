#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec::Functions qw(catfile catdir);
use File::Basename qw(basename);
use lib File::Basename::dirname __FILE__;
use lib catfile($ENV{ROOT}, 'bin');
use Misc qw(dirname assert note warning error fatal internal trace tracei);
sub get_header($$);
sub incr($$$);
$| = 1;

#my $NOTE_LOG = $ENV{HOME} . '/bin/note.log';
#my $log = Misc::do_open('>', $NOTE_LOG);
#print $log "root1 = $ENV{'ROOT'}\n";
#print $log "root2 = ", (File::Basename::dirname File::Basename::dirname __FILE__), "\n";
#close($log);
my $ROOT = $ENV{ROOT} || File::Basename::dirname File::Basename::dirname __FILE__;
my $NOTES = catfile($ROOT, 'notes', '<year>', '<mon>.txt');

my $OPT = Misc::getopt(
    {args => 0, exclusive => 'mon,next,prev'},
    "
Edit notes file, default is: $NOTES",
    'year=i<year>' => 'Use <year> instead of current year',
    'mon=s<mon>' => 'Use <mon> instead of current mon',
    'next' => 'Use next month instead of this one',
    'prev' => 'Use prev month instead of this one',
);

my $mon = Time::localtime::localtime->mon + 1;
my $year = Time::localtime::localtime->year + 1900;
if (defined(my $m = $OPT->mon)) {
    $mon = Misc::mon2num($m);
}
if (defined(my $y = $OPT->year)) {
    if ($y < 100) {
        $y += 2000;
    }
    $y < 2000 || $y >= 2100 and fatal "Bad year: " . $OPT->year;
    $year = $y;
}
($mon, $year) = incr(+1, $mon, $year) if $OPT->next;
($mon, $year) = incr(-1, $mon, $year) if $OPT->prev;

my $notes = Misc::subst($NOTES, '<mon>' => sprintf("%02d", $mon), '<year>' => $year);
Misc::mkdirs(dirname($notes));
-e $notes or Misc::put($notes, get_header($mon, $year));
note "File: $notes";
chdir(dirname($notes));

my @opt = ("let g:page_prefix='NOTES - '", "set shiftwidth=2");
my @args = ('--servername', 'NOTES',
    '--remote-tab-silent', '+$', '+tabmove', $notes);  # move new tab to end
Misc::run_vim2(\@opt, \@args);

exit;

sub get_header($$) {
    my($mon, $year) = @_;
    my($nm, $ny) = incr(+1, $mon, $year);
    my($pm, $py) = incr(-1, $mon, $year);
    my $header = sprintf("=== Notes for %s %d\n", Misc::num2mon($mon), $year);
    $header .= sprintf("  %02d.txt - %s %d\n", $pm, Misc::num2mon($pm), $py);
    $header .= sprintf("  %02d.txt - %s %d\n", $nm, Misc::num2mon($nm), $ny);
    return $header . "\n";
}

# increment (mon, year) by delta months
sub incr($$$) {
    my($delta, $mon, $year) = @_;
    $mon += $delta;
    while ($mon > 12) {
        $year += 1;
        $mon -= 12;
    }
    while ($mon < 1) {
        $year -= 1;
        $mon += 12;
    }
    return ($mon, $year);
}
