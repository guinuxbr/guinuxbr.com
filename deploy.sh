#!/bin/sh

# If a command fails then the deploy stops
set -e

echo "\033[0;32mDeploying updates to GitHub...\033[0m\n"

# Removing "docs" directory.
rm -rf docs

# Build the project.
hugo # if using a theme, replace with `hugo -t <YOURTHEME>`

# Copy CNAME file do "docs" directory
cp CNAME docs/

# Add changes to git.
git add .

# Commit changes.
echo "Add a commit message:"
read msg
if [ -n "$*" ]; then
	msg="$*"
fi
git commit -m "$msg"

# Push source and build repos.
git push