#!/usr/bin/perl
use strict; use warnings;  # vim:ft=perl ff=unix:
sub get_size($);

# Read the output of "docker build" on stdin and write it to stdout with
# image sizes added to each " ---> " line that identifies a new image.
# It also shows how much the size increased from the previous image.

my $prev_size = undef;
while (<>) {
    if (!/ ---> ([0-9a-f]+)$/) {
        print;
        next;
    }
    my $id = $1;
    my $size = get_size($id);
    my $delta = defined($prev_size) && sprintf('  %+.1fM', $size - $prev_size);
    printf " ---> %s  %.1fM%s\n", $id, $size, $delta;
    $prev_size = $size;
}

exit;

sub get_size($) {
    my($id) = @_;
    my $x = `docker inspect --format '{{.VirtualSize}}' $id`;
    return eval($x) / 1000000;
}
