#!/usr/bin/env bash

set -euo pipefail

# Usage: ./bootstrap-project.sh NEW_NAME
new_name=${1:?Usage: $0 NEW_NAME}
old_name="example_project"

if ! [[ $new_name =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
  printf 'Error: "%s" is not a valid Python module name\n' "$new_name" >&2
  exit 1
fi

# cleanup all .bak files on any exit
trap 'find . -type f -name "*.bak" -print0 | xargs -0 rm -f' EXIT INT TERM

for file in \
  AGENTS.md \
  compose.yml \
  tests/test_example.py \
  pyproject.toml \
  Dockerfile \
  README.md
do
  sed -i.bak "s/${old_name}/${new_name}/g" "$file"
done

mv "src/$old_name" "src/$new_name"
rm -rf src/*.egg-info

# Delete this script itself.
rm bootstrap-project.sh
# Sync again!
uv sync
git add :/
