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

SOURCE_REPO_URL="https://github.com/$SOURCE_REPO_NAME.git"

echo "Check if repo $SOURCE_REPO_URL exists"
git ls-remote "$SOURCE_REPO_URL" -q

if [[ $? -ne 0 ]]
then
    echo "The repository $SOURCE_REPO_NAME does not exist."

    exit 1
fi

echo "Update git configuration"
git config user.name "$GITHUB_USERNAME"
git config user.email "$GITHUB_EMAIL"

echo "Get latest files for $SOURCE_FOLDER_PATH"
BRANCH_WITH_CHANGES="source/$SOURCE_BRANCH"

git remote add -f source "$SOURCE_REPO_URL"
git fetch source
git checkout -b upstream "$BRANCH_WITH_CHANGES"

echo "Squelching git filter-branch warning"
export FILTER_BRANCH_SQUELCH_WARNING=1

git filter-branch --prune-empty --subdirectory-filter "$SOURCE_FOLDER_PATH" "$BRANCH_WITH_CHANGES"
git checkout "$TARGET_BRANCH"

echo "Check if the example has changed"
if git diff "$TARGET_BRANCH".."$BRANCH_WITH_CHANGES" --exit-code -- ':!.github'
then
    echo "The example has not changed"
else
    echo "Merging changes..."
    git reset --hard "$BRANCH_WITH_CHANGES"

    echo "Pushing changes..."
    git push -f
fi
