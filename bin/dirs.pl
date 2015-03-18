#!/usr/bin/env perl
# pipe dirs thru this
my @x = split(' ', <>);
for (my $i = $#x; $i > 0; $i--) {
  printf "%d  %s\n", $i, $x[$i];
}
