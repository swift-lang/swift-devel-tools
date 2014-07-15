#!/bin/bash

set -e

SCRIPTDIR=$(cd $(dirname $0); pwd)

git init .
echo 

cat  >> .git/config <<EOF
[svn-remote "cog-svn"]
  url = https://svn.code.sf.net/p/cogkit/svn
  fetch = trunk:refs/remotes/cog-svn/trunk.before_move
  branches = branches/*:refs/remotes/cog-svn/*
  tags = tags/*:refs/remotes/cog-svn/tags/*

[svn-remote "swift-svn"]
  url = https://svn.ci.uchicago.edu/svn/vdl2
  fetch = trunk:refs/remotes/swift-svn/trunk
  branches = branches/*:refs/remotes/swift-svn/*
  tags = tags/*:refs/remotes/swift-svn/tags/*
EOF

git config svn.authorsfile $SCRIPTDIR/authors.txt

#Trunk moving stuff messed up history.  Fetch up until that revision, then
#rename trunk revs and explicitly fetch from that rev onwards.

git svn fetch -r 1:3713 cog-svn
sed -i 's/.before_move//' .git/config 
git svn fetch -r 3713:HEAD cog-svn
git svn fetch swift-svn
