#!/usr/bin/env perl
use strict;
use warnings;

# pipe dirs thru this
local $/ = undef;
my @x = split('\n', <>);
for (my $i = $#x; $i >= 0; $i--) {
  print $x[$i], "\n";
}
