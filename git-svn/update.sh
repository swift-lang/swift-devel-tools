#!/bin/bash

set -e

if [ $# != 0 ]
then
  echo "Usage: $(basename $0)"
  echo "Checks for and merges changes from svn remote trunks to current HEAD"
  exit 1
fi

HEAD_REF=$(git symbolic-ref HEAD 2>/dev/null)

# Currently only handle trunk
REMOTE_BRANCH_SUFFIX="trunk"

echo "Attempting to merge changes from svn to current HEAD: ${HEAD_REF}"

for svn_remote in cog-svn swift-svn
do
  URL=$(git config svn-remote.${svn_remote}.url)
  echo
  echo "SVN Remote: ${svn_remote} ${URL}"
  
  echo "Fetch from SVN remote ${svn_remote}"
  git svn fetch ${svn_remote}

  GIT_SVN_ID=$(git log | grep -F "git-svn-id: ${URL}" | head -n1 |
               grep -o -E "git-svn-id: [^ ]* [0-9a-f-]+")
  GIT_SVN_REV=$(echo ${GIT_SVN_ID} | grep -o "@[0-9]*" | sed 's/@//')
  
  remote_branch="remotes/${svn_remote}/${REMOTE_BRANCH_SUFFIX}"
  echo "Last SVN revision on current HEAD: r${GIT_SVN_REV}"

  # Get last commit merged
  git_rev=$(git log ${remote_branch} -n 1 \
                --fixed-strings --grep="${GIT_SVN_ID}" |
                head -n1 | sed 's/commit //')

  echo "Corresponding git rev on ${remote_branch} is ${git_rev}"
  remote_branch_rev=$(git rev-parse ${remote_branch})

  if [ "${remote_branch_rev}" = "${git_rev}" ]
  then
    echo "All revisions from ${remote_branch} already integrated into current HEAD"
    continue
  fi

  rev_range="${git_rev}..${remote_branch}"

  if [ $svn_remote = cog-svn ]
  then
    # Strip src/cog off paths, and replace with cogkit
    AM_P=3
    AM_DIR=cogkit
  elif [ $svn_remote = swift-svn ]
  then
    # Merge Swift changes to root
    AM_P=1
    AM_DIR=
  else
    echo "Unexpected remote $svn_remote"
    exit 1
  fi

  git format-patch --stdout ${rev_range} |
    git am -p ${AM_P} --directory=${AM_DIR}
done

echo "Changes have been successfully applied to current HEAD: ${HEAD_REF}"
echo "You can go ahead and push now if you want."

