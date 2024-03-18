#!/bin/bash

repo_name=$1
owner="YOUR_GITHUB_USERNAME_OR_ORG" # Adjust this to your username or organization

curl \
  -X DELETE \
  -H "Authorization: token $GH_PAT" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$owner/$repo_name

echo "Repository $repo_name has been deleted."
