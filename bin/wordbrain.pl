#!/usr/bin/env perl

sub found($);
sub gen($$$);
sub get_words();

my $length = 6;
my $show_letters = 3;
my $letters = [qw(?
    b l e l
    w r b a
    e o u d
    t l l d
)];


my $WORDS = get_words();
my $used = [(0) x 17];

my $adj = [
    [],                            #0
    [2, 5, 6],                     #1
    [1, 3, 5, 6, 7],               #2
    [2, 4, 6, 7, 8],               #3
    [3, 7, 8],                     #4
    [1, 2, 6, 9, 10],              #5
    [1, 2, 3, 5, 7, 9, 10, 11],    #6
    [2, 3, 4, 6, 8, 10, 11, 12],   #7
    [3, 4, 7, 11, 12],             #8
    [5, 6, 10, 13, 14],            #9
    [5, 6, 7, 9, 11, 13, 14, 15],  #10
    [6, 7, 8, 10, 12, 14, 15, 16], #11
    [7, 8, 11, 15, 16],            #12
    [9, 10, 14],                   #13
    [9, 10, 11, 13, 15],           #14
    [10, 11, 12, 14, 16],          #15
    [11, 12, 15],                  #16
];

my $all = {};
my $count = {};
for my $start (1..16) {
    gen('', $start, $length);
}
print "$show_letters-letter prefixes of $length-letter words\n";
for my $prefix (sort keys %$count) {
    my $c = $count->{$prefix};
    if ($c > 1) {
        printf "%s  %d\n", $prefix, $c;
    } else {
        printf "%s\n", $prefix;
    }
}

exit;

sub found($) {
    my($word) = @_;
    my $n = $show_letters || $length;
    my $prefix = substr($word, 0, $n);
    $count->{$prefix}++;
}

# add to $curr, starting at $pos, till we get to this length
sub gen($$$) {
    my($curr, $pos, $length) = @_;
    $curr .= $letters->[$pos];
    if (length($curr) == $length) {
        if ($WORDS->{$curr} && !$all->{$curr}) {
            $all->{$curr} = 1;
            found($curr);
        }
    } else {
        $used->[$pos] = 1;
        for my $a (@{$adj->[$pos]}) {
            if (!$used->[$a]) {
                gen($curr, $a, $length);
            }
        }
        $used->[$pos] = 0;
    }
}

sub get_words() {
    my $words = {};
    open(my $in, '<', '/usr/share/dict/american-english') or die "Error reading word list: $!";
    while (<$in>) {
        if (/^[a-z]{3,}$/) {
            chomp;
            $words->{$_} = 1;
        }
    }
    close($in);
    return $words;
}
