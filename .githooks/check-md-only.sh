#!/bin/sh
# Reads file paths (one per line) on stdin; fails if any is not allowed.
# Allowed: *.md, .gitignore, LICENSE, .githooks/*, .github/workflows/*.yml
bad=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  case "$f" in
    *.md|.gitignore|.gitattributes|LICENSE|.githooks/*|.github/workflows/*.yml) ;;
    *) echo "Not allowed (markdown only): $f"; bad=1 ;;
  esac
done
if [ "$bad" -ne 0 ]; then
  echo "This repo accepts only .md files (plus .gitignore, .gitattributes, LICENSE, .githooks/, .github/workflows/*.yml)."
  exit 1
fi
