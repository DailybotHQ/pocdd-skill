#!/usr/bin/env bash
# POCDD installer — optionally configures a slim pack, then symlinks
# skills/pocdd/ into your agent's skills directory.
#
# Local (from a clone):
#   ./setup.sh                 # configure if needed, then auto-detect agents
#   ./setup.sh --host claude
#   ./setup.sh --configure     # force re-configure (interactive)
#   ./setup.sh --configure --yes --gaps 1 --profile light
#
# Remote (curl one-liner — self-clones into a cache dir):
#   curl -fsSL https://raw.githubusercontent.com/DailybotHQ/pocdd-skill/main/setup.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/DailybotHQ/pocdd-skill/main/setup.sh | bash -s -- --host claude
#
# Portable Bash (no associative arrays) so it runs on macOS's stock bash 3.2.
set -euo pipefail

NAME="pocdd"
REPO_URL="${POCDD_REPO_URL:-https://github.com/DailybotHQ/pocdd-skill.git}"
CACHE_DIR="${POCDD_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/pocdd-skill}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "$PWD")"
if [ -d "$SCRIPT_DIR/skills/$NAME" ] || [ -f "$SCRIPT_DIR/build/configure.sh" ]; then
  ROOT="$SCRIPT_DIR"
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
  ROOT="$CACHE_DIR"
fi

SRC="$ROOT/skills/$NAME"
CONFIGURE="$ROOT/build/configure.sh"
ALL_HOSTS="claude cursor codex windsurf copilot cline gemini opencode antigravity"

DO_CONFIGURE=0
CONFIGURE_ARGS=()
HOST_TARGET=""
SKIP_CONFIGURE=0

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

maybe_configure() {
  if [ "$SKIP_CONFIGURE" -eq 1 ]; then
    return 0
  fi
  if [ ! -f "$CONFIGURE" ]; then
    return 0
  fi
  # Force, or first-time (no local profile) when stdin is a TTY / --yes passed
  if [ "$DO_CONFIGURE" -eq 1 ]; then
    echo "Running ./configure …"
    bash "$CONFIGURE" "${CONFIGURE_ARGS[@]+"${CONFIGURE_ARGS[@]}"}"
    return 0
  fi
  if [ ! -f "$ROOT/.pocdd/profile.json" ]; then
    if [ -t 0 ] || printf '%s\n' "${CONFIGURE_ARGS[@]+"${CONFIGURE_ARGS[@]}"}" | grep -q -- '--yes'; then
      echo "No .pocdd/profile.json yet — running configure (recommendations + questions)."
      echo "(Pass --skip-configure to keep the committed default pack.)"
      bash "$CONFIGURE" "${CONFIGURE_ARGS[@]+"${CONFIGURE_ARGS[@]}"}"
    else
      echo "Using committed skills/pocdd/ (run ./configure or ./setup.sh --configure to tune)."
    fi
  fi
}

usage() {
  echo "usage: ./setup.sh [--host <agent>] [--configure [--yes] …] [--skip-configure]"
  echo "agents: $ALL_HOSTS"
  echo ""
  echo "  --configure       Run build/configure.sh before linking (extra flags forwarded)"
  echo "  --skip-configure  Never run configure; link the committed pack as-is"
  echo "  Configure flags:  --yes --lang … --gaps … --profile … --layout …"
}

main() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --host) HOST_TARGET="${2:-}"; shift 2 ;;
      --configure) DO_CONFIGURE=1; shift ;;
      --skip-configure) SKIP_CONFIGURE=1; shift ;;
      --yes|--lang|--gaps|--layout|--profile|--out|--detect-root)
        # Forward configure flags (and their values when needed)
        DO_CONFIGURE=1
        case "$1" in
          --yes) CONFIGURE_ARGS+=("$1"); shift ;;
          *) CONFIGURE_ARGS+=("$1" "${2:-}"); shift 2 ;;
        esac
        ;;
      -h|--help) usage; exit 0 ;;
      *) echo "unknown arg: $1" >&2; usage; exit 2 ;;
    esac
  done

  maybe_configure

  [ -d "$SRC" ] || { echo "error: skill source not found at $SRC" >&2; exit 1; }

  if [ -n "$HOST_TARGET" ]; then
    install_host "$HOST_TARGET"
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
