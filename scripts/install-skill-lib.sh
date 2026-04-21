#!/usr/bin/env bash
# install-skill-lib.sh — reusable skill dependency installer with scope control.
#
# Usage: source this file from your setup.sh, then call install_skill.
#
#   source "$(dirname "$0")/install-skill-lib.sh"
#
#   install_skill "readme-craft" "motiful/readme-craft"              # default: global
#   install_skill "project-only" "org/skill" "project"               # project-level
#
# Scope values:
#   global  (default) — install to user-level (~/.claude/skills/ + ~/.agents/skills/)
#   project           — install to current working directory (.claude/skills/ + .agents/skills/)
#
# Custom absolute paths are NOT supported in v1 (npx skills add does not accept
# arbitrary paths). Planned for v0.2 via git clone fallback (see install-cascade-design.md §5.2).
#
# Requires: node + npx in PATH. Calls `npx skills add <repo> [-g] -y` under the hood.
#
# Cascade: after a successful install, runs the installed skill's own
# scripts/setup.sh to pull deeper dependencies. This mirrors npm's postinstall
# semantics that `npx skills add` itself does not provide. Recursion is capped
# by the SKILL_DEPS_DEPTH env var (max depth: 5).
#
# Activation hints: this lib does NOT detect or run any activate script. A skill
# that needs activation (e.g. Protocol skills modifying global rule files) must
# print its own hint from the tail of its scripts/setup.sh. The cascade will
# surface that hint naturally because we run the installed skill's setup.sh.

# --- skill_installed: check if a skill is already installed in the given scope ---
# Usage: skill_installed <name> [scope]
#   scope: "any" (default, checks both), "global", "project"
skill_installed() {
  local name=$1 scope=${2:-any}

  if [ "$scope" = "any" ] || [ "$scope" = "global" ]; then
    for root in \
      "$HOME/.claude/skills" \
      "$HOME/.agents/skills" \
      "$HOME/.copilot/skills" \
      "$HOME/.cursor/skills" \
      "$HOME/.codeium/windsurf/skills"; do
      [ -d "$root/$name" ] && return 0
    done
  fi

  if [ "$scope" = "any" ] || [ "$scope" = "project" ]; then
    [ -d "$PWD/.claude/skills/$name" ] && return 0
    [ -d "$PWD/.agents/skills/$name" ] && return 0
  fi

  return 1
}

# --- skill_install_path: resolve an installed skill's directory ---
# Usage: skill_install_path <name> [scope]
#   scope: "any" (default), "global", "project"
skill_install_path() {
  local name=$1 scope=${2:-any}

  if [ "$scope" = "any" ] || [ "$scope" = "global" ]; then
    for root in \
      "$HOME/.claude/skills" \
      "$HOME/.agents/skills" \
      "$HOME/.copilot/skills" \
      "$HOME/.cursor/skills" \
      "$HOME/.codeium/windsurf/skills"; do
      if [ -d "$root/$name" ]; then
        printf '%s\n' "$root/$name"
        return 0
      fi
    done
  fi

  if [ "$scope" = "any" ] || [ "$scope" = "project" ]; then
    if [ -d "$PWD/.claude/skills/$name" ]; then
      printf '%s\n' "$PWD/.claude/skills/$name"
      return 0
    fi
    if [ -d "$PWD/.agents/skills/$name" ]; then
      printf '%s\n' "$PWD/.agents/skills/$name"
      return 0
    fi
  fi

  return 1
}

# --- install_skill: install + cascade-run its setup.sh ---
# Usage: install_skill <name> <org/repo> [scope]
#   scope: "global" (default) | "project"
install_skill() {
  local name=$1 repo=$2
  local scope=${3:-global}

  # Validate scope
  case "$scope" in
    global|project) ;;
    *)
      echo "  ERROR: install_skill: unsupported scope '$scope'"
      echo "  Accepted: global (default) | project"
      echo "  Custom absolute paths planned for v0.2."
      return 1
      ;;
  esac

  if skill_installed "$name" "$scope"; then
    echo "  $name: installed ($scope)"
    return 0
  fi

  echo "  $name: installing ($scope)..."
  # Build npx flags: always -y; add -g only for global
  local npx_flags=("-y")
  [ "$scope" = "global" ] && npx_flags=("-g" "-y")

  if ! npx skills add "$repo" "${npx_flags[@]}" 2>/dev/null; then
    echo "  ERROR: failed to install $name ($scope)"
    echo "  Manual fix: npx skills add $repo ${npx_flags[*]}"
    return 1
  fi
  echo "  $name: installed"

  local path
  path=$(skill_install_path "$name" "$scope") || {
    echo "  WARN: $name installed but install path not detectable — skipping cascade"
    return 0
  }

  # Cascade: run the newly installed skill's setup.sh if present.
  # SKILL_DEPS_DEPTH caps recursion to prevent cycles.
  local depth=${SKILL_DEPS_DEPTH:-0}
  if [ "$depth" -ge 5 ]; then
    echo "  WARN: cascade depth $depth reached on $name — stopping recursion"
    return 0
  fi

  if [ -x "$path/scripts/setup.sh" ]; then
    echo "  $name: running its setup.sh..."
    if ! SKILL_DEPS_DEPTH=$((depth + 1)) bash "$path/scripts/setup.sh"; then
      echo "  ERROR: $name's setup.sh failed"
      return 1
    fi
  fi

  return 0
}
