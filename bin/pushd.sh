#!/bin/sh
case "$1" in 
    [0-9])
        n=$1
        eval `dirs | perl -e '
            my $n = '"$n"';
            my @x = split(" ", <>);
            my $top = $x[$n];  # new top
            $top =~ s=^\~/=$ENV{HOME}/=;
            print "popd +$n >/dev/null && pushd \"$top\" >/dev/null\n";
        '`
        ;;
    *) pushd "$@" > /dev/null
esac
if [[ $? = 0 ]]; then
    dirs -v | dirs.pl
fi
