#!/bin/bash

set -e

# Check for and merge changes from svn remotes to current branch

HEAD_REF=$(git symbolic-ref HEAD 2>/dev/null)

echo "Attempting to merge changes from svn to current HEAD: ${HEAD_REF}"

for svn_remote in cog-svn swift-svn
do
  URL=$(git config svn-remote.${svn_remote}.url)
  echo
  echo "Checking ${svn_remote} remote at repo ${URL}"
  GIT_SVN_ID=$(git log | grep -F "git-svn-id: ${URL}" | head -n1 |
               grep -o -E "git-svn-id: [^ ]* [0-9a-f-]+")
  GIT_SVN_ID_SHORT=$(echo ${GIT_SVN_ID} |
                        sed -e 's/git-svn-id: //' -e 's/ [0-9a-z-]*$//')
  
  remote_trunk="remotes/${svn_remote}/trunk"
  echo "Last SVN revision on current HEAD: ${GIT_SVN_ID_SHORT}"

  # Get last commit merged
  git_rev=$(git log ${remote_trunk} -n 1 \
                --fixed-strings --grep="${GIT_SVN_ID}" |
                head -n1 | sed 's/commit //')

  echo "Corresponding git rev on ${svn_remote} is ${git_rev}"
  remote_trunk_rev=$(git rev-parse ${remote_trunk})

  if [ "${remote_trunk_rev}" = "${git_rev}" ]
  then
    echo "All revisions from ${svn_remote} already integrated into current HEAD"
    continue
  fi

  rev_range="${git_commit}..${remote_trunk}"

  echo "Fetching updates"
  git svn fetch ${svn_remote}

  if [ $svn_remote = cog-svn ]
  then
    # Strip src/cog off paths
    AM_P=3
    AM_DIR=
  elif [ $svn_remote = swift-svn ]
  then
    # Add modules/swift to paths
    AM_P=1
    AM_DIR=modules/swift
  else
    echo "Unexpected remote $svn_remote"
    exit 1
  fi

  git format-patch --stdout ${rev_range} |
    git am -p ${AM_P} --directory=${AM_DIR}
done

echo "Changes have been successfully applied to current HEAD: ${HEAD_REF}"
echo "You can go ahead and push now if you want."

