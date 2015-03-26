#!/usr/bin/env bash
# First do: git clone https://github.com/timkeith/misc.git
# Then run setup.sh
cd $(dirname $0)
dir=$(basename $(pwd))
for x in * .*; do
    if [[ $x = . || $x = .. || $x = .git || $x = *.swp ]]; then
        continue
    fi
    if [[ -h ../$x ]]; then
        : already a symlink
    elif [[ -e ../$x ]]; then
        echo "../$x already exists and is not a symlink"
    else
        echo "Creating link $x"
        ln -s $dir/$x ../$x
    fi
done
