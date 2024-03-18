#!/bin/bash

# Usage: ./manage-repo.sh <library_name> <output_dir> <commit_message>

library_name="$1"
output_dir="$2"
commit_message="$3"
owner="BobrePatre" # Change this to your GitHub username or organization
GH_PAT="${GH_PAT}" # Ensure GH_PAT is passed as an environment variable

# Check if the repository exists
repo_exists=$(curl -o /dev/null -s -w "%{http_code}\n" -H "Authorization: token $GH_PAT" https://api.github.com/repos/$owner/$library_name)

# Function to push changes to the repository
push_changes() {
  cd "$output_dir" || exit 1
  git init
  git config user.name "GitHub Actions"
  git config user.email "actions@github.com"
  git add .
  git commit -m "$commit_message"
  git branch -M main
  git remote add origin https://$owner:$GH_PAT@github.com/$owner/$library_name.git
  git push -u origin main
  cd - || exit 1
}

if [ "$repo_exists" -eq 200 ]; then
  echo "Repository $library_name already exists, updating..."
  tmp_clone_dir=$(mktemp -d)
  git clone https://github.com/$owner/$library_name.git "$tmp_clone_dir"
  rsync -av --exclude='.git' "$output_dir/" "$tmp_clone_dir/"
  push_changes "$tmp_clone_dir"
  rm -rf "$tmp_clone_dir"
else
  echo "Creating repository $library_name..."
  curl -u "$owner:$GH_PAT" https://api.github.com/user/repos -d "{\"name\":\"$library_name\"}"
  push_changes
fi
