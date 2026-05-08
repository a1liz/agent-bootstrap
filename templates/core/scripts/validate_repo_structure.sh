#!/usr/bin/env bash

set -euo pipefail

required_paths=(
  "docs/BOOTSTRAP_ADOPTION.md"
  "docs/OPERATIONS.md"
  "artifacts/runs"
  ".gitignore"
  "schemas"
)

for path in "${required_paths[@]}"; do
  if [[ ! -e "$path" ]]; then
    echo "missing required path: $path" >&2
    exit 1
  fi
done

echo "repo structure looks valid"
