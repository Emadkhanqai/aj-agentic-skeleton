#!/usr/bin/env bash
# Installs the native git pre-push hook into the current repo.
set -e
ROOT="$(git rev-parse --show-toplevel)"
SRC="$(dirname "$0")/pre-push"
cp "$SRC" "$ROOT/.git/hooks/pre-push"
chmod +x "$ROOT/.git/hooks/pre-push"
echo "Installed: $ROOT/.git/hooks/pre-push"
