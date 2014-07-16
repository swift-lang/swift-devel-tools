#!/bin/bash
set -e


usage() {
  echo "Usage: $(basename $0)"
  echo " -f: force push"
  echo "Push branches from svn remotes to git"
  echo "Reads branch info from stdin"
}

PUSH_FLAGS=""

while getopts "f" arg; do
  case $arg in
    f)
      PUSH_FLAGS+="-f"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

shift $((OPTIND-1))

if [ $# != 0 ]
then
  usage
  exit 1
fi

echo "Reading branch info..."

while read line
do
  # Strip comments
  line=$(echo $line | sed 's/#.*$//')

  if [[ ! "$line" =~ ^[[:blank:]]*$ ]]
  then 
    echo
    svn_remote=$(echo "$line" | cut -d ' ' -f 1)
    svn_branch=$(echo "$line" | cut -d ' ' -f 2)
    git_branch=$(echo "$line" | cut -d ' ' -f 3)
    
    remote_branch="remotes/${svn_remote}/$svn_branch"

    if git show-ref --verify --quiet refs/heads/${git_branch}
    then
      rev1=$(git rev-parse ${remote_branch})
      rev2=$(git rev-parse ${git_branch})
      if [ "$rev1" = "$rev2" ]
      then
        echo "${git_branch} already exists and matches ${remote_branch}."
      else
        echo "${git_branch} already exists and does not match ${remote_branch}. Abort."
        exit 1
      fi
    else
      git branch $git_branch $remote_branch
    fi
    echo "Pushing branch $remote_branch to $git_branch"
    git push ${PUSH_FLAGS} github $git_branch:$git_branch
  fi
done
