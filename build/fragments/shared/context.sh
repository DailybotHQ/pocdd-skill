#!/usr/bin/env bash
# Shared context for the POCDD skill.
#
# Source this file (do not execute it) to resolve the `.pocs/` directory and
# enumerate POC files in a tool-agnostic way:
#
#     . "$(dirname "$0")/../shared/context.sh"
#     dir="$(pocdd_ensure_dir)"
#
# The `.pocs/` location is, in order of precedence:
#   1. $POCS_DIR (explicit override)
#   2. <git repo root>/.pocs
#   3. <current dir>/.pocs   (when not in a git repo)
#
# Intentionally does NOT enable `set -e`/`set -u` so sourcing never alters the
# caller's shell options.

# Absolute path of the repo root (or the current dir outside a git repo).
pocdd_repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

# Absolute path of the `.pocs/` directory (not guaranteed to exist).
pocdd_dir() {
  if [ -n "${POCS_DIR:-}" ]; then
    printf '%s\n' "${POCS_DIR%/}"
  else
    printf '%s/.pocs\n' "$(pocdd_repo_root)"
  fi
}

# Ensure `.pocs/` exists and print its path.
pocdd_ensure_dir() {
  local d
  d="$(pocdd_dir)"
  mkdir -p "$d"
  printf '%s\n' "$d"
}

# List POC files (one per line). Skips dotfiles (tokens) and caches.
pocdd_list() {
  local d
  d="$(pocdd_dir)"
  [ -d "$d" ] || return 0
  find "$d" -maxdepth 1 -type f ! -name '.*' 2>/dev/null \
    | grep -Ev '/(__pycache__|node_modules)/' \
    | sort
}

# Resolve a POC by <name> (with or without extension). Prints the file path if a
# single match is found; non-zero on no/ambiguous match.
pocdd_resolve() {
  local name="$1" d match
  d="$(pocdd_dir)"
  [ -d "$d" ] || return 1
  if [ -f "$d/$name" ]; then
    printf '%s\n' "$d/$name"
    return 0
  fi
  match="$(find "$d" -maxdepth 1 -type f -name "${name}.*" 2>/dev/null | sort)"
  [ -n "$match" ] || return 1
  [ "$(printf '%s\n' "$match" | wc -l)" -eq 1 ] || return 2
  printf '%s\n' "$match"
}
