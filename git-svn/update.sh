
for svn_remote in cog-svn swift-svn
do
  URL=$(git config svn-remote.${svn_remote}.url)
  GIT_SVN_ID=$(git log | grep -F "git-svn-id: ${SWIFT_URL}" | head -n1)
 
  #TODO: get last commit merged
  git log remotes/${svn_remote}/trunk --grep=""

  #TODO: format-patch for these commits
  #TODO: am for these commits
done

