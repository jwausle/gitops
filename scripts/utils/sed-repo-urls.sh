#!/bin/zsh
SCRIPT_NAME=$(basename "$0")

GITHUB_TARGET_URL="$1"
GITHUB_SOURCE_URL="${GITHUB_SOURCE_URL:-"https://github.com/jwausle/gitops.git"}"

if [ -z "$GITHUB_TARGET_URL" ] ; then
  echo "Missing first param: <target-url>"
  exit 1
fi

for file in $(ack "$GITHUB_SOURCE_URL" -l --ignore-dir=.bak) ; do
  file_name=$(basename "$file")
  if [ "$file_name" == "$SCRIPT_NAME" ] ; then
    echo "Ignore the script '$SCRIPT_NAME' to be idempotent"
    continue
  fi
  sed -i.bak "s|$GITHUB_SOURCE_URL|$GITHUB_TARGET_URL|g" $file
done