#!/usr/bin/env bash
# One-command checks for the POCDD skill pack.
#
# Runs the same gates locally that CI runs:
#   1. `bash -n` on every tracked shell script (syntax).
#   2. `shellcheck` (error severity) on every script (if installed — else skipped).
#   3. Frontmatter contract on every SKILL.md (required keys + version lockstep).
#   4. `verify.sh` against the shipped POC templates.
#   5. Ship boundary — nothing outside skills/pocdd/ is referenced at runtime.
#
# Exit code is non-zero if any check fails. No arguments.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
cd "$ROOT"

fail=0
section() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
ok()      { printf '  \033[32mok\033[0m    %s\n' "$1"; }
bad()     { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; fail=1; }
skip()    { printf '  \033[33mskip\033[0m  %s\n' "$1"; }

# Prefer the git index so untracked scratch files don't get checked; fall back to
# a find when not in a git work tree.
list() { # list <glob...>
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git ls-files -- "$@"
  else
    # shellcheck disable=SC2068
    find $@ -type f 2>/dev/null
  fi
}

# 1. Shell syntax --------------------------------------------------------------
section "shell syntax (bash -n)"
shell_scripts="$(list '*.sh')"
if [ -z "$shell_scripts" ]; then
  skip "no shell scripts found"
else
  while IFS= read -r s; do
    [ -n "$s" ] || continue
    if bash -n "$s" 2>/tmp/pocdd_bn.$$; then ok "$s"; else bad "$s"; cat /tmp/pocdd_bn.$$; fi
  done <<< "$shell_scripts"
  rm -f /tmp/pocdd_bn.$$
fi

# 2. shellcheck (optional) -----------------------------------------------------
section "shellcheck (optional)"
if command -v shellcheck >/dev/null 2>&1; then
  while IFS= read -r s; do
    [ -n "$s" ] || continue
    if shellcheck -S error "$s"; then ok "$s"; else bad "$s"; fi
  done <<< "$shell_scripts"
else
  skip "shellcheck not installed"
fi

# 3. SKILL.md frontmatter contract --------------------------------------------
section "SKILL.md frontmatter"
skills="$(list 'skills/**/SKILL.md' 'skills/*/SKILL.md')"
required_keys="name description version documentation_url user-invocable"
versions=""
if [ -z "$skills" ]; then
  bad "no SKILL.md files found"
else
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    # Frontmatter must open on line 1 and close at the next '---'.
    if [ "$(head -1 "$f")" != "---" ]; then bad "$f: missing opening '---' on line 1"; continue; fi
    fm="$(awk 'NR==1{next} /^---[[:space:]]*$/{exit} {print}' "$f")"
    missing=""
    for k in $required_keys; do
      printf '%s\n' "$fm" | grep -Eq "^${k}:" || missing="$missing $k"
    done
    if [ -n "$missing" ]; then bad "$f: missing key(s):$missing"; continue; fi
    v="$(printf '%s\n' "$fm" | sed -n 's/^version:[[:space:]]*//p' | tr -d '"'"'"' ' | head -1)"
    versions="$versions$v\n"
    ok "$f (v$v)"
  done <<< "$skills"

  # version lockstep
  uniq_versions="$(printf '%b' "$versions" | grep -v '^$' | sort -u)"
  count="$(printf '%s\n' "$uniq_versions" | grep -c .)"
  if [ "$count" -gt 1 ]; then
    bad "version mismatch across SKILL.md files: $(printf '%s ' $uniq_versions)"
  else
    ok "version lockstep: $uniq_versions"
  fi
fi

# 4. verify.sh against templates ----------------------------------------------
section "verify.sh vs templates"
verify="skills/pocdd/verify/verify.sh"
if [ -x "$verify" ] || [ -f "$verify" ]; then
  for t in skills/pocdd/templates/poc.md skills/pocdd/templates/poc.py; do
    if [ -f "$t" ]; then
      if bash "$verify" "$t" >/dev/null 2>&1; then ok "$t conforms"; else bad "$t failed verify"; fi
    fi
  done
else
  bad "$verify not found"
fi

# 5. Ship boundary -------------------------------------------------------------
# skills/pocdd/ must not reference repo-dev paths at runtime.
section "ship boundary"
leak="$(grep -rEn '(\.\./)+(README|AGENTS|CONTRIBUTING|SECURITY|CHANGELOG|setup\.sh|docs/|scripts/|\.github/)' skills/pocdd 2>/dev/null || true)"
if [ -n "$leak" ]; then
  bad "skills/pocdd references repo-dev infrastructure:"
  printf '%s\n' "$leak"
else
  ok "skills/pocdd is self-contained"
fi

# Result -----------------------------------------------------------------------
printf '\n'
if [ "$fail" -eq 0 ]; then
  printf '\033[32mAll checks passed.\033[0m\n'
  exit 0
fi
printf '\033[31mSome checks failed.\033[0m\n'
exit 1
