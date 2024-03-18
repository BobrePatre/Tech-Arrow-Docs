#!/bin/bash

# Usage: ./manage-repo.sh <library_name> <output_dir> <commit_message>

library_name="$1"
output_dir="$2"
commit_message="$3"
owner="BobrePatre" # Change this to your GitHub username or organization
GH_PAT="${GH_PAT}" # Ensure GH_PAT is passed as an environment variable

# Function to push changes to the repository
push_changes() {
  # Navigate to the output directory
  cd "$1" || exit 1

  # Setup the user name and email for git commits
  git config user.name "GitHub Actions"
  git config user.email "actions@github.com"

  # Add all changes to git
  git add .

  # Check if there are any changes to commit
  if ! git diff --cached --quiet; then
    git commit -m "$commit_message"

    # Pull the latest changes from the remote repository and rebase
    git pull --rebase origin main

    # Push the changes back to the remote repository
    git push origin main
  else
    echo "No changes to commit for $library_name."
  fi

  # Navigate back
  cd - || exit 1
}

# Check if the repository exists
repo_exists=$(curl --silent --output /dev/null --write-out "%{http_code}" --head --fail --user "$owner:$GH_PAT" "https://api.github.com/repos/$owner/$library_name")

# If repository exists, clone and push changes
if [ "$repo_exists" -eq 200 ]; then
  echo "Repository $library_name already exists, updating..."
  tmp_clone_dir=$(mktemp -d)
  git clone --depth=1 "https://$owner:$GH_PAT@github.com/$owner/$library_name.git" "$tmp_clone_dir"

  # Synchronize the generated files into the temporary directory
  rsync -av --exclude='.git' "$output_dir/" "$tmp_clone_dir/"

  # Push changes
  push_changes "$tmp_clone_dir"

  # Remove the temporary directory
  rm -rf "$tmp_clone_dir"
elif [ "$repo_exists" -eq 404 ]; then
  echo "Creating repository $library_name..."
  curl --silent --user "$owner:$GH_PAT" "https://api.github.com/user/repos" -d "{\"name\":\"$library_name\"}"

  # Initialize a new git repository and push
  mkdir -p "$output_dir"
  cd "$output_dir" || exit 1
  git init
  git remote add origin "https://$owner:$GH_PAT@github.com/$owner/$library_name.git"
  push_changes "$output_dir"
  cd -
else
  echo "Failed to check if repository exists. HTTP status: $repo_exists"
  exit 1
fi
