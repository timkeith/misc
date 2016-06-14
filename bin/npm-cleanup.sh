#!/usr/bin/env bash
find ~ -name node_modules -print -prune \
    | xargs du -h -s \
    | sed "s#\\t$HOME/#\\t#" \
    | grep '^[0-9.]\+M' \
    | grep -v '	\.meteor/' \
    | grep -v '	\.npm/' \
    | grep -v '	node_modules' \
    | sort -nr \
    | awk '
        BEGIN { print "df -h ~ | tail -1\n"}
        { printf("rm -rf ~/%-60s  # %s\n", $2, $1) }
        END { print "df -h ~ | tail -1\n"}
    '
