#!/usr/bin/env bash
#find ~ -name .meteor -type d -prune -print | sed 's#^(.*)$#rm -rf &/local#'
df -h ~
find ~ -path '*/.meteor/local' -type d -prune -print | xargs rm -rf
df -h ~
