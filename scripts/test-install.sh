#!/usr/bin/env bash
# Installation validation — exercises setup.sh in an isolated HOME and asserts the
# linked pack is discoverable and loadable. Invoked by scripts/check.sh (CI).
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

fail=0
ok()   { printf '  \033[32mok\033[0m    %s\n' "$1"; }
bad()  { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; fail=1; }

TMP_HOME=""
cleanup() {
  if [ -n "$TMP_HOME" ] && [ -d "$TMP_HOME" ]; then
    rm -rf "$TMP_HOME"
  fi
}
trap cleanup EXIT

TMP_HOME="$(mktemp -d)"
export HOME="$TMP_HOME"
mkdir -p "$HOME/.cursor"

INSTALL_ROOT="$HOME/.cursor/skills/pocdd"
EXPECTED_SUBSKILLS="create work status list implement archive remove clear verify"
REQUIRED_FILES="SKILL.md shared/conventions.md shared/context.sh verify/verify.sh templates/poc.md"

if ! bash "$ROOT/setup.sh" --host cursor --skip-configure >/tmp/pocdd_install.$$ 2>&1; then
  bad "setup.sh --host cursor --skip-configure failed"
  tail -20 /tmp/pocdd_install.$$
  rm -f /tmp/pocdd_install.$$
  exit 1
fi
rm -f /tmp/pocdd_install.$$
ok "setup.sh --host cursor --skip-configure succeeded"

if [ ! -L "$HOME/.cursor/skills/pocdd" ]; then
  bad "expected symlink at ~/.cursor/skills/pocdd"
elif [ ! -d "$INSTALL_ROOT" ]; then
  bad "install path is not a directory: $INSTALL_ROOT"
else
  link_target="$(readlink -f "$HOME/.cursor/skills/pocdd" 2>/dev/null || readlink "$HOME/.cursor/skills/pocdd")"
  expected_target="$(cd "$ROOT/skills/pocdd" && pwd -P)"
  if [ "$link_target" != "$expected_target" ]; then
    bad "symlink target mismatch (got $link_target, want $expected_target)"
  else
    ok "symlink ~/.cursor/skills/pocdd -> $expected_target"
  fi
fi

for rel in $REQUIRED_FILES; do
  if [ -f "$INSTALL_ROOT/$rel" ]; then
    ok "installed pack has $rel"
  else
    bad "missing $rel in installed pack"
  fi
done

for cmd in $EXPECTED_SUBSKILLS; do
  if [ -f "$INSTALL_ROOT/$cmd/SKILL.md" ]; then
    ok "sub-skill $cmd/SKILL.md present"
  else
    bad "missing sub-skill $cmd/SKILL.md"
  fi
done

if [ -f "$INSTALL_ROOT/SKILL.md" ]; then
  if [ "$(head -1 "$INSTALL_ROOT/SKILL.md")" = "---" ]; then
    ok "router SKILL.md has YAML frontmatter"
  else
    bad "router SKILL.md missing opening frontmatter"
  fi
fi

if [ -f "$INSTALL_ROOT/verify/verify.sh" ]; then
  if bash "$INSTALL_ROOT/verify/verify.sh" "$INSTALL_ROOT/templates/poc.md" >/tmp/pocdd_v.$$ 2>&1; then
    ok "installed verify.sh accepts shipped poc.md template"
  else
    bad "installed verify.sh failed on poc.md template"
    tail -10 /tmp/pocdd_v.$$
  fi
  rm -f /tmp/pocdd_v.$$
fi

if [ -f "$INSTALL_ROOT/shared/context.sh" ]; then
  # shellcheck source=/dev/null
  if ( . "$INSTALL_ROOT/shared/context.sh" && pocdd_dir >/dev/null ); then
    ok "installed context.sh sources and pocdd_dir works"
  else
    bad "installed context.sh failed to source or pocdd_dir errored"
  fi
fi

if [ "$fail" -eq 0 ]; then
  exit 0
fi
exit 1
