#!/bin/bash

# Pull changes from another repository

set -e  # if a command fails it stops the execution
set -u  # script fails if trying to access to an undefined variable

function git-remote-url-reachable {
    git ls-remote "$1" CHECK_GIT_REMOTE_URL_REACHABILITY &>/dev/null
}

####### region: Inputs

DESTINATION_REPO_NAME="$1"
DESTINATION_FOLDER_PATH="$2"
DESTINATION_BRANCH="$3"
GITHUB_USERNAME="$4"
GITHUB_EMAIL="$5"

####### endregion: Configurations

REPO_URL="git://github.com/$DESTINATION_REPO_NAME"
DESTINATION_URL="https://github.com/$DESTINATION_REPO_NAME.git"

if ! git-remote-url-reachable $REPO_URL
then
    echo "The repository $DESTINATION_REPO_NAME does not exist."

    exit 1
fi

echo "Set git configurations"
git config user.name "$GITHUB_USERNAME"
git config user.email "$GITHUB_EMAIL"

echo "Check if repo $DESTINATION_URL exists"
git remote add -f source "$DESTINATION_URL"
git checkout -b upstream "source/$DESTINATION_BRANCH"

echo "Get latest files for $DESTINATION_FOLDER_PATH"
git subtree split -P "$DESTINATION_FOLDER_PATH" -b example
git checkout master

echo "Check if exist changes"
if git diff master..example &>/dev/null
then
    echo "Merging changes..."
    git merge -s recursive -Xtheirs example --allow-unrelated-histories --no-edit

    echo "Pushing changes..."
    git push
else
    echo "Does not exist any changes."
fi
