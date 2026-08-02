#!/usr/bin/env bash
# PreToolUse (Bash). Blocks dangerous commands; gates NEW dependencies behind a
# human-maintained approvals file (invariant #7). Plain restores always pass.
input=$(cat); cmd=$(echo "$input" | python3 -c "import sys,json;print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)

deny='rm -rf|git push --force|git push -f|git reset --hard|--dangerously-skip-permissions'
if echo "$cmd" | grep -qE "$deny"; then
  echo "BLOCKED by policy (invariants): $cmd" >&2; exit 2
fi

# Approvals file is human-only: block shell writes to it
if echo "$cmd" | grep -q "approved-packages" && echo "$cmd" | grep -qE '>>|> |tee |sed -i|echo '; then
  echo "BLOCKED: .claude/approved-packages.txt is human-maintained; the agent may not write to it." >&2; exit 2
fi

askdep='dotnet add package|npm install|npm i |yarn add|pnpm add|ng add '
if echo "$cmd" | grep -qE "$askdep"; then
  # Extract package tokens: text after the keyword, stop at command chaining, drop flags/versions
  seg=$(echo "$cmd" | sed -E 's/.*(dotnet add package|npm install|npm i |yarn add|pnpm add|ng add)//' | sed 's/&&.*//;s/;.*//;s/|.*//')
  pkgs=$(echo "$seg" | tr ' ' '\n' | grep -vE '^-|^[0-9.^~]+$|^$')
  # Plain restore (npm install / npm ci with no package names) → always allowed
  [ -z "$pkgs" ] && exit 0

  appr=".claude/approved-packages.txt"
  ok=1
  for p in $pkgs; do
    base="$p"
    case "$p" in
      @*@*) base="${p%@*}";;   # @scope/name@version → @scope/name
      @*)   base="$p";;
      *@*)  base="${p%%@*}";;  # name@version → name
    esac
    match=0
    if [ -f "$appr" ]; then
      while IFS= read -r line; do
        line="${line%%#*}"; line="$(echo "$line" | tr -d '[:space:]')"
        [ -z "$line" ] && continue
        case "$line" in
          *\*) pref="${line%\*}"; case "$base" in "$pref"*) match=1;; esac;;
          *)   [ "$base" = "$line" ] && match=1;;
        esac
      done < "$appr"
    fi
    [ "$match" = "1" ] || { ok=0; echo "Not approved: $base" >&2; }
  done
  [ "$ok" = "1" ] && exit 0
  echo "NEW dependency requires human approval (invariant #7): ask the user to add the package name (or a scope wildcard like @angular/*) to .claude/approved-packages.txt, then retry." >&2
  exit 2
fi
exit 0
