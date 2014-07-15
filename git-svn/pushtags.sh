#!/bin/bash
set -e


if [ $# != 0 ]
then
  echo "Usage: $(basename $0)"
  echo "Push tags from svn remotes to git"
  echo "Reads tag info from stdin"
  exit 1
fi

while read line
do
  # Strip comments
  line=$(echo $line | sed 's/#.*$//')

  if [[ ! "$line" =~ ^[[:blank:]]*$ ]]
  then 
    svn_remote=$(echo "$line" | cut -d ' ' -f 1)
    svn_tag=$(echo "$line" | cut -d ' ' -f 2)
    git_tag=$(echo "$line" | cut -d ' ' -f 3)
    
    remote_tag="remotes/${svn_remote}/tags/$svn_tag"
    echo "Pushing tag $remote_tag to $git_tag"
    git tag -f $git_tag $remote_tag
    git push github $git_tag
  fi
done
