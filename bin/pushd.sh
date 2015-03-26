#!/bin/sh
case "$1" in 
    [0-9]) pushd +$1 ;;
    *) pushd "$@"
esac > /dev/null
dirs | dirs.pl
