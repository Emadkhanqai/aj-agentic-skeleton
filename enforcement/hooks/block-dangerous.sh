#!/usr/bin/env bash
# PreToolUse (Bash). Blocks dangerous commands + unapproved dependency adds (invariant #7).
input=$(cat); cmd=$(echo "$input" | python3 -c "import sys,json;print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)
deny='rm -rf|git push --force|git push -f|git reset --hard|--dangerously-skip-permissions'
askdep='dotnet add package|npm install |npm i |yarn add|pnpm add'
if echo "$cmd" | grep -qE "$deny"; then
  echo "BLOCKED by policy (invariants): $cmd" >&2; exit 2
fi
if echo "$cmd" | grep -qE "$askdep"; then
  echo "Dependency change requires explicit human approval in this session (invariant #7). State the package, version, and why; wait for approval." >&2; exit 2
fi
exit 0
