#!/usr/bin/env bash
# PreToolUse (Edit|Write). Blocks edits to protected files.
input=$(cat); fp=$(echo "$input" | python3 -c "import sys,json;print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)
case "$fp" in
  *.env|*.env.*|*appsettings.Production.json|*/Migrations/*_*.cs)
    echo "BLOCKED: $fp is protected (secrets/prod config/committed migrations). Ask the human." >&2; exit 2;;
esac
exit 0
