#!/usr/bin/env bash
# POCDD installer — symlinks skills/pocdd/ into your agent's skills directory so
# the router and every /poc sub-command are discoverable.
#
# Local (from a clone):
#   ./setup.sh              # auto-detect installed agents
#   ./setup.sh --host claude
#
# Remote (curl one-liner — self-clones into a cache dir):
#   curl -fsSL https://raw.githubusercontent.com/DailybotHQ/pocdd-skill/main/setup.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/DailybotHQ/pocdd-skill/main/setup.sh | bash -s -- --host claude
#
# Portable Bash (no associative arrays) so it runs on macOS's stock bash 3.2.
set -euo pipefail

NAME="pocdd"
REPO_URL="${POCDD_REPO_URL:-https://github.com/DailybotHQ/pocdd-skill.git}"
# Where a curl/remote install caches the cloned repo (symlink target).
CACHE_DIR="${POCDD_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/pocdd-skill}"

# Resolve the skill source. When run from a clone, use it directly. When piped
# from curl (no local skills/pocdd), clone/update the cache and use that.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "$PWD")"
if [ -d "$SCRIPT_DIR/skills/$NAME" ]; then
  SRC="$SCRIPT_DIR/skills/$NAME"
else
  command -v git >/dev/null 2>&1 || {
    echo "error: git is required for a remote (curl) install." >&2; exit 1; }
  if [ -d "$CACHE_DIR/.git" ]; then
    echo "updating cached POCDD in $CACHE_DIR"
    git -C "$CACHE_DIR" pull --ff-only --quiet || true
  else
    echo "cloning POCDD into $CACHE_DIR"
    mkdir -p "$(dirname "$CACHE_DIR")"
    git clone --depth 1 --quiet "$REPO_URL" "$CACHE_DIR"
  fi
  SRC="$CACHE_DIR/skills/$NAME"
fi

[ -d "$SRC" ] || { echo "error: skill source not found at $SRC" >&2; exit 1; }

ALL_HOSTS="claude cursor codex windsurf copilot cline gemini opencode antigravity"

host_dir() {
  case "$1" in
    claude)      printf '%s\n' "$HOME/.claude/skills" ;;
    cursor)      printf '%s\n' "$HOME/.cursor/skills" ;;
    codex)       printf '%s\n' "$HOME/.codex/skills" ;;
    windsurf)    printf '%s\n' "$HOME/.codeium/windsurf/skills" ;;
    copilot)     printf '%s\n' "$HOME/.copilot/skills" ;;
    cline)       printf '%s\n' "$HOME/.cline/skills" ;;
    gemini)      printf '%s\n' "$HOME/.gemini/skills" ;;
    opencode)    printf '%s\n' "$HOME/.config/opencode/skills" ;;
    antigravity) printf '%s\n' "$HOME/.antigravity/skills" ;;
    *) return 1 ;;
  esac
}

install_host() {
  local host="$1" base
  base="$(host_dir "$host")" || { echo "unknown host: $host" >&2; return 1; }
  mkdir -p "$base"
  ln -sfn "$SRC" "$base/$NAME"
  echo "linked $base/$NAME -> $SRC"
}

usage() {
  echo "usage: ./setup.sh [--host <agent>]"
  echo "agents: $ALL_HOSTS"
}

main() {
  local target=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --host) target="${2:-}"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "unknown arg: $1" >&2; usage; exit 2 ;;
    esac
  done

  if [ -n "$target" ]; then
    install_host "$target"
    return
  fi

  local any=0 host base parent
  for host in $ALL_HOSTS; do
    base="$(host_dir "$host")"
    parent="$(dirname "$base")"
    if [ -d "$parent" ]; then
      install_host "$host"
      any=1
    fi
  done
  if [ "$any" -eq 0 ]; then
    echo "No known agent config dirs found. Install explicitly with --host <agent>."
    usage
  fi
}

main "$@"
