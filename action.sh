#!/bin/bash

# Pull changes from another repository

set -u  # script fails if trying to access to an undefined variable

####### Inputs

DESTINATION_REPO_NAME="$1"
DESTINATION_FOLDER_PATH="$2"
DESTINATION_BRANCH="$3"
SOURCE_BRANCH="$4"
GITHUB_USERNAME="$5"
GITHUB_EMAIL="$6"

#######

REPO_URL="git://github.com/$DESTINATION_REPO_NAME"
DESTINATION_URL="https://github.com/$DESTINATION_REPO_NAME.git"

echo "Check if repo $REPO_URL exists"
git ls-remote "$REPO_URL" -q

if [[ $? -ne 0 ]]
then
    echo "The repository $DESTINATION_REPO_NAME does not exist."

    exit 1
fi

echo "Set git configurations"
git config user.name "$GITHUB_USERNAME"
git config user.email "$GITHUB_EMAIL"

echo "Get latest files for $DESTINATION_FOLDER_PATH"
git remote add -f source "$DESTINATION_URL" &> /dev/null
git checkout -b upstream "source/$DESTINATION_BRANCH"

git filter-branch --prune-empty --subdirectory-filter "$DESTINATION_FOLDER_PATH" "source/$DESTINATION_BRANCH"
# git subtree split -P "$DESTINATION_FOLDER_PATH" -b example
BRANCH_WITH_CHANGES="source/$DESTINATION_BRANCH"
git checkout "origin/$SOURCE_BRANCH"

echo "Check if exist changes"
if git diff "$SOURCE_BRANCH".."$BRANCH_WITH_CHANGES" -- ':!.github' &> /dev/null
then
    echo "Merging changes..."
    git merge -s recursive -Xtheirs "$BRANCH_WITH_CHANGES" --allow-unrelated-histories --no-edit

    echo "Pushing changes..."
    git push
else
    echo "Does not exist any changes."
fi
