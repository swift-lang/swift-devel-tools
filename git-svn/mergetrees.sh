#!/bin/sh

set -e

git checkout -b swift-trunk remotes/swift-svn/trunk
mkdir -p modules/swift
git mv $(ls -A | grep -v modules | grep -v .git ) modules/swift
git commit -a -m "Move Swift source into modules subdirectory before merge"

git checkout -b swift-unified-trunk remotes/cog-svn/trunk
git mv src/cog/* .
rmdir src/cog
rmdir src
git commit -a -m "Move CoG source into root before merge"
git merge swift-trunk -m "Merge CoG trunk and Swift trunk into unified tree"
