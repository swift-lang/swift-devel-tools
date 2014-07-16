Scripts and other files for converting SVN history to git.

Initial Conversion Process
==========================
1. Make directory for repo, cd into it
        mkdir swift-merged.git
        cd swift-merged.git
2. Create git repo and fetch all svn history with git-svn
  - authors.txt contains the author mapping used
        /path/to/swift-devel-tools/git-svn/checkout.sh
3. Merge cog and svn into unified layout
        /path/to/swift-devel-tools/git-svn/mergetree.sh

Updating Checked-out branch
===========================
1. Apply new commits from SVN cog/swift repos to current branch
        /path/to/swift-devel-tools/git-svn/update.sh

Pushing branches and tags
=========================
1. Run from within git repo to push branches/tags specified in text files
          /path/to/swift-devel-tools/git-svn/pushtags.sh < /path/to/swift-devel-tools/git-svn/tags.txt
        /path/to/swift-devel-tools/git-svn/pushbranches.sh < /path/to/swift-devel-tools/git-svn/branches.txt 
