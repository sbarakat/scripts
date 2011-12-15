#!/bin/bash

#
# Author: Sami Barakat <sami@sbarakat.co.uk>
# Date: 20/11/2011
#
# This script has been used to migrate a Mercurial repository to Git. There
# were extra complications as my Mercurial repo had several other projects
# in it that I didn't want to share and I only wanted to export the version
# history of one of the sub folders.
#
# For example my Mercurial repo directory structure was set out like so:
# my_project1/
#   project files
# my_project2/
#   project files
# my_project3/
#   project files
#
# The script below will clone the Mercurial repo, go back to the very first
# revision and check for the existence of the sub directory, in this case
# my_project1. It will copy those files over to the Git repo and commit the
# changes (using the same date and comment as the Mercurial repo). It will
# then move onto the next revision and repeat the whole process eventually
# creating a Git repo with only the changes that were done to my_project1.
#

# Set these values for Git
git config --global user.name "Firstname Lastname";
git config --global user.email your_email@youremail.com;
# The Mercurial repo to clone
HG_REPO=https://{username}@bitbucket.org/{username}/{reponame};
# the sub directory project to export to Git
SUB_DIR=my_project;
# Full path to Mercurial/Git repos. These will be created so should not exist
HG_DIR=/home/sami/hg_repo;
GIT_DIR=/home/sami/git_repo;

echo 'Creating git repositry';
mkdir $GIT_DIR;
cd $GIT_DIR;
git init;
cd ..;

echo 'Cloning mercurial repositry';
mkdir $HG_DIR;
cd $HG_DIR;
hg clone $HG_REPO $HG_DIR;

hg log --template "{rev}--{date|isodate}--{desc|firstline}\n" | tac | while read line
do
    REV=`echo $line | sed -e 's/--.*//'`;
    COMMENT=`echo $line | sed -e 's/.*--//'`;
    # Commit messages always started with "My Project 1:", remove that message
    COMMENT=`echo $COMMENT | sed -e 's/My Project 1: //'`;
    DATE=`echo $line | sed -e 's/.*--\(.*\)--.*/\1/'`;

    echo "Going to rev $REV";
    cd $HG_DIR;
    hg update --clean -r $REV > /dev/null;

    if [ -d "$SUB_DIR" ]; then

        # Remove any incriminating evidence from the source files (passwords,
        # emails, etc.). This line can be repeated for however many items need
        # to be removed from the source files
        find ./$SUB_DIR/ -type f -exec sed -i -e 's/supersecrectpassword/lalalala/g' {} \;;

        if ! diff -qr -x '.git' $HG_DIR/$SUB_DIR $GIT_DIR > /dev/null; then
            echo 'Commiting changes to GIT repo';
            rm -r $GIT_DIR/*;
            cp -rp $HG_DIR/$SUB_DIR/* $GIT_DIR;

            cd $GIT_DIR;
            export GIT_COMMITTER_DATE="$DATE";
            export GIT_AUTHOR_DATE="$DATE";

            git add *;
            git commit -a -m "$COMMENT" --date="$DATE";

            export GIT_COMMITTER_DATE="";
            export GIT_AUTHOR_DATE="";
        fi
    fi

    # Used for incremental debugging
    #if [ $REV -gt 142 ]; then exit 0; fi

done

exit 0;
