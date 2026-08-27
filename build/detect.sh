#!/usr/bin/env bash
# Hardware / stack / layout probes for POCDD configure.
# Source this file — do not execute it directly.
# Intentionally does NOT enable set -e / set -u.

# --- RAM (GiB available, integer floor) ---------------------------------------

pocdd_detect_ram_gib() {
  local kib=0
  if [ -r /proc/meminfo ]; then
    kib="$(awk '/^MemAvailable:/{print $2; exit}' /proc/meminfo 2>/dev/null || true)"
    if [ -z "$kib" ] || [ "$kib" -eq 0 ] 2>/dev/null; then
      kib="$(awk '/^MemTotal:/{print $2; exit}' /proc/meminfo 2>/dev/null || true)"
    fi
  elif command -v sysctl >/dev/null 2>&1; then
    # macOS: bytes
    local bytes
    bytes="$(sysctl -n hw.memsize 2>/dev/null || echo 0)"
    kib=$((bytes / 1024))
  fi
  if [ -z "$kib" ] || [ "$kib" -eq 0 ] 2>/dev/null; then
    printf '%s\n' ""
    return 1
  fi
  printf '%s\n' "$((kib / 1024 / 1024))"
}

# --- VRAM (GiB, discrete GPU if detectable; empty if none) --------------------

pocdd_detect_vram_gib() {
  local mib=""
  if command -v nvidia-smi >/dev/null 2>&1; then
    mib="$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ')"
  elif command -v rocm-smi >/dev/null 2>&1; then
    # Best-effort; formats vary — leave empty on parse failure.
    mib="$(rocm-smi --showmeminfo vram 2>/dev/null | awk '/Total/{print $NF; exit}' | tr -dc '0-9')"
  fi
  if [ -z "$mib" ] || [ "$mib" -eq 0 ] 2>/dev/null; then
    printf '%s\n' ""
    return 1
  fi
  printf '%s\n' "$((mib / 1024))"
}

# --- Recommend gaps_per_pass + profile from RAM/VRAM --------------------------
# Prints: <gaps> <profile>
# Rules (see docs/DESIGN.md):
#   RAM < 8, OR (no discrete VRAM and RAM < 12) → 1 light
#   RAM < 16 → 2 mid
#   else → 3 full
# VRAM ≥ 8 upgrades to at least full/3; VRAM ≥ 4 with RAM ≥ 8 upgrades to mid/2.

pocdd_recommend_model() {
  local ram="${1:-}"
  local vram="${2:-}"
  local gaps=2 profile=mid

  if [ -z "$ram" ]; then
    printf '%s\n' "2 mid"
    return 0
  fi

  if [ "$ram" -lt 8 ]; then
    gaps=1; profile=light
  elif [ -z "$vram" ] && [ "$ram" -lt 12 ]; then
    gaps=1; profile=light
  elif [ "$ram" -lt 16 ]; then
    gaps=2; profile=mid
  else
    gaps=3; profile=full
  fi

  if [ -n "$vram" ] && [ "$vram" -ge 8 ]; then
    gaps=3; profile=full
  elif [ -n "$vram" ] && [ "$vram" -ge 4 ] && [ "$ram" -ge 8 ] && [ "$gaps" -lt 2 ]; then
    gaps=2; profile=mid
  fi

  printf '%s %s\n' "$gaps" "$profile"
}

# --- Stack languages from cwd markers -----------------------------------------
# Prints comma-separated: python,js,go,md (md always recommended as secondary)

pocdd_detect_langs() {
  local root="${1:-.}"
  local langs=""
  if [ -f "$root/pyproject.toml" ] || [ -f "$root/requirements.txt" ] || [ -f "$root/setup.py" ]; then
    langs="${langs:+$langs,}python"
  fi
  if [ -f "$root/package.json" ]; then
    langs="${langs:+$langs,}js"
  fi
  if [ -f "$root/go.mod" ]; then
    langs="${langs:+$langs,}go"
  fi
  # Always include md for reasoned POCs
  case ",$langs," in
    *,md,*) ;;
    *) langs="${langs:+$langs,}md" ;;
  esac
  if [ -z "$langs" ] || [ "$langs" = "md" ]; then
    # No stack markers — recommend python+md (shipped default)
    langs="python,md"
  fi
  printf '%s\n' "$langs"
}

# --- Repo layout --------------------------------------------------------------
# Prints: monorepo_repositories | monorepo_apps | monorepo_packages | src_root | single_root

pocdd_detect_layout() {
  local root="${1:-.}"
  if [ -d "$root/repositories" ]; then
    printf '%s\n' "monorepo_repositories"
  elif [ -d "$root/apps" ] && [ -d "$root/packages" ]; then
    printf '%s\n' "monorepo_packages"
  elif [ -d "$root/apps" ]; then
    printf '%s\n' "monorepo_apps"
  elif [ -d "$root/packages" ]; then
    printf '%s\n' "monorepo_packages"
  elif [ -d "$root/src" ]; then
    printf '%s\n' "src_root"
  else
    printf '%s\n' "single_root"
  fi
}

pocdd_layout_hint() {
  case "${1:-single_root}" in
    monorepo_repositories)
      printf '%s\n' "Cite product code as repositories/<repo>/path/to/file.ext:LINE — never paste production code into the POC."
      ;;
    monorepo_apps)
      printf '%s\n' "Cite product code as apps/<app>/… or packages/<pkg>/… by path:LINE — never paste production code into the POC."
      ;;
    monorepo_packages)
      printf '%s\n' "Cite product code as packages/<pkg>/… or apps/<app>/… by path:LINE — never paste production code into the POC."
      ;;
    src_root)
      printf '%s\n' "Cite product code as src/… by path:LINE — never paste production code into the POC."
      ;;
    *)
      printf '%s\n' "Cite product code by path relative to the repo root (path/to/file.ext:LINE) — never paste production code into the POC."
      ;;
  esac
}

# Stack command hints for conventions / create
pocdd_stack_commands() {
  local langs="${1:-python,md}"
  local out=""
  case ",$langs," in
    *,python,*)
      out="${out}- **Python runnable POC:** \`python .pocs/<name>.py --probe\` / \`--demo\` (optional \`--json\`). Done-checks often use \`pytest\`."$'\n'
      ;;
  esac
  case ",$langs," in
    *,js,*)
      out="${out}- **JS/TS runnable POC:** \`node .pocs/<name>.js --probe\` / \`--demo\`. Done-checks often use \`npm test\` / \`npx vitest\`."$'\n'
      ;;
  esac
  case ",$langs," in
    *,go,*)
      out="${out}- **Go runnable POC:** \`go run .pocs/<name>.go -probe\` / \`-demo\`. Done-checks often use \`go test ./...\`."$'\n'
      ;;
  esac
  case ",$langs," in
    *,md,*)
      out="${out}- **Markdown reasoned POC:** no runtime — prove by reading code paths and writing findings with provenance."$'\n'
      ;;
  esac
  printf '%s' "$out"
}
