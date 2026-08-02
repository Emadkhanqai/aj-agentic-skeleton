#!/usr/bin/env bash
# PostToolUse (Edit|Write). Formats the touched file. Silent on failure — formatting must never block work.
input=$(cat); fp=$(echo "$input" | python3 -c "import sys,json;print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)
case "$fp" in
  *.cs) dotnet format --include "$fp" >/dev/null 2>&1 || true;;
  *.ts|*.html|*.scss|*.json) npx --no-install prettier --write "$fp" >/dev/null 2>&1 || true;;
esac
exit 0
