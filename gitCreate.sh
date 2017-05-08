#!/bin/bash
#
# Run this first
# git config --global github.user dfgit
# git config --global github.token <put your token here>

repo_name=$1

dir_name=`basename $(pwd)`
if [ "$repo_name" = "" ]; then
echo "Repo name (hit enter to use '$dir_name')?"
read repo_name
fi
echo "Creating REPO ${dir_name}"

if [ "$repo_name" = "" ]; then
repo_name=$dir_name
fi

username=`git config github.user`
if [ "$username" = "" ]; then
echo "Could not find username, run 'git config --global github.user <username>'"
invalid_credentials=1
fi

token=`git config github.token`
if [ "$token" = "" ]; then
echo "Could not find token, run 'git config --global github.token <token>'"
invalid_credentials=1
fi

if [ "$invalid_credentials" == "1" ]; then
exit 1
fi

echo -n "Creating Github repository '$repo_name' ..."
curl -u "$username:$token" https://api.github.com/user/repos -d '{"name":"'$repo_name'"}' 
echo " done."

echo "Need to add CDSW ssh key to add origin and push"
echo "git remote add origin git@github.com:$username/$repo_name.git "
echo "git push -u origin master "
# exit
echo -n "Pushing local code to remote ..."
git init
git add *
git commit -a -m 'Initial commit from gitCreate.sh'
git remote add origin git@github.com:$username/$repo_name.git # > /dev/null 2>&1
#
git push -u origin master # > /dev/null 2>&1
echo " done."

