#!/bin/sh
case "$1" in 
    [0-9]) popd +$1 > /dev/null ;;
    '') popd > /dev/null ;;
    *) echo "Bad arg to pp: $1"; false ;;
esac
if [[ $? = 0 ]]; then
    dirs -v | dirs.pl
fi
