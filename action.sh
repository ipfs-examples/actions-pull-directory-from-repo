#!/bin/bash

# Pull changes from another repository

set -u  # script fails if trying to access to an undefined variable

####### Inputs

DESTINATION_REPO_NAME="$1"
DESTINATION_FOLDER_PATH="$2"
DESTINATION_BRANCH="$3"
GITHUB_USERNAME="$4"
GITHUB_EMAIL="$5"

#######

REPO_URL="git://github.com/$DESTINATION_REPO_NAME"
DESTINATION_URL="https://github.com/$DESTINATION_REPO_NAME.git"

echo "Check if repo $REPO_URL exists"
if ! git ls-remote "$REPO_URL"
then
    echo "The repository $DESTINATION_REPO_NAME does not exist."

    exit 1
fi

echo "Set git configurations"
git config user.name "$GITHUB_USERNAME"
git config user.email "$GITHUB_EMAIL"

echo "Get latest files for $DESTINATION_FOLDER_PATH"
git remote add -f source "$DESTINATION_URL"
git checkout -b upstream "source/$DESTINATION_BRANCH"

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
