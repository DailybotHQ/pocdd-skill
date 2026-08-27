#!/usr/bin/env bash
# One-command checks for the POCDD skill pack.
#
# Runs the same gates locally that CI runs:
#   1. `bash -n` on every tracked shell script (syntax) + build/configure helpers.
#   2. `shellcheck` (error severity) on every script (if installed — else skipped).
#   3. Frontmatter contract on every SKILL.md (required keys + version lockstep).
#   4. `verify.sh` against the shipped POC templates.
#   5. Ship boundary — nothing outside skills/pocdd/ is referenced at runtime.
#   6. Light-context — router must not mandate loading full methodology.
#   7. configure --yes determinism for the committed mid defaults.
#   8. Installation validation — setup.sh in an isolated HOME (scripts/test-install.sh).
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
# Always include build helpers + root configure even if not yet tracked
extra_scripts=""
for s in configure build/configure.sh build/detect.sh \
         build/fragments/shared/context.sh build/fragments/shared/verify.sh \
         skills/pocdd/shared/context.sh skills/pocdd/verify/verify.sh \
         setup.sh scripts/check.sh scripts/test-install.sh; do
  [ -f "$s" ] || continue
  case $'\n'"$shell_scripts"$'\n' in
    *$'\n'"$s"$'\n'*) ;;
    *) extra_scripts="${extra_scripts}${s}"$'\n' ;;
  esac
done
shell_scripts="$(printf '%s\n%s' "$shell_scripts" "$extra_scripts" | grep -v '^$' | sort -u)"

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
# Fallback when pack is regenerated but not yet git-added
if [ -z "$skills" ]; then
  skills="$(find skills/pocdd -name 'SKILL.md' -type f 2>/dev/null | sort)"
fi
required_keys="name description version documentation_url user-invocable"
versions=""
if [ -z "$skills" ]; then
  bad "no SKILL.md files found"
else
  while IFS= read -r f; do
    [ -n "$f" ] || continue
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
  any_tmpl=0
  for t in skills/pocdd/templates/poc.md skills/pocdd/templates/poc.py \
           skills/pocdd/templates/poc.js skills/pocdd/templates/poc.go; do
    if [ -f "$t" ]; then
      any_tmpl=1
      if bash "$verify" "$t" >/dev/null 2>&1; then ok "$t conforms"; else bad "$t failed verify"; fi
    fi
  done
  if [ "$any_tmpl" -eq 0 ]; then
    bad "no templates under skills/pocdd/templates/"
  fi
else
  bad "$verify not found"
fi

# 5. Ship boundary -------------------------------------------------------------
section "ship boundary"
leak="$(grep -rEn '(\.\./)+(README|AGENTS|CONTRIBUTING|SECURITY|CHANGELOG|setup\.sh|docs/|scripts/|build/|\.github/)' skills/pocdd 2>/dev/null || true)"
if [ -n "$leak" ]; then
  bad "skills/pocdd references repo-dev infrastructure:"
  printf '%s\n' "$leak"
else
  ok "skills/pocdd is self-contained"
fi

# 6. Light-context assertions --------------------------------------------------
section "light-context"
if [ -f skills/pocdd/SKILL.md ]; then
  if grep -Eqi 'Read both before acting' skills/pocdd/SKILL.md; then
    bad "router still mandates reading full methodology ('Read both before acting')"
  else
    ok "router does not mandate 'Read both before acting'"
  fi
  if grep -Eq 'spec/POCDD\.md' skills/pocdd/SKILL.md; then
    bad "router still references spec/POCDD.md (methodology must stay outside the pack)"
  else
    ok "router does not reference spec/POCDD.md"
  fi
  if [ -d skills/pocdd/spec ]; then
    bad "skills/pocdd/spec/ must not ship (methodology lives in docs/POCDD.md)"
  else
    ok "no skills/pocdd/spec/ directory"
  fi
  if [ -f skills/pocdd/.generated ]; then
    ok "skills/pocdd/.generated present"
  else
    bad "missing skills/pocdd/.generated (pack should be produced by ./configure)"
  fi
  if grep -Eq 'gaps_per_pass|gaps per' skills/pocdd/work/SKILL.md skills/pocdd/shared/conventions.md 2>/dev/null; then
    ok "gaps_per_pass baked into work/conventions"
  else
    bad "gaps_per_pass not found in work skill or conventions"
  fi
else
  bad "skills/pocdd/SKILL.md missing"
fi

# 7. configure determinism (mid defaults) --------------------------------------
section "configure --yes determinism"
if [ -x build/configure.sh ] || [ -f build/configure.sh ]; then
  tmp1="$(mktemp -d)"
  tmp2="$(mktemp -d)"
  # Generate into temps without clobbering the committed pack / profile
  if POCDD_PROFILE_DIR="$tmp1/profile" bash build/configure.sh --yes \
        --lang python,md --gaps 2 --profile mid --layout single_root \
        --out "$tmp1/pack" --detect-root "$ROOT" >/tmp/pocdd_cfg1.$$ 2>&1 \
     && POCDD_PROFILE_DIR="$tmp2/profile" bash build/configure.sh --yes \
        --lang python,md --gaps 2 --profile mid --layout single_root \
        --out "$tmp2/pack" --detect-root "$ROOT" >/tmp/pocdd_cfg2.$$ 2>&1; then
    if diff -ru "$tmp1/pack" "$tmp2/pack" >/tmp/pocdd_cfgdiff.$$ 2>&1; then
      ok "configure --yes mid defaults is deterministic"
    else
      bad "configure produced different packs across two identical runs"
      head -50 /tmp/pocdd_cfgdiff.$$
    fi
  else
    bad "configure --yes failed"
    cat /tmp/pocdd_cfg1.$$ /tmp/pocdd_cfg2.$$ 2>/dev/null | tail -40
  fi
  rm -rf "$tmp1" "$tmp2"
  rm -f /tmp/pocdd_cfg1.$$ /tmp/pocdd_cfg2.$$ /tmp/pocdd_cfgdiff.$$
else
  bad "build/configure.sh not found"
fi

# 8. Installation validation -------------------------------------------------
section "installation validation"
install_test="$HERE/test-install.sh"
if [ -f "$install_test" ]; then
  chmod +x "$install_test" 2>/dev/null || true
  if bash "$install_test"; then
    ok "setup.sh install path is valid"
  else
    bad "installation validation failed (see above)"
  fi
else
  bad "$install_test not found"
fi

# Result -----------------------------------------------------------------------
printf '\n'
if [ "$fail" -eq 0 ]; then
  printf '\033[32mAll checks passed.\033[0m\n'
  exit 0
fi
printf '\033[31mSome checks failed.\033[0m\n'
exit 1
