#!/bin/bash

# Pull changes from another repository

set -u  # script fails if trying to access to an undefined variable

####### Inputs

SOURCE_REPO_NAME="$1"
SOURCE_FOLDER_PATH="$2"
SOURCE_BRANCH="$3"
TARGET_BRANCH="$4"
GITHUB_USERNAME="$5"
GITHUB_EMAIL="$6"

#######

REPO_URL="git://github.com/$SOURCE_REPO_NAME"
DESTINATION_URL="https://github.com/$SOURCE_REPO_NAME.git"

echo "Check if repo $REPO_URL exists"
git ls-remote "$REPO_URL" -q

if [[ $? -ne 0 ]]
then
    echo "The repository $SOURCE_REPO_NAME does not exist."

    exit 1
fi

echo "Set git configurations"
git config user.name "$GITHUB_USERNAME"
git config user.email "$GITHUB_EMAIL"

echo "Get latest files for $SOURCE_FOLDER_PATH"
git remote add -f source "$DESTINATION_URL" &> /dev/null
git checkout -b upstream "source/$SOURCE_BRANCH"

git filter-branch --prune-empty --subdirectory-filter "$SOURCE_FOLDER_PATH" "source/$SOURCE_BRANCH"
# git subtree split -P "$SOURCE_FOLDER_PATH" -b example
BRANCH_WITH_CHANGES="source/$SOURCE_BRANCH"
git checkout "$TARGET_BRANCH"

echo "Check if exist changes"
if git diff "$TARGET_BRANCH".."$BRANCH_WITH_CHANGES" -- ':!.github'
then
    echo "Merging changes..."
    git merge -s recursive -Xtheirs "$BRANCH_WITH_CHANGES" --allow-unrelated-histories --no-edit

    echo "Pushing changes..."
    git push
else
    echo "Does not exist any changes."
fi
