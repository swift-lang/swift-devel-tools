#!/bin/bash

set -e

SCRIPTDIR=$(cd $(dirname $0); pwd)

git checkout --detach
if git branch -D __TMP_MASTER 2> /dev/null; then
  :
fi
git checkout -b __TMP_MASTER remotes/github/master
$SCRIPTDIR/update.sh
git push github HEAD:master

$SCRIPTDIR/pushbranches.sh < $SCRIPTDIR/branches.txt
$SCRIPTDIR/pushtags.sh < $SCRIPTDIR/tags.txt
