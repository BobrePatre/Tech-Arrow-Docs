#!/bin/bash

# Usage: ./manage-repo.sh <library_name> <output_dir> <commit_message>

library_name="$1"
output_dir="$2"
commit_message="$3"
owner="BobrePatre" # Change this to your GitHub username or organization
GH_PAT="${GH_PAT}" # Ensure GH_PAT is passed as an environment variable

echo "Checking if $library_name repository exists..."
if curl --silent --output /dev/null --head --fail "https://github.com/$owner/$library_name"; then
  echo "Repository $library_name already exists, updating..."
  # Создаем временную директорию для клонирования и обновления репозитория
  tmp_clone_dir=$(mktemp -d)
  git clone https://BobrePatre:"$GH_PAT"@github.com/$owner/"$library_name".git "$tmp_clone_dir"

  # Синхронизируем сгенерированные файлы во временную директорию
  rsync -av --exclude='.git' "$output_dir/" "$tmp_clone_dir/"

  cd "$tmp_clone_dir" || exit 1
  git config user.name "GitHub Actions"
  git config user.email "actions@github.com"
  git add .
  if ! git diff --cached --exit-code; then
    git commit -m "$commit_message"
    git pull --rebase origin main
    git push origin main
  else
    echo "No changes to commit for $library_name."
  fi
  # Удаляем временную директорию
  rm -rf "$tmp_clone_dir"
else
  echo "Creating repository $library_name..."
  curl -u "$owner:$GH_PAT" https://api.github.com/user/repos -d "{\"name\":\"$library_name\"}"

  # Инициализация и первый коммит в новом репозитории
  cd "$output_dir" || exit 1
  git init
  git config user.name "GitHub Actions"
  git config user.email "actions@github.com"
  git add .
  git commit -m "$commit_message"
  git branch -M main
  git remote add origin https://BobrePatre:"$GH_PAT"@github.com/BobrePatre/"$library_name".git
  git push -u origin main
fi