#!/bin/bash
# tag-client-libs.sh

repo_name=$1
new_tag=$2

# Убедитесь, что GH_PAT экспортирован как переменная окружения
echo "Tagging $repo_name with $new_tag..."
gh api -X POST /repos/"$repo_name"/git/refs \
  -f ref="refs/tags/$new_tag" \
  -f sha="$(gh api /repos/"$repo_name"/git/refs/heads/main | jq -r '.object.sha')" \
  --silent

if [ $? -eq 0 ]; then
  echo "Successfully tagged $repo_name with $new_tag."
else
  echo "Failed to tag $repo_name with $new_tag."
fi
