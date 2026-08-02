#!/usr/bin/env bash
# PreToolUse (Bash). Blocks dangerous commands; gates new dependencies behind a
# human-maintained approvals file (invariant #7).
input=$(cat); cmd=$(echo "$input" | python3 -c "import sys,json;print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)

deny='rm -rf|git push --force|git push -f|git reset --hard|--dangerously-skip-permissions'
if echo "$cmd" | grep -qE "$deny"; then
  echo "BLOCKED by policy (invariants): $cmd" >&2; exit 2
fi

# The approvals file is human-only: block shell writes to it
if echo "$cmd" | grep -q "approved-packages" && echo "$cmd" | grep -qE '>>|> |tee |sed -i|echo '; then
  echo "BLOCKED: .claude/approved-packages.txt is human-maintained; the agent may not write to it." >&2; exit 2
fi

askdep='dotnet add package|npm install |npm i |yarn add|pnpm add|ng add '
if echo "$cmd" | grep -qE "$askdep"; then
  appr=".claude/approved-packages.txt"
  pkgs=$(echo "$cmd" | sed -E 's/.*(dotnet add package|npm install|npm i |yarn add|pnpm add|ng add)//' \
        | tr ' ' '\n' | grep -vE '^-|^[0-9.]+$|^$')
  if [ -f "$appr" ] && [ -n "$pkgs" ]; then
    ok=1
    for p in $pkgs; do
      base="$p"
      # strip trailing @version (preserve npm scopes like @angular/core)
      case "$p" in
        @*@*) base="${p%@*}";;
        @*) base="$p";;
        *@*) base="${p%%@*}";;
      esac
      grep -qixF -- "$base" "$appr" || { ok=0; echo "Not approved: $base" >&2; }
    done
    [ "$ok" = "1" ] && exit 0
  fi
  echo "Dependency requires human approval (invariant #7): ask the user to add the package name(s) to .claude/approved-packages.txt, then retry." >&2
  exit 2
fi
exit 0
