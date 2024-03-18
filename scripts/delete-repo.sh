#!/bin/bash

repo_name=$1
owner="BobrePatre" # Adjust this to your username or organization
GH_PAT="${GH_PAT}" # Make sure to replace this with your actual GitHub Personal Access Token

# Check if the repository exists
status_code=$(curl -o /dev/null -s -w "%{http_code}\n" -H "Authorization: token $GH_PAT" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/$owner/"$repo_name")

echo "$status_code is status code of repo"

if [ "$status_code" -eq 200 ]; then
  # The repository exists, proceed with deletion
  curl \
    -X DELETE \
    -H "Authorization: token $GH_PAT" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/$owner/"$repo_name"

  echo "Repository $repo_name has been deleted."
else
  # The repository does not exist
  echo "Repository $repo_name does not exist or the token lacks the required permissions."
fi
