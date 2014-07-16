#!/bin/bash
set -e


usage() {
  echo "Usage: $(basename $0)"
  echo " -f: force push"
  echo "Push tags from svn remotes to git"
  echo "Reads tag info from stdin"
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

echo "Reading tag info..."

while read line
do
  # Strip comments
  line=$(echo $line | sed 's/#.*$//')

  if [[ ! "$line" =~ ^[[:blank:]]*$ ]]
  then 
    echo
    svn_remote=$(echo "$line" | cut -d ' ' -f 1)
    svn_tag=$(echo "$line" | cut -d ' ' -f 2)
    git_tag=$(echo "$line" | cut -d ' ' -f 3)
    
    remote_tag="remotes/${svn_remote}/tags/$svn_tag"
    
    if git show-ref --verify --quiet refs/tags/${git_tag}
    then
      rev1=$(git rev-parse ${remote_tag})
      rev2=$(git rev-parse ${git_tag})
      if [ "$rev1" = "$rev2" ]
      then
        echo "${git_tag} already exists and matches ${remote_tag}."
      else
        echo "${git_tag} already exists and does not match ${remote_tag}. Abort."
        exit 1
      fi
    else
      git tag $git_tag $remote_tag
    fi

    echo "Pushing tag $remote_tag to $git_tag"
    git push ${PUSH_FLAGS} github $git_tag
  fi
done
